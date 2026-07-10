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
  var enterPressed = false

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

  /// Any brick/solid block hit on the given side during the last pass?
  func touchesWall(_ side: CollisionDirection) -> Bool {
    hits.contains { hit in
      (hit.other.kind == .brick || hit.other.kind == .solidBlock) && hit.collision.dir == side
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
      if enterPressed {
        enterPressed = false
        world.levelCompleted()
      }

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
      if jumpState == .up {
        y = Int(currentPosition)
      } else {
        y += 6 + Int(timeCount)
      }

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
      // Note the legacy left/right swap: `.left` collisions are walls on
      // Mario's right side, and vice versa.
      if !touchesWall(.right) {
        if moveState == .right { x += 3 + Int(xAdd) }
      }
      if !touchesWall(.left) {
        if moveState == .left { x -= 3 + Int(xAdd) }
      }
    }

    if moveState == .stopping {
      moving = true
      setDirections()
      world.updateScreensX()

      xCount = xCount.squareRoot()
      if facing == .right { x += Int(xCount) }
      if facing == .left { x -= Int(xCount) }

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
