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

-- True if the plan may use what this holder has (scope "character" only
-- counts the character we plan for).
local function IsCounted(holder, scope, currentKey)
    return scope ~= "character" or holder.who == currentKey
end

-- "you: bags 8, bank 2; Bankalt: bank 40; Warband bank 10"
-- You first, then the others by biggest stack, then the Warband bank.
-- Holders the plan doesn't count (scope "character") are marked.
function PlanText.Holders(holders, currentKey, scope)
    local byChar, order, account = {}, {}, nil
    for _, holder in ipairs(holders) do
        if holder.where == "accountBank" then
            account = holder
        else
            if not byChar[holder.who] then
                byChar[holder.who] = {}
                table.insert(order, holder.who)
            end
            byChar[holder.who][holder.where] = holder.count
        end
    end
    for i, key in ipairs(order) do
        if key == currentKey then
            table.remove(order, i)
            table.insert(order, 1, key)
            break
        end
    end

    local parts = {}
    for _, key in ipairs(order) do
        local where = {}
        if byChar[key].bags then table.insert(where, string.format(L.HOLDER_BAGS, byChar[key].bags)) end
        if byChar[key].bank then table.insert(where, string.format(L.HOLDER_BANK, byChar[key].bank)) end
        local text = string.format(L.HOLDER_CHAR, PlanText.ShortName(key, currentKey), table.concat(where, ", "))
        if not IsCounted({ who = key }, scope, currentKey) then
            text = text .. L.HOLDER_NOT_COUNTED
        end
        table.insert(parts, text)
    end
    if account then
        local text = string.format(L.HOLDER_ACCOUNT, account.count)
        if scope == "character" then
            text = text .. L.HOLDER_NOT_COUNTED
        end
        table.insert(parts, text)
    end
    return table.concat(parts, L.HOLDER_SEPARATOR)
end

-- How many of an item the plan may use (what the counted holders have).
local function CountedOwned(holders, currentKey, scope)
    local total = 0
    for _, holder in ipairs(holders) do
        if holder.where == "accountBank" then
            if scope ~= "character" then total = total + holder.count end
        elseif IsCounted(holder, scope, currentKey) then
            total = total + holder.count
        end
    end
    return total
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
    if prof.source then
        table.insert(lines, string.format(L.PLAN_GUIDE, prof.source))
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

-- "make 54 (Smelt Copper)", with a warning if the character's skill is too low.
local function MakeText(item, char)
    local recipe, prof = item.recipe, item.recipeProfession
    local text = string.format(L.MAT_MAKE, item.toCraft, recipe.name)
    local known = char and char.professions and char.professions[prof.id]
    local rank = known and known.rank or 0
    -- minSkill is only known for some recipes (e.g. smelting).
    local needed = recipe.minSkill or 1
    if rank < needed then
        text = text .. string.format(L.MAT_MAKE_SKILL_LOW, prof.name, needed, rank)
    end
    return text
end

-- "64 Copper Ore" or "32 Copper Bar, 32 Tin Bar": what making an item takes.
-- Recipes that make more than one (Smelt Bronze makes 2) need fewer crafts.
local function ReagentsText(item)
    local crafts = math.ceil(item.toCraft / item.recipe.count)
    local parts = {}
    for _, reagent in ipairs(item.recipe.reagents) do
        local name = ns.Calculator.GetItemName(ns.Data, reagent[1])
        table.insert(parts, string.format(L.MAT_FROM_PART, reagent[2] * crafts, name))
    end
    return table.concat(parts, ", ")
end

-- Sort order: missing first, then things to make, then ready; then by name.
local function Rank(item)
    if item.missing > 0 then return 1 end
    if item.toCraft > 0 then return 2 end
    return 3
end

-- Every material the plan uses (not counting what earlier steps make), as:
--   Coarse Stone: have 20, need 72 - missing 52
--         Where: you: bags 12, bank 8; Bankalt: bank 40
--         Get: mine Tin Vein (Mining 65): Hillsbrad Foothills (20-30), ...
function PlanText.MaterialLines(plan, char, currentKey, header)
    local lines = { header }
    local rows = {}
    for _, item in pairs(plan.items) do
        if item.required - item.fromMade > 0 then
            table.insert(rows, item)
        end
    end
    table.sort(rows, function(a, b)
        if Rank(a) ~= Rank(b) then return Rank(a) < Rank(b) end
        return a.name < b.name
    end)
    if #rows == 0 then
        table.insert(lines, L.MAT_NONE)
        return lines
    end

    for _, item in ipairs(rows) do
        local status
        if item.missing > 0 then
            status = string.format(L.MAT_MISSING, item.missing)
        elseif item.toCraft > 0 then
            status = MakeText(item, char)
        else
            status = L.MAT_READY
        end
        local have = CountedOwned(item.holders, currentKey, plan.scope)
        table.insert(lines, string.format(L.MAT_LINE, item.name, have, item.required - item.fromMade, status))
        if #item.holders > 0 then
            table.insert(lines, string.format(L.MAT_WHERE, PlanText.Holders(item.holders, currentKey, plan.scope)))
        end
        if item.toCraft > 0 then
            table.insert(lines, string.format(L.MAT_FROM, ReagentsText(item)))
        end
        if item.missing > 0 then
            table.insert(lines, string.format(L.MAT_GET, PlanText.Source(item.source)))
        end
    end
    return lines
end

-- Vendor cost and a warning when part of the route has no data.
function PlanText.FooterLines(plan)
    local lines = {}
    if plan.cost > 0 then
        table.insert(lines, string.format(L.PLAN_COST, ns.Calculator.FormatMoney(plan.cost)))
    end
    if plan.missingRoute then
        table.insert(lines, L.PLAN_MISSING_ROUTE)
    end
    return lines
end

-- Do you have everything for the target? If not, what is missing (details
-- are in the Shopping list tab).
function PlanText.SummaryLines(plan)
    -- Gathering professions level by gathering; there is nothing to buy.
    if plan.profession.gathering then
        return {}
    end
    if #plan.shopping == 0 then
        return { string.format(L.MAT_SUMMARY_OK, plan.to) }
    end
    local lines = { string.format(L.MAT_SUMMARY_MISSING, plan.to) }
    for _, item in ipairs(plan.shopping) do
        table.insert(lines, string.format(L.MAT_SUMMARY_LINE, item.missing, item.name))
    end
    table.insert(lines, L.MAT_SUMMARY_DETAILS)
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
        PlanText.MaterialLines(plan, char, currentKey, string.format(L.MAT_HEADER_TOTAL, plan.to)),
        PlanText.FooterLines(plan))
    for _, line in ipairs(lines) do
        ns:Print(line)
    end
end
