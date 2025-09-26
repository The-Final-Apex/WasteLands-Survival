local cfg = ws_hunger.cfg

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function meta_get(player)
  return player:get_meta()
end

function ws_hunger.get_satiation(player)
  local m = meta_get(player)
  local v = m:get_int("ws_hunger:satiation")
  if v == 0 and m:get_string("ws_hunger:init") == "" then
    v = cfg.start
    m:set_int("ws_hunger:satiation", v)
    m:set_string("ws_hunger:init", "1")
  end
  return clamp(v, 0, cfg.max)
end

function ws_hunger.set_satiation(player, value)
  value = clamp(math.floor(value or 0), 0, cfg.max)
  meta_get(player):set_int("ws_hunger:satiation", value)
  ws_hunger._satiation[player:get_player_name()] = value
  ws_hunger.hud_update(player)
  return value
end

function ws_hunger.add_satiation(player, delta)
  local v = ws_hunger.get_satiation(player) + (delta or 0)
  return ws_hunger.set_satiation(player, v)
end

function ws_hunger.add_exhaustion(player, name, amount)
  local pn = player:get_player_name()
  ws_hunger._exhaust[pn] = (ws_hunger._exhaust[pn] or 0) + (amount or 0)
  if ws_hunger._exhaust[pn] >= cfg.exhaust_threshold then
    ws_hunger._exhaust[pn] = 0
    ws_hunger.add_satiation(player, -1)
  end
end

function ws_hunger.get_exhaustion(player)
  return ws_hunger._exhaust[player:get_player_name()] or 0
end

function ws_hunger.poison(player, time, dps)
  local pn = player:get_player_name()
  ws_hunger._poison[pn] = ws_hunger._poison[pn] or {time_left=0, dps=1}
  ws_hunger._poison[pn].time_left = (ws_hunger._poison[pn].time_left or 0) + (time or 0)
  ws_hunger._poison[pn].dps = dps or 1
end

function ws_hunger.eat(gain, opts)
  opts = opts or {}
  local replace = opts.replace
  local poison = opts.poison
  local sound  = opts.sound or "ws_hunger_eat"
  return function(itemstack, user, pointed)
    if not user or not user:is_player() then return itemstack end
    minetest.sound_play({name=sound, gain=1},{pos=user:get_pos(), max_hear_distance=16})
    ws_hunger.add_satiation(user, gain or 1)
    if poison and (poison.time or 0) > 0 then
      ws_hunger.poison(user, poison.time, poison.dps or 1)
    end
    itemstack:take_item(1)
    if replace and replace ~= "" then
      if itemstack:is_empty() then
        itemstack:add_item(replace)
      else
        local inv = user:get_inventory()
        if inv and inv:room_for_item("main", replace) then
          inv:add_item("main", replace)
        else
          minetest.add_item(user:get_pos(), replace)
        end
      end
    end
    return itemstack
  end
end
