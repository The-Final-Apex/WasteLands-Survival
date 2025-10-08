-- ws_tech: Technology tree for Wastelands Survival

local tech = {}
tech.players = {}
tech.technologies = {}
tech.research_categories = {}

-- Research categories
tech.research_categories = {
    survival = {
        name = "Basic Survival",
        icon = "ws_tech_survival.png",
        description = "Essential survival technologies"
    },
    tools = {
        name = "Tools & Equipment", 
        icon = "ws_tech_tools.png",
        description = "Advanced tools and equipment"
    },
    construction = {
        name = "Construction",
        icon = "ws_tech_construction.png",
        description = "Building and base construction"
    },
    energy = {
        name = "Energy",
        icon = "ws_tech_energy.png",
        description = "Power generation and storage"
    },
    advanced = {
        name = "Advanced Tech",
        icon = "ws_tech_advanced.png",
        description = "Pre-apocalypse technology"
    }
}

-- Technology definitions
tech.technologies = {
    -- Survival tier
    ["basic_tools"] = {
        name = "Basic Tool Crafting",
        description = "Unlocks stone tools and basic equipment",
        category = "survival",
        icon = "ws_tech_basic_tools.png",
        cost = {["default:cobble"] = 10},
        prerequisites = {},
        unlocks = {
            recipes = {"default:pick_stone", "default:axe_stone", "default:shovel_stone"},
            items = {"default:pick_stone", "default:axe_stone"}
        }
    },
    
    ["water_purification"] = {
        name = "Water Purification",
        description = "Basic water cleaning methods",
        category = "survival", 
        icon = "ws_tech_water_purify.png",
        cost = {["default:clay_lump"] = 5, ["default:sand"] = 10},
        prerequisites = {"basic_tools"},
        unlocks = {
            recipes = {"ws_tech:clay_filter", "ws_tech:water_boiler"},
            items = {"ws_tech:clay_filter"}
        }
    },
    
    ["basic_agriculture"] = {
        name = "Basic Agriculture", 
        description = "Simple farming techniques",
        category = "survival",
        icon = "ws_tech_farming.png",
        cost = {["default:stick"] = 8, ["farming:seed_wheat"] = 3},
        prerequisites = {"basic_tools"},
        unlocks = {
            recipes = {"farming:hoe_stone", "farming:seed_wheat"},
            items = {"farming:hoe_stone"}
        }
    },
    
    -- Tools tier
    ["metal_working"] = {
        name = "Metal Working",
        description = "Smelting and basic metal tools",
        category = "tools",
        icon = "ws_tech_metal.png",
        cost = {["default:iron_lump"] = 5, ["default:furnace"] = 1},
        prerequisites = {"basic_tools"},
        unlocks = {
            recipes = {"default:pick_steel", "default:axe_steel", "default:shovel_steel"},
            items = {"default:pick_steel"}
        }
    },
    
    ["advanced_tools"] = {
        name = "Advanced Tools",
        description = "Specialized tools for specific tasks",
        category = "tools",
        icon = "ws_tech_advanced_tools.png",
        cost = {["default:steel_ingot"] = 8, ["default:diamond"] = 1},
        prerequisites = {"metal_working"},
        unlocks = {
            recipes = {"ws_tech:hammer", "ws_tech:saw", "ws_tech:screwdriver"},
            items = {"ws_tech:hammer"}
        }
    },
    
    -- Construction tier  
    ["basic_construction"] = {
        name = "Basic Construction",
        description = "Improved building materials",
        category = "construction",
        icon = "ws_tech_construction.png",
        cost = {["default:wood"] = 20, ["default:stone"] = 15},
        prerequisites = {"basic_tools"},
        unlocks = {
            recipes = {"default:chest", "doors:door_wood", "xpanes:bar_flat"},
            items = {"default:chest", "doors:door_wood"}
        }
    },
    
    ["reinforced_structures"] = {
        name = "Reinforced Structures",
        description = "Stronger defensive structures",
        category = "construction",
        icon = "ws_tech_reinforced.png",
        cost = {["default:steel_ingot"] = 10, ["default:stone"] = 20},
        prerequisites = {"metal_working", "basic_construction"},
        unlocks = {
            recipes = {"ws_tech:reinforced_door", "ws_tech:barricade", "ws_tech:watchtower"},
            items = {"ws_tech:reinforced_door"}
        }
    },
    
    -- Energy tier
    ["basic_power"] = {
        name = "Basic Power Generation",
        description = "Simple electricity production",
        category = "energy",
        icon = "ws_tech_power.png",
        cost = {["default:copper_ingot"] = 8, ["default:steel_ingot"] = 5},
        prerequisites = {"metal_working"},
        unlocks = {
            recipes = {"ws_tech:hand_crank", "ws_tech:basic_battery", "ws_tech:simple_light"},
            items = {"ws_tech:hand_crank"}
        }
    },
    
    ["solar_power"] = {
        name = "Solar Power",
        description = "Renewable energy from the sun",
        category = "energy", 
        icon = "ws_tech_solar.png",
        cost = {["default:glass"] = 10, ["default:copper_ingot"] = 15, ["ws_tech:basic_battery"] = 2},
        prerequisites = {"basic_power"},
        unlocks = {
            recipes = {"ws_tech:solar_panel", "ws_tech:led_light", "ws_tech:power_storage"},
            items = {"ws_tech:solar_panel"}
        }
    },
    
    -- Advanced tier
    ["radiation_protection"] = {
        name = "Radiation Protection",
        description = "Equipment to survive contaminated zones",
        category = "advanced",
        icon = "ws_tech_rad_protection.png",
        cost = {["default:steel_ingot"] = 10, ["default:glass"] = 5, ["default:coal_lump"] = 8},
        prerequisites = {"metal_working"},
        unlocks = {
            recipes = {"ws_radiation:gas_mask", "ws_radiation:geiger_counter", "ws_radiation:rad_pills"},
            items = {"ws_radiation:gas_mask"}
        }
    },
    
    ["advanced_medicine"] = {
        name = "Advanced Medicine",
        description = "Medical treatments and antidotes",
        category = "advanced",
        icon = "ws_tech_medicine.png",
        cost = {["farming:carrot"] = 5, ["default:glass"] = 3, ["default:mese_crystal"] = 1},
        prerequisites = {"water_purification", "radiation_protection"},
        unlocks = {
            recipes = {"ws_tech:antidote", "ws_tech:medkit", "ws_tech:painkillers"},
            items = {"ws_tech:antidote"}
        }
    }
}

-- Player research management
function tech.get_player_research(player_name)
    if not tech.players[player_name] then
        tech.players[player_name] = {
            researched = {},
            research_points = 0,
            available_points = 0
        }
    end
    return tech.players[player_name]
end

function tech.can_research(player_name, tech_id)
    local player_tech = tech.get_player_research(player_name)
    local technology = tech.technologies[tech_id]
    
    if not technology or player_tech.researched[tech_id] then
        return false, "Already researched or invalid technology"
    end
    
    -- Check prerequisites
    for _, prereq in ipairs(technology.prerequisites) do
        if not player_tech.researched[prereq] then
            return false, "Missing prerequisite: " .. tech.technologies[prereq].name
        end
    end
    
    -- Check if player has required items
    for item, count in pairs(technology.cost) do
        local player_inv = minetest.get_player_by_name(player_name):get_inventory()
        if player_inv:contains_item("main", ItemStack(item .. " " .. count)) < count then
            return false, "Need " .. count .. " " .. minetest.registered_items[item].description
        end
    end
    
    return true, "Can research"
end

function tech.research_technology(player_name, tech_id)
    local can_research, reason = tech.can_research(player_name, tech_id)
    if not can_research then
        return false, reason
    end
    
    local technology = tech.technologies[tech_id]
    local player_tech = tech.get_player_research(player_name)
    local player = minetest.get_player_by_name(player_name)
    
    -- Consume research items
    for item, count in pairs(technology.cost) do
        local player_inv = player:get_inventory()
        player_inv:remove_item("main", ItemStack(item .. " " .. count))
    end
    
    -- Mark as researched
    player_tech.researched[tech_id] = true
    player_tech.research_points = player_tech.research_points + 1
    
    -- Unlock recipes
    if technology.unlocks.recipes then
        for _, recipe in ipairs(technology.unlocks.recipes) do
            -- This would integrate with the crafting system
            minetest.log("action", "[ws_tech] Unlocked recipe: " .. recipe .. " for " .. player_name)
        end
    end
    
    -- Grant starter items
    if technology.unlocks.items then
        local player_inv = player:get_inventory()
        for _, item in ipairs(technology.unlocks.items) do
            if player_inv:room_for_item("main", ItemStack(item)) then
                player_inv:add_item("main", ItemStack(item))
            end
        end
    end
    
    -- Show research complete message
    minetest.chat_send_player(player_name, "#55FF55 Research Complete: " .. technology.name)
    
    -- Achievement integration
    if minetest.get_modpath("ws_achievements") then
        if not ws_achievements.has_achievement(player_name, "first_research") then
            ws_achievements.grant_achievement(player_name, "first_research")
        end
    end
    
    return true, "Research successful"
end

-- Research table node
minetest.register_node("ws_tech:research_table", {
    description = "Research Table\nUsed to unlock new technologies",
    tiles = {"ws_tech_research_table_top.png", "ws_tech_research_table_bottom.png", 
             "ws_tech_research_table_side.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 1},
    ---#FIXME
    sounds = ((rawget(_G, "default") and default.node_sound_wood_defaults()) or {}),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        tech.show_research_gui(player_name)
    end,
})

-- Research GUI
function tech.show_research_gui(player_name)
    local player_tech = tech.get_player_research(player_name)
    local formspec = "size[12,10]" ..
        "bgcolor[#1E1E1E;false]" ..
        "label[0.5,0.5;" .. minetest.colorize("#FFFFFF", "Technology Research") .. "]" ..
        "label[10,0.5;" .. minetest.colorize("#FFFF00", "Research Points: " .. player_tech.research_points) .. "]" ..
        "textlist[0.5,1;2.5,8;categories;"
    
    -- Add categories
    for category_id, category in pairs(tech.research_categories) do
        formspec = formspec .. category.name .. ","
    end
    formspec = formspec .. "]" ..
        "textlist[3,1;8.5,8;technologies;"
    
    -- Add technologies for selected category (default: survival)
    local tech_count = 0
    for tech_id, technology in pairs(tech.technologies) do
        if technology.category == "survival" then
            local status = player_tech.researched[tech_id] and "✓ " or "○ "
            local cost_text = ""
            for item, count in pairs(technology.cost) do
                cost_text = cost_text .. count .. " " .. minetest.registered_items[item].description .. ", "
            end
            formspec = formspec .. status .. technology.name .. " - " .. technology.description .. " (Cost: " .. cost_text:sub(1, -3) .. ")" .. ","
            tech_count = tech_count + 1
        end
    end
    
    if tech_count == 0 then
        formspec = formspec .. "No technologies available in this category,"
    end
    
    formspec = formspec .. "]" ..
        "button[8.5,9;3,0.5;research;Research Selected]" ..
        "button_exit[0.5,9;3,0.5;close;Close]"
    
    minetest.show_formspec(player_name, "ws_tech:research", formspec)
end

-- Handle research GUI events
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ws_tech:research" then return end
    
    local player_name = player:get_player_name()
    
    if fields.research then
        -- This would research the selected technology
        -- Implementation depends on your GUI selection system
        minetest.chat_send_player(player_name, "#FFFF00 Select a technology from the list first")
    end
    
    return true
end)

-- Crafting recipes
minetest.register_craft({
    output = "ws_tech:research_table",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:stick", "", "default:stick"},
        {"default:stone", "default:stone", "default:stone"}
    }
})

-- Research point items
minetest.register_craftitem("ws_tech:research_data", {
    description = "Research Data\nUsed for technology research",
    inventory_image = "ws_tech_research_data.png",
    groups = {research_material = 1},
})

-- Generate research data from certain actions
minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger then return end
    
    local player_name = digger:get_player_name()
    local node_name = oldnode.name
    
    -- Research data from certain nodes
    local research_nodes = {
        ["default:bookshelf"] = 0.3, -- 30% chance
        ["default:chest"] = 0.2,
        ["default:furnace"] = 0.4,
    }
    
    if research_nodes[node_name] and math.random() < research_nodes[node_name] then
        local player = minetest.get_player_by_name(player_name)
        local inv = player:get_inventory()
        if inv:room_for_item("main", ItemStack("ws_tech:research_data")) then
            inv:add_item("main", ItemStack("ws_tech:research_data"))
            minetest.chat_send_player(player_name, "#55FFFF Found research data!")
        end
    end
end)

-- Player management
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    tech.get_player_research(player_name) -- Initialize research data
end)

-- ws_achievements integration
if minetest.get_modpath("ws_achievements") then
    ws_achievements.register_achievement("first_research", {
        title = "Mad Scientist",
        description = "Research your first technology",
        category = "crafting",
        icon = "ws_achievements_research.png"
    })
    
    ws_achievements.register_achievement("tech_master", {
        title = "Tech Master",
        description = "Research 10 different technologies",
        category = "crafting", 
        icon = "ws_achievements_tech_master.png"
    })
end

-- Journal integration  
if minetest.get_modpath("ws_story") then
    local triggers = journal.require("triggers")
    
    triggers.register_on_craft({
        target = "ws_tech:research_table",
        id = "ws_tech:research_discovery",
        call_once = true,
        call = function(data)
            local entries = journal.require("entries")
            entries.add_entry(data.playerName, "ws_story:survivor",
                "Built a research table today. Maybe I can rediscover some of the old technology " ..
                "and make life here more bearable. Those research documents I've been finding might actually be useful now.", true)
        end,
    })
end

minetest.log("action", "[ws_tech] Technology tree loaded with " .. 
    #tech.technologies .. " technologies")
