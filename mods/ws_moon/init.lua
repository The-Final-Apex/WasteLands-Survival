local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/settings.lua")
dofile(modpath .. "/sky.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/chat.lua")
