-- Leatherworking: recipes and leveling route.
-- Pure data, no logic. See README.md for the format.
--
-- Source: https://www.wow-professions.com/forever/leatherworking-leveling-guide
-- (read 2026-10-10; 225-300 added 2026-11-07, after launch). The guide marks
-- 225-300 as untested: it was written during the beta.
-- 225-300 spell IDs and reagents checked against https://www.wowhead.com/forever/
local _, ns = ...

ns.Data.Professions[165] = {
    id = 165,
    name = "Leatherworking",
    beta = true,  -- 225-300 untested by the guide
    source = "https://www.wow-professions.com/forever/leatherworking-leveling-guide",

    tools = {},

    -- Forever: Apprentice has no level requirement. Expert costs 50 silver.
    -- cost is in copper; nil = not listed in the guide.
    trainers = {
        { rank = "Apprentice", maxSkill = 75,  minSkill = 0,   minLevel = nil, cost = nil,
          horde = { "Kamari (Orgrimmar)", "Dan Golthas (Undercity)", "Mak (Thunder Bluff)", "Chaw Stronghide (Mulgore)", "Shelene Rhobart (Tirisfal Glades)" },
          alliance = { "Randal Worth (Stormwind)", "Gretta Finespindle (Ironforge)", "Darianna (Darnassus)", "Adele Fielder (Elwynn Forest)", "Nadyia Maneweaver (Teldrassil)" } },
        { rank = "Journeyman", maxSkill = 150, minSkill = 50,  minLevel = 10,  cost = nil,
          horde = { "Karolek (Orgrimmar)", "Arthur Moore (Undercity)", "Tarn (Thunder Bluff)" },
          alliance = { "Simon Tanner (Stormwind)", "Fimble Finespindle (Ironforge)", "Faldron (Darnassus)" } },
        { rank = "Expert",     maxSkill = 225, minSkill = 125, minLevel = 20,  cost = 5000,
          horde = { "Una (Thunder Bluff)" },
          alliance = { "Telonis (Darnassus)" } },
        { rank = "Artisan",    maxSkill = 300, minSkill = 200, minLevel = 35,  cost = nil,
          horde = { "Hahrana Ironhide (Camp Mojache, Feralas)" },
          alliance = { "Drakk Stonehand (Aerie Peak, The Hinterlands)" } },
    },

    -- Recipes keyed by spellID. Reagents per craft = the guide's step totals
    -- divided by the number of crafts (all match the Classic recipes).
    -- Skill colour thresholds are left out on purpose (see Blacksmithing.lua).
    recipes = {
        [2881]  = { name = "Light Leather",            item = 2318, count = 1, learn = "trainer", reagents = { { 2934, 3 } } },
        [3816]  = { name = "Cured Light Hide",         item = 4231, count = 1, learn = "trainer", reagents = { { 783, 1 }, { 4289, 1 } } },
        [3756]  = { name = "Embossed Leather Gloves",  item = 4239, count = 1, learn = "trainer", reagents = { { 2318, 3 }, { 2320, 2 } } },
        [20648] = { name = "Medium Leather",           item = 2319, count = 1, learn = "trainer", reagents = { { 2318, 4 } } },
        [3817]  = { name = "Cured Medium Hide",        item = 4233, count = 1, learn = "trainer", reagents = { { 4232, 1 }, { 4289, 1 } } },
        [3763]  = { name = "Fine Leather Belt",        item = 4246, count = 1, learn = "trainer", reagents = { { 2318, 6 }, { 2320, 2 } } },
        [9068]  = { name = "Light Leather Pants",      item = 7282, count = 1, learn = "trainer", reagents = { { 2318, 10 }, { 4231, 1 }, { 2321, 1 } } },
        [3766]  = { name = "Dark Leather Belt",        item = 4249, count = 1, learn = "trainer", reagents = { { 4246, 1 }, { 4233, 1 }, { 2321, 2 }, { 4340, 1 } } },
        [20649] = { name = "Heavy Leather",            item = 4234, count = 1, learn = "trainer", reagents = { { 2319, 5 } } },
        [3818]  = { name = "Cured Heavy Hide",         item = 4236, count = 1, learn = "trainer", reagents = { { 4235, 1 }, { 4289, 3 } } },
        [3764]  = { name = "Hillman's Leather Gloves", item = 4247, count = 1, learn = "trainer", reagents = { { 2319, 14 }, { 2321, 4 } } },
        [7151]  = { name = "Barbaric Shoulders",       item = 5964, count = 1, learn = "trainer", reagents = { { 4234, 8 }, { 4236, 1 }, { 2321, 2 } } },
        [7156]  = { name = "Guardian Gloves",          item = 5966, count = 1, learn = "trainer", reagents = { { 4234, 4 }, { 4236, 1 }, { 4291, 1 } } },
        [7149]  = { name = "Barbaric Leggings",        item = 5963, count = 1, learn = "vendor",
                    note = "Pattern: Jandia (Thousand Needles) / Keena (Arathi Highlands) for Horde, Hammon Karwn (Arathi Highlands) / Lardan (Ashenvale) for Alliance.",
                    reagents = { { 4234, 10 }, { 2321, 2 }, { 1206, 1 } } },
        [6661]  = { name = "Barbaric Harness",         item = 5739, count = 1, learn = "trainer", reagents = { { 4234, 14 }, { 2321, 2 }, { 7071, 1 } } },
        [10507] = { name = "Nightscape Headband",      item = 8176, count = 1, learn = "trainer", reagents = { { 4304, 5 }, { 4291, 2 } } },
        [10548] = { name = "Nightscape Pants",         item = 8193, count = 1, learn = "trainer", reagents = { { 4304, 14 }, { 4291, 4 } },
                    note = "Only the Artisan trainers teach this, not the Expert trainers." },
        [10558] = { name = "Nightscape Boots",         item = 8197, count = 1, learn = "trainer", reagents = { { 4304, 16 }, { 8343, 2 } } },  -- TODO: verify where it's learned
        [19049] = { name = "Wicked Leather Gauntlets", item = 15083, count = 1, learn = "vendor",
                    note = "Pattern: Werg Thickblade (Tirisfal Glades) for Horde, Leonard Porter (Western Plaguelands) for Alliance.",
                    reagents = { { 8170, 8 }, { 2325, 1 }, { 14341, 1 } } },
        [19082] = { name = "Runic Leather Headband",   item = 15094, count = 1, learn = "vendor",
                    note = "Pattern: Jase Farlane (Light's Hope Chapel, Eastern Plaguelands).",
                    reagents = { { 8170, 14 }, { 14047, 10 }, { 14341, 1 } } },
        [19047] = { name = "Cured Rugged Hide",        item = 15407, count = 1, learn = "trainer", reagents = { { 8171, 1 }, { 15409, 1 } } },  -- TODO: verify where it's learned
        [19100] = { name = "Heavy Scorpid Shoulders",  item = 15081, count = 1, learn = "drop",
                    reagents = { { 8170, 14 }, { 15408, 14 }, { 15407, 1 }, { 14341, 2 } } },
        [19098] = { name = "Wicked Leather Armor",     item = 15085, count = 1, learn = "drop",
                    reagents = { { 8170, 20 }, { 15407, 2 }, { 14256, 6 }, { 2325, 4 }, { 14341, 2 } } },
        -- New spell ID in Forever (the Classic one is different).
        [1255018] = { name = "Tooled Leather Pants",   item = 252560, count = 1, learn = "drop",
                    reagents = { { 8170, 18 }, { 14341, 1 }, { 6261, 1 }, { 15407, 1 } } },
    },

    -- Leveling route. crafts = how many the guide says to make for this step.
    -- 130-175 follows the guide's "Cured Heavy Hide" path; 175-195 needs
    -- Cured Heavy Hide anyway. The other path is described in the note.
    route = {
        { from = 1,   to = 30,  recipe = 2881,  crafts = 33 },
        { from = 30,  to = 55,  recipe = 3816,  crafts = 27, note = "Keep the hides, you need 24 at 100-115." },
        { from = 55,  to = 75,  recipe = 3756,  crafts = 21 },
        { from = 75,  to = 80,  recipe = 20648, crafts = 8 },
        { from = 80,  to = 90,  recipe = 3817,  crafts = 10, note = "Keep the hides, you need them at 115-125." },
        { from = 90,  to = 100, recipe = 3763,  crafts = 19, note = "Keep 10 belts, you need them at 115-125." },
        { from = 100, to = 115, recipe = 9068,  crafts = 24 },
        { from = 115, to = 125, recipe = 3766,  crafts = 10 },
        { from = 125, to = 130, recipe = 20649, crafts = 7 },
        { from = 130, to = 140, recipe = 3818,  crafts = 20,
          note = "Without Heavy Hide: Hillman's Leather Gloves x30 to 155, Barbaric Leggings x17 to 170, Barbaric Harness x5 to 175." },
        { from = 140, to = 155, recipe = 3764,  crafts = 20 },
        { from = 155, to = 165, recipe = 7151,  crafts = 10 },
        { from = 165, to = 175, recipe = 7156,  crafts = 10 },
        { from = 175, to = 195, recipe = 7156,  crafts = 26 },
        { from = 195, to = 210, recipe = 10507, crafts = 21 },
        { from = 210, to = 225, recipe = 10548, crafts = 15 },
        { from = 225, to = 235, recipe = 10558, crafts = 12, note = "Untested by the guide from here on (written during the beta)." },
        { from = 235, to = 250, recipe = 19049, crafts = 15 },
        { from = 250, to = 265, recipe = 19049, crafts = 21 },
        { from = 265, to = 285, recipe = 19082, crafts = 20 },
        { from = 285, to = 300, recipe = 19082, crafts = 33,
          alternatives = { { recipe = 19100, crafts = 15 }, { recipe = 19098, crafts = 15 }, { recipe = 1255018, crafts = 15 } },
          note = "The alternatives need patterns you may already have; they also need Cured Rugged Hide." },
    },
}
