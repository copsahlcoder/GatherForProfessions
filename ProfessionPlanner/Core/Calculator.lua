-- Leveling calculator. Pure Lua: no WoW API calls, so it can be tested
-- outside the game (see tests/). All input comes in as plain tables.
--
-- data        = ns.Data ({ Professions = {...}, Sources = {...} })
-- inventories = { current = "Name-Realm",
--                 chars = { ["Name-Realm"] = { bags = {[itemID]=n}, bank = {...} } },
--                 accountBank = { [itemID] = n } or nil }
local _, ns = ...

local Calculator = {}
ns.Calculator = Calculator

-- Expected skill points per craft by recipe colour. Only used for route
-- steps that don't say how many crafts they need.
Calculator.DEFAULT_POINTS = { orange = 1, yellow = 0.75, green = 0.25, gray = 0 }

-- Safety limit for breaking down intermediate items (catches recipe loops).
local MAX_DEPTH = 10

-- math.ceil, but tolerant of tiny floating point errors (30.0000001 -> 30).
local function Ceil(x)
    return math.ceil(x - 1e-9)
end

local function AddCounts(target, counts)
    for itemID, count in pairs(counts or {}) do
        target[itemID] = (target[itemID] or 0) + count
    end
end

---------------------------------------------------------------------------
-- Lookups
---------------------------------------------------------------------------

-- Finds a profession by name (any case) or skill line ID.
function Calculator.FindProfession(data, query)
    local id = tonumber(query)
    if id then
        return data.Professions[id]
    end
    query = string.lower(query or "")
    for _, prof in pairs(data.Professions) do
        if string.lower(prof.name) == query then
            return prof
        end
    end
    return nil
end

-- The next trainer cap above the current skill: 75, 150, 225 or 300.
function Calculator.NextMilestone(prof, skill)
    local best
    for _, trainer in ipairs(prof.trainers) do
        if trainer.maxSkill > skill and (not best or trainer.maxSkill < best) then
            best = trainer.maxSkill
        end
    end
    return best
end

-- Returns the recipe that makes an item (from Sources "craft"/"smelt"), or nil.
function Calculator.GetSourceRecipe(data, itemID)
    local source = data.Sources[itemID]
    if not source or (source.type ~= "craft" and source.type ~= "smelt") then
        return nil
    end
    local prof = data.Professions[source.profession]
    return prof and prof.recipes[source.recipe], prof
end

-- Best known name for an item: Sources first, then any recipe that makes it.
function Calculator.GetItemName(data, itemID)
    local source = data.Sources[itemID]
    if source then
        return source.name
    end
    for _, prof in pairs(data.Professions) do
        for _, recipe in pairs(prof.recipes) do
            if recipe.item == itemID then
                return recipe.itemName or recipe.name
            end
        end
        for _, tool in ipairs(prof.tools or {}) do
            if tool.item == itemID then
                return tool.name
            end
        end
    end
    return "item:" .. itemID
end

-- Formats copper as "1g 20s 5c".
function Calculator.FormatMoney(copper)
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    local rest = copper % 100
    local parts = {}
    if gold > 0 then table.insert(parts, gold .. "g") end
    if silver > 0 then table.insert(parts, silver .. "s") end
    if rest > 0 or #parts == 0 then table.insert(parts, rest .. "c") end
    return table.concat(parts, " ")
end

---------------------------------------------------------------------------
-- Route
---------------------------------------------------------------------------

-- How many crafts a step needs to cover skill `from` to `to`.
-- Uses the guide's craft count, scaled if we only need part of the step.
function Calculator.CraftsForStep(step, from, to, points)
    local skillPoints = to - from
    if step.crafts then
        return Ceil(step.crafts * skillPoints / (step.to - step.from))
    end
    local perCraft = (points or Calculator.DEFAULT_POINTS)[step.color or "yellow"] or 0
    if perCraft <= 0 then
        return 0  -- grey recipes give no skill
    end
    return Ceil(skillPoints / perCraft)
end

-- Returns the route steps between current skill and target, each as
-- { from, to, step, recipeID, recipe, crafts }. Partial steps are trimmed.
function Calculator.GetRemainingSteps(prof, current, target, points)
    local steps = {}
    for _, step in ipairs(prof.route) do
        local from = math.max(step.from, current)
        local to = math.min(step.to, target)
        if to > from then
            local entry = { from = from, to = to, step = step }
            if step.recipe then
                entry.recipeID = step.recipe
                entry.recipe = prof.recipes[step.recipe]
                entry.crafts = Calculator.CraftsForStep(step, from, to, points)
            end
            table.insert(steps, entry)
        end
    end
    return steps
end

---------------------------------------------------------------------------
-- Inventories
---------------------------------------------------------------------------

-- Everything we may use. scope = "character" (only the current character)
-- or "account" (all characters + account bank).
function Calculator.BuildPool(inventories, scope)
    local pool = {}
    if scope == "character" then
        local char = inventories.chars[inventories.current]
        if char then
            AddCounts(pool, char.bags)
            AddCounts(pool, char.bank)
        end
    else
        for _, char in pairs(inventories.chars) do
            AddCounts(pool, char.bags)
            AddCounts(pool, char.bank)
        end
        AddCounts(pool, inventories.accountBank)
    end
    return pool
end

-- Who has an item: list of { who = "Name-Realm" or nil, where = "bags"/"bank"/"accountBank", count },
-- biggest stacks first.
function Calculator.FindHolders(inventories, itemID)
    local holders = {}
    for key, char in pairs(inventories.chars) do
        local bags = char.bags and char.bags[itemID] or 0
        local bank = char.bank and char.bank[itemID] or 0
        if bags > 0 then table.insert(holders, { who = key, where = "bags", count = bags }) end
        if bank > 0 then table.insert(holders, { who = key, where = "bank", count = bank }) end
    end
    local account = inventories.accountBank and inventories.accountBank[itemID] or 0
    if account > 0 then
        table.insert(holders, { where = "accountBank", count = account })
    end
    table.sort(holders, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return (a.who or "") < (b.who or "")
    end)
    return holders
end

-- How many of an item the current character has (bags + bank).
function Calculator.CountOnCurrent(inventories, itemID)
    local char = inventories.chars[inventories.current]
    if not char then return 0 end
    return (char.bags and char.bags[itemID] or 0) + (char.bank and char.bank[itemID] or 0)
end

---------------------------------------------------------------------------
-- The plan
---------------------------------------------------------------------------

-- Builds a full plan. options:
--   scope      "account" (default) or "character": what stock may be used
--   currentMax the character's current skill cap (to know which trainers are needed)
--   points     skill points per craft by colour (default DEFAULT_POINTS)
--
-- Result:
--   steps     remaining route steps (see GetRemainingSteps)
--   items     [itemID] = { itemID, name, source, required, fromMade, fromStock,
--                          toCraft, missing, cost, holders, onCurrent, recipe,
--                          recipeProfession }
--             fromMade = made earlier in this plan, fromStock = already owned
--   shopping  items with missing > 0 (raw materials to get), sorted by name
--   crafting  items with toCraft > 0 (intermediates to make), sorted by name
--   stock     items with fromStock > 0, sorted by name
--   trainers  trainer ranks you must learn on the way
--   recipes   route recipes in order: { recipeID, recipe }
--   tools     { item, name, have }
--   cost      estimated vendor cost in copper
--   missingRoute  true if a part of the range has no route data yet
function Calculator.Plan(data, prof, current, target, inventories, options)
    options = options or {}
    local result = {
        profession = prof, from = current, to = target,
        items = {}, shopping = {}, crafting = {}, stock = {},
        trainers = {}, recipes = {}, tools = {}, cost = 0,
    }

    result.steps = Calculator.GetRemainingSteps(prof, current, target, options.points)
    local items = result.items

    -- Two separate pools:
    --   stock = what the player owns (counts as "fromStock")
    --   made  = what this plan makes along the way: products of earlier route
    --           steps and leftovers from recipes that make more than one.
    local stock = Calculator.BuildPool(inventories, options.scope or "account")
    local made = {}

    local function GetItem(itemID)
        if not items[itemID] then
            items[itemID] = { itemID = itemID, required = 0, fromMade = 0, fromStock = 0, toCraft = 0, missing = 0 }
        end
        return items[itemID]
    end

    -- Takes up to `amount` from a pool and returns how many it got.
    local function Take(pool, itemID, amount)
        local got = math.min(pool[itemID] or 0, amount)
        if got > 0 then
            pool[itemID] = pool[itemID] - got
        end
        return got
    end

    -- Takes `amount` of an item: first from what the plan already made, then
    -- from stock, then by crafting it from its reagents (recursively).
    -- Whatever is left counts as missing.
    local function Need(itemID, amount, depth)
        if depth > MAX_DEPTH then
            error("recipe loop while breaking down item " .. itemID)
        end
        local item = GetItem(itemID)
        item.required = item.required + amount

        local fromMade = Take(made, itemID, amount)
        item.fromMade = item.fromMade + fromMade
        amount = amount - fromMade

        local fromStock = Take(stock, itemID, amount)
        item.fromStock = item.fromStock + fromStock
        amount = amount - fromStock

        if amount == 0 then
            return
        end

        local recipe, recipeProf = Calculator.GetSourceRecipe(data, itemID)
        if recipe then
            local crafts = Ceil(amount / recipe.count)
            item.toCraft = item.toCraft + amount
            item.recipe = recipe
            item.recipeProfession = recipeProf
            -- Recipes that make more than one (Smelt Bronze makes 2):
            -- keep the extra for later.
            made[itemID] = (made[itemID] or 0) + crafts * recipe.count - amount
            for _, reagent in ipairs(recipe.reagents) do
                Need(reagent[1], reagent[2] * crafts, depth + 1)
            end
        else
            item.missing = item.missing + amount
        end
    end

    -- Walk the route in order. What a step makes is kept, so later steps
    -- can use it (e.g. grinding stones made at 25-50).
    local seenRecipe = {}
    for _, entry in ipairs(result.steps) do
        if entry.step.missing then
            result.missingRoute = true
        end
        local recipe = entry.recipe
        if recipe and entry.crafts > 0 then
            for _, reagent in ipairs(recipe.reagents) do
                Need(reagent[1], reagent[2] * entry.crafts, 1)
            end
            made[recipe.item] = (made[recipe.item] or 0) + entry.crafts * recipe.count
            if not seenRecipe[entry.recipeID] then
                seenRecipe[entry.recipeID] = true
                table.insert(result.recipes, { recipeID = entry.recipeID, recipe = recipe })
            end
        end
    end

    -- Fill in names, sources, holders and cost, and sort into lists.
    for itemID, item in pairs(items) do
        item.name = Calculator.GetItemName(data, itemID)
        item.source = data.Sources[itemID]
        item.holders = Calculator.FindHolders(inventories, itemID)
        item.onCurrent = Calculator.CountOnCurrent(inventories, itemID)
        if item.missing > 0 and item.source and item.source.type == "vendor" and item.source.price then
            item.cost = item.missing * item.source.price
            result.cost = result.cost + item.cost
        end
        if item.missing > 0 then table.insert(result.shopping, item) end
        if item.toCraft > 0 then table.insert(result.crafting, item) end
        if item.fromStock > 0 then table.insert(result.stock, item) end
    end
    local function ByName(a, b) return a.name < b.name end
    table.sort(result.shopping, ByName)
    table.sort(result.crafting, ByName)
    table.sort(result.stock, ByName)

    -- Trainer ranks: needed if the rank raises our cap and the previous
    -- cap is below the target.
    local currentMax = options.currentMax or 0
    local previousMax = 0
    for _, trainer in ipairs(prof.trainers) do
        if trainer.maxSkill > currentMax and previousMax < target then
            table.insert(result.trainers, trainer)
        end
        previousMax = trainer.maxSkill
    end

    -- Tools must be on the current character.
    for _, tool in ipairs(prof.tools or {}) do
        table.insert(result.tools, {
            item = tool.item,
            name = tool.name,
            have = Calculator.CountOnCurrent(inventories, tool.item) > 0,
        })
    end

    return result
end
