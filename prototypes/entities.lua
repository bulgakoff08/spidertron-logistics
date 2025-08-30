local GRAPHICS_PATH = "__spidertron-logistics__/graphics/"

local function dropZone (letter)
    return {
        type = "simple-entity",
        name = "sl-drop-zone-" .. letter,
        icon = GRAPHICS_PATH .. "icons/sl-drop-zone-" .. letter .. ".png",
        icon_size = 64,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "sl-drop-zone-" .. letter},
        max_health = 1500,
        corpse = "big-remnants",
        collision_box = nil,
        selection_box = {{-2, -2}, {2, 2}},
        resistances = {
            {type = "fire", percent = 90},
            {type = "impact", percent = 60}
        },
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        pictures = {
            {
                filename = GRAPHICS_PATH .. "entities/drop-zone-" .. letter .. ".png",
                priority = "extra-high",
                width = 228,
                height = 228,
                shift = util.by_pixel(0, 0),
                scale = 0.6
            }
        }
    }
end

local function loadZone (letter)
    return {
        type = "simple-entity",
        name = "sl-load-zone-" .. letter,
        icon = GRAPHICS_PATH .. "icons/sl-load-zone-" .. letter .. ".png",
        icon_size = 64,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "sl-load-zone-" .. letter},
        max_health = 1500,
        corpse = "big-remnants",
        collision_box = nil,
        selection_box = {{-2, -2}, {2, 2}},
        resistances = {
            {type = "fire", percent = 90},
            {type = "impact", percent = 60}
        },
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        pictures = {
            {
                filename = GRAPHICS_PATH .. "entities/load-zone-" .. letter .. ".png",
                priority = "extra-high",
                width = 228,
                height = 228,
                shift = util.by_pixel(0, 0),
                scale = 0.6
            }
        }
    }
end

for _, letter in pairs({"a", "b", "c", "d", "e", "f"}) do
    data:extend({
        dropZone(letter),
        loadZone(letter)
    })
end