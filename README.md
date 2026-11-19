# Code vs Errors — Prototype

A tiny Windows-first lane-defense prototype inspired by Plants vs. Zombies.

## Play the no-install browser version

Download [`Code-vs-Errors.html`](Code-vs-Errors.html) and double-click it to open it in a modern browser on Windows. It is a single self-contained file; no Godot or other game engine is needed.

## Play the Godot version

1. Download **Godot 4.2+** for Windows.
2. Open this repository folder in Godot.
3. Press **F6** or click **Run Project**.

## Prototype controls

- Select **Compiler** for 50 cycles.
- Select **Firewall** for 75 cycles.
- Click a grid tile to place the selected defender.
- Compilers automatically shoot bugs in their lane.
- Firewalls block bugs and absorb damage.
- You earn 25 cycles every 5 seconds.
- Survive for 75 seconds to win.
- Bugs that reach the left side end the game.
- Click after the end screen to restart.

## Export to Windows `.exe`

In Godot, use **Project > Export**, install the Windows export templates, create a Windows Desktop preset, and export. Players can run the exported `.exe` without installing Godot.

> Both prototypes use code-drawn graphics and do not need external art or sound assets.
