-- NPC Variables
local sellerNpc = nil
local jobNpc = nil
local sellerTargetOptions = {}
-- Export activeJob globally so job.lua can access it
activeJob = false
local currentBlips = {}

CreateThread(function()
    -- Spawn Wine Buyer NPC
    if Config.WineBuyer.model then
        lib.requestModel(Config.WineBuyer.model)
        sellerNpc = CreatePed(4, Config.WineBuyer.model, Config.WineBuyer.location.x, Config.WineBuyer.location.y, Config.WineBuyer.location.z, Config.WineBuyer.location.w, false, true)
        SetEntityInvincible(sellerNpc, true)
        SetBlockingOfNonTemporaryEvents(sellerNpc, true)
        FreezeEntityPosition(sellerNpc, true)

        if Config.WineBuyer.animations.dict and Config.WineBuyer.animations.clip then
            lib.requestAnimDict(Config.WineBuyer.animations.dict)
            TaskPlayAnim(sellerNpc, Config.WineBuyer.animations.dict, Config.WineBuyer.animations.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
        end

        -- Add ox_target
        exports.ox_target:addLocalEntity(sellerNpc, {{
            label = 'Sell Wine',
            icon = 'fa-solid fa-dollar-sign',
            onSelect = function()
                OpenSellMenu()
            end
        }})
    end

    -- Spawn Job Manager PED
    if Config.JobManager.model then
        lib.requestModel(Config.JobManager.model)
        jobNpc = CreatePed(4, Config.JobManager.model, Config.JobManager.location.x, Config.JobManager.location.y, Config.JobManager.location.z, Config.JobManager.location.w, false, true)
        SetEntityInvincible(jobNpc, true)
        SetBlockingOfNonTemporaryEvents(jobNpc, true)
        FreezeEntityPosition(jobNpc, true)

        if Config.JobManager.animations.dict and Config.JobManager.animations.clip then
            lib.requestAnimDict(Config.JobManager.animations.dict)
            TaskPlayAnim(jobNpc, Config.JobManager.animations.dict, Config.JobManager.animations.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
        end

        -- Add ox_target options (both start and cancel available)
        exports.ox_target:addLocalEntity(jobNpc, {{
            name = 'wine_start_job',
            label = 'Start Wine Job',
            icon = 'fa-solid fa-solid fa-play',
            canInteract = function() return not activeJob end, -- Only show when no job
            onSelect = function()
                TriggerServerEvent('wine:startJob')
            end
        }, {
            name = 'wine_cancel_job',
            label = 'Cancel Wine Job',
            icon = 'fa-solid fa-stop',
            canInteract = function() return activeJob end, -- Only show when job active
            onSelect = function()
                TriggerServerEvent('wine:cancelJob')
            end
        }})
    end
end)

-- Sell Menu
function OpenSellMenu()
    local sellOptions = {}
    for wineType, price in pairs(Config.WineBuyer.prices) do
        -- Get wine count (works with non-stacked items)
        local wineCount = exports.ox_inventory:Search('count', wineType) or 0

        if wineCount > 0 then
            table.insert(sellOptions, {
                title = wineType:gsub('_', ' '):gsub('wine ', ''),
                description = ('You have %dx ($%d each)'):format(wineCount, price),
                onSelect = function()
                    local input = lib.inputDialog('Sell ' .. wineType:gsub('_', ' '):gsub('wine ', ' Wine'), {
                        {type = 'number', label = 'Amount', min = 1, max = wineCount, required = true}
                    })
                    if input and input[1] then
                        local amount = input[1]
                        TriggerServerEvent('wine:sellWineBatch', wineType, amount, price)
                    end
                end
            })
        end
    end

    if #sellOptions == 0 then
        lib.notify({ title = 'No Wine', description = 'You have no wine to sell', type = 'error' })
        return
    end

    lib.registerContext({
        id = 'wine_sell',
        title = 'Sell Wine',
        options = sellOptions
    })
    lib.showContext('wine_sell')
end

-- Remove NPC on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and DoesEntityExist(sellerNpc) then
        DeleteEntity(sellerNpc)
    end
end)
