import Foundation

/// A coin: either placed in the level (animated, collectible) or hidden in a
/// question block (`movingCoin`), where it only appears for the brief
/// pop-up animation when the block is hit.
public final class CoinBlock: AnimatedEntity {
  var moveUp = false
  var yOff: Double = 0

  init(x: Int, y: Int, movingCoin: Bool, world: GameWorld) {
    super.init(kind: .coin)
    if movingCoin {
      visible = false
      animated = false
    }
    animatedCount = 4
    self.x = x
    self.y = y
    setWidthHeight()

    world.on(.t100) { [self] world in onAnimate(world) }
  }

  func moveCoinUp() {
    if !moveUp {
      moveUp = true
      yOff = 0
    }
  }

  override func onAnimate(_ world: GameWorld) {
    super.onAnimate(world)
    if moveUp {
      visible = true
      animated = true
      yOff += 0.5
      newy -= 6 + Int(yOff)
      if yOff >= 2 {
        moveUp = false
        visible = false
        animated = false
      }
    }
  }
}

/// Red mushroom (grow). Spawns hidden inside a question block and starts
/// walking once released.
public final class MushRed: MoveableEntity {
  init(x: Int, y: Int, world: GameWorld) {
    super.init(kind: .mushRed)
    imageCount = 2
    imageIndex = 0
    self.x = x
    self.y = y
    walkStep = 2
    setWidthHeight()
    live = false
    visible = false

    world.on(.t50) { [self] world in onWalk(world) }
  }

  override func onWalk(_ world: GameWorld) {
    guard live else { return }
    super.onWalk(world)
  }
}

/// Green 1-up mushroom (second frame of the mushroom sheet).
public final class MushLife: MoveableEntity {
  init(x: Int, y: Int, world: GameWorld) {
    super.init(kind: .mushLife)
    imageCount = 2
    imageIndex = 1
    self.x = x
    self.y = y
    walkStep = 2
    setWidthHeight()
    live = false
    visible = false

    world.on(.t50) { [self] world in onWalk(world) }
  }

  override func onWalk(_ world: GameWorld) {
    guard live else { return }
    super.onWalk(world)
  }
}

/// Fire flower. Static; appears above its question block when released.
public final class Flower: Entity {
  init(x: Int, y: Int) {
    super.init(kind: .flower)
    visible = false
    self.x = x
    self.y = y
    setWidthHeight()
  }
}
