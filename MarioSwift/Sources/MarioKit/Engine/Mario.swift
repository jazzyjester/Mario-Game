import Foundation

/// Mario. Unlike every other entity, his pixel position lives in `x`/`y`
/// (top-left, level coordinates) — a legacy quirk preserved because all the
/// physics constants are tuned to it.
public final class Mario: AnimatedEntity {
  public enum JumpState: Equatable, Sendable { case none, up, down }
  public enum MoveState: Equatable, Sendable { case none, right, left, stopping }
  public enum PowerUp: Equatable, Sendable { case small, big, fire }
  public enum Facing: Equatable, Sendable { case left, right }

  public internal(set) var powerUp: PowerUp = .small
  public internal(set) var facing: Facing = .right
  public internal(set) var jumpState: JumpState = .none
  public internal(set) var moveState: MoveState = .none
  public internal(set) var moving = false
  public internal(set) var blinking = false
  public internal(set) var blinkingShow = true
  var blinkValue = 0
  var upPressed = false

  // Jump parabola state (50ms ticks, t advances 0.35 per tick).
  var startVelocity: Double = 0
  var startPosition: Double = 0
  var currentPosition: Double = 0
  var oldPosition: Double = 0
  var timeCount: Double = 0

  // Horizontal run acceleration / stop slide.
  var xCount: Double = 0
  var xAdd: Double = 0

  let fireBalls: [FireBall]
  var fireBallIndex = 0

  public internal(set) var collectedCoins = 0

  init(x: Int, y: Int, world: GameWorld) {
    fireBalls = [FireBall(world: world), FireBall(world: world)]
    super.init(kind: .mario)
    for ball in fireBalls {
      addChild(ball)
    }
    setProperties()
    self.x = x * 16
    self.y = GameWorld.levelHeight - 16 * y - height

    world.on(.t100) { [self] world in onAnimate(world) }
    world.on(.t50) { [self] world in onJumpTick(world) }
    world.on(.t50) { [self] world in onMoveTick(world) }
    world.on(.t50) { world in world.checkLevelCollisions() }
  }

  public var sheet: SpriteSheet {
    switch powerUp {
    case .small: .marioSmall
    case .big: .marioBig
    case .fire: .marioFire
    }
  }

  public override var rect: IRect {
    switch powerUp {
    case .small: IRect(x: x, y: y, width: 16, height: 16)
    case .big, .fire: IRect(x: x, y: y, width: 16, height: 27)
    }
  }

  override var isDrawn: Bool { blinkingShow }

  override func renderable() -> Renderable? {
    guard isDrawn else { return nil }
    return Renderable(
      sheet: sheet,
      source: IRect(x: 16 * imageIndex, y: 0, width: sheet.size.width / 6, height: sheet.size.height),
      dest: IRect(x: x, y: y, width: width, height: height)
    )
  }

  // MARK: Damage / power-ups

  func handleDamage(_ world: GameWorld) {
    switch powerUp {
    case .fire:
      powerUp = .big
      startBlinking()
      setProperties()
    case .big:
      powerUp = .small
      startBlinking()
      setProperties()
    case .small:
      die(world)
    }
  }

  func die(_ world: GameWorld) {
    collectedCoins = 0
    world.marioDied()
  }

  // MARK: Death animation

  /// Start the classic death leap: a small hop straight up, then a fall
  /// through the floor. Driven by `deathFallTick` while the world is in its
  /// `marioDying` phase.
  func beginDeathLeap() {
    moveState = .none
    moving = false
    blinking = false
    blinkingShow = true
    imageIndex = facing == .left ? 4 : 5  // jump pose
    jumpState = .up
    timeCount = 0
    startPosition = Double(y)
    startVelocity = -20
  }

  func deathFallTick() {
    timeCount += 350.0 / 1000.0
    y = Int(startPosition + startVelocity * timeCount + 4.9 * timeCount * timeCount)
  }

  func setProperties() {
    switch powerUp {
    case .small:
      width = 16
      height = 16
      y += 11
    case .big, .fire:
      width = 16
      height = 27
      y -= 11
    }
  }

  func startBlinking() {
    if !blinking {
      blinking = true
      blinkValue = 0
    }
  }

  // MARK: Input actions

  func move(_ state: MoveState) {
    moveState = state
    if state == .left { facing = .left }
    if state == .right { facing = .right }
  }

  func stopMove() {
    guard moveState != .stopping else { return }
    switch moveState {
    case .left: facing = .left
    case .right: facing = .right
    default: break
    }
    moveState = .stopping
    if !upPressed {
      xCount = 5
      xAdd = 0
    }
  }

  func startJump(kill: Bool, defaultVelocity: Double, world: GameWorld) {
    if !kill {
      upPressed = true
    }
    if jumpState == .none || kill {
      world.play(.jump)
      jumpState = .up
      startPosition = Double(y)
      oldPosition = Double(y)
      currentPosition = Double(y)
      timeCount = 0
      startVelocity = defaultVelocity != 0 ? defaultVelocity : -38
    }
  }

  func fireBall(_ world: GameWorld) {
    guard powerUp == .fire else { return }
    let ball = fireBalls[fireBallIndex]
    if !ball.started {
      let dir: FireBall.Dir = facing == .right ? .right : .left
      ball.run(x: x, y: y, type: .mario, dir: dir, world: world)
      fireBallIndex = (fireBallIndex + 1) % 2
      world.play(.fireball)
    }
  }

  // MARK: Collision response

  /// Block kinds that are solid for Mario's movement. Exits are passable;
  /// hidden question blocks are excluded via their `visible` flag until hit.
  static let wallKinds: Set<EntityKind> = [
    .grass, .solidBlock, .ground1, .brick, .pipeUp,
    .blockQuestion, .blockQuestionHidden, .movingBlock,
  ]

  /// Any solid block hit on the given side during the last pass? Legacy
  /// direction names: a `.left` collision is a wall against Mario's RIGHT
  /// side (it pushes him left), and vice versa.
  func touchesWall(_ side: CollisionDirection) -> Bool {
    hits.contains { hit in
      Mario.wallKinds.contains(hit.other.kind) && hit.collision.dir == side
    }
  }

  /// Deliberate fix over the legacy engine (the "climb over walls" bug):
  /// resolve each movement axis immediately after its position step, so the
  /// collision pass only ever sees flush contacts. The legacy classifier
  /// misread a sideways step into a block just below its top edge as "landed
  /// on top" (and a deep fall across a tile seam as a side hit), because
  /// movement used to run unchecked before classification. Flush contacts
  /// still register (containment is edge-inclusive), so all the gameplay
  /// callbacks — landing, head bumps, wall stops — keep firing.
  func resolveHorizontalOverlap(movedBy dx: Int, world: GameWorld) {
    guard dx != 0 else { return }
    for block in world.objects where block !== self && block.visible {
      guard Mario.wallKinds.contains(block.kind) else { continue }
      let b = block.rect
      let r = rect
      guard r.x < b.maxX, r.maxX > b.x, r.y < b.maxY, r.maxY > b.y else { continue }
      if dx > 0 {
        if r.maxX - b.x <= dx { x = b.x - width }
      } else {
        if b.maxX - r.x <= -dx { x = b.maxX }
      }
    }
  }

  func resolveVerticalOverlap(movedBy dy: Int, world: GameWorld) {
    guard dy != 0 else { return }
    for block in world.objects where block !== self && block.visible {
      guard Mario.wallKinds.contains(block.kind) else { continue }
      let b = block.rect
      let r = rect
      guard r.x < b.maxX, r.maxX > b.x, r.y < b.maxY, r.maxY > b.y else { continue }
      if dy > 0 {
        // Falling: land flush on the block top we crossed this step.
        if r.maxY - b.y <= dy { y = b.y - height }
      } else {
        // Rising: stop flush under the block bottom (head bump).
        if b.maxY - r.y <= -dy { y = b.maxY }
      }
    }
  }

  override func intersectionNone(_ world: GameWorld) {
    super.intersectionNone(world)
    if jumpState == .none {
      jumpState = .down
      startPosition = Double(y)
      timeCount = 0
      startVelocity = 0
    }
  }

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)
    switch g.kind {
    case .exit:
      world.levelCompleted()

    case .flower:
      g.visible = false
      if powerUp != .fire {
        powerUp = .fire
        setProperties()
        world.play(.mush)
      }

    case .mushRed:
      let mush = g as! MushRed
      mush.visible = false
      mush.animated = false
      mush.live = false
      if powerUp == .small {
        powerUp = .big
        setProperties()
        world.play(.mush)
      }

    case .mushLife:
      let mush = g as! MushLife
      mush.visible = false
      mush.animated = false
      mush.live = false
      world.emit(.extraLife)

    case .coin:
      let coin = g as! CoinBlock
      coin.animated = false
      coin.visible = false
      world.play(.coin)
      collectedCoins += 1

    case .goomba:
      let goomba = g as! MonsterGoomba
      if c.dir == .up && !goomba.isFallDying {
        startJump(kill: true, defaultVelocity: upPressed ? 0 : -20, world: world)
        goomba.die()
        world.play(.stomp)
      }

    case .piranha:
      if c.dir == .up {
        startJump(kill: true, defaultVelocity: upPressed ? 0 : -20, world: world)
        (g as! MonsterPiranha).die(world)
        world.play(.stomp)
      }

    case .koopa:
      let koopa = g as! MonsterKoopa
      if c.dir == .up {
        switch koopa.state {
        case .walking:
          startJump(kill: true, defaultVelocity: upPressed ? 0 : -20, world: world)
          koopa.setState(.shield)
          world.play(.stomp)
        case .shield where koopa.returningTime >= 3:
          koopa.setState(.shieldMoving)
        case .shieldMoving:
          startJump(kill: true, defaultVelocity: upPressed ? 0 : -20, world: world)
          koopa.setState(.shield)
        default:
          break
        }
      }

    case .movingBlock, .solidBlock, .pipeUp, .blockQuestion, .blockQuestionHidden, .brick, .grass:
      setDirections()

      if c.dir == .up {
        if let moving = g as? BlockMoving {
          y = g.newy - height
          moving.marioOn = true
        } else if jumpState != .none {
          y = g.newy - height
        }
        if jumpState != .none {
          jumpState = .none
        }
        setDirections()
      }

      if c.dir == .left {
        x = g.newx - width
      }

      if c.dir == .down {
        if jumpState == .up {
          jumpState = .down
          startPosition = Double(y)
          timeCount = 0
          startVelocity = 0

          if let question = g as? BlockQuestion {
            question.killMonsterOnTop()
            question.startMove(world)
            if question.hiddenItem != .coin {
              world.play(.block)
            } else {
              collectedCoins += 1
              world.play(.coin)
            }
          }
          if let brick = g as? BlockBrick {
            if powerUp == .big || powerUp == .fire {
              brick.breakBrick()
              world.play(.brick)
            } else {
              world.play(.block)
            }
          }
        }
      }

      if c.dir == .right {
        x = g.newx + g.width
      }

    default:
      break
    }
  }

  // MARK: Per-tick physics

  func setDirections() {
    if jumpState != .none {
      imageIndex = facing == .left ? 4 : 5
    } else if moving {
      if facing == .left {
        imageIndex = imageIndex == 0 ? 1 : 0
      } else {
        imageIndex = imageIndex == 2 ? 3 : 2
      }
    } else {
      imageIndex = facing == .right ? 2 : 0
    }
  }

  func onJumpTick(_ world: GameWorld) {
    if jumpState != .none {
      setDirections()
      timeCount += 350.0 / 1000.0
      oldPosition = currentPosition
      currentPosition = startPosition + startVelocity * timeCount + 4.9 * timeCount * timeCount
      let previousY = y
      if jumpState == .up {
        y = Int(currentPosition)
      } else {
        y += 6 + Int(timeCount)
      }
      resolveVerticalOverlap(movedBy: y - previousY, world: world)

      world.updateScreensY()

      if jumpState == .up && currentPosition > oldPosition {
        jumpState = .down
        timeCount = 0
      }
    } else {
      timeCount = 0
    }
  }

  func onMoveTick(_ world: GameWorld) {
    if y > GameWorld.levelHeight + 50 {
      die(world)
    }

    if moveState != .none && moveState != .stopping {
      moving = true
      setDirections()
      world.updateScreensX()

      if xAdd < 3 {
        xAdd += 0.5
      }
      if moveState == .right && !touchesWall(.left) {
        let step = 3 + Int(xAdd)
        x += step
        resolveHorizontalOverlap(movedBy: step, world: world)
      }
      if moveState == .left && !touchesWall(.right) {
        let step = 3 + Int(xAdd)
        x -= step
        resolveHorizontalOverlap(movedBy: -step, world: world)
      }
    }

    if moveState == .stopping {
      moving = true
      setDirections()
      world.updateScreensX()

      xCount = xCount.squareRoot()
      if facing == .right {
        x += Int(xCount)
        resolveHorizontalOverlap(movedBy: Int(xCount), world: world)
      }
      if facing == .left {
        x -= Int(xCount)
        resolveHorizontalOverlap(movedBy: -Int(xCount), world: world)
      }

      if xCount < 1.05 {  // standing
        moveState = .none
        moving = false
      }
    }
  }

  override func onAnimate(_ world: GameWorld) {
    if blinking {
      blinkValue += 1
      blinkingShow = blinkValue % 2 == 0
      if blinkValue == 20 {
        blinking = false
        blinkingShow = true
      }
    }
  }
}
