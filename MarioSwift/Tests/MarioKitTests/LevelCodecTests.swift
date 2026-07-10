import Foundation
import Testing

@testable import MarioKit

@Suite("Legacy level XML codec")
struct LevelCodecTests {
  @Test func decodesSampleXML() throws {
    let xml = """
      <?xml version="1.0" encoding="utf-8"?>
      <root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <Object>
          <OName>BlockQuestion</OName>
          <X>12</X><Y>7</Y>
          <Int1>13</Int1><Int2>0</Int2><Int3>0</Int3>
          <Bool1>true</Bool1><Bool2>false</Bool2><Bool3>false</Bool3>
        </Object>
        <Object>
          <OName>NotARealObject</OName>
          <X>1</X><Y>1</Y>
        </Object>
      </root>
      """
    let level = try LegacyLevelXML.decode(Data(xml.utf8))
    #expect(level.objects.count == 1)
    let object = try #require(level.objects.first)
    #expect(object.kind == .blockQuestion)
    #expect(object.x == 12)
    #expect(object.y == 7)
    #expect(object.ints == [13, 0, 0])
    #expect(object.bools == [true, false, false])
    #expect(QuestionBlockItem(rawValue: object.ints[0]) == .mushroom)
  }

  @Test func roundTripsThroughEncode() throws {
    let original = LevelDocument(objects: [
      LevelObject(kind: .mario, x: 2, y: 3),
      LevelObject(kind: .blockMoving, x: 10, y: 5, ints: [4, 1, 0], bools: [true, false, false]),
      LevelObject(kind: .exit, x: 60, y: 2),
    ])
    let decoded = try LegacyLevelXML.decode(LegacyLevelXML.encode(original))
    #expect(decoded == original)
  }

  @Test(arguments: ["lev1.xml", "Level2.xml", "Level3.xml"])
  func loadsShippedLevel(name: String) throws {
    let level = try BundledAssets.level(named: name)
    #expect(level.objects.count > 20)
    #expect(level.marioCount == 1)
    #expect(level.exitCount >= 1)
    // Every object fits in the level's 64×29 tile grid.
    for object in level.objects {
      #expect(object.x >= 0 && object.x < LevelDocument.pixelWidth / LevelDocument.tileSize)
      #expect(object.y >= 0 && object.y < LevelDocument.pixelHeight / LevelDocument.tileSize)
    }
  }

  @Test func shippedLevelsRoundTrip() throws {
    let level = try BundledAssets.level(named: "lev1.xml")
    let reEncoded = try LegacyLevelXML.decode(LegacyLevelXML.encode(level))
    #expect(reEncoded == level)
  }

  @Test func decodesLevelCatalog() throws {
    let catalog = try BundledAssets.catalog()
    #expect(catalog.levelFileNames == ["lev1.xml", "Level2.xml", "Level3.xml"])
    #expect(catalog.marioLives == 5)
  }

  @Test func bundledAssetLookups() throws {
    #expect(BundledAssets.imageURL("Mario/mariosmall.png") != nil)
    #expect(BundledAssets.imageURL("Blocks/brick.png") != nil)
    #expect(BundledAssets.soundURL("jump.wav") != nil)
    #expect(BundledAssets.soundURL("level1.mp3") != nil)
  }
}
