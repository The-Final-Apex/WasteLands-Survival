# ws_buckets

A clean-room rewrite of a simple buckets mod for Minetest under the **MIT License (code only)**. Media (textures) are not included.

## Features
- Clay and metal bucket families (empty + filled variants)
- Scoop/place behavior for registered liquid sources
- Protection-aware (won’t scoop/place in protected areas)
- Inventory-friendly (gives back empty bucket, handles stacks)
- Small API to register your own bucket sets

## API
```lua
-- Register a family of buckets sharing one empty bucket item + N filled variants.
ws_buckets.register_bucket_set({
  empty = {
    name = "ws_buckets:clay_empty",
    description = "Empty Clay Bucket",
    image = "bucket_clay_empty.png", -- supply your own
    groups = {bucket = 1},
    stack_max = 99,
  },
  filled = {
    {
      name = "ws_buckets:clay_water",
      description = "Water Bucket (Clay)",
      image = "bucket_clay_water.png",
      liquid_source = "ws_core:water_source",
      force_renew = true,
      groups = {water_bucket = 1},
    },
    -- add more liquids here...
  }
})
```

## Licensing
- **Code:** MIT (see `LICENSE`).
- **Media:** Bring your own textures or ensure compatible licensing.

## Migration
- Replace any old buckets mod with this one (`ws_buckets`).
- Update item names or add aliases if needed.
