import AppKit
import ComposableArchitecture
import MarioKit
import SwiftUI

struct EditorView: View {
  @Bindable var store: StoreOf<EditorFeature>

  var body: some View {
    HSplitView {
      palette
        .frame(minWidth: 180, maxWidth: 220)
      VStack(spacing: 0) {
        toolbar
        Divider()
        if !store.validationIssues.isEmpty {
          validationBanner
        }
        ScrollView([.horizontal, .vertical]) {
          EditorCanvas(store: store)
            .padding(12)
        }
        .background(Color(nsColor: .underPageBackgroundColor))
        Divider()
        statusBar
      }
      if paramsKind != nil {
        inspector
          .frame(minWidth: 200, maxWidth: 240)
      }
    }
  }

  private var paramsKind: ObjectKind? {
    if case .place(let kind) = store.tool, kind.hasParams { return kind }
    return nil
  }

  // MARK: Palette

  private var palette: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 6) {
        paletteButton(icon: "eraser", title: "Eraser", isSelected: store.tool == .erase) {
          store.send(.binding(.set(\.tool, .erase)))
        }
        ForEach(ObjectKind.paletteGroups, id: \.0) { group, kinds in
          Text(group)
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .padding(.top, 8)
          ForEach(kinds, id: \.self) { kind in
            paletteButton(
              thumbnail: EditorSprite.preview(for: kind),
              title: kind.displayName,
              isSelected: store.tool == .place(kind)
            ) {
              store.send(.binding(.set(\.tool, .place(kind))))
            }
          }
        }
      }
      .padding(10)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func paletteButton(
    icon: String? = nil,
    thumbnail: Image? = nil,
    title: String,
    isSelected: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        Group {
          if let thumbnail {
            thumbnail.resizable().scaledToFit()
          } else if let icon {
            SwiftUI.Image(systemName: icon)
          }
        }
        .frame(width: 22, height: 22)
        Text(title)
          .lineLimit(1)
        Spacer(minLength: 0)
      }
      .padding(.vertical, 3)
      .padding(.horizontal, 6)
      .background(
        isSelected ? Color.accentColor.opacity(0.25) : .clear,
        in: RoundedRectangle(cornerRadius: 5)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  // MARK: Toolbar

  private var toolbar: some View {
    HStack(spacing: 12) {
      Button("New", systemImage: "doc") { store.send(.newTapped) }
        .keyboardShortcut("n")
      Button("Open…", systemImage: "folder") { store.send(.openTapped) }
        .keyboardShortcut("o")
      Button("Save", systemImage: "square.and.arrow.down") { store.send(.saveTapped) }
        .keyboardShortcut("s")
      Button("Save As…") { store.send(.saveAsTapped) }
        .keyboardShortcut("s", modifiers: [.command, .shift])

      Divider().frame(height: 16)

      Button("Undo", systemImage: "arrow.uturn.backward") { store.send(.undoTapped) }
        .keyboardShortcut("z")
        .disabled(store.undoStack.isEmpty)
      Button("Redo", systemImage: "arrow.uturn.forward") { store.send(.redoTapped) }
        .keyboardShortcut("z", modifiers: [.command, .shift])
        .disabled(store.redoStack.isEmpty)

      Divider().frame(height: 16)

      Picker("Zoom", selection: $store.zoom) {
        Text("1×").tag(1.0)
        Text("1.5×").tag(1.5)
        Text("2×").tag(2.0)
        Text("3×").tag(3.0)
      }
      .pickerStyle(.segmented)
      .frame(width: 180)
      .labelsHidden()

      Spacer()

      Button {
        store.send(.playTapped)
      } label: {
        Label("Play Level", systemImage: "play.fill")
      }
      .keyboardShortcut("p")
      .disabled(!store.canPlay)

      Button("Back to Menu") { store.send(.backToMenuTapped) }
        .keyboardShortcut(.escape, modifiers: [])
    }
    .buttonStyle(.borderless)
    .labelStyle(.titleAndIcon)
    .padding(10)
  }

  private var validationBanner: some View {
    HStack {
      SwiftUI.Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(.yellow)
      Text(store.validationIssues.joined(separator: "  "))
      Spacer()
    }
    .font(.callout)
    .padding(8)
    .background(.yellow.opacity(0.15))
  }

  private var statusBar: some View {
    HStack(spacing: 12) {
      Text("\(store.fileName)\(store.isDirty ? " •" : "")")
      Text("\(store.document.objects.count) objects")
        .foregroundStyle(.secondary)
      if let cell = store.hoverCell {
        Text("(\(cell.x), \(cell.y))")
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      Spacer()
      if let message = store.statusMessage {
        Text(message).foregroundStyle(.secondary)
      }
      Text("⌃-click: pick object")
        .foregroundStyle(.tertiary)
    }
    .font(.caption)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
  }

  // MARK: Inspector

  @ViewBuilder
  private var inspector: some View {
    Form {
      switch paramsKind {
      case .blockQuestion, .blockQuestionHidden:
        Picker("Hidden item", selection: $store.params.questionItem) {
          Text("Coin").tag(QuestionBlockItem.coin)
          Text("Mushroom").tag(QuestionBlockItem.mushroom)
          Text("Fire Flower").tag(QuestionBlockItem.flower)
          Text("1-Up Mushroom").tag(QuestionBlockItem.lifeMushroom)
        }
        .pickerStyle(.radioGroup)

      case .blockMoving:
        Picker("Travel distance", selection: $store.params.movingDistance) {
          Text("Small (25px)").tag(25)
          Text("Medium (50px)").tag(50)
          Text("Big (75px)").tag(75)
          Text("Huge (100px)").tag(100)
        }
        Picker("Direction", selection: $store.params.movingAxisRaw) {
          Text("Up / Down").tag(0)
          Text("Right / Left").tag(1)
        }
        Toggle("Start reversed", isOn: $store.params.movingStartReversed)

      case .blockPipeUp:
        Picker("Piranha", selection: $store.params.piranha) {
          Text("None").tag(PiranhaKind.none)
          Text("Piranha").tag(PiranhaKind.fish)
          Text("Fire Piranha").tag(PiranhaKind.fire)
        }
        .pickerStyle(.radioGroup)

      default:
        EmptyView()
      }
    }
    .formStyle(.grouped)
  }
}

/// The editable level surface: grid + object sprites + hover preview.
struct EditorCanvas: View {
  @Bindable var store: StoreOf<EditorFeature>
  @State private var strokeInProgress = false

  var body: some View {
    let zoom = store.zoom
    let tile = 16.0 * zoom
    let size = CGSize(
      width: Double(LevelDocument.pixelWidth) * zoom,
      height: Double(LevelDocument.pixelHeight) * zoom
    )
    let commands = drawCommands(zoom: zoom)

    Canvas(opaque: true) { context, _ in
      // Sky backdrop.
      if let (bg, rect) = backgroundCommand(zoom: zoom) {
        context.draw(bg, in: rect)
      }
      // Objects.
      for (image, rect) in commands {
        context.draw(image, in: rect)
      }
      // Grid.
      var grid = Path()
      for column in 0...EditorFeature.gridWidth {
        grid.move(to: CGPoint(x: Double(column) * tile, y: 0))
        grid.addLine(to: CGPoint(x: Double(column) * tile, y: size.height))
      }
      for row in 0...EditorFeature.gridHeight {
        grid.move(to: CGPoint(x: 0, y: Double(row) * tile))
        grid.addLine(to: CGPoint(x: size.width, y: Double(row) * tile))
      }
      context.stroke(grid, with: .color(.black.opacity(0.12)), lineWidth: 0.5)

      // Hover highlight.
      if let cell = store.hoverCell {
        let rect = CGRect(
          x: Double(cell.x) * tile,
          y: (Double(EditorFeature.gridHeight - 1 - cell.y)) * tile + extraTopInset(zoom: zoom),
          width: tile, height: tile
        )
        context.stroke(Path(rect), with: .color(.white), lineWidth: 2)
        context.stroke(Path(rect.insetBy(dx: -1, dy: -1)), with: .color(.black.opacity(0.6)), lineWidth: 1)
      }
    }
    .frame(width: size.width, height: size.height)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { value in
          guard let cell = cell(at: value.location, zoom: zoom) else { return }
          if !strokeInProgress {
            strokeInProgress = true
            if NSEvent.modifierFlags.contains(.control) {
              store.send(.eyedropper(cell))
            } else {
              store.send(.strokeStarted(cell))
            }
          } else {
            store.send(.strokeMoved(cell))
          }
        }
        .onEnded { _ in
          strokeInProgress = false
          store.send(.strokeEnded)
        }
    )
    .onContinuousHover { phase in
      switch phase {
      case .active(let location):
        $store.hoverCell.wrappedValue = cell(at: location, zoom: zoom)
      case .ended:
        $store.hoverCell.wrappedValue = nil
      }
    }
  }

  /// The level is 464px tall = 29 rows exactly; no inset needed, kept for
  /// clarity of the row math.
  private func extraTopInset(zoom: Double) -> Double { 0 }

  private func cell(at location: CGPoint, zoom: Double) -> EditorFeature.State.Cell? {
    let tile = 16.0 * zoom
    let x = Int(location.x / tile)
    let rowFromTop = Int(location.y / tile)
    let y = EditorFeature.gridHeight - 1 - rowFromTop
    guard (0..<EditorFeature.gridWidth).contains(x), (0..<EditorFeature.gridHeight).contains(y)
    else { return nil }
    return EditorFeature.State.Cell(x: x, y: y)
  }

  private func backgroundCommand(zoom: Double) -> (Image, CGRect)? {
    guard
      let bg = SpriteStore.shared.frame(
        .background,
        source: IRect(x: 0, y: 0, width: SpriteSheet.background.size.width, height: SpriteSheet.background.size.height))
    else { return nil }
    return (
      bg,
      CGRect(
        x: 0, y: 0,
        width: Double(LevelDocument.pixelWidth) * zoom,
        height: Double(LevelDocument.pixelHeight) * zoom)
    )
  }

  private func drawCommands(zoom: Double) -> [(Image, CGRect)] {
    store.document.objects.compactMap { object in
      guard let sprite = EditorSprite.renderable(for: object) else { return nil }
      guard let image = SpriteStore.shared.frame(sprite.sheet, source: sprite.source) else { return nil }
      return (
        image,
        CGRect(
          x: Double(sprite.dest.x) * zoom,
          y: Double(sprite.dest.y) * zoom,
          width: Double(sprite.dest.width) * zoom,
          height: Double(sprite.dest.height) * zoom
        )
      )
    }
  }
}

/// Static preview sprites for level objects (no simulation involved).
enum EditorSprite {
  /// Preview frame indices from the legacy editor's `GetLEObject`.
  private static func frameInfo(for kind: ObjectKind) -> (sheet: SpriteSheet, frameIndex: Int, frameCount: Int) {
    switch kind {
    case .mario: (.marioSmall, 2, 6)
    case .blockGrass: (.grass, 1, 2)
    case .blockSolid: (.solidBlock, 0, 1)
    case .blockBrick: (.brick, 0, 4)
    case .blockQuestion: (.itemBlock, 0, 6)
    case .blockQuestionHidden: (.itemBlock, 5, 6)
    case .blockMoving: (.movingBlock, 0, 1)
    case .blockPipeUp: (.pipeUp, 0, 1)
    case .coin: (.coin, 0, 4)
    case .exit: (.exit, 0, 1)
    case .monsterGoomba: (.goomba, 1, 4)
    case .monsterKoopa: (.koopa, 2, 10)
    }
  }

  @MainActor
  static func preview(for kind: ObjectKind) -> Image? {
    let info = frameInfo(for: kind)
    let frameWidth = info.sheet.size.width / info.frameCount
    return SpriteStore.shared.frame(
      info.sheet,
      source: IRect(x: frameWidth * info.frameIndex, y: 0, width: frameWidth, height: info.sheet.size.height))
  }

  /// Sprite + level-pixel rect for an object, bottom-anchored in its cell
  /// (taller-than-a-tile sprites extend upward, like in the game).
  static func renderable(for object: LevelObject) -> (sheet: SpriteSheet, source: IRect, dest: IRect)? {
    let info = frameInfo(for: object.kind)
    let frameWidth = info.sheet.size.width / info.frameCount
    let frameHeight = info.sheet.size.height
    let pixelX = object.x * LevelDocument.tileSize
    let bottom = LevelDocument.pixelHeight - object.y * LevelDocument.tileSize
    return (
      sheet: info.sheet,
      source: IRect(x: frameWidth * info.frameIndex, y: 0, width: frameWidth, height: frameHeight),
      dest: IRect(x: pixelX, y: bottom - frameHeight, width: frameWidth, height: frameHeight)
    )
  }
}
