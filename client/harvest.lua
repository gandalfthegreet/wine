-- Cache for pick points (used for cooldowns)
local activePickPoints = {}
local pickCooldowns = {}
local zoneTargetIds = {} -- Track ox_target zone IDs
-- Global mapping for job system
_G.pointToZone = {}

-- Function to create targets for a specific zone
function CreateZoneTargets(zoneKey)
    local zone = Config.VineyardZones[zoneKey]
    if not zone then print('[Wine] Zone not found: ' .. zoneKey) return end

    -- Clean existing targets for this zone
    if zoneTargetIds[zoneKey] then
        for _, zoneId in ipairs(zoneTargetIds[zoneKey]) do
            exports.ox_target:removeZone(zoneId)
        end
        zoneTargetIds[zoneKey] = {}
    end

    local selectedCoords = {}
    local coordsList = zone.coords
    local numToSelect = zone.randompickpoints or #coordsList

    if numToSelect >= #coordsList then
        selectedCoords = coordsList
    else
        local shuffled = {}
        for _, v in ipairs(coordsList) do table.insert(shuffled, v) end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        for i = 1, numToSelect do
            selectedCoords[i] = shuffled[i]
        end
    end

    zoneTargetIds[zoneKey] = {}

    for i, coords in ipairs(selectedCoords) do
        local pointKey = zoneKey .. '_' .. i
        _G.pointToZone[pointKey] = zoneKey -- Map point to zone for job system
        activePickPoints[pointKey] = {
            coords = coords,
            zone = zone,
            active = true
        }

        local zoneId = exports.ox_target:addSphereZone({
            coords = coords,
            radius = 3.0,
            debug = Config.Debug, -- Enable visual spheres if debug true
            options = {{
                label = 'Pick ' .. Config.Grapes[zone.grapeType].label,
                icon = 'fa-solid fa-leaf',
                distance = 3.0,
                canInteract = function()
                    return activePickPoints[pointKey] and activePickPoints[pointKey].active and not pickCooldowns[pointKey]
                end,
                onSelect = function()
                    TriggerServerEvent('wine:pickGrape', pointKey, zoneKey, zone)
                end
            }}
        })

        table.insert(zoneTargetIds[zoneKey], zoneId)
        print('[Wine Debug] Added harvest zone: ' .. pointKey .. ' at ' .. tostring(coords))
    end
    _G.activeZonePoints[zoneKey] = #selectedCoords -- Store total active points per zone
end

-- Function to remove targets for a specific zone
function RemoveZoneTargets(zoneKey)
    if zoneTargetIds[zoneKey] then
        for _, zoneId in ipairs(zoneTargetIds[zoneKey]) do
            exports.ox_target:removeZone(zoneId)
        end
        zoneTargetIds[zoneKey] = nil

        -- Remove active points for this zone
        for pointKey, _ in pairs(_G.pointToZone) do
            if _G.pointToZone[pointKey] == zoneKey then
                activePickPoints[pointKey] = nil
            end
        end
    end
end

-- Pre-calculate zone point counts on load
CreateThread(function()
    Wait(1000)
    _G.activeZonePoints = {}
    for zoneKey, zone in pairs(Config.VineyardZones) do
        local numToSelect = zone.randompickpoints or #zone.coords
        _G.activeZonePoints[zoneKey] = numToSelect >= #zone.coords and #zone.coords or numToSelect
    end
end)

-- Event: Start picking
RegisterNetEvent('wine:startPicking', function(pointKey, zone)
    local difficulty = Config.Difficulties[zone.difficulty]

    -- Start animation
    local animDict = zone.animDict
    local animClip = zone.animClip
    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animClip, 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Skill check using ox_lib
    if lib.progressCircle({
        duration = difficulty.minigameTime,
        label = 'Picking grapes...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true },
    }) then
        -- Send success to server
        local success = math.random() < difficulty.successChance
        TriggerServerEvent('wine:completePick', pointKey, zone, success)
        if success then
            -- Deactivate point for cooldown
            activePickPoints[pointKey].active = false
            pickCooldowns[pointKey] = true
            -- Particle effect: dust
            UseParticleFxAsset('core')
            StartParticleFxNonLoopedAtCoord('bul_grass', activePickPoints[pointKey].coords.x, activePickPoints[pointKey].coords.y, activePickPoints[pointKey].coords.z + 0.1, 0.0, 0.0, 0.0, 2.0, false, false, false)
            SetTimeout(Config.PickCooldown * 1000, function()
                activePickPoints[pointKey].active = true
                pickCooldowns[pointKey] = nil
            end)
        end
    else
        -- Cancelled
        ClearPedTasks(cache.ped)
    end
    ClearPedTasks(cache.ped)
end)

-- Debug drawing thread (only when Debug enabled)
CreateThread(function()
    while true do
        if Config.Debug then
            for pointKey, point in pairs(activePickPoints) do
                local color = point.active and { r = 0, g = 255, b = 0, a = 100 } or { r = 255, g = 0, b = 0, a = 100 }
                DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, color.r, color.g, color.b, color.a, false, false, 2, false, nil, nil, false)
                if Vdist(GetEntityCoords(cache.ped), point.coords) < 10.0 then
                    DrawText3D(point.coords.x, point.coords.y, point.coords.z + 0.5, '[' .. pointKey .. '] ' .. (point.active and 'Active' or 'Cooldown'), color.r, color.g, color.b)
                end
            end
        end
        Wait(0)
    end
end)

-- Helper function to draw 3D text
function DrawText3D(x, y, z, text, r, g, b)
    SetTextScale(0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(r, g, b, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = string.len(text) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
