-- ws_ruins: Ruin building functions for Wastelands Survival
-- Manual generation system - call functions to build specific ruins

local ruins = {}
ruins.registered_ruins = {}
ruins.building_materials = {}

-- Building material definitions
ruins.building_materials = {
    wood = {
        walls = {"default:wood", "default:tree", "default:junglewood"},
        damaged_walls = {"default:wood", "default:wood", "default:wood", "air"},
        floors = {"default:wood", "default:wood", "default:wood", "default:dirt"},
        roofs = {"default:wood", "default:wood", "default:leaves"},
        debris = {"default:stick", "default:wood", "default:sapling", "air"}
    },
    stone = {
        walls = {"default:stone", "default:cobble", "default:stonebrick"},
        damaged_walls = {"default:stone", "default:cobble", "default:stone", "air"},
        floors = {"default:stone", "default:cobble", "default:gravel"},
        roofs = {"default:stone", "default:cobble", "air"},
        debris = {"default:cobble", "default:gravel", "default:stone", "air"}
    },
    brick = {
        walls = {"default:brick", "default:stonebrick"},
        damaged_walls = {"default:brick", "default:stonebrick", "default:cobble", "air"},
        floors = {"default:brick", "default:stone", "default:clay"},
        roofs = {"default:brick", "default:stone", "air"},
        debris = {"default:brick", "default:clay_lump", "default:stone", "air"}
    }
}

-- Core building function
function ruins.build_structure(pos, structure_def)
    local placed_nodes = 0
    
    for _, part in ipairs(structure_def.parts) do
        for x = part.area.min.x, part.area.max.x do
            for y = part.area.min.y, part.area.max.y do
                for z = part.area.min.z, part.area.max.z do
                    local node_pos = vector.add(pos, {x = x, y = y, z = z})
                    
                    -- Only place node if it's not air in the definition
                    if part.node ~= "air" then
                        -- Add some randomness for damaged structures
                        if math.random(1, 100) <= part.damage_chance or part.damage_chance == 100 then
                            minetest.set_node(node_pos, {name = part.node})
                            placed_nodes = placed_nodes + 1
                        else
                            minetest.set_node(node_pos, {name = "air"})
                        end
                    else
                        minetest.set_node(node_pos, {name = "air"})
                    end
                end
            end
        end
    end
    
    return placed_nodes
end

-- Add loot to a structure
function ruins.add_loot(pos, loot_def)
    local chest_pos = vector.add(pos, loot_def.chest_offset)
    
    -- Place chest
    minetest.set_node(chest_pos, {name = "default:chest"})
    
    -- Get chest metadata and add items
    local meta = minetest.get_meta(chest_pos)
    local inv = meta:get_inventory()
    inv:set_list("main", {})
    
    for _, loot_item in ipairs(loot_def.items) do
        if math.random(1, 100) <= loot_item.chance then
            local stack = ItemStack(loot_item.name .. " " .. math.random(loot_item.min_count, loot_item.max_count))
            if inv:room_for_item("main", stack) then
                inv:add_item("main", stack)
            end
        end
    end
    
    -- Set chest description
    meta:set_string("infotext", loot_def.description or "Abandoned Chest")
end

-- Generate debris around a structure
function ruins.add_debris(pos, debris_def)
    local debris_nodes = 0
    
    for x = -debris_def.radius, debris_def.radius do
        for z = -debris_def.radius, debris_def.radius do
            if math.random(1, 100) <= debris_def.density then
                local debris_pos = {
                    x = pos.x + x,
                    y = pos.y + debris_def.y_offset,
                    z = pos.z + z
                }
                
                local node_name = debris_def.materials[math.random(1, #debris_def.materials)]
                if node_name ~= "air" then
                    minetest.set_node(debris_pos, {name = node_name})
                    debris_nodes = debris_nodes + 1
                end
            end
        end
    end
    
    return debris_nodes
end

-- Specific ruin building functions

function ruins.build_small_house(pos, material_type)
    material_type = material_type or "wood"
    local materials = ruins.building_materials[material_type] or ruins.building_materials.wood
    
    local structure_def = {
        parts = {
            -- Floor (5x5)
            {
                area = {min = {x = -2, y = 0, z = -2}, max = {x = 2, y = 0, z = 2}},
                node = materials.floors[1],
                damage_chance = 10
            },
            -- Walls
            {
                area = {min = {x = -2, y = 1, z = -2}, max = {x = 2, y = 3, z = -2}},
                node = materials.walls[1],
                damage_chance = 40
            },
            {
                area = {min = {x = -2, y = 1, z = 2}, max = {x = 2, y = 3, z = 2}},
                node = materials.walls[1],
                damage_chance = 40
            },
            {
                area = {min = {x = -2, y = 1, z = -1}, max = {x = -2, y = 3, z = 1}},
                node = materials.walls[1],
                damage_chance = 40
            },
            {
                area = {min = {x = 2, y = 1, z = -1}, max = {x = 2, y = 3, z = 1}},
                node = materials.walls[1],
                damage_chance = 40
            },
            -- Doorway (always damaged)
            {
                area = {min = {x = 0, y = 1, z = 2}, max = {x = 0, y = 2, z = 2}},
                node = "air",
                damage_chance = 100
            },
            -- Roof (partially collapsed)
            {
                area = {min = {x = -2, y = 4, z = -2}, max = {x = 2, y = 4, z = 2}},
                node = materials.roofs[1],
                damage_chance = 70
            }
        }
    }
    
    local nodes_placed = ruins.build_structure(pos, structure_def)
    
    -- Add debris
    ruins.add_debris(pos, {
        materials = materials.debris,
        radius = 4,
        density = 30,
        y_offset = 0
    })
    
    -- Add loot chest
    ruins.add_loot(pos, {
        chest_offset = {x = 0, y = 1, z = 0},
        items = {
            {name = "default:stick", chance = 80, min_count = 1, max_count = 5},
            {name = "default:wood", chance = 60, min_count = 1, max_count = 3},
            {name = "farming:bread", chance = 40, min_count = 1, max_count = 2},
            {name = "default:apple", chance = 30, min_count = 1, max_count = 3}
        },
        description = "Abandoned House Chest"
    })
    
    return nodes_placed
end

function ruins.build_guard_tower(pos)
    local structure_def = {
        parts = {
            -- Foundation
            {
                area = {min = {x = -1, y = 0, z = -1}, max = {x = 1, y = 0, z = 1}},
                node = "default:stone",
                damage_chance = 5
            },
            -- Tower base
            {
                area = {min = {x = -1, y = 1, z = -1}, max = {x = 1, y = 8, z = 1}},
                node = "default:stone",
                damage_chance = 20
            },
            -- Platform
            {
                area = {min = {x = -2, y = 9, z = -2}, max = {x = 2, y = 9, z = 2}},
                node = "default:wood",
                damage_chance = 60
            },
            -- Railings (partially broken)
            {
                area = {min = {x = -2, y = 10, z = -2}, max = {x = 2, y = 10, z = -2}},
                node = "default:fence_wood",
                damage_chance = 80
            },
            {
                area = {min = {x = -2, y = 10, z = 2}, max = {x = 2, y = 10, z = 2}},
                node = "default:fence_wood",
                damage_chance = 80
            },
            {
                area = {min = {x = -2, y = 10, z = -1}, max = {x = -2, y = 10, z = 1}},
                node = "default:fence_wood",
                damage_chance = 80
            },
            {
                area = {min = {x = 2, y = 10, z = -1}, max = {x = 2, y = 10, z = 1}},
                node = "default:fence_wood",
                damage_chance = 80
            },
            -- Ladder shaft
            {
                area = {min = {x = 0, y = 1, z = 0}, max = {x = 0, y = 8, z = 0}},
                node = "air",
                damage_chance = 100
            }
        }
    }
    
    local nodes_placed = ruins.build_structure(pos, structure_def)
    
    -- Add ladder remains
    for y = 1, 8 do
        if math.random(1, 100) <= 40 then -- 40% chance for each ladder segment
            local ladder_pos = vector.add(pos, {x = 0, y = y, z = 1})
            minetest.set_node(ladder_pos, {name = "default:ladder", param2 = 2})
        end
    end
    
    -- Add debris
    ruins.add_debris(pos, {
        materials = {"default:cobble", "default:gravel", "default:stick", "air"},
        radius = 3,
        density = 40,
        y_offset = 0
    })
    
    -- Add loot chest at top
    ruins.add_loot(vector.add(pos, {x = 0, y = 9, z = 0}), {
        items = {
            {name = "default:steel_ingot", chance = 70, min_count = 1, max_count = 3},
            {name = "default:pick_steel", chance = 30, min_count = 1, max_count = 1},
            {name = "default:apple", chance = 50, min_count = 1, max_count = 2}
        },
        description = "Guard Tower Chest"
    })
    
    return nodes_placed
end

function ruins.build_bunker(pos)
    local structure_def = {
        parts = {
            -- Bunker entrance (partially collapsed)
            {
                area = {min = {x = -2, y = 0, z = -2}, max = {x = 2, y = 1, z = 2}},
                node = "default:stone",
                damage_chance = 30
            },
            -- Entrance hallway
            {
                area = {min = {x = -1, y = -1, z = 2}, max = {x = 1, y = -1, z = 4}},
                node = "default:stone",
                damage_chance = 20
            },
            -- Main room
            {
                area = {min = {x = -3, y = -1, z = 5}, max = {x = 3, y = -1, z = 8}},
                node = "default:stone",
                damage_chance = 10
            },
            -- Room walls
            {
                area = {min = {x = -3, y = 0, z = 5}, max = {x = 3, y = 2, z = 5}},
                node = "default:stone",
                damage_chance = 15
            },
            {
                area = {min = {x = -3, y = 0, z = 8}, max = {x = 3, y = 2, z = 8}},
                node = "default:stone",
                damage_chance = 15
            },
            {
                area = {min = {x = -3, y = 0, z = 6}, max = {x = -3, y = 2, z = 7}},
                node = "default:stone",
                damage_chance = 15
            },
            {
                area = {min = {x = 3, y = 0, z = 6}, max = {x = 3, y = 2, z = 7}},
                node = "default:stone",
                damage_chance = 15
            },
            -- Ceiling (partially collapsed)
            {
                area = {min = {x = -3, y = 3, z = 5}, max = {x = 3, y = 3, z = 8}},
                node = "default:stone",
                damage_chance = 50
            }
        }
    }
    
    local nodes_placed = ruins.build_structure(pos, structure_def)
    
    -- Clear interior space
    local interior_nodes = {
        {min = {x = -2, y = 0, z = 6}, max = {x = 2, y = 2, z = 7}}
    }
    
    for _, area in ipairs(interior_nodes) do
        for x = area.min.x, area.max.x do
            for y = area.min.y, area.max.y do
                for z = area.min.z, area.max.z do
                    local node_pos = vector.add(pos, {x = x, y = y, z = z})
                    minetest.set_node(node_pos, {name = "air"})
                end
            end
        end
    end
    
    -- Add bunker debris
    ruins.add_debris(pos, {
        materials = {"default:stone", "default:cobble", "default:steelblock", "air"},
        radius = 5,
        density = 25,
        y_offset = 0
    })
    
    -- Add multiple loot chests
    ruins.add_loot(vector.add(pos, {x = -1, y = 0, z = 6}), {
        items = {
            {name = "default:steel_ingot", chance = 90, min_count = 2, max_count = 8},
            {name = "default:coal_lump", chance = 80, min_count = 3, max_count = 12},
            {name = "default:pick_steel", chance = 40, min_count = 1, max_count = 1}
        },
        description = "Bunker Storage"
    })
    
    ruins.add_loot(vector.add(pos, {x = 1, y = 0, z = 7}), {
        items = {
            {name = "farming:bread", chance = 70, min_count = 2, max_count = 5},
            {name = "default:apple", chance = 60, min_count = 1, max_count = 4},
            {name = "bucket:bucket_water", chance = 30, min_count = 1, max_count = 1}
        },
        description = "Bunker Supplies"
    })
    
    return nodes_placed
end

function ruins.build_farmhouse(pos)
    local structure_def = {
        parts = {
            -- Main house floor
            {
                area = {min = {x = -3, y = 0, z = -3}, max = {x = 3, y = 0, z = 3}},
                node = "default:wood",
                damage_chance = 15
            },
            -- House walls
            {
                area = {min = {x = -3, y = 1, z = -3}, max = {x = 3, y = 3, z = -3}},
                node = "default:wood",
                damage_chance = 50
            },
            {
                area = {min = {x = -3, y = 1, z = 3}, max = {x = 3, y = 3, z = 3}},
                node = "default:wood",
                damage_chance = 50
            },
            {
                area = {min = {x = -3, y = 1, z = -2}, max = {x = -3, y = 3, z = 2}},
                node = "default:wood",
                damage_chance = 50
            },
            {
                area = {min = {x = 3, y = 1, z = -2}, max = {x = 3, y = 3, z = 2}},
                node = "default:wood",
                damage_chance = 50
            },
            -- Barn section
            {
                area = {min = {x = -5, y = 0, z = 4}, max = {x = 5, y = 0, z = 8}},
                node = "default:dirt",
                damage_chance = 10
            },
            -- Barn walls (more damaged)
            {
                area = {min = {x = -5, y = 1, z = 4}, max = {x = 5, y = 3, z = 4}},
                node = "default:wood",
                damage_chance = 70
            },
            {
                area = {min = {x = -5, y = 1, z = 8}, max = {x = 5, y = 3, z = 8}},
                node = "default:wood",
                damage_chance = 70
            },
            {
                area = {min = {x = -5, y = 1, z = 5}, max = {x = -5, y = 3, z = 7}},
                node = "default:wood",
                damage_chance = 70
            },
            {
                area = {min = {x = 5, y = 1, z = 5}, max = {x = 5, y = 3, z = 7}},
                node = "default:wood",
                damage_chance = 70
            }
        }
    }
    
    local nodes_placed = ruins.build_structure(pos, structure_def)
    
    -- Add farm debris
    ruins.add_debris(pos, {
        materials = {"default:wood", "default:stick", "farming:wheat", "default:dirt", "air"},
        radius = 8,
        density = 35,
        y_offset = 0
    })
    
    -- Add farming loot
    ruins.add_loot(vector.add(pos, {x = 0, y = 1, z = 0}), {
        items = {
            {name = "farming:seed_wheat", chance = 90, min_count = 3, max_count = 12},
            {name = "farming:hoe_steel", chance = 50, min_count = 1, max_count = 1},
            {name = "farming:bread", chance = 70, min_count = 1, max_count = 4},
            {name = "bucket:bucket_water", chance = 40, min_count = 1, max_count = 1}
        },
        description = "Farmhouse Supplies"
    })
    
    return nodes_placed
end

function ruins.build_radio_tower(pos)
    local structure_def = {
        parts = {
            -- Tower base
            {
                area = {min = {x = -1, y = 0, z = -1}, max = {x = 1, y = 0, z = 1}},
                node = "default:steelblock",
                damage_chance = 5
            },
            -- Tower segments
            {
                area = {min = {x = -1, y = 1, z = -1}, max = {x = 1, y = 15, z = 1}},
                node = "default:steelblock",
                damage_chance = 25
            },
            -- Platform
            {
                area = {min = {x = -2, y = 16, z = -2}, max = {x = 2, y = 16, z = 2}},
                node = "default:steelblock",
                damage_chance = 40
            },
            -- Antenna base
            {
                area = {min = {x = 0, y = 17, z = 0}, max = {x = 0, y = 20, z = 0}},
                node = "default:steelblock",
                damage_chance = 60
            },
            -- Antenna (broken)
            {
                area = {min = {x = 0, y = 21, z = 0}, max = {x = 0, y = 22, z = 0}},
                node = "default:steelblock",
                damage_chance = 90
            }
        }
    }
    
    local nodes_placed = ruins.build_structure(pos, structure_def)
    
    -- Add equipment hut
    local hut_pos = vector.add(pos, {x = 4, y = 0, z = 0})
    minetest.set_node(hut_pos, {name = "default:steelblock"})
    minetest.set_node(vector.add(hut_pos, {x = 0, y = 1, z = 0}), {name = "default:steelblock"})
    minetest.set_node(vector.add(hut_pos, {x = 1, y = 0, z = 0}), {name = "default:steelblock"})
    minetest.set_node(vector.add(hut_pos, {x = 0, y = 0, z = 1}), {name = "default:steelblock"})
    
    -- Add technical loot
    ruins.add_loot(vector.add(hut_pos, {x = 0, y = 1, z = 0}), {
        items = {
            {name = "default:steel_ingot", chance = 95, min_count = 5, max_count = 15},
            {name = "default:copper_ingot", chance = 80, min_count = 3, max_count = 10},
            {name = "default:mese_crystal", chance = 30, min_count = 1, max_count = 2},
            {name = "ws_tech:research_data", chance = 70, min_count = 1, max_count = 3}
        },
        description = "Radio Tower Equipment"
    })
    
    return nodes_placed
end

-- API functions for other mods to use
function ruins.build_ruin(ruin_type, pos, options)
    options = options or {}
    
    local ruin_functions = {
        small_house = ruins.build_small_house,
        guard_tower = ruins.build_guard_tower,
        bunker = ruins.build_bunker,
        farmhouse = ruins.build_farmhouse,
        radio_tower = ruins.build_radio_tower
    }
    
    if ruin_functions[ruin_type] then
        return ruin_functions[ruin_type](pos, options.material)
    else
        minetest.log("error", "[ws_ruins] Unknown ruin type: " .. ruin_type)
        return 0
    end
end

-- Chat commands for testing/administration
minetest.register_chatcommand("build_ruin", {
    params = "<type> [material]",
    description = "Build a ruin at your position. Types: small_house, guard_tower, bunker, farmhouse, radio_tower",
    func = function(name, param)
        local params = param:split(" ")
        local ruin_type = params[1]
        local material = params[2]
        
        if not ruin_type then
            return false, "Please specify a ruin type"
        end
        
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end
        
        local pos = player:get_pos()
        pos = vector.round(pos)
        
        local options = {}
        if material then
            options.material = material
        end
        
        local nodes_placed = ruins.build_ruin(ruin_type, pos, options)
        
        return true, "Built " .. ruin_type .. " with " .. nodes_placed .. " nodes at " .. minetest.pos_to_string(pos)
    end
})

-- Achievement integration
if minetest.get_modpath("ws_achievements") then
    ws_achievements.register_achievement("ruin_explorer", {
        title = "Ruin Explorer",
        description = "Discover and explore 5 different ruins",
        category = "exploration",
        icon = "ws_achievements_ruins.png"
    })
    
    ws_achievements.register_achievement("treasure_hunter", {
        title = "Treasure Hunter", 
        description = "Find loot in 10 different ruin chests",
        category = "exploration",
        icon = "ws_achievements_treasure.png"
    })
end

-- Journal integration
if minetest.get_modpath("ws_story") then
    local triggers = journal.require("triggers")
    
    -- This would be called when a player first discovers a ruin
    function ruins.on_ruin_discovery(player_name, ruin_type)
        local entries = journal.require("entries")
        
        local discovery_messages = {
            small_house = "Found an old house today. The previous owners left in a hurry - most of their stuff is still here. Maybe I can find something useful.",
            guard_tower = "Came across an old watchtower. Good vantage point, but it's seen better days. Found some supplies left by the guards.",
            bunker = "Discovered a hidden bunker! This must have been someone's survival shelter. Lots of useful materials inside.",
            farmhouse = "An abandoned farm. The fields are dead now, but the old tools might still be useful.",
            radio_tower = "Found a radio tower! The equipment is mostly broken, but there might be some valuable components left."
        }
        
        local message = discovery_messages[ruin_type] or "Found some ruins today. Another reminder of what was lost."
        entries.add_entry(player_name, "ws_story:survivor", message, true)
        
        -- Grant achievement progress
        if minetest.get_modpath("ws_achievements") then
            -- Track ruin discoveries for achievement
            -- Implementation depends on your tracking system
        end
    end
end

minetest.log("action", "[ws_ruins] Ruin building system loaded")

-- Make API available globally
ws_ruins = ruins
