import ComposableArchitecture
import MarioKit

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var levelNames: [String]
    var lives: Int
    var selectedLevelIndex = 0
    @Presents var editor: EditorFeature.State?
    /// Presented on top of the menu *or* the editor ("Play Level").
    @Presents var game: GameFeature.State?

    init() {
      let catalog = (try? BundledAssets.catalog()) ?? LevelCatalog()
      levelNames = catalog.levelFileNames
      lives = catalog.marioLives
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case editor(PresentationAction<EditorFeature.Action>)
    case editorTapped
    case game(PresentationAction<GameFeature.Action>)
    case playTapped
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .editor(.presented(.delegate(.backToMenu))):
        state.editor = nil
        return .none

      case .editor(.presented(.delegate(.playLevel(let document)))):
        state.game = try? GameFeature.State(
          levelIndex: 0,
          levelNames: [],
          lives: state.lives,
          customLevel: document,
          launchedFromEditor: true
        )
        return .none

      case .editor:
        return .none

      case .editorTapped:
        state.editor = EditorFeature.State()
        return .none

      case .game(.presented(.delegate(.backToMenu))):
        state.game = nil
        return .none

      case .game(.presented(.delegate(.backToEditor))):
        state.game = nil  // editor state is still there underneath
        return .none

      case .game:
        return .none

      case .playTapped:
        state.game = try? GameFeature.State(
          levelIndex: state.selectedLevelIndex,
          levelNames: state.levelNames,
          lives: state.lives
        )
        return .none
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
