-- Enchanting: recipes and leveling route.
-- Pure data, no logic. See README.md for the format.
--
-- Source: https://www.wow-professions.com/forever/enchanting-leveling-guide
-- (read 2026-11-07, after launch). The guide marks 225-300 as untested: it
-- was written during the beta.
-- Spell IDs and reagents checked against https://www.wowhead.com/forever/
--
-- Enchants don't make an item, so those recipes have no item/count.
-- The runed rods are made along the route; the plain rods come from
-- Blacksmithing or the Auction House (see Sources.lua).
local _, ns = ...

-- Formula vendors the guide lists for the Journeyman/Expert oils and enchants.
local FORMULA_VENDORS = "Kithas (Orgrimmar), Nata Dawnstrider (Thunder Bluff), Thaddeus Webb (Undercity), "
    .. "Vaean (Darnassus), Tilli Thistlefuzz (Ironforge), Jessara Cordell (Stormwind)"

ns.Data.Professions[333] = {
    id = 333,
    name = "Enchanting",
    beta = true,  -- 225-300 untested by the guide
    source = "https://www.wow-professions.com/forever/enchanting-leveling-guide",

    tools = {},

    -- Forever: Apprentice has no level requirement. Expert costs 50 silver.
    -- cost is in copper; nil = not listed in the guide.
    trainers = {
        { rank = "Apprentice", maxSkill = 75,  minSkill = 0,   minLevel = nil, cost = nil,
          horde = { "Jhag (Orgrimmar)", "Malcomb Wynn (Undercity)", "Mot Dawnstrider (Thunder Bluff)", "Pa'zula (Sen'jin Village)",
                    "Vance Undergloom (Brill)", "Eaysaa Brightgust (Valanaar, Zephras Isle)", "Nasalanna Windsinger (Shen'dar Village, Zephras Isle)" },
          alliance = { "Betty Quin (Stormwind)", "Thonys Pillarstone (Ironforge)", "Lalina Summermoon (Darnassus)", "Alanna Raveneye (Teldrassil)",
                       "Eaysaa Brightgust (Valanaar, Zephras Isle)", "Nasalanna Windsinger (Shen'dar Village, Zephras Isle)" } },
        { rank = "Journeyman", maxSkill = 150, minSkill = 50,  minLevel = 10,  cost = nil,
          horde = { "Godan (Orgrimmar)", "Lavinia Crowe (Undercity)", "Teg Dawnstrider (Thunder Bluff)" },
          alliance = { "Lucan Cordell (Stormwind)", "Gimble Thistlefuzz (Ironforge)", "Taladan (Darnassus)" } },
        { rank = "Expert",     maxSkill = 225, minSkill = 125, minLevel = 20,  cost = 5000,
          horde = { "Hgarth (Sun Rock Retreat, Stonetalon Mountains)" },
          alliance = { "Kitta Firewind (Tower of Azora, Elwynn Forest)" } },
        -- Annora only appears after you clear her area in Uldaman (not soloable at 35).
        -- She is the only trainer for the 230+ recipes: learn everything before you leave.
        { rank = "Artisan",    maxSkill = 300, minSkill = 200, minLevel = 35,  cost = nil,
          horde = { "Annora (Uldaman, Badlands)" },
          alliance = { "Annora (Uldaman, Badlands)" } },
    },

    -- Recipes keyed by spellID. Reagents per craft from Wowhead; they match
    -- the guide's step totals. Skill colours are left out (see Blacksmithing.lua).
    recipes = {
        -- Apprentice
        [7421]  = { name = "Runed Copper Rod", item = 6218, count = 1, learn = "trainer", reagents = { { 6217, 1 }, { 247786, 1 } } },
        [7418]  = { name = "Enchant Bracer - Inferior Stamina", learn = "trainer", reagents = { { 247786, 1 } } },
        [7428]  = { name = "Enchant Bracer - Minor Deflect",    learn = "trainer", reagents = { { 10938, 1 } } },
        [7420]  = { name = "Enchant Chest - Inferior Stamina",  learn = "trainer", reagents = { { 10940, 1 } } },
        -- Journeyman
        [7426]  = { name = "Enchant Chest - Minor Absorption",  learn = "trainer", reagents = { { 10938, 1 } } },
        [7457]  = { name = "Enchant Bracer - Minor Stamina",    learn = "trainer", reagents = { { 10940, 2 } } },
        [7771]  = { name = "Enchant Cloak - Minor Protection",  learn = "trainer", reagents = { { 10940, 2 } } },
        [7795]  = { name = "Runed Silver Rod", item = 6339, count = 1, learn = "trainer",
                    reagents = { { 6338, 1 }, { 10940, 3 }, { 10938, 4 }, { 1210, 1 } } },
        [7793]  = { name = "Enchant 2H Weapon - Lesser Intellect", learn = "vendor",
                    note = "Formula: Kithas (Orgrimmar), Nata Dawnstrider (Thunder Bluff), Leo Sarn (Silverpine Forest), Tilli Thistlefuzz (Ironforge). "
                        .. "Buy Minor Mana Oil and Lesser Wizard Oil there too.",
                    reagents = { { 10938, 4 } } },
        [7863]  = { name = "Enchant Boots - Minor Stamina",     learn = "trainer", reagents = { { 10940, 4 } } },
        [13501] = { name = "Enchant Bracer - Lesser Stamina",   learn = "trainer", reagents = { { 11083, 1 } } },
        -- Expert
        [13628] = { name = "Runed Golden Rod", item = 11130, count = 1, learn = "trainer",
                    reagents = { { 11128, 1 }, { 5500, 1 }, { 11082, 1 }, { 11083, 1 } } },
        [25125] = { name = "Minor Mana Oil", item = 20745, count = 1, learn = "vendor", note = "Formula: " .. FORMULA_VENDORS .. ".",
                    reagents = { { 11083, 1 }, { 17034, 2 }, { 3372, 1 } } },
        [13637] = { name = "Enchant Boots - Lesser Agility",    learn = "trainer", reagents = { { 11083, 1 } } },
        [13661] = { name = "Enchant Bracer - Strength",         learn = "trainer", reagents = { { 11137, 1 } } },
        [13702] = { name = "Runed Truesilver Rod", item = 11145, count = 1, learn = "trainer",
                    reagents = { { 11144, 1 }, { 7971, 1 }, { 11135, 1 }, { 11137, 1 } } },
        [25126] = { name = "Lesser Wizard Oil", item = 20746, count = 1, learn = "vendor", note = "Formula: " .. FORMULA_VENDORS .. ".",
                    reagents = { { 11137, 1 }, { 17035, 2 }, { 3372, 1 } } },
        [13746] = { name = "Enchant Cloak - Greater Defense",   learn = "trainer", reagents = { { 11137, 1 } } },
        -- Artisan (taught by Annora unless noted)
        [13815] = { name = "Enchant Gloves - Agility",          learn = "trainer", reagents = { { 11137, 1 } } },
        [13836] = { name = "Enchant Boots - Stamina",           learn = "trainer", reagents = { { 11137, 2 } } },
        [13858] = { name = "Enchant Chest - Superior Stamina",  learn = "trainer", reagents = { { 11137, 3 } } },
        [25127] = { name = "Lesser Mana Oil", item = 20747, count = 1, learn = "vendor", note = "Formula: Kania (inn, Cenarion Hold, Silithus).",
                    reagents = { { 11176, 1 }, { 8831, 1 }, { 8925, 1 } } },
        [13939] = { name = "Enchant Bracer - Greater Strength", learn = "trainer", reagents = { { 11176, 1 }, { 11174, 2 } } },
        [20017] = { name = "Enchant Shield - Greater Stamina",  learn = "vendor",
                    note = "Formula (bind on pickup): Daniel Bartlett (Undercity), Mythrin'dir (Darnassus).",
                    reagents = { { 11176, 6 } } },
        [20051] = { name = "Runed Arcanite Rod", item = 16207, count = 1, learn = "vendor",
                    note = "Formula: Lorelae Wintersong (Nighthaven, Moonglade). She also sells Enchant Cloak - Superior Defense.",
                    reagents = { { 16206, 1 }, { 13926, 1 }, { 16204, 10 }, { 16203, 4 }, { 14343, 4 }, { 14344, 2 } } },
        [20015] = { name = "Enchant Cloak - Superior Defense",  learn = "vendor", note = "Formula: Lorelae Wintersong (Nighthaven, Moonglade).",
                    reagents = { { 16204, 8 } } },
    },

    -- Leveling route. crafts = how many the guide says to make for this step.
    -- 70-150 follows the guide's Lesser Magic Essence route; the Strange Dust
    -- route is given as alternatives (same skill ranges).
    route = {
        { from = 1,   to = 2,   recipe = 7421,  crafts = 1 },
        { from = 2,   to = 20,  recipe = 7418,  crafts = 18 },
        { from = 20,  to = 70,  recipe = 7428,  crafts = 50, alternatives = { { recipe = 7420, crafts = 50 } },
          note = "A Greater Magic Essence can be split into 3 Lesser Magic Essence (right-click it)." },
        { from = 70,  to = 100, recipe = 7426,  crafts = 33, alternatives = { { recipe = 7457, crafts = 30 } } },
        { from = 100, to = 109, recipe = 7426,  crafts = 18, alternatives = { { recipe = 7771, crafts = 9 } } },
        { from = 109, to = 110, recipe = 7795,  crafts = 1 },
        { from = 110, to = 130, recipe = 7793,  crafts = 20, alternatives = { { recipe = 7771, crafts = 32 } } },
        { from = 130, to = 150, recipe = 7793,  crafts = 32,
          alternatives = { { recipe = 7863, crafts = 20 }, { recipe = 13501, crafts = 20 } } },
        { from = 150, to = 151, recipe = 13628, crafts = 1 },
        { from = 151, to = 165, recipe = 25125, crafts = 16 },
        { from = 165, to = 185, recipe = 13637, crafts = 22,
          note = "If Vision Dust is expensive, keep making these until 200 (about 22 more)." },
        { from = 185, to = 200, recipe = 13661, crafts = 15 },
        { from = 200, to = 201, recipe = 13702, crafts = 1 },
        { from = 201, to = 220, recipe = 25126, crafts = 25 },
        { from = 220, to = 225, recipe = 13746, crafts = 5 },
        { from = 225, to = 230, recipe = 13815, crafts = 5,
          note = "Untested by the guide from here on (written during the beta). Bring ~100 Vision Dust to Annora." },
        { from = 230, to = 235, recipe = 13836, crafts = 5 },
        { from = 235, to = 250, recipe = 13858, crafts = 20 },
        { from = 250, to = 265, recipe = 25127, crafts = 20,
          note = "Without Purple Lotus: Enchant Bracer - Greater Strength (from Annora) instead." },
        { from = 265, to = 294, recipe = 20017, crafts = 32 },
        { from = 294, to = 295, recipe = 20051, crafts = 1 },
        { from = 295, to = 300, recipe = 20015, crafts = 5 },
    },
}
