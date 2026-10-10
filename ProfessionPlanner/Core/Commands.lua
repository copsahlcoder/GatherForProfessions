-- Slash commands: /gfp
local addonName, ns = ...
local L = ns.L

local Commands = {}
ns.Commands = Commands

---------------------------------------------------------------------------
-- /gfp scan
---------------------------------------------------------------------------

local function FormatDate(timestamp)
    return date("%Y-%m-%d %H:%M", timestamp)
end

function Commands.PrintSummary()
    local Scanner = ns.Scanner
    local char = Scanner.GetCurrentChar()

    ns:Print(L.SCAN_CHAR, ns.Planner.DisplayName(Scanner.GetCharKey()), char.race or "?", char.class or "?",
        char.level or 0, char.faction or "?")

    -- Professions, sorted by name so the output is stable.
    ns:Print(L.SCAN_PROFS_HEADER)
    local profs = {}
    for _, prof in pairs(char.professions or {}) do
        table.insert(profs, prof)
    end
    table.sort(profs, function(a, b) return a.name < b.name end)
    if #profs == 0 then
        ns:Print(L.SCAN_NO_PROFS)
    end
    for _, prof in ipairs(profs) do
        local suffix = prof.primary and "" or L.SCAN_SECONDARY
        ns:Print(L.SCAN_PROF_LINE, prof.name, prof.rank, prof.maxRank, suffix)
    end

    ns:Print(L.SCAN_BAGS, Scanner.CountSummary(char.bags))

    if char.bankTime then
        local different, total = Scanner.CountSummary(char.bank)
        ns:Print(L.SCAN_BANK, different, total, FormatDate(char.bankTime))
    else
        ns:Print(L.SCAN_BANK_NEVER)
    end

    local accountBank = ns.db.accountBank
    if accountBank then
        local different, total = Scanner.CountSummary(accountBank.items)
        ns:Print(L.SCAN_ACCOUNT_BANK, different, total, FormatDate(accountBank.time))
    end

    local numChars = 0
    for _ in pairs(ns.db.chars) do numChars = numChars + 1 end
    ns:Print(L.SCAN_CHARS_SAVED, numChars)

    if #ns.unavailableEvents > 0 then
        ns:Print(L.SCAN_UNAVAILABLE_EVENTS, table.concat(ns.unavailableEvents, ", "))
    end
end

---------------------------------------------------------------------------
-- /gfp reset <name> | <name-realm>
---------------------------------------------------------------------------

local function SavedCharList()
    local keys = {}
    for key in pairs(ns.db.chars) do table.insert(keys, key) end
    table.sort(keys)
    return table.concat(keys, ", ")
end

function Commands.Reset(arg)
    if arg == "" then
        ns:Print(L.RESET_USAGE)
        return
    end

    -- Match either the full "Name-Realm" key or just the name, ignoring case.
    local wanted = string.lower(arg)
    local matches = {}
    for key, char in pairs(ns.db.chars) do
        if string.lower(key) == wanted or string.lower(char.name or "") == wanted then
            table.insert(matches, key)
        end
    end

    if #matches == 0 then
        ns:Print(L.RESET_NOT_FOUND, arg, SavedCharList())
    elseif #matches > 1 then
        ns:Print(L.RESET_AMBIGUOUS, arg, table.concat(matches, ", "))
    else
        ns.db.chars[matches[1]] = nil
        ns:Print(L.RESET_DONE, matches[1])
        -- If we just deleted ourselves, rebuild right away.
        if matches[1] == ns.Scanner.GetCharKey() then
            ns.Scanner.ScanAll()
        end
    end
end

---------------------------------------------------------------------------
-- /gfp plan <profession> [target]
---------------------------------------------------------------------------

local function KnownProfessionNames()
    local names = {}
    for _, prof in pairs(ns.Data.Professions) do
        table.insert(names, prof.name)
    end
    table.sort(names)
    return table.concat(names, ", ")
end

function Commands.Plan(arg)
    -- "blacksmithing 225" -> name = "blacksmithing", target = "225"
    local name, target = string.match(arg or "", "^(.-)%s*(%d*)$")
    if name == "" then
        ns:Print(L.PLAN_USAGE, KnownProfessionNames())
        return
    end

    local Calculator = ns.Calculator
    local prof = Calculator.FindProfession(ns.Data, name)
    if not prof then
        ns:Print(L.PLAN_UNKNOWN, name, KnownProfessionNames())
        return
    end

    -- Make sure the numbers are fresh before planning.
    ns.Scanner.ScanAll()
    local key = ns.Scanner.GetCharKey()
    local result, reason, current, wanted = ns.Planner.Build(key, prof, tonumber(target), "account")
    if reason == "maxed" then
        ns:Print(L.PLAN_MAXED, prof.name)
    elseif reason == "done" then
        ns:Print(L.PLAN_DONE, prof.name, current, wanted)
    elseif result then
        ns.PlanText.PrintPlan(result.plan, result.char, key)
    end
end

---------------------------------------------------------------------------
-- Dispatcher
---------------------------------------------------------------------------

function Commands.PrintHelp()
    ns:Print(L.HELP_HEADER)
    ns:Print(L.HELP_TOGGLE)
    ns:Print(L.HELP_SCAN)
    ns:Print(L.HELP_PLAN)
    ns:Print(L.HELP_RESET)
    ns:Print(L.HELP_VERIFY)
    ns:Print(L.HELP_LOOKUP)
    ns:Print(L.HELP_HELP)
end

local function HandleCommand(msg)
    -- Split "plan Mining" into cmd = "plan", arg = "Mining".
    local cmd, arg = string.match(msg or "", "^%s*(%S*)%s*(.-)%s*$")
    cmd = string.lower(cmd or "")

    if cmd == "" then
        if ns.UI and ns.UI.Toggle then
            ns.UI.Toggle()
        else
            ns:Print(L.NOT_READY_UI)
        end
    elseif cmd == "scan" then
        ns.Scanner.ScanAll()
        Commands.PrintSummary()
    elseif cmd == "plan" then
        Commands.Plan(arg)
    elseif cmd == "reset" then
        Commands.Reset(arg)
    elseif cmd == "verify" then
        ns.Verify.Run()
    elseif cmd == "lookup" then
        ns.Verify.Lookup(arg)
    elseif cmd == "help" then
        Commands.PrintHelp()
    else
        ns:Print(L.UNKNOWN_COMMAND, cmd)
    end
end

-- Unique key so we don't collide with other addons. Never use /pp.
SLASH_PROFESSIONPLANNER1 = "/gfp"
SlashCmdList["PROFESSIONPLANNER"] = function(msg)
    ns:SafeCall("/gfp " .. (msg or ""), HandleCommand, msg)
end
