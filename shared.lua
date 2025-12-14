local QBCore = exports['qb-core']:GetCoreObject()

-- Job state per player
PlayerJobs = {}

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
