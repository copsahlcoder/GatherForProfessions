-- Where each material comes from, keyed by itemID.
-- Pure data, no logic. See README.md for the format.
--
-- type = "node"    Mined from a node. node, skill (Mining needed), zones.
--        "smelt"   Smelted. profession + recipe point to the Mining recipe
--                  (which lists the ore and the Mining skill needed).
--        "craft"   Made with a profession. profession + recipe (spellID).
--        "mobdrop" Drops from mobs. mobs, zones.
--        "vendor"  Bought from a vendor. price (copper), vendor.
--        "other"   Anything else (other professions, Auction House). note.
-- zones = { { zone = "Name", min = minLevel, max = maxLevel }, ... }
--
-- Forever is in BETA. Zones and prices are Classic values unless noted.
-- TODO: verify zones for Forever (e.g. Zephras Isle is new and not listed here).
local _, ns = ...
local S = ns.Data.Sources

---------------------------------------------------------------------------
-- Zone lists shared by several items
---------------------------------------------------------------------------

local COPPER_ZONES = {
    { zone = "Durotar",          min = 1,  max = 10 },
    { zone = "Mulgore",          min = 1,  max = 10 },
    { zone = "Tirisfal Glades",  min = 1,  max = 10 },
    { zone = "Elwynn Forest",    min = 1,  max = 10 },
    { zone = "Dun Morogh",       min = 1,  max = 10 },
    { zone = "Darkshore",        min = 10, max = 20 },
    { zone = "The Barrens",      min = 10, max = 25 },
}

local TIN_ZONES = {
    { zone = "Hillsbrad Foothills", min = 20, max = 30 },
    { zone = "Redridge Mountains",  min = 15, max = 25 },
    { zone = "Ashenvale",           min = 18, max = 30 },
    { zone = "The Barrens",         min = 10, max = 25 },
}

local IRON_ZONES = {
    { zone = "Arathi Highlands",  min = 30, max = 40 },
    { zone = "Desolace",          min = 30, max = 40 },
    { zone = "Thousand Needles",  min = 25, max = 35 },
}

local MITHRIL_ZONES = {
    { zone = "The Hinterlands", min = 40, max = 50 },
    { zone = "Tanaris",         min = 40, max = 50 },
}

local THORIUM_ZONES = {
    { zone = "Un'Goro Crater", min = 48, max = 55 },
    { zone = "Blasted Lands",  min = 45, max = 55 },
    { zone = "Felwood",        min = 48, max = 55 },
}

---------------------------------------------------------------------------
-- Ores and stones (Mining nodes)
-- skill = Mining skill needed to mine the node (Classic -- TODO: verify).
---------------------------------------------------------------------------

S[2770]  = { name = "Copper Ore",     type = "node", node = "Copper Vein",       skill = 1,   zones = COPPER_ZONES }
S[2835]  = { name = "Rough Stone",    type = "node", node = "Copper Vein",       skill = 1,   zones = COPPER_ZONES }
S[2771]  = { name = "Tin Ore",        type = "node", node = "Tin Vein",          skill = 65,  zones = TIN_ZONES }
S[2836]  = { name = "Coarse Stone",   type = "node", node = "Tin Vein",          skill = 65,  zones = TIN_ZONES }
S[2775]  = { name = "Silver Ore",     type = "node", node = "Silver Vein",       skill = 75,  zones = TIN_ZONES }
S[2772]  = { name = "Iron Ore",       type = "node", node = "Iron Deposit",      skill = 125, zones = IRON_ZONES }
S[2838]  = { name = "Heavy Stone",    type = "node", node = "Iron Deposit",      skill = 125, zones = IRON_ZONES }
S[2776]  = { name = "Gold Ore",       type = "node", node = "Gold Vein",         skill = 155, zones = IRON_ZONES }
S[3858]  = { name = "Mithril Ore",    type = "node", node = "Mithril Deposit",   skill = 175, zones = MITHRIL_ZONES }
S[7912]  = { name = "Solid Stone",    type = "node", node = "Mithril Deposit",   skill = 175, zones = MITHRIL_ZONES }
S[7911]  = { name = "Truesilver Ore", type = "node", node = "Truesilver Deposit", skill = 230, zones = MITHRIL_ZONES }
S[10620] = { name = "Thorium Ore",    type = "node", node = "Small Thorium Vein", skill = 245, zones = THORIUM_ZONES }

---------------------------------------------------------------------------
-- Bars (smelted with Mining, recipes in Data/Mining.lua)
---------------------------------------------------------------------------

S[2840]  = { name = "Copper Bar",     type = "smelt", profession = 186, recipe = 2657 }
S[3576]  = { name = "Tin Bar",        type = "smelt", profession = 186, recipe = 3304 }
S[2841]  = { name = "Bronze Bar",     type = "smelt", profession = 186, recipe = 2659 }
S[2842]  = { name = "Silver Bar",     type = "smelt", profession = 186, recipe = 2658 }
S[3575]  = { name = "Iron Bar",       type = "smelt", profession = 186, recipe = 3307 }
S[3577]  = { name = "Gold Bar",       type = "smelt", profession = 186, recipe = 3308 }
S[3859]  = { name = "Steel Bar",      type = "smelt", profession = 186, recipe = 3569 }
S[3860]  = { name = "Mithril Bar",    type = "smelt", profession = 186, recipe = 10097 }
S[6037]  = { name = "Truesilver Bar", type = "smelt", profession = 186, recipe = 10098 }
S[12359] = { name = "Thorium Bar",    type = "smelt", profession = 186, recipe = 16153 }

---------------------------------------------------------------------------
-- Crafted intermediate items
---------------------------------------------------------------------------

S[3470] = { name = "Rough Grinding Stone",  type = "craft", profession = 164, recipe = 3320 }
S[3478] = { name = "Coarse Grinding Stone", type = "craft", profession = 164, recipe = 3326 }
S[3486] = { name = "Heavy Grinding Stone",  type = "craft", profession = 164, recipe = 3337 }
S[7966] = { name = "Solid Grinding Stone",  type = "craft", profession = 164, recipe = 9920 }

S[2996] = { name = "Bolt of Linen Cloth",   type = "craft", profession = 197, recipe = 2963 }
S[2997] = { name = "Bolt of Woolen Cloth",  type = "craft", profession = 197, recipe = 2964 }
S[4305] = { name = "Bolt of Silk Cloth",    type = "craft", profession = 197, recipe = 3839 }
S[4339] = { name = "Bolt of Mageweave",     type = "craft", profession = 197, recipe = 3865,
            note = "Mageweave is rare on beta; the guide suggests buying bolts on the Auction House." }

---------------------------------------------------------------------------
-- Cloth (drops from humanoid mobs)
-- TODO: verify level ranges and zones for Forever.
---------------------------------------------------------------------------

S[2589] = { name = "Linen Cloth", type = "mobdrop", mobs = "Humanoids level 5-15",
    zones = { { zone = "Westfall", min = 10, max = 20 }, { zone = "The Barrens", min = 10, max = 25 },
              { zone = "Silverpine Forest", min = 10, max = 20 } } }
S[2592] = { name = "Wool Cloth", type = "mobdrop", mobs = "Humanoids level 15-30",
    zones = { { zone = "Hillsbrad Foothills", min = 20, max = 30 }, { zone = "Wetlands", min = 20, max = 30 },
              { zone = "The Barrens", min = 15, max = 25 } } }
S[4306] = { name = "Silk Cloth", type = "mobdrop", mobs = "Humanoids level 25-40",
    zones = { { zone = "Alterac Mountains", min = 30, max = 40 }, { zone = "Arathi Highlands", min = 30, max = 40 },
              { zone = "Stranglethorn Vale", min = 30, max = 45 } } }
S[4338] = { name = "Mageweave Cloth", type = "mobdrop", mobs = "Humanoids level 40+ (Forever guide)",
    zones = { { zone = "Tanaris", min = 40, max = 50 }, { zone = "The Hinterlands", min = 40, max = 50 },
              { zone = "Feralas", min = 40, max = 50 } } }

---------------------------------------------------------------------------
-- Vendor items. price in copper.
-- TODO: verify all prices for Forever (Classic values; the guide lists none).
---------------------------------------------------------------------------

S[2320] = { name = "Coarse Thread",        type = "vendor", price = 10,   vendor = "Tailoring Supplies, next to most Tailoring trainers" }
S[2321] = { name = "Fine Thread",          type = "vendor", price = 100,  vendor = "Tailoring Supplies, next to most Tailoring trainers" }
S[4291] = { name = "Silken Thread",        type = "vendor", price = 500,  vendor = "Tailoring Supplies, next to most Tailoring trainers" }
S[8343] = { name = "Heavy Silken Thread",  type = "vendor", price = 2000, vendor = "Tailoring Supplies, next to most Tailoring trainers" }
S[2604] = { name = "Red Dye",              type = "vendor", price = 50,   vendor = "Tailoring Supplies, next to most Tailoring trainers" }
S[2605] = { name = "Green Dye",            type = "vendor", price = 100,
    vendor = "Horde: Tamar (Orgrimmar), Millie Gregorian (Undercity), Mahu (Thunder Bluff). Alliance: Jillian Tanner (Stormwind), Bombus Finespindle (Ironforge)" }
S[2880] = { name = "Weak Flux",            type = "vendor", price = 100,  vendor = "Blacksmithing Supplies, next to the trainer in each capital" }
S[3466] = { name = "Strong Flux",          type = "vendor", price = 2000, vendor = "Blacksmithing Supplies, next to the trainer in each capital" }
S[3857] = { name = "Coal",                 type = "vendor", price = 500,  vendor = "Blacksmithing Supplies -- TODO: verify" }
S[5956] = { name = "Blacksmith Hammer",    type = "vendor", price = 16,   vendor = "Blacksmithing / Trade Supplies vendors" }
S[2901] = { name = "Mining Pick",          type = "vendor", price = 81,   vendor = "Mining Supplies, next to most Mining trainers" }

---------------------------------------------------------------------------
-- Other professions / Auction House
---------------------------------------------------------------------------

S[2319] = { name = "Medium Leather",   type = "other", note = "Skinning (beasts level 20-30) or Auction House" }
S[4234] = { name = "Heavy Leather",    type = "other", note = "Skinning (beasts level 30-40) or Auction House" }
S[3383] = { name = "Elixir of Wisdom", type = "other", note = "Alchemy or Auction House" }
