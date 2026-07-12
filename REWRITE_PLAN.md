# Mario Swift Rewrite — Master Plan

Rewrite of the 2010 C# WinForms Mario game + level editor as a native macOS app in
Swift / SwiftUI / Composable Architecture (TCA). This file is the cross-session
source of truth: **each session, read this file first, do the next unchecked work,
check items off, add session notes at the bottom, and commit.**

## Ground rules

- New code lives in `MarioSwift/` (SwiftPM package). Old C# code stays untouched as reference.
- Toolchain: Swift 6.3 **CLI only — no full Xcode on this machine**. Everything must work with
  `swift build` / `swift run` / `swift test` from `MarioSwift/`. Tests use Swift Testing (`@Test`), not XCTest.
- Git: work on branch `swift-rewrite`, commit after each meaningful step, message prefix `swift:`.
- Level format: stay **compatible with the legacy XML** (`OName`/`X`/`Y`/`Int1..3`/`Bool1..3`)
  so the 3 shipped levels and old editor files load. Grid: 16px tiles, Y counted from the bottom in files.
- Architecture split:
  - `MarioKit` (library target): pure model + engine. No SwiftUI. Deterministic, fully testable:
    level model, XML codec, game simulation (tick-based), collision, entity behaviors.
  - `MarioApp` (executable target): TCA features + SwiftUI views + Canvas renderer + AVFoundation audio.
  - TCA features: `AppFeature` (root, switches Menu / Game / Editor), `GameFeature`, `EditorFeature`.
- Rendering: SwiftUI `TimelineView(.animation)` + `Canvas`, drawing sprite sheets copied from the
  C# project into package resources. Nearest-neighbor scaling, integer zoom.
- Input: keyboard (arrows = move/jump, X or Ctrl = fireball, Enter = enter exit) via `.onKeyPress` / NSEvent fallback.
- Engine timing: fixed 20 Hz logic tick (matches C# 50ms timer) with animation subticks
  (C# used 100/200/500ms timers → every 2/4/10 logic ticks). Keep the original physics constants
  (see reference below) so the game *feels* identical.

## Legacy mechanics reference (from C# code)

- Object catalog (XML `OName` → behavior): `Mario`, `BlockGrass`, `BlockGround1`, `BlockSolid`,
  `BlockBrick` (breakable when big/fire), `BlockQuestion` (+`Int1` = hidden item ObjectType),
  `BlockQuestionHidden` (invisible until hit), `BlockMoving` (`Int1`=range, `Int2`=MovingType h/v, `Bool1`),
  `BlockPipeUp` (`Int1` = PiranahType), `CoinBlock`, `ExitBlock` (legacy: Enter to finish; Swift
  rewrite deviation: touching it finishes the level immediately, no key needed), `MonsterGoomba`,
  `MonsterKoopa` (walk → shield → sliding shield), `MonsterPiranah`, `MushRed` (grow), `MushLife` (+1 life),
  `Flower` (fire), `FireBall`, `BlockBrickPiece` (break debris).
- Mario: Small/Big/Fire (16×16 small, 16×27 big/fire), damage downgrades one stage + blink (~20 anim ticks),
  dies when small-hit or falls below level bottom (+50px). 2 fireballs max in flight.
- Physics (C# constants): logic tick 50ms. Jump: parabola `pos = start + v0*t + 4.9*t²`,
  `v0 = -38` (stomp bounce `-20`), `t += 0.35` per tick; falling: `y += 6 + t` per tick.
  Run: `x ± (3 + XAdd)` per tick, `XAdd += 0.5` capped at 3; stop: sliding `x ± √XCount` decay from 5.
  Monsters walk 1px per tick, reverse on side collisions, fall at 2px/tick.
- Swift rewrite deviation (physics): a *held* jump still plays out this exact parabola/fall
  bit-for-bit — the generated levels' pit widths and wall heights are tuned against this precise
  arc, so it's kept byte-identical rather than "improved" wholesale. Layered on top, as pure
  additions that never change a held jump's shape: variable jump height (releasing early cuts the
  rise short and switches straight to the fall step — the legacy engine always played the full
  arc regardless of input), coyote time (~5 ticks of post-ledge jump grace; the legacy engine
  disabled jumping the instant a ledge was left), jump buffering (~5 ticks, a press shortly before
  landing fires on touchdown), and a terminal-velocity cap (11px/tick) on the otherwise-unbounded
  `6 + t` fall step for long falls. See `Mario.swift`'s `Physics` enum and `onJumpTick`/`startJump`.
- Collision: AABB overlap, direction classified per corner-containment with W/H comparison
  (see `Level.Intersects` in `MarioObjects/Objects/BaseObjects/Level.cs`) — port it faithfully;
  gameplay (wall stops, landing, head-bump on question/brick) depends on its quirks.
- Camera: follows Mario, clamped at level edges (level 1024×464 px, viewport ~800×464);
  parallax background scrolls at 1/3 speed.
- Swift rewrite deviation (parallax): the legacy pipeline derived the background scroll from the
  delta between two independently-clamped camera trackers (a 320×240 "output" viewport and a
  400×304 "background" viewport). Away from level edges the two moved in lockstep and the delta
  was a harmless constant, but they clamped against the level bounds at different points (being
  different sizes), so in the band between those two clamp points — which sits right around
  spawn — the delta spiked instead of staying constant, a visible scroll-speed glitch. The Swift
  version drops the second tracker and scrolls the background directly off the one real camera
  (`screen.x / 3`, `screen.y / 3`, clamped to the background sheet's own bounds).
- Levels: `MarioObjects/bin/Debug/lev1.xml`, `Level2.xml`, `Level3.xml` (+ `LevelManager.xml` = level list,
  lives carried across levels, start lives = 3).
- Sounds: jump, coin, stomp, mush, brick, block, fireball (wav) + level1/level2 music (mp3).
- Sprites: `MarioObjects/Images/**` sprite sheets laid out horizontally, frame width = image height
  (frames = width/height). Mario sheets: 6 frames (0,1 walk-left, 2,3 walk-right, 4 jump-left, 5 jump-right).

## Phases

### Phase 0 — Foundation
- [x] Explore legacy code, write this plan
- [x] Branch `swift-rewrite`, git identity set, commit plan
- [x] Scaffold `MarioSwift` SwiftPM package: `MarioKit` lib + `MarioApp` exe + test target, TCA dependency
- [x] Copy assets into package resources (Images, Sounds, Levels incl. LevelManager.xml)
- [x] `swift build` + `swift test` green — commit
  - **NOTE**: run tests with `MarioSwift/Scripts/test.sh` — plain `swift test` fails on this machine
    (CLT-only; the script adds the CLT's Testing.framework search paths + rpaths).

### Phase 1 — Level model & legacy XML codec
- [x] `ObjectKind` enum (all legacy ONames), `LevelObject` (kind, gridX, gridY, ints, bools), `LevelDocument`
- [x] Legacy XML decode + encode (round-trip compatible so the old game could still load saved files)
- [x] Load all 3 shipped levels in tests (lev1=254, Level2=70, Level3=44 objects; 1 Mario + ≥1 Exit each)
- [x] `LevelCatalog` (parse LevelManager.xml)
- [x] Commit

### Phase 2 — Game engine (pure MarioKit)
- [x] `GameWorld` (class, deterministic): entities from `LevelDocument`, fixed-tick `advance(input:)` @ 20Hz,
      timer-slot handlers (t50/t100/t200/t500) registered in legacy creation order, `drainEvents()` for
      sounds/died/completed, `renderables()` for the renderer (draw order = legacy object order)
- [x] Collision port (`classifyCollision`) — unit tests with crafted rects
- [x] Mario movement/jump/fall with original constants — tests (jump apex ~73px, landing, wall stop, slide)
- [x] Camera/screen tracking (`ScreenState`: 400×304 background + 320×240 output viewports)
- [x] Blocks: solid/grass, brick break + flying pieces, question block pop + hidden, moving block carry, pipes
- [x] Items: coin (incl. in-block pop), mushroom, life mush (emits `.extraLife`), flower, blink invulnerability
- [x] Monsters: Goomba, Koopa (walk/shield/returning/shieldMoving), Piranha (pipe cycle + aimed fireball)
- [x] Fireballs (bounce on grass/question/brick, die on solid/pipe — legacy), win/die events
- [x] 32 tests green — committed
- Engine quirks preserved on purpose: walkers only recognize grass/question tops as ground (jitter on solid),
  fireballs eaten by solid blocks, Mario always spawns bottom-left x=20 (XML Mario pos ignored, like the game).
  (Session 3 deviation: touching the exit finishes the level immediately — the legacy "Enter is
  sticky until an exit is touched" requirement was removed; see Phase 5b/session log.)
- **Deliberate deviation from C# (session 2)**: the wall-climb bug is FIXED. Mario resolves
  overlaps per axis right after each movement step (see `resolveHorizontalOverlap` /
  `resolveVerticalOverlap` in Mario.swift); the legacy classifier then only sees flush
  contacts, so its misclassifications (side-entry read as "landed on top") can't happen.
  Hidden question blocks stay penetrable (excluded via `visible`).

### Phase 3 — Playable game app
- [x] TCA `GameFeature`: `GameSession` box (identity+tick Equatable) holds `GameWorld`, 50ms clock timer
      effect sends `.tick`, held-key set + fire/enter edge flags → `GameInput`
- [x] SwiftUI `GameView`: Canvas renderer (draw commands resolved outside the canvas closure —
      SpriteStore is MainActor), parallax bg, text HUD, pause/game-over/won overlays
- [x] `SpriteStore` (CGImage crops cached per source rect, `.interpolation(.none)`)
- [x] `AudioPlayerClient` @DependencyClient (AVFoundation actor: effect players + looping music)
- [x] `AppFeature` (menu ↔ game via @Presents/ifLet), menu with level picker; death reloads level
      (lives−1), game over at 0 lives, next level on completion, won overlay after last level
- [x] Verified: renders lev1 correctly (offscreen screenshots at tick 0/40 — camera, parallax,
      sprites, koopa/goombas all correct); app runs via `swift run MarioApp`
- [x] README quickstart in `MarioSwift/`
- [x] Debug tool: `swift run MarioApp --screenshot out.png [ticks]` renders a frame headlessly
- Note: GameFeature/AppFeature delegate cases already support `launchedFromEditor`/`customLevel`
  for Phase 4's "Play level" button.

### Phase 4 — Level editor
- [x] TCA `EditorFeature`: document, palette tool (place kind / eraser), drag-paint strokes with
      one undo snapshot per stroke, undo/redo stacks, params inspector (question item, moving
      platform distance/axis/reversed, pipe piranha), ⌃-click eyedropper absorbs params
- [x] `EditorCanvas`: full 1024×464 level, zoom 1–3×, scroll, grid, hover highlight, sprite previews
      (legacy editor frame indices, incl. green hidden-? preview) — verified via `--editor-screenshot`
- [x] Open/Save/Save As via `FileDialogClient` dependency (NSOpen/NSSavePanel), legacy XML round-trip
- [x] "Play Level" → GameFeature with `customLevel`/`launchedFromEditor` (Back to Editor keeps editor state)
- [x] New-level template (grass floor + Mario + exit), validation banner (one Mario, ≥1 exit) gates Play
- [x] Menu "LEVEL EDITOR" button (⌘E); editor shortcuts ⌘N/⌘O/⌘S/⇧⌘S/⌘Z/⇧⌘Z/⌘P/esc
- [x] Commit

### Phase 5b — "Complete game" pass (2026-07-10, session 2)
- [x] **Wall-climb bug fixed** (years-old legacy bug, deliberate deviation from C#):
      axis-separated overlap resolution in Mario (vertical after the jump/fall step,
      horizontal after the run/slide step) so the legacy corner classifier only sees
      flush contacts; also fixes landing stutter at tile seams. Regression test:
      `cannotClimbWallByJumpingAgainstIt`.
- [x] Classic death sequence: engine `marioDying` phase (leap + fall through floor,
      world frozen, 50 ticks), synthesized `death.wav` jingle, black "MARIO × N"
      fade interstitial, then reload; 5 start lives.
- [x] Title screen (sprite diorama, keyboard menu): NEW GAME / LEVEL SELECT /
      LEVEL EDITOR / OPTIONS / ABOUT.
- [x] Level select with locks; progress persisted via `@Shared(.appStorage)`
      (`unlockedLevels`, completing bundled level N unlocks N+1).
- [x] Options: sound + music toggles, persisted, split AudioPlayerClient.
- [x] About screen (C# 2010 origin + Claude Code rewrite credit).
- [x] Levels 4–8 generated (`MarioSwift/Scripts/make_levels.py`, design rules in
      the script) with rising difficulty; LevelManager.xml lists 8 levels; music
      alternates per level. Geometry proven completable by a runner bot test
      (`LevelGeometryTests`; Level2 exempt — moving-platform void).
- [x] Renderer review: engine-side culling (`renderables(visibleIn:)`), background
      drawn as full sheet behind the clip (the old per-scroll crop grew the sprite
      cache without bound). Pixel-identical output verified.
- New debug flag: `--menu-screenshot out.png [main|levels|options|about]`;
  `--screenshot` takes an optional level name.

### Phase 5 — Polish
- [x] TCA reducer tests (TestStore): GameFeature death→reload/lives, game-over→backToMenu delegate,
      custom-level won→backToEditor, bundled level progression, pause (exhaustive); EditorFeature
      place/undo/redo (exhaustive), eyedropper, validation gating, play delegate, save round-trip;
      AppFeature navigation (menu↔editor, play-from-editor keeps editor state). 45 tests total.
- [x] `Scripts/ci.sh` (build + test), root README "Swift rewrite" banner
- [ ] Native menu bar & shortcuts (Game/File menus via SwiftUI `.commands`), window sizing polish, app icon
- [ ] Persist last level / sound toggle (@Shared(.appStorage) from Sharing, already a transitive dep)
- [ ] Optional: package as .app bundle (script: build release, make Contents/MacOS layout, Info.plist, icns from MarioIcon.ico)

**Note for the Delegate enums**: they're `@CasePathable` so tests can `store.receive(\.delegate.backToMenu)`.

### Phase 5c — Ronny's feature requests (2026-07-11, session 3)
- [x] Level-intro splash ("LEVEL N", 1.5s): shows on `.task` (new game / level select /
      editor play) and when advancing to the next level; NOT shown on a same-level death
      respawn (that keeps the existing "lives" interstitial instead). `GameFeature.State.Overlay.intro(String)`.
- [x] Top HUD bar restyled as a solid-background bar (was transparent overlay text):
      level name (`levelDisplayName`, "LEVEL N") · coin icon + count · Mario icon + lives.
- [x] Menu: EXIT option (`NSApplication.shared.terminate(nil)`).
- [x] **Deliberate deviation from C#**: touching the exit finishes the level immediately —
      the Enter-key requirement (and all its plumbing: `GameInput.enter`, `Mario.enterPressed`,
      `GameFeature.pendingEnter`/`.enterPressed`) was removed outright, not just bypassed.
- [x] Level9.xml ("Grassy Overworld"), a classic-World-1-1-flavored level: opening
      question/brick cluster, a quiet pipe then a piranha pipe, one pit crossing, a small
      hill climb, exit near the right edge. Generated via `make_levels.py`; LevelManager.xml
      now lists 9 levels.
- [x] 51 tests green (geometry + smoke tests now cover 8/9 and 9/9 levels respectively).

### Phase 6 — Fidelity pass (optional)
- [ ] Side-by-side quirk checklist vs C# (koopa shield timings, hidden block one-way, pipe spawn timing…)
- [ ] Performance: only draw on-screen objects, sprite caching
- [ ] Music per level from LevelManager.xml

## Session log

- **2026-07-10 (session 1)**: Explored C# codebase, wrote this plan. **Phases 0–4 done, Phase 5 mostly done.**
  - Phases 0–2: package scaffold + assets + legacy XML codec + full engine port (faithful OO port,
    class-based `GameWorld`, `GameSession` wraps it for TCA with identity+tick equality).
  - Phase 3: playable app — AppFeature/GameFeature, Canvas renderer (verified by screenshots),
    AVFoundation audio, keyboard via NSEvent monitors, lives/game-over/progression flows.
  - Phase 4: level editor — palette/drag-paint/undo/params inspector/eyedropper, open/save legacy XML,
    Play Level round-trip, validation. Canvas verified via `--editor-screenshot`.
  - Phase 5: 45 tests green (incl. TestStore reducer tests), `Scripts/ci.sh`, README updates.
  - **Run tests with `MarioSwift/Scripts/test.sh`, never bare `swift test`** (CLT-only machine).
  - Debug renders: `swift run MarioApp --screenshot f.png [ticks]` / `--editor-screenshot e.png`.
  - **Next session**: finish Phase 5 leftovers (menu bar `.commands`, @Shared(.appStorage) persistence,
    app icon / .app bundle script), then Phase 6 fidelity/perf pass. Also worth: manual playthrough
    feedback from Ronny (jump feel, koopa shield timing) → tune against C# constants in Mario.swift.

- **2026-07-10 (session 2)**: "Complete game" pass — see Phase 5b above. 51 tests green.
  Fixed the legacy wall-climb bug (+ collision hardening), classic death sequence with
  jingle + lives interstitial, real title screen with level select (locks, persisted
  progress), options (sound/music, persisted), about screen, five generated levels
  (4–8, runner-bot-verified geometry), renderer culling + bounded sprite cache.
  - **Next session**: Phase 5 leftovers (native menu bar `.commands`, app icon /
    .app bundle script), Phase 6 fidelity checklist, and Ronny's playthrough feedback
    on the new levels' difficulty.

- **2026-07-11 (session 3)**: Ronny's 6 feature requests — see Phase 5c above. 51 tests
  green. Level-intro splash overlay (entry + next-level advance, not death respawn),
  HUD restyled into a solid top bar, EXIT menu item, Level9.xml (classic-flavored, 9
  levels total), and the exit mechanic changed from "walk in + press Enter" to
  "just walk in" — the enter-key plumbing was deleted outright rather than left dead.
  Could not visually verify the splash/HUD SwiftUI rendering in this environment (no
  Xcode, and the existing `--screenshot` debug tool only renders `GameCanvas`, not the
  full `GameView` with its overlays) — worth a manual playthrough next session.
  - **Next session**: Phase 5 leftovers still open (native menu bar `.commands`, app
    icon / .app bundle script), Phase 6 fidelity checklist, and Ronny's visual/feel
    feedback on the splash timing (1.5s) and the new Level9.
