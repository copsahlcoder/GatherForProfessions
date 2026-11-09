-- /gfp verify: checks the static data in Data/*.lua against the game.
-- For every itemID and spellID we ask the client for its name and print any
-- that are missing or have a different name than the data file says.
local addonName, ns = ...
local L = ns.L
local Compat = ns.Compat

local Verify = {}
ns.Verify = Verify

-- Seconds to wait for the server to send item data before reporting.
local ITEM_WAIT = 3

-- Collects { [itemID] = expectedName } and { [spellID] = expectedName },
-- plus a list of data problems we can find without asking the game.
local function CollectIDs()
    local items, spells, problems = {}, {}, {}
    local Sources = ns.Data.Sources

    for itemID, source in pairs(Sources) do
        items[itemID] = source.name
    end

    for _, prof in pairs(ns.Data.Professions) do
        for _, tool in ipairs(prof.tools or {}) do
            items[tool.item] = tool.name
        end

        for spellID, recipe in pairs(prof.recipes) do
            spells[spellID] = recipe.name
            -- Products named in Sources (bars, bolts...) use that name;
            -- other products use itemName, or the recipe name if not set.
            -- Enchants make no item, so there is nothing to check.
            if recipe.item and not items[recipe.item] then
                items[recipe.item] = recipe.itemName or recipe.name
            end
            for _, reagent in ipairs(recipe.reagents) do
                if not Sources[reagent[1]] then
                    table.insert(problems, string.format(L.VERIFY_NO_SOURCE, reagent[1], recipe.name))
                end
            end
        end

        -- Every recipe the route uses must exist in the recipes table.
        local function CheckRecipe(step, recipeID)
            if not prof.recipes[recipeID] then
                table.insert(problems, string.format(L.VERIFY_NO_RECIPE, prof.name, step.from, step.to, recipeID))
            end
        end
        for _, step in ipairs(prof.route) do
            if step.recipe then
                CheckRecipe(step, step.recipe)
            end
            for _, alt in ipairs(step.alternatives or {}) do
                CheckRecipe(step, alt.recipe)
            end
        end
    end
    return items, spells, problems
end

-- Compares names and prints one line per problem. Returns the problem count.
local function Report(items, spells, problems)
    for itemID, expected in pairs(items) do
        local actual = Compat.GetItemName(itemID)
        if not actual then
            table.insert(problems, string.format(L.VERIFY_ITEM_MISSING, itemID, expected))
        elseif actual ~= expected then
            table.insert(problems, string.format(L.VERIFY_ITEM_WRONG, itemID, expected, actual))
        end
    end

    for spellID, expected in pairs(spells) do
        local actual = Compat.GetSpellName(spellID)
        if not actual then
            table.insert(problems, string.format(L.VERIFY_SPELL_MISSING, spellID, expected))
        elseif actual ~= expected then
            table.insert(problems, string.format(L.VERIFY_SPELL_WRONG, spellID, expected, actual))
        end
    end

    table.sort(problems)
    for _, line in ipairs(problems) do
        ns:Print(line)
    end
    return #problems
end

-- /gfp lookup spell|item <from> [to]: prints the names of a range of IDs.
-- Handy for finding the right ID when /gfp verify reports a wrong one.
local MAX_LOOKUP = 50

function Verify.Lookup(arg)
    local kind, from, to = string.match(arg or "", "^(%a+)%s+(%d+)%s*(%d*)$")
    from = tonumber(from)
    to = tonumber(to) or from
    if not from or (kind ~= "spell" and kind ~= "item") or to < from or to - from >= MAX_LOOKUP then
        ns:Print(L.LOOKUP_USAGE, MAX_LOOKUP)
        return
    end

    local function PrintRange()
        for id = from, to do
            local name
            if kind == "spell" then
                name = Compat.GetSpellName(id)
            else
                name = Compat.GetItemName(id)
            end
            if name then
                ns:Print(L.LOOKUP_LINE, kind, id, name)
            end
        end
    end

    if kind == "spell" then
        PrintRange()
    else
        -- Items may need to be loaded from the server first.
        for id = from, to do
            Compat.RequestItem(id)
        end
        ns:Print(L.LOOKUP_WAIT, ITEM_WAIT)
        Compat.After(ITEM_WAIT, function()
            ns:SafeCall("/gfp lookup", PrintRange)
        end)
    end
end

function Verify.Run()
    local items, spells, problems = CollectIDs()

    local numItems, numSpells = 0, 0
    for itemID in pairs(items) do
        Compat.RequestItem(itemID)
        numItems = numItems + 1
    end
    for _ in pairs(spells) do
        numSpells = numSpells + 1
    end

    ns:Print(L.VERIFY_START, numItems, numSpells, ITEM_WAIT)
    Compat.After(ITEM_WAIT, function()
        ns:SafeCall("/gfp verify", function()
            local count = Report(items, spells, problems)
            if count == 0 then
                ns:Print(L.VERIFY_OK)
            else
                ns:Print(L.VERIFY_DONE, count)
            end
        end)
    end)
end
