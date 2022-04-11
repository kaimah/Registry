# Registry

Simple registry system with path-based indexing.

Read the [documentation](https://kairamah.github.io/Registry/) for more info.

```lua
local items = Registry.new("Items", {
    melee = {
        axes = {
            { name = "woodenAxe", quantity = 1 }
        }
    }

    ranged = {}
})

local woodenAxeData = items:search("melee/axes"):with({ name = "woodenAxe" }):get()
```