-- Setup fixed crafting locations on load
CreateThread(function()
    Wait(1000)
    for i, coords in ipairs(Config.CraftingLocations) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 3.0,
            debug = false,
            options = {{
                label = 'Craft Wine',
                icon = 'fa-solid fa-wine-bottle',
                onSelect = OpenCraftingMenu,
                distance = 3.0
            }}
        })
    end
end)

-- Crafting menu using ox_lib
function OpenCraftingMenu()
    local recipes = {}
    for recipeKey, recipe in pairs(Config.Recipes) do
        -- Check if player has ingredients
        local canCraft = true
        for item, req in pairs(recipe.ingredients) do
            local itemCount = exports.ox_inventory:GetItemCount(item)
            if itemCount < req.amount then
                canCraft = false
                break
            end
        end
        table.insert(recipes, {
            title = recipeKey:gsub('_', ' '):gsub('wine ', ''),
            description = function()
                local reqs = {}
                for item, req in pairs(recipe.ingredients) do
                    table.insert(reqs, req.label .. ' x' .. req.amount)
                end
                return 'Requires: ' .. table.concat(reqs, ', ')
            end,
            disabled = not canCraft,
            onSelect = function()
                TriggerServerEvent('wine:craftWine', recipeKey, recipe)
            end
        })
    end

        lib.registerContext({
            id = 'wine_crafting',
            title = 'Wine Crafting Menu',
            options = recipes
        })
        lib.showContext('wine_crafting')
end

-- Event to handle crafting
RegisterNetEvent('wine:startCrafting', function(recipeKey, recipe)
    if lib.progressCircle({
        duration = recipe.duration,
        label = 'Crafting wine...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true },
    }) then
        TriggerServerEvent('wine:finishCrafting', recipeKey, recipe)
        lib.notify({ title = 'Crafted', description = 'Wine crafted successfully', type = 'success' })
    else
        -- Refund ingredients if canceled
        TriggerServerEvent('wine:craftingCanceled', recipeKey, recipe)
        lib.notify({ title = 'Cancelled', description = 'Crafting cancelled, ingredients refunded', type = 'info' })
    end
end)
