-- Small, self-made UI widgets. We avoid UIDropDownMenu and the tab
-- templates on purpose: they differ a lot between client versions.
-- Everything here uses only basic frames and UIPanelButtonTemplate.
local addonName, ns = ...
local Compat = ns.Compat

local Widgets = {}
ns.Widgets = Widgets

local ROW_HEIGHT = 18

local MENU_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

---------------------------------------------------------------------------
-- Label
---------------------------------------------------------------------------

function Widgets.CreateLabel(parent, text)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetText(text)
    return label
end

---------------------------------------------------------------------------
-- Dropdown: a button showing the current choice. Clicking it opens a list.
--   dropdown:SetItems({ { value = ..., text = ... }, ... })
--   dropdown:SetValue(value)
--   onSelect(value) is called when the player picks an item.
---------------------------------------------------------------------------

function Widgets.CreateDropdown(parent, width, onSelect)
    local button = Compat.CreateFrame("Button", parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button.items = {}
    button.rows = {}

    local menu = Compat.CreateFrame("Frame", button, "BackdropTemplate")
    menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    menu:SetWidth(width)
    menu:SetFrameStrata("DIALOG")
    if menu.SetBackdrop then
        menu:SetBackdrop(MENU_BACKDROP)
        menu:SetBackdropColor(0, 0, 0, 0.95)
    end
    menu:Hide()
    button.menu = menu

    -- Creates (or reuses) row number i in the open list.
    local function GetRow(i)
        local row = button.rows[i]
        if not row then
            row = CreateFrame("Button", nil, menu)
            row:SetHeight(ROW_HEIGHT)
            row:SetPoint("TOPLEFT", 6, -6 - (i - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", -6, 0)
            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 4, 0)
            row.text:SetPoint("RIGHT", -4, 0)
            row.text:SetJustifyH("LEFT")
            local highlight = row:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 1, 1, 0.15)
            row:SetScript("OnClick", function(self)
                menu:Hide()
                button:SetValue(self.value)
                ns:SafeCall("dropdown", onSelect, self.value)
            end)
            button.rows[i] = row
        end
        return row
    end

    local function OpenMenu()
        for i, item in ipairs(button.items) do
            local row = GetRow(i)
            row.value = item.value
            row.text:SetText(item.text)
            row:Show()
        end
        for i = #button.items + 1, #button.rows do
            button.rows[i]:Hide()
        end
        menu:SetHeight(12 + #button.items * ROW_HEIGHT)
        menu:Show()
    end

    button:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            OpenMenu()
        end
    end)
    button:SetScript("OnHide", function()
        menu:Hide()
    end)

    function button:SetItems(items)
        self.items = items
        self:SetValue(self.value)
    end

    function button:SetValue(value)
        self.value = value
        for _, item in ipairs(self.items) do
            if item.value == value then
                self:SetText(item.text)
                return
            end
        end
        self:SetText("")
    end

    return button
end

---------------------------------------------------------------------------
-- Tabs: a row of buttons. The selected one is disabled so it looks pressed.
--   tabs:Select(index); onSelect(index) is called on click.
---------------------------------------------------------------------------

function Widgets.CreateTabs(parent, names, onSelect)
    local tabs = { buttons = {} }
    local previous
    for i, name in ipairs(names) do
        local tab = Compat.CreateFrame("Button", parent, "UIPanelButtonTemplate")
        tab:SetText(name)
        tab:SetSize(110, 22)
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        end
        tab:SetScript("OnClick", function()
            tabs:Select(i)
            ns:SafeCall("tab", onSelect, i)
        end)
        tabs.buttons[i] = tab
        previous = tab
    end

    function tabs:Select(index)
        self.selected = index
        for i, tab in ipairs(self.buttons) do
            tab:SetEnabled(i ~= index)
        end
    end

    -- Anchor the first tab; the others follow it.
    function tabs:SetPoint(...)
        self.buttons[1]:SetPoint(...)
    end

    return tabs
end

---------------------------------------------------------------------------
-- Scrolling text area: one long multi-line text inside a scroll frame.
--   area:SetLines({ "line 1", "line 2", ... })
---------------------------------------------------------------------------

function Widgets.CreateTextArea(parent, width)
    local scroll = Compat.CreateFrame("ScrollFrame", parent, "UIPanelScrollFrameTemplate")
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(width, 1)
    scroll:SetScrollChild(child)

    local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetWidth(width)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetSpacing then
        text:SetSpacing(2)
    end

    function scroll:SetLines(lines)
        text:SetText(table.concat(lines, "\n"))
        child:SetHeight(text:GetStringHeight() + 10)
        self:SetVerticalScroll(0)
    end

    return scroll
end
