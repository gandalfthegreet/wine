local placedProp = nil

-- Event: Client pick up prop (local only)
RegisterNetEvent('wine:pickupProp', function()
    if placedProp then
        DeleteEntity(placedProp)
        placedProp = nil
        Config.CraftingCoords = nil
        lib.notify({ title = 'Picked Up', description = 'Crafting prop picked up', type = 'info' })
    else
        lib.notify({ title = 'No Prop', description = 'No prop to pick up', type = 'error' })
    end
end)

-- Command to place crafting prop (for testing, can be menu/command)
RegisterCommand('placewineprop', function()
    if not HasRequiredJob(cache.ped) then lib.notify({ title = 'No Access', description = 'You need the required job', type = 'error' }) return end
    if placedProp then lib.notify({ title = 'Already Placed', description = 'Remove existing prop first', type = 'error' }) return end

    -- Raycast to place on ground
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if not success then coords = GetEntityCoords(cache.ped) end

    -- Spawn prop
    lib.requestModel(Config.CraftingProp)
    placedProp = CreateObject(Config.CraftingProp, coords.x, coords.y, coords.z, true, true, true)
    SetEntityAsMissionEntity(placedProp, true, true)
    PlaceObjectOnGroundProperly(placedProp)
    FreezeEntityPosition(placedProp, true)

    Config.CraftingCoords = coords

    -- Add target
    exports.ox_target:addLocalEntity(placedProp, {{
        label = 'Craft Wine',
        icon = 'fa-solid fa-wine-bottle',
        canInteract = function()
            return HasRequiredJob(cache.ped)
        end,
        onSelect = function()
            OpenCraftingMenu()
        end
    }, {
        label = 'Pick Up Prop',
        icon = 'fa-solid fa-hand-paper',
        canInteract = function()
            return HasRequiredJob(cache.ped)
        end,
        onSelect = function()
            TriggerServerEvent('wine:pickupProp')
        end
    }})

    lib.notify({ title = 'Placed', description = 'Crafting prop placed', type = 'success' })
end, false)

-- Command to remove prop
RegisterCommand('removewineprop', function()
    if not placedProp then lib.notify({ title = 'No Prop', description = 'No prop to remove', type = 'error' }) return end
    DeleteEntity(placedProp)
    placedProp = nil
    Config.CraftingCoords = nil
    lib.notify({ title = 'Removed', description = 'Crafting prop removed', type = 'info' })
end, false)

-- Crafting menu using ox_lib
function OpenCraftingMenu()
    local recipes = {}
    for recipeKey, recipe in pairs(Config.Recipes) do
        -- Check if player has ingredients
        local canCraft = true
        for item, req in pairs(recipe.ingredients) do
            if not exports.ox_inventory:Search('count', item) >= req.amount then
                canCraft = false
                break
            end
        end
        table.insert(recipes, {
            title = recipeKey:gsub('_', ' '):gsub('wine ', ''),
            description = 'Requires: ' .. function()
                local reqs = {}
                for item, req in pairs(recipe.ingredients) do
                    table.insert(reqs, req.label .. ' x' .. req.amount)
                end
                return table.concat(reqs, ', ')
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
        lib.notify({ title = 'Cancelled', description = 'Crafting cancelled', type = 'info' })
    end
end)
