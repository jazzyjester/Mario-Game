import Testing

@testable import MarioKit

/// Builds a small test level: a full ground row of solid blocks at grid y=0
/// (Mario always spawns at x=20px on the bottom row), plus extra objects.
private func makeLevel(
  groundWidth: Int = 64,
  ground: ObjectKind = .blockSolid,
  extra: [LevelObject] = []
) -> LevelDocument {
  var objects: [LevelObject] = [LevelObject(kind: .mario, x: 1, y: 1)]
  for x in 0..<groundWidth {
    objects.append(LevelObject(kind: ground, x: x, y: 0))
  }
  objects.append(contentsOf: extra)
  return LevelDocument(objects: objects)
}

private func makeWorld(
  groundWidth: Int = 64,
  ground: ObjectKind = .blockSolid,
  extra: [LevelObject] = []
) throws -> GameWorld {
  try GameWorld(level: makeLevel(groundWidth: groundWidth, ground: ground, extra: extra))
}

@Suite("GameWorld basics")
struct GameWorldBasicsTests {
  @Test func spawnIsBottomLeft() throws {
    let world = try makeWorld()
    // Legacy: Mario always starts 20px in, standing on the bottom tile row.
    #expect(world.mario.x == 20)
    #expect(world.mario.y == 432)
    #expect(world.mario.powerUp == .small)
  }

  @Test func worldWithoutMarioThrows() {
    #expect(throws: GameWorld.WorldError.missingMario) {
      _ = try GameWorld(level: LevelDocument(objects: [LevelObject(kind: .blockSolid, x: 0, y: 0)]))
    }
  }

  @Test func standingStill_staysOnGround() throws {
    let world = try makeWorld()
    for _ in 0..<40 {
      world.advance(GameInput())
    }
    #expect(world.mario.x == 20)
    #expect(world.mario.y == 432)
    #expect(world.mario.jumpState == .none)
  }

  @Test func fallsToDeathWithoutGround() throws {
    // Ground exists only far to the right; Mario spawns over the void.
    let level = LevelDocument(objects: [
      LevelObject(kind: .mario, x: 1, y: 1),
      LevelObject(kind: .blockSolid, x: 60, y: 0),
    ])
    let world = try GameWorld(level: level)
    var died = false
    for _ in 0..<150 {
      world.advance(GameInput())
      if world.drainEvents().contains(.marioDied) { died = true }
    }
    #expect(died)
    #expect(world.finished)
  }

  @Test func deathPlaysLeapAnimationBeforeFinishing() throws {
    // Kill Mario with a goomba right next to the spawn.
    let world = try makeWorld(extra: [LevelObject(kind: .monsterGoomba, x: 3, y: 1)])

    var events: [GameEvent] = []
    for _ in 0..<100 where !world.marioDying {
      world.advance(GameInput(right: true))
      events += world.drainEvents()
    }
    // Death starts: jingle + dying event, but the world isn't finished yet.
    #expect(world.marioDying)
    #expect(!world.finished)
    #expect(events.contains(.marioDying))
    #expect(events.contains(.play(.death)))
    #expect(!events.contains(.marioDied))

    // The leap: Mario first rises, then falls below the level.
    let deathY = world.mario.y
    for _ in 0..<6 {
      world.advance(GameInput())
    }
    #expect(world.mario.y < deathY)

    for _ in 0..<50 where !world.finished {
      world.advance(GameInput())
      events += world.drainEvents()
    }
    #expect(world.finished)
    #expect(events.contains(.marioDied))
    #expect(world.mario.y > GameWorld.levelHeight)
  }
}

@Suite("Mario movement")
struct MarioMovementTests {
  @Test func runsRightWithAcceleration() throws {
    let world = try makeWorld()
    world.advance(GameInput(right: true))
    #expect(world.mario.x == 23)  // 3 + Int(0.5)
    world.advance(GameInput(right: true))
    #expect(world.mario.x == 27)  // +3 + Int(1.0)
    for _ in 0..<6 {
      world.advance(GameInput(right: true))
    }
    // Acceleration caps at +6/tick.
    let before = world.mario.x
    world.advance(GameInput(right: true))
    #expect(world.mario.x - before == 6)
    #expect(world.mario.facing == .right)
  }

  @Test func slidesToAStopAfterRelease() throws {
    let world = try makeWorld()
    for _ in 0..<5 {
      world.advance(GameInput(right: true))
    }
    let atRelease = world.mario.x
    for _ in 0..<10 {
      world.advance(GameInput())
    }
    // Slid a little further, then stopped completely.
    #expect(world.mario.x > atRelease)
    #expect(world.mario.x <= atRelease + 8)
    #expect(world.mario.moveState == .none)
    let rest = world.mario.x
    world.advance(GameInput())
    #expect(world.mario.x == rest)
  }

  @Test func wallStopsRunning() throws {
    // Wall two tiles high at grid x=4 (Mario is 16px wide starting at x=20).
    let world = try makeWorld(extra: [
      LevelObject(kind: .blockSolid, x: 4, y: 1),
      LevelObject(kind: .blockSolid, x: 4, y: 2),
    ])
    for _ in 0..<30 {
      world.advance(GameInput(right: true))
    }
    // Pushed back flush against the wall (wall left edge at 64px).
    #expect(world.mario.x == 64 - world.mario.width)
  }

  @Test func cannotClimbWallByJumpingAgainstIt() throws {
    // The years-old legacy bug: repeatedly jumping against a tall wall let
    // Mario climb it — a sideways step into a block just below its top edge
    // was classified as "landed on top", teleporting him up the wall face.
    // Wall column at grid x=6 (left edge 96px), 8 tiles high (top at 320px)
    // — unclearable, the jump apex leaves Mario's bottom at ~375px.
    let wall = (1...8).map { LevelObject(kind: .blockBrick, x: 6, y: $0) }
    let world = try makeWorld(ground: .blockGrass, extra: wall)

    for tick in 0..<600 {
      world.advance(GameInput(right: true, jump: true))
      if world.mario.x > 96 - world.mario.width {
        Issue.record(
          "Mario entered the wall at tick \(tick): x=\(world.mario.x), y=\(world.mario.y)")
        return
      }
    }
    #expect(!world.finished)
  }

  @Test func jumpRisesAndLandsBack() throws {
    let world = try makeWorld()
    let groundY = world.mario.y

    world.advance(GameInput(jump: true))
    #expect(world.drainEvents().contains(.play(.jump)))
    #expect(world.mario.jumpState == .up)
    #expect(world.mario.y < groundY)

    var minY = groundY
    for _ in 0..<60 {
      world.advance(GameInput())
      minY = min(minY, world.mario.y)
    }
    // Rose a meaningful amount (apex of the -38 parabola ≈ 73px up), then
    // landed back exactly on the ground.
    #expect(groundY - minY > 60)
    #expect(world.mario.y == groundY)
    #expect(world.mario.jumpState == .none)
  }
}

@Suite("Items & blocks")
struct ItemsAndBlocksTests {
  @Test func collectsCoin() throws {
    // Coin one tile above ground, right of spawn.
    let world = try makeWorld(extra: [LevelObject(kind: .coin, x: 3, y: 1)])
    for _ in 0..<10 {
      world.advance(GameInput(right: true))
    }
    #expect(world.mario.collectedCoins == 1)
    let coin = world.objects.first { $0.kind == .coin }!
    #expect(!coin.visible)
  }

  @Test func questionBlockCoinPopsAndCounts() throws {
    // Question block three tiles above the ground at Mario's column.
    let world = try makeWorld(extra: [
      LevelObject(kind: .blockQuestion, x: 1, y: 3, ints: [QuestionBlockItem.coin.rawValue, 0, 0])
    ])
    let question = world.objects.compactMap { $0 as? BlockQuestion }.first!

    world.advance(GameInput(jump: true))
    var events: [GameEvent] = []
    for _ in 0..<20 {
      world.advance(GameInput())
      events += world.drainEvents()
    }
    #expect(question.open)
    #expect(world.mario.collectedCoins == 1)
    #expect(events.contains(.play(.coin)))
  }

  @Test func mushroomGrowsMario() throws {
    // Grass ground: released items walk on grass; on solid blocks they hit
    // the legacy "unrecognized ground" quirk and jitter in place.
    let world = try makeWorld(
      ground: .blockGrass,
      extra: [
        LevelObject(kind: .blockQuestion, x: 1, y: 3, ints: [QuestionBlockItem.mushroom.rawValue, 0, 0])
      ])
    let mush = world.objects.compactMap { $0 as? MushRed }.first!

    world.advance(GameInput(jump: true))
    for _ in 0..<30 {
      world.advance(GameInput())
    }
    // The released mushroom walks right; park Mario in its path.
    world.mario.x = mush.newx + 60
    world.mario.y = 432
    var grew = false
    for _ in 0..<200 {
      world.advance(GameInput())
      if world.mario.powerUp == .big { grew = true; break }
    }
    #expect(mush.live || !mush.visible)  // released (walking) or already eaten
    #expect(grew)
    #expect(world.mario.height == 27)
  }

  @Test func smallMarioCannotBreakBrick_bigMarioCan() throws {
    let world = try makeWorld(extra: [LevelObject(kind: .blockBrick, x: 1, y: 3)])
    let brick = world.objects.compactMap { $0 as? BlockBrick }.first!

    // Small Mario: head bump plays the block sound, brick survives.
    world.advance(GameInput(jump: true))
    var events: [GameEvent] = []
    for _ in 0..<30 {
      world.advance(GameInput())
      events += world.drainEvents()
    }
    #expect(brick.visible)
    #expect(events.contains(.play(.block)))

    // Grow Mario, bump again: brick breaks into flying pieces.
    world.mario.powerUp = .big
    world.mario.setProperties()
    world.advance(GameInput(jump: true))
    events = []
    var sawFlyingPiece = false
    for _ in 0..<30 {
      world.advance(GameInput())
      events += world.drainEvents()
      if world.objects.contains(where: { ($0 as? BlockBrickPiece)?.running == true }) {
        sawFlyingPiece = true
      }
    }
    #expect(!brick.visible)
    #expect(events.contains(.play(.brick)))
    #expect(sawFlyingPiece)
  }

  @Test func walkingIntoExitCompletesLevelWithoutEnter() throws {
    // Exit a few tiles past the spawn point.
    let world = try makeWorld(extra: [LevelObject(kind: .exit, x: 4, y: 1)])
    var events: [GameEvent] = []
    for _ in 0..<20 {
      world.advance(GameInput(right: true))
      events += world.drainEvents()
      if world.finished { break }
    }
    #expect(events.contains(.levelCompleted))
    #expect(world.finished)
  }
}

@Suite("Monsters")
struct MonsterTests {
  @Test func stompKillsGoombaAndBounces() throws {
    let world = try makeWorld(extra: [LevelObject(kind: .monsterGoomba, x: 10, y: 1)])
    let goomba = world.objects.compactMap { $0 as? MonsterGoomba }.first!

    // Drop Mario straight onto the goomba.
    world.mario.x = goomba.newx
    world.mario.y = goomba.newy - 60

    var events: [GameEvent] = []
    for _ in 0..<20 {
      world.advance(GameInput())
      events += world.drainEvents()
    }
    #expect(!goomba.live)
    #expect(events.contains(.play(.stomp)))
    #expect(!world.finished)  // Mario survived
  }

  @Test func sideCollisionKillsSmallMario() throws {
    let world = try makeWorld(extra: [LevelObject(kind: .monsterGoomba, x: 4, y: 1)])
    var events: [GameEvent] = []
    for _ in 0..<120 {  // contact + the ~50-tick death animation
      world.advance(GameInput(right: true))
      events += world.drainEvents()
    }
    #expect(events.contains(.marioDied))
    #expect(world.finished)
  }

  @Test func sideCollisionShrinksBigMarioAndBlinks() throws {
    let world = try makeWorld(extra: [LevelObject(kind: .monsterGoomba, x: 4, y: 1)])
    world.mario.powerUp = .big
    world.mario.setProperties()

    var shrunk = false
    for _ in 0..<40 {
      world.advance(GameInput(right: true))
      if world.mario.powerUp == .small { shrunk = true; break }
    }
    #expect(shrunk)
    #expect(world.mario.blinking)
    #expect(!world.finished)
  }

  @Test func stompedKoopaShields() throws {
    let world = try makeWorld(extra: [LevelObject(kind: .monsterKoopa, x: 12, y: 1)])
    let koopa = world.objects.compactMap { $0 as? MonsterKoopa }.first!
    #expect(koopa.state == .walking)

    world.mario.x = koopa.newx
    world.mario.y = koopa.newy - 60

    var events: [GameEvent] = []
    for _ in 0..<15 {
      world.advance(GameInput())
      events += world.drainEvents()
    }
    #expect(koopa.state == .shield || koopa.state == .returning)
    #expect(events.contains(.play(.stomp)))
  }

  @Test func fireballKillsGoomba() throws {
    // Grass ground: fireballs bounce on grass but die on solid blocks
    // (legacy behavior), so a solid floor would eat the ball.
    let world = try makeWorld(
      ground: .blockGrass,
      extra: [LevelObject(kind: .monsterGoomba, x: 8, y: 1)])
    let goomba = world.objects.compactMap { $0 as? MonsterGoomba }.first!
    world.mario.powerUp = .fire
    world.mario.setProperties()

    var events: [GameEvent] = []
    world.advance(GameInput(fire: true))
    events += world.drainEvents()
    #expect(events.contains(.play(.fireball)))

    var fell = false
    for _ in 0..<60 {
      world.advance(GameInput())
      if goomba.isFallDying { fell = true; break }
    }
    #expect(fell)
  }
}

@Suite("Level geometry")
struct LevelGeometryTests {
  /// Every listed level's *geometry* must be completable by a simple
  /// "run right, jump over walls and pits" runner once monsters are stripped
  /// (a player can dodge monsters; the terrain itself must never dead-end).
  /// This guards the generated levels 4–10 and the design rules they follow
  /// (pits ≤ 4 tiles, climbs ≤ 4 tiles, no ceilings over required jumps).
  /// Level2 is exempt: its whole right half is a void crossed on moving
  /// platforms, beyond a simple runner (covered by the smoke test instead).
  @Test(arguments: [
    "lev1.xml", "Level3.xml", "Level4.xml",
    "Level5.xml", "Level6.xml", "Level7.xml", "Level8.xml", "Level9.xml", "Level10.xml",
  ])
  func geometryIsCompletable(name: String) throws {
    var document = try BundledAssets.level(named: name)
    document.objects.removeAll {
      $0.kind == .monsterGoomba || $0.kind == .monsterKoopa
    }
    document.objects = document.objects.map { object in
      var object = object
      if object.kind == .blockPipeUp { object.ints[0] = 0 }  // no piranhas
      return object
    }

    let world = try GameWorld(level: document)
    var completed = false
    for _ in 0..<12000 {  // Level10 is twice the width of the others
      world.advance(GameInput(right: true, jump: shouldJump(world)))
      if world.drainEvents().contains(.levelCompleted) {
        completed = true
        break
      }
      if world.finished { break }  // fell into a pit: geometry failed
    }
    #expect(
      completed,
      "runner failed in \(name) at x=\(world.mario.x), y=\(world.mario.y), died=\(world.finished)")
  }

  /// A competent runner: jump when a wall blocks the path or a pit opens
  /// just ahead, otherwise keep feet on the ground.
  private func shouldJump(_ world: GameWorld) -> Bool {
    let mario = world.mario!
    let rect = mario.rect
    let walls: Set<EntityKind> = [
      .grass, .solidBlock, .ground1, .brick, .pipeUp, .blockQuestion, .movingBlock,
    ]
    let solids = world.objects.filter { $0.visible && walls.contains($0.kind) }

    // A wall at body height within 24px ahead?
    let wallAhead = solids.contains { block in
      let b = block.rect
      return b.x >= rect.maxX - 4 && b.x <= rect.maxX + 24
        && b.y < rect.maxY && b.maxY > rect.y
    }
    if wallAhead { return true }

    // Standing, with no ground in the next two tile columns below the feet?
    guard mario.jumpState == .none else { return false }
    let footY = rect.maxY
    let pitAhead = !(1...2).allSatisfy { column in
      let probeX = rect.maxX + column * 16 - 8
      return solids.contains { block in
        let b = block.rect
        return probeX >= b.x && probeX <= b.maxX && b.y >= footY && b.y <= footY + 64
      }
    }
    return pitAhead
  }
}

@Suite("Shipped levels smoke test")
struct ShippedLevelSmokeTests {
  @Test(arguments: [
    "lev1.xml", "Level2.xml", "Level3.xml", "Level4.xml",
    "Level5.xml", "Level6.xml", "Level7.xml", "Level8.xml", "Level9.xml", "Level10.xml",
  ])
  func runsWithoutCrashing(name: String) throws {
    let world = try GameWorld(level: BundledAssets.level(named: name))
    var rng = SystemRandomNumberGenerator()
    for tick in 0..<2000 {
      guard !world.finished else { break }
      // Chaotic input: mostly run right, jump in bursts, occasional fire.
      let input = GameInput(
        left: tick % 97 < 5,
        right: tick % 97 >= 5,
        jump: tick % 31 < 12,
        fire: Int.random(in: 0..<20, using: &rng) == 0
      )
      world.advance(input)
      _ = world.drainEvents()
      _ = world.renderables()
    }
    // The world stayed consistent: Mario is somewhere sane horizontally.
    #expect(world.mario.x >= 0)
    #expect(world.mario.x <= GameWorld.levelWidth)
  }

  @Test func lev1RenderablesLookSane() throws {
    let world = try GameWorld(level: BundledAssets.level(named: "lev1.xml"))
    let renderables = world.renderables()
    #expect(renderables.count > 100)
    for r in renderables {
      #expect(r.source.x >= 0)
      #expect(r.source.maxX <= r.sheet.size.width, "source overflows \(r.sheet): \(r.source)")
      #expect(r.source.height <= r.sheet.size.height)
    }
    // Mario is drawn.
    #expect(renderables.contains { $0.sheet == .marioSmall })
  }
}
