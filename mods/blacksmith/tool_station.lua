-- Tool Station for combining parts into tools

minetest.register_node("blacksmith:tool_station", {
    description = "Tool Station",
    tiles = {"blacksmith_tool_station.png"},
    groups = {cracky = 3},
    on_rightclick = function(pos, node, player)
        minetest.show_formspec(player:get_player_name(), "blacksmith:tool_station",
            "size[8,9]" ..
            "list[context;input;0.5,0.5;2,1;]" ..
            "list[context;output;3.5,0.5;1,1;]" ..
            "button[5,0.5;2,1;craft;Assemble Tool]" ..
            "list[current_player;main;0,5;8,4;]"
        )
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 2)
        inv:set_size("output", 1)
    end,
    on_receive_fields = function(pos, formname, fields, player)
        if fields.craft then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            if inv:contains_item("input", "blacksmith:pickaxe_head") and
               inv:contains_item("input", "blacksmith:tool_handle") then
                inv:remove_item("input", "blacksmith:pickaxe_head")
                inv:remove_item("input", "blacksmith:tool_handle")
                inv:add_item("output", "blacksmith:pickaxe")
            end
        end
    end,
})

