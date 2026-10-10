-- Reads character info, professions, bags and bank, and stores them in
-- ProfessionPlannerDB.chars["Name-Realm"].
local addonName, ns = ...
local L = ns.L
local Compat = ns.Compat

local Scanner = {}
ns.Scanner = Scanner

-- Seconds to wait before scanning after a burst of events.
local DEBOUNCE = 0.5

-- Professions we recognise, keyed by their name in the enUS client.
-- id is the skill line ID, which is what the rest of the addon uses.
Scanner.PROFESSIONS = {
    ["Alchemy"]        = { id = 171, primary = true },
    ["Blacksmithing"]  = { id = 164, primary = true },
    ["Enchanting"]     = { id = 333, primary = true },
    ["Engineering"]    = { id = 202, primary = true },
    ["Herbalism"]      = { id = 182, primary = true },
    ["Leatherworking"] = { id = 165, primary = true },
    ["Mining"]         = { id = 186, primary = true },
    ["Skinning"]       = { id = 393, primary = true },
    ["Tailoring"]      = { id = 197, primary = true },
    ["Cooking"]        = { id = 185, primary = false },
    ["First Aid"]      = { id = 129, primary = false },
    ["Fishing"]        = { id = 356, primary = false },
}

---------------------------------------------------------------------------
-- Character record
---------------------------------------------------------------------------

function Scanner.GetCharKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

-- Returns the saved table for the current character, creating it if needed.
function Scanner.GetCurrentChar()
    local key = Scanner.GetCharKey()
    local chars = ns.db.chars
    if not chars[key] then
        chars[key] = { professions = {}, bags = {}, bank = {} }
    end
    return chars[key], key
end

function Scanner.ScanCharacter()
    local char = Scanner.GetCurrentChar()
    char.name = UnitName("player")
    char.realm = GetRealmName()
    char.race, char.raceFile = UnitRace("player")     -- "Night Elf", "NightElf"
    char.class, char.classFile = UnitClass("player")  -- "Warrior", "WARRIOR"
    char.level = UnitLevel("player")
    char.faction = UnitFactionGroup("player")         -- "Alliance" / "Horde"
    char.lastUpdate = time()
end

---------------------------------------------------------------------------
-- Professions
---------------------------------------------------------------------------

function Scanner.ScanProfessions()
    local char = Scanner.GetCurrentChar()
    local list, anyCollapsed = Compat.GetProfessionList()

    if not list then
        if not Scanner.warnedNoAPI then
            Scanner.warnedNoAPI = true
            ns:PrintError(L.NO_PROFESSION_API)
        end
        return
    end

    local found = {}
    for _, entry in ipairs(list) do
        local known = Scanner.PROFESSIONS[entry.name]
        -- Prefer the ID the game gives us; fall back to our name table.
        local id = entry.id or (known and known.id)
        if id then
            found[id] = {
                name = entry.name,
                rank = entry.rank,
                maxRank = entry.maxRank,
                primary = not known or known.primary,
            }
        end
    end

    if anyCollapsed then
        -- We can't see inside collapsed headers, so keep what we knew before
        -- instead of deleting professions we simply can't see right now.
        for id, old in pairs(char.professions or {}) do
            if not found[id] then
                found[id] = old
            end
        end
        if not Scanner.warnedCollapsed then
            Scanner.warnedCollapsed = true
            ns:Print(L.SKILL_HEADER_COLLAPSED)
        end
    end

    char.professions = found
    ns:FireCallback("DATA_CHANGED")
end

---------------------------------------------------------------------------
-- Bags and bank
---------------------------------------------------------------------------

-- Counts all items in the given containers: returns { [itemID] = count }.
-- Also returns the total number of slots, so callers can tell
-- "empty containers" (slots > 0) from "not readable right now" (slots == 0).
local function CountItems(bagIDs)
    local counts = {}
    local totalSlots = 0
    for _, bag in ipairs(bagIDs) do
        local numSlots = Compat.GetContainerNumSlots(bag)
        totalSlots = totalSlots + numSlots
        for slot = 1, numSlots do
            local itemID, count = Compat.GetContainerItem(bag, slot)
            if itemID then
                counts[itemID] = (counts[itemID] or 0) + count
            end
        end
    end
    return counts, totalSlots
end

function Scanner.ScanBags()
    local char = Scanner.GetCurrentChar()
    char.bags = CountItems(Compat.GetBagIDs())
    char.bagsTime = time()
    ns:FireCallback("DATA_CHANGED")
end

-- The bank can only be read while it is open. If it's closed (or reports
-- no slots yet) we keep the last saved contents instead of overwriting them.
function Scanner.ScanBank()
    if not Scanner.bankOpen then return end

    local char = Scanner.GetCurrentChar()
    local counts, slots = CountItems(Compat.GetBankBagIDs())
    if slots > 0 then
        char.bank = counts
        char.bankTime = time()
    end

    -- The account (Warband) bank is shared, so it is saved once for the account.
    local accountCounts, accountSlots = CountItems(Compat.GetAccountBankBagIDs())
    if accountSlots > 0 then
        ns.db.accountBank = { items = accountCounts, time = time() }
    end
    ns:FireCallback("DATA_CHANGED")
end

function Scanner.ScanAll()
    Scanner.ScanCharacter()
    Scanner.ScanProfessions()
    Scanner.ScanBags()
    Scanner.ScanBank()
end

-- Returns number of different items and total item count in a count table.
function Scanner.CountSummary(counts)
    local different, total = 0, 0
    for _, count in pairs(counts or {}) do
        different = different + 1
        total = total + count
    end
    return different, total
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

ns:RegisterEvent("PLAYER_LOGIN", function()
    Scanner.ScanCharacter()
    Scanner.ScanProfessions()
    Scanner.ScanBags()
end)

ns:RegisterEvent("SKILL_LINES_CHANGED", function()
    if not ns.loggedIn then return end
    ns:Debounce("ScanProfessions", DEBOUNCE, Scanner.ScanProfessions)
end)

ns:RegisterEvent("PLAYER_LEVEL_UP", function(event, newLevel)
    -- UnitLevel can still return the old level during this event,
    -- so use the level the event gives us.
    local char = Scanner.GetCurrentChar()
    char.level = newLevel or UnitLevel("player")
    ns:FireCallback("DATA_CHANGED")
end)

ns:RegisterEvent("BAG_UPDATE", function()
    -- BAG_UPDATE fires many times during loading; wait until we're logged in.
    if not ns.loggedIn then return end
    ns:Debounce("ScanBags", DEBOUNCE, Scanner.ScanBags)
    -- Bank bags also fire BAG_UPDATE while the bank is open.
    if Scanner.bankOpen then
        ns:Debounce("ScanBank", DEBOUNCE, Scanner.ScanBank)
    end
end)

ns:RegisterEvent("BANKFRAME_OPENED", function()
    Scanner.bankOpen = true
    Scanner.ScanBank()
end)

ns:RegisterEvent("PLAYERBANKSLOTS_CHANGED", function()
    ns:Debounce("ScanBank", DEBOUNCE, Scanner.ScanBank)
end)

ns:RegisterEvent("BANKFRAME_CLOSED", function()
    Scanner.bankOpen = false
end)
