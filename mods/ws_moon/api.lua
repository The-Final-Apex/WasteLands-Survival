-- Public API

-- Get the current phase (1..8)
function ws_moon.get_phase()
  return ws_moon._phase
end

-- Set the current phase (1..8). Stores offset relative to current day so it persists.
function ws_moon.set_phase(target_phase)
  local n = tonumber(target_phase) and math.floor(target_phase) or nil
  if not n or n < 1 or n > ws_moon.cfg.phase_count then return false end

  -- compute required offset so that _calc_phase() will equal n
  local current = ws_moon._calc_phase()
  local delta = (n - current) % ws_moon.cfg.phase_count

  local day = minetest.get_day_count()
  local offset = ws_moon._store:get_int("offset") or 0
  local phase_days = ws_moon.cfg.cycle_days
  local new_offset = offset + delta * phase_days

  ws_moon._store:set_int("offset", new_offset)
  ws_moon._phase = ws_moon._calc_phase()
  ws_moon._broadcast_phase(ws_moon._phase)
  return true
end

-- Set a player's preferred texture style ("classic" | "realistic")
function ws_moon.set_style(player, style)
  if not (player and player.is_player and player:is_player()) then return false end
  if style ~= "classic" and style ~= "realistic" then return false end
  player:get_meta():set_string("ws_moon:style", style)
  ws_moon._apply_sky(player, ws_moon._phase)
  return true
end

-- Lifecycle
minetest.register_on_joinplayer(function(player)
  -- initialize current phase and push sky on join
  ws_moon._phase = ws_moon._calc_phase()
  ws_moon._apply_sky(player, ws_moon._phase)
end)

-- Small timer to detect when phase flips (when day count advances far enough)
local acc = 1e9
minetest.register_globalstep(function(dtime)
  acc = acc + dtime
  if acc < ws_moon.cfg.sky_tick then return end
  acc = 0
  local p = ws_moon._calc_phase()
  if p ~= ws_moon._phase then
    ws_moon._phase = p
    ws_moon._broadcast_phase(p)
  end
end)
