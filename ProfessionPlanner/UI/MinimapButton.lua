-- Minimap button: left-click opens/closes the main window, drag moves it
-- around the minimap. Position and visibility are saved in
-- ProfessionPlannerDB.ui.minimap. No libraries (no LibDBIcon).
local addonName, ns = ...
local L = ns.L

local Minimap = Minimap
local MinimapButton = {}
ns.MinimapButton = MinimapButton

local ICON = "Interface\\Icons\\INV_Pick_02"
local DEFAULT_ANGLE = 210  -- degrees, 0 = right, counter-clockwise (lower left)

local button  -- created at login, see Create()

local function Settings()
    local ui = ns.db.ui
    ui.minimap = ui.minimap or { angle = DEFAULT_ANGLE, hide = false }
    return ui.minimap
end

-- Places the button on the minimap edge at the saved angle.
local function UpdatePosition()
    local angle = math.rad(Settings().angle)
    local radius = Minimap:GetWidth() / 2 + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

-- While dragging: follow the cursor around the minimap centre.
local function OnDragUpdate()
    local centerX, centerY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    Settings().angle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX)) % 360
    UpdatePosition()
end

local function OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L.UI_TITLE)
    GameTooltip:AddLine(L.MINIMAP_TIP_CLICK, 1, 1, 1)
    GameTooltip:AddLine(L.MINIMAP_TIP_DRAG, 1, 1, 1)
    GameTooltip:AddLine(L.MINIMAP_TIP_HIDE, 0.5, 0.5, 0.5)
    GameTooltip:Show()
end

local function Create()
    button = CreateFrame("Button", nil, Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- The usual round minimap button look: dark background, icon, gold ring.
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture(ICON)
    icon:SetPoint("TOPLEFT", 7, -6)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT")

    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function()
        ns.UI.Toggle()
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", OnDragUpdate)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdatePosition()
    button:SetShown(not Settings().hide)
end

-- /gfp minimap: show or hide the button.
function MinimapButton.Toggle()
    local settings = Settings()
    settings.hide = not settings.hide
    if button then
        button:SetShown(not settings.hide)
    end
    ns:Print(settings.hide and L.MINIMAP_HIDDEN or L.MINIMAP_SHOWN)
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    if Minimap then
        Create()
    end
end)
