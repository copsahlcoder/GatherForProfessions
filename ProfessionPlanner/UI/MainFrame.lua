-- The main window: character / profession / target choices and three tabs
-- (Plan, Shopping list, Overview). Opened with /gfp.
local addonName, ns = ...
local L = ns.L
local Compat = ns.Compat
local Widgets = ns.Widgets

local UI = {}
ns.UI = UI

local WIDTH, HEIGHT = 620, 480
local TEXT_WIDTH = WIDTH - 60   -- room for the scroll bar
local TAB_PLAN, TAB_SHOPPING, TAB_OVERVIEW = 1, 2, 3

local frame          -- created on first open, see Create()
local controls = {}  -- dropdowns, tabs, text area

---------------------------------------------------------------------------
-- Saved choices (ProfessionPlannerDB.ui)
---------------------------------------------------------------------------

-- True until the window has been opened once this session. Then we switch
-- to the logged-in character and its main profession (ui is shared by all
-- characters on the account, so it may still point to another character).
local firstOpen = true

-- Selects a character and, if it has one we have data for, its main profession.
local function SelectCharacter(ui, charKey)
    ui.char = charKey
    ui.prof = ns.Planner.MainProfession(charKey) or ui.prof
end

-- Returns the saved UI settings, filling in defaults.
local function Settings()
    local ui = ns.db.ui
    if firstOpen or not ui.char or not ns.db.chars[ui.char] then
        firstOpen = false
        SelectCharacter(ui, ns.Scanner.GetCharKey())
    end
    if not ui.prof or not ns.Data.Professions[ui.prof] then
        ui.prof = 164  -- Blacksmithing, if nothing better is known
    end
    ui.target = ui.target or "next"
    ui.scope = ui.scope or "account"
    ui.tab = ui.tab or TAB_PLAN
    return ui
end

---------------------------------------------------------------------------
-- Dropdown contents
---------------------------------------------------------------------------

local function CharacterItems()
    local items = {}
    for key in pairs(ns.db.chars) do
        table.insert(items, { value = key, text = ns.Planner.DisplayName(key) })
    end
    table.sort(items, function(a, b) return a.text < b.text end)
    return items
end

-- "Blacksmithing (75/150)" when the chosen character has the profession.
local function ProfessionItems(charKey)
    local char = ns.db.chars[charKey] or {}
    local items = {}
    for id, prof in pairs(ns.Data.Professions) do
        local rank, maxRank = ns.Planner.GetSkill(char, id)
        local text = prof.name
        if maxRank > 0 then
            text = string.format(L.UI_PROF_WITH_SKILL, prof.name, rank, maxRank)
        end
        table.insert(items, { value = id, text = text, name = prof.name })
    end
    table.sort(items, function(a, b) return a.name < b.name end)
    return items
end

local function TargetItems()
    return {
        { value = "next", text = L.UI_TARGET_NEXT },
        { value = 75,  text = "75" },
        { value = 150, text = "150" },
        { value = 225, text = "225" },
        { value = 300, text = "300" },
    }
end

local function ScopeItems()
    return {
        { value = "account",   text = L.UI_SCOPE_ACCOUNT },
        { value = "character", text = L.UI_SCOPE_CHARACTER },
    }
end

---------------------------------------------------------------------------
-- Tab contents. Each returns a list of lines.
---------------------------------------------------------------------------

local function DateText(timestamp)
    if not timestamp then
        return L.UI_NEVER
    end
    return date("%Y-%m-%d %H:%M", timestamp)
end

-- Builds the plan for the current choices. Returns result, or nil + message lines.
local function BuildPlan(ui)
    local prof = ns.Data.Professions[ui.prof]
    local target = (ui.target ~= "next") and ui.target or nil
    local result, reason, current, wanted = ns.Planner.Build(ui.char, prof, target, ui.scope)
    if result then
        return result
    end
    if reason == "maxed" then
        return nil, { string.format(L.PLAN_MAXED, prof.name) }
    elseif reason == "done" then
        return nil, { string.format(L.PLAN_DONE, prof.name, current, wanted) }
    end
    return nil, { L.UI_NO_CHAR }
end

local function PlanTabLines(ui)
    local result, message = BuildPlan(ui)
    if not result then
        return message
    end
    local plan, char = result.plan, result.char
    local PlanText = ns.PlanText
    local lines = PlanText.Append({},
        PlanText.HeaderLines(plan),
        { "" },
        PlanText.TrainerLines(plan, char.faction),
        PlanText.ToolLines(plan),
        { "" },
        PlanText.ProgressLines(plan.profession, result.current, result.target))

    -- Materials for the step you are on, then one line for the whole way.
    local stepEnd = ns.Planner.StepEnd(plan.profession, result.current, result.target)
    local stepResult = stepEnd and ns.Planner.Build(ui.char, plan.profession, stepEnd, ui.scope)
    if stepResult then
        local header = string.format(L.MAT_HEADER_STEP, result.current, stepEnd)
        PlanText.Append(lines, { "" }, PlanText.MaterialLines(stepResult.plan, char, ui.char, header))
    end
    return PlanText.Append(lines, { "" }, PlanText.SummaryLines(plan))
end

local function ShoppingTabLines(ui)
    local result, message = BuildPlan(ui)
    if not result then
        return message
    end
    local plan, char = result.plan, result.char
    local PlanText = ns.PlanText
    local lines = PlanText.Append({},
        PlanText.HeaderLines(plan),
        { "" },
        PlanText.MaterialLines(plan, char, ui.char, string.format(L.MAT_HEADER_TOTAL, plan.to)),
        { "" },
        PlanText.FooterLines(plan))
    -- Bank data is only as fresh as the last bank visit.
    table.insert(lines, "")
    table.insert(lines, string.format(L.UI_BANK_SEEN, DateText(char.bankTime)))
    return lines
end

local function OverviewTabLines()
    local lines = {}
    local keys = {}
    for key in pairs(ns.db.chars) do table.insert(keys, key) end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local char = ns.db.chars[key]
        local color = Compat.ClassColorHex(char.classFile)
        table.insert(lines, string.format(L.UI_OVERVIEW_NAME, color, ns.Planner.DisplayName(key)))
        table.insert(lines, string.format(L.UI_OVERVIEW_INFO, char.race or "?", char.class or "?",
            char.level or 0, char.faction or "?"))

        -- Professions sorted by name.
        local profs = {}
        for _, prof in pairs(char.professions or {}) do table.insert(profs, prof) end
        table.sort(profs, function(a, b) return a.name < b.name end)
        local parts = {}
        for _, prof in ipairs(profs) do
            table.insert(parts, string.format(L.UI_OVERVIEW_PROF, prof.name, prof.rank, prof.maxRank))
        end
        table.insert(lines, "    " .. (#parts > 0 and table.concat(parts, ", ") or L.SCAN_NO_PROFS))

        local _, bagTotal = ns.Scanner.CountSummary(char.bags)
        local _, bankTotal = ns.Scanner.CountSummary(char.bank)
        table.insert(lines, string.format(L.UI_OVERVIEW_ITEMS, bagTotal, bankTotal, DateText(char.bankTime)))
        table.insert(lines, "")
    end

    if ns.db.accountBank then
        local _, total = ns.Scanner.CountSummary(ns.db.accountBank.items)
        table.insert(lines, string.format(L.UI_OVERVIEW_ACCOUNT_BANK, total, DateText(ns.db.accountBank.time)))
    end
    return lines
end

---------------------------------------------------------------------------
-- Refresh: rebuild dropdowns and the visible tab from saved data
---------------------------------------------------------------------------

function UI.Refresh()
    if not frame or not frame:IsShown() then return end
    local ui = Settings()

    controls.char:SetItems(CharacterItems())
    controls.char:SetValue(ui.char)
    controls.prof:SetItems(ProfessionItems(ui.char))
    controls.prof:SetValue(ui.prof)
    controls.target:SetValue(ui.target)
    controls.scope:SetValue(ui.scope)
    controls.tabs:Select(ui.tab)

    -- The Overview tab doesn't use the choices above, so hide them there.
    local showChoices = ui.tab ~= TAB_OVERVIEW
    for _, name in ipairs({ "prof", "target", "scope", "profLabel", "targetLabel", "scopeLabel" }) do
        controls[name]:SetShown(showChoices)
    end

    local lines
    if ui.tab == TAB_PLAN then
        lines = PlanTabLines(ui)
    elseif ui.tab == TAB_SHOPPING then
        lines = ShoppingTabLines(ui)
    else
        lines = OverviewTabLines()
    end
    controls.text:SetLines(lines)
end

-- Saves a choice and redraws.
local function Choose(key, value)
    Settings()[key] = value
    UI.Refresh()
end

---------------------------------------------------------------------------
-- Creating the window (only once, the first time it is opened)
---------------------------------------------------------------------------

local function SavePosition(self)
    local point, _, relativePoint, x, y = self:GetPoint()
    ns.db.ui.point = { point, relativePoint, x, y }
end

local function RestorePosition(self)
    local saved = ns.db.ui.point
    self:ClearAllPoints()
    if saved then
        self:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
    else
        self:SetPoint("CENTER")
    end
end

local function Create()
    frame = Compat.CreateFrame("Frame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self)
    end)
    RestorePosition(frame)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -5)
    title:SetText(L.UI_TITLE)

    -- Row 1: character and profession.
    controls.charLabel = Widgets.CreateLabel(frame, L.UI_CHARACTER)
    controls.charLabel:SetPoint("TOPLEFT", 16, -34)
    controls.char = Widgets.CreateDropdown(frame, 220, function(value)
        SelectCharacter(Settings(), value)
        UI.Refresh()
    end)
    controls.char:SetPoint("TOPLEFT", controls.charLabel, "BOTTOMLEFT", 0, -2)

    controls.profLabel = Widgets.CreateLabel(frame, L.UI_PROFESSION)
    controls.profLabel:SetPoint("TOPLEFT", 250, -34)
    controls.prof = Widgets.CreateDropdown(frame, 200, function(value)
        Choose("prof", value)
    end)
    controls.prof:SetPoint("TOPLEFT", controls.profLabel, "BOTTOMLEFT", 0, -2)

    controls.targetLabel = Widgets.CreateLabel(frame, L.UI_TARGET)
    controls.targetLabel:SetPoint("TOPLEFT", 460, -34)
    controls.target = Widgets.CreateDropdown(frame, 140, function(value)
        Choose("target", value)
    end)
    controls.target:SetItems(TargetItems())
    controls.target:SetPoint("TOPLEFT", controls.targetLabel, "BOTTOMLEFT", 0, -2)

    -- Row 2: tabs, and whose items to count.
    controls.tabs = Widgets.CreateTabs(frame, { L.UI_TAB_PLAN, L.UI_TAB_SHOPPING, L.UI_TAB_OVERVIEW }, function(index)
        Choose("tab", index)
    end)
    controls.tabs:SetPoint("TOPLEFT", 16, -82)

    controls.scopeLabel = Widgets.CreateLabel(frame, L.UI_SCOPE)
    controls.scopeLabel:SetPoint("TOPLEFT", 380, -88)
    controls.scope = Widgets.CreateDropdown(frame, 150, function(value)
        Choose("scope", value)
    end)
    controls.scope:SetItems(ScopeItems())
    controls.scope:SetPoint("LEFT", controls.scopeLabel, "RIGHT", 6, 0)

    -- The scrolling text for the selected tab.
    controls.text = Widgets.CreateTextArea(frame, TEXT_WIDTH)
    controls.text:SetPoint("TOPLEFT", 18, -114)
    controls.text:SetPoint("BOTTOMRIGHT", -34, 14)

    frame:SetScript("OnShow", UI.Refresh)
    frame:Hide()
end

---------------------------------------------------------------------------
-- Public
---------------------------------------------------------------------------

function UI.Toggle()
    if not frame then
        Create()
    end
    frame:SetShown(not frame:IsShown())
end

-- Redraw when bags, bank or skills change (at most every half second).
ns:RegisterCallback("DATA_CHANGED", function()
    if frame and frame:IsShown() then
        ns:Debounce("RefreshUI", 0.5, UI.Refresh)
    end
end)
