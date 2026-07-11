import Foundation

/// The object types that can be placed in a level file. Raw values are the
/// legacy `OName` strings used by the 2010 C# editor's XML format.
public enum ObjectKind: String, CaseIterable, Codable, Sendable, Hashable {
  case mario = "Mario"
  case blockGrass = "BlockGrass"
  case blockSolid = "BlockSolid"
  case blockBrick = "BlockBrick"
  case blockQuestion = "BlockQuestion"
  case blockQuestionHidden = "BlockQuestionHidden"
  case blockMoving = "BlockMoving"
  case blockPipeUp = "BlockPipeUp"
  case coin = "CoinBlock"
  case exit = "ExitBlock"
  case monsterGoomba = "MonsterGoomba"
  case monsterKoopa = "MonsterKoopa"
}

/// Item types that can hide inside a question block. Raw values are the
/// legacy C# `ObjectType` enum indices stored in the file's `Int1` field.
public enum QuestionBlockItem: Int, CaseIterable, Codable, Sendable, Hashable {
  case coin = 0
  case mushroom = 13
  case flower = 18
  case lifeMushroom = 23
}

/// One placed object in a level: a grid position (16px tiles, Y counted from
/// the bottom of the level) plus the legacy parameter slots.
public struct LevelObject: Equatable, Codable, Sendable, Hashable {
  public var kind: ObjectKind
  public var x: Int
  public var y: Int
  public var ints: [Int]
  public var bools: [Bool]

  public init(
    kind: ObjectKind,
    x: Int,
    y: Int,
    ints: [Int] = [0, 0, 0],
    bools: [Bool] = [false, false, false]
  ) {
    self.kind = kind
    self.x = x
    self.y = y
    self.ints = ints
    self.bools = bools
  }
}

/// A whole level. Pixel dimensions are fixed in the legacy engine.
public struct LevelDocument: Equatable, Codable, Sendable {
  public static let tileSize = 16
  public static let pixelWidth = 2048
  public static let pixelHeight = 464

  public var objects: [LevelObject]

  public init(objects: [LevelObject] = []) {
    self.objects = objects
  }

  public var marioCount: Int { objects.count(where: { $0.kind == .mario }) }
  public var exitCount: Int { objects.count(where: { $0.kind == .exit }) }
}
