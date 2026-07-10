# MarioSwift

Native macOS rewrite of the 2010 C# "Mario Objects" game + level editor:
Swift 6, SwiftUI, and the Composable Architecture. The simulation in
`MarioKit` is a faithful port of the original engine (same physics constants,
same collision quirks) and loads the original level XML files.

## Run

```sh
cd MarioSwift
swift run MarioApp
```

Controls: ← → move · ↑ or Z jump · space or X fireball · ⏎ enter the exit door ·
P pause · R restart level · esc back to menu.

## Test

```sh
Scripts/test.sh        # NOT bare `swift test` — see note
```

This machine setup (Command Line Tools without Xcode) needs explicit
Testing.framework search paths; the script adds them.

## Debug rendering headlessly

```sh
swift run MarioApp --screenshot /tmp/frame.png 40   # render lev1 after 40 ticks
```

## Layout

- `Sources/MarioKit` — pure model + engine: level XML codec, deterministic
  20Hz `GameWorld` simulation, no UI. See `REWRITE_PLAN.md` at the repo root.
- `Sources/MarioApp` — TCA features (`AppFeature`, `GameFeature`) + SwiftUI
  views (Canvas renderer, keyboard via NSEvent monitors) + AVFoundation audio.
- `Tests/MarioKitTests` — codec + engine behavior tests.
