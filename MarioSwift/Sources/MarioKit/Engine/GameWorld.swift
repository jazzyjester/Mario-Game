import Foundation

/// Sound effects the world can request. Raw values are the bundled file names.
public enum SoundEffect: String, Equatable, Sendable, CaseIterable {
  case jump = "jump.wav"
  case coin = "coin.wav"
  case stomp = "stomp.wav"
  case mush = "mush.wav"
  case brick = "brick.wav"
  case block = "block.wav"
  case fireball = "fireball.wav"
  case death = "death.wav"
}

public enum GameEvent: Equatable, Sendable {
  case play(SoundEffect)
  case extraLife
  case levelCompleted
  /// Mario was just killed: the death animation (leap up, fall through the
  /// floor) starts now, `marioDied` follows once it finishes.
  case marioDying
  case marioDied
}

/// Input for one 50ms tick. `left`/`right`/`jump` reflect keys currently
/// held; `fire` is a press edge.
public struct GameInput: Equatable, Sendable {
  public var left = false
  public var right = false
  public var jump = false
  public var fire = false

  public init(
    left: Bool = false, right: Bool = false, jump: Bool = false,
    fire: Bool = false
  ) {
    self.left = left
    self.right = right
    self.jump = jump
    self.fire = fire
  }
}

/// The camera: a 320×240 viewport that follows Mario, clamped to the level
/// bounds. `x` counts from the level's left edge; `y` counts *up from the
/// level's bottom edge*.
public struct ScreenState: Equatable, Sendable {
  public var x = 0
  public var y = 0
  public let width = 320
  public let height = 240

  /// Top edge of the visible viewport in level pixel coordinates.
  public var viewTopY: Int { GameWorld.levelHeight - height - y }
}

/// The deterministic game simulation: builds entities from a `LevelDocument`
/// and advances in fixed 50ms ticks (the legacy master timer). Animation
/// handlers run every 2/4/10 ticks, matching the legacy 100/200/500ms timers.
public final class GameWorld {
  public static let levelWidth = LevelDocument.pixelWidth
  public static let levelHeight = LevelDocument.pixelHeight

  public enum WorldError: Error, Equatable {
    case missingMario
  }

  public private(set) var objects: [Entity] = []
  public private(set) var mario: Mario!
  public internal(set) var screen = ScreenState()
  public private(set) var tickCount = 0
  /// Set once Mario dies or finishes the level; the world stops advancing.
  public private(set) var finished = false
  /// True while the death animation plays: Mario leaps up and falls through
  /// the floor, everything else freezes (classic platformer death). Ends
  /// with `finished = true` and a `.marioDied` event.
  public private(set) var marioDying = false
  private var deathTicks = 0

  enum TimerSlot: CaseIterable { case t50, t100, t200, t500 }
  private var handlers: [TimerSlot: [(GameWorld) -> Void]] = [:]
  private var events: [GameEvent] = []
  private var previousInput = GameInput()

  public init(level: LevelDocument) throws {
    for object in level.objects {
      let entity = makeEntity(object)
      addObject(entity)
      if let mario = entity as? Mario { self.mario = mario }
    }
    guard let mario else { throw WorldError.missingMario }

    // The legacy game overrode the level's Mario placement on every load:
    // always bottom-left, 20px in.
    mario.x = 20
    mario.y = Self.levelHeight - 16 - mario.height
    updateScreensX()
    updateScreensY()
  }

  private func makeEntity(_ object: LevelObject) -> Entity {
    let x = object.x
    let y = object.y
    switch object.kind {
    case .mario:
      return Mario(x: x, y: y, world: self)
    case .blockGrass:
      return BlockGrass(x: x, y: y)
    case .blockSolid:
      return BlockSolid(x: x, y: y)
    case .blockBrick:
      return BlockBrick(x: x, y: y, world: self)
    case .blockQuestion:
      return BlockQuestion(x: x, y: y, hidden: QuestionBlockItem(rawValue: object.ints[0]) ?? .coin, world: self)
    case .blockQuestionHidden:
      return BlockQuestionHidden(x: x, y: y, hidden: QuestionBlockItem(rawValue: object.ints[0]) ?? .coin, world: self)
    case .blockMoving:
      return BlockMoving(
        x: x, y: y, distance: object.ints[0],
        axis: object.ints[1] == 0 ? .upDown : .rightLeft,
        startReversed: object.bools[0], world: self)
    case .blockPipeUp:
      return BlockPipeUp(x: x, y: y, piranha: PiranhaKind(rawValue: object.ints[0]) ?? .none, world: self)
    case .coin:
      return CoinBlock(x: x, y: y, movingCoin: false, world: self)
    case .exit:
      return ExitBlock(x: x, y: y)
    case .monsterGoomba:
      return MonsterGoomba(x: x, y: y, world: self)
    case .monsterKoopa:
      return MonsterKoopa(x: x, y: y, world: self)
    }
  }

  /// Legacy `Level.AddObject`: children enter the object list before their
  /// parent, recursively. List order is both collision-sweep and draw order.
  private func addObject(_ entity: Entity) {
    for child in entity.children {
      addObject(child)
    }
    objects.append(entity)
  }

  func on(_ slot: TimerSlot, _ handler: @escaping (GameWorld) -> Void) {
    handlers[slot, default: []].append(handler)
  }

  func emit(_ event: GameEvent) {
    events.append(event)
  }

  func play(_ sound: SoundEffect) {
    emit(.play(sound))
  }

  /// Events produced since the last drain (sounds, death, level completion).
  public func drainEvents() -> [GameEvent] {
    defer { events.removeAll() }
    return events
  }

  /// Advance the simulation by one 50ms tick.
  public func advance(_ input: GameInput) {
    guard !finished else { return }

    if marioDying {
      // Death animation: only Mario's leap-and-fall runs; input is ignored,
      // monsters and timers freeze, the camera stays put.
      tickCount += 1
      deathTicks += 1
      mario.deathFallTick()
      if deathTicks >= 50 {  // 2.5s — matches the death jingle
        finished = true
        emit(.marioDied)
      }
      return
    }

    apply(input)
    run(.t50)
    tickCount += 1
    if tickCount % 2 == 0 { run(.t100) }
    if tickCount % 4 == 0 { run(.t200) }
    if tickCount % 10 == 0 { run(.t500) }
    previousInput = input
  }

  private func run(_ slot: TimerSlot) {
    guard let slotHandlers = handlers[slot] else { return }
    // Handlers registered during a tick (never happens today, but matches
    // the timer list semantics) run starting next tick.
    for handler in slotHandlers {
      handler(self)
    }
  }

  private func apply(_ input: GameInput) {
    // The legacy form translated (auto-repeating) key events; holding a key
    // is equivalent to re-sending its action every tick. Jump is the
    // exception: it's edge-triggered so the jump buffer only arms once per
    // press, not continuously while held (which would let a buffered press
    // held past release still auto-fire on a later landing).
    if input.jump {
      if !previousInput.jump {
        mario.startJump(kill: false, world: self)
      }
    } else if previousInput.jump {
      mario.endJump()
    }

    if input.right {
      mario.move(.right)
    } else if input.left {
      mario.move(.left)
    } else if previousInput.left || previousInput.right {
      mario.stopMove()
    }

    if input.fire {
      mario.fireBall(self)
    }
  }

  func marioDied() {
    guard !finished, !marioDying else { return }
    marioDying = true
    mario.beginDeathLeap()
    play(.death)
    emit(.marioDying)
  }

  func levelCompleted() {
    guard !finished else { return }
    finished = true
    emit(.levelCompleted)
  }

  /// Legacy `Level.CheckLevelCollisions`: O(n²) sweep; each source entity's
  /// hit list is rebuilt, and `intersection` runs immediately (mutating the
  /// world mid-sweep, exactly like the original).
  func checkLevelCollisions() {
    for src in objects {
      var count = 0
      src.hits.removeAll(keepingCapacity: true)
      for dest in objects where src !== dest {
        if src.visible && dest.visible, let c = classifyCollision(src: src.rect, dest: dest.rect) {
          src.hits.append((c, dest))
          src.intersection(c, dest, self)
          count += 1
        }
      }
      if count == 0 {
        src.intersectionNone(self)
      }
    }
  }

  // MARK: Camera (legacy Level.Update_ScreensX/Y)

  func updateScreensX() {
    if mario.x >= screen.width / 2 {
      screen.x = mario.x - screen.width / 2
    } else {
      screen.x = 0
    }
    if mario.x + screen.width / 2 >= Self.levelWidth {
      screen.x = Self.levelWidth - screen.width
    }
  }

  func updateScreensY() {
    let height = Self.levelHeight
    if height - mario.y >= screen.height / 2 {
      screen.y = height - mario.y - screen.height / 2
    } else {
      screen.y = 0
    }
    if height - mario.y + screen.height / 2 >= height {
      screen.y = height - screen.height
    }
  }

  // MARK: Rendering

  /// Draw commands for all currently-drawn entities, in legacy draw order.
  /// Pass the camera viewport (level pixel coordinates) to cull off-screen
  /// entities before draw commands are built.
  public func renderables(visibleIn viewport: IRect? = nil) -> [Renderable] {
    objects.compactMap { entity in
      guard let renderable = entity.renderable() else { return nil }
      if let viewport {
        let dest = renderable.dest
        guard
          dest.x < viewport.maxX, dest.maxX > viewport.x,
          dest.y < viewport.maxY, dest.maxY > viewport.y
        else { return nil }
      }
      return renderable
    }
  }
}
