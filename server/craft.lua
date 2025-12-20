local QBCore = exports['qb-core']:GetCoreObject()

-- Get random zone for job
local function GetRandomZone(exclude)
    local zones = {}
    for key, _ in pairs(Config.VineyardZones) do
        if not exclude or not exclude[key] then
            table.insert(zones, key)
        end
    end
    if #zones == 0 then return nil end
    return zones[math.random(#zones)]
end

RegisterNetEvent('wine:pickGrape', function(pointKey, zoneKey, zone)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    -- Check if player has active job
    if not player or not PlayerJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Active Job', description = 'You need an active wine job to harvest', type = 'error' })
        return
    end
    local grapeData = Config.Grapes[zone.grapeType]
    if not exports.ox_inventory:CanCarryItem(src, grapeData.item, grapeData.amount) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Inventory Full', type = 'error' })
        return
    end
    TriggerClientEvent('wine:startPicking', src, pointKey, zoneKey, zone)
end)

RegisterNetEvent('wine:completePick', function(pointKey, zoneKey, zone, success)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local grapeData = Config.Grapes[zone.grapeType]
    if not grapeData then return end

    if not success then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'You damaged the grapes!', type = 'error' })
        return
    end

    -- Re-check right before giving (inventory may have changed while picking)
    if not exports.ox_inventory:CanCarryItem(src, grapeData.item, grapeData.amount) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Inventory Full', type = 'error' })
        return
    end

    -- Give grapes via ox_inventory (NOT QBCore AddItem)
    local added = exports.ox_inventory:AddItem(src, grapeData.item, grapeData.amount)
    if not added then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Inventory Full', type = 'error' })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Success',
        description = ('You picked %s'):format(grapeData.label),
        type = 'success'
    })

    SendDiscordLog('Grape Harvest', string.format('Player %s picked %s at zone', src, grapeData.label))

    -- Job progression: track completion (same logic you already had)
    local job = PlayerJobs[src]
    if job and job.currentZone == zoneKey then
        local zonePoints = job.completedPoints[job.currentZone] or {}
        zonePoints[pointKey] = true
        job.completedPoints[job.currentZone] = zonePoints

        -- Count completed points properly (since zonePoints is a table keyed by pointKey)
        local completedCount = 0
        for _ in pairs(zonePoints) do completedCount += 1 end

        local requiredCount = job.totalPointsRequired and job.totalPointsRequired[job.currentZone] or #zone.coords
        if completedCount >= requiredCount then
            TriggerClientEvent('wine:zoneCompleted', src)
        end
    end
end)

-- RegisterNetEvent('wine:completePick', function(pointKey, zone, success)
--     local src = source
--     local player = QBCore.Functions.GetPlayer(src)
--     if not player then return end
--     local grapeData = Config.Grapes[zone.grapeType]
--     if success then
--         player.Functions.AddItem(grapeData.item, grapeData.amount)
--         TriggerClientEvent('ox_lib:notify', src, { title = 'Success', description = 'You picked ' .. grapeData.label, type = 'success' })
--         SendDiscordLog('Grape Harvest', string.format('Player %s picked %s at zone', src, grapeData.label))

--         -- Job progression: track completion
--         local job = PlayerJobs[src]
--         if job and job.currentZone == zoneKey then
--             local zonePoints = job.completedPoints[job.currentZone] or {}
--             zonePoints[pointKey] = true
--             job.completedPoints[job.currentZone] = zonePoints

--             -- Check if zone is complete
--             local requiredCount = job.totalPointsRequired and job.totalPointsRequired[job.currentZone] or #zone.coords
--             if #zonePoints >= requiredCount then
--                 TriggerClientEvent('wine:zoneCompleted', src)
--             end
--         end
--     else
--         TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'You damaged the grapes!', type = 'error' })
--     end
-- end)

RegisterNetEvent('wine:craftWine', function(recipeKey, recipe)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Error', type = 'error' })
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
    if not output or not output.item or not output.amount then return end

    -- IMPORTANT: do NOT include "created=os.time()" or every bottle becomes unique and never stacks
    local metadata = {
        description = string.format('A bottle of %s', output.label or output.item),
        sips_remaining = output.sips or 5
    }

    -- Check room using ox_inventory
    if not exports.ox_inventory:CanCarryItem(src, output.item, output.amount) then
        -- refund ingredients
        for item, req in pairs(recipe.ingredients) do
            exports.ox_inventory:AddItem(src, item, req.amount)
        end

        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'Inventory full, ingredients refunded', type = 'error' })
        return
    end

    -- Add output via ox_inventory
    local added = exports.ox_inventory:AddItem(src, output.item, output.amount, metadata)
    if added then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Crafted', description = string.format('You crafted %s', output.label or output.item), type = 'success' })
        SendDiscordLog('Crafting Completed', string.format('Player %s completed crafting %s (sips: %d)', src, recipeKey, output.sips or 5))
    else
        -- refund ingredients
        for item, req in pairs(recipe.ingredients) do
            exports.ox_inventory:AddItem(src, item, req.amount)
        end

        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'Inventory full, ingredients refunded', type = 'error' })
    end
end)


RegisterNetEvent('wine:useWine', function(wineItem)
    local src = source
    if type(wineItem) ~= 'table' or not wineItem.name then return end

    local slot = wineItem.slot
    if not slot then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Error', description = 'Missing item slot.', type = 'error' })
        return
    end

    local items = exports.ox_inventory:GetInventoryItems(src)
    local found = items and items[slot]

    if not found or found.name ~= wineItem.name or (found.count or 0) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Error', description = 'Item not found in that slot.', type = 'error' })
        return
    end

    local metadata = found.metadata or {}
    local maxSips = (Config.Effects[wineItem.name] and Config.Effects[wineItem.name].base_sips) or 5
    local sips = tonumber(metadata.sips_remaining) or maxSips

    if sips > 1 then
        metadata.sips_remaining = sips - 1
        exports.ox_inventory:SetMetadata(src, slot, metadata)
        TriggerClientEvent('wine:drinkWine', src, wineItem, true)
    else
        -- remove bottle via ox_inventory (NOT QBCore)
        exports.ox_inventory:RemoveItem(src, wineItem.name, 1, nil, slot)
        TriggerClientEvent('wine:drinkWine', src, wineItem, false)
    end
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

RegisterNetEvent('wine:sellWineBatch', function(wineType, amount, price)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    -- Try to process the batch sale directly (QBCore handles inventory validation)
    local success = player.Functions.RemoveItem(wineType, amount)
    if success then
        local totalAmount = amount * price
        player.Functions.AddMoney('cash', totalAmount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Sold', description = string.format('Sold %dx %s for $%d', amount, wineType:gsub('_', ' '), totalAmount), type = 'success' })
        SendDiscordLog('Wine Batch Sold', string.format('Player %s sold %dx %s for $%d', src, amount, wineType, totalAmount))
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Sale Failed', description = 'Could not sell the wines', type = 'error' })
    end
end)

-- Job Management Events
RegisterNetEvent('wine:startJob', function()
    local src = source
    if PlayerJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Job Active', type = 'error' })
        return
    end

    -- Select random starting zone
    local zoneKey = GetRandomZone()
    if not zoneKey then
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Zones', type = 'error' })
        return
    end

    -- Calculate zone point counts
    local zoneCounts = {}
    for z, zone in pairs(Config.VineyardZones) do
        local numToSelect = zone.randompickpoints or #zone.coords
        zoneCounts[z] = numToSelect >= #zone.coords and #zone.coords or numToSelect
    end

    PlayerJobs[src] = {
        active = true,
        currentZone = zoneKey,
        completedZones = {},
        completedPoints = {},
        totalPointsRequired = zoneCounts
    }

    TriggerClientEvent('wine:startJob', src, zoneKey, {}, zoneCounts)
    SendDiscordLog('Job Started', string.format('Player %s started wine job in %s', src, zoneKey))
end)

RegisterNetEvent('wine:cancelJob', function()
    local src = source
    if not PlayerJobs[src] then return end

    PlayerJobs[src] = nil
    TriggerClientEvent('wine:cancelJob', src)
    SendDiscordLog('Job Canceled', string.format('Player %s canceled wine job', src))
end)

RegisterNetEvent('wine:zoneCompleted', function()
    local src = source
    local job = PlayerJobs[src]
    if not job then return end

    -- Mark zone as completed
    job.completedZones[job.currentZone] = true
    job.completedPoints[job.currentZone] = {}

    -- Find next zone
    local nextZone = GetRandomZone(job.completedZones)
    if not nextZone then
        -- All zones done
        PlayerJobs[src] = nil
        TriggerClientEvent('wine:jobDone', src)
        SendDiscordLog('Job Completed', string.format('Player %s completed all wine zones', src))
    else
        job.currentZone = nextZone
        TriggerClientEvent('wine:nextZone', src, nextZone, {})
    end
end)
