-- Blacksmithing: recipes and leveling route.
-- Pure data, no logic. See README.md for the format.
--
-- Source: https://www.wow-professions.com/forever/blacksmithing-leveling-guide
-- (read 2026-11-07, after launch). The guide marks 215-300 as untested: it
-- was written during the beta, where you couldn't level that far.
-- Spell IDs and reagents checked against https://www.wowhead.com/forever/
local _, ns = ...

ns.Data.Professions[164] = {
    id = 164,
    name = "Blacksmithing",
    beta = true,  -- 215-300 untested by the guide
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
    -- Reagents per craft from Wowhead; they match the guide's step totals.
    -- Skill colour thresholds are left out on purpose: the guide says Forever
    -- recipes turn grey 25+ points earlier than Classic, and lists no values.
    recipes = {
        [2660]  = { name = "Rough Sharpening Stone",  item = 2862, count = 1, learn = "trainer", reagents = { { 2835, 1 } } },
        [3320]  = { name = "Rough Grinding Stone",    item = 3470, count = 1, learn = "trainer", reagents = { { 2835, 2 } } },
        [3326]  = { name = "Coarse Grinding Stone",   item = 3478, count = 1, learn = "trainer", reagents = { { 2836, 2 } } },
        [3323]  = { name = "Runed Copper Gauntlets",  item = 3472, count = 1, learn = "trainer", reagents = { { 2840, 8 }, { 3470, 2 } } },
        [2666]  = { name = "Runed Copper Belt",       item = 2857, count = 1, learn = "trainer", reagents = { { 2840, 10 } } },
        [7818]  = { name = "Silver Rod",              item = 6338, count = 1, learn = "trainer", reagents = { { 2842, 1 }, { 3470, 2 } } },
        [2672]  = { name = "Patterned Bronze Bracers", item = 2868, count = 1, learn = "trainer", reagents = { { 2841, 5 }, { 3478, 2 } } },
        [3337]  = { name = "Heavy Grinding Stone",    item = 3486, count = 1, learn = "trainer", reagents = { { 2838, 3 } } },
        [2742]  = { name = "Bronze Shortsword",       item = 2850, count = 1, learn = "trainer", reagents = { { 2841, 5 }, { 2880, 4 }, { 2319, 2 } } },
        [9985]  = { name = "Bronze Warhammer",        item = 7956, count = 1, learn = "trainer", reagents = { { 2841, 8 }, { 3466, 1 }, { 2319, 1 } } },
        [3501]  = { name = "Green Iron Bracers",      item = 3835, count = 1, learn = "trainer", reagents = { { 3575, 6 }, { 2605, 1 } } },
        [9920]  = { name = "Solid Grinding Stone",    item = 7966, count = 1, learn = "trainer", reagents = { { 7912, 4 } } },
        [7223]  = { name = "Golden Scale Bracers",    item = 6040, count = 1, learn = "trainer", reagents = { { 3859, 5 }, { 3486, 2 } } },
        [9931]  = { name = "Mithril Plate Pants",     item = 7920, count = 1, learn = "trainer", reagents = { { 3860, 12 } } },  -- TODO: verify where it's learned
        [9916]  = { name = "Steel Breastplate",       item = 7963, count = 1, learn = "trainer", reagents = { { 3859, 16 }, { 3486, 3 } } },
        [9935]  = { name = "Steel Plate Helm",        item = 7922, count = 1, learn = "trainer", reagents = { { 3859, 14 }, { 7966, 1 } } },
        [9959]  = { name = "Heavy Mithril Breastplate", item = 7930, count = 1, learn = "trainer", reagents = { { 3860, 16 } } },  -- TODO: verify where it's learned
        [9964]  = { name = "Mithril Spurs",           item = 7969, count = 1, learn = "drop", note = "World drop plan, check the Auction House.",
                    reagents = { { 3860, 4 }, { 7966, 3 } } },
        [16641] = { name = "Dense Sharpening Stone",  item = 12404, count = 1, learn = "trainer", reagents = { { 12365, 1 } } },
        [9968]  = { name = "Heavy Mithril Boots",     item = 7933, count = 1, learn = "trainer", reagents = { { 3860, 14 }, { 4304, 4 } } },
        -- Imperial Plate: four quests from Derotain Mudsipper (Tanaris, level 50).
        -- The quests also take Thorium Bars (20/20/40/60), not counted here.
        [16647] = { name = "Imperial Plate Belt",     item = 12424, count = 1, learn = "quest",
                    note = "Quest from Derotain Mudsipper (Tanaris), hand in 20 Thorium Bar.",
                    reagents = { { 12359, 22 }, { 8170, 6 }, { 7909, 1 } } },
        [16649] = { name = "Imperial Plate Bracers",  item = 12425, count = 1, learn = "quest",
                    note = "Quest from Derotain Mudsipper (Tanaris), hand in 20 Thorium Bar.",
                    reagents = { { 12359, 20 }, { 7910, 1 } } },
        [16657] = { name = "Imperial Plate Boots",    item = 12426, count = 1, learn = "quest",
                    note = "Quest from Derotain Mudsipper (Tanaris), hand in 40 Thorium Bar.",
                    reagents = { { 12359, 34 }, { 7910, 1 }, { 7909, 1 } } },
        [16730] = { name = "Imperial Plate Leggings", item = 12429, count = 1, learn = "quest",
                    note = "Quest from Derotain Mudsipper (Tanaris), hand in 60 Thorium Bar.",
                    reagents = { { 12359, 44 }, { 7910, 2 } } },
        -- Fallbacks if the Imperial Plate quests still need skill 265 (as in Classic).
        [10013] = { name = "Ebon Shiv",               item = 7947, count = 1, learn = "vendor", note = "Plans from Magnus Frostwake (Western Plaguelands).",
                    reagents = { { 3860, 12 }, { 6037, 6 }, { 7910, 2 }, { 7966, 1 }, { 4304, 2 } } },
        [16639] = { name = "Dense Grinding Stone",    item = 12644, count = 1, learn = "trainer", reagents = { { 12365, 4 } } },
        [16969] = { name = "Ornate Thorium Handaxe",  item = 12773, count = 1, learn = "vendor", note = "Plans from Magnus Frostwake (Western Plaguelands).",
                    reagents = { { 12359, 20 }, { 12799, 2 }, { 12644, 2 }, { 8170, 4 } } },
    },

    -- Leveling route. crafts = how many the guide says to make for this step.
    -- alternatives = other recipes the guide suggests for the same step.
    route = {
        { from = 1,   to = 25,  recipe = 2660, crafts = 30 },
        { from = 25,  to = 50,  recipe = 3320, crafts = 30, note = "Keep the stones, you need them later." },
        { from = 50,  to = 67,  recipe = 3326, crafts = 36, note = "Keep the stones, you need them later." },
        { from = 67,  to = 75,  recipe = 3323, crafts = 8 },
        { from = 75,  to = 80,  recipe = 2666, crafts = 5,  alternatives = { { recipe = 7818, crafts = 5 } } },
        { from = 80,  to = 95,  recipe = 2666, crafts = 18 },
        { from = 95,  to = 100, recipe = 2672, crafts = 5 },
        { from = 100, to = 112, recipe = 3337, crafts = 20 },
        { from = 112, to = 125, recipe = 2672, crafts = 13 },
        { from = 125, to = 140, recipe = 2742, crafts = 24 },
        { from = 140, to = 150, recipe = 9985, crafts = 10 },
        { from = 150, to = 170, recipe = 9985, crafts = 29 },
        { from = 170, to = 175, recipe = 3501, crafts = 9 },
        { from = 175, to = 185, recipe = 7223, crafts = 10 },
        { from = 185, to = 215, recipe = 9931, crafts = 36,
          note = "If Mithril is expensive: Steel Breastplate x15 (185-200), then Steel Plate Helm x17 (200-215)." },
        { from = 215, to = 225, recipe = 9959, crafts = 10, alternatives = { { recipe = 9964, crafts = 10 } },
          note = "Untested by the guide from here on (written during the beta)." },
        { from = 225, to = 230, recipe = 16641, crafts = 5 },
        { from = 230, to = 240, recipe = 9968,  crafts = 16 },
        { from = 240, to = 245, recipe = 16647, crafts = 5,
          note = "Bring 250+ Thorium Bar: the four Imperial Plate quests take 140 on top of the crafts. "
              .. "If the quests need skill 265: Ebon Shiv x15 (240-255) and Ornate Thorium Handaxe x15 (255-270)." },
        { from = 245, to = 270, recipe = 16649, crafts = 27 },
        { from = 270, to = 290, recipe = 16657, crafts = 20, note = "Based on game files only; the guide could not test this far." },
        { from = 290, to = 300, recipe = 16730, crafts = 10 },
    },
}
