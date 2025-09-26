ws_moon = rawget(_G, "ws_moon") or {}
local settings = minetest.settings

-- Prefer our own keys; fall back to original mod's keys for convenience
local cycle_days = tonumber(settings:get("ws_moon.cycle_days")) 
                    or tonumber(settings:get("moon_phases_cycle")) or 4
local default_style = settings:get("ws_moon.style") 
                    or settings:get("moon_phases_style") or "classic"

ws_moon.cfg = {
  cycle_days = cycle_days,   -- in-game days per phase
  default_style = default_style, -- "classic" | "realistic"
  phase_count = 8,
  sky_tick = 0.7, -- seconds between checks
}

-- runtime state
ws_moon._phase = 1
ws_moon._store = minetest.get_mod_storage()

-- Helpers
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end
ws_moon._clamp = clamp

-- Compute phase from absolute day count + offset (stored in mod storage)
function ws_moon._calc_phase()
  local day = minetest.get_day_count() + (ws_moon._store:get_int("offset") or 0)
  -- Progress increases after local midnight to keep phase change during night
  local t = minetest.get_timeofday()
  local roll = (t > 0.5) and 1 or 0
  local idx = math.floor(((day + roll) / ws_moon.cfg.cycle_days)) % ws_moon.cfg.phase_count
  return idx + 1
end
