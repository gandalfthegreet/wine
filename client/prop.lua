local placedProps = {}

-- Ply loaded, request props
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('wine:playerJoined')
end)

-- On resource start, request props (for script restart)
CreateThread(function()
    Wait(5000) -- wait for server to load props
    TriggerServerEvent('wine:playerJoined')
end)

-- Manual load props
RegisterCommand('loadwineprops', function()
    TriggerServerEvent('wine:playerJoined')
end, false)

-- Item use event
RegisterNetEvent('wine:placePropItem', function()
    TriggerServerEvent('wine:placePropItem', DeterminePlaceCoords())
end)

function DeterminePlaceCoords()
    -- Raycast to place on ground
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if not success then coords = GetEntityCoords(cache.ped) end
    return coords
end

-- Event: Spawn prop
RegisterNetEvent('wine:spawnProp', function(id, coords)
    print('[Wine Client] Spawning prop ' .. id .. ' at ' .. tostring(coords.x) .. ',' .. tostring(coords.y) .. ',' .. tostring(coords.z))
    lib.requestModel(Config.CraftingProp)
    local propEntity = CreateObject(Config.CraftingProp, coords.x, coords.y, coords.z, false, true, true)
    print('[Wine Client] Created object: ' .. tostring(propEntity) .. ' exists: ' .. tostring(DoesEntityExist(propEntity)))
    PlaceObjectOnGroundProperly(propEntity)
    FreezeEntityPosition(propEntity, true)

    placedProps[id] = propEntity

    -- Add ox_target
    exports.ox_target:addLocalEntity(propEntity, {{
        label = 'Craft Wine',
        icon = 'fa-solid fa-wine-bottle',
        onSelect = function()
            OpenCraftingMenu()
        end
    }, {
        label = 'Pick Up Prop',
        icon = 'fa-solid fa-hand-paper',
        onSelect = function()
            TriggerServerEvent('wine:pickupProp', id)
        end
    }})
    print('[Wine Client] Prop ' .. id .. ' setup complete')
end)

-- Event: Spawn multiple props (for player load)
RegisterNetEvent('wine:spawnAllProps', function(propsToSpawn)
    for id, coords in pairs(propsToSpawn) do
        local propEntity = nil
        if not placedProps[id] then
            lib.requestModel(Config.CraftingProp)
            propEntity = CreateObject(Config.CraftingProp, coords.x, coords.y, coords.z, false, true, true)
            PlaceObjectOnGroundProperly(propEntity)
            FreezeEntityPosition(propEntity, true)
            placedProps[id] = propEntity
        end
        if placedProps[id] then
            -- Add ox_target
            exports.ox_target:addLocalEntity(placedProps[id], {{
                label = 'Craft Wine',
                icon = 'fa-solid fa-wine-bottle',
                onSelect = function()
                    OpenCraftingMenu()
                end
            }, {
                label = 'Pick Up Prop',
                icon = 'fa-solid fa-hand-paper',
                onSelect = function()
                    TriggerServerEvent('wine:pickupProp', id)
                end
            }})
        end
    end
end)

-- Event: Remove prop
RegisterNetEvent('wine:removeProp', function(id)
    if placedProps[id] then
        DeleteEntity(placedProps[id])
        placedProps[id] = nil
    end
end)

-- Event: Clear all props
RegisterNetEvent('wine:clearProps', function()
    for id, prop in pairs(placedProps) do
        DeleteEntity(prop)
        placedProps[id] = nil
    end
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
