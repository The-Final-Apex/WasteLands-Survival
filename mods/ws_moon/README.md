# WS Moon (MIT)

A fresh, MIT-licensed moon phases system for Minetest.

## Features
- **8-phase** lunar cycle; each phase lasts `ws_moon.cycle_days` in-game days.
- **Per-player style**: `classic` (pixel) or `realistic` (photo); players can switch via chat.
- **Sky integration**: prefers `climate_api` or `skylayer` if present; otherwise uses the native sky API.
- **Commands** (namespaced to avoid conflicts):
  - `/ws_moon` — show the current phase number (1..8)
  - `/ws_moon_set <1..8>` — admin-only: set the active phase
  - `/ws_moon_style <classic|realistic>` — set your personal texture style

## Textures
This mod does not bundle media. Place textures in a texture pack or in this mod's `textures/` folder:
```
ws_moon_1_classic.png .. ws_moon_8_classic.png
ws_moon_1_realistic.png .. ws_moon_8_realistic.png
```
You can use your own art or public-domain imagery compatible with your game.

## Settings (minetest.conf)
```
ws_moon.cycle_days = 4
ws_moon.style = classic
```
(For drop-in convenience, the mod will also read `moon_phases_cycle` and `moon_phases_style`
if the `ws_moon.*` settings are not defined, so you can re-use existing configs.)

## License
- **Code**: MIT
- **Media**: bring your own; supply any moon textures you wish.
