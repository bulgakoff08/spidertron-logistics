local GRAPHICS_PATH = "__eight-legged-courier__/graphics/"

local function equipment (letter)
    return {
        type = "battery-equipment",
        name = "sl-navigation-equipment-" .. letter,
        sprite = {
            filename = GRAPHICS_PATH .. "/equipment/navigation-equipment-" .. letter .. ".png",
            width = 128,
            height = 128,
            scale = 0.5,
            priority = "medium"
        },
        shape = {width = 2, height = 2, type = "full"},
        energy_source = {
            type = "electric", buffer_capacity = "0J", input_flow_limit = "0W",
            output_flow_limit = "0W", usage_priority = "tertiary"
        },
        categories = {"armor"}
    }
end

local function equipmentItem (letter)
    return {
        type = "item",
        name = "sl-navigation-equipment-" .. letter,
        icon = GRAPHICS_PATH .. "/icons/sl-navigation-equipment-" .. letter .. ".png",
        icon_size = 64,
        place_as_equipment_result = "sl-navigation-equipment-" .. letter,
        subgroup = "sl-modules",
        order = "n",
        stack_size = 20
    }
end

local function zoneItem (type, group, letter)
    return {
        type = "item",
        name = "sl-" .. type .. "-" .. letter,
        icon = GRAPHICS_PATH .. "icons/sl-" .. type .. "-" .. letter .. ".png",
        icon_size = 64,
        subgroup = group,
        stack_size = 10,
        place_result = "sl-" .. type .. "-" .. letter
    }
end

for _, letter in pairs({"a", "b", "c", "d", "e", "f"}) do
    data:extend({
        equipment(letter),
        equipmentItem(letter),
        zoneItem("drop-zone", "sl-loads", letter),
        zoneItem("load-zone", "sl-unloads", letter)
    })
end

data:extend({
    {
        type = "battery-equipment",
        name = "sl-timer-equipment",
        sprite = {
            filename = GRAPHICS_PATH .. "/equipment/timer-equipment.png",
            width = 64,
            height = 64,
            scale = 0.5,
            priority = "medium"
        },
        shape = {width = 1, height = 1, type = "full"},
        energy_source = {
            type = "electric", buffer_capacity = "0J", input_flow_limit = "0W",
            output_flow_limit = "0W", usage_priority = "tertiary"
        },
        categories = {"armor"}
    },
    {
        type = "item",
        name = "sl-timer-equipment",
        icon = GRAPHICS_PATH .. "/icons/sl-timer-equipment.png",
        icon_size = 64,
        place_as_equipment_result = "sl-timer-equipment",
        subgroup = "sl-modules",
        order = "n",
        stack_size = 20
    }
})