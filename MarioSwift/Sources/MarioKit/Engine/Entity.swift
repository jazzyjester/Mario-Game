import Foundation

/// Runtime entity types. These mirror the legacy `ObjectType` cases that can
/// exist during gameplay (a superset of the placeable `ObjectKind`s, because
/// question blocks spawn items, bricks spawn debris, etc).
public enum EntityKind: Equatable, Sendable {
  case mario
  case coin, mushRed, mushLife, flower
  case grass, solidBlock, ground1, brick, brickPiece
  case blockQuestion, blockQuestionHidden, movingBlock, pipeUp, exit
  case goomba, koopa, piranha
  case fireBall

  var sheet: SpriteSheet {
    switch self {
    case .mario: .marioSmall  // Mario's actual sheet depends on his power-up state.
    case .coin: .coin
    case .mushRed, .mushLife: .mush
    case .flower: .flower
    case .grass: .grass
    case .solidBlock: .solidBlock
    case .ground1: .ground1
    case .brick: .brick
    case .brickPiece: .brickPiece
    case .blockQuestion, .blockQuestionHidden: .itemBlock
    case .movingBlock: .movingBlock
    case .pipeUp: .pipeUp
    case .exit: .exit
    case .goomba: .goomba
    case .koopa: .koopa
    case .piranha: .piranha
    case .fireBall: .fireBall
    }
  }
}

/// Base game object: a faithful port of the legacy `GraphicObject` /
/// `StaticGraphicObject` pair. Positions use two coordinate systems, exactly
/// like the original: blocks keep their grid cell in `x`/`y` and their pixel
/// position in `newx`/`newy`; Mario stores pixels directly in `x`/`y`.
public class Entity {
  public let kind: EntityKind

  public internal(set) var x = 0
  public internal(set) var y = 0
  public internal(set) var newx = 0
  public internal(set) var newy = 0
  public internal(set) var width = 0
  public internal(set) var height = 0

  public internal(set) var visible = true
  public internal(set) var imageIndex = 0
  public internal(set) var offsetIndex = 0
  public internal(set) var imageCount = 1

  var children: [Entity] = []

  /// Collisions recorded for this entity during the most recent collision
  /// pass (the legacy `IntersectsObjects`). Consulted by Mario's wall checks
  /// and the question block's monster check.
  var hits: [(collision: Collision, other: Entity)] = []

  init(kind: EntityKind) {
    self.kind = kind
  }

  public var rect: IRect {
    IRect(x: newx, y: newy, width: width, height: height)
  }

  /// Legacy `SetWidthHeight`: square size from the sheet height, pixel
  /// position from the grid cell (grid Y counts from the level bottom).
  func setWidthHeight() {
    width = kind.sheet.size.height
    height = kind.sheet.size.height
    newx = x * LevelDocument.tileSize
    newy = GameWorld.levelHeight - (y + 1) * LevelDocument.tileSize
    if height == 32 { newy -= 16 }
  }

  func addChild(_ entity: Entity) {
    children.append(entity)
  }

  // Collision callbacks, overridden by subclasses.
  func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {}
  func intersectionNone(_ world: GameWorld) {}

  /// Whether the renderer should draw this entity right now.
  var isDrawn: Bool { visible }

  /// Draw command matching `StaticGraphicObject.Draw`. Note the legacy quirk
  /// that the source X advances by the entity's *collision* width while the
  /// frame size comes from the sheet — both are ported as-is; the renderer
  /// clamps overflowing source rects to the sheet bounds.
  func renderable() -> Renderable? {
    guard isDrawn else { return nil }
    let sheet = self.kind.sheet
    let frameWidth = sheet.size.width / imageCount
    // The legacy blit could ask for a source wider than the sheet (e.g.
    // grass: frame index 1 of a 2-frame sheet with imageCount 1); GDI just
    // clipped it, so clamp to the sheet and shrink the destination to match.
    let sourceX = width * (imageIndex + offsetIndex)
    let clampedWidth = min(frameWidth, sheet.size.width - sourceX)
    return Renderable(
      sheet: sheet,
      source: IRect(x: sourceX, y: 0, width: clampedWidth, height: sheet.size.height),
      dest: IRect(x: newx, y: newy, width: clampedWidth, height: sheet.size.height)
    )
  }
}

/// Legacy `AnimatedGraphicObject`.
public class AnimatedEntity: Entity {
  public internal(set) var animatedCount = 1
  public internal(set) var animated = true

  override init(kind: EntityKind) {
    super.init(kind: kind)
    imageCount = kind.sheet.defaultImageCount
  }

  func onAnimate(_ world: GameWorld) {
    if animated {
      imageIndex += 1
      if imageIndex >= animatedCount { imageIndex = 0 }
    }
  }
}

/// Legacy `MoveableAnimatedObject`: walkers (monsters, mushrooms) that
/// reverse on side collisions and fall 2px/tick when airborne.
public class MoveableEntity: AnimatedEntity {
  var dirX = 1
  var dirY = 0
  public internal(set) var live = true
  var walkStep = 1
  var fall = false

  override func intersection(_ c: Collision, _ g: Entity, _ world: GameWorld) {
    super.intersection(c, g, world)
    switch g.kind {
    case .blockQuestion, .grass:
      if c.dir == .up { fall = false }
    case .brick, .piranha, .solidBlock, .pipeUp:
      if c.dir == .left || c.dir == .right {
        fall = false
        dirX *= -1
        onWalk(world)
      }
    default:
      break
    }
  }

  override func intersectionNone(_ world: GameWorld) {
    super.intersectionNone(world)
    fall = true
  }

  func onWalk(_ world: GameWorld) {
    newx += dirX * walkStep
    if fall { newy += 2 }
  }
}
