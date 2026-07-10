import AppKit
import ComposableArchitecture
import MarioKit
import SwiftUI

/// Renders one frame of lev1 (after `ticks` ticks of hold-right input) to a
/// PNG. Debug aid for verifying the renderer headlessly:
/// `swift run MarioApp --screenshot /tmp/frame.png 40`
@MainActor
func renderGameScreenshot(to path: String, ticks: Int) {
  do {
    var session = try GameSession(level: BundledAssets.level(named: "lev1.xml"))
    for tick in 0..<ticks {
      _ = session.advance(GameInput(right: true, jump: tick % 31 < 8))
    }

    let renderer = ImageRenderer(
      content: GameCanvas(session: session).frame(width: 640, height: 480))
    renderer.scale = 1
    guard let cgImage = renderer.cgImage else {
      FileHandle.standardError.write(Data("screenshot: no image rendered\n".utf8))
      exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    guard let png = rep.representation(using: .png, properties: [:]) else {
      FileHandle.standardError.write(Data("screenshot: PNG encode failed\n".utf8))
      exit(1)
    }
    try png.write(to: URL(fileURLWithPath: path))
    print("screenshot: wrote \(path) at tick \(session.world.tickCount), mario at (\(session.world.mario.x), \(session.world.mario.y))")
  } catch {
    FileHandle.standardError.write(Data("screenshot: \(error)\n".utf8))
    exit(1)
  }
}

/// Same idea for the editor: `swift run MarioApp --editor-screenshot /tmp/e.png`
/// renders the editor UI over lev1.
@MainActor
func renderEditorScreenshot(to path: String) {
  do {
    var state = EditorFeature.State()
    state.document = try BundledAssets.level(named: "lev1.xml")
    state.tool = .place(.blockQuestion)
    state.zoom = 1
    state.hoverCell = .init(x: 10, y: 5)
    let store = Store(initialState: state) { EditorFeature() }

    // HSplitView (AppKit-backed) can't be rendered offscreen; the canvas is
    // the custom part worth checking.
    let renderer = ImageRenderer(
      content: EditorCanvas(store: store))
    renderer.scale = 1
    guard let cgImage = renderer.cgImage else {
      FileHandle.standardError.write(Data("editor screenshot: no image rendered\n".utf8))
      exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    guard let png = rep.representation(using: .png, properties: [:]) else {
      FileHandle.standardError.write(Data("editor screenshot: PNG encode failed\n".utf8))
      exit(1)
    }
    try png.write(to: URL(fileURLWithPath: path))
    print("editor screenshot: wrote \(path)")
  } catch {
    FileHandle.standardError.write(Data("editor screenshot: \(error)\n".utf8))
    exit(1)
  }
}
