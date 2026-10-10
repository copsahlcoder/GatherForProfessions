-- Blacksmithing: recipes and leveling route.
-- Pure data, no logic. See README.md for the format.
--
-- Source: https://www.wow-professions.com/forever/blacksmithing-leveling-guide
-- (read 2026-10-10). Forever is in BETA: the guide stops at 225 and may change.
local _, ns = ...

ns.Data.Professions[164] = {
    id = 164,
    name = "Blacksmithing",
    beta = true,
    source = "https://www.wow-professions.com/forever/blacksmithing-leveling-guide",

    tools = {
        { item = 5956, name = "Blacksmith Hammer" },  -- needed from skill 67
    },

    -- Forever: Apprentice has no level requirement. Expert costs 50 silver.
    -- cost is in copper; nil = not listed in the guide.
    trainers = {
        { rank = "Apprentice", maxSkill = 75,  minSkill = 0,   minLevel = nil, cost = nil,
          horde = { "Ug'thok (Orgrimmar)", "Basil Frye (Undercity)", "Thrag Stonehoof (Thunder Bluff)", "Dwukk (Razor Hill)", "Angus Hammerhand (Tirisfal Glades)" },
          alliance = { "Dane Lindgren (Stormwind)", "Groum Stonebeard (Ironforge)", "Smith Argus (Goldshire)", "Tognus Flintfire (Kharanos)", "Delfrum Flintbeard (Auberdine)" } },
        { rank = "Journeyman", maxSkill = 150, minSkill = 50,  minLevel = 10,  cost = nil,
          horde = { "Snarl (Orgrimmar)", "James Van Brunt (Undercity)", "Karn Stonehoof (Thunder Bluff)", "Angus Hammerhand (Tirisfal Glades)" },
          alliance = { "Therum Deepforge (Stormwind)", "Rotgath Stonebeard (Ironforge)" } },
        { rank = "Expert",     maxSkill = 225, minSkill = 125, minLevel = 20,  cost = 5000,
          horde = { "Saru Steelfury (Orgrimmar)" },
          alliance = { "Bengus Deepforge (Ironforge)" } },
        { rank = "Artisan",    maxSkill = 300, minSkill = 200, minLevel = 35,  cost = nil,
          horde = { "Brikk Keencraft (Booty Bay)" },
          alliance = { "Brikk Keencraft (Booty Bay)" } },
    },

    -- Recipes keyed by spellID. learn = where the recipe comes from.
    -- Reagents follow the Forever guide's totals.
    -- Skill colour thresholds are left out on purpose: the guide says Forever
    -- recipes turn grey 25+ points earlier than Classic, and lists no values.
    recipes = {
        [2660]  = { name = "Rough Sharpening Stone",  item = 2862, count = 1, learn = "trainer", reagents = { { 2835, 1 } } },
        [3320]  = { name = "Rough Grinding Stone",    item = 3470, count = 1, learn = "trainer", reagents = { { 2835, 2 } } },
        [3326]  = { name = "Coarse Grinding Stone",   item = 3478, count = 1, learn = "trainer", reagents = { { 2836, 2 } } },
        [3323]  = { name = "Runed Copper Gauntlets",  item = 3472, count = 1, learn = "trainer", reagents = { { 2840, 8 }, { 3470, 2 } } },  -- TODO: verify spell/item ID
        [2666]  = { name = "Runed Copper Belt",       item = 2857, count = 1, learn = "trainer", reagents = { { 2840, 10 } } },  -- TODO: verify spell/item ID
        [7818]  = { name = "Silver Rod",              item = 6338, count = 1, learn = "trainer", reagents = { { 2842, 1 }, { 3470, 2 } } },
        [2668]  = { name = "Rough Bronze Leggings",   item = 2865, count = 1, learn = "trainer", reagents = { { 2841, 6 } } },  -- TODO: verify spell/item ID
        [2672]  = { name = "Patterned Bronze Bracers", item = 2868, count = 1, learn = "trainer", reagents = { { 2841, 5 }, { 3478, 2 } } },  -- TODO: verify spell/item ID
        [3337]  = { name = "Heavy Grinding Stone",    item = 3486, count = 1, learn = "trainer", reagents = { { 2838, 3 } } },
        [2742]  = { name = "Bronze Shortsword",       item = 2850, count = 1, learn = "trainer", reagents = { { 2841, 5 }, { 2880, 4 }, { 2319, 2 } } },  -- TODO: verify spell/item ID
        [9985]  = { name = "Bronze Warhammer",        item = 7956, count = 1, learn = "trainer", reagents = { { 2841, 8 }, { 3466, 1 }, { 2319, 1 } } },  -- TODO: verify spell/item ID
        [3501]  = { name = "Green Iron Bracers",      item = 3835, count = 1, learn = "trainer", reagents = { { 3575, 6 }, { 2605, 1 } } },  -- TODO: verify spell/item ID
        [9920]  = { name = "Solid Grinding Stone",    item = 7966, count = 1, learn = "trainer", reagents = { { 7912, 4 } } },
        [7223]  = { name = "Golden Scale Bracers",    item = 6040, count = 1, learn = "trainer", reagents = { { 3859, 5 }, { 3486, 2 } } },  -- TODO: verify spell/item ID
        [9928]  = { name = "Heavy Mithril Gauntlet",  item = 7919, count = 1, learn = "trainer", reagents = { { 3860, 6 }, { 4338, 4 } } },  -- TODO: verify spell/item ID
        [9926]  = { name = "Heavy Mithril Shoulder",  item = 7918, count = 1, learn = "trainer", reagents = { { 3860, 8 }, { 4234, 6 } } },  -- TODO: verify spell/item ID
        [9935]  = { name = "Steel Plate Helm",        item = 7922, count = 1, learn = "trainer", reagents = { { 3859, 14 }, { 7966, 1 } } },  -- TODO: verify spell/item ID
        [9964]  = { name = "Mithril Spurs",           item = 7969, count = 1, learn = "drop", note = "World drop plan, check the Auction House.",
                    reagents = { { 3860, 4 }, { 7966, 3 } } },
    },

    -- Leveling route. crafts = how many the guide says to make for this step.
    -- alternatives = other recipes the guide suggests for the same step.
    route = {
        { from = 1,   to = 25,  recipe = 2660, crafts = 30 },
        { from = 25,  to = 50,  recipe = 3320, crafts = 30, note = "Keep the stones, you need them later." },
        { from = 50,  to = 67,  recipe = 3326, crafts = 36, note = "Keep the stones, you need them later." },
        { from = 67,  to = 75,  recipe = 3323, crafts = 8 },
        { from = 75,  to = 80,  recipe = 2666, crafts = 5,  alternatives = { { recipe = 7818, crafts = 5 } } },
        { from = 80,  to = 95,  recipe = 2668, crafts = 15 },
        { from = 95,  to = 100, recipe = 2672, crafts = 5 },
        { from = 100, to = 112, recipe = 3337, crafts = 20 },
        { from = 112, to = 125, recipe = 2672, crafts = 13 },
        { from = 125, to = 140, recipe = 2742, crafts = 24 },
        { from = 140, to = 150, recipe = 9985, crafts = 10 },
        { from = 150, to = 165, recipe = 9985, crafts = 19 },
        { from = 165, to = 175, recipe = 3501, crafts = 15 },
        { from = 175, to = 185, recipe = 9920, crafts = 40, alternatives = { { recipe = 7223, crafts = 10 } } },
        { from = 185, to = 200, recipe = 9928, crafts = 15, alternatives = { { recipe = 9926, crafts = 15 } } },
        { from = 200, to = 225, recipe = 9935, crafts = 37, alternatives = { { recipe = 9964, crafts = 15 } } },
        { from = 225, to = 300, missing = true, note = "Artisan route not published for Forever yet (beta)." },
    },
}
