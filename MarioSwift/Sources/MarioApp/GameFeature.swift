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
    var pendingEnter = false

    /// True when this game was launched from the editor (changes the exit flow).
    var launchedFromEditor = false
    /// The editor's document, replayed when launched from the editor.
    var customLevel: LevelDocument?

    var levelName: String {
      guard levelNames.indices.contains(levelIndex) else { return "Custom Level" }
      return levelNames[levelIndex]
    }

    enum Overlay: Equatable {
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
    case enterPressed
    case overlayConfirmed
    case pauseToggled
    case restartTapped
    case task
    case tick

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

      case .enterPressed:
        state.pendingEnter = true
        return .none

      case .overlayConfirmed:
        switch state.overlay {
        case .gameOver, .won:
          return .concatenate(
            .run { _ in await audioPlayer.stopMusic() },
            .send(.delegate(state.launchedFromEditor ? .backToEditor : .backToMenu))
          )
        case nil:
          return .none
        }

      case .pauseToggled:
        state.paused.toggle()
        return .none

      case .restartTapped:
        return reload(&state, levelIndex: state.levelIndex)

      case .task:
        let music = state.levelIndex == 0 ? "level1.mp3" : "level2.mp3"
        return .merge(
          .run { _ in await audioPlayer.playMusic(music) },
          .run { send in
            for await _ in clock.timer(interval: .milliseconds(50)) {
              await send(.tick)
            }
          }
          .cancellable(id: CancelID.tick, cancelInFlight: true)
        )

      case .tick:
        guard !state.paused, state.overlay == nil else { return .none }

        let input = GameInput(
          left: state.heldKeys.contains(.left),
          right: state.heldKeys.contains(.right),
          jump: state.heldKeys.contains(.jump),
          fire: state.pendingFire,
          enter: state.pendingEnter
        )
        state.pendingFire = false
        state.pendingEnter = false

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

      case .marioDied:
        state.lives -= 1
        if state.lives <= 0 {
          state.overlay = .gameOver
        } else {
          effects.append(reload(&state, levelIndex: state.levelIndex))
        }

      case .levelCompleted:
        if state.customLevel != nil {
          state.overlay = .won
        } else if state.levelIndex + 1 < state.levelNames.count {
          effects.append(reload(&state, levelIndex: state.levelIndex + 1))
        } else {
          state.overlay = .won
        }
      }
    }
    return .merge(effects)
  }

  /// Rebuild the world for the given level (same level = death reload, next
  /// level = progression) and restart its music.
  private func reload(_ state: inout State, levelIndex: Int) -> Effect<Action> {
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

    let previousIndex = state.levelIndex
    state.session = session
    state.levelIndex = levelIndex
    state.heldKeys = []
    state.pendingFire = false
    state.pendingEnter = false

    guard previousIndex != levelIndex else { return .none }
    let music = levelIndex == 0 ? "level1.mp3" : "level2.mp3"
    return .run { _ in await audioPlayer.playMusic(music) }
  }
}
