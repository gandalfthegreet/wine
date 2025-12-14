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

        -- Job progression: track completion
        local job = PlayerJobs[src]
        if job and job.currentZone == zoneKey then
            local zonePoints = job.completedPoints[job.currentZone] or {}
            zonePoints[pointKey] = true
            job.completedPoints[job.currentZone] = zonePoints

            -- Check if zone is complete
            local requiredCount = job.totalPointsRequired and job.totalPointsRequired[job.currentZone] or #zone.coords
            if #zonePoints >= requiredCount then
                TriggerClientEvent('wine:zoneCompleted', src)
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Failed', description = 'You damaged the grapes!', type = 'error' })
    end
end)

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
