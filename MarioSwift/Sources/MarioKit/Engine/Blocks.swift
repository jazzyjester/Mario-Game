import Foundation

public final class BlockGrass: Entity {
  init(x: Int, y: Int) {
    super.init(kind: .grass)
    imageIndex = 1
    self.x = x
    self.y = y
    setWidthHeight()
  }
}

public final class BlockSolid: Entity {
  init(x: Int, y: Int) {
    super.init(kind: .solidBlock)
    self.x = x
    self.y = y
    setWidthHeight()
  }
}

public final class ExitBlock: Entity {
  init(x: Int, y: Int) {
    super.init(kind: .exit)
    self.x = x
    self.y = y
    setWidthHeight()
    width = 16
  }
}

/// Debris spawned when a brick breaks: flies on a parabola until it leaves
/// the level. Legacy `BlockBrickPiece`.
public final class BlockBrickPiece: AnimatedEntity {
  public internal(set) var running = false
  var startVelocity: Double
  var startPosition: Double = 0
  var timeCount: Double = 0
  var dirX: Int

  init(x: Int, y: Int, startVelocity: Double, dirX: Int, world: GameWorld) {
    self.startVelocity = startVelocity
    self.dirX = dirX
    super.init(kind: .brickPiece)
    animatedCount = 4
    self.x = x
    self.y = y
    setWidthHeight()
    startPosition = Double(newy)

    world.on(.t50) { [self] world in onFall(world) }
    world.on(.t200) { [self] world in onAnimate(world) }
  }

  override var isDrawn: Bool { running }

  func onFall(_ world: GameWorld) {
    guard running else { return }
    timeCount += 500.0 / 1000.0
    newy = Int(startPosition + startVelocity * timeCount + 4.9 * timeCount * timeCount)
    newx += dirX * 3
    if newy > GameWorld.levelHeight {
      running = false
      visible = false
    }
  }
}

public final class BlockBrick: AnimatedEntity {
  let pieces: [BlockBrickPiece]

  init(x: Int, y: Int, world: GameWorld) {
    pieces = [
      BlockBrickPiece(x: x, y: y, startVelocity: -30, dirX: 1, world: world),
      BlockBrickPiece(x: x, y: y, startVelocity: -30, dirX: -1, world: world),
      BlockBrickPiece(x: x, y: y, startVelocity: -15, dirX: 1, world: world),
      BlockBrickPiece(x: x, y: y, startVelocity: -15, dirX: -1, world: world),
    ]
    super.init(kind: .brick)
    animatedCount = 4
    self.x = x
    self.y = y
    setWidthHeight()
    for piece in pieces {
      addChild(piece)
    }
    world.on(.t100) { [self] world in onAnimate(world) }
  }

  func breakBrick() {
    visible = false
    animated = false
    for piece in pieces {
      piece.running = true
    }
  }
}

/// Question block. Bounces when hit from below and releases its hidden item.
public class BlockQuestion: AnimatedEntity {
  public internal(set) var hit = false
  public internal(set) var open = false
  var offY: Double = 0
  var dirY = 0

  public internal(set) var hiddenItem: QuestionBlockItem
  var hiddenObject: Entity!

  convenience init(x: Int, y: Int, hidden: QuestionBlockItem, world: GameWorld) {
    self.init(kind: .blockQuestion, x: x, y: y, hidden: hidden, world: world)
  }

  init(kind: EntityKind, x: Int, y: Int, hidden: QuestionBlockItem, world: GameWorld) {
    hiddenItem = hidden
    super.init(kind: kind)
    animatedCount = 4
    self.x = x
    self.y = y
    setWidthHeight()

    switch hidden {
    case .coin:
      hiddenObject = CoinBlock(x: x, y: y, movingCoin: true, world: world)
    case .mushroom:
      hiddenObject = MushRed(x: x, y: y + 1, world: world)
    case .lifeMushroom:
      hiddenObject = MushLife(x: x, y: y + 1, world: world)
    case .flower:
      hiddenObject = Flower(x: x, y: y + 1)
    }
    addChild(hiddenObject)

    world.on(.t100) { [self] world in onAnimate(world) }
    world.on(.t50) { [self] world in onBlockHit(world) }
  }

  /// A monster standing on the block when it's bumped gets killed
  /// (legacy `isMonsterExist`).
  func killMonsterOnTop() {
    guard !open else { return }
    for hit in hits {
      switch hit.other {
      case let goomba as MonsterGoomba:
        goomba.fallDie()
        return
      case let koopa as MonsterKoopa:
        koopa.setState(.shield)
        return
      default:
        continue
      }
    }
  }

  func startMove(_ world: GameWorld) {
    guard !hit, !open else { return }
    open = true
    dirY = -1
    hit = true
    offY = 0

    switch hiddenItem {
    case .flower:
      hiddenObject.visible = true
    case .lifeMushroom:
      let mush = hiddenObject as! MushLife
      mush.visible = true
      mush.live = true
    case .mushroom:
      let mush = hiddenObject as! MushRed
      mush.visible = true
      mush.live = true
    case .coin:
      world.play(.coin)
      (hiddenObject as! CoinBlock).moveCoinUp()
    }
  }

  /// The 2px up/down bounce after being hit.
  func onBlockHit(_ world: GameWorld) {
    guard hit else { return }
    if dirY == -1 {
      offY += 1
      newy += dirY * Int(offY)
      if offY == 2 {
        dirY = 1
        offY = 0
      }
    } else {
      offY += 1
      newy += Int(offY)
      if offY == 2 {
        dirY = -1
        offY = 0
        hit = false
      }
    }
  }

  override func onAnimate(_ world: GameWorld) {
    if open {
      animated = false
      imageIndex = 4
    } else {
      super.onAnimate(world)
    }
  }
}

/// Invisible question block: only appears once bumped from below.
public final class BlockQuestionHidden: BlockQuestion {
  init(x: Int, y: Int, hidden: QuestionBlockItem, world: GameWorld) {
    super.init(kind: .blockQuestionHidden, x: x, y: y, hidden: hidden, world: world)
    animated = false
    visible = false
  }

  override var isDrawn: Bool { open && visible }

  override func onBlockHit(_ world: GameWorld) {
    super.onBlockHit(world)

    // Being invisible, this block is skipped by the normal collision sweep
    // (invisible entities don't collide), so it probes Mario directly.
    let mario = world.mario!
    guard let c = classifyCollision(src: mario.rect, dest: rect), c.dir == .down else { return }
    if mario.jumpState == .up {
      visible = true
      killMonsterOnTop()
      startMove(world)
      mario.jumpState = .down
      mario.startPosition = Double(mario.y)
      mario.timeCount = 0
      mario.startVelocity = 0
      if hiddenItem != .coin {
        world.play(.block)
      }
    }
  }
}

/// Moving platform. Travels `maxDistance` around its start position along
/// one axis, slowing near the ends, and carries Mario when he stands on it.
public final class BlockMoving: Entity {
  public enum Axis: Equatable, Sendable { case upDown, rightLeft }

  let axis: Axis
  let maxDistance: Int
  var startPosition = 0
  var dir: Double
  var marioOn = false

  init(x: Int, y: Int, distance: Int, axis: Axis, startReversed: Bool, world: GameWorld) {
    self.axis = axis
    self.maxDistance = distance
    self.dir = startReversed ? -2.0 : 2.0
    super.init(kind: .movingBlock)
    self.x = x
    self.y = y
    setWidthHeight()
    width = 50
    startPosition = axis == .upDown ? newy : newx

    world.on(.t50) { [self] world in onMove(world) }
  }

  override func intersectionNone(_ world: GameWorld) {
    super.intersectionNone(world)
    marioOn = false
  }

  func onMove(_ world: GameWorld) {
    if axis == .upDown {
      newy += Int(dir)
    } else {
      newx += Int(dir)
    }

    if marioOn {
      let mario = world.mario!
      if axis == .upDown {
        mario.y = newy - mario.height
        world.updateScreensY()
      } else {
        mario.x += Int(dir)
        world.updateScreensX()
      }
    }

    let position = axis == .upDown ? newy : newx
    if dir > 0 {
      if position >= startPosition + maxDistance - 5 { dir = 1 }
      if position >= startPosition + maxDistance { dir = -2 }
    } else {
      if position <= startPosition - maxDistance + 5 { dir = -1 }
      if position <= startPosition - maxDistance { dir = 2 }
    }
  }
}

/// Pipe, optionally home to a piranha plant that pops out periodically.
public final class BlockPipeUp: Entity {
  public internal(set) var monster: MonsterPiranha?

  init(x: Int, y: Int, piranha: PiranhaKind, world: GameWorld) {
    super.init(kind: .pipeUp)
    if piranha != .none {
      let monster = MonsterPiranha(x: x, y: y, type: piranha, world: world)
      self.monster = monster
      addChild(monster)
    }
    self.x = x
    self.y = y
    setWidthHeight()
  }
}
