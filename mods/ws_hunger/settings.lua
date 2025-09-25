local S = minetest.settings

ws_hunger = rawget(_G, "ws_hunger") or {}

ws_hunger.cfg = {
  max = tonumber(S:get("ws_hunger.max")) or 30,
  start = tonumber(S:get("ws_hunger.start")) or 20,
  passive_interval = tonumber(S:get("ws_hunger.passive_interval")) or 800,

  exhaust_threshold = tonumber(S:get("ws_hunger.exhaust_threshold")) or 160,
  cost_dig = tonumber(S:get("ws_hunger.cost_dig")) or 3,
  cost_place = tonumber(S:get("ws_hunger.cost_place")) or 1,
  cost_move_tick = tonumber(S:get("ws_hunger.cost_move_tick")) or 0.3,

  regen_threshold = tonumber(S:get("ws_hunger.regen_threshold")) or 16,
  regen_interval = tonumber(S:get("ws_hunger.regen_interval")) or 4,
  regen_amount = tonumber(S:get("ws_hunger.regen_amount")) or 1,

  starve_threshold = tonumber(S:get("ws_hunger.starve_threshold")) or 1,
  starve_interval = tonumber(S:get("ws_hunger.starve_interval")) or 4,
  starve_damage = tonumber(S:get("ws_hunger.starve_damage")) or 1,

  use_hudbars = (S:get_bool("ws_hunger.use_hudbars", true) ~= false),
}

-- Runtime tables
ws_hunger._satiation = {}
ws_hunger._exhaust = {}
ws_hunger._poison = {}
