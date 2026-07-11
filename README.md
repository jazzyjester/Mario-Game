# 🎮 Mario Objects - Classic Mario Game & Level Editor 🎮

Welcome to **Mario Objects**! This is a Mario-inspired game and level editor that I created during my college days. It started as a small project to learn C# but grew into something much bigger as I added features and expanded my skills.

> **🚀 2026 update — native macOS rewrite in Swift!**
> The game and the level editor have been rewritten for macOS with Swift 6,
> SwiftUI, and the Composable Architecture, reusing the original sprites,
> sounds, levels, and physics. See [`MarioSwift/`](MarioSwift/) —
> `cd MarioSwift && swift run MarioApp`. The rewrite plan and progress live
> in [`REWRITE_PLAN.md`](REWRITE_PLAN.md). The original C# projects below are
> kept unchanged as reference.

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
