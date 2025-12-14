# Wine Production Script

A comprehensive FiveMscript for wine production featuring harvesting, crafting, and sales with an immersive job system.

## Features

### 🍇 Harvesting System
- **169 predefined grape locations** across 5 vineyard zones (red, white, merlot, sauvignon, rose)
- **Dynamic difficulty scaling** with minigame mechanics
- **Cooldown system** (10-minute timers per point)
- **Animated harvesting** with particle effects

### 🏭 Crafting System
- **7 wine recipes** using harvested grapes
- **Progress-based crafting** with cancel/refund mechanics
- **Fixed crafting stations** with ox_target integration

### 🍷 Consumption & Effects
- **Sip-based drinking system** (5 sips per bottle)
- **Aging mechanics** with time-based bonuses
- **Personalized effects** (drunk, buff types with screen effects)
- **Inventory management** with metadata tracking

### 💼 Job System
- **Job Manager PED** for starting/stopping jobs
- **Zone progression** with map guidance
- **Dynamic target visibility** (harvest points only show when job active)
- **Completion rewards** and automatic zone advancement

### 💰 Economy Integration
- **NPC salesman** with configurable pricing
- **Sales tracking** and Discord webhook logging
- **Profit optimization** through aging mechanics

### 🔧 Technical Features
- **QBOX-Core framework** integration
- **ox_inventory, ox_lib, ox_target** compatibility
- **MySQL persistence** (optional for prop placements)
- **Scalable configuration** with debug options
- **Production-optimized** error handling

## Installation

1. **Place** the wine resource folder in your `resources/` directory
2. **Add** to your `server.cfg`: `ensure wine`
3. **Configure** inventory items in `ox_inventory/data/items.lua`
4. **Adjust** coordinates in `config.lua` for your server's location

## Configuration

### Required ox_inventory Items
Add these items to your ox_inventory config:

```lua
-- Grapes
['grape_cabernet'] = { label = 'Cabernet Sauvignon Grapes', weight = 100, stack = true, close = true },
['grape_chardonnay'] = { label = 'Chardonnay Grapes', weight = 100, stack = true, close = true },
['grape_merlot'] = { label = 'Merlot Grapes', weight = 100, stack = true, close = true },
['grape_sauvignon'] = { label = 'Sauvignon Blanc Grapes', weight = 100, stack = true, close = true },
['grape_rose'] = { label = 'Rose Grapes', weight = 100, stack = true, close = true },

-- Wines (all require consumption event)
['wine_cabernet'] = { label = 'Cabernet Sauvignon Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_chardonnay'] = { label = 'Chardonnay Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_merlot'] = { label = 'Merlot Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_sauvignon'] = { label = 'Sauvignon Blanc Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_rose'] = { label = 'Rose Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_red_blend'] = { label = 'Red Blend Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
['wine_white_blend'] = { label = 'White Blend Wine', weight = 200, stack = false, close = true, client = { event = 'wine:usage' } },
```

### Important Settings
- **Job Manager PED**: Change location in `Config.JobManager.location`
- **Crafting Station**: Modify `Config.CraftingLocations` to place your crafting spot
- **Vineyard Zones**: Customize harvest locations in `Config.VineyardZones`
- **Economy**: Adjust prices in `Config.WineBuyer.prices`

## Usage

### For Players:
1. **Start Job**: Talk to Job Manager PED and select "Start Wine Job"
2. **Follow Location**: Check GPS/map for grape vine waypoints
3. **Harvest**: Approach vines and use ox_target to pick grapes
4. **Craft**: Visit crafting station with grapes to make wine
5. **Sell**: Take wine to NPC salesman for profit
6. **Complete Zones**: Automatically advance through all 5 vineyard areas

### For Admins:
- `Config.Debug = true` - Enable visual sphere markers for testing
- Configure Discord webhook in `Config.DiscordWebhook` for logging
- Adjust difficulty, yields, and pricing to balance economy

## Files Structure

```
wine/
├── fxmanifest.lua       # Resource manifest
├── config.lua          # Main configuration
├── shared.lua          # Shared utilities
├── client/
│   ├── craft.lua       # Crafting interface & targets
│   ├── harvest.lua     # Harvesting system
│   ├── drink.lua       # Wine consumption
│   ├── sell.lua        # NPC management & selling
│   └── job.lua         # Job system & map guidance
├── server/
│   └── craft.lua       # Server-side logic
└── README.md           # This documentation
```

## Dependencies

- **qb-core** - Essential framework
- **ox_inventory** - Item management
- **ox_lib** - UI components
- **ox_target** - Target system
- **oxmysql** - Database (optional)

## Server Compatibility

Tested with:
- QBOX-Core
- ox_inventory
- OneSync Legacy/Infinity
- MySQL/MariaDB

## Support

For issues or questions, check your server console for debug messages and ensure all dependencies are properly loaded.

---

**Version**: 1.0.0
**Author**: Generated for wine production system
**License**: MIT
