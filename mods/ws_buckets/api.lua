-- ws_buckets/api.lua
-- MIT-licensed minimal bucket API, built from scratch.

ws_buckets = rawget(_G, "ws_buckets") or {}

-- internal helpers
local function protected_at(pos, actor_name, action_text)
  if minetest.is_protected(pos, actor_name) then
    minetest.log("action", (actor_name ~= "" and actor_name or "Someone")
      .. " tried to " .. action_text
      .. " at protected position " .. minetest.pos_to_string(pos)
      .. " using a bucket")
    minetest.record_protection_violation(pos, actor_name)
    return true
  end
  return false
end

local function build_liquid_map(filled_defs)
  local map = {}
  for _, f in ipairs(filled_defs) do
    map[f.liquid_source] = {
      full_item = f.name,
      force_renew = not not f.force_renew,
      source = f.liquid_source,
    }
  end
  return map
end

local function on_scoop(itemstack, user, pointed_thing)
  if pointed_thing.type == "object" then
    local ref = pointed_thing.ref
    if ref and ref.punch then
      ref:punch(user, 1.0, {full_punch_interval = 1.0}, nil)
    end
    return user and user:get_wielded_item() or itemstack
  end

  if pointed_thing.type ~= "node" then
    return itemstack
  end

  local stackname = itemstack:get_name()
  local itemdef = minetest.registered_items[stackname]
  local liquids = itemdef and itemdef._ws_liquids
  if not liquids then
    return itemstack
  end

  local pos = pointed_thing.under
  local node = minetest.get_node(pos)
  local info = liquids[node.name]
  if not info then
    local ndef = minetest.registered_nodes[node.name]
    if ndef and ndef.on_punch and user then
      ndef.on_punch(pos, node, user, pointed_thing)
    end
    return user and user:get_wielded_item() or itemstack
  end

  local playername = (user and user:is_player()) and user:get_player_name() or ""
  if protected_at(pos, playername, "scoop " .. node.name) then
    return itemstack
  end

  local give = ItemStack(info.full_item)
  if itemstack:get_count() > 1 and user then
    local inv = user:get_inventory()
    if inv and inv:room_for_item("main", give) then
      inv:add_item("main", give)
    else
      local drop = vector.round(user:get_pos() or pos)
      minetest.add_item(drop, give)
    end
    itemstack:take_item(1)
  else
    itemstack = give
  end

  local preserve = false
  if info.force_renew then
    local neighbor = minetest.find_node_near(pos, 1, {info.source})
    preserve = (neighbor ~= nil)
  end
  if not preserve then
    minetest.remove_node(pos)
  end

  return itemstack
end

local function on_pour(itemstack, user, pointed_thing)
  if pointed_thing.type ~= "node" then
    return itemstack
  end

  local under = pointed_thing.under
  local above = pointed_thing.above

  local node = minetest.get_node_or_nil(under)
  local ndef = node and minetest.registered_nodes[node.name]
  if ndef and ndef.on_rightclick and user and user:is_player() then
    local ctrl = user:get_player_control() or {}
    if not ctrl.sneak then
      return ndef.on_rightclick(under, node, user, itemstack) or itemstack
    end
  end

  local place_pos
  if ndef and ndef.buildable_to then
    place_pos = under
  else
    local abnode = minetest.get_node_or_nil(above)
    local abdef = abnode and minetest.registered_nodes[abnode.name]
    if abdef and abdef.buildable_to then
      place_pos = above
    else
      return itemstack
    end
  end

  local idef = minetest.registered_items[itemstack:get_name()]
  local liquids = idef and idef._ws_bucket
  if not liquids then
    return itemstack
  end

  local playername = (user and user:is_player()) and user:get_player_name() or ""
  if protected_at(place_pos, playername, "place " .. (liquids.liquid or "liquid")) then
    return itemstack
  end

  minetest.set_node(place_pos, {name = liquids.liquid})
  return ItemStack(liquids.empty_item or "")
end

-- Public API
function ws_buckets.register_bucket_set(def)
  assert(type(def) == "table", "ws_buckets.register_bucket_set expects a table")
  assert(type(def.empty) == "table" and type(def.filled) == "table", "def must include 'empty' and 'filled' tables")

  local liquid_map = build_liquid_map(def.filled)

  minetest.register_craftitem(def.empty.name, {
    description = def.empty.description or "Empty Bucket",
    inventory_image = def.empty.image or "unknown_item.png",
    groups = def.empty.groups or {bucket = 1},
    stack_max = def.empty.stack_max or 99,
    liquids_pointable = true,
    _ws_liquids = liquid_map,
    on_use = on_scoop,
  })

  for _, f in ipairs(def.filled) do
    minetest.register_craftitem(f.name, {
      description = f.description or "Filled Bucket",
      inventory_image = f.image or "unknown_item.png",
      groups = f.groups or {},
      stack_max = 1,
      liquids_pointable = true,
      _ws_bucket = {
        empty_item = def.empty.name,
        liquid = f.liquid_source,
      },
      on_place = on_pour,
    })
  end
end
