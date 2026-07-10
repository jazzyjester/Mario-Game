import Foundation

/// A fireball: Mario's bouncing projectile, or a piranha's aimed shot.
/// Both of Mario's fireballs (and each fire-piranha's single ball) exist for
/// the whole level and are recycled.
public final class FireBall: AnimatedEntity {
  public enum BallType: Equatable, Sendable { case mario, piranha }
  public enum Dir: Equatable, Sendable { case right, left }

  var type: BallType = .mario
  var direction: Dir = .right
  var dirX = 1
  public internal(set) var started = false
  var fire = false

  var startVelocity: Double = 0
  var startPosition: Double = 0
  var timeCount: Double = 0
  var offX: Double = 0
  var offY: Double = 0

  init(world: GameWorld) {
    super.init(kind: .fireBall)
    fire = false
    visible = false
    animatedCount = 4

    world.on(.t100) { [self] world in onAnimate(world) }
    world.on(.t50) { [self] world in onFire(world) }
  }

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)
    switch g.kind {
    case .grass, .blockQuestion, .brick:
      bounce()
    case .pipeUp, .solidBlock:
      started = false
      visible = false
    case .goomba:
      if type == .mario {
        (g as! MonsterGoomba).fallDie()
        started = false
        visible = false
      }
    case .koopa:
      if type == .mario {
        (g as! MonsterKoopa).setState(.shield)
        started = false
        visible = false
      }
    case .piranha:
      let piranha = g as! MonsterPiranha
      if type == .mario && piranha.move != .none {
        piranha.visible = false
        piranha.live = false
      }
    case .mario:
      if type != .mario {
        let mario = g as! Mario
        if !mario.blinking {
          mario.handleDamage(world)
        }
      }
    default:
      break
    }
  }

  func run(x: Int, y: Int, type: BallType, dir: Dir, world: GameWorld) {
    self.type = type
    self.direction = dir
    if type == .mario {
      dirX = dir == .right ? 1 : -1
    }
    setWidthHeight()
    width = 8
    height = 9
    newx = x
    newy = y
    bounce()
  }

  /// (Re)start the parabola from the current height — first launch flat,
  /// each ground bounce with upward velocity. Legacy `StartFireBall`.
  func bounce() {
    fire = true
    visible = true
    startPosition = Double(newy)
    startVelocity = started ? -15 : 0
    started = true
    timeCount = 0
  }

  func setOffsets(dx: Double, dy: Double) {
    offX = dx
    offY = dy
  }

  func onFire(_ world: GameWorld) {
    guard started, fire else { return }

    if type == .mario {
      timeCount += 250.0 / 1000.0
      newy = Int(startPosition + startVelocity * timeCount + 4.9 * timeCount * timeCount)
      newx += 5 * dirX
    } else {
      newx += Int(offX)
      newy += Int(offY)
    }

    if newy < 0 {
      started = false
    }
    // Out of range of Mario: despawn.
    if newx >= world.mario.x + 320 || newx < world.mario.x - 320 {
      started = false
      visible = false
    }
  }
}
