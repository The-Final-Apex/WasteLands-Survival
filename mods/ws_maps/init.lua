-- ws_maps: Enhanced mapping and navigation system for Wastelands Survival

local maps = {}
maps.player_data = {}
maps.landmark_types = {}
maps.map_items = {}

-- Configuration
maps.config = {
    auto_mapping = true,
    mapping_radius = 20, -- Nodes around player to map
    update_interval = 5.0, -- Seconds between auto-map updates
    max_map_scale = 1000, -- Maximum map size in nodes
    min_map_scale = 50,   -- Minimum map size in nodes
    landmark_discovery_range = 10, -- How close to discover landmarks
}

-- Player data structure
maps.player_data_template = {
    discovered_areas = {},
    landmarks = {},
    waypoints = {},
    current_map_scale = 200,
    map_center = {x = 0, y = 0, z = 0},
    has_map_item = false
}

-- Landmark types with icons and discovery messages
maps.landmark_types = {
    ["water_source"] = {
        name = "Water Source",
        icon = "ws_maps_water.png",
        discovery_msg = "Discovered fresh water source",
        nodes = {"default:water_source", "default:river_water_source"}
    },
    ["ruins"] = {
        name = "Ruins", 
        icon = "ws_maps_ruins.png",
        discovery_msg = "Found ancient ruins",
        nodes = {"ws_ruins:small_house", "ws_ruins:guard_tower", "ws_ruins:bunker"}
    },
    ["danger_zone"] = {
        name = "Danger Zone",
        icon = "ws_maps_danger.png",
        discovery_msg = "Marked dangerous area",
        nodes = {"ws_radiation:zone", "mobs:spawner"}
    },
    ["resources"] = {
        name = "Resources",
        icon = "ws_maps_resources.png",
        discovery_msg = "Found valuable resources", 
        nodes = {"default:stone_with_iron", "default:stone_with_copper", "default:stone_with_diamond"}
    },
    ["shelter"] = {
        name = "Shelter",
        icon = "ws_maps_shelter.png",
        discovery_msg = "Found potential shelter",
        nodes = {"default:chest", "doors:door_wood", "xpanes:bar_flat"}
    },
    ["high_ground"] = {
        name = "High Ground",
        icon = "ws_maps_high_ground.png",
        discovery_msg = "Good vantage point discovered",
        nodes = {"default:tree", "default:pine_tree", "default:jungletree"}
    }
}

-- Initialize player data
function maps.init_player_data(player_name)
    if not maps.player_data[player_name] then
        maps.player_data[player_name] = table.copy(maps.player_data_template)
    end
    return maps.player_data[player_name]
end

-- Check if position is discovered
function maps.is_position_discovered(player_name, pos)
    local data = maps.init_player_data(player_name)
    local chunk_x = math.floor(pos.x / 16) * 16
    local chunk_z = math.floor(pos.z / 16) * 16
    local chunk_key = chunk_x .. "," .. chunk_z
    
    return data.discovered_areas[chunk_key] or false
end

-- Discover new area
function maps.discover_area(player_name, pos)
    local data = maps.init_player_data(player_name)
    local chunk_x = math.floor(pos.x / 16) * 16
    local chunk_z = math.floor(pos.z / 16) * 16
    local chunk_key = chunk_x .. "," .. chunk_z
    
    if not data.discovered_areas[chunk_key] then
        data.discovered_areas[chunk_key] = {
            x = chunk_x,
            z = chunk_z,
            discovered_at = os.time()
        }
        return true
    end
    return false
end

-- Auto-mapping system
function maps.update_player_map(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end
    
    local data = maps.init_player_data(player_name)
    local pos = player:get_pos()
    
    -- Discover area around player
    local radius = maps.config.mapping_radius
    local new_areas = 0
    
    for x = -radius, radius, 16 do
        for z = -radius, radius, 16 do
            local check_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
            if maps.discover_area(player_name, check_pos) then
                new_areas = new_areas + 1
            end
        end
    end
    
    -- Check for landmarks
    maps.check_landmarks(player_name, pos)
    
    return new_areas
end

-- Landmark discovery system
function maps.check_landmarks(player_name, pos)
    local data = maps.init_player_data(player_name)
    
    for landmark_type, def in pairs(maps.landmark_types) do
        for _, node_name in ipairs(def.nodes) do
            local found_pos = maps.find_nearby_node(pos, node_name, maps.config.landmark_discovery_range)
            if found_pos then
                maps.add_landmark(player_name, landmark_type, found_pos)
            end
        end
    end
end

function maps.find_nearby_node(center_pos, node_name, range)
    for x = -range, range do
        for y = -range, range do
            for z = -range, range do
                local check_pos = {
                    x = center_pos.x + x,
                    y = center_pos.y + y, 
                    z = center_pos.z + z
                }
                local node = minetest.get_node(check_pos)
                if node.name == node_name then
                    return check_pos
                end
            end
        end
    end
    return nil
end

function maps.add_landmark(player_name, landmark_type, pos)
    local data = maps.init_player_data(player_name)
    local landmark_key = pos.x .. "," .. pos.z
    
    if not data.landmarks[landmark_key] then
        data.landmarks[landmark_key] = {
            type = landmark_type,
            pos = table.copy(pos),
            discovered_at = os.time(),
            notes = ""
        }
        
        -- Notify player
        local landmark_def = maps.landmark_types[landmark_type]
        if landmark_def and landmark_def.discovery_msg then
            minetest.chat_send_player(player_name, "#55FFFF " .. landmark_def.discovery_msg)
        end
        
        -- Journal integration
        if minetest.get_modpath("ws_story") then
            local entries = journal.require("entries")
            entries.add_entry(player_name, "ws_story:survivor",
                landmark_def.discovery_msg .. " at " .. math.floor(pos.x) .. ", " .. math.floor(pos.z), true)
        end
        
        return true
    end
    return false
end

-- Waypoint system
function maps.add_waypoint(player_name, name, pos, color)
    local data = maps.init_player_data(player_name)
    local waypoint_key = name:gsub("%s+", "_"):lower()
    
    data.waypoints[waypoint_key] = {
        name = name,
        pos = table.copy(pos),
        color = color or "#FFFFFF",
        created_at = os.time()
    }
    
    return waypoint_key
end

function maps.remove_waypoint(player_name, waypoint_key)
    local data = maps.init_player_data(player_name)
    data.waypoints[waypoint_key] = nil
end

-- Map item registration
minetest.register_craftitem("ws_maps:empty_map", {
    description = "Empty Map\nRight-click to start mapping your journey",
    inventory_image = "ws_maps_empty.png",
    groups = {map = 1},
    
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local data = maps.init_player_data(player_name)
        
        if not data.has_map_item then
            data.has_map_item = true
            data.map_center = user:get_pos()
            minetest.chat_send_player(player_name, "#55FF55 Map activated! Your journey begins here.")
            
            -- Transform into filled map
            itemstack:set_name("ws_maps:filled_map")
        end
        
        return itemstack
    end,
})

minetest.register_craftitem("ws_maps:filled_map", {
    description = "Explorer's Map\nRight-click to view your discoveries",
    inventory_image = "ws_maps_filled.png",
    groups = {map = 1, not_in_creative_inventory = 1},
    
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        maps.show_map_gui(player_name)
        return itemstack
    end,
})

minetest.register_craftitem("ws_maps:blank_map", {
    description = "Blank Map\nCan be copied from existing maps",
    inventory_image = "ws_maps_blank.png",
    groups = {map = 1},
})

-- Map crafting recipes
minetest.register_craft({
    output = "ws_maps:empty_map",
    recipe = {
        {"default:paper", "default:paper", "default:paper"},
        {"default:paper", "default:coal_lump", "default:paper"},
        {"default:paper", "default:paper", "default:paper"}
    }
})

minetest.register_craft({
    output = "ws_maps:blank_map",
    recipe = {
        {"default:paper", "default:paper"},
        {"default:paper", "default:paper"},
    }
})

-- Map copying
minetest.register_craft({
    type = "shapeless",
    output = "ws_maps:filled_map",
    recipe = {"ws_maps:filled_map", "ws_maps:blank_map"}
})

-- Main map GUI
function maps.show_map_gui(player_name)
    local data = maps.init_player_data(player_name)
    local player = minetest.get_player_by_name(player_name)
    local player_pos = player:get_pos()
    
    local formspec = "size[12,10]" ..
        "bgcolor[#1A1A2E;false]" ..
        "background9[0,0;12,10;ws_maps_bg.png;false;10]" ..
        "label[0.5,0.5;" .. minetest.colorize("#FFFFFF", "Wastelands Survival Map") .. "]" ..
        "label[9,0.5;" .. minetest.colorize("#FFFF00", "Scale: 1:" .. data.current_map_scale) .. "]" ..
        "button[0.5,9;2,0.5;zoom_in;Zoom In]" ..
        "button[2.5,9;2,0.5;zoom_out;Zoom Out]" ..
        "button[4.5,9;2,0.5;set_waypoint;Set Waypoint]" ..
        "button[6.5,9;2,0.5;waypoints;Waypoints]" ..
        "button_exit[9.5,9;2,0.5;close;Close]" ..
        "container[0.5,1]"
    
    -- Create map background grid
    local map_size = 8.5
    local center_x = data.map_center.x
    local center_z = data.map_center.z
    local scale = data.current_map_scale
    
    -- Draw map background
    formspec = formspec ..
        "image[0,0;" .. map_size .. "," .. map_size .. ";ws_maps_grid.png]"
    
    -- Draw discovered areas
    for chunk_key, chunk_data in pairs(data.discovered_areas) do
        local rel_x = (chunk_data.x - center_x) / scale
        local rel_z = (chunk_data.z - center_z) / scale
        
        if math.abs(rel_x) <= map_size/2 and math.abs(rel_z) <= map_size/2 then
            local screen_x = (map_size/2) + rel_x - 0.2
            local screen_y = (map_size/2) + rel_z - 0.2
            formspec = formspec ..
                "image[" .. screen_x .. "," .. screen_y .. ";0.4,0.4;ws_maps_discovered.png]"
        end
    end
    
    -- Draw landmarks
    for _, landmark_data in pairs(data.landmarks) do
        local rel_x = (landmark_data.pos.x - center_x) / scale
        local rel_z = (landmark_data.pos.z - center_z) / scale
        
        if math.abs(rel_x) <= map_size/2 and math.abs(rel_z) <= map_size/2 then
            local screen_x = (map_size/2) + rel_x - 0.1
            local screen_y = (map_size/2) + rel_z - 0.1
            local landmark_def = maps.landmark_types[landmark_data.type]
            
            if landmark_def then
                formspec = formspec ..
                    "image[" .. screen_x .. "," .. screen_y .. ";0.2,0.2;" .. landmark_def.icon .. "]"
            end
        end
    end
    
    -- Draw waypoints
    for _, waypoint_data in pairs(data.waypoints) do
        local rel_x = (waypoint_data.pos.x - center_x) / scale
        local rel_z = (waypoint_data.pos.z - center_z) / scale
        
        if math.abs(rel_x) <= map_size/2 and math.abs(rel_z) <= map_size/2 then
            local screen_x = (map_size/2) + rel_x - 0.1
            local screen_y = (map_size/2) + rel_z - 0.1
            formspec = formspec ..
                "image[" .. screen_x .. "," .. screen_y .. ";0.2,0.2;ws_maps_waypoint.png]"
        end
    end
    
    -- Draw player position
    local player_rel_x = (player_pos.x - center_x) / scale
    local player_rel_z = (player_pos.z - center_z) / scale
    
    if math.abs(player_rel_x) <= map_size/2 and math.abs(player_rel_z) <= map_size/2 then
        local screen_x = (map_size/2) + player_rel_x - 0.1
        local screen_y = (map_size/2) + player_rel_z - 0.1
        formspec = formspec ..
            "image[" .. screen_x .. "," .. screen_y .. ";0.2,0.2;ws_maps_player.png]"
    end
    
    formspec = formspec .. "container_end[]" ..
        "label[9,1;Statistics]" ..
        "label[9,1.5;Discovered Areas: " .. #data.discovered_areas .. "]" ..
        "label[9,2;Landmarks: " .. #data.landmarks .. "]" ..
        "label[9,2.5;Waypoints: " .. #data.waypoints .. "]" ..
        "label[9,3;Current Position:]" ..
        "label[9,3.5;" .. math.floor(player_pos.x) .. ", " .. math.floor(player_pos.z) .. "]"
    
    minetest.show_formspec(player_name, "ws_maps:main", formspec)
end

-- Waypoints management GUI
function maps.show_waypoints_gui(player_name)
    local data = maps.init_player_data(player_name)
    local formspec = "size[8,9]" ..
        "bgcolor[#1A1A2E;false]" ..
        "label[0.5,0.5;" .. minetest.colorize("#FFFFFF", "Waypoints Management") .. "]" ..
        "textlist[0.5,1;7,6;waypoints_list;"
    
    local waypoint_count = 0
    for key, waypoint_data in pairs(data.waypoints) do
        formspec = formspec .. waypoint_data.name .. " (" .. 
                   math.floor(waypoint_data.pos.x) .. ", " .. 
                   math.floor(waypoint_data.pos.z) .. "),"
        waypoint_count = waypoint_count + 1
    end
    
    if waypoint_count == 0 then
        formspec = formspec .. "No waypoints set,"
    end
    
    formspec = formspec .. "]" ..
        "button[0.5,7.5;3,0.5;add_waypoint;Add Waypoint]" ..
        "button[3.5,7.5;3,0.5;remove_waypoint;Remove Selected]" ..
        "button_exit[6.5,7.5;1,0.5;close;Close]"
    
    minetest.show_formspec(player_name, "ws_maps:waypoints", formspec)
end

-- Add waypoint GUI
function maps.show_add_waypoint_gui(player_name)
    local player = minetest.get_player_by_name(player_name)
    local pos = player:get_pos()
    
    local formspec = "size[6,4]" ..
        "bgcolor[#1A1A2E;false]" ..
        "label[0.5,0.5;Add New Waypoint]" ..
        "field[0.5,1.5;5,0.5;waypoint_name;Waypoint Name;]" ..
        "label[0.5,2.5;Position: " .. math.floor(pos.x) .. ", " .. math.floor(pos.z) .. "]" ..
        "button[0.5,3;2,0.5;confirm_add;Add Waypoint]" ..
        "button[2.5,3;2,0.5;cancel;Cancel]"
    
    minetest.show_formspec(player_name, "ws_maps:add_waypoint", formspec)
end

-- Handle GUI events
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    local data = maps.init_player_data(player_name)
    
    if formname == "ws_maps:main" then
        if fields.zoom_in then
            data.current_map_scale = math.max(maps.config.min_map_scale, data.current_map_scale / 1.5)
            maps.show_map_gui(player_name)
        elseif fields.zoom_out then
            data.current_map_scale = math.min(maps.config.max_map_scale, data.current_map_scale * 1.5)
            maps.show_map_gui(player_name)
        elseif fields.set_waypoint then
            maps.show_add_waypoint_gui(player_name)
        elseif fields.waypoints then
            maps.show_waypoints_gui(player_name)
        end
        return true
        
    elseif formname == "ws_maps:add_waypoint" then
        if fields.confirm_add and fields.waypoint_name and fields.waypoint_name ~= "" then
            local player_pos = player:get_pos()
            maps.add_waypoint(player_name, fields.waypoint_name, player_pos, "#FF5555")
            minetest.chat_send_player(player_name, "#55FF55 Waypoint '" .. fields.waypoint_name .. "' added!")
            maps.show_map_gui(player_name)
        elseif fields.cancel then
            maps.show_map_gui(player_name)
        end
        return true
        
    elseif formname == "ws_maps:waypoints" then
        if fields.add_waypoint then
            maps.show_add_waypoint_gui(player_name)
        elseif fields.waypoints_list then
            local event = minetest.explode_textlist_event(fields.waypoints_list)
            if event.type == "DCL" then
                -- Double click to teleport? Or show info?
            end
        end
        return true
    end
end)

-- Compass item for navigation
minetest.register_craftitem("ws_maps:compass", {
    description = "Compass\nRight-click to check direction",
    inventory_image = "ws_maps_compass.png",
    groups = {tool = 1},
    
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local player = minetest.get_player_by_name(player_name)
        local yaw = player:get_look_horizontal()
        
        local directions = {
            {min = -22.5, max = 22.5, name = "North", color = "#FF5555"},
            {min = 22.5, max = 67.5, name = "Northeast", color = "#FFAA55"},
            {min = 67.5, max = 112.5, name = "East", color = "#FFFF55"},
            {min = 112.5, max = 157.5, name = "Southeast", color = "#AAFF55"},
            {min = 157.5, max = 202.5, name = "South", color = "#55FF55"},
            {min = 202.5, max = 247.5, name = "Southwest", color = "#55FFAA"},
            {min = 247.5, max = 292.5, name = "West", color = "#55FFFF"},
            {min = 292.5, max = 337.5, name = "Northwest", color = "#5555FF"},
        }
        
        local degrees = math.deg(yaw) % 360
        if degrees < 0 then degrees = degrees + 360 end
        
        local direction_name = "North"
        local direction_color = "#FF5555"
        
        for _, dir in ipairs(directions) do
            if degrees >= dir.min and degrees < dir.max then
                direction_name = dir.name
                direction_color = dir.color
                break
            end
        end
        
        minetest.chat_send_player(player_name, direction_color .. "Facing: " .. direction_name .. 
                                 " (" .. math.floor(degrees) .. "°)")
        
        return itemstack
    end,
})

minetest.register_craft({
    output = "ws_maps:compass",
    recipe = {
        {"", "default:steel_ingot", ""},
        {"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
        {"", "default:steel_ingot", ""}
    }
})

-- Auto-mapping background task
local function mapping_task()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local data = maps.init_player_data(player_name)
        
        if data.has_map_item then
            maps.update_player_map(player_name)
        end
    end
    
    minetest.after(maps.config.update_interval, mapping_task)
end

-- Start auto-mapping
minetest.after(0, mapping_task)

-- Player management
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    maps.init_player_data(player_name)
end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    -- Persist data if needed, or keep in memory
end)

-- Achievement integration
if minetest.get_modpath("ws_achievements") then
    ws_achievements.register_achievement("cartographer", {
        title = "Cartographer",
        description = "Discover 100 map chunks",
        category = "exploration",
        icon = "ws_achievements_map.png"
    })
    
    ws_achievements.register_achievement("landmark_explorer", {
        title = "Landmark Explorer", 
        description = "Discover 10 different landmarks",
        category = "exploration",
        icon = "ws_achievements_landmark.png"
    })
    
    ws_achievements.register_achievement("pathfinder", {
        title = "Pathfinder",
        description = "Set 5 personal waypoints",
        category = "exploration", 
        icon = "ws_achievements_waypoint.png"
    })
end

-- Journal integration
if minetest.get_modpath("ws_story") then
    local triggers = journal.require("triggers")
    
    triggers.register_on_craft({
        target = "ws_maps:empty_map",
        id = "ws_maps:map_creation",
        call_once = true,
        call = function(data)
            local entries = journal.require("entries")
            entries.add_entry(data.playerName, "ws_story:survivor",
                "Created a map today. Maybe if I document my journey, others might find it useful someday. " ..
                "Or at least I won't keep getting lost in this endless wasteland.", true)
        end,
    })
end

-- Admin command to reveal map
minetest.register_chatcommand("reveal_map", {
    description = "Reveal entire map (admin only)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end
        
        local pos = player:get_pos()
        local data = maps.init_player_data(name)
        
        -- Reveal large area around player
        local radius = 500
        local chunks_revealed = 0
        
        for x = -radius, radius, 16 do
            for z = -radius, radius, 16 do
                local chunk_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
                if maps.discover_area(name, chunk_pos) then
                    chunks_revealed = chunks_revealed + 1
                end
            end
        end
        
        return true, "Revealed " .. chunks_revealed .. " map chunks"
    end,
})

minetest.log("action", "[ws_maps] Mapping system loaded")

-- Make API available globally
ws_maps = maps
