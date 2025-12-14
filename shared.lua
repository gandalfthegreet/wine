local QBOXCore = exports['qb-core']:GetCoreObject()

-- Utility: Generate random coords within zone
function GenerateGrapeCoords(zone)
    local center = zone.center
    local radius = zone.radius
    local attempts = 0
    local maxAttempts = 10
    while attempts < maxAttempts do
        local x = center.x + math.random(-radius, radius)
        local y = center.y + math.random(-radius, radius)
        local z = center.z + 10.0 -- search above
        local success, groundZ = GetGroundZFor_3dCoord(x, y, z, true)
        if success then
            return vector3(x, y, groundZ)
        end
        attempts = attempts + 1
    end
    return center -- fallback
end

-- Utility: Check if player has job (if required)
function HasRequiredJob(source)
    if not Config.RequiredJob then return true end
    local player = QBOXCore.Functions.GetPlayer(source)
    return player.PlayerData.job.name == Config.RequiredJob
end

-- Utility: Check aging bonus
function IsWineAged(metadata)
    if not metadata.created then return false end
    local createdTime = metadata.created
    local currentTime = os.time()
    return (currentTime - createdTime) >= Config.AgingTime
end

-- Utility: Apply aging bonus to effects
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

-- Utility: Discord logging function
function SendDiscordLog(title, message, color)
    if Config.DiscordWebhook == '' then return end
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or 16744192, -- Orange
            ["footer"] = {
                ["text"] = "Wine Script Log",
                ["icon_url"] = "https://i.imgur.com/removed.png" -- Placeholder
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Wine Script", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
