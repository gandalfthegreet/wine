-- client/craft.lua
-- Crafting + Picking progress handlers (ox_lib + ox_target)

local oxTarget = exports.ox_target
local oxInv = exports.ox_inventory

-- =========================
-- Helpers
-- =========================
local function getPickDurationFromDifficulty(difficulty)
    local diff = Config.Difficulties and Config.Difficulties[difficulty]
    return (diff and tonumber(diff.minigameTime)) or 5000
end

-- =========================
-- Crafting Targets
-- =========================
CreateThread(function()
    Wait(1000)

    for _, coords in ipairs(Config.CraftingLocations or {}) do
        oxTarget:addSphereZone({
            coords = coords,
            radius = 3.0,
            debug = false,
            options = {{
                label = 'Craft Wine',
                icon = 'fa-solid fa-wine-bottle',
                onSelect = function()
                    OpenCraftingMenu()
                end,
                distance = 3.0
            }}
        })
    end
end)

-- =========================
-- Crafting Menu (ox_lib)
-- =========================
function OpenCraftingMenu()
    local recipes = {}

    for recipeKey, recipe in pairs(Config.Recipes or {}) do
        local canCraft = true
        local reqs = {}

        for item, req in pairs(recipe.ingredients or {}) do
            local need = tonumber(req.amount) or 0
            local have = oxInv:GetItemCount(item)

            if have < need then
                canCraft = false
            end

            reqs[#reqs + 1] = (req.label or item) .. ' x' .. need
        end

        recipes[#recipes + 1] = {
            title = (recipe.output and (recipe.output.label or recipeKey)) or recipeKey,
            description = 'Requires: ' .. table.concat(reqs, ', '),
            disabled = not canCraft,
            onSelect = function()
                -- keep your original pattern: send recipeKey + recipe table
                TriggerServerEvent('wine:craftWine', recipeKey, recipe)
            end
        }
    end

    lib.registerContext({
        id = 'wine_crafting',
        title = 'Wine Crafting Menu',
        options = recipes
    })

    lib.showContext('wine_crafting')
end

-- =========================
-- Crafting Progress
-- =========================
RegisterNetEvent('wine:startCrafting', function(recipeKey, recipe)
    local duration = (recipe and tonumber(recipe.duration)) or 30000

    if lib.progressCircle({
        duration = duration,
        label = 'Crafting wine...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
    }) then
        TriggerServerEvent('wine:finishCrafting', recipeKey, recipe)
        lib.notify({ title = 'Crafted', description = 'Wine crafted successfully', type = 'success' })
    else
        TriggerServerEvent('wine:craftingCanceled', recipeKey, recipe)
        lib.notify({ title = 'Cancelled', description = 'Crafting cancelled, ingredients refunded', type = 'info' })
    end
end)

-- =========================
-- Picking Progress
-- =========================
RegisterNetEvent('wine:startPicking', function(pointKey, zoneKey, zone)
    -- duration comes from zone difficulty
    local duration = getPickDurationFromDifficulty(zone and zone.difficulty)

    local ok = lib.progressCircle({
        duration = duration,
        label = 'Picking grapes...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
    })

    -- Tell server outcome (server adds item via ox_inventory)
    TriggerServerEvent('wine:completePick', pointKey, zoneKey, zone, ok == true)
end)

RegisterNetEvent('wine:useWine', function(item)
    -- ox_inventory passes the used item data here (includes name/slot/metadata)
    TriggerServerEvent('wine:useWine', item)
end)

-- -- Setup fixed crafting locations on load
-- CreateThread(function()
--     Wait(1000)
--     for i, coords in ipairs(Config.CraftingLocations) do
--         exports.ox_target:addSphereZone({
--             coords = coords,
--             radius = 3.0,
--             debug = false,
--             options = {{
--                 label = 'Craft Wine',
--                 icon = 'fa-solid fa-wine-bottle',
--                 onSelect = OpenCraftingMenu,
--                 distance = 3.0
--             }}
--         })
--     end
-- end)

-- -- Crafting menu using ox_lib
-- function OpenCraftingMenu()
--     local recipes = {}
--     for recipeKey, recipe in pairs(Config.Recipes) do
--         -- Check if player has ingredients
--         local canCraft = true
--         for item, req in pairs(recipe.ingredients) do
--             local itemCount = exports.ox_inventory:GetItemCount(item)
--             if itemCount < req.amount then
--                 canCraft = false
--                 break
--             end
--         end
--         table.insert(recipes, {
--             title = recipeKey:gsub('_', ' '):gsub('wine ', ''),
--             description = function()
--                 local reqs = {}
--                 for item, req in pairs(recipe.ingredients) do
--                     table.insert(reqs, req.label .. ' x' .. req.amount)
--                 end
--                 return 'Requires: ' .. table.concat(reqs, ', ')
--             end,
--             disabled = not canCraft,
--             onSelect = function()
--                 TriggerServerEvent('wine:craftWine', recipeKey, recipe)
--             end
--         })
--     end

--         lib.registerContext({
--             id = 'wine_crafting',
--             title = 'Wine Crafting Menu',
--             options = recipes
--         })
--         lib.showContext('wine_crafting')
-- end

-- -- Event to handle crafting
-- RegisterNetEvent('wine:startCrafting', function(recipeKey, recipe)
--     if lib.progressCircle({
--         duration = recipe.duration,
--         label = 'Crafting wine...',
--         position = 'bottom',
--         useWhileDead = false,
--         canCancel = true,
--         disable = { car = true },
--     }) then
--         TriggerServerEvent('wine:finishCrafting', recipeKey, recipe)
--         lib.notify({ title = 'Crafted', description = 'Wine crafted successfully', type = 'success' })
--     else
--         -- Refund ingredients if canceled
--         TriggerServerEvent('wine:craftingCanceled', recipeKey, recipe)
--         lib.notify({ title = 'Cancelled', description = 'Crafting cancelled, ingredients refunded', type = 'info' })
--     end
-- end)
