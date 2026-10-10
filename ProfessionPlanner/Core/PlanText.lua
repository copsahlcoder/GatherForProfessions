-- Turns a Calculator plan into readable text: used by /gfp plan now,
-- and by the main window later (step d).
local addonName, ns = ...
local L = ns.L

local PlanText = {}
ns.PlanText = PlanText

-- How many zones to show per material, to keep chat lines short.
local MAX_ZONES = 3

---------------------------------------------------------------------------
-- Small text helpers
---------------------------------------------------------------------------

-- "Name-Realm" -> "Name". Our own character becomes "you".
function PlanText.ShortName(key, currentKey)
    if key == currentKey then
        return L.WHO_YOU
    end
    return string.match(key or "", "^([^-]+)") or key
end

-- "Bankalt bank 40, you bags 5"
function PlanText.Holders(holders, currentKey)
    local parts = {}
    for _, holder in ipairs(holders) do
        if holder.where == "accountBank" then
            table.insert(parts, string.format(L.HOLDER_ACCOUNT, holder.count))
        else
            table.insert(parts, string.format(L.HOLDER, PlanText.ShortName(holder.who, currentKey), holder.where, holder.count))
        end
    end
    return table.concat(parts, ", ")
end

-- "Durotar (1-10), Mulgore (1-10), Tirisfal Glades (1-10)"
function PlanText.Zones(zones)
    local parts = {}
    for i, zone in ipairs(zones or {}) do
        if i > MAX_ZONES then break end
        table.insert(parts, string.format(L.ZONE, zone.zone, zone.min, zone.max))
    end
    return table.concat(parts, ", ")
end

-- Where a raw material comes from, as one line of text.
function PlanText.Source(source)
    if not source then
        return L.SOURCE_UNKNOWN
    elseif source.type == "node" then
        return string.format(L.SOURCE_NODE, source.node, source.skill, PlanText.Zones(source.zones))
    elseif source.type == "mobdrop" then
        return string.format(L.SOURCE_MOBDROP, source.mobs, PlanText.Zones(source.zones))
    elseif source.type == "vendor" then
        return string.format(L.SOURCE_VENDOR, ns.Calculator.FormatMoney(source.price), source.vendor)
    end
    return source.note or L.SOURCE_UNKNOWN
end

---------------------------------------------------------------------------
-- Printing a plan to chat
---------------------------------------------------------------------------

local function PrintTrainers(plan, faction)
    if #plan.trainers == 0 then return end
    ns:Print(L.PLAN_TRAINERS)
    for _, trainer in ipairs(plan.trainers) do
        -- Build "(skill 125, level 20, 50s)" from whatever is known.
        local details = {}
        if trainer.minSkill and trainer.minSkill > 0 then
            table.insert(details, string.format(L.PLAN_TRAINER_SKILL, trainer.minSkill))
        end
        if trainer.minLevel then
            table.insert(details, string.format(L.PLAN_TRAINER_LEVEL, trainer.minLevel))
        end
        if trainer.cost then
            table.insert(details, ns.Calculator.FormatMoney(trainer.cost))
        end
        local detailText = #details > 0 and (" (" .. table.concat(details, ", ") .. ")") or ""
        local where = (faction == "Alliance") and trainer.alliance or trainer.horde
        ns:Print(L.PLAN_TRAINER, trainer.rank, detailText, table.concat(where or {}, ", "))
    end
end

local function PrintSteps(plan)
    local prof = plan.profession
    ns:Print(L.PLAN_STEPS)
    for _, entry in ipairs(plan.steps) do
        local step = entry.step
        if step.missing then
            ns:Print(L.PLAN_STEP_MISSING, entry.from, entry.to, step.note or "")
        elseif step.gather then
            local names = {}
            for _, itemID in ipairs(step.gather) do
                table.insert(names, ns.Calculator.GetItemName(ns.Data, itemID))
            end
            ns:Print(L.PLAN_STEP_GATHER, entry.from, entry.to, table.concat(names, ", "), step.note or "")
        elseif entry.recipe then
            local extra = ""
            if entry.recipe.learn and entry.recipe.learn ~= "trainer" then
                extra = string.format(L.PLAN_STEP_LEARN, entry.recipe.learn)
            end
            for _, alt in ipairs(step.alternatives or {}) do
                local altRecipe = prof.recipes[alt.recipe]
                if altRecipe then
                    extra = extra .. string.format(L.PLAN_STEP_ALT, altRecipe.name, alt.crafts)
                end
            end
            ns:Print(L.PLAN_STEP_CRAFT, entry.from, entry.to, entry.recipe.name, entry.crafts, extra)
        end
    end
end

-- Intermediate items to make, with a warning if the character's skill is too low.
local function PrintCrafting(plan, char)
    if #plan.crafting == 0 then return end
    ns:Print(L.PLAN_CRAFTING)
    for _, item in ipairs(plan.crafting) do
        local recipe, prof = item.recipe, item.recipeProfession
        local known = char.professions and char.professions[prof.id]
        -- minSkill is only known for some recipes (e.g. smelting).
        local requirement = prof.name
        if recipe.minSkill then
            requirement = string.format(L.PLAN_CRAFT_SKILL, prof.name, recipe.minSkill)
        end
        local warning = ""
        if not known or known.rank < (recipe.minSkill or 1) then
            warning = string.format(L.PLAN_CRAFT_SKILL_LOW, prof.name, known and known.rank or 0)
        end
        ns:Print(L.PLAN_CRAFT_LINE, item.toCraft, item.name, recipe.name, requirement, warning)
    end
end

function PlanText.PrintPlan(plan, char, currentKey)
    local prof = plan.profession
    ns:Print(L.PLAN_HEADER, prof.name, plan.from, plan.to)
    if prof.beta and prof.source then
        ns:Print(L.PLAN_BETA, prof.source)
    end

    PrintTrainers(plan, char.faction)
    for _, tool in ipairs(plan.tools) do
        if not tool.have then
            ns:Print(L.PLAN_TOOL_MISSING, tool.name)
        end
    end

    PrintSteps(plan)
    PrintCrafting(plan, char)

    if #plan.stock > 0 then
        ns:Print(L.PLAN_STOCK)
        for _, item in ipairs(plan.stock) do
            ns:Print(L.PLAN_STOCK_LINE, item.fromStock, item.name, PlanText.Holders(item.holders, currentKey))
        end
    end

    ns:Print(L.PLAN_SHOPPING)
    if #plan.shopping == 0 then
        ns:Print(L.PLAN_SHOPPING_NONE)
    end
    for _, item in ipairs(plan.shopping) do
        ns:Print(L.PLAN_SHOPPING_LINE, item.missing, item.name, PlanText.Source(item.source))
    end

    if plan.cost > 0 then
        ns:Print(L.PLAN_COST, ns.Calculator.FormatMoney(plan.cost))
    end
    if plan.missingRoute then
        ns:Print(L.PLAN_MISSING_ROUTE)
    end
end
