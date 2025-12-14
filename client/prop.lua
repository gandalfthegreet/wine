local placedProps = {}

-- Item use event for placing barrel
RegisterNetEvent('wine:placePropItem', function()
    TriggerServerEvent('wine:placePropItem', DeterminePlaceCoords())
end)

function DeterminePlaceCoords()
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if not success then coords = GetEntityCoords(cache.ped) end
    return coords
end

-- Spawn networked crafting prop
RegisterNetEvent('wine:spawnPropNetId', function(id, netId)
    local propEntity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(propEntity) then
        SetEntityAsMissionEntity(propEntity, true, true)
        PlaceObjectOnGroundProperly(propEntity)
        FreezeEntityPosition(propEntity, true)
        placedProps[id] = propEntity
        exports.ox_target:addLocalEntity(propEntity, {{
            name = 'wine_craft',
            label = 'Craft Wine',
            icon = 'fa-solid fa-wine-bottle',
            onSelect = OpenCraftingMenu,
            distance = 2.0
        }, {
            name = 'wine_pickup',
            label = 'Pick Up Barrel',
            icon = 'fa-solid fa-hand-paper',
            onSelect = function()
                TriggerServerEvent('wine:pickupProp', id)
            end,
            distance = 2.0
        }})
    end
end)

-- Remove prop target
RegisterNetEvent('wine:removeProp', function(id)
    if placedProps[id] then
        placedProps[id] = nil
    end
end)

-- Clear all props (admin)
RegisterNetEvent('wine:clearProps', function()
    placedProps = {}
end)

-- Commands for placing prop (job optional)
RegisterCommand('placewineprop', function()
    if Config.RequiredJob and not HasRequiredJob(cache.ped) then lib.notify({ title = 'No Access', description = 'You need the required job', type = 'error' }) return end
    for _, prop in pairs(placedProps) do
        if prop then lib.notify({ title = 'Already Placed', description = 'Remove existing prop first', type = 'error' }) return end
    end

    -- Raycast to place on ground
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if not success then coords = GetEntityCoords(cache.ped) end

    -- Request server to place prop
    TriggerServerEvent('wine:placeProp', coords)
end, false)

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
