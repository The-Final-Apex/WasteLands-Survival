-- Smeltery multiblock system

local function check_smeltery_structure(pos)
    -- Check 3x3 floor of smeltery bricks with hollow center
    for x = -1, 1 do
        for z = -1, 1 do
            local check_pos = {x = pos.x + x, y = pos.y - 1, z = pos.z + z}
            local name = minetest.get_node(check_pos).name
            if x == 0 and z == 0 then
                if name ~= "air" then return false end
            else
                if name ~= "blacksmith:smeltery_bricks" then return false end
            end
        end
    end
    return true
end

minetest.register_node("blacksmith:smeltery_controller", {
    description = "Smeltery Controller",
    tiles = {"blacksmith_smeltery_controller.png"},
    groups = {cracky = 3},
    on_rightclick = function(pos, node, player)
        if not check_smeltery_structure(pos) then
            minetest.chat_send_player(player:get_player_name(), "Invalid smeltery structure!")
            return
        end

        local meta = minetest.get_meta(pos)
        minetest.show_formspec(player:get_player_name(), "blacksmith:smeltery", 
            "size[8,9]" ..
            "label[0,0;Smeltery Controller]" ..
            "list[context;input;0.5,1;3,3;]" ..
            "button[4,1;2,1;smelt;Start Smelting]" ..
            "list[current_player;main;0,5;8,4;]"
        )
    end,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 9)
        meta:set_int("molten_iron", 0)
        meta:set_int("molten_copper", 0)
    end,

    on_receive_fields = function(pos, formname, fields, player)
        if fields.smelt then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            for i = 1, inv:get_size("input") do
                local stack = inv:get_stack("input", i)
                if stack:get_name() == "blacksmith:iron_ore" then
                    meta:set_int("molten_iron", meta:get_int("molten_iron") + 144)
                    stack:take_item()
                    inv:set_stack("input", i, stack)
                elseif stack:get_name() == "blacksmith:copper_ore" then
                    meta:set_int("molten_copper", meta:get_int("molten_copper") + 144)
                    stack:take_item()
                    inv:set_stack("input", i, stack)
                end
            end
        end
    end,
})

minetest.register_node("blacksmith:smeltery_bricks", {
    description = "Smeltery Bricks",
    tiles = {"blacksmith_smeltery_bricks.png"},
    groups = {cracky = 3},
})

