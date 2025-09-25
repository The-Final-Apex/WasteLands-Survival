-- Priv + commands (namespaced)

minetest.register_privilege("ws_moon", {
  description = "Set WS Moon phase",
  give_to_singleplayer = false,
})

minetest.register_chatcommand("ws_moon", {
  description = "Show the current moon phase (1..8)",
  func = function(name, param)
    minetest.chat_send_player(name, "Current moon phase: " .. ws_moon.get_phase())
  end
})

minetest.register_chatcommand("ws_moon_set", {
  params = "<1..8>",
  description = "Admin: set the current moon phase",
  privs = { ws_moon = true },
  func = function(name, param)
    local ok = ws_moon.set_phase(param)
    if ok then
      return true, "Moon phase updated."
    else
      return false, "Usage: /ws_moon_set <1..8>"
    end
  end
})

minetest.register_chatcommand("ws_moon_style", {
  params = "<classic|realistic>",
  description = "Choose your personal moon texture preset",
  func = function(name, param)
    local player = minetest.get_player_by_name(name)
    if not player then return false, "Player not found." end
    if ws_moon.set_style(player, param) then
      return true, "Style updated."
    else
      return false, "Usage: /ws_moon_style <classic|realistic>"
    end
  end
})
