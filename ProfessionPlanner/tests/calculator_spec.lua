-- Tests for Core/Calculator.lua with small mock data.

-- Works with tests/run.lua (LoadAddonFile) and with busted run from the repo root.
local LoadFile = LoadAddonFile or function(path, ns)
    loadfile("ProfessionPlanner/" .. path)("ProfessionPlanner", ns)
    return ns
end

local Calculator = LoadFile("Core/Calculator.lua", {}).Calculator

-- IDs used in the mock data (same as the real game IDs, for readability).
local COPPER_ORE, TIN_ORE = 2770, 2771
local COPPER_BAR, TIN_BAR, BRONZE_BAR = 2840, 3576, 2841
local LINEN, LINEN_BOLT, COARSE_THREAD = 2589, 2996, 2320
local HAMMER = 5956

local function MockData()
    local data = { Professions = {}, Sources = {} }
    local S = data.Sources
    S[COPPER_ORE]    = { name = "Copper Ore", type = "node" }
    S[TIN_ORE]       = { name = "Tin Ore", type = "node" }
    S[COPPER_BAR]    = { name = "Copper Bar", type = "smelt", profession = 186, recipe = 1 }
    S[TIN_BAR]       = { name = "Tin Bar", type = "smelt", profession = 186, recipe = 2 }
    S[BRONZE_BAR]    = { name = "Bronze Bar", type = "smelt", profession = 186, recipe = 3 }
    S[LINEN]         = { name = "Linen Cloth", type = "mobdrop" }
    S[LINEN_BOLT]    = { name = "Bolt of Linen Cloth", type = "craft", profession = 197, recipe = 10 }
    S[COARSE_THREAD] = { name = "Coarse Thread", type = "vendor", price = 10 }
    S[HAMMER]        = { name = "Blacksmith Hammer", type = "vendor", price = 16 }

    local trainers = {
        { rank = "Apprentice", maxSkill = 75 },
        { rank = "Journeyman", maxSkill = 150 },
        { rank = "Expert",     maxSkill = 225 },
        { rank = "Artisan",    maxSkill = 300 },
    }

    data.Professions[186] = {
        id = 186, name = "Mining", trainers = trainers, tools = {},
        recipes = {
            [1] = { name = "Smelt Copper", item = COPPER_BAR, count = 1, reagents = { { COPPER_ORE, 1 } } },
            [2] = { name = "Smelt Tin",    item = TIN_BAR,    count = 1, reagents = { { TIN_ORE, 1 } } },
            [3] = { name = "Smelt Bronze", item = BRONZE_BAR, count = 2, reagents = { { COPPER_BAR, 1 }, { TIN_BAR, 1 } } },
        },
        route = {},
    }

    data.Professions[164] = {
        id = 164, name = "Blacksmithing", trainers = trainers,
        tools = { { item = HAMMER, name = "Blacksmith Hammer" } },
        recipes = {
            [20] = { name = "Bronze Thing", item = 9001, count = 1, reagents = { { BRONZE_BAR, 4 } } },
        },
        route = {
            { from = 1, to = 50, recipe = 20, crafts = 10 },
            { from = 50, to = 75, recipe = 20, color = "orange" },
            { from = 75, to = 300, missing = true },
        },
    }

    data.Professions[197] = {
        id = 197, name = "Tailoring", trainers = trainers, tools = {},
        recipes = {
            [10] = { name = "Bolt of Linen Cloth", item = LINEN_BOLT, count = 1, reagents = { { LINEN, 2 } } },
            [11] = { name = "Linen Belt", item = 9002, count = 1, reagents = { { LINEN_BOLT, 1 }, { COARSE_THREAD, 1 } } },
        },
        route = {
            { from = 1, to = 30, recipe = 10, crafts = 30 },
            { from = 30, to = 55, recipe = 11, crafts = 25 },
        },
    }
    return data
end

local function Inventories(chars, accountBank)
    return { current = "Me-Realm", chars = chars, accountBank = accountBank }
end

local function NoStock()
    return Inventories({ ["Me-Realm"] = { bags = {}, bank = {} } })
end

describe("Calculator", function()
    local data
    before_each(function()
        data = MockData()
    end)

    describe("lookups", function()
        it("finds a profession by name in any case, or by ID", function()
            assert.are.equal(164, Calculator.FindProfession(data, "blacksmithing").id)
            assert.are.equal(164, Calculator.FindProfession(data, "BlackSmithing").id)
            assert.are.equal(197, Calculator.FindProfession(data, "197").id)
            assert.is_nil(Calculator.FindProfession(data, "Alchemy"))
        end)

        it("finds the next milestone", function()
            local prof = data.Professions[164]
            assert.are.equal(75, Calculator.NextMilestone(prof, 1))
            assert.are.equal(150, Calculator.NextMilestone(prof, 75))
            assert.are.equal(150, Calculator.NextMilestone(prof, 103))
            assert.are.equal(300, Calculator.NextMilestone(prof, 299))
            assert.is_nil(Calculator.NextMilestone(prof, 300))
        end)

        it("formats money", function()
            assert.are.equal("0c", Calculator.FormatMoney(0))
            assert.are.equal("5c", Calculator.FormatMoney(5))
            assert.are.equal("1s 5c", Calculator.FormatMoney(105))
            assert.are.equal("1g 20s", Calculator.FormatMoney(12000))
        end)
    end)

    describe("remaining steps", function()
        it("returns whole steps when starting at the beginning", function()
            local steps = Calculator.GetRemainingSteps(data.Professions[197], 1, 55)
            assert.are.equal(2, #steps)
            assert.are.equal(30, steps[1].crafts)
            assert.are.equal(25, steps[2].crafts)
        end)

        it("scales a step we are halfway through", function()
            -- 1-30 needs 30 crafts over 29 points; from 16 there are 14 points left.
            local steps = Calculator.GetRemainingSteps(data.Professions[197], 16, 30)
            assert.are.equal(1, #steps)
            assert.are.equal(16, steps[1].from)
            assert.are.equal(15, steps[1].crafts)  -- ceil(30 * 14 / 29) = ceil(14.48)
        end)

        it("stops at the target", function()
            local steps = Calculator.GetRemainingSteps(data.Professions[197], 1, 40)
            assert.are.equal(2, #steps)
            assert.are.equal(40, steps[2].to)
            assert.are.equal(10, steps[2].crafts)  -- 25 crafts * 10/25
        end)

        it("uses skill points per colour when the step has no craft count", function()
            -- 50-75 orange: 25 points at 1 point per craft.
            local steps = Calculator.GetRemainingSteps(data.Professions[164], 50, 75)
            assert.are.equal(25, steps[1].crafts)
            -- With custom points: orange = 0.5 means twice as many crafts.
            steps = Calculator.GetRemainingSteps(data.Professions[164], 50, 75, { orange = 0.5 })
            assert.are.equal(50, steps[1].crafts)
        end)

        it("returns nothing when already at the target", function()
            assert.are.equal(0, #Calculator.GetRemainingSteps(data.Professions[197], 55, 55))
        end)
    end)

    describe("plan", function()
        it("breaks bolts down to cloth (Bolt of Linen Cloth -> 2x Linen Cloth)", function()
            local plan = Calculator.Plan(data, data.Professions[197], 1, 30, NoStock())
            assert.are.equal(60, plan.items[LINEN].missing)
            assert.are.equal(1, #plan.shopping)
        end)

        it("uses bolts made in an earlier step for a later step", function()
            -- 1-30 makes 30 bolts, 30-55 uses 25 of them: no extra cloth needed.
            local plan = Calculator.Plan(data, data.Professions[197], 1, 55, NoStock())
            assert.are.equal(60, plan.items[LINEN].missing)
            assert.are.equal(25, plan.items[LINEN_BOLT].fromMade)
            assert.are.equal(0, plan.items[LINEN_BOLT].fromStock)  -- not something we owned
            assert.are.equal(0, plan.items[LINEN_BOLT].toCraft)
            assert.are.equal(25, plan.items[COARSE_THREAD].missing)
            assert.are.equal(250, plan.cost)  -- 25 thread x 10c
        end)

        it("breaks Bronze Bar down to ore, and smelting makes 2 bars", function()
            -- 40 bars needed (10 crafts x 4) = 20 smelts = 20 copper + 20 tin bars = 20 + 20 ore.
            local plan = Calculator.Plan(data, data.Professions[164], 1, 50, NoStock())
            assert.are.equal(40, plan.items[BRONZE_BAR].toCraft)
            assert.are.equal(20, plan.items[COPPER_BAR].toCraft)
            assert.are.equal(20, plan.items[COPPER_ORE].missing)
            assert.are.equal(20, plan.items[TIN_ORE].missing)
        end)

        it("does not count leftover bars from smelting as owned", function()
            -- 3 bars per craft, 2 crafts = 6 bars from 20 owned: no smelting at all.
            data.Professions[164].recipes[20].reagents = { { BRONZE_BAR, 3 } }
            local inv = Inventories({ ["Me-Realm"] = { bags = { [BRONZE_BAR] = 5 }, bank = {} } })
            -- From 45: 2 crafts = 6 bars. 5 owned, 1 smelt makes 2 -> 1 bar left over.
            local plan = Calculator.Plan(data, data.Professions[164], 45, 50, inv)
            assert.are.equal(5, plan.items[BRONZE_BAR].fromStock)
            assert.are.equal(1, plan.items[BRONZE_BAR].toCraft)
            assert.are.equal(1, plan.items[COPPER_ORE].missing)
            assert.are.equal(1, #plan.stock)  -- only the bronze we really own
        end)

        it("rounds up when an odd number of bronze bars is needed", function()
            data.Professions[164].recipes[20].reagents = { { BRONZE_BAR, 3 } }
            -- From 45: ceil(10 * 5/49) = 2 crafts -> 6 bars -> 3 smelts -> 3 copper ore.
            local plan = Calculator.Plan(data, data.Professions[164], 45, 50, NoStock())
            assert.are.equal(3, plan.items[COPPER_ORE].missing)
        end)

        it("subtracts what the current character has", function()
            local inv = Inventories({ ["Me-Realm"] = { bags = { [LINEN] = 10 }, bank = { [LINEN] = 5 } } })
            local plan = Calculator.Plan(data, data.Professions[197], 1, 30, inv)
            assert.are.equal(15, plan.items[LINEN].fromStock)
            assert.are.equal(45, plan.items[LINEN].missing)
        end)

        it("uses intermediate items in stock before breaking them down", function()
            local inv = Inventories({ ["Me-Realm"] = { bags = { [BRONZE_BAR] = 30 }, bank = {} } })
            local plan = Calculator.Plan(data, data.Professions[164], 1, 50, inv)
            assert.are.equal(30, plan.items[BRONZE_BAR].fromStock)
            assert.are.equal(5, plan.items[COPPER_ORE].missing)  -- 10 bars left = 5 smelts
        end)

        it("uses alts and the account bank with scope 'account', and says who has what", function()
            local inv = Inventories({
                ["Me-Realm"] = { bags = {}, bank = {} },
                ["Bankalt-Realm"] = { bags = {}, bank = { [COPPER_ORE] = 40 } },
            }, { [TIN_ORE] = 7 })
            local plan = Calculator.Plan(data, data.Professions[164], 1, 50, inv)
            assert.are.equal(0, plan.items[COPPER_ORE].missing)
            assert.are.equal(13, plan.items[TIN_ORE].missing)
            local holder = plan.items[COPPER_ORE].holders[1]
            assert.are.equal("Bankalt-Realm", holder.who)
            assert.are.equal("bank", holder.where)
            assert.are.equal(40, holder.count)
            assert.are.equal("accountBank", plan.items[TIN_ORE].holders[1].where)
        end)

        it("ignores alts with scope 'character' but still lists them as holders", function()
            local inv = Inventories({
                ["Me-Realm"] = { bags = {}, bank = {} },
                ["Bankalt-Realm"] = { bags = {}, bank = { [COPPER_ORE] = 40 } },
            })
            local plan = Calculator.Plan(data, data.Professions[164], 1, 50, inv, { scope = "character" })
            assert.are.equal(20, plan.items[COPPER_ORE].missing)
            assert.are.equal(1, #plan.items[COPPER_ORE].holders)
        end)

        it("flags route parts that have no data yet", function()
            local plan = Calculator.Plan(data, data.Professions[164], 1, 150, NoStock())
            assert.is_true(plan.missingRoute)
            plan = Calculator.Plan(data, data.Professions[164], 1, 50, NoStock())
            assert.is_nil(plan.missingRoute)
        end)

        it("lists the trainer ranks needed", function()
            local prof = data.Professions[164]
            -- Not learned yet, target 75: only Apprentice.
            local plan = Calculator.Plan(data, prof, 0, 75, NoStock(), { currentMax = 0 })
            assert.are.equal(1, #plan.trainers)
            assert.are.equal("Apprentice", plan.trainers[1].rank)
            -- Journeyman (cap 150), target 225: only Expert.
            plan = Calculator.Plan(data, prof, 103, 225, NoStock(), { currentMax = 150 })
            assert.are.equal(1, #plan.trainers)
            assert.are.equal("Expert", plan.trainers[1].rank)
            -- Apprentice (cap 75), target 300: Journeyman, Expert and Artisan.
            plan = Calculator.Plan(data, prof, 60, 300, NoStock(), { currentMax = 75 })
            assert.are.equal(3, #plan.trainers)
        end)

        it("checks tools on the current character only", function()
            local inv = Inventories({
                ["Me-Realm"] = { bags = {}, bank = {} },
                ["Alt-Realm"] = { bags = { [HAMMER] = 1 }, bank = {} },
            })
            local plan = Calculator.Plan(data, data.Professions[164], 1, 50, inv)
            assert.is_false(plan.tools[1].have)
            inv.chars["Me-Realm"].bags[HAMMER] = 1
            plan = Calculator.Plan(data, data.Professions[164], 1, 50, inv)
            assert.is_true(plan.tools[1].have)
        end)

        it("stops on recipe loops instead of hanging", function()
            -- Make Copper Bar need Bronze Bar, which needs Copper Bar.
            data.Professions[186].recipes[1].reagents = { { BRONZE_BAR, 1 } }
            assert.has_error(function()
                Calculator.Plan(data, data.Professions[164], 1, 50, NoStock())
            end)
        end)
    end)
end)
