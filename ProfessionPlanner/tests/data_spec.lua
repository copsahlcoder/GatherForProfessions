-- Sanity checks on the real data files in Data/, plus a full plan run on them.
-- These catch typos (missing sources, wrong recipe IDs, gaps in routes)
-- before you ever start the game.

local LoadFile = LoadAddonFile or function(path, ns)
    loadfile("ProfessionPlanner/" .. path)("ProfessionPlanner", ns)
    return ns
end

local ns = { Data = { Professions = {}, Sources = {} } }
for _, file in ipairs({ "Data/Sources.lua", "Data/Mining.lua", "Data/Blacksmithing.lua",
                        "Data/Tailoring.lua", "Data/Leatherworking.lua", "Data/Enchanting.lua" }) do
    LoadFile(file, ns)
end
LoadFile("Core/Calculator.lua", ns)
local Data, Calculator = ns.Data, ns.Calculator

describe("Data files", function()
    it("load Mining, Blacksmithing, Tailoring, Leatherworking and Enchanting", function()
        assert.is_not_nil(Data.Professions[186])
        assert.is_not_nil(Data.Professions[164])
        assert.is_not_nil(Data.Professions[197])
        assert.is_not_nil(Data.Professions[165])
        assert.is_not_nil(Data.Professions[333])
    end)

    for id, prof in pairs(Data.Professions) do
        describe(prof.name, function()
            it("has its ID as key", function()
                assert.are.equal(id, prof.id)
            end)

            it("has a source for every reagent", function()
                for spellID, recipe in pairs(prof.recipes) do
                    for _, reagent in ipairs(recipe.reagents) do
                        assert(Data.Sources[reagent[1]], "recipe " .. spellID .. " uses item " .. reagent[1] .. " with no source")
                    end
                end
            end)

            it("only uses recipes that exist", function()
                for _, step in ipairs(prof.route) do
                    if step.recipe then
                        assert(prof.recipes[step.recipe], "route " .. step.from .. "-" .. step.to .. " uses unknown recipe " .. step.recipe)
                    end
                    for _, alt in ipairs(step.alternatives or {}) do
                        assert(prof.recipes[alt.recipe], "alternative uses unknown recipe " .. alt.recipe)
                    end
                end
            end)

            it("has a route from 1 to 300 without gaps", function()
                local expected = 1
                for _, step in ipairs(prof.route) do
                    assert(step.from == expected, "route gap or overlap at " .. step.from .. " (expected " .. expected .. ")")
                    assert(step.to > step.from, "empty step at " .. step.from)
                    expected = step.to
                end
                assert.are.equal(300, expected)
            end)

            it("has four trainer ranks ending at 300", function()
                assert.are.equal(4, #prof.trainers)
                assert.are.equal(300, prof.trainers[4].maxSkill)
            end)
        end)
    end

    describe("Sources", function()
        it("point to recipes that exist and make that item", function()
            for itemID, source in pairs(Data.Sources) do
                if source.type == "craft" or source.type == "smelt" then
                    local recipe = Calculator.GetSourceRecipe(Data, itemID)
                    assert(recipe, source.name .. " points to a missing recipe")
                    assert(recipe.item == itemID, source.name .. " points to a recipe that makes something else")
                end
            end
        end)

        it("have a price for every vendor item", function()
            for _, source in pairs(Data.Sources) do
                if source.type == "vendor" then
                    assert(source.price, source.name .. " has no price")
                end
            end
        end)
    end)
end)

describe("Plan with real data", function()
    local empty = { current = "Me-Realm", chars = { ["Me-Realm"] = { bags = {}, bank = {} } } }

    it("Blacksmithing 1-150 matches the guide's totals", function()
        local plan = Calculator.Plan(Data, Data.Professions[164], 1, 150, empty)
        -- Guide (1-150): 90 Rough Stone, 72 Coarse Stone, 60 Heavy Stone, 96 Weak Flux.
        assert.are.equal(90, plan.items[2835].missing)
        assert.are.equal(72, plan.items[2836].missing)
        assert.are.equal(60, plan.items[2838].missing)
        assert.are.equal(96, plan.items[2880].missing)
        -- 294 Copper Bar for gear + 290 Bronze Bar (145 smelts = 145 more copper bars).
        assert.are.equal(294 + 145, plan.items[2770].missing)  -- Copper Ore
        assert.are.equal(145, plan.items[2771].missing)        -- Tin Ore
    end)

    it("Blacksmithing 225-300 matches the guide's totals", function()
        local plan = Calculator.Plan(Data, Data.Professions[164], 225, 300, empty)
        -- Guide: 1910 Thorium Bar incl. 140 for the quests (not counted by us).
        assert.are.equal(1910 - 140, plan.items[10620].missing)  -- Thorium Ore (1 per bar)
        assert.are.equal(224, plan.items[3858].missing)          -- Mithril Ore
        assert.are.equal(5, plan.items[12365].missing)           -- Dense Stone
        assert.are.equal(64, plan.items[4304].missing)           -- Thick Leather
        assert.are.equal(30, plan.items[8170].missing)           -- Rugged Leather
        assert.are.equal(67, plan.items[7910].missing)           -- Star Ruby
        assert.are.equal(25, plan.items[7909].missing)           -- Aquamarine
    end)

    it("Tailoring 225-265 needs the guide's 1220 Runecloth", function()
        local plan = Calculator.Plan(Data, Data.Professions[197], 225, 265, empty)
        assert.are.equal(1220, plan.items[14047].missing)
        assert.are.equal(172, plan.items[8170].missing)   -- Rugged Leather
        assert.are.equal(244, plan.items[14048].toCraft)  -- Bolt of Runecloth
    end)

    it("Enchanting 1-300 matches the guide's shopping list", function()
        local plan = Calculator.Plan(Data, Data.Professions[333], 1, 300, empty)
        assert.is_nil(plan.missingRoute)
        assert.are.equal(19, plan.items[247786].missing)       -- Mote of Magic
        assert.are.equal(46 + 75, plan.items[11137].missing)   -- Vision Dust (1-225 + 225-300)
        assert.are.equal(212, plan.items[11176].missing)       -- Dream Dust
        assert.are.equal(50, plan.items[16204].missing)        -- Illusion Dust
        assert.are.equal(39, plan.items[11083].missing)        -- Soul Dust
    end)

    it("Tailoring 1-30 needs 60 Linen Cloth", function()
        local plan = Calculator.Plan(Data, Data.Professions[197], 1, 30, empty)
        assert.are.equal(60, plan.items[2589].missing)
    end)

    it("Leatherworking 1-130 matches the guide", function()
        local plan = Calculator.Plan(Data, Data.Professions[165], 1, 130, empty)
        assert.are.equal(99, plan.items[2934].missing)   -- Ruined Leather Scraps (guide: ~100)
        -- Light Leather: 63 + 32 + 114 + 240 = 449 used, 33 made at 1-30 (guide: ~415).
        assert.are.equal(416, plan.items[2318].missing)
        assert.are.equal(27, plan.items[783].missing)    -- Light Hide
        -- Hides and belts made earlier in the route are reused, not bought.
        assert.are.equal(24, plan.items[4231].fromMade)  -- Cured Light Hide
        assert.are.equal(10, plan.items[4246].fromMade)  -- Fine Leather Belt
        assert.are.equal(10, plan.items[4233].fromMade)  -- Cured Medium Hide
    end)

    it("Leatherworking 130-225 makes the extra Cured Heavy Hide it needs", function()
        local plan = Calculator.Plan(Data, Data.Professions[165], 130, 225, empty)
        -- 20 cured at 130-140; 10 + 10 + 26 used later -> 26 more to cure.
        assert.are.equal(26, plan.items[4236].toCraft)
        assert.are.equal(46, plan.items[4235].missing)   -- Heavy Hide: 20 + 26
        assert.are.equal(315, plan.items[4304].missing)  -- Thick Leather (guide: 315)
    end)

    it("Mining has gather steps but nothing to buy", function()
        local plan = Calculator.Plan(Data, Data.Professions[186], 1, 150, empty)
        assert.are.equal(0, #plan.shopping)
        assert.is_not_nil(plan.steps[1].step.gather)
    end)

    it("Tailoring to 300 flags the missing 265-300 route", function()
        local plan = Calculator.Plan(Data, Data.Professions[197], 200, 300, empty)
        assert.is_true(plan.missingRoute)
    end)

    it("only makes leather from lower leather when asked", function()
        -- Bronze Shortsword x24 (125-140) needs 48 Medium Leather.
        local plan = Calculator.Plan(Data, Data.Professions[164], 125, 140, empty)
        assert.are.equal(48, plan.items[2319].missing)
        assert.is_nil(plan.items[2318])

        plan = Calculator.Plan(Data, Data.Professions[164], 125, 140, empty, { makeLeather = true })
        assert.are.equal(0, plan.items[2319].missing)
        assert.are.equal(48, plan.items[2319].toCraft)
        assert.are.equal(48 * 4, plan.items[2318].toCraft)      -- Light Leather, made from scraps
        assert.are.equal(48 * 4 * 3, plan.items[2934].missing)  -- Ruined Leather Scraps
    end)
end)
