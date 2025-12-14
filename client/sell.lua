-- Wine Seller NPC
local sellerNpc = nil
local sellerTargetOptions = {}

CreateThread(function()
    -- Spawn NPC
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
end)

-- Sell Menu
function OpenSellMenu()
    local sellOptions = {}
    for wineType, price in pairs(Config.WineBuyer.prices) do
        local count = exports.ox_inventory:Search('count', wineType)
        if count > 0 then
            table.insert(sellOptions, {
                title = wineType:gsub('_', ' '):gsub('wine ', ''),
                description = ('You have %dx ($%d each)'):format(count, price),
                onSelect = function()
                    local input = lib.inputDialog('Sell Wine', {
                        {type = 'number', label = 'Amount', min = 1, max = count, required = true}
                    })
                    if input and input[1] then
                        local amount = input[1]
                        TriggerServerEvent('wine:sellWine', wineType, amount, price)
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
