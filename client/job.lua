-- Wine Job System
local currentZoneKey = nil
local completedPoints = {}
local zoneBlips = {}
local staticBlips = {}

-- Create static blips for crafting and shop when job active
local function CreateStaticBlips()
    -- Crafting locations
    for i, coords in ipairs(Config.CraftingLocations) do
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 50) -- wine bottle
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 45)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Wine Crafting")
        EndTextCommandSetBlipName(blip)
        table.insert(staticBlips, blip)
    end

    -- Wine shop
    local shopBlip = AddBlipForCoord(Config.WineBuyer.location.x, Config.WineBuyer.location.y, Config.WineBuyer.location.z)
    SetBlipSprite(shopBlip, 50) -- wine bottle
    SetBlipDisplay(shopBlip, 4)
    SetBlipScale(shopBlip, 0.7)
    SetBlipColour(shopBlip, 45)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Wine Shop")
    EndTextCommandSetBlipName(shopBlip)
    table.insert(staticBlips, shopBlip)
end

-- Clear all blips and waypoint
local function ClearAllBlips()
    for _, blip in ipairs(zoneBlips) do
        RemoveBlip(blip)
    end
    zoneBlips = {}

    for _, blip in ipairs(staticBlips) do
        RemoveBlip(blip)
    end
    staticBlips = {}

    -- Clear waypoint
    ClearGpsPlayerWaypoint()
    DeleteWaypoint()
end

-- Create zone grape waypoints
local function CreateZoneBlips(zoneKey)
    local zone = Config.VineyardZones[zoneKey]
    if not zone then return end

    local zoneCoords = zone.coords
    for i, coords in ipairs(zoneCoords) do
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 468) -- grape
        SetBlipDisplay(blip, 2) -- Show on minimap
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2) -- Green
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Grape Vine")
        EndTextCommandSetBlipName(blip)
        table.insert(zoneBlips, blip)
    end

    -- Set first waypoint
    SetNewWaypoint(zoneCoords[1].x, zoneCoords[1].y)
end

-- Event: Start job
RegisterNetEvent('wine:startJob', function(zoneKey, completed, zoneCounts)
    activeJob = true
    currentZoneKey = zoneKey
    completedPoints = completed or {}

    -- Store zone point counts from server
    _G.activeZonePoints = zoneCounts or _G.activeZonePoints

    -- Create harvest targets for current zone
    CreateZoneTargets(zoneKey)

    CreateZoneBlips(zoneKey)
    CreateStaticBlips()

    exports.ox_target:removeLocalEntity(jobNpc)
    exports.ox_target:addLocalEntity(jobNpc, {{
        label = 'Cancel Wine Job',
        icon = 'fa-solid fa-times',
        onSelect = function()
            TriggerServerEvent('wine:cancelJob')
        end
    }})

    lib.notify({ title = 'Job Started', description = 'You are now harvesting ' .. string.gsub(zoneKey, '_', ' '), type = 'success' })
end)

-- Event: Next zone
RegisterNetEvent('wine:nextZone', function(zoneKey, completed)
    -- Remove current zone targets
    if currentZoneKey then
        RemoveZoneTargets(currentZoneKey)
    end

    completedPoints = completed or {}
    currentZoneKey = zoneKey

    ClearAllBlips()
    CreateZoneTargets(zoneKey)
    CreateZoneBlips(zoneKey)
    CreateStaticBlips()

    lib.notify({ title = 'Next Zone', description = 'Moving to ' .. string.gsub(zoneKey, '_', ' '), type = 'info' })
end)

-- Event: Job completed
RegisterNetEvent('wine:jobDone', function()
    -- Remove harvest targets
    if currentZoneKey then
        RemoveZoneTargets(currentZoneKey)
    end

    ClearAllBlips()
    currentZoneKey = nil
    completedPoints = {}

    exports.ox_target:removeLocalEntity(jobNpc)
    exports.ox_target:addLocalEntity(jobNpc, {{
        label = 'Start Wine Job',
        icon = 'fa-solid fa-wine-bottle',
        onSelect = function()
            TriggerServerEvent('wine:startJob')
        end
    }})

    activeJob = false
    lib.notify({ title = 'Job Done', description = 'All zones completed!', type = 'success' })
end)

-- Event: Cancel job
RegisterNetEvent('wine:cancelJob', function()
    -- Remove harvest targets
    if currentZoneKey then
        RemoveZoneTargets(currentZoneKey)
    end

    ClearAllBlips()
    currentZoneKey = nil
    completedPoints = {}

    exports.ox_target:removeLocalEntity(jobNpc)
    exports.ox_target:addLocalEntity(jobNpc, {{
        label = 'Start Wine Job',
        icon = 'fa-solid fa-wine-bottle',
        onSelect = function()
            TriggerServerEvent('wine:startJob')
        end
    }})

    activeJob = false
    lib.notify({ title = 'Job Canceled', description = 'Wine job canceled', type = 'info' })
end)
