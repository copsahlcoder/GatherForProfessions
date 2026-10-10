-- Mining: gathering route and smelting recipes.
-- Pure data, no logic. See README.md for the format.
--
-- wow-professions.com has no Forever Mining guide yet, so the route below
-- follows the Classic rules. Forever is in BETA; update this when a guide exists.
local _, ns = ...

ns.Data.Professions[186] = {
    id = 186,
    name = "Mining",
    gathering = true,  -- levels by gathering, not crafting
    beta = true,
    source = "Classic rules (no Forever Mining guide yet)",  -- TODO: verify when a Forever guide exists

    -- Items you must carry to use the profession.
    tools = {
        { item = 2901, name = "Mining Pick" },
    },

    -- minLevel = character level, minSkill = skill needed to learn the rank.
    -- TODO: verify all Mining trainer data for Forever (copied from Classic).
    trainers = {
        { rank = "Apprentice", maxSkill = 75,  minSkill = 0,   minLevel = nil, cost = nil,
          horde = { "Makaru (Orgrimmar)", "Brom Killian (Undercity)", "Brek Stonehoof (Thunder Bluff)", "Krunn (Durotar)" },
          alliance = { "Geofram Bouldertoe (Ironforge)", "Gelman Stonehand (Stormwind)", "Yarr Hammerstone (Dun Morogh)", "Kurdram Stonehammer (Darkshore)" } },
        { rank = "Journeyman", maxSkill = 150, minSkill = 50,  minLevel = 10,  cost = nil,
          horde = { "Makaru (Orgrimmar)", "Brom Killian (Undercity)", "Brek Stonehoof (Thunder Bluff)", "Johan Focht (Silverpine Forest)" },
          alliance = { "Geofram Bouldertoe (Ironforge)", "Gelman Stonehand (Stormwind)", "Matt Johnson (Duskwood)" } },
        { rank = "Expert",     maxSkill = 225, minSkill = 125, minLevel = 20,  cost = nil,
          horde = { "Makaru (Orgrimmar)", "Brom Killian (Undercity)", "Brek Stonehoof (Thunder Bluff)" },
          alliance = { "Geofram Bouldertoe (Ironforge)", "Gelman Stonehand (Stormwind)" } },
        { rank = "Artisan",    maxSkill = 300, minSkill = 200, minLevel = 35,  cost = nil,
          horde = { "Pikkle (Tanaris)" },
          alliance = { "Pikkle (Tanaris)" } },
    },

    -- Smelting recipes, keyed by spellID.
    -- minSkill = Mining skill needed to smelt (Classic values -- TODO: verify for Forever).
    -- Skill colour thresholds (orange/yellow/green/gray) are left out on purpose:
    -- Forever differs from Classic and no source lists them yet.
    recipes = {
        [2657]  = { name = "Smelt Copper",     item = 2840,  count = 1, minSkill = 1,   reagents = { { 2770, 1 } } },
        [3304]  = { name = "Smelt Tin",        item = 3576,  count = 1, minSkill = 65,  reagents = { { 2771, 1 } } },
        [2659]  = { name = "Smelt Bronze",     item = 2841,  count = 2, minSkill = 65,  reagents = { { 2840, 1 }, { 3576, 1 } } },
        [2658]  = { name = "Smelt Silver",     item = 2842,  count = 1, minSkill = 75,  reagents = { { 2775, 1 } } },
        [3307]  = { name = "Smelt Iron",       item = 3575,  count = 1, minSkill = 125, reagents = { { 2772, 1 } } },
        [3308]  = { name = "Smelt Gold",       item = 3577,  count = 1, minSkill = 155, reagents = { { 2776, 1 } } },
        [3569]  = { name = "Smelt Steel",      item = 3859,  count = 1, minSkill = 165, reagents = { { 3575, 1 }, { 3857, 1 } } },
        [10097] = { name = "Smelt Mithril",    item = 3860,  count = 1, minSkill = 175, reagents = { { 3858, 1 } } },
        [10098] = { name = "Smelt Truesilver", item = 6037,  count = 1, minSkill = 230, reagents = { { 7911, 1 } } },
        [16153] = { name = "Smelt Thorium",    item = 12359, count = 1, minSkill = 250, reagents = { { 10620, 1 } } },
    },

    -- Leveling route. Mining levels by gathering, so steps list the ores to
    -- mine (gather) instead of a recipe. Zones are in Data/Sources.lua.
    -- TODO: verify whole route for Forever (Classic route).
    route = {
        { from = 1,   to = 65,  gather = { 2770 },               note = "Mine Copper Veins." },
        { from = 65,  to = 125, gather = { 2771, 2770, 2775 },   note = "Mine Tin Veins (plus Copper and Silver)." },
        { from = 125, to = 175, gather = { 2772, 2776, 2771 },   note = "Mine Iron Deposits (plus Gold). Smelting Gold from 155 also gives skill." },
        { from = 175, to = 245, gather = { 3858, 7911 },         note = "Mine Mithril Deposits (plus Truesilver)." },
        { from = 245, to = 300, gather = { 10620, 3858, 7911 },  note = "Mine Small Thorium Veins, Rich Thorium from 275." },
    },
}
