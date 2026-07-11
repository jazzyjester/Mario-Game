import ComposableArchitecture
import Foundation
import MarioKit
import Testing

@testable import MarioApp

/// In-memory `LevelStorageClient` stub: `bundled` seeds fallback documents
/// (standing in for `BundledAssets`), `overrides` tracks saved edits — same
/// shape as the live implementation, without touching disk.
private final class TestLevelStorage: @unchecked Sendable {
  private let lock = NSLock()
  private let bundled: [String: LevelDocument]
  private var overrides: [String: LevelDocument] = [:]

  init(bundled: [String: LevelDocument]) {
    self.bundled = bundled
  }

  func hasOverride(_ name: String) -> Bool {
    lock.lock(); defer { lock.unlock() }
    return overrides[name] != nil
  }

  var client: LevelStorageClient {
    LevelStorageClient(
      load: { [self] name in
        lock.lock(); defer { lock.unlock() }
        if let doc = overrides[name] { return doc }
        if let doc = bundled[name] { return doc }
        throw LegacyLevelXML.CodecError.malformedXML
      },
      hasOverride: { [self] name in
        lock.lock(); defer { lock.unlock() }
        return overrides[name] != nil
      },
      save: { [self] name, document in
        lock.lock(); defer { lock.unlock() }
        overrides[name] = document
      },
      revert: { [self] name in
        lock.lock(); defer { lock.unlock() }
        overrides.removeValue(forKey: name)
      },
      overriddenNames: { [self] in
        lock.lock(); defer { lock.unlock() }
        return Set(overrides.keys)
      }
    )
  }
}

@MainActor
@Suite("EditorFeature")
struct EditorFeatureTests {
  @Test func placeUndoRedo() async {
    let store = TestStore(initialState: EditorFeature.State()) {
      EditorFeature()
    }
    let cell = EditorFeature.State.Cell(x: 10, y: 5)
    let original = store.state.document
    let placed = LevelObject(kind: .blockBrick, x: 10, y: 5)

    await store.send(.binding(.set(\.tool, .place(.blockBrick)))) {
      $0.tool = .place(.blockBrick)
    }
    await store.send(.strokeStarted(cell)) {
      $0.undoStack = [original]
      $0.strokeActive = true
      $0.document.objects.append(placed)
      $0.isDirty = true
    }
    await store.send(.strokeEnded) {
      $0.strokeActive = false
    }

    var edited = store.state.document
    await store.send(.undoTapped) {
      $0.undoStack = []
      $0.redoStack = [edited]
      $0.document = original
    }
    await store.send(.redoTapped) {
      $0.redoStack = []
      $0.undoStack = [original]
      $0.document = edited
    }

    // Erasing removes the object again.
    await store.send(.binding(.set(\.tool, .erase))) {
      $0.tool = .erase
    }
    edited = store.state.document
    await store.send(.strokeStarted(cell)) {
      $0.undoStack = [original, edited]
      $0.redoStack = []
      $0.strokeActive = true
      $0.document.objects.removeAll { $0.x == 10 && $0.y == 5 }
    }
  }

  @Test func eyedropperPicksKindAndParams() async {
    var state = EditorFeature.State()
    state.document.objects.append(
      LevelObject(kind: .blockQuestion, x: 7, y: 4, ints: [QuestionBlockItem.flower.rawValue, 0, 0]))
    let store = TestStore(initialState: state) {
      EditorFeature()
    }

    await store.send(.eyedropper(.init(x: 7, y: 4))) {
      $0.tool = .place(.blockQuestion)
      $0.params.questionItem = .flower
      $0.statusMessage = "Picked ? Block"
    }
  }

  @Test func validationBlocksPlayWithoutMario() async {
    var state = EditorFeature.State()
    state.document.objects.removeAll { $0.kind == .mario }
    let store = TestStore(initialState: state) {
      EditorFeature()
    }
    #expect(!store.state.canPlay)
    #expect(store.state.validationIssues == ["Place a Mario start position."])

    // Play is a no-op while invalid: no delegate action received.
    await store.send(.playTapped)
  }

  @Test func playDelegatesDocument() async {
    let store = TestStore(initialState: EditorFeature.State()) {
      EditorFeature()
    }
    #expect(store.state.canPlay)

    await store.send(.playTapped)
    await store.receive(\.delegate.playLevel)
  }

  @Test func saveWritesLegacyXMLToExistingURL() async throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("editor-save-test-\(UUID().uuidString).xml")
    defer { try? FileManager.default.removeItem(at: url) }

    var state = EditorFeature.State()
    state.fileURL = url
    state.isDirty = true
    let store = TestStore(initialState: state) {
      EditorFeature()
    }

    await store.send(.saveTapped)
    await store.receive(\.documentSaved) {
      $0.isDirty = false
      $0.statusMessage = "Saved \(url.lastPathComponent)"
    }

    // The saved file round-trips through the legacy codec.
    let reloaded = try LegacyLevelXML.decode(try Data(contentsOf: url))
    #expect(reloaded == store.state.document)
  }

  @Test func bundledLevelPickedLoadsOriginalWhenNoOverrideSaved() async {
    let original = LevelDocument(objects: [LevelObject(kind: .mario, x: 1, y: 1)])
    let storage = TestLevelStorage(bundled: ["Level3.xml": original])
    let store = TestStore(initialState: EditorFeature.State(levelNames: ["Level1.xml", "Level2.xml", "Level3.xml"])) {
      EditorFeature()
    } withDependencies: {
      $0.levelStorage = storage.client
    }
    store.exhaustivity = .off

    await store.send(.bundledLevelPicked("Level3.xml"))
    #expect(store.state.document == original)
    #expect(store.state.bundledLevelName == "Level3.xml")
    #expect(store.state.bundledLevelDisplayName == "Level 3")
    #expect(!store.state.hasOverride)
  }

  @Test func savingABundledLevelPersistsAnOverrideAndRevertRestoresTheOriginal() async {
    let original = LevelDocument(objects: [LevelObject(kind: .mario, x: 1, y: 1)])
    let edited = LevelDocument(objects: [
      LevelObject(kind: .mario, x: 1, y: 1),
      LevelObject(kind: .blockBrick, x: 5, y: 0),
    ])
    let storage = TestLevelStorage(bundled: ["Level2.xml": original])
    var state = EditorFeature.State(levelNames: ["Level1.xml", "Level2.xml"])
    state.bundledLevelName = "Level2.xml"
    state.document = edited
    state.isDirty = true
    let store = TestStore(initialState: state) {
      EditorFeature()
    } withDependencies: {
      $0.levelStorage = storage.client
    }
    store.exhaustivity = .off

    // Saving persists the edit to an override — the bundled original is
    // untouched (the stub's `bundled` dictionary never changes).
    await store.send(.saveTapped)
    #expect(store.state.hasOverride)
    #expect(!store.state.isDirty)
    #expect(storage.hasOverride("Level2.xml"))

    // Reverting deletes the override and restores the original document.
    await store.send(.revertTapped)
    #expect(store.state.document == original)
    #expect(!store.state.hasOverride)
    #expect(!storage.hasOverride("Level2.xml"))
  }

  @Test func eraserRemovesMultiTileObjectFromAnyFootprintTile() async {
    var state = EditorFeature.State()
    state.document.objects.append(LevelObject(kind: .blockPipeUp, x: 30, y: 0))
    state.tool = .erase
    let store = TestStore(initialState: state) {
      EditorFeature()
    }
    store.exhaustivity = .off

    // `blockPipeUp` renders 2×2 tiles; click its upper-right tile, not its
    // (30, 0) anchor — this used to be a silent no-op.
    await store.send(.strokeStarted(.init(x: 31, y: 1)))
    #expect(!store.state.document.objects.contains { $0.kind == .blockPipeUp })
  }

  @Test func selectToolEditsExistingObjectParamsAndDeletes() async {
    // y: 1 (on top of the ground row, not embedded in it) so the pipe's
    // anchor doesn't collide with a ground tile's own (x, 0) anchor.
    var state = EditorFeature.State()
    state.document.objects.append(
      LevelObject(kind: .blockPipeUp, x: 20, y: 1, ints: [PiranhaKind.fish.rawValue, 0, 0]))
    state.tool = .select
    let store = TestStore(initialState: state) {
      EditorFeature()
    }
    store.exhaustivity = .off

    // Clicking the pipe's upper-right footprint tile (not its anchor)
    // still selects it, since blockPipeUp renders 2×2 tiles.
    await store.send(.selectTapped(.init(x: 21, y: 2)))
    #expect(store.state.selectedCell == .init(x: 20, y: 1))
    #expect(store.state.selectionParams.piranha == .fish)

    // Editing the inspector's params live-updates the placed object without
    // changing its kind or position.
    await store.send(.binding(.set(\.selectionParams.piranha, .fire)))
    let updated = store.state.document.objects.first { $0.x == 20 && $0.y == 1 }
    #expect(updated?.kind == .blockPipeUp)
    #expect(updated?.ints[0] == PiranhaKind.fire.rawValue)

    await store.send(.deleteSelectedTapped)
    #expect(!store.state.document.objects.contains { $0.x == 20 && $0.y == 1 })
    #expect(store.state.selectedCell == nil)
  }
}

@MainActor
@Suite("AppFeature navigation")
struct AppFeatureTests {
  @Test func menuToEditorAndBack() async {
    let state = AppFeature.State()
    let store = TestStore(initialState: state) {
      AppFeature()
    }

    await store.send(.editorTapped) {
      $0.editor = EditorFeature.State(levelNames: state.levelNames)
    }
    await store.send(.editor(.presented(.delegate(.backToMenu)))) {
      $0.editor = nil
    }
  }

  @Test func playFromEditorKeepsEditorUnderneath() async {
    var state = AppFeature.State()
    state.editor = EditorFeature.State()
    let document = state.editor!.document
    let store = TestStore(initialState: state) {
      AppFeature()
    }
    store.exhaustivity = .off

    await store.send(.editor(.presented(.delegate(.playLevel(document)))))
    #expect(store.state.game != nil)
    #expect(store.state.game?.launchedFromEditor == true)
    #expect(store.state.editor != nil)

    await store.send(.game(.presented(.delegate(.backToEditor))))
    #expect(store.state.game == nil)
    #expect(store.state.editor != nil)
  }

  @Test func newGameStartsLevelOneWithFiveLives() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }
    store.exhaustivity = .off

    await store.send(.newGameTapped)
    #expect(store.state.game?.levelIndex == 0)
    #expect(store.state.game?.lives == 5)
  }

  @Test func lockedLevelCannotBeSelected() async {
    let state = AppFeature.State()
    state.$unlockedLevels.withLock { $0 = 1 }
    let store = TestStore(initialState: state) {
      AppFeature()
    }
    store.exhaustivity = .off

    // Level 2 (index 1) is locked: selecting it does nothing.
    await store.send(.levelSelected(1))
    #expect(store.state.game == nil)

    // Unlock it (as completing level 1 would), now it starts.
    state.$unlockedLevels.withLock { $0 = 2 }
    await store.send(.levelSelected(1))
    #expect(store.state.game?.levelIndex == 1)
    #expect(store.state.game?.levelName == "Level2.xml")
  }

  @Test func completingBundledLevelUnlocksTheNext() async throws {
    let initialState = try GameFeature.State(
      levelIndex: 0, levelNames: ["lev1.xml", "Level2.xml", "Level3.xml"], lives: 5)
    initialState.$unlockedLevels.withLock { $0 = 1 }
    var state = initialState
    state.session = try GameSession(
      level: LevelDocument(objects: [
        LevelObject(kind: .mario, x: 1, y: 1),
        LevelObject(kind: .blockGrass, x: 1, y: 0),
        LevelObject(kind: .blockGrass, x: 2, y: 0),
        LevelObject(kind: .exit, x: 2, y: 1),
      ]))

    let store = TestStore(initialState: state) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
    }
    store.exhaustivity = .off

    await store.send(.keyDown(.right))
    for _ in 0..<10 {
      await store.send(.tick)
    }

    #expect(store.state.levelIndex == 1)
    #expect(store.state.unlockedLevels == 2)
  }

  @Test func togglesPersistSettings() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }
    store.exhaustivity = .off
    #expect(store.state.soundEnabled)
    #expect(store.state.musicEnabled)

    await store.send(.soundToggled)
    await store.send(.musicToggled)
    #expect(!store.state.soundEnabled)
    #expect(!store.state.musicEnabled)

    // A fresh state (new app run) sees the same persisted values.
    let rebooted = AppFeature.State()
    #expect(!rebooted.soundEnabled)
    #expect(!rebooted.musicEnabled)
  }
}
