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

/// Lets the editor open one of the 9 shipped levels, save edits to a
/// user-writable override (never touching the bundled original), and revert.
/// Plain file I/O, so unlike `FileDialogClient` these calls are synchronous.
@DependencyClient
struct LevelStorageClient {
  var load: @Sendable (_ name: String) throws -> LevelDocument
  var hasOverride: @Sendable (_ name: String) -> Bool = { _ in false }
  var save: @Sendable (_ name: String, _ document: LevelDocument) throws -> Void
  var revert: @Sendable (_ name: String) throws -> Void
  var overriddenNames: @Sendable () -> Set<String> = { [] }
}

extension LevelStorageClient: DependencyKey {
  /// Overrides live in `Application Support/MarioSwift/CustomLevels/<name>`,
  /// entirely separate from the app-bundled originals.
  private static var overridesDirectory: URL {
    let base =
      FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      ?? FileManager.default.temporaryDirectory
    return base.appendingPathComponent("MarioSwift/CustomLevels", isDirectory: true)
  }

  private static func overrideURL(_ name: String) -> URL {
    overridesDirectory.appendingPathComponent(name)
  }

  static let liveValue = LevelStorageClient(
    load: { name in
      let url = overrideURL(name)
      if FileManager.default.fileExists(atPath: url.path) {
        return try LegacyLevelXML.decode(try Data(contentsOf: url))
      }
      return try BundledAssets.level(named: name)
    },
    hasOverride: { name in
      FileManager.default.fileExists(atPath: overrideURL(name).path)
    },
    save: { name, document in
      try FileManager.default.createDirectory(
        at: overridesDirectory, withIntermediateDirectories: true)
      try LegacyLevelXML.encode(document).write(to: overrideURL(name))
    },
    revert: { name in
      let url = overrideURL(name)
      if FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.removeItem(at: url)
      }
    },
    overriddenNames: {
      let names = try? FileManager.default.contentsOfDirectory(atPath: overridesDirectory.path)
      return Set(names ?? [])
    }
  )

  static let testValue = LevelStorageClient()
}

extension DependencyValues {
  var levelStorage: LevelStorageClient {
    get { self[LevelStorageClient.self] }
    set { self[LevelStorageClient.self] = newValue }
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

    /// The bundled level names ("Level1.xml", …), passed in from `AppFeature`
    /// so the editor can offer "Edit Level 1..9" without re-reading the
    /// catalog itself.
    var levelNames: [String] = []
    /// Non-nil while editing one of the 9 shipped levels (whether or not an
    /// override has been saved yet); nil for a free-standing custom document.
    var bundledLevelName: String?
    /// Whether `bundledLevelName` currently has a saved override on disk.
    var hasOverride = false
    /// Bundled level names that currently have a saved override, for the
    /// "Edit Level" picker's customized badge.
    var overriddenLevelNames: Set<String> = []

    var undoStack: [LevelDocument] = []
    var redoStack: [LevelDocument] = []
    var strokeActive = false

    /// The anchor cell of the object selected by the Select tool.
    var selectedCell: Cell?
    /// Live-edited params for the selected object (Select tool's inspector).
    var selectionParams = PlacementParams()

    var hoverCell: Cell?
    var zoom: Double = 2
    var statusMessage: String?

    enum Tool: Equatable {
      case place(ObjectKind)
      case erase
      case select
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

    /// "LEVEL N" for the bundled level currently being edited, if any.
    var bundledLevelDisplayName: String? {
      guard let name = bundledLevelName, let index = levelNames.firstIndex(of: name)
      else { return nil }
      return "Level \(index + 1)"
    }

    var fileName: String {
      if let displayName = bundledLevelDisplayName {
        return "\(displayName) (\(hasOverride ? "edited" : "original"))"
      }
      return fileURL?.lastPathComponent ?? "Untitled.xml"
    }
  }

  enum Action: BindableAction {
    case backToMenuTapped
    case binding(BindingAction<State>)
    case bundledLevelPicked(String)
    case delegate(Delegate)
    case deleteSelectedTapped
    case documentOpened(LevelDocument, URL)
    case documentSaved(URL)
    case editorAppeared
    case eraseTapped(State.Cell)
    case eyedropper(State.Cell)
    case newTapped
    case openTapped
    case playTapped
    case redoTapped
    case revertTapped
    case saveAsTapped
    case saveFailed(String)
    case saveTapped
    case selectTapped(State.Cell)
    case strokeEnded
    case strokeMoved(State.Cell)
    case strokeStarted(State.Cell)
    case undoTapped

    @CasePathable
    enum Delegate {
      case backToMenu
      case playLevel(LevelDocument)
    }
  }

  @Dependency(\.fileDialog) var fileDialog
  @Dependency(\.levelStorage) var levelStorage

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .backToMenuTapped:
        return .send(.delegate(.backToMenu))

      case .binding:
        // Live-project the Select tool's inspector edits back into the
        // selected object (only meaningful while a selection is active).
        if state.tool == .select, let cell = state.selectedCell,
          let index = state.document.objects.lastIndex(where: { $0.x == cell.x && $0.y == cell.y })
        {
          let kind = state.document.objects[index].kind
          state.document.objects[index].ints = state.selectionParams.ints(for: kind)
          state.document.objects[index].bools = state.selectionParams.bools(for: kind)
          state.isDirty = true
        }
        return .none

      case .bundledLevelPicked(let name):
        pushUndo(&state)
        state.selectedCell = nil
        do {
          state.document = try levelStorage.load(name)
          state.bundledLevelName = name
          state.fileURL = nil
          state.hasOverride = levelStorage.hasOverride(name)
          state.isDirty = false
          let display = state.bundledLevelDisplayName ?? name
          state.statusMessage =
            state.hasOverride
            ? "Editing \(display) — your saved edits"
            : "Editing \(display) — original, not yet customized"
        } catch {
          state.statusMessage = "Could not load \(name)"
        }
        return .none

      case .delegate:
        return .none

      case .deleteSelectedTapped:
        guard let cell = state.selectedCell else { return .none }
        pushUndo(&state)
        state.document.objects.removeAll { $0.x == cell.x && $0.y == cell.y }
        state.selectedCell = nil
        state.isDirty = true
        return .none

      case .documentOpened(let document, let url):
        pushUndo(&state)
        state.document = document
        state.fileURL = url
        state.bundledLevelName = nil
        state.hasOverride = false
        state.selectedCell = nil
        state.isDirty = false
        state.statusMessage = "Opened \(url.lastPathComponent) (\(document.objects.count) objects)"
        return .none

      case .documentSaved(let url):
        state.fileURL = url
        state.bundledLevelName = nil
        state.hasOverride = false
        state.isDirty = false
        state.statusMessage = "Saved \(url.lastPathComponent)"
        return .none

      case .editorAppeared:
        state.overriddenLevelNames = levelStorage.overriddenNames()
        return .none

      case .eraseTapped(let cell):
        // Right-click quick erase: works regardless of the current tool.
        guard let hit = object(in: state.document, at: cell) else { return .none }
        pushUndo(&state)
        state.document.objects.removeAll { $0 == hit }
        if state.selectedCell == State.Cell(x: hit.x, y: hit.y) { state.selectedCell = nil }
        state.isDirty = true
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
        state.bundledLevelName = nil
        state.hasOverride = false
        state.selectedCell = nil
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
        state.selectedCell = nil
        state.isDirty = true
        return .none

      case .revertTapped:
        guard let name = state.bundledLevelName else { return .none }
        pushUndo(&state)
        state.selectedCell = nil
        do {
          try levelStorage.revert(name)
          state.document = try levelStorage.load(name)
          state.hasOverride = false
          state.isDirty = false
          state.overriddenLevelNames = levelStorage.overriddenNames()
          state.statusMessage = "Reverted \(state.bundledLevelDisplayName ?? name) to the original"
        } catch {
          state.statusMessage = "Could not revert \(name)"
        }
        return .none

      case .saveAsTapped:
        return save(state, forcePanel: true)

      case .saveFailed(let message):
        state.statusMessage = message
        return .none

      case .saveTapped:
        if let name = state.bundledLevelName {
          do {
            try levelStorage.save(name, state.document)
            state.isDirty = false
            state.hasOverride = true
            state.overriddenLevelNames = levelStorage.overriddenNames()
            state.statusMessage =
              "Saved your edits to \(state.bundledLevelDisplayName ?? name) (original preserved)"
          } catch {
            state.statusMessage = "Could not save \(name)"
          }
          return .none
        }
        return save(state, forcePanel: false)

      case .selectTapped(let cell):
        if let object = object(in: state.document, at: cell) {
          state.selectedCell = State.Cell(x: object.x, y: object.y)
          state.selectionParams.absorb(object)
          state.statusMessage = "Selected \(object.kind.displayName)"
        } else {
          state.selectedCell = nil
        }
        return .none

      case .strokeEnded:
        state.strokeActive = false
        return .none

      case .strokeMoved(let cell), .strokeStarted(let cell):
        if case .strokeStarted = action {
          pushUndo(&state)
          state.strokeActive = true
          state.selectedCell = nil
        }
        guard state.strokeActive else { return .none }
        apply(tool: state.tool, at: cell, &state)
        return .none

      case .undoTapped:
        guard let previous = state.undoStack.popLast() else { return .none }
        state.redoStack.append(state.document)
        state.document = previous
        state.selectedCell = nil
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

  /// Footprint-aware hit test: matches a cell against an object's whole
  /// rendered footprint (e.g. a 2×2 pipe), not just its anchor tile, so
  /// clicking anywhere on a multi-tile sprite finds it.
  private func object(in document: LevelDocument, at cell: State.Cell) -> LevelObject? {
    document.objects.last {
      let footprint = EditorSprite.tileFootprint(for: $0.kind)
      return ($0.x..<($0.x + footprint.width)).contains(cell.x)
        && ($0.y..<($0.y + footprint.height)).contains(cell.y)
    }
  }

  private func apply(tool: State.Tool, at cell: State.Cell, _ state: inout State) {
    guard (0..<Self.gridWidth).contains(cell.x), (0..<Self.gridHeight).contains(cell.y)
    else { return }

    switch tool {
    case .erase:
      if let hit = object(in: state.document, at: cell) {
        state.document.objects.removeAll { $0 == hit }
        state.isDirty = true
      }

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

    case .select:
      break  // handled via .selectTapped, not the paint-stroke path
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
