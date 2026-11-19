# Code vs Errors — Prototype

A tiny Windows-first lane-defense prototype inspired by Plants vs. Zombies.

## Play it

1. Download **Godot 4.2+** for Windows.
2. Open this repository folder in Godot.
3. Press **F6** or click **Run Project**.

## Prototype controls

- Select **Compiler** for 50 cycles.
- Select **Firewall** for 75 cycles.
- Click a grid tile to place the selected defender.
- You earn 25 cycles every 5 seconds.
- Survive for 75 seconds to win.
- Bugs that reach the left side end the game.

## Export to Windows `.exe`

In Godot, use **Project > Export**, install the Windows export templates, create a Windows Desktop preset, and export.

> The prototype has no external art or sound assets. Everything is drawn in code.

## Roadmap

- Add real sprites and animations
- Add multiple bug types
- Add sun/cycle economy upgrades
- Add a main menu and level selection
- Add sound and music
- Balance progression and boss fights
