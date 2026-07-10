# MarioSwift

Native macOS rewrite of the 2010 C# "Mario Objects" game + level editor:
Swift 6, SwiftUI, and the Composable Architecture. The simulation in
`MarioKit` is a faithful port of the original engine (same physics constants,
same collision behavior — minus the old wall-climb bug, fixed on purpose)
and loads the original level XML files.

8 levels (3 original + 5 new with rising difficulty), level select with
progress locks, classic death sequence, sound/music options — all progress
and settings persist between launches.

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
swift run MarioApp --screenshot /tmp/frame.png 40             # lev1 after 40 ticks
swift run MarioApp --screenshot /tmp/f.png 100 Level5.xml     # any bundled level
swift run MarioApp --menu-screenshot /tmp/m.png levels        # main|levels|options|about
swift run MarioApp --editor-screenshot /tmp/e.png
```

## Levels

`Scripts/make_levels.py` regenerates the five 2026 levels (Level4–Level8)
from code; the design rules that keep them beatable are documented in the
script. The geometry of every level is proven completable by a runner bot
in `LevelGeometryTests`.

## Layout

- `Sources/MarioKit` — pure model + engine: level XML codec, deterministic
  20Hz `GameWorld` simulation, no UI. See `REWRITE_PLAN.md` at the repo root.
- `Sources/MarioApp` — TCA features (`AppFeature`, `GameFeature`) + SwiftUI
  views (Canvas renderer, keyboard via NSEvent monitors) + AVFoundation audio.
- `Tests/MarioKitTests` — codec + engine behavior tests.
