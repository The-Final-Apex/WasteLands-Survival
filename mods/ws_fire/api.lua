-- ws_fire/api.lua
ws_fire = rawget(_G, "ws_fire") or {}

local S = minetest.get_translator and minetest.get_translator("ws_fire") or function(s) return s end
local settings = minetest.settings

local ENABLE_SPREAD      = settings:get_bool("ws_fire.enable_spread", true)
local ENABLE_DECAY       = settings:get_bool("ws_fire.enable_decay", true)
local TICK_INTERVAL      = tonumber(settings:get("ws_fire.tick_interval")) or 1.5
local MIN_LIFE_TIME      = tonumber(settings:get("ws_fire.min_life_time")) or 6
local MAX_LIFE_TIME      = tonumber(settings:get("ws_fire.max_life_time")) or 18
local SPREAD_RADIUS      = tonumber(settings:get("ws_fire.spread_radius")) or 2
local IGNITE_CHANCE      = tonumber(settings:get("ws_fire.ignite_chance")) or 0.35
local SKY_DECAY_BONUS    = tonumber(settings:get("ws_fire.sky_decay_bonus")) or 0.5
local DPS                = tonumber(settings:get("ws_fire.damage_per_second")) or 3
local ENABLE_PARTICLES   = settings:get_bool("ws_fire.enable_particles", true)
local ENABLE_SOUND       = settings:get_bool("ws_fire.enable_sound", true)

ws_fire.cfg = {
  enable_spread    = ENABLE_SPREAD,
  enable_decay     = ENABLE_DECAY,
  tick_interval    = TICK_INTERVAL,
  min_life_time    = MIN_LIFE_TIME,
  max_life_time    = MAX_LIFE_TIME,
  spread_radius    = SPREAD_RADIUS,
  ignite_chance    = IGNITE_CHANCE,
  sky_decay_bonus  = SKY_DECAY_BONUS,
  damage_per_second= DPS,
  enable_particles = ENABLE_PARTICLES,
  enable_sound     = ENABLE_SOUND,
}

-- Utility: is this node burnable based on groups?
function ws_fire.can_burn(name)
  local def = minetest.registered_nodes[name]
  if not def or def.groups == nil then return false end
  local fl = def.groups.flammable or 0
  return fl > 0
end

-- Utility: attempt to place fire node
local function place_fire_at(pos, lifetime)
  local node = minetest.get_node_or_nil(pos)
  if not node then return false end
  local def = minetest.registered_nodes[node.name]
  if not def then return false end

  if def.name == "air" or (def and def.buildable_to) then
    minetest.set_node(pos, {name = "ws_fire:fire"})
    local timer = minetest.get_node_timer(pos)
    timer:start(ws_fire.cfg.tick_interval)
    -- store lifetime in meta
    local meta = minetest.get_meta(pos)
    meta:set_float("ws_fire_life", lifetime)
    return true
  end
  return false
end

-- Ray test to sky: simple check to see if vertical column is clear to 'ignore'
local function sees_open_sky(pos)
  local max_y = 31000
  local p = {x = pos.x, y = pos.y + 1, z = pos.z}
  for y = p.y, max_y do
    local n = minetest.get_node({x=pos.x, y=y, z=pos.z})
    if n.name == "ignore" then
      return true
    end
    local def = minetest.registered_nodes[n.name]
    if not def or not def.buildable_to then
      return false
    end
  end
  return true
end

-- Public: start fire
function ws_fire.start_fire(pos, opts)
  opts = opts or {}
  local pname = (opts.player and opts.player:is_player()) and opts.player:get_player_name() or ""

  if not opts.force and minetest.is_protected(pos, pname) then
    minetest.record_protection_violation(pos, pname or "")
    return false
  end

  local lifetime = tonumber(opts.lifetime) or math.random(ws_fire.cfg.min_life_time, ws_fire.cfg.max_life_time)
  return place_fire_at(vector.new(pos), lifetime)
end

-- Tool definition: firestarter (like flint & steel)
minetest.register_tool("ws_fire:firestarter", {
  description = S("Firestarter"),
  inventory_image = "ws_fire_firestarter.png", -- user-supplied
  sound = {breaks = "default_tool_breaks"},
  on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then return itemstack end
    local under = pointed_thing.under
    local above = pointed_thing.above
    local node = minetest.get_node(under)
    local def = minetest.registered_nodes[node.name]
    local place_at = nil

    if def and def.buildable_to then
      place_at = under
    else
      local abdef = minetest.registered_nodes[minetest.get_node(above).name]
      if abdef and abdef.buildable_to then
        place_at = above
      end
    end

    if not place_at then return itemstack end

    -- Slight fuel requirement: must be near something flammable to catch
    local near = minetest.find_nodes_in_area(vector.subtract(place_at, 1), vector.add(place_at, 1), {"group:flammable"})
    if #near == 0 then
      return itemstack
    end

    if ws_fire.start_fire(place_at, {player = user}) then
      itemstack:add_wear(65535/64) -- 64 uses
    end
    return itemstack
  end
})
