import ComposableArchitecture
import Foundation
import MarioKit
import Testing

@testable import MarioApp

/// A minimal playable level: grass floor, Mario, and an exit near the spawn.
private func tinyLevel(exitAtSpawn: Bool = false) -> LevelDocument {
  var objects: [LevelObject] = [LevelObject(kind: .mario, x: 1, y: 1)]
  for x in 0..<64 {
    objects.append(LevelObject(kind: .blockGrass, x: x, y: 0))
  }
  objects.append(LevelObject(kind: .exit, x: exitAtSpawn ? 2 : 60, y: 1))
  return LevelDocument(objects: objects)
}

/// A death trap: no ground at all.
private let voidLevel = LevelDocument(objects: [
  LevelObject(kind: .mario, x: 1, y: 1),
  LevelObject(kind: .blockSolid, x: 63, y: 0),
])

@MainActor
@Suite("GameFeature flows")
struct GameFeatureTests {
  @Test func deathShowsLivesScreenThenReloadsWithOneFewerLife() async throws {
    let initialState = try GameFeature.State(
      levelIndex: 0, levelNames: [], lives: 3, customLevel: voidLevel)
    let store = TestStore(initialState: initialState) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
    }
    store.exhaustivity = .off
    let originalSessionID = store.state.session.id

    // Mario free-falls into the void (~10 ticks to pass the death line),
    // then the ~50-tick death animation plays before the life is lost.
    // Stop at the first death — the reloaded level is just as deadly.
    for _ in 0..<150 where store.state.lives == 3 {
      await store.send(.tick)
    }

    // The black "MARIO × 2" interstitial is up; its timer then reloads.
    #expect(store.state.lives == 2)
    #expect(store.state.overlay == .lives)
    await store.receive(\.livesScreenFinished)
    #expect(store.state.overlay == nil)
    // A fresh world was created for the reload.
    #expect(store.state.session.id != originalSessionID)
    #expect(store.state.session.world.tickCount < 30)
  }

  @Test func gameOverAtZeroLivesThenBackToMenu() async throws {
    let initialState = try GameFeature.State(
      levelIndex: 0, levelNames: [], lives: 1, customLevel: voidLevel)
    let store = TestStore(initialState: initialState) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
    }
    store.exhaustivity = .off

    for _ in 0..<150 where store.state.overlay == nil {
      await store.send(.tick)
    }
    #expect(store.state.lives == 0)
    #expect(store.state.overlay == .gameOver)

    await store.send(.overlayConfirmed)
    await store.receive(\.delegate.backToMenu)
  }

  @Test func completingCustomLevelShowsWonOverlay() async throws {
    let initialState = try GameFeature.State(
      levelIndex: 0, levelNames: [], lives: 5,
      customLevel: tinyLevel(exitAtSpawn: true),
      launchedFromEditor: true)
    let store = TestStore(initialState: initialState) {
      GameFeature()
    }
    store.exhaustivity = .off

    // Walk into the exit with Enter pressed.
    await store.send(.keyDown(.right))
    for _ in 0..<10 {
      await store.send(.enterPressed)
      await store.send(.tick)
    }

    #expect(store.state.overlay == .won)

    await store.send(.overlayConfirmed)
    await store.receive(\.delegate.backToEditor)
  }

  @Test func completingBundledLevelAdvancesToNext() async throws {
    var state = try GameFeature.State(
      levelIndex: 0, levelNames: ["lev1.xml", "Level2.xml"], lives: 5)
    // Swap in a trivially-completable world for lev1.
    state.session = try GameSession(level: tinyLevel(exitAtSpawn: true))

    let store = TestStore(initialState: state) {
      GameFeature()
    }
    store.exhaustivity = .off

    await store.send(.keyDown(.right))
    for _ in 0..<10 {
      await store.send(.enterPressed)
      await store.send(.tick)
    }

    #expect(store.state.levelIndex == 1)
    #expect(store.state.overlay == nil)
    // The new session runs Level2 (many objects, fresh tick count).
    #expect(store.state.session.world.tickCount < 10)
  }

  @Test func pauseStopsTheWorld() async throws {
    let initialState = try GameFeature.State(
      levelIndex: 0, levelNames: [], lives: 5, customLevel: tinyLevel())
    let store = TestStore(initialState: initialState) {
      GameFeature()
    }

    await store.send(.pauseToggled) {
      $0.paused = true
    }
    // Ticks are ignored while paused: state unchanged (exhaustive assert).
    await store.send(.tick)
    await store.send(.pauseToggled) {
      $0.paused = false
    }
  }
}
