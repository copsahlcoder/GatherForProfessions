-- Tailoring: recipes and leveling route.
-- Pure data, no logic. See README.md for the format.
--
-- Source: https://www.wow-professions.com/forever/tailoring-leveling-guide
-- (read 2026-11-07, after launch). The guide marks 225-300 as untested and
-- has no route past 265 yet.
-- Spell IDs and reagents checked against https://www.wowhead.com/forever/
local _, ns = ...

ns.Data.Professions[197] = {
    id = 197,
    name = "Tailoring",
    beta = true,  -- 225-300 untested by the guide
    source = "https://www.wow-professions.com/forever/tailoring-leveling-guide",

    tools = {},

    -- Forever: Apprentice has no level requirement. Expert costs 50 silver.
    -- cost is in copper; nil = not listed in the guide.
    trainers = {
        { rank = "Apprentice", maxSkill = 75,  minSkill = 0,   minLevel = nil, cost = nil,
          horde = { "Snang (Orgrimmar)", "Victor Ward (Undercity)", "Vhan (Thunder Bluff)", "Bowen Brisboise (Tirisfal Glades)" },
          alliance = { "Lawrence Schneider (Stormwind)", "Uthrar Threx (Ironforge)", "Trianna (Darnassus)", "Eldrin (Elwynn Forest)" } },
        { rank = "Journeyman", maxSkill = 150, minSkill = 50,  minLevel = 10,  cost = nil,
          horde = { "Magar (Orgrimmar)", "Rhiannon Davis (Undercity)", "Tepa (Thunder Bluff)" },
          alliance = { "Sellandus (Stormwind)", "Jormund Stonebrow (Ironforge)", "Me'lynn (Darnassus)" } },
        { rank = "Expert",     maxSkill = 225, minSkill = 125, minLevel = 20,  cost = 5000,
          horde = { "Josef Gregorian (Undercity)" },
          alliance = { "Georgio Bolero (Stormwind)" } },
        { rank = "Artisan",    maxSkill = 300, minSkill = 200, minLevel = 35,  cost = nil,
          horde = { "Daryl Stack (Tarren Mill)" },
          alliance = { "Timothy Worthington (Theramore Isle)" } },
    },

    -- Recipes keyed by spellID. Reagents follow the Forever guide's totals.
    -- Skill colour thresholds are left out on purpose (see Blacksmithing.lua).
    recipes = {
        [2963]  = { name = "Bolt of Linen Cloth",     item = 2996,  count = 1, learn = "trainer", reagents = { { 2589, 2 } } },
        [8776]  = { name = "Linen Belt",              item = 7026,  count = 1, learn = "trainer", reagents = { { 2996, 1 }, { 2320, 1 } } },
        [2964]  = { name = "Bolt of Woolen Cloth",    item = 2997,  count = 1, learn = "trainer", reagents = { { 2592, 3 } } },
        [2402]  = { name = "Woolen Cape",             item = 2584,  count = 1, learn = "trainer", reagents = { { 2997, 1 }, { 2321, 1 } } },
        -- The spell says "stitched", the item says "Stitched".
        [3848]  = { name = "Double-stitched Woolen Shoulders", itemName = "Double-Stitched Woolen Shoulders",
                    item = 4314, count = 1, learn = "trainer", reagents = { { 2997, 3 }, { 2321, 2 } } },
        [3839]  = { name = "Bolt of Silk Cloth",      item = 4305,  count = 1, learn = "trainer", reagents = { { 4306, 4 } } },
        [3852]  = { name = "Gloves of Meditation",    item = 4318,  count = 1, learn = "trainer", reagents = { { 2997, 4 }, { 2321, 3 }, { 3383, 1 } } },
        [3865]  = { name = "Bolt of Mageweave",       item = 4339,  count = 1, learn = "trainer", reagents = { { 4338, 5 } } },
        [8489]  = { name = "Red Swashbuckler's Shirt", item = 6796, count = 1, learn = "trainer", reagents = { { 4305, 3 }, { 2604, 2 }, { 4291, 1 } } },
        [8791]  = { name = "Crimson Silk Vest",       item = 7058,  count = 1, learn = "trainer", reagents = { { 4305, 4 }, { 2604, 2 }, { 2321, 2 } } },
        [8799]  = { name = "Crimson Silk Pantaloons", item = 7062,  count = 1, learn = "trainer", reagents = { { 4305, 4 }, { 2604, 2 }, { 4291, 2 } } },
        [12053] = { name = "Black Mageweave Gloves",  item = 10003, count = 1, learn = "trainer", reagents = { { 4339, 2 }, { 8343, 2 } } },
        [12065] = { name = "Mageweave Bag",           item = 10050, count = 1, learn = "trainer", reagents = { { 4339, 4 }, { 4291, 2 } } },
        [18401] = { name = "Bolt of Runecloth",       item = 14048, count = 1, learn = "trainer", reagents = { { 14047, 5 } },
                    note = "Gives no skill points any more, so make all the bolts you need at once." },
        [18402] = { name = "Runecloth Belt",          item = 13856, count = 1, learn = "trainer", reagents = { { 14048, 3 }, { 14341, 1 } } },
        [18417] = { name = "Runecloth Gloves",        item = 13863, count = 1, learn = "vendor", note = "Pattern from Qia (Everlook, Winterspring).",
                    reagents = { { 14048, 4 }, { 8170, 4 }, { 14341, 1 } } },
    },

    -- Leveling route. crafts = how many the guide says to make for this step.
    route = {
        { from = 1,   to = 30,  recipe = 2963,  crafts = 30 },
        { from = 30,  to = 55,  recipe = 8776,  crafts = 28 },
        { from = 55,  to = 80,  recipe = 2964,  crafts = 45 },
        { from = 80,  to = 95,  recipe = 2402,  crafts = 22 },
        { from = 95,  to = 100, recipe = 3848,  crafts = 5 },
        { from = 100, to = 120, recipe = 3839,  crafts = 54, note = "Keep the bolts, you need them at 150-190." },
        { from = 120, to = 125, recipe = 3852,  crafts = 5 },
        { from = 125, to = 140, recipe = 3852,  crafts = 24 },
        { from = 140, to = 150, recipe = 3865,  crafts = 23, alternatives = { { recipe = 8489, crafts = 10 } },
          note = "Keep the bolts, you need them at 190-225." },
        { from = 150, to = 170, recipe = 8791,  crafts = 20 },
        { from = 170, to = 190, recipe = 8799,  crafts = 26 },
        { from = 190, to = 215, recipe = 12053, crafts = 38 },
        { from = 215, to = 225, recipe = 12065, crafts = 26 },
        { from = 225, to = 240, recipe = 18402, crafts = 24, note = "Untested by the guide from here on (written during the beta)." },
        { from = 240, to = 265, recipe = 18417, crafts = 43 },
        { from = 265, to = 300, missing = true,
          note = "No trainer or vendor recipe found past 265 yet. Candidates (world drop patterns): Runecloth Shoulders, Wizardweave Turban." },
    },
}
