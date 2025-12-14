-- Usables handled via sprinkles inventory

-- Event to handle drinking
RegisterNetEvent('wine:drinkWine', function(wineItem, sip)
    local effects = ApplyAgingBonus(wineItem.name, wineItem.metadata or {})

    if sip then
        -- Sip: partial effects
        effects.duration = effects.duration * Config.SipEffectMultiplier
        effects.strength = effects.strength * Config.SipEffectMultiplier
    end

    -- Animation
    local animDict = 'mp_player_intdrink'
    local animClip = 'loop'
    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animClip, 8.0, -8.0, effects.duration or 5000, 1, 0, false, false, false)

    -- Spawn prop
    local prop = effects.prop
    lib.requestModel(prop)
    local coords = GetEntityCoords(cache.ped)
    local propEntity = CreateObject(prop, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(propEntity, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.13, -0.02, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)

    -- Apply effects
    if Config.EnableWineConsumption then
        if effects.type == 'drunk' then
            lib.notify({ title = 'Drinking', description = 'You feel the effects coming...', type = 'info' })
            -- Apply drunk effects immediately
            -- Screen effects removed due to invalid GTA V effects
            SetPedMotionBlur(cache.ped, true)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', effects.strength)
            -- Clear after duration
            SetTimeout(effects.duration, function()
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(true)
            end)
        elseif effects.type == 'buff' then
            -- Buff effect, perhaps speed or strength increase
            SetRunSprintMultiplierForPlayer(cache.ped, effects.strength + 1.0)
            -- Screen effects removed due to invalid GTA V effects
            SetTimeout(effects.duration, function()
                SetRunSprintMultiplierForPlayer(cache.ped, 1.0)
            end)
        end
    else
        lib.notify({ title = 'Drinking', description = 'Passed to external consumption system', type = 'info' })
    end

    -- Remove prop after animation
    SetTimeout(effects.duration, function()
        DeleteEntity(propEntity)
    end)

    -- Log
    SendDiscordLog('Wine Consumed', ('Player %s drank %s (%s)'):format(cache.serverId, wineItem.label, sip and 'sip' or 'full'))

    if sip then
        lib.notify({ title = 'Sipped', description = 'You took a sip from the bottle', type = 'info' })
    else
        lib.notify({ title = 'Finished', description = 'You finished the wine', type = 'success' })
    end
end)

-- Handle player death, remove effects if needed
AddEventHandler('esx:onPlayerDeath', function(data)
    ClearTimecycleModifier()
    SetPedMotionBlur(cache.ped, false)
    StopGameplayCamShaking(true)
    SetRunSprintMultiplierForPlayer(cache.ped, 1.0)
end)
