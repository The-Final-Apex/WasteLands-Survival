# ws_fire

A clean-room, MIT-licensed fire system for Minetest.

## Features
- **Ignition**: start fires with API or the included `ws_fire:firestarter` tool.
- **Spread**: fire spreads to nearby flammable nodes, respecting protection.
- **Decay**: fires die out over time; faster under open sky (rain-friendly behavior).
- **Damage**: configurable damage per second when standing in fire.
- **Particles/Sound**: lightweight visuals and looping crackle (if sound exists).
- **API**: `ws_fire.start_fire(pos, opts)` and `ws_fire.can_burn(name)`.

## Settings (minetest.conf)
```
# Enable/disable global fire behavior
ws_fire.enable_spread = true
ws_fire.enable_decay  = true

# Timers (seconds)
ws_fire.tick_interval = 1.5
ws_fire.min_life_time = 6
ws_fire.max_life_time = 18

# Spread
ws_fire.spread_radius = 2     # how far to search for fuel
ws_fire.ignite_chance = 0.35  # chance per tick to ignite a candidate

# Decay/extinguish
ws_fire.sky_decay_bonus = 0.5 # multiplier applied if fire sees open sky (faster decay)

# Damage
ws_fire.damage_per_second = 3

# Particles
ws_fire.enable_particles = true
ws_fire.enable_sound = true
```

## Integration
- Respects node `groups.flammable` (>0 considered burnable).
- Won't spread in **protected** areas.
- If `ws_core` is present, uses its water/lava to auto-extinguish nearby fire.

## Media
- No textures or sounds included. Use your own or CC0 assets with names:
  - `ws_fire_fire.png` (animated or static)
  - `ws_fire_embers.png`
  - `ws_fire_smoke.png`
  - `ws_fire_fire.ogg` (crackle loop)

## API
```lua
-- Start a fire at `pos`. Returns true if placed.
-- opts: {force = false, lifetime = nil}
--  force: ignore protection (default false)
--  lifetime: override time-to-live
ws_fire.start_fire(pos, opts)

-- Returns true if node name can burn (based on groups.flammable)
ws_fire.can_burn(name)
```

## Tool
- `ws_fire:firestarter`: right-click a flammable node or ground to ignite.

## License
- **Code** MIT. No media included.
