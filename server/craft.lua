local QBOXCore = exports['qb-core']:GetCoreObject()

-- Prop storage
local placedProps = {}

function LoadPlacedProps()
    exports.oxmysql:execute('CREATE TABLE IF NOT EXISTS wine_props (id INT AUTO_INCREMENT PRIMARY KEY, coords MEDIUMTEXT)', {}, function()
    end)
    exports.oxmysql:execute([[DELETE FROM wine_props WHERE coords IS NULL OR TRIM(coords) = '' OR NOT JSON_VALID(coords)]], {}, function()
        exports.oxmysql:query('SELECT coords FROM wine_props', {}, function(result)
            print('[Wine Debug] Loading ' .. #result .. ' props from DB')
            for i, row in ipairs(result) do
                if row.coords then
                    local ok, coords = pcall(json.decode, row.coords)
                    if ok and coords and type(coords) == 'table' and coords.x and coords.y and coords.z then
                        print('[Wine Debug] Loading prop ' .. i .. ' at' .. coords.x .. ',' .. coords.y .. ',' .. coords.z)
                        SpawnCraftingProp(coords)
                    else
                        print('[Wine Debug] Skipping invalid prop ' .. i .. ': ' .. tostring(row.coords))
                    end
                end
            end
        end)
    end)
end

-- Load props on server start
LoadPlacedProps()

-- Send props to players when they load
RegisterNetEvent('wine:playerJoined', function()
    local source = source
    local propsForPlayer = {}
    for id, propData in pairs(placedProps) do
        propsForPlayer[id] = propData.coords
    end
    TriggerClientEvent('wine:spawnAllProps', source, propsForPlayer)
end)

-- Command to clear all props (admin)
RegisterCommand('clearwineprops', function(source)
    if source ~= 0 then -- only console/server
        TriggerClientEvent('ox_lib:notify', source, { title = 'Denied', description = 'Server only command', type = 'error' })
        return
    end
    exports.oxmysql:execute('TRUNCATE TABLE wine_props', {}, function()
        placedProps = {}
        print('[Wine] Cleared all wine props from DB')
        TriggerClientEvent('wine:clearProps', -1)
    end)
end, true)

function SpawnCraftingProp(coords)
    local id = #placedProps + 1
    placedProps[id] = {
        coords = coords,
        entity = nil
    }
    -- Spawn and setup
    TriggerClientEvent('wine:spawnProp', -1, id, coords)
end

-- Event: Pick grape
RegisterNetEvent('wine:pickGrape', function(pointKey, zone)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Check job
    if not HasRequiredJob(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'No Access', description = 'You need the required job', type = 'error' })
        return
    end

    -- Check if can carry
    local grapeData = Config.Grapes[zone.grapeType]
    if not exports.ox_inventory:CanCarryItem(source, grapeData.item, grapeData.amount) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Inventory Full', description = 'You can\'t carry more grapes', type = 'error' })
        return
    end

    -- Trigger client to do the animation/skill check
    TriggerClientEvent('wine:startPicking', source, pointKey, zone)
end)

-- Event: Complete pick
RegisterNetEvent('wine:completePick', function(pointKey, zone, success)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    local grapeData = Config.Grapes[zone.grapeType]

    if success then
        player.Functions.AddItem(grapeData.item, grapeData.amount)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Success', description = 'You picked ' .. grapeData.label, type = 'success' })
        SendDiscordLog('Grape Harvest', ('Player %s picked %s at zone %s'):format(source, grapeData.label, zone.center))
    else
        TriggerClientEvent('ox_lib:notify', source, { title = 'Failed', description = 'You damaged the grapes!', type = 'error' })
    end
end)

-- Event: Start crafting
RegisterNetEvent('wine:craftWine', function(recipeKey, recipe)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Check job if required
    if not HasRequiredJob(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'No Access', description = 'You need the required job', type = 'error' })
        return
    end

    -- Verify ingredients
    local hasIngredients = true
    for item, req in pairs(recipe.ingredients) do
        if player.Functions.GetItemByName(item) == nil or player.Functions.GetItemByName(item).amount < req.amount then
            hasIngredients = false
            break
        end
    end

    if not hasIngredients then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Missing Ingredients', description = 'You don\'t have the required items', type = 'error' })
        return
    end

    -- Remove ingredients
    for item, req in pairs(recipe.ingredients) do
        player.Functions.RemoveItem(item, req.amount)
    end

    -- Start crafting progress
    TriggerClientEvent('wine:startCrafting', source, recipeKey, recipe)

    -- Log
    SendDiscordLog('Crafting Started', ('Player %s started crafting %s'):format(source, recipeKey))
end)

-- Event: Finish crafting
RegisterNetEvent('wine:finishCrafting', function(recipeKey, recipe)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    local output = recipe.output

    -- Add crafted wine with metadata
    local metadata = {
        description = ('A bottle of %s'):format(output.label),
        created = os.time(),
        sips_remaining = output.sips
    }

    if player.Functions.AddItem(output.item, output.amount, false, metadata) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Crafted', description = ('You crafted %s'):format(output.label), type = 'success' })
        SendDiscordLog('Crafting Completed', ('Player %s completed crafting %s (sips: %d)'):format(source, recipeKey, output.sips))
    else
        -- If can't add, refund ingredients (simple version)
        for item, req in pairs(recipe.ingredients) do
            player.Functions.AddItem(item, req.amount)
        end
        TriggerClientEvent('ox_lib:notify', source, { title = 'Failed', description = 'Inventory full, ingredients refunded', type = 'error' })
    end
end)

-- Event: Use wine
RegisterNetEvent('wine:useWine', function(wineItem)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Find the item in inventory
    local items = exports.ox_inventory:GetInventoryItems(source)
    local foundItem = nil
    for slot, item in pairs(items) do
        if item.name == wineItem.name and (wineItem.slot == slot or not wineItem.slot) then
            foundItem = item
            foundItem.slot = slot
            break
        end
    end

    if not foundItem or foundItem.count < 1 then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Error', description = 'You don\'t have that wine', type = 'error' })
        return
    end

    local metadata = foundItem.metadata or {}
    local maxSips = Config.Effects[wineItem.name] and Config.Effects[wineItem.name].base_sips or 5

    -- Determine if sip or full
    local isSip = false
    if metadata.sips_remaining == nil then
        metadata.sips_remaining = maxSips - 1  -- First use is sip unless single
        isSip = true
    elseif metadata.sips_remaining > 1 then
        isSip = true
        metadata.sips_remaining = metadata.sips_remaining - 1
    else
        -- Last sip
        player.Functions.RemoveItem(wineItem.name, 1, foundItem.slot)
        TriggerClientEvent('wine:drinkWine', source, wineItem, true)
        SendDiscordLog('Wine Consumed', ('Player %s finished %s'):format(source, wineItem.label))
        return
    end

    -- Update inventory with new metadata
    exports.ox_inventory:SetMetadata(source, foundItem.slot, metadata)
    TriggerClientEvent('wine:drinkWine', source, wineItem, isSip)
    SendDiscordLog('Wine Consumed', ('Player %s sipped %s'):format(source, wineItem.label))
end)

-- Event: Place prop (item use)
RegisterNetEvent('wine:placePropItem', function(coords)
    if not coords then return end
    print('Server placePropItem coords: ' .. tostring(coords.x) .. ',' .. tostring(coords.y) .. ',' .. tostring(coords.z))
    local playerSource = source
    local player = QBOXCore.Functions.GetPlayer(playerSource)
    if not player then return end

    local item = player.Functions.GetItemByName(Config.CraftingItem)
    if not item or item.amount < 1 then
        TriggerClientEvent('ox_lib:notify', playerSource, { title = 'No Item', description = 'You need a wooden wine barrel', type = 'error' })
        return
    end
    player.Functions.RemoveItem(Config.CraftingItem, 1)

    exports.oxmysql:insert('INSERT INTO wine_props (coords) VALUES (?)', {json.encode(coords)}, function(insertId)
        print('Insert result, id: ' .. tostring(insertId))
        if insertId then
            SpawnCraftingProp(coords)
            TriggerClientEvent('ox_lib:notify', playerSource, { title = 'Placed', description = 'Crafting prop placed and saved', type = 'success' })
        else
            -- Refund item if save failed
            player.Functions.AddItem(Config.CraftingItem, 1)
            TriggerClientEvent('ox_lib:notify', playerSource, { title = 'Error', description = 'Failed to save prop', type = 'error' })
        end
    end)
end)

-- Event: Place prop (old command)
RegisterNetEvent('wine:placeProp', function(coords)
    if not coords then return end
    print('Server placeProp coords: ' .. tostring(coords.x) .. ',' .. tostring(coords.y) .. ',' .. tostring(coords.z))
    local playerSource = source

    exports.oxmysql:insert('INSERT INTO wine_props (coords) VALUES (?)', {json.encode(coords)}, function(insertId)
        print('Insert result, id: ' .. tostring(insertId))
        if insertId then
            SpawnCraftingProp(coords)
            TriggerClientEvent('ox_lib:notify', playerSource, { title = 'Placed', description = 'Crafting prop placed and saved', type = 'success' })
        else
            TriggerClientEvent('ox_lib:notify', playerSource, { title = 'Error', description = 'Failed to save prop', type = 'error' })
        end
    end)
end)

-- Event: Pickup prop
RegisterNetEvent('wine:pickupProp', function()
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Find prop near player
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local propFound = false
    for id, propData in pairs(placedProps) do
        local dist = math.sqrt((playerCoords.x - propData.coords.x)^2 + (playerCoords.y - propData.coords.y)^2 + (playerCoords.z - propData.coords.z)^2)
        if dist < 5.0 then
            -- Remove from DB
            exports.oxmysql:execute('DELETE FROM wine_props WHERE coords = ?', {json.encode(propData.coords)}, function()
                placedProps[id] = nil
                TriggerClientEvent('wine:removeProp', -1, id)
                -- Add item back
                player.Functions.AddItem(Config.CraftingItem, 1)
                TriggerClientEvent('ox_lib:notify', source, { title = 'Picked Up', description = 'Wooden wine barrel picked up', type = 'info' })
            end)
            propFound = true
            break
        end
    end

    if not propFound then
        TriggerClientEvent('ox_lib:notify', source, { title = 'No Prop', description = 'No prop found nearby', type = 'error' })
    end
end)

-- Event: Crafting canceled, refund ingredients
RegisterNetEvent('wine:craftingCanceled', function(recipeKey, recipe)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Refund ingredients
    for item, req in pairs(recipe.ingredients) do
        player.Functions.AddItem(item, req.amount)
    end

    TriggerClientEvent('ox_lib:notify', source, { title = 'Refunted', description = 'Ingredients refunded due to cancel', type = 'info' })
end)

-- Event: Sell wine
RegisterNetEvent('wine:sellWine', function(wineType, amount, price)
    local source = source
    local player = QBOXCore.Functions.GetPlayer(source)
    if not player then return end

    -- Check if player has enough wine
    local item = player.Functions.GetItemByName(wineType)
    if not item or item.amount < amount then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Not Enough', description = 'You don\'t have enough wine', type = 'error' })
        return
    end

    -- Remove wine
    player.Functions.RemoveItem(wineType, amount)

    -- Add money
    local total = amount * price
    player.Functions.AddMoney('cash', total)

    TriggerClientEvent('ox_lib:notify', source, { title = 'Sold', description = ('Sold %dx %s for $%d'):format(amount, wineType:gsub('_', ' '), total), type = 'success' })
    SendDiscordLog('Wine Sold', ('Player %s sold %dx %s for $%d'):format(source, amount, wineType, total))
end)
