-- ws_buckets: clean-room MIT rewrite
-- Entry: loads API + bundled content

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/api.lua")
dofile(modpath .. "/content.lua")
