-- API compatibility layer.
-- Every WoW API call that differs between client versions goes through here,
-- so the rest of the addon never has to care which client it runs on.
local addonName, ns = ...

local Compat = {}
ns.Compat = Compat

---------------------------------------------------------------------------
-- Container (bag/bank) IDs
---------------------------------------------------------------------------

-- WoW Forever runs on a modern client engine (confirmed with /dump):
-- NUM_BAG_SLOTS = 4, NUM_TOTAL_EQUIPPED_BAG_SLOTS = 5, NUM_BANKBAGSLOTS = nil.
local BagIndex = (type(Enum) == "table" and Enum.BagIndex) or {}

Compat.BACKPACK = BagIndex.Backpack or BACKPACK_CONTAINER or 0

-- Bag slots the player can equip (normally 4), plus the reagent bag if any.
local numBags = NUM_BAG_SLOTS or 4
local numEquippedBags = NUM_TOTAL_EQUIPPED_BAG_SLOTS or numBags

-- Returns a list of the bag IDs we carry (backpack + equipped bags + reagent bag).
function Compat.GetBagIDs()
    local ids = {}
    for bag = Compat.BACKPACK, Compat.BACKPACK + numEquippedBags do
        table.insert(ids, bag)
    end
    return ids
end

-- Collects Enum.BagIndex[prefix .. 1], [prefix .. 2], ... until one is missing.
local function GetTabIDs(prefix)
    local ids = {}
    local i = 1
    while BagIndex[prefix .. i] do
        table.insert(ids, BagIndex[prefix .. i])
        i = i + 1
    end
    return ids
end

-- Returns a list of the character's bank container IDs.
-- WoW Forever uses bank tabs: CharacterBankTab_1..9 = 6..14 (confirmed with /dump).
-- Note: in this client -1 is the Keyring, not the bank.
-- Older clients use the main bank (-1) plus bank bags after the equipped bags.
function Compat.GetBankBagIDs()
    if BagIndex.CharacterBankTab_1 then
        return GetTabIDs("CharacterBankTab_")
    end

    local ids = {}

    table.insert(ids, BagIndex.Bank or BANK_CONTAINER or -1)
    local firstBankBag = numEquippedBags + 1
    for bag = firstBankBag, firstBankBag + (NUM_BANKBAGSLOTS or 6) - 1 do
        table.insert(ids, bag)
    end
    return ids
end

-- Returns the account-wide (Warband) bank tab IDs: AccountBankTab_1..9 = 15..23.
-- Empty list on clients without an account bank.
function Compat.GetAccountBankBagIDs()
    return GetTabIDs("AccountBankTab_")
end

---------------------------------------------------------------------------
-- Container contents
---------------------------------------------------------------------------

-- Newer clients put the container functions in the C_Container table,
-- older ones have them as global functions.
local hasCContainer = type(C_Container) == "table"
    and type(C_Container.GetContainerNumSlots) == "function"

function Compat.GetContainerNumSlots(bag)
    if hasCContainer then
        return C_Container.GetContainerNumSlots(bag) or 0
    end
    return GetContainerNumSlots(bag) or 0
end

-- Pulls the itemID out of an item link like "|Hitem:2770:...|h".
local function ItemIDFromLink(link)
    if not link then return nil end
    return tonumber(string.match(link, "item:(%d+)"))
end

-- Returns itemID, count for one slot, or nil if the slot is empty.
function Compat.GetContainerItem(bag, slot)
    if hasCContainer then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if not info then return nil end
        return info.itemID or ItemIDFromLink(info.hyperlink), info.stackCount or 1
    end

    -- Old global version returns many values; we need count (2), link (7) and itemID (10).
    local _, count, _, _, _, _, link, _, _, itemID = GetContainerItemInfo(bag, slot)
    if not itemID and not link and GetContainerItemLink then
        link = GetContainerItemLink(bag, slot)
    end
    itemID = itemID or ItemIDFromLink(link)
    if not itemID then return nil end
    return itemID, count or 1
end

---------------------------------------------------------------------------
-- Professions
---------------------------------------------------------------------------

-- GetSkillLineInfo does NOT exist in WoW Forever (confirmed with /dump), so we
-- try the modern API first and keep the Classic API as a fallback.

-- Modern API: GetProfessions() returns up to 6 indexes (some may be nil):
-- prof1, prof2, archaeology, fishing, cooking, firstAid.
local function GetProfessionsModern()
    local list = {}
    local indexes = { GetProfessions() }
    for i = 1, 6 do
        local index = indexes[i]
        if index then
            local name, _, rank, maxRank, _, _, skillLineID = GetProfessionInfo(index)
            if name then
                table.insert(list, {
                    name = name,
                    id = skillLineID,
                    rank = rank or 0,
                    maxRank = maxRank or 0,
                })
            end
        end
    end
    return list, false
end

-- Classic API: walk the Skills tab. Lines inside a collapsed header are
-- hidden, so we also report whether any header was collapsed.
local function GetProfessionsClassic()
    local list = {}
    local anyCollapsed = false
    for i = 1, GetNumSkillLines() do
        local name, isHeader, isExpanded, rank, _, _, maxRank = GetSkillLineInfo(i)
        if isHeader then
            if not isExpanded then anyCollapsed = true end
        else
            table.insert(list, { name = name, rank = rank or 0, maxRank = maxRank or 0 })
        end
    end
    return list, anyCollapsed
end

-- Returns list, anyCollapsed. Each entry is { name, id (may be nil), rank, maxRank }.
-- Returns nil if this client has no profession API we know about.
function Compat.GetProfessionList()
    if GetProfessions and GetProfessionInfo then
        return GetProfessionsModern()
    end
    if GetNumSkillLines and GetSkillLineInfo then
        return GetProfessionsClassic()
    end
    return nil
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

-- Modern clients raise an error when registering an event that doesn't exist.
-- Returns true if the event was registered.
function Compat.RegisterEvent(frame, event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then
        return false
    end
    return (pcall(frame.RegisterEvent, frame, event))
end

---------------------------------------------------------------------------
-- Timers
---------------------------------------------------------------------------

-- Fallback timer, only used if C_Timer is missing. The OnUpdate script is
-- only active while at least one timer is waiting, so it costs nothing otherwise.
local timerFrame
local waiting = {}

local function OnTimerUpdate(self, elapsed)
    for i = #waiting, 1, -1 do
        local t = waiting[i]
        t.left = t.left - elapsed
        if t.left <= 0 then
            table.remove(waiting, i)
            t.fn()
        end
    end
    if #waiting == 0 then
        self:SetScript("OnUpdate", nil)
    end
end

-- Calls fn once after the given number of seconds.
function Compat.After(seconds, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, fn)
        return
    end
    timerFrame = timerFrame or CreateFrame("Frame")
    table.insert(waiting, { left = seconds, fn = fn })
    timerFrame:SetScript("OnUpdate", OnTimerUpdate)
end
