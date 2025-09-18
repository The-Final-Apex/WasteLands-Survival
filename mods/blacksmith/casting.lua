-- Casting Table & Basin

minetest.register_node("blacksmith:casting_table", {
    description = "Casting Table",
    tiles = {"blacksmith_casting_table.png"},
    groups = {cracky = 3},
    on_rightclick = function(pos, node, player)
        minetest.show_formspec(player:get_player_name(), "blacksmith:casting_table",
            "size[8,9]" ..
            "list[context;cast;0.5,0.5;1,1;]" ..
            "list[context;output;2,0.5;1,1;]" ..
            "button[4,0.5;2,1;pour;Pour Metal]" ..
            "list[current_player;main;0,5;8,4;]"
        )
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("cast", 1)
        inv:set_size("output", 1)
    end,
    on_receive_fields = function(pos, formname, fields, player)
        if fields.pour then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local cast = inv:get_stack("cast", 1)
            if cast:get_name() == "blacksmith:cast_pickaxe_head" then
                -- Get smeltery molten iron nearby
                local smeltery_pos = {x = pos.x, y = pos.y, z = pos.z + 1}
                local smeltery_meta = minetest.get_meta(smeltery_pos)
                local molten_iron = smeltery_meta:get_int("molten_iron")
                if molten_iron >= 288 then
                    smeltery_meta:set_int("molten_iron", molten_iron - 288)
                    inv:add_item("output", "blacksmith:pickaxe_head")
                end
            end
        end
    end,
})
