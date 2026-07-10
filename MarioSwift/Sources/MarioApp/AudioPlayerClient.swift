import AVFoundation
import Dependencies
import DependenciesMacros
import MarioKit

@DependencyClient
struct AudioPlayerClient {
  var playEffect: @Sendable (SoundEffect) async -> Void
  var playMusic: @Sendable (_ fileName: String) async -> Void
  var stopMusic: @Sendable () async -> Void
  var setSoundEnabled: @Sendable (Bool) async -> Void
  var setMusicEnabled: @Sendable (Bool) async -> Void
}

extension AudioPlayerClient: DependencyKey {
  static let liveValue: AudioPlayerClient = {
    let engine = AudioEngine()
    return AudioPlayerClient(
      playEffect: { await engine.play($0) },
      playMusic: { await engine.playMusic($0) },
      stopMusic: { await engine.stopMusic() },
      setSoundEnabled: { await engine.setSoundEnabled($0) },
      setMusicEnabled: { await engine.setMusicEnabled($0) }
    )
  }()

  static let testValue = AudioPlayerClient(
    playEffect: { _ in },
    playMusic: { _ in },
    stopMusic: {},
    setSoundEnabled: { _ in },
    setMusicEnabled: { _ in }
  )
}

extension DependencyValues {
  var audioPlayer: AudioPlayerClient {
    get { self[AudioPlayerClient.self] }
    set { self[AudioPlayerClient.self] = newValue }
  }
}

private actor AudioEngine {
  private var effectPlayers: [SoundEffect: AVAudioPlayer] = [:]
  private var musicPlayer: AVAudioPlayer?
  private var soundEnabled = true
  private var musicEnabled = true

  func setSoundEnabled(_ enabled: Bool) {
    soundEnabled = enabled
  }

  func setMusicEnabled(_ enabled: Bool) {
    musicEnabled = enabled
    if !enabled {
      musicPlayer?.pause()
    } else {
      musicPlayer?.play()
    }
  }

  func play(_ effect: SoundEffect) {
    guard soundEnabled else { return }
    let player: AVAudioPlayer
    if let cached = effectPlayers[effect] {
      player = cached
    } else {
      guard
        let url = BundledAssets.soundURL(effect.rawValue),
        let fresh = try? AVAudioPlayer(contentsOf: url)
      else { return }
      fresh.volume = 0.15  // legacy effect volume
      effectPlayers[effect] = fresh
      player = fresh
    }
    player.currentTime = 0
    player.play()
  }

  func playMusic(_ fileName: String) {
    musicPlayer?.stop()
    guard
      let url = BundledAssets.soundURL(fileName),
      let player = try? AVAudioPlayer(contentsOf: url)
    else { return }
    player.numberOfLoops = -1
    player.volume = 1
    musicPlayer = player
    if musicEnabled {
      player.play()
    }
  }

  func stopMusic() {
    musicPlayer?.stop()
    musicPlayer = nil
  }
}
