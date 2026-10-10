-- Turns a Calculator plan into lines of text. The same lines are printed to
-- chat by /gfp plan and shown in the main window.
local addonName, ns = ...
local L = ns.L

local PlanText = {}
ns.PlanText = PlanText

-- How many zones to show per material, to keep lines short.
local MAX_ZONES = 3

-- Colours used in the window and chat.
local GREY = "|cff808080"
local YELLOW = "|cffffd100"
local GREEN = "|cff40ff40"
local END = "|r"

---------------------------------------------------------------------------
-- Small text helpers
---------------------------------------------------------------------------

-- "Name-Realm" -> "Name". The character we plan for becomes "you".
function PlanText.ShortName(key, currentKey)
    if key == currentKey then
        return L.WHO_YOU
    end
    return ns.Planner.DisplayName(key)
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

-- " (or Silver Rod x5)" for a route step with alternatives.
local function AlternativesText(prof, step)
    local text = ""
    for _, alt in ipairs(step.alternatives or {}) do
        local recipe = prof.recipes[alt.recipe]
        if recipe then
            text = text .. string.format(L.PLAN_STEP_ALT, recipe.name, alt.crafts)
        end
    end
    return text
end

-- " [drop]" for recipes that don't come from a trainer.
local function LearnText(recipe)
    if recipe.learn and recipe.learn ~= "trainer" then
        return string.format(L.PLAN_STEP_LEARN, recipe.learn)
    end
    return ""
end

---------------------------------------------------------------------------
-- Line builders. Each returns a list of strings (possibly empty).
---------------------------------------------------------------------------

function PlanText.HeaderLines(plan)
    local prof = plan.profession
    local lines = { string.format(L.PLAN_HEADER, prof.name, plan.from, plan.to) }
    if prof.beta and prof.source then
        table.insert(lines, string.format(L.PLAN_BETA, prof.source))
    end
    return lines
end

function PlanText.TrainerLines(plan, faction)
    local lines = {}
    if #plan.trainers == 0 then return lines end
    table.insert(lines, L.PLAN_TRAINERS)
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
        table.insert(lines, string.format(L.PLAN_TRAINER, trainer.rank, detailText, table.concat(where or {}, ", ")))
    end
    return lines
end

function PlanText.ToolLines(plan)
    local lines = {}
    for _, tool in ipairs(plan.tools) do
        if not tool.have then
            table.insert(lines, string.format(L.PLAN_TOOL_MISSING, tool.name))
        end
    end
    return lines
end

-- The remaining route steps (used by /gfp plan).
function PlanText.StepLines(plan)
    local prof = plan.profession
    local lines = { L.PLAN_STEPS }
    for _, entry in ipairs(plan.steps) do
        local step = entry.step
        if step.missing then
            table.insert(lines, string.format(L.PLAN_STEP_MISSING, entry.from, entry.to, step.note or ""))
        elseif step.gather then
            local names = {}
            for _, itemID in ipairs(step.gather) do
                table.insert(names, ns.Calculator.GetItemName(ns.Data, itemID))
            end
            table.insert(lines, string.format(L.PLAN_STEP_GATHER, entry.from, entry.to, table.concat(names, ", "), step.note or ""))
        elseif entry.recipe then
            local extra = LearnText(entry.recipe) .. AlternativesText(prof, step)
            table.insert(lines, string.format(L.PLAN_STEP_CRAFT, entry.from, entry.to, entry.recipe.name, entry.crafts, extra))
        end
    end
    return lines
end

-- The whole route up to the target, with done / current / upcoming
-- marked by colour (used by the Plan tab).
function PlanText.ProgressLines(prof, current, target)
    local lines = { L.PLAN_STEPS }
    for _, step in ipairs(prof.route) do
        if step.from >= target then break end
        local recipe = step.recipe and prof.recipes[step.recipe]
        local what
        if step.missing then
            what = L.UI_STEP_MISSING
        elseif step.gather then
            what = step.note or ""
        elseif recipe then
            what = string.format(L.UI_STEP_RECIPE, recipe.name, step.crafts or 0) .. LearnText(recipe) .. AlternativesText(prof, step)
        else
            what = ""
        end

        local range = string.format(L.UI_STEP_RANGE, step.from, step.to)
        if step.to <= current then
            table.insert(lines, GREY .. L.UI_STEP_INDENT .. range .. what .. END)
        elseif step.from <= current then
            local left = ""
            if recipe and step.crafts then
                local crafts = ns.Calculator.CraftsForStep(step, current, math.min(step.to, target))
                left = string.format(L.UI_STEP_LEFT, crafts)
            end
            table.insert(lines, YELLOW .. L.UI_STEP_NOW .. range .. what .. left .. END)
        else
            table.insert(lines, L.UI_STEP_INDENT .. range .. what)
        end
        -- Notes for steps still ahead (gather steps already show the note).
        if step.note and not step.gather and step.to > current then
            table.insert(lines, GREY .. "      " .. step.note .. END)
        end
    end
    return lines
end

-- Intermediate items to make, with a warning if the skill is too low.
function PlanText.CraftingLines(plan, char)
    local lines = {}
    if #plan.crafting == 0 then return lines end
    table.insert(lines, L.PLAN_CRAFTING)
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
        table.insert(lines, string.format(L.PLAN_CRAFT_LINE, item.toCraft, item.name, recipe.name, requirement, warning))
    end
    return lines
end

function PlanText.StockLines(plan, currentKey)
    local lines = {}
    if #plan.stock == 0 then return lines end
    table.insert(lines, L.PLAN_STOCK)
    for _, item in ipairs(plan.stock) do
        table.insert(lines, string.format(L.PLAN_STOCK_LINE, item.fromStock, item.name, PlanText.Holders(item.holders, currentKey)))
    end
    return lines
end

function PlanText.ShoppingLines(plan)
    local lines = { L.PLAN_SHOPPING }
    if #plan.shopping == 0 then
        table.insert(lines, GREEN .. L.PLAN_SHOPPING_NONE .. END)
    end
    for _, item in ipairs(plan.shopping) do
        table.insert(lines, string.format(L.PLAN_SHOPPING_LINE, item.missing, item.name, PlanText.Source(item.source)))
    end
    if plan.cost > 0 then
        table.insert(lines, string.format(L.PLAN_COST, ns.Calculator.FormatMoney(plan.cost)))
    end
    if plan.missingRoute then
        table.insert(lines, L.PLAN_MISSING_ROUTE)
    end
    return lines
end

---------------------------------------------------------------------------
-- Combining
---------------------------------------------------------------------------

-- Appends all lists to `target`. Returns target.
function PlanText.Append(target, ...)
    for i = 1, select("#", ...) do
        for _, line in ipairs((select(i, ...))) do
            table.insert(target, line)
        end
    end
    return target
end

-- Prints a whole plan to chat (/gfp plan).
function PlanText.PrintPlan(plan, char, currentKey)
    local lines = PlanText.Append({},
        PlanText.HeaderLines(plan),
        PlanText.TrainerLines(plan, char.faction),
        PlanText.ToolLines(plan),
        PlanText.StepLines(plan),
        PlanText.CraftingLines(plan, char),
        PlanText.StockLines(plan, currentKey),
        PlanText.ShoppingLines(plan))
    for _, line in ipairs(lines) do
        ns:Print(line)
    end
end
