import AppKit
import MarioKit
import SwiftUI

/// Loads sprite sheets from the MarioKit bundle and serves pre-cropped
/// frames as SwiftUI images (cropping at draw time isn't possible in
/// `Canvas`). Frames are cached by source rect.
@MainActor
final class SpriteStore {
  static let shared = SpriteStore()

  private var sheets: [SpriteSheet: CGImage] = [:]
  private struct FrameKey: Hashable {
    let sheet: SpriteSheet
    let x, y, width, height: Int
  }
  private var frames: [FrameKey: Image] = [:]

  func sheetImage(_ sheet: SpriteSheet) -> CGImage? {
    if let cached = sheets[sheet] { return cached }
    guard
      let url = sheet.url,
      let ns = NSImage(contentsOf: url),
      let cg = ns.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else { return nil }
    sheets[sheet] = cg
    return cg
  }

  func frame(_ sheet: SpriteSheet, source: IRect) -> Image? {
    let key = FrameKey(sheet: sheet, x: source.x, y: source.y, width: source.width, height: source.height)
    if let cached = frames[key] { return cached }
    guard let sheetImage = sheetImage(sheet) else { return nil }

    // Sheet PNGs are authored at 1x; CGImage size == sheet.size.
    let scaleX = CGFloat(sheetImage.width) / CGFloat(sheet.size.width)
    let scaleY = CGFloat(sheetImage.height) / CGFloat(sheet.size.height)
    let crop = CGRect(
      x: CGFloat(source.x) * scaleX,
      y: CGFloat(source.y) * scaleY,
      width: CGFloat(source.width) * scaleX,
      height: CGFloat(source.height) * scaleY
    )
    guard let cropped = sheetImage.cropping(to: crop) else { return nil }
    let image = Image(decorative: cropped, scale: 1)
      .interpolation(.none)
    frames[key] = image
    return image
  }
}
