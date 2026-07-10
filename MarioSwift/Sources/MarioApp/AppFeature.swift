import ComposableArchitecture
import MarioKit

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var levelNames: [String]
    var lives: Int
    var selectedLevelIndex = 0
    @Presents var game: GameFeature.State?

    init() {
      let catalog = (try? BundledAssets.catalog()) ?? LevelCatalog()
      levelNames = catalog.levelFileNames
      lives = catalog.marioLives
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case game(PresentationAction<GameFeature.Action>)
    case playTapped
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .game(.presented(.delegate(.backToMenu))),
        .game(.presented(.delegate(.backToEditor))):
        state.game = nil
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
    .ifLet(\.$game, action: \.game) {
      GameFeature()
    }
  }
}
