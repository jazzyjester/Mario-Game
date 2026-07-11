import AppKit
import ComposableArchitecture
import MarioKit
import SwiftUI

/// The game's title screen and its sub-screens (level select, options,
/// about), styled like a classic platformer front-end: sky, grass strip,
/// sprite decorations, and a keyboard-driven menu.
struct MenuView: View {
  let store: StoreOf<AppFeature>

  @State private var mainSelection = 0
  @State private var levelSelection = 0
  @State private var optionsSelection = 0

  private enum MenuItem: Int, CaseIterable {
    case newGame, levelSelect, editor, options, about, exit

    var title: String {
      switch self {
      case .newGame: "NEW GAME"
      case .levelSelect: "LEVEL SELECT"
      case .editor: "LEVEL EDITOR"
      case .options: "OPTIONS"
      case .about: "ABOUT"
      case .exit: "EXIT"
      }
    }
  }

  var body: some View {
    ZStack {
      background

      VStack(spacing: 36) {
        title

        switch store.screen {
        case .main: mainMenu
        case .levelSelect: levelSelect
        case .options: options
        case .about: about
        }
      }
      .padding(.bottom, 120)
    }
    .modifier(
      GameKeyHandling(
        onKeyDown: { event in handle(keyDown: event) },
        onKeyUp: { _ in false }
      )
    )
  }

  // MARK: Screens

  private var title: some View {
    VStack(spacing: 8) {
      Text("MARIO OBJECTS")
        .font(.system(size: 52, weight: .heavy, design: .monospaced))
        .foregroundStyle(Color(red: 0.92, green: 0.25, blue: 0.15))
        .shadow(color: .black.opacity(0.85), radius: 0, x: 4, y: 4)
      Text("EST. 2010 · REBUILT FOR MAC")
        .font(.system(size: 12, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.6), radius: 0, x: 1, y: 1)
    }
  }

  private var mainMenu: some View {
    VStack(spacing: 28) {
      VStack(alignment: .leading, spacing: 14) {
        ForEach(MenuItem.allCases, id: \.rawValue) { item in
          HStack(spacing: 14) {
            spriteView(.mush, frame: 0, scale: 1.6)
              .opacity(mainSelection == item.rawValue ? 1 : 0)
            Text(item.title)
              .font(.system(size: 24, weight: .heavy, design: .monospaced))
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.7), radius: 0, x: 2, y: 2)
          }
          .contentShape(Rectangle())
          .onHover { hovering in
            if hovering { mainSelection = item.rawValue }
          }
          .onTapGesture {
            mainSelection = item.rawValue
            activate(item)
          }
        }
      }

      Text("↑ ↓ choose · ⏎ select")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.white.opacity(0.8))
        .shadow(color: .black.opacity(0.6), radius: 0, x: 1, y: 1)
    }
  }

  private var levelSelect: some View {
    VStack(spacing: 24) {
      Text("SELECT LEVEL")
        .font(.system(size: 24, weight: .heavy, design: .monospaced))
        .foregroundStyle(.white)

      LazyVGrid(
        columns: Array(
          repeating: GridItem(.fixed(96), spacing: 18),
          count: max(1, min(4, store.levelNames.count))),
        spacing: 18
      ) {
        ForEach(store.levelNames.indices, id: \.self) { index in
          levelTile(index)
        }
      }

      Text("← → ↑ ↓ choose · ⏎ play · esc back")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.white.opacity(0.7))
    }
    .padding(36)
    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
  }

  private func levelTile(_ index: Int) -> some View {
    let unlocked = index < store.unlockedLevels
    let selected = levelSelection == index
    return VStack(spacing: 8) {
      if unlocked {
        Text("\(index + 1)")
          .font(.system(size: 36, weight: .heavy, design: .monospaced))
      } else {
        Image(systemName: "lock.fill")
          .font(.system(size: 30))
      }
      Text("LEVEL \(index + 1)")
        .font(.system(size: 11, weight: .bold, design: .monospaced))
    }
    .foregroundStyle(unlocked ? Color.white : Color.white.opacity(0.35))
    .frame(width: 96, height: 96)
    .background(
      unlocked ? Color(red: 0.22, green: 0.55, blue: 0.25) : Color.white.opacity(0.08),
      in: RoundedRectangle(cornerRadius: 10)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(selected ? Color.yellow : .clear, lineWidth: 3)
    )
    .contentShape(Rectangle())
    .onHover { hovering in
      if hovering { levelSelection = index }
    }
    .onTapGesture {
      levelSelection = index
      store.send(.levelSelected(index))
    }
  }

  private var options: some View {
    VStack(spacing: 24) {
      Text("OPTIONS")
        .font(.system(size: 24, weight: .heavy, design: .monospaced))
        .foregroundStyle(.white)

      VStack(alignment: .leading, spacing: 18) {
        optionRow(0, label: "SOUND EFFECTS", isOn: store.soundEnabled) {
          store.send(.soundToggled)
        }
        optionRow(1, label: "MUSIC", isOn: store.musicEnabled) {
          store.send(.musicToggled)
        }
      }

      Text("↑ ↓ choose · ⏎ toggle · esc back")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.white.opacity(0.7))
    }
    .padding(36)
    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
  }

  private func optionRow(
    _ index: Int, label: String, isOn: Bool, action: @escaping () -> Void
  ) -> some View {
    HStack(spacing: 14) {
      spriteView(.mush, frame: 0, scale: 1.4)
        .opacity(optionsSelection == index ? 1 : 0)
      Text(label)
        .frame(width: 240, alignment: .leading)
      Text(isOn ? "ON" : "OFF")
        .foregroundStyle(isOn ? Color.green : Color.red)
    }
    .font(.system(size: 20, weight: .heavy, design: .monospaced))
    .foregroundStyle(.white)
    .contentShape(Rectangle())
    .onHover { hovering in
      if hovering { optionsSelection = index }
    }
    .onTapGesture {
      optionsSelection = index
      action()
    }
  }

  private var about: some View {
    VStack(spacing: 20) {
      Text("ABOUT")
        .font(.system(size: 24, weight: .heavy, design: .monospaced))
        .foregroundStyle(.white)

      Text(
        """
        Mario Objects started in 2010 as a student project:
        a Mario-inspired game and level editor, written
        entirely by hand in C# and WinForms.

        In 2026 it was re-written for macOS with Claude Code AI —
        Swift, SwiftUI and the Composable Architecture — keeping
        the original sprites, sounds, levels and physics.
        """
      )
      .font(.system(size: 13, design: .monospaced))
      .foregroundStyle(.white.opacity(0.95))
      .multilineTextAlignment(.center)
      .lineSpacing(4)

      HStack(spacing: 10) {
        spriteView(.marioSmall, frame: 2, scale: 1.6)
        Text("Ronny Remesnik · Claude")
          .font(.system(size: 12, weight: .bold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.8))
      }

      Text("esc back")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.white.opacity(0.7))
    }
    .padding(36)
    .frame(maxWidth: 560)
    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
  }

  // MARK: Background

  private var background: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.32, green: 0.55, blue: 0.95),
          Color(red: 0.62, green: 0.82, blue: 1.0),
        ],
        startPoint: .top, endPoint: .bottom
      )

      VStack(spacing: 0) {
        Spacer()
        decorRow
        grassStrip
      }
    }
    .ignoresSafeArea()
  }

  /// Sprites standing on the grass, like a little diorama.
  private var decorRow: some View {
    HStack(alignment: .bottom, spacing: 70) {
      spriteView(.marioSmall, frame: 2, scale: 3)
      spriteView(.itemBlock, frame: 0, scale: 3)
        .padding(.bottom, 80)
      spriteView(.goomba, frame: 0, scale: 3)
      spriteView(.exit, frame: 0, scale: 2.5)
      spriteView(.pipeUp, frame: 0, scale: 3)
    }
  }

  private var grassStrip: some View {
    HStack(spacing: 0) {
      ForEach(0..<80, id: \.self) { _ in
        spriteView(.grass, frame: 1, scale: 2)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 32)
    .clipped()
  }

  /// One square frame of a sprite sheet, pixel-scaled.
  private func spriteView(_ sheet: SpriteSheet, frame: Int, scale: CGFloat) -> some View {
    let frameHeight = sheet.size.height
    let frameWidth = sheet == .exit ? 16 : frameHeight
    return Group {
      if let image = SpriteStore.shared.frame(
        sheet, source: IRect(x: frameWidth * frame, y: 0, width: frameWidth, height: frameHeight))
      {
        image
          .resizable()
          .interpolation(.none)
          .frame(width: CGFloat(frameWidth) * scale, height: CGFloat(frameHeight) * scale)
      }
    }
  }

  // MARK: Input

  private func activate(_ item: MenuItem) {
    switch item {
    case .newGame: store.send(.newGameTapped)
    case .levelSelect: store.send(.navigated(.levelSelect))
    case .editor: store.send(.editorTapped)
    case .options: store.send(.navigated(.options))
    case .about: store.send(.navigated(.about))
    case .exit: NSApplication.shared.terminate(nil)
    }
  }

  /// Returns true when the key was handled (suppresses the system beep).
  private func handle(keyDown event: NSEvent) -> Bool {
    let itemCount = MenuItem.allCases.count
    switch store.screen {
    case .main:
      switch event.keyCode {
      case 126: mainSelection = (mainSelection + itemCount - 1) % itemCount  // up
      case 125: mainSelection = (mainSelection + 1) % itemCount  // down
      case 36, 76: activate(MenuItem(rawValue: mainSelection) ?? .newGame)  // return
      default: return false
      }
      return true

    case .levelSelect:
      let count = store.levelNames.count
      guard count > 0 else {
        if event.keyCode == 53 { store.send(.navigated(.main)) }
        return event.keyCode == 53
      }
      let columns = max(1, min(4, count))
      switch event.keyCode {
      case 123: levelSelection = max(0, levelSelection - 1)  // left
      case 124: levelSelection = min(count - 1, levelSelection + 1)  // right
      case 126: levelSelection = max(0, levelSelection - columns)  // up
      case 125: levelSelection = min(count - 1, levelSelection + columns)  // down
      case 36, 76: store.send(.levelSelected(levelSelection))
      case 53: store.send(.navigated(.main))  // esc
      default: return false
      }
      return true

    case .options:
      switch event.keyCode {
      case 126, 125: optionsSelection = 1 - optionsSelection
      case 36, 76, 49:  // return or space toggles
        store.send(optionsSelection == 0 ? .soundToggled : .musicToggled)
      case 53: store.send(.navigated(.main))
      default: return false
      }
      return true

    case .about:
      switch event.keyCode {
      case 53, 36, 76: store.send(.navigated(.main))
      default: return false
      }
      return true
    }
  }
}
