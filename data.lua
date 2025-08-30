require("prototypes.items")
require("prototypes.entities")
require("prototypes.recipes")

data:extend({
    {
        type = "item-subgroup",
        name = "sl-loads",
        group = "logistics",
        order = "s-l"
    },
    {
        type = "item-subgroup",
        name = "sl-unloads",
        group = "logistics",
        order = "s-u"
    },
    {
        type = "item-subgroup",
        name = "sl-modules",
        group = "combat",
        order = "s-m"
    }
})