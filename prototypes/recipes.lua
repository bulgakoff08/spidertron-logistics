local function items (...)
    local arguments = {...}
    local result = {}
    for index = 1, #arguments, 2 do
        if arguments[index + 1] < 1 then
            table.insert(result, {
                type = "item",
                name = arguments[index],
                probability = arguments[index + 1],
                amount = 1
            })
        else
            table.insert(result, {
                type = "item",
                name = arguments[index],
                amount = arguments[index + 1]
            })
        end
    end
    return result
end

local function recipe (category, craftingTime, recipeId, inputs, outputs, productivity)
    return {
        type = "recipe",
        name = recipeId,
        category = category,
        ingredients = inputs,
        results = outputs,
        energy_required = craftingTime,
        allow_productivity = productivity or false
    }
end

for _, letter in pairs({"a", "b", "c", "d", "e", "f"}) do
    data:extend({
        recipe("crafting", 1, "sl-drop-zone-" .. letter, items("refined-concrete", 16), items("sl-drop-zone-" .. letter, 1)),
        recipe("crafting", 1, "sl-load-zone-" .. letter, items("refined-concrete", 16), items("sl-load-zone-" .. letter, 1)),
        recipe("crafting", 1, "sl-navigation-equipment-" .. letter, items("radar", 1, "processing-unit", 5), items("sl-navigation-equipment-" .. letter, 1))
    })
end

data:extend({
    recipe("crafting", 1, "sl-timer-equipment", items("advanced-circuit", 5), items("sl-timer-equipment", 1))
})