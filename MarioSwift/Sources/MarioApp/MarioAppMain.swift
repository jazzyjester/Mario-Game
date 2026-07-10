import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct MarioAppMain: App {
  @MainActor
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  init() {
    // Headless render check: `swift run MarioApp --screenshot out.png [ticks]`
    // draws one game frame offscreen and exits. Used to verify the renderer
    // without a display/interaction.
    if let flagIndex = CommandLine.arguments.firstIndex(of: "--screenshot"),
      CommandLine.arguments.count > flagIndex + 1
    {
      let path = CommandLine.arguments[flagIndex + 1]
      let ticks = CommandLine.arguments.count > flagIndex + 2
        ? Int(CommandLine.arguments[flagIndex + 2]) ?? 0 : 0
      MainActor.assumeIsolated {
        renderGameScreenshot(to: path, ticks: ticks)
      }
      exit(0)
    }

    // Running as a bare SwiftPM executable: promote to a regular app so the
    // window comes to front and receives key events.
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate()
  }

  var body: some Scene {
    WindowGroup("Mario") {
      AppView(store: Self.store)
        .frame(minWidth: 800, minHeight: 600)
    }
  }
}

struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    if let gameStore = store.scope(state: \.game, action: \.game.presented) {
      GameView(store: gameStore)
    } else {
      MenuView(store: store)
    }
  }
}
