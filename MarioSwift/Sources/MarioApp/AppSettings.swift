import ComposableArchitecture

// Persisted app settings and progress (user defaults via Sharing).

extension SharedKey where Self == AppStorageKey<Int>.Default {
  /// How many bundled levels are playable; completing level N unlocks N+1.
  static var unlockedLevels: Self {
    Self[.appStorage("unlockedLevels"), default: 1]
  }
}

extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var soundEnabled: Self {
    Self[.appStorage("soundEnabled"), default: true]
  }

  static var musicEnabled: Self {
    Self[.appStorage("musicEnabled"), default: true]
  }
}
