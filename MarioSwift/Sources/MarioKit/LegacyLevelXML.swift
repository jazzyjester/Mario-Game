import Foundation

/// Reads and writes the legacy level XML produced by the 2010 C# editor:
///
/// ```xml
/// <root>
///   <Object>
///     <OName>BlockSolid</OName>
///     <X>0</X> <Y>2</Y>
///     <Int1>0</Int1> ... <Bool3>false</Bool3>
///   </Object>
/// </root>
/// ```
///
/// Unknown `OName`s are skipped on load (mirroring the C# loader), so files
/// remain forward/backward compatible.
public enum LegacyLevelXML {
  public enum CodecError: Error, Equatable {
    case malformedXML
  }

  public static func decode(_ data: Data) throws -> LevelDocument {
    guard let document = try? XMLDocument(data: data), let root = document.rootElement() else {
      throw CodecError.malformedXML
    }

    var objects: [LevelObject] = []
    for element in root.elements(forName: "Object") {
      func text(_ name: String) -> String? {
        element.elements(forName: name).first?.stringValue
      }
      func int(_ name: String) -> Int { text(name).flatMap(Int.init) ?? 0 }
      func bool(_ name: String) -> Bool { text(name) == "true" }

      guard let kind = text("OName").flatMap(ObjectKind.init(rawValue:)) else { continue }
      objects.append(
        LevelObject(
          kind: kind,
          x: int("X"),
          y: int("Y"),
          ints: [int("Int1"), int("Int2"), int("Int3")],
          bools: [bool("Bool1"), bool("Bool2"), bool("Bool3")]
        )
      )
    }
    return LevelDocument(objects: objects)
  }

  public static func encode(_ level: LevelDocument) -> Data {
    let root = XMLElement(name: "root")
    root.addAttribute(XMLNode.attribute(withName: "xmlns:xsi", stringValue: "http://www.w3.org/2001/XMLSchema-instance") as! XMLNode)
    root.addAttribute(XMLNode.attribute(withName: "xmlns:xsd", stringValue: "http://www.w3.org/2001/XMLSchema") as! XMLNode)

    for object in level.objects {
      let element = XMLElement(name: "Object")
      func add(_ name: String, _ value: String) {
        element.addChild(XMLElement(name: name, stringValue: value))
      }
      add("OName", object.kind.rawValue)
      add("X", String(object.x))
      add("Y", String(object.y))
      for (index, value) in object.ints.prefix(3).enumerated() {
        add("Int\(index + 1)", String(value))
      }
      for (index, value) in object.bools.prefix(3).enumerated() {
        add("Bool\(index + 1)", value ? "true" : "false")
      }
      root.addChild(element)
    }

    let document = XMLDocument(rootElement: root)
    document.version = "1.0"
    document.characterEncoding = "utf-8"
    return document.xmlData(options: .nodePrettyPrint)
  }
}

/// The legacy `LevelManager.xml`: ordered level file names plus persisted
/// progress (current level, remaining lives).
public struct LevelCatalog: Equatable, Sendable {
  public var currentLevelIndex: Int
  public var marioLives: Int
  public var levelFileNames: [String]

  public init(currentLevelIndex: Int = 0, marioLives: Int = 5, levelFileNames: [String] = []) {
    self.currentLevelIndex = currentLevelIndex
    self.marioLives = marioLives
    self.levelFileNames = levelFileNames
  }

  public static func decode(_ data: Data) throws -> LevelCatalog {
    guard let document = try? XMLDocument(data: data), let root = document.rootElement() else {
      throw LegacyLevelXML.CodecError.malformedXML
    }
    let index = root.elements(forName: "CurrentLevelIndex").first?.stringValue.flatMap(Int.init) ?? 0
    let lives = root.elements(forName: "MarioLives").first?.stringValue.flatMap(Int.init) ?? 5
    let names = root.elements(forName: "LevelFilePaths").first?
      .elements(forName: "string")
      .compactMap(\.stringValue) ?? []
    return LevelCatalog(currentLevelIndex: index, marioLives: lives, levelFileNames: names)
  }
}

/// Access to the levels, images, and sounds bundled with MarioKit.
public enum BundledAssets {
  public static var bundle: Bundle { Bundle.module }

  public static func levelURL(named name: String) -> URL? {
    // Names in LevelManager.xml include the .xml extension already.
    let base = (name as NSString).deletingPathExtension
    return bundle.url(forResource: base, withExtension: "xml", subdirectory: "Resources/Levels")
  }

  public static func level(named name: String) throws -> LevelDocument {
    guard let url = levelURL(named: name) else {
      throw LegacyLevelXML.CodecError.malformedXML
    }
    return try LegacyLevelXML.decode(try Data(contentsOf: url))
  }

  public static func catalog() throws -> LevelCatalog {
    guard
      let url = bundle.url(
        forResource: "LevelManager", withExtension: "xml", subdirectory: "Resources/Levels")
    else {
      throw LegacyLevelXML.CodecError.malformedXML
    }
    return try LevelCatalog.decode(try Data(contentsOf: url))
  }

  public static func imageURL(_ relativePath: String) -> URL? {
    let base = (relativePath as NSString).deletingPathExtension
    let directory = (relativePath as NSString).deletingLastPathComponent
    return bundle.url(
      forResource: (base as NSString).lastPathComponent,
      withExtension: (relativePath as NSString).pathExtension,
      subdirectory: "Resources/Images/\(directory)"
    )
  }

  public static func soundURL(_ fileName: String) -> URL? {
    let base = (fileName as NSString).deletingPathExtension
    return bundle.url(
      forResource: base,
      withExtension: (fileName as NSString).pathExtension,
      subdirectory: "Resources/Sounds"
    )
  }
}
