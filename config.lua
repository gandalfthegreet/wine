Config = {
    -- Vineyard Zones with predefined coords
    VineyardZones = {
    ['red_zone'] = {
            coords = {
                vec3(-1970.96, 1938.14, 169.88), vec3(-1947.93, 1925.14, 170.91), vec3(-1936.75, 1918.63, 170.94),
                vec3(-1923.62, 1910.88, 170.23), vec3(-1914.37, 1905.55, 168.76), vec3(-1921.64, 1904.61, 171.29),
                vec3(-1933.19, 1911.52, 172.3), vec3(-1923.93, 1900.8, 173.36), vec3(-1978.57, 1952.83, 163.32),
                vec3(-1965.27, 1945.33, 164.73), vec3(-1950.37, 1936.85, 165.92), vec3(-1935.54, 1928.19, 166.95),
                vec3(-1927.94, 1924.07, 166.78), vec3(-1922.72, 1920.92, 166.56), vec3(-1914.84, 1916.27, 166.51),
                vec3(-1905.54, 1911.12, 165.91)
            },
            randompickpoints = 6,
            grapeType = 'cabernet_sauvignon',
            difficulty = 'hard',
            animDict = 'amb@world_human_gardener_plant@male@base',
            animClip = 'base',
            particleFx = 'core'
        },
        ['white_zone'] = {
            coords = {
                vec3(-1894.28, 1919.7, 160.58), vec3(-1900.05, 1923.26, 160.9), vec3(-1908.14, 1927.99, 161.07),
                vec3(-1918.09, 1933.72, 161.47), vec3(-1929.36, 1940.13, 161.45), vec3(-1940.48, 1946.37, 159.53),
                vec3(-1947.51, 1950.76, 158.3), vec3(-1957.56, 1956.1, 157.17), vec3(-1967.09, 1961.69, 156.39),
                vec3(-1939.86, 1956.73, 154.31), vec3(-1927.14, 1949.29, 156.83), vec3(-1916.02, 1942.79, 157.92),
                vec3(-1905.05, 1936.52, 157.46), vec3(-1895.5, 1931.16, 157.24), vec3(-1880.6, 1922.74, 156.94),
                vec3(-1877.24, 1930.9, 153.08), vec3(-1892.73, 1939.79, 153.41), vec3(-1905.19, 1946.96, 153.69),
                vec3(-1916.2, 1953.22, 153.37), vec3(-1922.52, 1957.11, 152.28), vec3(-1913.52, 1962.58, 149.41),
                vec3(-1899.25, 1954.06, 150.28), vec3(-1886.2, 1946.51, 149.94), vec3(-1873.11, 1938.82, 149.72),
                vec3(-1864.18, 1933.61, 149.64), vec3(-1896.45, 1962.71, 146.59), vec3(-1902.14, 1966.08, 146.33)
            },
            randompickpoints = 15,
            grapeType = 'chardonnay',
            difficulty = 'medium',
            animDict = 'amb@world_human_gardener_plant@male@base',
            animClip = 'base',
            particleFx = 'core'
        },
        ['merlot_zone'] = {
            coords = {
                vec3(-1937.41, 1869.3, 177.24), vec3(-1930.23, 1874.14, 174.93), vec3(-1924.92, 1878.33, 172.83),
                vec3(-1915.13, 1885.04, 170.31), vec3(-1909.74, 1888.9, 168.41), vec3(-1903.85, 1893.14, 166.64),
                vec3(-1899.01, 1896.13, 165.71), vec3(-1944.67, 1853.61, 177.43), vec3(-1941.46, 1855.93, 176.62),
                vec3(-1936.22, 1859.55, 174.96), vec3(-1933.51, 1861.38, 174.03), vec3(-1929.31, 1864.2, 172.87),
                vec3(-1926.17, 1866.46, 171.99), vec3(-1906.19, 1880.36, 165.81), vec3(-1900.98, 1884.03, 164.52),
                vec3(-1897.16, 1886.62, 163.66), vec3(-1893.02, 1889.61, 162.74), vec3(-1889.35, 1892.24, 161.87),
                vec3(-1881.58, 1897.48, 159.79), vec3(-1875.84, 1901.61, 158.0), vec3(-1865.88, 1908.24, 154.79),
                vec3(-1859.05, 1912.8, 152.6), vec3(-1854.75, 1916.05, 151.13), vec3(-1848.67, 1909.45, 148.86),
                vec3(-1857.52, 1903.45, 151.69), vec3(-1879.89, 1887.58, 158.03), vec3(-1893.93, 1878.16, 161.74),
                vec3(-1908.18, 1867.92, 164.99), vec3(-1926.38, 1855.02, 170.02), vec3(-1936.53, 1848.36, 172.97),
                vec3(-1944.83, 1842.11, 175.32), vec3(-1944.13, 1831.87, 173.11), vec3(-1934.86, 1838.32, 170.09),
                vec3(-1926.76, 1843.83, 167.73), vec3(-1915.58, 1851.38, 164.55), vec3(-1906.79, 1858.06, 162.59),
                vec3(-1897.34, 1864.43, 160.48), vec3(-1884.93, 1873.35, 158.16), vec3(-1873.93, 1881.02, 154.59),
                vec3(-1861.12, 1890.23, 150.91), vec3(-1852.06, 1896.16, 148.55), vec3(-1844.56, 1901.6, 146.53)
            },
            randompickpoints = 25,
            grapeType = 'merlot',
            difficulty = 'easy',
            animDict = 'amb@world_human_gardener_plant@male@base',
            animClip = 'base',
            particleFx = 'core'
        },
        ['sauvignon_zone'] = {
            coords = {
                vec3(-1782.76, 1928.43, 131.91), vec3(-1775.94, 1940.22, 129.32), vec3(-1769.6, 1950.57, 126.36),
                vec3(-1765.15, 1958.67, 123.45), vec3(-1757.86, 1970.72, 119.79), vec3(-1749.02, 1967.98, 121.12),
                vec3(-1754.41, 1958.89, 124.73), vec3(-1757.62, 1953.14, 126.74), vec3(-1764.32, 1941.69, 130.47),
                vec3(-1768.34, 1934.54, 132.64), vec3(-1773.27, 1925.84, 135.07), vec3(-1777.51, 1919.1, 136.5),
                vec3(-1780.64, 1913.74, 137.9), vec3(-1777.61, 1901.1, 143.79), vec3(-1773.91, 1907.26, 141.8),
                vec3(-1768.33, 1916.71, 139.27), vec3(-1761.17, 1929.32, 135.74), vec3(-1756.98, 1936.58, 133.48),
                vec3(-1753.71, 1941.79, 131.74), vec3(-1750.55, 1947.85, 129.54), vec3(-1745.37, 1956.23, 125.44),
                vec3(-1742.17, 1961.65, 122.67), vec3(-1730.97, 1945.13, 129.21), vec3(-1734.98, 1937.99, 133.53),
                vec3(-1739.22, 1930.94, 137.1), vec3(-1745.68, 1919.93, 141.76), vec3(-1752.32, 1908.5, 144.9),
                vec3(-1757.48, 1899.62, 147.06), vec3(-1761.18, 1892.9, 148.88), vec3(-1752.26, 1891.37, 151.18),
                vec3(-1748.28, 1897.83, 149.52), vec3(-1743.75, 1905.23, 147.57), vec3(-1738.95, 1913.98, 145.07),
                vec3(-1731.63, 1926.07, 139.29), vec3(-1722.95, 1923.78, 140.38), vec3(-1730.13, 1910.63, 147.09),
                vec3(-1735.91, 1900.63, 150.82), vec3(-1740.03, 1893.61, 152.28), vec3(-1737.31, 1889.86, 154.58),
                vec3(-1731.06, 1900.52, 151.77), vec3(-1725.93, 1909.39, 147.83), vec3(-1721.59, 1916.41, 144.52),
                vec3(-1714.55, 1910.82, 147.95), vec3(-1717.6, 1905.65, 150.15), vec3(-1720.74, 1899.91, 152.65),
                vec3(-1724.2, 1894.25, 154.98), vec3(-1720.23, 1891.98, 156.4), vec3(-1717.17, 1896.96, 154.34),
                vec3(-1712.78, 1904.93, 151.01), vec3(-1709.85, 1909.81, 148.84)
            },
            randompickpoints = 35,
            grapeType = 'sauvignon_blanc',
            difficulty = 'medium',
            animDict = 'amb@world_human_gardener_plant@male@base',
            animClip = 'base',
            particleFx = 'core'
        },
        ['rose_zone'] = {
            coords = {
                vec3(-1690.8, 1946.35, 135.07), vec3(-1690.28, 1951.07, 133.23), vec3(-1689.53, 1959.44, 131.03),
                vec3(-1688.8, 1966.36, 129.24), vec3(-1696.39, 1929.85, 142.44), vec3(-1695.92, 1938.28, 138.4),
                vec3(-1695.37, 1943.21, 136.19), vec3(-1694.95, 1947.32, 134.46), vec3(-1694.42, 1952.58, 132.68),
                vec3(-1694.29, 1956.82, 131.53), vec3(-1693.47, 1964.3, 129.53), vec3(-1693.02, 1970.09, 127.9),
                vec3(-1692.28, 1979.3, 126.26), vec3(-1691.32, 1988.62, 124.2), vec3(-1690.76, 1996.66, 121.9),
                vec3(-1689.89, 2006.5, 118.68), vec3(-1689.26, 2011.75, 116.83), vec3(-1691.95, 2033.18, 111.69),
                vec3(-1692.43, 2026.54, 113.01), vec3(-1693.07, 2020.76, 114.4), vec3(-1693.92, 2014.6, 116.3),
                vec3(-1694.3, 2006.0, 119.18), vec3(-1695.02, 2001.18, 120.69), vec3(-1695.69, 1993.08, 122.77),
                vec3(-1696.47, 1982.11, 125.39), vec3(-1697.47, 1970.86, 127.45), vec3(-1698.27, 1962.18, 129.64),
                vec3(-1699.54, 1948.31, 133.63), vec3(-1700.36, 1938.38, 137.43), vec3(-1700.94, 1931.48, 141.01),
                vec3(-1709.46, 1935.74, 136.9), vec3(-1708.82, 1943.12, 133.35), vec3(-1708.15, 1950.95, 130.2),
                vec3(-1707.26, 1959.26, 128.27), vec3(-1706.56, 1969.77, 125.99), vec3(-1705.87, 1977.67, 124.33),
                vec3(-1704.54, 1990.54, 121.83), vec3(-1703.76, 2000.18, 120.3), vec3(-1702.17, 2018.46, 115.14),
                vec3(-1701.63, 2024.91, 113.43), vec3(-1700.6, 2035.43, 110.75), vec3(-1705.37, 2034.53, 111.2),
                vec3(-1705.81, 2028.35, 112.69), vec3(-1706.67, 2019.96, 114.74), vec3(-1707.89, 2007.32, 118.28),
                vec3(-1708.4, 1998.15, 120.17), vec3(-1709.71, 1989.83, 121.36), vec3(-1710.22, 1983.64, 122.35),
                vec3(-1710.98, 1972.87, 124.63), vec3(-1712.39, 1956.13, 127.61), vec3(-1713.24, 1947.26, 130.34),
                vec3(-1721.44, 1957.62, 125.24), vec3(-1719.56, 1978.95, 121.91), vec3(-1718.31, 1992.57, 119.47),
                vec3(-1716.18, 2014.7, 115.56), vec3(-1714.85, 2030.35, 112.05), vec3(-1726.27, 2007.33, 115.42),
                vec3(-1726.97, 1994.67, 117.87), vec3(-1728.55, 1975.51, 121.01), vec3(-1733.25, 1976.24, 119.9),
                vec3(-1732.72, 1981.46, 119.22), vec3(-1732.05, 1992.09, 117.51), vec3(-1736.55, 1991.47, 116.92),
                vec3(-1737.82, 1978.09, 118.81)
            },
            randompickpoints = 45,
            grapeType = 'rose',
            difficulty = 'easy',
            animDict = 'amb@world_human_gardener_plant@male@base',
            animClip = 'base',
            particleFx = 'core'
        },
    },
    -- Cooldown for picking each point (seconds)
    PickCooldown = 600, -- 10 minutes
    -- Difficulty settings
    Difficulties = {
        ['easy'] = { minigameTime = 10000, successChance = 0.7 },
        ['medium'] = { minigameTime = 15000, successChance = 0.5 },
        ['hard'] = { minigameTime = 20000, successChance = 0.3 },
    },
    -- Grape items
    Grapes = {
        ['cabernet_sauvignon'] = { item = 'grape_cabernet', label = 'Cabernet Sauvignon Grapes', amount = 5 },
        ['chardonnay'] = { item = 'grape_chardonnay', label = 'Chardonnay Grapes', amount = 5 },
        ['merlot'] = { item = 'grape_merlot', label = 'Merlot Grapes', amount = 4 },
        ['sauvignon_blanc'] = { item = 'grape_sauvignon', label = 'Sauvignon Blanc Grapes', amount = 4 },
        ['rose'] = { item = 'grape_rose', label = 'Rose Grapes', amount = 3 },
    },
    -- Crafting Prop
    CraftingProp = 'prop_wooden_barrel', -- Wine barrel
    CraftingItem = 'wooden_wine_barrel', -- Item to place prop
    CraftingCoords = nil,
    -- Crafting Recipes
    Recipes = {
        ['wine_cabernet'] = {
            ingredients = { ['grape_cabernet'] = { amount = 10, label = 'Cabernet Sauvignon Grapes' } },
            duration = 30000, -- 30s
            output = { item = 'wine_cabernet', amount = 1, label = 'Cabernet Sauvignon Wine', sips = 5 }
        },
        ['wine_chardonnay'] = {
            ingredients = { ['grape_chardonnay'] = { amount = 10, label = 'Chardonnay Grapes' } },
            duration = 30000,
            output = { item = 'wine_chardonnay', amount = 1, label = 'Chardonnay Wine', sips = 5 }
        },
        ['wine_merlot'] = {
            ingredients = { ['grape_merlot'] = { amount = 8, label = 'Merlot Grapes' } },
            duration = 25000,
            output = { item = 'wine_merlot', amount = 1, label = 'Merlot Wine', sips = 5 }
        },
        ['wine_sauvignon'] = {
            ingredients = { ['grape_sauvignon'] = { amount = 8, label = 'Sauvignon Blanc Grapes' } },
            duration = 25000,
            output = { item = 'wine_sauvignon', amount = 1, label = 'Sauvignon Blanc Wine', sips = 5 }
        },
        ['wine_rose'] = {
            ingredients = { ['grape_rose'] = { amount = 6, label = 'Rose Grapes' } },
            duration = 20000,
            output = { item = 'wine_rose', amount = 1, label = 'Rose Wine', sips = 5 }
        },
        ['wine_red_blend'] = {
            ingredients = { ['grape_cabernet'] = { amount = 5, label = 'Cabernet Sauvignon Grapes' }, ['grape_merlot'] = { amount = 5, label = 'Merlot Grapes' } },
            duration = 40000,
            output = { item = 'wine_red_blend', amount = 1, label = 'Red Blend Wine', sips = 5 }
        },
        ['wine_white_blend'] = {
            ingredients = { ['grape_chardonnay'] = { amount = 5, label = 'Chardonnay Grapes' }, ['grape_sauvignon'] = { amount = 5, label = 'Sauvignon Blanc Grapes' } },
            duration = 40000,
            output = { item = 'wine_white_blend', amount = 1, label = 'White Blend Wine', sips = 5 }
        },
    },
    -- Aging Bonuses (after 7 days in inventory)
    AgingTime = 604800, -- 7 days in seconds
    AgedBonus = { durationMultiplier = 1.5, strengthMultiplier = 1.25, valueMultiplier = 1.5 },
    -- Drinking Effects
    Effects = {
        ['wine_cabernet'] = { type = 'drunk', duration = 30000, strength = 1.0, screenEffect = 'DrugsDrivingIn', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_02', base_sips = 5 },
        ['wine_chardonnay'] = { type = 'buff', duration = 20000, strength = 0.5, screenEffect = 'PPGreen', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_01', base_sips = 5 },
        ['wine_merlot'] = { type = 'drunk', duration = 25000, strength = 0.75, screenEffect = 'InchPurple', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_02', base_sips = 5 },
        ['wine_sauvignon'] = { type = 'buff', duration = 15000, strength = 0.75, screenEffect = 'PPOrange', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_01', base_sips = 5 },
        ['wine_rose'] = { type = 'drunk', duration = 20000, strength = 0.5, screenEffect = 'Rampage', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_02', base_sips = 5 },
        ['wine_red_blend'] = { type = 'drunk', duration = 40000, strength = 1.25, screenEffect = 'DrugsMichaelAliensFight', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_02', base_sips = 5 },
        ['wine_white_blend'] = { type = 'buff', duration = 30000, strength = 1.0, screenEffect = 'PPPurple', animation = 'WORLD_HUMAN_DRINKING', prop = 'prop_wine_bot_01', base_sips = 5 },
    },
    -- Sip Settings
    SipEffectMultiplier = 0.5, -- partial effects per sip
    SipAnimation = 'WORLD_HUMAN_SMOKING_POT', -- shorter sip animation
-- Wine Buyer NPC
WineBuyer = {
    location = vec4(-1886.77, 2049.76, 139.98, 163.3),
    model = 'a_m_m_hillbilly_01', -- NPC model
    animations = { dict = 'mini@strip_club@idles@bouncer@base', clip = 'base' },
    prices = {
        ['wine_cabernet'] = 50,
        ['wine_chardonnay'] = 45,
        ['wine_merlot'] = 40,
        ['wine_sauvignon'] = 35,
        ['wine_rose'] = 30,
        ['wine_red_blend'] = 60,
        ['wine_white_blend'] = 55,
    }
},
    -- Logging
    DiscordWebhook = '', -- Replace with actual URL
    -- Debug: Enable harvest point visualization
    Debug = false,
    -- Wine: Enable built-in consumption effects (false for external food script handling)
    EnableWineConsumption = true,
    -- Job: Require specific job for harvesting/placing (nil to disable)
    RequiredJob = nil
}

-- ox_inventory Items (ensure added to ox_inventory config)
-- Grapes items: grape_cabernet, grape_chardonnay, grape_merlot, grape_sauvignon, grape_rose
-- Wine items: wine_cabernet, wine_chardonnay, wine_merlot, wine_sauvignon, wine_rose, wine_red_blend, wine_white_blend
-- Add for wine items: client = { event = 'wine:usage' }
-- Crafting item: wooden_wine_barrel client = { event = 'wine:placePropItem' }
