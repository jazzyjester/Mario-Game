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
  `BlockPipeUp` (`Int1` = PiranahType), `CoinBlock`, `ExitBlock` (Enter to finish), `MonsterGoomba`,
  `MonsterKoopa` (walk → shield → sliding shield), `MonsterPiranah`, `MushRed` (grow), `MushLife` (+1 life),
  `Flower` (fire), `FireBall`, `BlockBrickPiece` (break debris).
- Mario: Small/Big/Fire (16×16 small, 16×27 big/fire), damage downgrades one stage + blink (~20 anim ticks),
  dies when small-hit or falls below level bottom (+50px). 2 fireballs max in flight.
- Physics (C# constants): logic tick 50ms. Jump: parabola `pos = start + v0*t + 4.9*t²`,
  `v0 = -38` (stomp bounce `-20`), `t += 0.35` per tick; falling: `y += 6 + t` per tick.
  Run: `x ± (3 + XAdd)` per tick, `XAdd += 0.5` capped at 3; stop: sliding `x ± √XCount` decay from 5.
  Monsters walk 1px per tick, reverse on side collisions, fall at 2px/tick.
- Collision: AABB overlap, direction classified per corner-containment with W/H comparison
  (see `Level.Intersects` in `MarioObjects/Objects/BaseObjects/Level.cs`) — port it faithfully;
  gameplay (wall stops, landing, head-bump on question/brick) depends on its quirks.
- Camera: follows Mario, clamped at level edges (level 1024×464 px, viewport ~800×464);
  parallax background scrolls at 1/3 speed.
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
- [ ] `GameWorld` struct: entities instantiated from `LevelDocument`, fixed-tick `advance(input:)`
- [ ] Port collision detection (`Intersects` + direction logic) — unit tests with crafted rects
- [ ] Mario movement/jump/fall state machine with original constants — tests (jump apex, landing, wall stop)
- [ ] Camera/screen tracking + parallax offsets
- [ ] Blocks: solid/grass/ground collision, brick break, question block pop (item spawn), hidden block, moving block carry
- [ ] Items: coin, mushroom, life mush, flower; Mario grow/shrink/fire + blink invulnerability
- [ ] Monsters: Goomba (walk/stomp/fall-die), Koopa (shield states), Piranha (pipe emerge cycle)
- [ ] Fireballs (bounce, kill monsters), brick pieces
- [ ] Win (exit + Enter) / die (fall, small-hit) / lives / level progression events
- [ ] Engine test suite green — commit(s) per chunk

### Phase 3 — Playable game app
- [ ] TCA `GameFeature`: holds `GameWorld`, tick driven by clock effect, input actions
- [ ] SwiftUI `GameView`: `Canvas` renderer (sprites, camera, parallax bg, HUD: lives/coins), keyboard handling
- [ ] Sprite loading from bundle resources, sliced frames, nearest-neighbor
- [ ] `AudioPlayer` dependency (AVFoundation): sfx + looping level music
- [ ] `AppFeature` + menu screen (Play / Editor / level picker), death/game-over/level-complete flows
- [ ] Playable end-to-end on the 3 legacy levels via `swift run MarioApp` — commit
- [ ] README quickstart in `MarioSwift/`

### Phase 4 — Level editor
- [ ] TCA `EditorFeature`: document state, palette selection, place/erase on grid, drag-paint,
      object params sheet (question-block item, moving-block params, pipe piranha type), undo/redo
- [ ] Editor canvas: grid, zoom, scroll, hover preview, object sprites
- [ ] Open/Save legacy XML, "Play level" button → GameFeature
- [ ] New-level template, validation (exactly one Mario, at least one Exit)
- [ ] Commit

### Phase 5 — Polish
- [ ] App menus & shortcuts, window sizing, app icon
- [ ] Persist last level / best coins (UserDefaults or Sharing library)
- [ ] TCA reducer tests (TestStore) for the important flows
- [ ] CI-able script (`Scripts/ci.sh`: build + test), update root README
- [ ] Optional: package as .app bundle

### Phase 6 — Fidelity pass (optional)
- [ ] Side-by-side quirk checklist vs C# (koopa shield timings, hidden block one-way, pipe spawn timing…)
- [ ] Performance: only draw on-screen objects, sprite caching
- [ ] Music per level from LevelManager.xml

## Session log

- **2026-07-10 (session 1)**: Explored C# codebase, wrote this plan. Starting Phase 0.
