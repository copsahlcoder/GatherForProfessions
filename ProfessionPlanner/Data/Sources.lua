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
S[12365] = { name = "Dense Stone",    type = "node", node = "Small Thorium Vein", skill = 245, zones = THORIUM_ZONES }

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
S[12644] = { name = "Dense Grinding Stone", type = "craft", profession = 164, recipe = 16639 }

S[2996] = { name = "Bolt of Linen Cloth",   type = "craft", profession = 197, recipe = 2963 }
S[2997] = { name = "Bolt of Woolen Cloth",  type = "craft", profession = 197, recipe = 2964 }
S[4305] = { name = "Bolt of Silk Cloth",    type = "craft", profession = 197, recipe = 3839 }
S[4339] = { name = "Bolt of Mageweave",     type = "craft", profession = 197, recipe = 3865,
            note = "Mageweave is rare on beta; the guide suggests buying bolts on the Auction House." }
S[14048] = { name = "Bolt of Runecloth",    type = "craft", profession = 197, recipe = 18401 }

S[4231] = { name = "Cured Light Hide",      type = "craft", profession = 165, recipe = 3816 }
S[4233] = { name = "Cured Medium Hide",     type = "craft", profession = 165, recipe = 3817 }
S[4236] = { name = "Cured Heavy Hide",      type = "craft", profession = 165, recipe = 3818 }
S[4246] = { name = "Fine Leather Belt",     type = "craft", profession = 165, recipe = 3763 }
S[15407] = { name = "Cured Rugged Hide",    type = "craft", profession = 165, recipe = 19047 }

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
S[14047] = { name = "Runecloth", type = "mobdrop", mobs = "Humanoids level 50-60",
    zones = { { zone = "Winterspring", min = 53, max = 60 }, { zone = "Eastern Plaguelands", min = 53, max = 60 },
              { zone = "Western Plaguelands", min = 51, max = 58 }, { zone = "Burning Steppes", min = 50, max = 58 } } }
S[14256] = { name = "Felcloth", type = "mobdrop", mobs = "Satyrs and demons level 50+, or Auction House",
    zones = { { zone = "Felwood", min = 48, max = 55 }, { zone = "Winterspring", min = 53, max = 60 } } }

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
S[4289] = { name = "Salt",                 type = "vendor", price = 50,   vendor = "Leatherworking Supplies, next to most Leatherworking trainers; Tharynn Bouden (Goldshire), Abigail Shiel (Brill)" }
S[4340] = { name = "Gray Dye",             type = "vendor", price = 35,   vendor = "Leatherworking / Tailoring Supplies" }
S[3857] = { name = "Coal",                 type = "vendor", price = 500,  vendor = "Blacksmithing Supplies -- TODO: verify" }
S[5956] = { name = "Blacksmith Hammer",    type = "vendor", price = 16,   vendor = "Blacksmithing / Trade Supplies vendors" }
S[2901] = { name = "Mining Pick",          type = "vendor", price = 81,   vendor = "Mining Supplies, next to most Mining trainers" }

-- Added after launch. Prices are 4x the sell price on Wowhead (the usual
-- vendor markup). TODO: verify in game.
S[14341]  = { name = "Rune Thread",        type = "vendor", price = 5000, vendor = "Tailoring / Leatherworking Supplies" }
S[2325]   = { name = "Black Dye",          type = "vendor", price = 1000, vendor = "Tailoring / Leatherworking Supplies" }
S[6261]   = { name = "Orange Dye",         type = "vendor", price = 1000, vendor = "Tailoring / Leatherworking Supplies" }
S[247786] = { name = "Mote of Magic",      type = "vendor", price = 4,    vendor = "Enchanting Supplies, next to most Enchanting trainers" }  -- new in Forever
S[6217]   = { name = "Copper Rod",         type = "vendor", price = 96,   vendor = "Enchanting Supplies, next to most Enchanting trainers" }
S[17034]  = { name = "Maple Seed",         type = "vendor", price = 200,  vendor = "Reagent vendors" }
S[17035]  = { name = "Stranglethorn Seed", type = "vendor", price = 4,    vendor = "Reagent vendors" }
S[3372]   = { name = "Leaded Vial",        type = "vendor", price = 40,   vendor = "Alchemy Supplies" }
S[8925]   = { name = "Crystal Vial",       type = "vendor", price = 500,  vendor = "Alchemy Supplies; Mishta (Cenarion Hold, Silithus)" }

---------------------------------------------------------------------------
-- Other professions / Auction House
---------------------------------------------------------------------------

-- Leather and hides. Leatherworking can also make leather from lower leather
-- (e.g. 4 Light -> 1 Medium), but we keep them as "other" so plans for other
-- professions don't tell you to make leather from scraps. The Leatherworking
-- route makes them in its own steps.
-- TODO: verify skinning level ranges for Forever.
S[2934] = { name = "Ruined Leather Scraps", type = "other", note = "Skinning (beasts level 1-15) or Auction House" }
S[2318] = { name = "Light Leather",    type = "other", note = "Skinning (beasts level 1-20) or Auction House" }
S[783]  = { name = "Light Hide",       type = "other", note = "Skinning (beasts level 1-20) or Auction House" }
S[2319] = { name = "Medium Leather",   type = "other", note = "Skinning (beasts level 20-30), Leatherworking (4 Light Leather) or Auction House" }
S[4232] = { name = "Medium Hide",      type = "other", note = "Skinning (beasts level 20-30) or Auction House" }
S[4234] = { name = "Heavy Leather",    type = "other", note = "Skinning (beasts level 30-40), Leatherworking (5 Medium Leather) or Auction House" }
S[4235] = { name = "Heavy Hide",       type = "other", note = "Skinning (beasts level 30-40) or Auction House" }
S[4304] = { name = "Thick Leather",    type = "other", note = "Skinning (beasts level 40-50) or Auction House" }

S[8170]  = { name = "Rugged Leather",   type = "other", note = "Skinning (beasts level 45-60) or Auction House" }
S[8171]  = { name = "Rugged Hide",      type = "other", note = "Skinning (beasts level 45-60) or Auction House" }
S[15408] = { name = "Heavy Scorpid Scale", type = "other", note = "Skinning scorpids in Silithus and Burning Steppes, or Auction House" }
S[15409] = { name = "Refined Deeprock Salt", type = "other", note = "Salt Shaker (Leatherworking) from Deeprock Salt, or Auction House" }

S[3383] = { name = "Elixir of Wisdom", type = "other", note = "Alchemy or Auction House" }
S[8831] = { name = "Purple Lotus",     type = "other", note = "Herbalism or Auction House" }
S[1206] = { name = "Moss Agate",       type = "other", note = "Mining (Tin and Silver veins) or Auction House" }
S[7071] = { name = "Iron Buckle",      type = "other", note = "Blacksmithing or Auction House" }

-- Gems and pearls. TODO: verify sources for Forever.
S[1210]  = { name = "Shadowgem",       type = "other", note = "Mining (Tin veins) or Auction House" }
S[7909]  = { name = "Aquamarine",      type = "other", note = "Mining (Mithril and Truesilver deposits) or Auction House" }
S[7910]  = { name = "Star Ruby",       type = "other", note = "Mining (Mithril, Truesilver and Thorium) or Auction House" }
S[12799] = { name = "Large Opal",      type = "other", note = "Mining (Thorium veins) or Auction House" }
S[5500]  = { name = "Iridescent Pearl", type = "other", note = "Clams (fishing and mobs level 20-35) or Auction House" }
S[7971]  = { name = "Black Pearl",     type = "other", note = "Clams (mobs level 35-50) or Auction House" }
S[13926] = { name = "Golden Pearl",    type = "other", note = "Clams (mobs level 50+) or Auction House" }

-- Rods for the Enchanting runed rods. Blacksmiths make them, but we keep them
-- as "other" so an Enchanting plan doesn't tell you to smith them yourself.
S[6338]  = { name = "Silver Rod",      type = "other", note = "Blacksmithing or Auction House" }
S[11128] = { name = "Golden Rod",      type = "other", note = "Blacksmithing or Auction House" }
S[11144] = { name = "Truesilver Rod",  type = "other", note = "Blacksmithing or Auction House" }
S[16206] = { name = "Arcanite Rod",    type = "other", note = "Blacksmithing or Auction House" }

---------------------------------------------------------------------------
-- Enchanting materials (disenchanting green items, or the Auction House).
-- Item levels are Classic values. TODO: verify for Forever.
---------------------------------------------------------------------------

local function Disenchant(levels)
    return "Disenchant green items (item level " .. levels .. ") or Auction House"
end

S[10940] = { name = "Strange Dust",           type = "other", note = Disenchant("5-25") }
S[11083] = { name = "Soul Dust",              type = "other", note = Disenchant("26-35") }
S[11137] = { name = "Vision Dust",            type = "other", note = Disenchant("36-45") }
S[11176] = { name = "Dream Dust",             type = "other", note = Disenchant("46-55") }
S[16204] = { name = "Illusion Dust",          type = "other", note = Disenchant("56-65") }
S[10938] = { name = "Lesser Magic Essence",   type = "other", note = Disenchant("5-15") .. "; 1 Greater Magic Essence splits into 3" }
S[11082] = { name = "Greater Astral Essence", type = "other", note = Disenchant("26-30") }
S[11135] = { name = "Greater Mystic Essence", type = "other", note = Disenchant("36-40") }
S[11174] = { name = "Lesser Nether Essence",  type = "other", note = Disenchant("41-45") }
S[16203] = { name = "Greater Eternal Essence", type = "other", note = Disenchant("56-65") }
S[14343] = { name = "Small Brilliant Shard",  type = "other", note = "Disenchant blue items (item level 51-55), or Auction House" }
S[14344] = { name = "Large Brilliant Shard",  type = "other", note = "Disenchant blue items (item level 56-65), or Auction House" }
