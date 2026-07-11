import Foundation

/// The sprite sheets bundled with MarioKit. Raw value is the path under
/// `Resources/Images/`. Frames are laid out horizontally.
public enum SpriteSheet: String, CaseIterable, Sendable {
  case coin = "Items/coin.png"
  case mush = "Items/mush.png"
  case flower = "Items/fireflower.png"
  case itemBlock = "Blocks/itemblock.png"
  case brick = "Blocks/brick.png"
  case brickPiece = "Blocks/brickpiece.png"
  case grass = "Blocks/grass.png"
  case ground1 = "Blocks/ground1.png"
  case pipeUp = "Blocks/pipeup.png"
  case movingBlock = "Blocks/movingblock.png"
  case solidBlock = "Blocks/solidblock.png"
  case exit = "Blocks/exit.png"
  case goomba = "Monsters/goomba.png"
  case koopa = "Monsters/koopa.png"
  case piranha = "Monsters/piranahplant.png"
  case marioSmall = "Mario/mariosmall.png"
  case marioBig = "Mario/mariobig.png"
  case marioFire = "Mario/mariofire.png"
  case fireBall = "Mario/fireball.png"
  case background = "Backgrounds/bgblock.png"
  case numbers = "Stuff/numbers.png"

  public var url: URL? { BundledAssets.imageURL(rawValue) }

  /// Pixel size of the sheet. The legacy engine derived object sizes and
  /// frame counts from the loaded bitmaps; we hardcode the measured sizes so
  /// the simulation never needs to touch image data.
  public var size: (width: Int, height: Int) {
    switch self {
    case .coin: (64, 16)
    case .mush: (32, 16)
    case .flower: (16, 16)
    case .itemBlock: (96, 16)
    case .brick: (64, 16)
    case .brickPiece: (32, 8)
    case .grass: (32, 16)
    case .ground1: (16, 16)
    case .pipeUp: (32, 32)
    case .movingBlock: (50, 16)
    case .solidBlock: (16, 16)
    case .exit: (16, 32)
    case .goomba: (64, 16)
    case .koopa: (160, 27)
    case .piranha: (160, 32)
    case .marioSmall: (96, 16)
    case .marioBig: (96, 27)
    case .marioFire: (96, 27)
    case .fireBall: (32, 9)
    case .background: (1024, 464)
    case .numbers: (80, 8)
    }
  }

  /// Legacy `AnimatedGraphicObject` computed `ImageCount = round(width/height)`.
  var defaultImageCount: Int {
    Int((Double(size.width) / Double(size.height)).rounded())
  }
}

/// One draw command: blit `source` from `sheet` to `dest` in level pixel
/// coordinates. The renderer applies the camera transform.
public struct Renderable: Equatable, Sendable {
  public var sheet: SpriteSheet
  public var source: IRect
  public var dest: IRect
}
