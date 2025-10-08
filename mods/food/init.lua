food = {}

dofile(minetest.get_modpath('food')..'/bugs.lua')

minetest.register_craftitem("food:can", {
	description = "A Can of Preserved Food",
	inventory_image = "food_can.png",
	groups = {food = 1},
	on_use = minetest.item_eat(6),
})

-- Canned Beans — simple, nutritious
minetest.register_craftitem("food:canned_beans", {
	description = "Canned Beans",
	inventory_image = "food_canned_beans.png",
	on_use = minetest.item_eat(5),
	groups = {food = 1},
})


-- Just a note for anyone else developing
-- The following code contains 🔥🔥🔥🔥GAMBLING🔥🔥🔥🔥


--Mystery Meat — suspicious but filling
minetest.register_craftitem("food:mystery_meat", {
	description = "Mystery Meat",
	inventory_image = "food_mystery_meat.png",
	on_use = function(itemstack, user, pointed_thing)
		local player = user:get_player_name()
		if math.random(1, 5) == 1 then
			user:set_hp(user:get_hp() - 2) -- sometimes causes sickness
			minetest.chat_send_player(player, "that didn't taste right. *spongebobsadtheme*")
		else
			user:set_hp(user:get_hp() + 4)
		end
		itemstack:take_item()
		return itemstack
	end,
	groups = {food = 1, toxic = 1},
})

-- Dried Insect Protein — scavenged bug jerky
minetest.register_craftitem("food:bug_jerky", {
	description = "Bug Jerky",
	inventory_image = "food_bug_jerky.png",
	on_use = minetest.item_eat(3),
	groups = {food = 1},
})

-- Stale Bread — dry n edible
minetest.register_craftitem("food:stale_bread", {
	description = "Stale Bread",
	inventory_image = "food_stale_bread.png",
	on_use = minetest.item_eat(2),
	groups = {food = 1},
})

-- Cooked Rat — classic delicacy
minetest.register_craftitem("food:cooked_rat", {
	description = "Cooked Rat",
	inventory_image = "food_cooked_rat.png",
	on_use = minetest.item_eat(4),
	groups = {food = 1, meat = 1},
})

