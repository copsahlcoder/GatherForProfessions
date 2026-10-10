-- Glue between the saved data (ProfessionPlannerDB) and the pure Calculator.
-- Used by both /gfp plan and the main window.
local addonName, ns = ...

local Planner = {}
ns.Planner = Planner

-- Returns the skill and skill cap a saved character has in a profession (0, 0 if not learned).
function Planner.GetSkill(char, profID)
    local state = char.professions and char.professions[profID]
    if not state then
        return 0, 0
    end
    return state.rank, state.maxRank
end

-- The name to show for a saved character: just "Name", or "Name-Realm" if
-- another saved character has the same name on a different realm.
function Planner.DisplayName(charKey)
    local char = ns.db.chars[charKey]
    local name = (char and char.name) or string.match(charKey or "", "^([^-]+)") or charKey
    for otherKey, other in pairs(ns.db.chars) do
        if otherKey ~= charKey and other.name == name then
            return charKey
        end
    end
    return name
end

-- The character's main profession that we have data for. Crafting
-- professions come first (Blacksmithing before Mining), then gathering
-- professions, then secondary ones; the highest skill wins within each group.
-- Returns a profession ID, or nil if the character has none with data.
function Planner.MainProfession(charKey)
    local char = ns.db.chars[charKey]
    local bestID, bestScore
    for id, state in pairs(char and char.professions or {}) do
        local prof = ns.Data.Professions[id]
        if prof then
            local group = 0
            if state.primary then
                group = prof.gathering and 1000 or 2000
            end
            local score = group + state.rank
            if not bestScore or score > bestScore then
                bestID, bestScore = id, score
            end
        end
    end
    return bestID
end

-- Builds a plan for any saved character.
--   charKey  "Name-Realm"
--   prof     profession data table
--   target   a skill number, or nil for "next milestone"
--   scope    "account" (all characters + account bank) or "character"
-- Returns a table { plan, char, key, current, target }, or nil plus a reason:
--   "nochar" (unknown character), "maxed" (nothing above current skill),
--   "done" (already at or above target).
function Planner.Build(charKey, prof, target, scope)
    local char = ns.db.chars[charKey]
    if not char then
        return nil, "nochar"
    end

    local current, currentMax = Planner.GetSkill(char, prof.id)
    target = target or ns.Calculator.NextMilestone(prof, current)
    if not target then
        return nil, "maxed", current
    end
    if current >= target then
        return nil, "done", current, target
    end

    local inventories = {
        current = charKey,
        chars = ns.db.chars,
        accountBank = ns.db.accountBank and ns.db.accountBank.items,
    }
    local plan = ns.Calculator.Plan(ns.Data, prof, current, target, inventories,
        { currentMax = currentMax, scope = scope })

    return { plan = plan, char = char, key = charKey, current = current, target = target }
end
