-- ws_achievements: Achievement system for Wastelands Survival
-- Compatible with ws_story journal system

local achievements = {}
achievements.registered_achievements = {}
achievements.player_achievements = {}
achievements.active_displays = {}

-- Achievement categories
achievements.categories = {
    survival = {name = "Survival", color = "#FF6B35"},
    crafting = {name = "Crafting", color = "#4ECDC4"},
    exploration = {name = "Exploration", color = "#45B7D1"},
    combat = {name = "Combat", color = "#FF6384"},
    story = {name = "Story", color = "#A05195"}
}

-- Register achievement
function achievements.register_achievement(id, def)
    def.id = id
    def.players = def.players or {}
    achievements.registered_achievements[id] = def
end

-- Grant achievement to player
function achievements.grant_achievement(player_name, achievement_id)
    if not achievements.registered_achievements[achievement_id] then
        minetest.log("warning", "[ws_achievements] Attempted to grant unknown achievement: " .. achievement_id)
        return false
    end
    
    achievements.player_achievements[player_name] = achievements.player_achievements[player_name] or {}
    
    if not achievements.player_achievements[player_name][achievement_id] then
        achievements.player_achievements[player_name][achievement_id] = {
            unlocked = true,
            timestamp = os.time()
        }
        
        -- Show achievement notification
        achievements.show_achievement(player_name, achievement_id)
        
        -- Add to journal if story achievement
        local achievement = achievements.registered_achievements[achievement_id]
        if achievement.category == "story" and minetest.get_modpath("ws_story") then
            local entries = journal.require("entries")
            entries.add_entry(player_name, "ws_story:survivor",
                "Achievement Unlocked: " .. achievement.title .. " - " .. achievement.description, true)
        end
        
        minetest.log("action", "[ws_achievements] " .. player_name .. " unlocked achievement: " .. achievement_id)
        return true
    end
    return false
end

-- Check if player has achievement
function achievements.has_achievement(player_name, achievement_id)
    return achievements.player_achievements[player_name] and 
           achievements.player_achievements[player_name][achievement_id]
end

-- Show achievement notification
function achievements.show_achievement(player_name, achievement_id)
    local achievement = achievements.registered_achievements[achievement_id]
    if not achievement then return end
    
    local player = minetest.get_player_by_name(player_name)
    if not player then return end
    
    -- Create formspec for achievement notification
    local formspec = "size[8,3.5]" ..
        "bgcolor[#1E1E1E;false]" ..
        "background9[0,0;8,3.5;ws_achievements_bg.png;false;10]" ..
        "image[0.5,0.5;2,2;" .. (achievement.icon or "ws_achievements_unknown.png") .. "]" ..
        "label[2.5,0.7;" .. minetest.colorize(achievements.categories[achievement.category].color, "Achievement Unlocked!") .. "]" ..
        "label[2.5,1.3;" .. minetest.colorize("#FFFFFF", achievement.title) .. "]" ..
        "textarea[2.5,1.7;5,1.5;;" .. minetest.formspec_escape(achievement.description) .. ";]" ..
        "button_exit[3,2.8;2,0.5;close;Awesome!]"
    
    minetest.show_formspec(player_name, "ws_achievements:notification_" .. achievement_id, formspec)
    
    -- Auto-close after 5 seconds
    minetest.after(5, function()
        achievements.hide_achievement(player_name, achievement_id)
    end)
end

-- Hide achievement notification
function achievements.hide_achievement(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if player then
        minetest.close_formspec(player_name, "ws_achievements:notification_" .. achievement_id)
    end
end

-- Achievement list GUI
function achievements.show_achievement_list(player_name)
    local player_achievements = achievements.player_achievements[player_name] or {}
    local formspec = "size[10,9]" ..
        "bgcolor[#1E1E1E;false]" ..
        "background9[0,0;10,9;ws_achievements_bg.png;false;10]" ..
        "label[0.5,0.5;" .. minetest.colorize("#FFFFFF", "Wastelands Survival Achievements") .. "]" ..
        "textlist[0.5,1;9,7.5;achievement_list;"
    
    -- Build achievement list
    local achievement_count = 0
    local unlocked_count = 0
    
    for category_id, category in pairs(achievements.categories) do
        formspec = formspec .. minetest.colorize(category.color, "--- " .. category.name .. " ---,")
        achievement_count = achievement_count + 1
        
        for achievement_id, achievement in pairs(achievements.registered_achievements) do
            if achievement.category == category_id then
                local status = achievements.has_achievement(player_name, achievement_id) and "✓ " or "○ "
                local entry = status .. achievement.title
                if achievements.has_achievement(player_name, achievement_id) then
                    entry = entry .. " - " .. achievement.description
                    unlocked_count = unlocked_count + 1
                else
                    entry = entry .. " - ???"
                end
                formspec = formspec .. minetest.formspec_escape(entry) .. ","
                achievement_count = achievement_count + 1
            end
        end
    end
    
    formspec = formspec .. "]" ..
        "label[0.5,8.5;" .. minetest.colorize("#FFFFFF", "Progress: " .. unlocked_count .. "/" .. achievement_count .. " achievements unlocked") .. "]" ..
        "button_exit[8,8.5;2,0.5;close;Close]"
    
    minetest.show_formspec(player_name, "ws_achievements:list", formspec)
end

-- Register achievements
achievements.register_achievement("first_steps", {
    title = "First Steps",
    description = "Survive your first day in the wasteland",
    category = "survival",
    icon = "ws_achievements_first_steps.png"
})

achievements.register_achievement("journal_finder", {
    title = "Chronicler",
    description = "Discover the survivor's journal",
    category = "story",
    icon = "ws_achievements_journal.png"
})

achievements.register_achievement("crafting_master", {
    title = "Crafting Apprentice",
    description = "Craft your first crafting table",
    category = "crafting",
    icon = "ws_achievements_crafting.png"
})

achievements.register_achievement("water_collector", {
    title = "Water Collector",
    description = "Craft your first dew collector barrel",
    category = "survival",
    icon = "ws_achievements_water.png"
})

achievements.register_achievement("first_shelter", {
    title = "Homesteader",
    description = "Place your first door",
    category = "survival",
    icon = "ws_achievements_shelter.png"
})

achievements.register_achievement("ore_miner", {
    title = "Ore Miner",
    description = "Mine your first valuable ore",
    category = "crafting",
    icon = "ws_achievements_mining.png"
})

achievements.register_achievement("monster_slayer", {
    title = "Monster Slayer",
    description = "Defeat your first hostile creature",
    category = "combat",
    icon = "ws_achievements_combat.png"
})

achievements.register_achievement("explorer", {
    title = "Explorer",
    description = "Discover 5 different landmarks",
    category = "exploration",
    icon = "ws_achievements_exploration.png"
})

achievements.register_achievement("chef", {
    title = "Chef",
    description = "Cook your first proper meal",
    category = "survival",
    icon = "ws_achievements_cooking.png"
})

achievements.register_achievement("master_survivor", {
    title = "Master Survivor",
    description = "Survive for 10 in-game days",
    category = "survival",
    icon = "ws_achievements_master.png"
})

-- Integration with ws_story triggers
if minetest.get_modpath("ws_story") then
    local triggers = journal.require("triggers")
    
    -- Journal discovery
    triggers.register_on_join({
        id = "ws_achievements:journal",
        call_once = true,
        call = function(data)
            minetest.after(2, function()
                achievements.grant_achievement(data.playerName, "journal_finder")
            end)
        end,
    })
    
    -- Crafting table
    triggers.register_on_craft({
        target = "crafting:crafting_table",
        id = "ws_achievements:crafting_table",
        call_once = true,
        call = function(data)
            achievements.grant_achievement(data.playerName, "crafting_master")
        end,
    })
    
    -- Dew collector
    triggers.register_on_craft({
        target = "dewcollector:barrel_closed",
        id = "ws_achievements:dew_collector",
        call_once = true,
        call = function(data)
            achievements.grant_achievement(data.playerName, "water_collector")
        end,
    })
    
    -- First door
    triggers.register_on_place({
        target = {"group:door", "group:gate"},
        id = "ws_achievements:first_door",
        call_once = true,
        call = function(data)
            achievements.grant_achievement(data.playerName, "first_shelter")
        end,
    })
end

-- Day survival tracking
local player_days = {}
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local time_of_day = minetest.get_timeofday()
        
        -- Check for new day (time resets near 0)
        if time_of_day < 0.1 and not player_days[player_name] then
            player_days[player_name] = true
            
            -- Grant first steps achievement after first day/night cycle
            if not achievements.has_achievement(player_name, "first_steps") then
                achievements.grant_achievement(player_name, "first_steps")
            end
        elseif time_of_day > 0.5 then
            player_days[player_name] = false
        end
    end
end)

-- Ore mining detection
minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger then return end
    local player_name = digger:get_player_name()
    
    local ores = {
        ["default:stone_with_iron"] = "ore_miner",
        ["default:stone_with_copper"] = "ore_miner",
        ["default:stone_with_gold"] = "ore_miner",
        ["default:stone_with_diamond"] = "ore_miner",
    }
    
    if ores[oldnode.name] and not achievements.has_achievement(player_name, "ore_miner") then
        achievements.grant_achievement(player_name, "ore_miner")
    end
end)

-- Monster slayer detection
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if hitter and hitter:is_player() and damage > 0 then
        local entity = player:get_luaentity()
        if entity and entity.name:find("mobs:") then
            local player_name = hitter:get_player_name()
            if not achievements.has_achievement(player_name, "monster_slayer") then
                achievements.grant_achievement(player_name, "monster_slayer")
            end
        end
    end
end)

-- Cooking achievement
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if player then
        local player_name = player:get_player_name()
        local cooked_foods = {
            "farming:bread",
            "mobs:meat",
            "mobs:fish",
        }
        
        for _, food in ipairs(cooked_foods) do
            if itemstack:get_name() == food and not achievements.has_achievement(player_name, "chef") then
                achievements.grant_achievement(player_name, "chef")
                break
            end
        end
    end
end)

-- Chat command to view achievements
minetest.register_chatcommand("achievements", {
    description = "View your unlocked achievements",
    func = function(name, param)
        achievements.show_achievement_list(name)
        return true
    end,
})

-- Cleanup on player leave
minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    player_days[player_name] = nil
end)

-- Register achievements as a global table
ws_achievements = achievements

minetest.log("action", "[ws_achievements] Achievement system loaded with " .. 
    #achievements.registered_achievements .. " achievements")
