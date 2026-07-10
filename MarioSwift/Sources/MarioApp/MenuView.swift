import ComposableArchitecture
import MarioKit
import SwiftUI

struct MenuView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 4) {
        Text("MARIO OBJECTS")
          .font(.system(size: 42, weight: .heavy, design: .monospaced))
        Text("2010 C# original, reborn in Swift")
          .font(.system(size: 13, design: .monospaced))
          .foregroundStyle(.secondary)
      }

      if store.levelNames.isEmpty {
        Text("No levels found")
          .foregroundStyle(.red)
      } else {
        Picker("Level", selection: $store.selectedLevelIndex) {
          ForEach(Array(store.levelNames.enumerated()), id: \.offset) { index, name in
            Text("Level \(index + 1)  (\(name))").tag(index)
          }
        }
        .pickerStyle(.radioGroup)
        .labelsHidden()
      }

      Button {
        store.send(.playTapped)
      } label: {
        Text("PLAY")
          .font(.system(size: 20, weight: .heavy, design: .monospaced))
          .padding(.horizontal, 24)
          .padding(.vertical, 4)
      }
      .buttonStyle(.borderedProminent)
      .keyboardShortcut(.defaultAction)
      .disabled(store.levelNames.isEmpty)

      Text("← → move · ↑/Z jump · space/X fireball · ⏎ enter exit\nP pause · R restart · esc menu")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(48)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
