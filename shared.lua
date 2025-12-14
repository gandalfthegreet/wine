local QBCore = exports['qb-core']:GetCoreObject()

-- Generate random coords within zone (legacy)
function GenerateGrapeCoords(zone)
    local center = zone.center
    local radius = zone.radius
    local attempts = 0
    local maxAttempts = 10
    while attempts < maxAttempts do
        local x = center.x + math.random(-radius, radius)
        local y = center.y + math.random(-radius, radius)
        local z = center.z + 10.0
        local success, groundZ = GetGroundZFor_3dCoord(x, y, z, true)
        if success then
            return vector3(x, y, groundZ)
        end
        attempts = attempts + 1
    end
    return center
end

-- Check if player has required job
function HasRequiredJob(source)
    if not Config.RequiredJob then return true end
    local player = QBCore.Functions.GetPlayer(source)
    return player.PlayerData.job.name == Config.RequiredJob
end

-- Check if wine is aged
function IsWineAged(metadata)
    if not metadata.created then return false end
    return (os.time() - metadata.created) >= Config.AgingTime
end

-- Apply aging bonus to effects
function ApplyAgingBonus(wineType, metadata)
    local effects = Config.Effects[wineType]
    if not effects or not IsWineAged(metadata) then return effects end
    return {
        type = effects.type,
        duration = effects.duration * Config.AgedBonus.durationMultiplier,
        strength = effects.strength * Config.AgedBonus.strengthMultiplier,
        screenEffect = effects.screenEffect,
        animation = effects.animation,
        prop = effects.prop
    }
end

-- Discord logging
function SendDiscordLog(title, message, color)
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end
    local embed = {{
        ["title"] = title,
        ["description"] = message,
        ["color"] = color or 16744192,
        ["footer"] = { ["text"] = "Wine Script" },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
    PerformHttpRequest(Config.DiscordWebhook, function(err) end, 'POST', json.encode({username = "Wine Script", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
