# ws_hunger (Wastelands: Survival)

Clean-room, MIT-licensed hunger/satiation system for **Wastelands: Survival**.

## Gameplay
- New attribute: **satiation** (0–30). New players start at **20**.
- **Exhaustion** from digging/placing/moving lowers satiation over time.
- **Passive drain**: every **800 s** you lose 1 satiation even if idle.
- **Starvation**: at **≤1** satiation you take periodic damage (non-lethal poison is separate).
- **Regen**: at **≥16** satiation you slowly regenerate HP.
- **Eating**: converts food values to **satiation**; food does *not* heal directly.
- **Poison**: optional food poisoning drains HP briefly but never kills (stops at 1 HP).

## HUD
- If **hudbars** is installed, shows a `Satiation` bar (id: `ws_satiation`).
- Otherwise a minimal HUD (text + bar) is used.

## API
```lua
-- Read/write
ws_hunger.get_satiation(player) -> int
ws_hunger.set_satiation(player, value) -> int
ws_hunger.add_satiation(player, delta) -> int     -- clamps 0..max

-- Eating wrapper (returns on_use function)
ws_hunger.eat(satiation_gain, {replace=nil, poison={time=5, dps=1}, sound="ws_hunger_eat"}) -> function

-- Poison programmatically (non-lethal)
ws_hunger.poison(player, time, dps)

-- Custom exhaustion injection
ws_hunger.add_exhaustion(player, name, amount)
ws_hunger.get_exhaustion(player) -> number
```

## Settings (minetest.conf)
```
ws_hunger.max = 30
ws_hunger.start = 20
ws_hunger.passive_interval = 800

ws_hunger.exhaust_threshold = 160
ws_hunger.cost_dig = 3
ws_hunger.cost_place = 1
ws_hunger.cost_move_tick = 0.3   # per movement poll
ws_hunger.use_hudbars = true

ws_hunger.regen_threshold = 16
ws_hunger.regen_interval = 4
ws_hunger.regen_amount = 1

ws_hunger.starve_threshold = 1
ws_hunger.starve_interval = 4
ws_hunger.starve_damage = 1
```
