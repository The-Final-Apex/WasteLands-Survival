-- ws_buckets/content.lua
-- Example items using the API (textures referenced by name; provide your own).

-- Optional: unfired clay bucket + recipe + cooking
minetest.register_craftitem("ws_buckets:clay_unfired", {
  description = minetest.colorize("#FFFFFF", "Unfired Clay Bucket\n") ..
                minetest.colorize("#ababab", "Cook to harden for liquid use."),
  inventory_image = "bucket_clay_unfired.png",
  groups = {flammable = 1},
})

minetest.register_craft({
  type = "cooking",
  cooktime = 15,
  output = "ws_buckets:clay_empty",
  recipe = "ws_buckets:clay_unfired",
})

if minetest.registered_items["ws_core:clay_lump"] then
  minetest.register_craft({
    output = "ws_buckets:clay_unfired",
    recipe = {
      {"ws_core:clay_lump", "", "ws_core:clay_lump"},
      {"", "ws_core:clay_lump", ""},
    }
  })
end

-- Clay bucket family
ws_buckets.register_bucket_set({
  empty = {
    name = "ws_buckets:clay_empty",
    description = minetest.colorize("#FFFFFF", "Empty Clay Bucket\n") ..
                  minetest.colorize("#ababab", "Use on a liquid source to fill."),
    image = "bucket_clay_empty.png",
    groups = {bucket = 1},
    stack_max = 99,
  },
  filled = {
    {
      name = "ws_buckets:clay_water_toxic",
      description = "Toxic Water Bucket (Clay)",
      image = "bucket_clay_water_toxic.png",
      liquid_source = "ws_core:water_source_toxic",
      force_renew = false,
      groups = {water_bucket = 1, toxic_water_bucket = 1},
    },
    {
      name = "ws_buckets:clay_water",
      description = "Water Bucket (Clay)",
      image = "bucket_clay_water.png",
      liquid_source = "ws_core:water_source",
      force_renew = true,
      groups = {water_bucket = 1, clean_water_bucket = 1},
    },
    {
      name = "ws_buckets:clay_oil",
      description = "Oil Bucket (Clay)",
      image = "bucket_clay_oil.png",
      liquid_source = "ws_core:oil_source",
      force_renew = true,
      groups = {oil_bucket = 1},
    },
  }
})

-- Metal bucket family
ws_buckets.register_bucket_set({
  empty = {
    name = "ws_buckets:metal_empty",
    description = minetest.colorize("#FFFFFF", "Empty Metal Bucket\n") ..
                  minetest.colorize("#ababab", "Use on a liquid source to fill."),
    image = "bucket_metal_empty.png",
    groups = {bucket = 1},
    stack_max = 99,
  },
  filled = {
    {
      name = "ws_buckets:metal_water_toxic",
      description = "Toxic Water Bucket (Metal)",
      image = "bucket_metal_water_toxic.png",
      liquid_source = "ws_core:water_source_toxic",
      force_renew = false,
      groups = {water_bucket = 1, toxic_water_bucket = 1},
    },
    {
      name = "ws_buckets:metal_water",
      description = "Water Bucket (Metal)",
      image = "bucket_metal_water.png",
      liquid_source = "ws_core:water_source",
      force_renew = true,
      groups = {water_bucket = 1, clean_water_bucket = 1},
    },
    {
      name = "ws_buckets:metal_oil",
      description = "Oil Bucket (Metal)",
      image = "bucket_metal_oil.png",
      liquid_source = "ws_core:oil_source",
      force_renew = true,
      groups = {oil_bucket = 1},
    },
    {
      name = "ws_buckets:metal_lava",
      description = "Lava Bucket (Metal)",
      image = "bucket_metal_lava.png",
      liquid_source = "ws_core:lava_source",
      force_renew = true,
      groups = {lava_bucket = 1},
    },
  }
})
