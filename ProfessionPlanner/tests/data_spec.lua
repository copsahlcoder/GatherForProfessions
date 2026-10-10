-- Sanity checks on the real data files in Data/, plus a full plan run on them.
-- These catch typos (missing sources, wrong recipe IDs, gaps in routes)
-- before you ever start the game.

local LoadFile = LoadAddonFile or function(path, ns)
    loadfile("ProfessionPlanner/" .. path)("ProfessionPlanner", ns)
    return ns
end

local ns = { Data = { Professions = {}, Sources = {} } }
for _, file in ipairs({ "Data/Sources.lua", "Data/Mining.lua", "Data/Blacksmithing.lua", "Data/Tailoring.lua" }) do
    LoadFile(file, ns)
end
LoadFile("Core/Calculator.lua", ns)
local Data, Calculator = ns.Data, ns.Calculator

describe("Data files", function()
    it("load Mining, Blacksmithing and Tailoring", function()
        assert.is_not_nil(Data.Professions[186])
        assert.is_not_nil(Data.Professions[164])
        assert.is_not_nil(Data.Professions[197])
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
        -- 114 Copper Bar for gear + 380 Bronze Bar (190 smelts = 190 more copper bars).
        assert.are.equal(114 + 190, plan.items[2770].missing)  -- Copper Ore
        assert.are.equal(190, plan.items[2771].missing)        -- Tin Ore
    end)

    it("Tailoring 1-30 needs 60 Linen Cloth", function()
        local plan = Calculator.Plan(Data, Data.Professions[197], 1, 30, empty)
        assert.are.equal(60, plan.items[2589].missing)
    end)

    it("Mining has gather steps but nothing to buy", function()
        local plan = Calculator.Plan(Data, Data.Professions[186], 1, 150, empty)
        assert.are.equal(0, #plan.shopping)
        assert.is_not_nil(plan.steps[1].step.gather)
    end)

    it("Blacksmithing to 300 flags the missing Artisan route", function()
        local plan = Calculator.Plan(Data, Data.Professions[164], 200, 300, empty)
        assert.is_true(plan.missingRoute)
    end)
end)
