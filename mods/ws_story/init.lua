local entries = journal.require("entries")
local triggers = journal.require("triggers")

entries.register_page("ws_story:survivor", "Survivor's Log", "A tale of the last survivors in this world")

-- Function to check if creative mode is enabled for the player
local function is_creative_enabled_for(player_name)
    if minetest.get_modpath("creative") then
        return creative.is_enabled_for(player_name)
    else
        return false
    end
end

-- Creative mode trigger
triggers.register_on_join({
    id = "ws_story:creative",
    call_once = true,
    is_active = function(player_name)
        return is_creative_enabled_for(player_name)
    end,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "--- In creative mode the story " ..
            "of Wastelands Survival may lose its consistency. ---", false)
    end,
})

-- Add entry symbolizing a new owner when a player spawns
local function find_journal(player_name)
    entries.add_entry(player_name, "ws_story:survivor",
        "Today I found this old journal. " ..
        "Poor bastard who left this behind... I guess I'll just write a bit about my own life into this. " ..
        "Today even my last rations came to an end. Will I be the next victim of these wastelands?", true)
end

-- Write first entry when joining
triggers.register_on_join({
    id = "ws_story:start",
    call_once = true,
    call = function(data)
        find_journal(data.playerName)
        -- The plot
        minetest.after(10, entries.add_entry, data.playerName, "ws_story:survivor",
            "But first let me explain what happened: Robbers stole a secret formula from the military, a bio weapon. " ..
            "On their flight, it got dropped into some water and quickly spread into the oceans. " ..
            "A while later this killed the whole planet; food and clean water became too rare for humans to survive. " ..
            "Now me and perhaps a small group of other survivors live in these wastelands.", false)
        minetest.after(20, entries.add_entry, data.playerName, "ws_story:survivor",
            "Also, there are ogres and other evil critters. " ..
            "They were formed by all sorts of animals and also humans who suffered from the toxic water.", false)
        minetest.after(30, entries.add_entry, data.playerName, "ws_story:survivor",
            "I have to survive somehow. I'll need something to craft other than my hands. " ..
            "If I had a wooden table to put the stuff on, that would make things easier.", false)
    end,
})

-- Entry when dying, somebody else continues the journal
triggers.register_on_die(function(data)
    find_journal(data.playerName)
end)

-- Wood breaks into pieces if you don't cut it
triggers.register_on_dig({
    target = {"group:tree", "group:wood"},
    id = "ws_story:treepunch",
    call_once = true,
    call = function(data)
        if minetest.get_item_group(data.tool, "hatchet") == 0 and minetest.get_item_group(data.tool, "axe") == 0 then
            entries.add_entry(data.playerName, "ws_story:survivor",
                "Ouch, just hitting wood won't do. I guess I need a hatchet or an axe.", true)
        end
    end
})

-- Craft wood blocks from multiple stairs
triggers.register_on_dig({
    target = {"group:stair"},
    id = "ws_story:staircombine",
    call_once = true,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "I get all these broken planks from the ruins... Maybe I can combine them back into full walls.", true)
    end
})

-- Crafting table
triggers.register_on_craft({
    target = "crafting:crafting_table",
    id = "ws_story:crafting_table",
    call_once = true,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "I've got the crafting table. Now I need something against the unbearable thirst. " ..
            "If I remember correctly you can collect dew in a wooden barrel that has a plastic sheet on top instead of a wooden lid." ..
            "\n--- The dew barrel is currently craftable without plastic sheeting ---", true)
    end,
})
-- Helper: pick a random message
local function random_msg(list)
    return list[math.random(1, #list)]
end

-- Bigfoot Encounter
triggers.register_on_punch({
    target = {"mobs:bigfoot"},
    id = "ws_story:bigfoot",
    call_once = true,
    call = function(data)
        local msgs = {
            "I swear I just saw something huge and hairy in the trees.",
            "Big footprints... and then it was gone. Maybe I'm not alone?",
            "Bigfoot? Nah... right? RIGHT?"
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Yeti Encounter
triggers.register_on_punch({
    target = {"mobs:yeti"},
    id = "ws_story:yeti",
    call_once = true,
    call = function(data)
        local msgs = {
            "A big white creature just ran across the snow. Looked back at me too.",
            "It's freezing out here, and now there’s something big following me.",
            "I think I just saw a Yeti. Or maybe frostbite is making me see things."
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Sand Worm Encounter (not dune-style scary)
triggers.register_on_punch({
    target = {"mobs:sand_worm"},
    id = "ws_story:sand_worm",
    call_once = true,
    call = function(data)
        local msgs = {
            "Sand moved and a giant worm popped up. Looks harmless... maybe?",
            "It just wriggled back into the dunes. Weird but kinda funny.",
            "Biggest worm I’ve ever seen. Good thing it didn’t eat me."
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Spider Encounter
triggers.register_on_punch({
    target = {"mobs:spider", "mobs:spider_large"},
    id = "ws_story:spider",
    call_once = true,
    call = function(data)
        local msgs = {
            "Spiders. Big ones. Creepy legs everywhere. I'm not a fan.",
            "Eight legs too many for me. Staying away from webs from now on.",
            "That web was fresh... means they are close. Yikes."
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Ogre Encounter
triggers.register_on_punch({
    target = {"mobs:ogre"},
    id = "ws_story:ogre",
    call_once = true,
    call = function(data)
        local msgs = {
            "I just saw one of those big green brutes. Hope it didn’t see me.",
            "Ogre ahead. Might need to sneak around.",
            "Not sure what that was — looked like a walking rock with fists."
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Piranha Encounter
triggers.register_on_punch({
    target = {"mobs:piranha"},
    id = "ws_story:piranha",
    call_once = true,
    call = function(data)
        local msgs = {
            "Something just bit me in the water — sharp teeth! Piranhas!",
            "Splashing in the river was a mistake. Now I’m bleeding. Great.",
            "Tiny fish with big teeth... that’s new."
        }
        entries.add_entry(data.playerName, "ws_story:survivor", random_msg(msgs), true)
    end,
})

-- Dew barrel counter triggers
triggers.register_counter("ws_story:dew_barrel_count", "craft", "dewcollector:barrel_closed", false)

triggers.register_on_craft({
    target = "dewcollector:barrel_closed",
    id = "ws_story:dew_barrel",
    call_once = true,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "It is done, a dew collection barrel! Now I just have to place it somewhere and wait until it fills up. " ..
            "Then I can have a fresh drink. I guess I should build more of these.", true)
    end,
})

triggers.register_on_craft({
    target = "dewcollector:barrel_closed",
    id = "ws_story:some_dew_barrels",
    call_once = true,
    is_active = function(player)
        return triggers.get_count("ws_story:dew_barrel_count", player) > 2
    end,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "I guess three barrels are enough to survive for now. Maybe I should repair and extend a shelter...", true)
    end,
})

triggers.register_on_craft({
    target = "dewcollector:barrel_closed",
    id = "ws_story:many_dew_barrels",
    call_once = true,
    is_active = function(player)
        return triggers.get_count("ws_story:dew_barrel_count", player) > 4
    end,
    call = function(data)
        entries.add_entry(data.playerName, "ws_story:survivor",
            "These dew barrels are quite inefficient. I should try building a filter to clean the toxic water.", true)
    end,
})
