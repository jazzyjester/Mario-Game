import AppKit
import ComposableArchitecture
import MarioKit
import SwiftUI

/// The legacy viewport the game was designed around.
private let viewWidth = 320.0
private let viewHeight = 240.0

struct GameView: View {
  let store: StoreOf<GameFeature>

  var body: some View {
    ZStack {
      GameCanvas(session: store.session)
        .background(Color.black)

      hud

      if let overlay = store.overlay {
        // Cut to black immediately, then fade back out to the game.
        overlayView(overlay)
          .transition(.asymmetric(insertion: .identity, removal: .opacity))
      } else if store.paused {
        Text("PAUSED")
          .font(.system(size: 32, weight: .heavy, design: .monospaced))
          .foregroundStyle(.white)
          .shadow(radius: 4)
      }
    }
    .animation(.easeInOut(duration: 0.6), value: store.overlay)
    .task { await store.send(.task).finish() }
    .modifier(
      GameKeyHandling(
        onKeyDown: { key in handle(keyDown: key) },
        onKeyUp: { key in handle(keyUp: key) }
      )
    )
  }

  /// A solid top bar (distinct from the gameplay viewport below it), like a
  /// classic platformer's status bar: current level on the left, coins and
  /// lives on the right.
  private var hud: some View {
    VStack(spacing: 0) {
      HStack(spacing: 20) {
        Text(store.levelDisplayName)
        Spacer()
        HStack(spacing: 6) {
          coinIcon
          Text("\(store.session.world.mario.collectedCoins)")
        }
        HStack(spacing: 6) {
          marioIcon
          Text("× \(store.lives)")
        }
      }
      .font(.system(size: 14, weight: .bold, design: .monospaced))
      .foregroundStyle(.white)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background(Color.black.opacity(0.75))

      Spacer()
    }
  }

  private var coinIcon: some View {
    Group {
      if let image = SpriteStore.shared.frame(.coin, source: IRect(x: 0, y: 0, width: 16, height: 16)) {
        image.resizable().interpolation(.none).frame(width: 16, height: 16)
      }
    }
  }

  private var marioIcon: some View {
    marioSprite(size: 16)
  }

  /// Full-screen black interstitials, like the classic game's own screens.
  private func overlayView(_ overlay: GameFeature.State.Overlay) -> some View {
    ZStack {
      Color.black
      switch overlay {
      case .intro(let name):
        VStack(spacing: 16) {
          marioSprite(size: 48)
          Text(name)
            .font(.system(size: 34, weight: .heavy, design: .monospaced))
            .foregroundStyle(.white)
        }

      case .lives:
        HStack(spacing: 20) {
          marioSprite(size: 48)
          Text("× \(store.lives)")
            .font(.system(size: 30, weight: .heavy, design: .monospaced))
            .foregroundStyle(.white)
        }

      case .gameOver, .won:
        VStack(spacing: 24) {
          Text(overlay == .won ? "YOU WON!" : "GAME OVER")
            .font(.system(size: 36, weight: .heavy, design: .monospaced))
            .foregroundStyle(.white)
          Button(store.launchedFromEditor ? "Back to Editor" : "Back to Menu") {
            store.send(.overlayConfirmed)
          }
          .keyboardShortcut(.defaultAction)
        }
      }
    }
  }

  /// Small Mario, standing frame, pixel-scaled up.
  private func marioSprite(size: CGFloat) -> some View {
    Group {
      if let image = SpriteStore.shared.frame(
        .marioSmall, source: IRect(x: 32, y: 0, width: 16, height: 16))
      {
        image.resizable().interpolation(.none).frame(width: size, height: size)
      }
    }
  }

  /// Returns true when the key was handled (suppresses the system beep).
  private func handle(keyDown event: NSEvent) -> Bool {
    switch event.keyCode {
    case 123: store.send(.keyDown(.left))
    case 124: store.send(.keyDown(.right))
    case 126, 6: store.send(.keyDown(.jump))  // up arrow, Z
    case 49, 7: store.send(.firePressed)  // space, X
    case 35: store.send(.pauseToggled)  // P
    case 15: store.send(.restartTapped)  // R
    case 53: store.send(.backToMenuTapped)  // esc
    default: return false
    }
    return true
  }

  private func handle(keyUp event: NSEvent) -> Bool {
    switch event.keyCode {
    case 123: store.send(.keyUp(.left))
    case 124: store.send(.keyUp(.right))
    case 126, 6: store.send(.keyUp(.jump))
    default: return false
    }
    return true
  }
}

/// Draws one frame: parallax background + all world renderables, scaled
/// uniformly from the 320×240 legacy viewport to the available space.
struct GameCanvas: View {
  let session: GameSession

  var body: some View {
    // Frame images must be resolved outside the Canvas closure (SpriteStore
    // is main-actor; the canvas renderer isn't).
    let commands = drawCommands()
    Canvas(opaque: true) { context, size in
      let scale = min(size.width / viewWidth, size.height / viewHeight)
      let offsetX = (size.width - viewWidth * scale) / 2
      let offsetY = (size.height - viewHeight * scale) / 2
      context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
      context.translateBy(x: offsetX, y: offsetY)
      context.scaleBy(x: scale, y: scale)
      context.clip(to: Path(CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)))
      for (image, rect) in commands {
        context.draw(image, in: rect)
      }
    }
  }

  private func drawCommands() -> [(Image, CGRect)] {
    let store = SpriteStore.shared
    let world = session.world
    let screen = world.screen
    var commands: [(Image, CGRect)] = []

    // Parallax background: the legacy pipeline composed two offsets — the
    // 1/3-speed scroll and the background/output screen delta. Drawn as the
    // whole sheet shifted behind the clip (a per-scroll-position crop would
    // grow the sprite cache without bound).
    let bgSheet = SpriteSheet.background
    let bgSource = clamped(
      IRect(
        x: (screen.output.x - screen.background.x) + screen.output.x / 3,
        y: (GameWorld.levelHeight - Int(viewHeight))
          - (screen.output.y - screen.background.y) - screen.output.y / 3,
        width: Int(viewWidth),
        height: Int(viewHeight)
      ), to: bgSheet)
    let bgFull = IRect(x: 0, y: 0, width: bgSheet.size.width, height: bgSheet.size.height)
    if let bg = store.frame(bgSheet, source: bgFull) {
      commands.append(
        (
          bg,
          CGRect(
            x: CGFloat(-bgSource.x), y: CGFloat(-bgSource.y),
            width: CGFloat(bgSheet.size.width), height: CGFloat(bgSheet.size.height)
          )
        ))
    }

    // Entities: culled against the camera viewport inside the engine.
    let cameraX = screen.output.x
    let cameraY = screen.viewTopY
    let viewport = IRect(x: cameraX, y: cameraY, width: Int(viewWidth), height: Int(viewHeight))
    for renderable in world.renderables(visibleIn: viewport) {
      let dest = CGRect(
        x: CGFloat(renderable.dest.x - cameraX),
        y: CGFloat(renderable.dest.y - cameraY),
        width: CGFloat(renderable.dest.width),
        height: CGFloat(renderable.dest.height)
      )
      if let image = store.frame(renderable.sheet, source: renderable.source) {
        commands.append((image, dest))
      }
    }
    return commands
  }

  private func clamped(_ rect: IRect, to sheet: SpriteSheet) -> IRect {
    var rect = rect
    rect.x = max(0, min(rect.x, sheet.size.width - rect.width))
    rect.y = max(0, min(rect.y, sheet.size.height - rect.height))
    return rect
  }
}

/// Installs local NSEvent monitors for key handling while the view is on
/// screen. Returning `true` from a handler consumes the event.
struct GameKeyHandling: ViewModifier {
  let onKeyDown: (NSEvent) -> Bool
  let onKeyUp: (NSEvent) -> Bool

  @State private var monitors: [Any] = []

  func body(content: Content) -> some View {
    content
      .onAppear {
        monitors = [
          NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            onKeyDown(event) ? nil : event
          } as Any,
          NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            onKeyUp(event) ? nil : event
          } as Any,
        ]
      }
      .onDisappear {
        for monitor in monitors {
          NSEvent.removeMonitor(monitor)
        }
        monitors = []
      }
  }
}
