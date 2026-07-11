import ComposableArchitecture
import Foundation
import MarioKit

/// Keys the game cares about while they're held.
enum HeldKey: Hashable, Sendable {
  case left, right, jump
}

@Reducer
struct GameFeature {
  @ObservableState
  struct State: Equatable {
    var session: GameSession
    var levelIndex: Int
    var levelNames: [String]
    var lives: Int
    var overlay: Overlay?
    var paused = false

    var heldKeys: Set<HeldKey> = []
    var pendingFire = false

    /// True when this game was launched from the editor (changes the exit flow).
    var launchedFromEditor = false
    /// The editor's document, replayed when launched from the editor.
    var customLevel: LevelDocument?
    /// Persisted progression: completing bundled level N unlocks N+1.
    @Shared(.unlockedLevels) var unlockedLevels: Int

    var levelName: String {
      guard levelNames.indices.contains(levelIndex) else { return "Custom Level" }
      return levelNames[levelIndex]
    }

    /// Friendly name shown on the HUD and the level-intro splash.
    var levelDisplayName: String {
      guard levelNames.indices.contains(levelIndex) else { return "CUSTOM LEVEL" }
      return "LEVEL \(levelIndex + 1)"
    }

    enum Overlay: Equatable {
      /// Shown briefly when a level first loads (new game, level select, or
      /// advancing to the next level after completing one).
      case intro(String)
      /// The black interstitial after a death: "MARIO × lives".
      case lives
      case gameOver
      case won
    }

    init(
      levelIndex: Int,
      levelNames: [String],
      lives: Int = 5,
      customLevel: LevelDocument? = nil,
      launchedFromEditor: Bool = false
    ) throws {
      let document: LevelDocument
      if let customLevel {
        document = customLevel
      } else {
        document = try BundledAssets.level(named: levelNames[levelIndex])
      }
      self.session = try GameSession(level: document)
      self.levelIndex = levelIndex
      self.levelNames = levelNames
      self.lives = lives
      self.customLevel = customLevel
      self.launchedFromEditor = launchedFromEditor
    }
  }

  enum Action {
    case backToMenuTapped
    case delegate(Delegate)
    case keyDown(HeldKey)
    case keyUp(HeldKey)
    case firePressed
    case introFinished
    case livesScreenFinished
    case overlayConfirmed
    case pauseToggled
    case restartTapped
    case task
    case tick

    @CasePathable
    enum Delegate {
      case backToMenu
      case backToEditor
    }
  }

  enum CancelID { case tick }

  @Dependency(\.audioPlayer) var audioPlayer
  @Dependency(\.continuousClock) var clock

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .backToMenuTapped:
        return .concatenate(
          .run { _ in await audioPlayer.stopMusic() },
          .send(.delegate(state.launchedFromEditor ? .backToEditor : .backToMenu))
        )

      case .delegate:
        return .none

      case .keyDown(let key):
        state.heldKeys.insert(key)
        return .none

      case .keyUp(let key):
        state.heldKeys.remove(key)
        return .none

      case .firePressed:
        state.pendingFire = true
        return .none

      case .introFinished:
        if case .intro = state.overlay { state.overlay = nil }
        return .none

      case .livesScreenFinished:
        guard state.overlay == .lives else { return .none }
        state.overlay = nil
        return reload(&state, levelIndex: state.levelIndex)

      case .overlayConfirmed:
        switch state.overlay {
        case .gameOver, .won:
          return .concatenate(
            .run { _ in await audioPlayer.stopMusic() },
            .send(.delegate(state.launchedFromEditor ? .backToEditor : .backToMenu))
          )
        case .intro, .lives, nil:
          return .none
        }

      case .pauseToggled:
        state.paused.toggle()
        return .none

      case .restartTapped:
        // Restarting mid-death-animation would skip the life loss.
        guard !state.session.world.marioDying else { return .none }
        return reload(&state, levelIndex: state.levelIndex)

      case .task:
        let music = Self.music(for: state.levelIndex)
        return .merge(
          .run { _ in await audioPlayer.playMusic(music) },
          .run { send in
            for await _ in clock.timer(interval: .milliseconds(50)) {
              await send(.tick)
            }
          }
          .cancellable(id: CancelID.tick, cancelInFlight: true),
          introEffect(&state)
        )

      case .tick:
        guard !state.paused, state.overlay == nil else { return .none }

        let input = GameInput(
          left: state.heldKeys.contains(.left),
          right: state.heldKeys.contains(.right),
          jump: state.heldKeys.contains(.jump),
          fire: state.pendingFire
        )
        state.pendingFire = false

        let events = state.session.advance(input)
        return handle(events, &state)
      }
    }
  }

  private func handle(_ events: [GameEvent], _ state: inout State) -> Effect<Action> {
    var effects: [Effect<Action>] = []
    for event in events {
      switch event {
      case .play(let sound):
        effects.append(.run { _ in await audioPlayer.playEffect(sound) })

      case .extraLife:
        state.lives += 1

      case .marioDying:
        // The engine freezes and plays the death animation; the jingle is a
        // regular `.play(.death)` event. Just cut the music.
        effects.append(.run { _ in await audioPlayer.stopMusic() })

      case .marioDied:
        state.lives -= 1
        if state.lives <= 0 {
          state.overlay = .gameOver
        } else {
          state.overlay = .lives
          effects.append(
            .run { send in
              try await clock.sleep(for: .seconds(2))
              await send(.livesScreenFinished)
            })
        }

      case .levelCompleted:
        if state.customLevel != nil {
          state.overlay = .won
        } else {
          let unlocked = min(state.levelNames.count, state.levelIndex + 2)
          state.$unlockedLevels.withLock { $0 = max($0, unlocked) }
          if state.levelIndex + 1 < state.levelNames.count {
            effects.append(reload(&state, levelIndex: state.levelIndex + 1, showIntro: true))
          } else {
            state.overlay = .won
          }
        }
      }
    }
    return .merge(effects)
  }

  /// Rebuild the world for the given level (same level = death reload, next
  /// level = progression) and restart its music. `showIntro` shows the level
  /// splash — only for progression, not a same-level death respawn.
  private func reload(_ state: inout State, levelIndex: Int, showIntro: Bool = false) -> Effect<Action> {
    let document: LevelDocument?
    if let custom = state.customLevel {
      document = custom
    } else {
      document = try? BundledAssets.level(named: state.levelNames[levelIndex])
    }
    guard let document, let session = try? GameSession(level: document) else {
      // A bundled level that fails to load is unrecoverable; bail out.
      return .send(.delegate(state.launchedFromEditor ? .backToEditor : .backToMenu))
    }

    state.session = session
    state.levelIndex = levelIndex
    state.heldKeys = []
    state.pendingFire = false

    // Always restart the music: a death reload stopped it for the jingle.
    let music = Self.music(for: levelIndex)
    let musicEffect = Effect<Action>.run { _ in await audioPlayer.playMusic(music) }
    return showIntro ? .merge(musicEffect, introEffect(&state)) : musicEffect
  }

  /// Shows the "entering a level" splash and schedules its auto-dismiss.
  private func introEffect(_ state: inout State) -> Effect<Action> {
    state.overlay = .intro(state.levelDisplayName)
    return .run { send in
      try await clock.sleep(for: .seconds(1.5))
      await send(.introFinished)
    }
  }

  /// The two legacy tracks alternate across the level list.
  static func music(for levelIndex: Int) -> String {
    levelIndex % 2 == 0 ? "level1.mp3" : "level2.mp3"
  }
}
