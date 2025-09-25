-- ws_fire/nodes.lua

local cfg = ws_fire.cfg

minetest.register_node("ws_fire:fire", {
  description = "Fire",
  drawtype = "firelike",
  tiles = {
    {name="ws_fire_fire.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}}
  },
  inventory_image = "ws_fire_fire.png",
  wield_image = "ws_fire_fire.png",
  paramtype = "light",
  light_source = 13,
  walkable = false,
  buildable_to = true,
  floodable = true,
  damage_per_second = cfg.damage_per_second,
  groups = {igniter = 1, not_in_creative_inventory = 1, hot = 1},
  drop = "",
  on_construct = function(pos)
    local t = minetest.get_node_timer(pos)
    if not t:is_started() then
      t:start(cfg.tick_interval)
    end
  end,
  on_timer = function(pos, elapsed)
    -- Timer tick handled in spread.lua to keep logic in one place
    return true
  end,
  on_blast = function(pos)
    minetest.remove_node(pos)
  end,
})

minetest.register_node("ws_fire:embers", {
  description = "Embers",
  drawtype = "plantlike",
  tiles = {"ws_fire_embers.png"},
  paramtype = "light",
  light_source = 5,
  walkable = false,
  buildable_to = true,
  floodable = true,
  groups = {not_in_creative_inventory = 1},
  drop = "",
  on_construct = function(pos)
    local t = minetest.get_node_timer(pos)
    t:start(2)
  end,
  on_timer = function(pos, elapsed)
    minetest.remove_node(pos)
    return false
  end,
})

minetest.register_node("ws_fire:smoke", {
  description = "Smoke",
  drawtype = "airlike",
  paramtype = "light",
  sunlight_propagates = true,
  pointable = false,
  walkable = false,
  diggable = false,
  buildable_to = true,
  groups = {not_in_creative_inventory = 1},
})
