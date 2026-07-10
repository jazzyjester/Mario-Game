import AppKit
import ComposableArchitecture
import Foundation
import MarioKit

/// Open/save panels as a dependency so the reducer stays testable.
@DependencyClient
struct FileDialogClient {
  var openXML: @Sendable () async -> URL?
  var saveXML: @Sendable (_ suggestedName: String) async -> URL?
}

extension FileDialogClient: DependencyKey {
  static let liveValue = FileDialogClient(
    openXML: {
      await MainActor.run {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.xml]
        panel.allowsMultipleSelection = false
        panel.message = "Open a Mario level (legacy XML format)"
        return panel.runModal() == .OK ? panel.url : nil
      }
    },
    saveXML: { suggestedName in
      await MainActor.run {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.xml]
        panel.nameFieldStringValue = suggestedName
        panel.message = "Save Mario level"
        return panel.runModal() == .OK ? panel.url : nil
      }
    }
  )

  static let testValue = FileDialogClient(openXML: { nil }, saveXML: { _ in nil })
}

extension DependencyValues {
  var fileDialog: FileDialogClient {
    get { self[FileDialogClient.self] }
    set { self[FileDialogClient.self] = newValue }
  }
}

/// Parameters applied to newly placed objects (the legacy editor's
/// per-object properties dialog, as an always-visible inspector).
struct PlacementParams: Equatable {
  var questionItem: QuestionBlockItem = .coin
  var movingDistance = 50
  var movingAxisRaw = 1  // 0 = up/down, 1 = right/left
  var movingStartReversed = false
  var piranha: PiranhaKind = .fish

  func ints(for kind: ObjectKind) -> [Int] {
    switch kind {
    case .blockQuestion, .blockQuestionHidden: [questionItem.rawValue, 0, 0]
    case .blockMoving: [movingDistance, movingAxisRaw, 0]
    case .blockPipeUp: [piranha.rawValue, 0, 0]
    default: [0, 0, 0]
    }
  }

  func bools(for kind: ObjectKind) -> [Bool] {
    switch kind {
    case .blockMoving: [movingStartReversed, false, false]
    default: [false, false, false]
    }
  }

  mutating func absorb(_ object: LevelObject) {
    switch object.kind {
    case .blockQuestion, .blockQuestionHidden:
      questionItem = QuestionBlockItem(rawValue: object.ints[0]) ?? .coin
    case .blockMoving:
      movingDistance = object.ints[0]
      movingAxisRaw = object.ints[1]
      movingStartReversed = object.bools[0]
    case .blockPipeUp:
      piranha = PiranhaKind(rawValue: object.ints[0]) ?? .fish
    default:
      break
    }
  }
}

@Reducer
struct EditorFeature {
  static let gridWidth = LevelDocument.pixelWidth / LevelDocument.tileSize  // 64
  static let gridHeight = LevelDocument.pixelHeight / LevelDocument.tileSize  // 29

  @ObservableState
  struct State: Equatable {
    var document = Self.newDocument
    var fileURL: URL?
    var isDirty = false

    var tool: Tool = .place(.blockGrass)
    var params = PlacementParams()

    var undoStack: [LevelDocument] = []
    var redoStack: [LevelDocument] = []
    var strokeActive = false

    var hoverCell: Cell?
    var zoom: Double = 2
    var statusMessage: String?

    enum Tool: Equatable {
      case place(ObjectKind)
      case erase
    }

    struct Cell: Equatable {
      var x: Int
      var y: Int  // grid Y, counted from the level bottom (legacy convention)
    }

    /// New levels start with a grass floor, Mario, and an exit — the
    /// minimum playable level.
    static var newDocument: LevelDocument {
      var objects: [LevelObject] = []
      for x in 0..<EditorFeature.gridWidth {
        objects.append(LevelObject(kind: .blockGrass, x: x, y: 0))
      }
      objects.append(LevelObject(kind: .mario, x: 1, y: 1))
      objects.append(LevelObject(kind: .exit, x: EditorFeature.gridWidth - 2, y: 2))
      return LevelDocument(objects: objects)
    }

    var validationIssues: [String] {
      var issues: [String] = []
      if document.marioCount == 0 { issues.append("Place a Mario start position.") }
      if document.marioCount > 1 { issues.append("Only one Mario allowed (found \(document.marioCount)).") }
      if document.exitCount == 0 { issues.append("Place at least one Exit door.") }
      return issues
    }

    var canPlay: Bool { validationIssues.isEmpty }

    var fileName: String {
      fileURL?.lastPathComponent ?? "Untitled.xml"
    }
  }

  enum Action: BindableAction {
    case backToMenuTapped
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case documentOpened(LevelDocument, URL)
    case documentSaved(URL)
    case eyedropper(State.Cell)
    case newTapped
    case openTapped
    case playTapped
    case redoTapped
    case saveAsTapped
    case saveFailed(String)
    case saveTapped
    case strokeEnded
    case strokeMoved(State.Cell)
    case strokeStarted(State.Cell)
    case undoTapped

    enum Delegate {
      case backToMenu
      case playLevel(LevelDocument)
    }
  }

  @Dependency(\.fileDialog) var fileDialog

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .backToMenuTapped:
        return .send(.delegate(.backToMenu))

      case .binding:
        return .none

      case .delegate:
        return .none

      case .documentOpened(let document, let url):
        pushUndo(&state)
        state.document = document
        state.fileURL = url
        state.isDirty = false
        state.statusMessage = "Opened \(url.lastPathComponent) (\(document.objects.count) objects)"
        return .none

      case .documentSaved(let url):
        state.fileURL = url
        state.isDirty = false
        state.statusMessage = "Saved \(url.lastPathComponent)"
        return .none

      case .eyedropper(let cell):
        if let object = object(in: state.document, at: cell) {
          state.tool = .place(object.kind)
          state.params.absorb(object)
          state.statusMessage = "Picked \(object.kind.displayName)"
        }
        return .none

      case .newTapped:
        pushUndo(&state)
        state.document = State.newDocument
        state.fileURL = nil
        state.isDirty = false
        state.statusMessage = "New level"
        return .none

      case .openTapped:
        return .run { send in
          guard let url = await fileDialog.openXML() else { return }
          do {
            let document = try LegacyLevelXML.decode(try Data(contentsOf: url))
            await send(.documentOpened(document, url))
          } catch {
            await send(.saveFailed("Could not open \(url.lastPathComponent)"))
          }
        }

      case .playTapped:
        guard state.canPlay else { return .none }
        return .send(.delegate(.playLevel(state.document)))

      case .redoTapped:
        guard let next = state.redoStack.popLast() else { return .none }
        state.undoStack.append(state.document)
        state.document = next
        state.isDirty = true
        return .none

      case .saveAsTapped:
        return save(state, forcePanel: true)

      case .saveFailed(let message):
        state.statusMessage = message
        return .none

      case .saveTapped:
        return save(state, forcePanel: false)

      case .strokeEnded:
        state.strokeActive = false
        return .none

      case .strokeMoved(let cell), .strokeStarted(let cell):
        if case .strokeStarted = action {
          pushUndo(&state)
          state.strokeActive = true
        }
        guard state.strokeActive else { return .none }
        apply(tool: state.tool, at: cell, &state)
        return .none

      case .undoTapped:
        guard let previous = state.undoStack.popLast() else { return .none }
        state.redoStack.append(state.document)
        state.document = previous
        state.isDirty = true
        return .none
      }
    }
  }

  private func pushUndo(_ state: inout State) {
    state.undoStack.append(state.document)
    if state.undoStack.count > 100 {
      state.undoStack.removeFirst()
    }
    state.redoStack.removeAll()
  }

  private func object(in document: LevelDocument, at cell: State.Cell) -> LevelObject? {
    document.objects.last { $0.x == cell.x && $0.y == cell.y }
  }

  private func apply(tool: State.Tool, at cell: State.Cell, _ state: inout State) {
    guard (0..<Self.gridWidth).contains(cell.x), (0..<Self.gridHeight).contains(cell.y)
    else { return }

    switch tool {
    case .erase:
      let before = state.document.objects.count
      state.document.objects.removeAll { $0.x == cell.x && $0.y == cell.y }
      if state.document.objects.count != before { state.isDirty = true }

    case .place(let kind):
      let object = LevelObject(
        kind: kind, x: cell.x, y: cell.y,
        ints: state.params.ints(for: kind),
        bools: state.params.bools(for: kind)
      )
      if let existing = self.object(in: state.document, at: cell), existing == object {
        return  // drag-paint over the same cell
      }
      state.document.objects.removeAll { $0.x == cell.x && $0.y == cell.y }
      state.document.objects.append(object)
      state.isDirty = true
    }
  }

  private func save(_ state: State, forcePanel: Bool) -> Effect<Action> {
    let document = state.document
    let existingURL = forcePanel ? nil : state.fileURL
    let suggestedName = state.fileURL?.lastPathComponent ?? "MyLevel.xml"
    return .run { send in
      let url: URL?
      if let existingURL {
        url = existingURL
      } else {
        url = await fileDialog.saveXML(suggestedName)
      }
      guard let url else { return }
      do {
        try LegacyLevelXML.encode(document).write(to: url)
        await send(.documentSaved(url))
      } catch {
        await send(.saveFailed("Could not save \(url.lastPathComponent)"))
      }
    }
  }
}

extension ObjectKind {
  var displayName: String {
    switch self {
    case .mario: "Mario"
    case .blockGrass: "Grass"
    case .blockSolid: "Solid Block"
    case .blockBrick: "Brick"
    case .blockQuestion: "? Block"
    case .blockQuestionHidden: "Hidden ? Block"
    case .blockMoving: "Moving Platform"
    case .blockPipeUp: "Pipe"
    case .coin: "Coin"
    case .exit: "Exit Door"
    case .monsterGoomba: "Goomba"
    case .monsterKoopa: "Koopa"
    }
  }

  /// Palette groups, in display order.
  static let paletteGroups: [(String, [ObjectKind])] = [
    ("Player", [.mario, .exit]),
    ("Blocks", [.blockGrass, .blockSolid, .blockBrick, .blockQuestion, .blockQuestionHidden, .blockMoving, .blockPipeUp]),
    ("Items", [.coin]),
    ("Monsters", [.monsterGoomba, .monsterKoopa]),
  ]

  var hasParams: Bool {
    switch self {
    case .blockQuestion, .blockQuestionHidden, .blockMoving, .blockPipeUp: true
    default: false
    }
  }
}
