local QBCore = exports['qb-core']:GetCoreObject()
local placedProps = {}

local function LoadPlacedProps()
    exports.oxmysql:execute('CREATE TABLE IF NOT EXISTS wine_props (id INT AUTO_INCREMENT PRIMARY KEY, coords MEDIUMTEXT)', {}, function() end)
    exports.oxmysql:execute([[DELETE FROM wine_props WHERE coords IS NULL OR TRIM(coords) = '' OR NOT JSON_VALID(coords)]], {}, function()
        exports.oxmysql:query('SELECT coords FROM wine_props', {}, function(result)
            for _, row in ipairs(result) do
                if row.coords then
                    local ok, coords = pcall(json.decode, row.coords)
                    if ok and coords and coords.x and coords.y and coords.z then
                        SpawnCraftingProp(coords)
                    end
                end
            end
        end)
    end)
end

local function SpawnCraftingProp(coords)
    local id = #placedProps + 1
    local obj = CreateObjectNoOffset(Config.CraftingProp, coords.x, coords.y, coords.z, true, true, true)
    FreezeEntityPosition(obj, true)
    local netId = NetworkGetNetworkIdFromEntity(obj)
    placedProps[id] = { coords = coords, entity = obj, netId = netId }
    TriggerClientEvent(-1, 'wine:spawnPropNetId', id, netId)
end

LoadPlacedProps()

RegisterCommand('clearwineprops', function(source)
    if source ~= 0 then return TriggerClientEvent('ox_lib:notify', source, { title = 'Denied', description = 'Server only command', type = 'error' }) end
    for _, propData in pairs(placedProps) do
        if propData.entity and DoesEntityExist(propData.entity) then
            DeleteEntity(propData.entity)
        end
    end
    table.wipe(placedProps)
    exports.oxmysql:execute('TRUNCATE TABLE wine_props', {}, function()
        print('[Wine] Cleared all wine props from DB and entities')
        TriggerClientEvent('wine:clearProps', -1)
    end)
end, true)

RegisterNetEvent('wine:pickGrape', function(pointKey, zone)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not HasRequiredJob(src) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Access', type = 'error' })
        return
    end
    local grapeData = Config.Grapes[zone.grapeType]
    if not exports.ox_inventory:CanCarryItem(src, grapeData.item, grapeData.amount) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Inventory Full', type = 'error' })
        return
    end
    TriggerClientEvent('wine:startPicking', src, pointKey, zone)
end)

RegisterNetEvent('wine:completePick', function(pointKey, zone, success)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local grapeData = Config.Grapes[zone.grapeType]
    if success then
        player.Functions.AddItem(grapeData.item, grapeData.amount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Success', description = 'You picked ' .. grapeData.label, type = 'success' })
        SendDiscordLog('Grape Harvest', string.format('Player %s picked %s at zone', src, grapeData.label))
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'You damaged the grapes!', type = 'error' })
    end
end)

RegisterNetEvent('wine:craftWine', function(recipeKey, recipe)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not HasRequiredJob(src) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Access', type = 'error' })
        return
    end
    for item, req in pairs(recipe.ingredients) do
        if not player.Functions.GetItemByName(item) or player.Functions.GetItemByName(item).amount < req.amount then
            TriggerClientEvent('ox_lib:notify', src, { title = 'Missing Ingredients', type = 'error' })
            return
        end
    end
    for item, req in pairs(recipe.ingredients) do player.Functions.RemoveItem(item, req.amount) end
    TriggerClientEvent('wine:startCrafting', src, recipeKey, recipe)
    SendDiscordLog('Crafting Started', string.format('Player %s started crafting %s', src, recipeKey))
end)

RegisterNetEvent('wine:finishCrafting', function(recipeKey, recipe)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local output = recipe.output
    local metadata = { description = string.format('A bottle of %s', output.label), created = os.time(), sips_remaining = output.sips }
    if player.Functions.AddItem(output.item, output.amount, false, metadata) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Crafted', description = string.format('You crafted %s', output.label), type = 'success' })
        SendDiscordLog('Crafting Completed', string.format('Player %s completed crafting %s (sips: %d)', src, recipeKey, output.sips))
    else
        for item, req in pairs(recipe.ingredients) do player.Functions.AddItem(item, req.amount) end
        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'Inventory full, ingredients refunded', type = 'error' })
    end
end)

RegisterNetEvent('wine:useWine', function(wineItem)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local items = exports.ox_inventory:GetInventoryItems(src)
    local foundItem
    for slot, item in pairs(items) do
        if item.name == wineItem.name then
            foundItem = item
            foundItem.slot = slot
            break
        end
    end
    if not foundItem or foundItem.count < 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Error', type = 'error' })
        return
    end
    local metadata = foundItem.metadata or {}
    local maxSips = Config.Effects[wineItem.name] and Config.Effects[wineItem.name].base_sips or 5
    local isSip = metadata.sips_remaining == nil or metadata.sips_remaining > 1
    if metadata.sips_remaining then metadata.sips_remaining = isSip and metadata.sips_remaining - 1 or metadata.sips_remaining end
    if metadata.sips_remaining == nil and not isSip then metadata.sips_remaining = maxSips - 1; isSip = true end
    if isSip then
        exports.ox_inventory:SetMetadata(src, foundItem.slot, metadata)
    else
        player.Functions.RemoveItem(wineItem.name, 1, foundItem.slot)
    end
    TriggerClientEvent('wine:drinkWine', src, wineItem, isSip)
    SendDiscordLog('Wine Consumed', isSip and string.format('Player %s sipped %s', src, wineItem.label) or string.format('Player %s finished %s', src, wineItem.label))
end)

RegisterNetEvent('wine:placePropItem', function(coords)
    if not coords then return end
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not player.Functions.GetItemByName(Config.CraftingItem) or player.Functions.GetItemByName(Config.CraftingItem).amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Item', type = 'error' })
        return
    end
    player.Functions.RemoveItem(Config.CraftingItem, 1)
    exports.oxmysql:insert('INSERT INTO wine_props (coords) VALUES (?)', {json.encode(coords)}, function(id)
        if id then
            SpawnCraftingProp(coords)
            TriggerClientEvent('ox_lib:notify', src, { title = 'Placed', type = 'success' })
        else
            player.Functions.AddItem(Config.CraftingItem, 1)
            TriggerClientEvent('ox_lib:notify', src, { title = 'Error', type = 'error' })
        end
    end)
end)

RegisterNetEvent('wine:pickupProp', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    for id, propData in pairs(placedProps) do
        if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, propData.coords.x, propData.coords.y, propData.coords.z, true) < 5.0 then
            exports.oxmysql:execute('DELETE FROM wine_props WHERE coords = ?', {json.encode(propData.coords)}, function()
                if propData.entity and DoesEntityExist(propData.entity) then DeleteEntity(propData.entity) end
                placedProps[id] = nil
                TriggerClientEvent('wine:removeProp', -1, id)
                player.Functions.AddItem(Config.CraftingItem, 1)
                TriggerClientEvent('ox_lib:notify', src, { title = 'Picked Up', type = 'info' })
            end)
            return
        end
    end
    TriggerClientEvent('ox_lib:notify', src, { title = 'No Prop', type = 'error' })
end)

RegisterNetEvent('wine:craftingCanceled', function(recipeKey, recipe)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    for item, req in pairs(recipe.ingredients) do player.Functions.AddItem(item, req.amount) end
    TriggerClientEvent('ox_lib:notify', src, { title = 'Refunded', type = 'info' })
end)

RegisterNetEvent('wine:sellWine', function(wineType, amount, price)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not player.Functions.GetItemByName(wineType) or player.Functions.GetItemByName(wineType).amount < amount then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Not Enough', type = 'error' })
        return
    end
    player.Functions.RemoveItem(wineType, amount)
    local total = amount * price
    player.Functions.AddMoney('cash', total)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Sold', description = string.format('Sold %dx for $%d', amount, total), type = 'success' })
    SendDiscordLog('Wine Sold', string.format('Player %s sold %dx %s for $%d', src, amount, wineType, total))
end)
