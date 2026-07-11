# 🎮 Mario Objects - Classic Mario Game & Level Editor 🎮

Welcome to **Mario Objects**! This is a Mario-inspired game and level editor that I created during my college days. It started as a small project to learn C# but grew into something much bigger as I added features and expanded my skills.

> **🚀 2026 update — native macOS rewrite in Swift!**
> The game and the level editor have been rewritten for macOS with Swift 6,
> SwiftUI, and the Composable Architecture, reusing the original sprites,
> sounds, levels, and physics. See [`MarioSwift/`](MarioSwift/) —
> `cd MarioSwift && swift run MarioApp`. Jump to [Swift Rewrite (2026)](#-swift-rewrite-2026)
> below for what's included, or [`REWRITE_PLAN.md`](REWRITE_PLAN.md) for the
> phased build log. The original C# projects below are kept unchanged as reference.

---

## 🖼️ Screenshots
![Level 1](https://github.com/jazzyjester/Mario-Objects/blob/master/mario_level_1.png)
![Level 2](https://github.com/jazzyjester/Mario-Objects/blob/master/mario_level_2.png)
![Level 3](https://github.com/jazzyjester/Mario-Objects/blob/master/mario_level_3.png)

---

## ✨ Introduction

**Mario Objects** is a tribute to the classic Mario games and my first project in C#. Initially, I set out to learn bitmap manipulation and surface handling, and Mario sprites seemed like the perfect practice material given my love for the game. 

Over time, I added more:
- **Objects** with distinct properties
- **Timers** for gameplay mechanics
- **Physics** for Mario’s movement
- **Interactions** between Mario and other objects

As a finishing touch, I built a level editor to design and play around with custom Mario-inspired levels. While it’s not perfect, it was a fun and fulfilling project, and I’m still proud of it!

---

## 🛠️ Project Structure

This solution was built in Visual Studio 2010 and contains the following projects:

- **MarioObjects** - The main game project.
- **MarioLevel Editor** - A level editor to design custom levels.
- **Mario Rectangle** - A simple test project.
- **Mario Test** - A unit test project for basic functionality.

---

## 🕹️ Swift Rewrite (2026)

[`MarioSwift/`](MarioSwift/) is a from-scratch native macOS port of both the
game and the level editor, built with Swift 6, SwiftUI, and the Composable
Architecture — reusing the original sprites, sounds, level XML files, and
physics constants. Full details in [`MarioSwift/README.md`](MarioSwift/README.md);
the phased build log is in [`REWRITE_PLAN.md`](REWRITE_PLAN.md).

- **Engine (`MarioKit`)** — deterministic 20Hz simulation ported object-for-object
  from the C# original, plus a legacy-compatible level XML codec. One deliberate
  behavior change: the old wall-climb bug is fixed.
- **Playable app** — title screen (with an EXIT option), level select with
  progress locks, 9 levels (the original 3 plus 6 new with a difficulty ramp),
  a level-intro splash on entry/advance, a top HUD bar (level/coins/lives),
  classic death sequence, sound/music options, about screen. Walking into the
  exit finishes the level — no key press needed.
- **Level editor** — palette + drag-paint, undo/redo, params inspector,
  eyedropper, open/save round-trips the legacy XML format, "Play Level" jumps
  straight into the game and back.
- **51 tests** across 11 suites, including a geometry runner-bot that proves
  every shipped level is completable.

```sh
cd MarioSwift
swift run MarioApp
```

---

## 🎨 Level Editor

The level editor lets you create custom levels by generating an XML file, which the game then loads to render your objects and designs.

- Objects are listed on the left panel for easy selection.
- Clicking an object opens a properties screen (if available).
  
> _Note:_ The UX is definitely "of its time," but it reflects my early approach to design!

![Level Editor](https://github.com/jazzyjester/Mario-Objects/blob/master/mario3.png)

---

## 📬 Contact

If you enjoy the game or have any questions, feel free to reach out!  
**Email:** jazzyjester@gmail.com

---

Thanks for stopping by, and happy gaming! 🎉
