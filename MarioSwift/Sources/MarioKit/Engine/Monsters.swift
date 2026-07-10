import Foundation

public final class MonsterGoomba: MoveableEntity {
  /// True once the goomba was hit by a fireball or a bumped block: it drops
  /// through the level with the squashed sprite.
  public private(set) var isFallDying = false

  init(x: Int, y: Int, world: GameWorld) {
    super.init(kind: .goomba)
    animatedCount = 2
    self.x = x
    self.y = y
    setWidthHeight()

    world.on(.t50) { [self] world in onWalk(world) }
    world.on(.t100) { [self] world in onAnimate(world) }
  }

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)
    switch g {
    case let other as MonsterGoomba:
      dirX *= -1
      onWalk(world)
      other.dirX *= -1
      other.onWalk(world)
    case let mario as Mario:
      if c.dir != .down && !mario.blinking {
        mario.handleDamage(world)
      }
    default:
      break
    }
  }

  func fallDie() {
    isFallDying = true
  }

  /// Stomped: freeze with the squash frame, then disappear.
  func die() {
    animated = false
    live = false
  }

  override func onWalk(_ world: GameWorld) {
    if !isFallDying {
      super.onWalk(world)
    } else {
      animated = false
      imageIndex = 3
      newy += 3
      if newy >= GameWorld.levelHeight {
        visible = false
      }
    }
  }

  override func onAnimate(_ world: GameWorld) {
    guard visible else { return }
    if live {
      super.onAnimate(world)
    } else if imageIndex != 2 {
      imageIndex = 2  // squashed frame
    } else {
      visible = false  // one animation tick later, gone
    }
  }
}

public final class MonsterKoopa: MoveableEntity {
  public enum State: Equatable, Sendable { case walking, shield, returning, shieldMoving }

  public private(set) var state: State = .walking
  var returningTime = 0

  init(x: Int, y: Int, world: GameWorld) {
    super.init(kind: .koopa)
    self.x = x
    self.y = y
    imageCount = 10
    setWidthHeight()
    setState(.walking)

    world.on(.t50) { [self] world in onWalk(world) }
    world.on(.t100) { [self] world in onAnimate(world) }
  }

  override func onWalk(_ world: GameWorld) {
    if state == .shield && hits.isEmpty {
      super.onWalk(world)
    }

    if state == .walking || state == .shieldMoving {
      // Legacy offscreen cleanup: a koopa far to Mario's left disappears.
      if newx <= world.mario.x - 160, live {
        animated = false
        live = false
        visible = false
      }

      super.onWalk(world)

      if state != .shieldMoving {
        offsetIndex = dirX > 0 ? 2 : 0
      }
    }
  }

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)

    switch g {
    case let brick as BlockBrick:
      if state == .shieldMoving && (c.dir == .left || c.dir == .right) {
        brick.breakBrick()
      }
    case let goomba as MonsterGoomba:
      switch state {
      case .shieldMoving:
        goomba.fallDie()
      case .walking:
        goomba.dirX *= -1
        goomba.newx += 5 * goomba.dirX
        goomba.onWalk(world)
        dirX *= -1
        onWalk(world)
      case .shield:
        goomba.dirX *= -1
        goomba.newx += 5 * goomba.dirX
        goomba.onWalk(world)
      case .returning:
        break
      }
    case let mario as Mario:
      if state == .shield && returningTime >= 3 {
        if c.dir == .left { dirX = -1 }
        if c.dir == .right { dirX = 1 }
        setState(.shieldMoving)
      }

      // Damage Mario, except from a resting shield or a shield he just
      // kicked away from himself (ported condition, original precedence).
      if state != .shield {
        let justKicked =
          state == .shieldMoving && (dirX == -1 && c.dir == .left)
          || (dirX == 1 && c.dir == .right)
        if !justKicked {
          if c.dir != .down && !mario.blinking {
            mario.handleDamage(world)
          }
        }
      }
    default:
      break
    }
  }

  override func onAnimate(_ world: GameWorld) {
    super.onAnimate(world)

    if state == .shield {
      returningTime += 1
      if returningTime > 20 {
        setState(.returning)
      }
    }
    if state == .returning {
      returningTime += 1
      imageIndex = (returningTime % 2) * 4 + 4  // flicker between 4 and 8

      if returningTime > 40 {
        setState(.walking)
        returningTime = 0
      }
    }
  }

  func setState(_ newState: State) {
    state = newState
    switch newState {
    case .walking:
      width = 16
      height = 27
      animatedCount = 2
      newy -= 11
      walkStep = 1
      animated = true
    case .shield:
      width = 16
      height = 27
      returningTime = 0
      offsetIndex = 0
      imageIndex = 4
      animated = false
    case .returning:
      offsetIndex = 0
    case .shieldMoving:
      width = 16
      height = 27
      walkStep = 4
      animatedCount = 4
      offsetIndex = 4
      animated = true
    }
  }
}

public enum PiranhaKind: Int, Equatable, Sendable, CaseIterable {
  case none = 0
  case fish = 1
  case fire = 2
}

/// Piranha plant living in a pipe: cycles hidden → rising → out → sinking.
/// The fire variant shoots an aimed fireball at Mario as it sinks.
public final class MonsterPiranha: AnimatedEntity {
  public enum Move: Equatable, Sendable { case none, up, middle, down }
  enum Direction { case left, right }

  public private(set) var type: PiranhaKind
  public private(set) var move: Move = .none
  public internal(set) var live = true
  var direction: Direction = .right
  var offY = 0
  var fireOnce = false
  let ball: FireBall

  init(x: Int, y: Int, type: PiranhaKind, world: GameWorld) {
    self.type = type
    self.ball = FireBall(world: world)
    super.init(kind: .piranha)
    imageCount = 10
    setProperties()
    self.x = x
    self.y = y
    setWidthHeight()
    newx += 8
    width = 16
    addChild(ball)

    world.on(.t500) { [self] world in onAnimate(world) }
    world.on(.t50) { [self] world in onMove(world) }
  }

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)
    if let mario = g as? Mario {
      // Only harmful while out of the pipe.
      if move != .none, c.dir != .down, !mario.blinking {
        mario.handleDamage(world)
      }
    }
  }

  func setDirectionTowardsMario(_ world: GameWorld) {
    direction = newx >= world.mario.x ? .left : .right
    setProperties()
  }

  func onMove(_ world: GameWorld) {
    guard live else { return }

    switch move {
    case .up:
      animated = type != .fire
      offY += 1
      newy -= 1
      if offY >= height {
        move = .middle
        offY = 0
      }
    case .down:
      if type == .fire {
        animated = false
        if !ball.started {
          aimBallAtMario(world)
          if fireOnce {
            ball.run(x: newx, y: newy, type: .piranha, dir: .left, world: world)
            fireOnce = false
          }
        }
      } else {
        animated = true
      }
      offY += 1
      newy += 1
      if offY >= height {
        move = .none
        offY = 0
      }
    case .middle:
      animated = true
      offY += 1
      if offY >= height {
        move = .down
        fireOnce = true
        offY = 0
      }
    case .none:
      offY += 1
      if offY >= height * 2 {
        move = .up
        offY = 0
        setDirectionTowardsMario(world)
      }
    }
  }

  private func aimBallAtMario(_ world: GameWorld) {
    var dx = 5.0
    // Guarded against Mario standing exactly at the pipe (the original would
    // divide by zero here).
    let steps = max(1, abs(newx - world.mario.x) / Int(dx))
    let srcY = Double(world.mario.y)
    let destY = Double(newy - height)
    let dy = (srcY - destY) / Double(steps)
    if newx > world.mario.x { dx *= -1 }
    ball.setOffsets(dx: dx, dy: dy)
  }

  func die(_ world: GameWorld) {
    newy = GameWorld.levelHeight
    animated = false
    live = false
  }

  func setProperties() {
    switch type {
    case .fish:
      animatedCount = 2
      offsetIndex = 8
    case .fire:
      animatedCount = 4
      offsetIndex = direction == .left ? 0 : 4
    case .none:
      break
    }
  }
}
