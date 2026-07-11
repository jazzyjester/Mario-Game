import Foundation
import MarioKit

/// Value-semantics wrapper for the class-based `GameWorld` so it can live in
/// TCA state: equality is identity + tick, which is exactly "did the
/// simulation move", and is what should invalidate the view.
struct GameSession: Equatable {
  let id = UUID()
  let world: GameWorld
  private(set) var tick = 0

  init(level: LevelDocument) throws {
    world = try GameWorld(level: level)
  }

  mutating func advance(_ input: GameInput) -> [GameEvent] {
    world.advance(input)
    tick = world.tickCount
    return world.drainEvents()
  }

  static func == (lhs: GameSession, rhs: GameSession) -> Bool {
    lhs.id == rhs.id && lhs.tick == rhs.tick
  }
}
