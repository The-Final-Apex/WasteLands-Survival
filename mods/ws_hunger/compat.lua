-- Wrap minetest.do_item_eat so food adds satiation rather than HP directly
local orig = minetest.do_item_eat

minetest.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
  local stack_old = itemstack
  local gain = math.floor((type(hp_change) == "number" and hp_change or 1) * 1.3)
  local func = ws_hunger.eat(gain, {replace = replace_with_item})
  local result = func(itemstack, user, pointed_thing)

  for _, cb in pairs(minetest.registered_on_item_eats or {}) do
    local r = cb(hp_change, replace_with_item, result, user, pointed_thing, stack_old)
    if r then return r end
  end
  return result
end
