import ComposableArchitecture
import MarioKit

@Reducer
struct AppFeature {
  /// Everyone starts with 5 lives, like the classic games.
  static let startLives = 5

  @ObservableState
  struct State: Equatable {
    /// Which menu screen is showing (when neither game nor editor is up).
    enum Screen: Equatable {
      case main, levelSelect, options, about
    }

    var levelNames: [String]
    var screen: Screen = .main
    @Shared(.unlockedLevels) var unlockedLevels: Int
    @Shared(.soundEnabled) var soundEnabled: Bool
    @Shared(.musicEnabled) var musicEnabled: Bool
    @Presents var editor: EditorFeature.State?
    /// Presented on top of the menu *or* the editor ("Play Level").
    @Presents var game: GameFeature.State?

    init() {
      let catalog = (try? BundledAssets.catalog()) ?? LevelCatalog()
      levelNames = catalog.levelFileNames
    }
  }

  enum Action {
    case editor(PresentationAction<EditorFeature.Action>)
    case editorTapped
    case game(PresentationAction<GameFeature.Action>)
    case levelSelected(Int)
    case musicToggled
    case navigated(State.Screen)
    case newGameTapped
    case soundToggled
    case task
  }

  @Dependency(\.audioPlayer) var audioPlayer

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .editor(.presented(.delegate(.backToMenu))):
        state.editor = nil
        return .none

      case .editor(.presented(.delegate(.playLevel(let document)))):
        state.game = try? GameFeature.State(
          levelIndex: 0,
          levelNames: [],
          lives: Self.startLives,
          customLevel: document,
          launchedFromEditor: true
        )
        return .none

      case .editor:
        return .none

      case .editorTapped:
        state.editor = EditorFeature.State(levelNames: state.levelNames)
        return .none

      case .game(.presented(.delegate(.backToMenu))):
        state.game = nil
        state.screen = .main
        return .none

      case .game(.presented(.delegate(.backToEditor))):
        state.game = nil  // editor state is still there underneath
        return .none

      case .game:
        return .none

      case .levelSelected(let index):
        guard index < state.unlockedLevels, state.levelNames.indices.contains(index)
        else { return .none }
        state.game = try? GameFeature.State(
          levelIndex: index,
          levelNames: state.levelNames,
          lives: Self.startLives
        )
        return .none

      case .musicToggled:
        state.$musicEnabled.withLock { $0.toggle() }
        let enabled = state.musicEnabled
        return .run { _ in await audioPlayer.setMusicEnabled(enabled) }

      case .navigated(let screen):
        state.screen = screen
        return .none

      case .newGameTapped:
        state.game = try? GameFeature.State(
          levelIndex: 0,
          levelNames: state.levelNames,
          lives: Self.startLives
        )
        return .none

      case .soundToggled:
        state.$soundEnabled.withLock { $0.toggle() }
        let enabled = state.soundEnabled
        return .run { _ in await audioPlayer.setSoundEnabled(enabled) }

      case .task:
        // Apply the persisted audio settings on launch.
        let sound = state.soundEnabled
        let music = state.musicEnabled
        return .run { _ in
          await audioPlayer.setSoundEnabled(sound)
          await audioPlayer.setMusicEnabled(music)
        }
      }
    }
    .ifLet(\.$editor, action: \.editor) {
      EditorFeature()
    }
    .ifLet(\.$game, action: \.game) {
      GameFeature()
    }
  }
}
