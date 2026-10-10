-- Core setup: chat output, error handling, events and the saved database.
local addonName, ns = ...
local L = ns.L

-- Bump this when the layout of ProfessionPlannerDB changes, and add a
-- matching function to the migrations table below.
ns.DB_VERSION = 1

-- Static data tables, filled by the files in Data/.
-- Professions[skillLineID] = profession data, Sources[itemID] = material source.
ns.Data = {
    Professions = {},
    Sources = {},
}

---------------------------------------------------------------------------
-- Chat output
---------------------------------------------------------------------------

-- Prints a message to chat. Extra arguments are passed to string.format.
function ns:Print(msg, ...)
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end
    DEFAULT_CHAT_FRAME:AddMessage(L.PREFIX .. " " .. tostring(msg))
end

function ns:PrintError(msg, ...)
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end
    DEFAULT_CHAT_FRAME:AddMessage(L.PREFIX .. " " .. L.ERROR_PREFIX .. " " .. tostring(msg))
end

-- Runs fn(...) and prints a readable chat error instead of failing silently.
-- `label` says where the error happened, e.g. "BAG_UPDATE" or "/gfp scan".
function ns:SafeCall(label, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        ns:PrintError(L.ERROR_IN, label, tostring(err))
    end
    return ok
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

-- One hidden frame receives all events and passes them to the registered
-- handler functions. Handlers are called as fn(event, ...).
local eventFrame = CreateFrame("Frame")
local handlers = {}

-- Events this client doesn't have; shown by /gfp scan to help debugging.
ns.unavailableEvents = {}

function ns:RegisterEvent(event, fn)
    if not handlers[event] then
        handlers[event] = {}
        if not ns.Compat.RegisterEvent(eventFrame, event) then
            table.insert(ns.unavailableEvents, event)
        end
    end
    table.insert(handlers[event], fn)
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    for _, fn in ipairs(handlers[event]) do
        ns:SafeCall(event, fn, event, ...)
    end
end)

-- Debounce: the first call schedules fn to run after `delay` seconds.
-- Further calls with the same key before then are ignored, so fn runs at
-- most once per `delay` seconds no matter how many events arrive.
local pending = {}

function ns:Debounce(key, delay, fn)
    if pending[key] then return end
    pending[key] = true
    ns.Compat.After(delay, function()
        pending[key] = nil
        ns:SafeCall(key, fn)
    end)
end

---------------------------------------------------------------------------
-- Internal callbacks (our own events between modules)
---------------------------------------------------------------------------

-- "DATA_CHANGED" is fired by the Scanner after every scan, so the window
-- can refresh itself.
local callbacks = {}

function ns:RegisterCallback(name, fn)
    callbacks[name] = callbacks[name] or {}
    table.insert(callbacks[name], fn)
end

function ns:FireCallback(name, ...)
    for _, fn in ipairs(callbacks[name] or {}) do
        ns:SafeCall(name, fn, ...)
    end
end

---------------------------------------------------------------------------
-- SavedVariables
---------------------------------------------------------------------------

-- migrations[n] upgrades the database from version n-1 to version n.
local migrations = {
    [1] = function(db)
        -- First version: nothing to convert.
    end,
}

local function Migrate(db)
    local from = db.version or 0
    local v = from
    while v < ns.DB_VERSION do
        v = v + 1
        if migrations[v] then
            migrations[v](db)
        end
        db.version = v
    end
    -- Only mention it when there was real old data to upgrade.
    if from > 0 and from < v then
        ns:Print(L.DB_MIGRATED, from, v)
    end
end

local function InitDB()
    if type(ProfessionPlannerDB) ~= "table" then
        ProfessionPlannerDB = {}
    end
    local db = ProfessionPlannerDB
    Migrate(db)

    db.chars = db.chars or {}        -- ["Name-Realm"] = character data
    db.settings = db.settings or {}
    if db.settings.tooltip == nil then
        db.settings.tooltip = true
    end
    db.ui = db.ui or {}              -- window position etc. (step d)

    ns.db = db
end

ns:RegisterEvent("ADDON_LOADED", function(event, loadedName)
    if loadedName == addonName then
        InitDB()
    end
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    ns.loggedIn = true
    ns:Print(L.LOADED)
end)
