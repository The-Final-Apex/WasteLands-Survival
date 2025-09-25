-- ws_fire/spread.lua
local cfg = ws_fire.cfg

-- Helpers
local function is_protected(pos, playername)
  if minetest.is_protected(pos, playername or "") then
    return true
  end
  return false
end

local function node_buildable_or_air(pos)
  local n = minetest.get_node_or_nil(pos)
  if not n then return false end
  if n.name == "air" then return true end
  local def = minetest.registered_nodes[n.name]
  return def and def.buildable_to
end

local function sees_open_sky(pos)
  -- simple vertical check; see api.lua alternative
  local above = vector.new(pos)
  for i = 1, 64 do
    above.y = above.y + 1
    local n = minetest.get_node(above)
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

local function is_wet_neighbor(pos)
  -- If ws_core water or lava nearby, adjust behavior
  local near = minetest.find_nodes_in_area(vector.subtract(pos, 1), vector.add(pos, 1),
    {"group:water", "ws_core:water_source", "ws_core:water_flowing"})
  return #near > 0
end

-- Node timer driver for fire behavior
minetest.register_abm({
  label = "ws_fire tick",
  nodenames = {"ws_fire:fire"},
  interval = cfg.tick_interval,
  chance = 1,
  action = function(pos, node, active_object_count, active_object_count_wider)
    local meta = minetest.get_meta(pos)
    local life = meta:get_float("ws_fire_life")
    if life <= 0 then
      life = math.random(cfg.min_life_time, cfg.max_life_time)
    end

    -- decay
    if cfg.enable_decay then
      local decay = 1.0
      if sees_open_sky(pos) then
        decay = decay + cfg.sky_decay_bonus
      end
      if is_wet_neighbor(pos) then
        decay = decay + 0.75
      end
      life = life - decay
      meta:set_float("ws_fire_life", life)
      if life <= 0 then
        -- transition to embers briefly
        minetest.set_node(pos, {name = "ws_fire:embers"})
        return
      end
    end

    -- spread
    if cfg.enable_spread then
      local minp = vector.subtract(pos, cfg.spread_radius)
      local maxp = vector.add(pos, cfg.spread_radius)
      local airspots = minetest.find_nodes_in_area_under_air(minp, maxp, {"group:flammable"})
      -- Ignite above/beside flammable nodes
      for _, under_pos in ipairs(airspots) do
        if math.random() < cfg.ignite_chance then
          local above = {x=under_pos.x, y=under_pos.y+1, z=under_pos.z}
          if node_buildable_or_air(above) then
            -- protection check
            if not is_protected(above) then
              ws_fire.start_fire(above, {force=false})
            end
          end
        end
      end
    end
  end
})
