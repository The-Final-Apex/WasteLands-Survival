-- Blacksmith Mod - Tinkers Construct Inspired
-- Entry point for loading all features

blacksmith = {}
blacksmith.modpath = minetest.get_modpath("blacksmith")

dofile(blacksmith.modpath .. "/smeltery.lua")
dofile(blacksmith.modpath .. "/casting.lua")
dofile(blacksmith.modpath .. "/tool_parts.lua")
dofile(blacksmith.modpath .. "/tool_station.lua")
