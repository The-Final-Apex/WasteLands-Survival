-- ws_fire/effects.lua
local cfg = ws_fire.cfg

-- Particles & sound management
local function spawn_particles(pos)
  if not cfg.enable_particles then return end
  minetest.add_particlespawner({
    amount = 8,
    time = 0.2,
    minpos = vector.add(pos, {-0.2, 0.0, -0.2}),
    maxpos = vector.add(pos, { 0.2, 0.4,  0.2}),
    minvel = {x=0, y=0.5, z=0},
    maxvel = {x=0.2, y=1.0, z=0.2},
    minacc = {x=0, y=0.0, z=0},
    maxacc = {x=0.1, y=0.2, z=0.1},
    minexptime = 0.4,
    maxexptime = 0.8,
    minsize = 1,
    maxsize = 2.5,
    texture = "ws_fire_smoke.png",
    glow = 3,
  })
end

local function play_sound(pos)
  if not cfg.enable_sound then return end
  minetest.sound_play("ws_fire_fire", {
    pos = pos, max_hear_distance = 12, gain = 0.35
  }, true) -- ephemeral handles are okay for lightweight loop-ish effect
end

-- Globalstep to add ambient effects on existing fire nodes
local step_accum = 0
minetest.register_globalstep(function(dtime)
  step_accum = step_accum + dtime
  if step_accum < 0.6 then return end
  step_accum = 0

  local players = minetest.get_connected_players()
  for _, p in ipairs(players) do
    local pos = vector.round(p:get_pos())
    local minp = vector.subtract(pos, 6)
    const = 6
    local maxp = vector.add(pos, const)
    local fires = minetest.find_nodes_in_area(minp, maxp, {"ws_fire:fire"})
    for _, fp in ipairs(fires) do
      spawn_particles(fp)
      play_sound(fp)
    end
  end
end)
