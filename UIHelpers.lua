local name, addon = ...

-- Use centralized version detection from VersionCompat.lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

-- Texture paths with Anniversary fallback
local GLOW_TEXTURE = USE_ATLAS and "Interface/TutorialFrame/UIFrameTutorialGlow"
    or "Interface\\AddOns\\KeyUI\\Media\\Atlas\\uiframetutorialglow"
local GLOW_TEXTURE_VERTICAL = USE_ATLAS and "Interface/TutorialFrame/UIFrameTutorialGlowVertical"
    or "Interface\\AddOns\\KeyUI\\Media\\Atlas\\uiframetutorialglowvertical"

-- Handles visual effects like manual glow borders for frames
-- Replaces the removed GlowBorderTemplate (thanks, Blizzard)
function addon:create_glow_border(frame)
    -- top left corner
    local topLeft = frame:CreateTexture(nil, "BORDER")
    topLeft:SetTexture(GLOW_TEXTURE)
    topLeft:SetSize(16, 16)
    topLeft:SetTexCoord(0.03125, 0.53125, 0.570312, 0.695312)
    topLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", -8, 8)

    -- top right corner
    local topRight = frame:CreateTexture(nil, "BORDER")
    topRight:SetTexture(GLOW_TEXTURE)
    topRight:SetSize(16, 16)
    topRight:SetTexCoord(0.03125, 0.53125, 0.710938, 0.835938)
    topRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 7, 8)

    -- bottom left corner
    local bottomLeft = frame:CreateTexture(nil, "BORDER")
    bottomLeft:SetTexture(GLOW_TEXTURE)
    bottomLeft:SetSize(16, 16)
    bottomLeft:SetTexCoord(0.03125, 0.53125, 0.289062, 0.414062)
    bottomLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -8, -8)

    -- bottom right corner
    local bottomRight = frame:CreateTexture(nil, "BORDER")
    bottomRight:SetTexture(GLOW_TEXTURE)
    bottomRight:SetSize(16, 16)
    bottomRight:SetTexCoord(0.03125, 0.53125, 0.429688, 0.554688)
    bottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -8)

    -- top edge
    local top = frame:CreateTexture(nil, "BORDER")
    top:SetTexture(GLOW_TEXTURE)
    top:SetSize(16, 16)
    top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
    top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
    top:SetTexCoord(0, 0.5, 0.148438, 0.273438)

    -- bottom edge
    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetTexture(GLOW_TEXTURE)
    bottom:SetSize(16, 16)
    bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
    bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")
    bottom:SetTexCoord(0, 0.5, 0.0078125, 0.132812)

    -- left edge
    local left = frame:CreateTexture(nil, "BORDER")
    left:SetTexture(GLOW_TEXTURE_VERTICAL)
    left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
    left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
    left:SetTexCoord(0.015625, 0.265625, 0, 1)

    -- right edge
    local right = frame:CreateTexture(nil, "BORDER")
    right:SetTexture(GLOW_TEXTURE_VERTICAL)
    right:SetPoint("TOPLEFT", topRight, "BOTTOMLEFT", 1, 0)
    right:SetPoint("BOTTOMRIGHT", bottomRight, "TOPRIGHT", 1, 0)
    right:SetTexCoord(0.296875, 0.546875, 0, 1)
end

-- Convenience helper to create a glow frame with consistent defaults.
-- Returns the newly created frame so callers can show/hide or resize it.
function addon:CreateGlowFrame(parent, options)
    assert(parent, "CreateGlowFrame requires a parent frame")

    options = options or {}
    local frameParent = options.parent or parent
    local frame = CreateFrame(options.frameType or "Frame", options.name, frameParent, options.template)

    local frameLevelOffset = options.frameLevelOffset
    if frameLevelOffset == nil then
        frameLevelOffset = 1
    end

    frame:SetFrameLevel(options.frameLevel or (frameParent:GetFrameLevel() + frameLevelOffset))
    frame:SetFrameStrata(options.frameStrata or frameParent:GetFrameStrata())

    if options.point then
        frame:SetPoint(unpack(options.point))
    elseif parent then
        frame:SetPoint("CENTER", parent, "CENTER", options.offsetX or 0, options.offsetY or 0)
    end

    if options.matchParent then
        frame:SetAllPoints(parent)
    else
        local width = options.width or parent:GetWidth()
        local height = options.height or parent:GetHeight()
        if width and height then
            frame:SetSize(width, height)
        end
    end

    if options.alpha then
        frame:SetAlpha(options.alpha)
    end

    addon:create_glow_border(frame)

    if options.startHidden ~= false then
        frame:Hide()
    end

    return frame
end

-- Helper to set texture with Atlas fallback
function addon:SetTexture(textureObject, atlasName, filePath, texCoords)
    if USE_ATLAS then
        textureObject:SetAtlas(atlasName)
    else
        textureObject:SetTexture(filePath)
        if texCoords then
            textureObject:SetTexCoord(unpack(texCoords))
        end
    end
end

-- Button styling helper using dropdown textures
local BUTTON_TEXTURE = USE_ATLAS and "Interface/Buttons/Dropdown"
    or "Interface\\AddOns\\KeyUI\\Media\\Atlas\\dropdown"

local TEX_COORDS = {
    normal_left = { 0.03125, 0.53125, 0.470703, 0.560547 },
    normal_right = { 0.03125, 0.53125, 0.751953, 0.841797 },
    normal_middle = { 0, 0.5, 0.0957031, 0.185547 },
    hover_left = { 0.03125, 0.53125, 0.283203, 0.373047 },
    hover_right = { 0.03125, 0.53125, 0.376953, 0.466797 },
    hover_middle = { 0, 0.5, 0.00195312, 0.0917969 },
}

local function applyDisabledState(button)
    local disabled = not button:IsEnabled()
    local textColor = disabled and 0.192 or 1
    local textureColor = disabled and 0.4 or 1

    if button._styledText then
        button._styledText:SetTextColor(textColor, textColor, textColor)
    end

    if button._styledHighlightText then
        button._styledHighlightText:SetTextColor(textColor, textColor, textColor)
    end

    if button._styledNormalTextures then
        for _, tex in ipairs(button._styledNormalTextures) do
            tex:SetVertexColor(textureColor, textureColor, textureColor)
        end
    end

    if button._styledHoverTextures then
        for _, tex in ipairs(button._styledHoverTextures) do
            tex:SetVertexColor(textureColor, textureColor, textureColor)
        end
    end
end

local function createTexture(parent, layer, coords, height)
    local tex = parent:CreateTexture(nil, layer)
    tex:SetTexture(BUTTON_TEXTURE)
    tex:SetTexCoord(unpack(coords))
    tex:SetSize(16, height)
    return tex
end

function addon:CreateStyledButton(parent, options)
    options = options or {}
    local button = CreateFrame(options.frameType or "Button", options.name, parent, options.template)

    button:SetSize(options.width or 160, options.height or 30)

    if options.point then
        button:SetPoint(unpack(options.point))
    end

    local fontRatio = options.fontRatio or 1.0
    local font = options.font or addon:GetFont()
    local fontSize = options.fontSize or addon:GetFontSize(fontRatio)
    local textOffsetX = options.textOffsetX or 0
    local textOffsetY = options.textOffsetY or 0
    local textLayer = options.textLayer or "OVERLAY"
    local highlightLayer = options.highlightLayer or "HIGHLIGHT"

    local text = button:CreateFontString(nil, textLayer)
    text:SetFont(font, fontSize)
    text:SetPoint("CENTER", button, "CENTER", textOffsetX, textOffsetY)
    text:SetText(options.label or "")
    text:SetTextColor(1, 1, 1)
    button._styledText = text
    addon:RegisterFontString(text, fontRatio)

    local highlightText = button:CreateFontString(nil, highlightLayer)
    highlightText:SetFont(font, fontSize)
    highlightText:SetPoint("CENTER", button, "CENTER", textOffsetX, textOffsetY)
    highlightText:SetText(options.label or "")
    button._styledHighlightText = highlightText
    addon:RegisterFontString(highlightText, fontRatio)

    local textureHeight = options.textureHeight or 46

    local left = createTexture(button, "ARTWORK", TEX_COORDS.normal_left, textureHeight)
    left:SetPoint("LEFT", button, "LEFT")

    local right = createTexture(button, "ARTWORK", TEX_COORDS.normal_right, textureHeight)
    right:SetPoint("RIGHT", button, "RIGHT")

    local middle = createTexture(button, "ARTWORK", TEX_COORDS.normal_middle, textureHeight)
    middle:SetPoint("LEFT", left, "RIGHT")
    middle:SetPoint("RIGHT", right, "LEFT")

    local hoverLeft = createTexture(button, "HIGHLIGHT", TEX_COORDS.hover_left, textureHeight)
    hoverLeft:SetPoint("LEFT", button, "LEFT")

    local hoverRight = createTexture(button, "HIGHLIGHT", TEX_COORDS.hover_right, textureHeight)
    hoverRight:SetPoint("RIGHT", button, "RIGHT")

    local hoverMiddle = createTexture(button, "HIGHLIGHT", TEX_COORDS.hover_middle, textureHeight)
    hoverMiddle:SetPoint("LEFT", hoverLeft, "RIGHT")
    hoverMiddle:SetPoint("RIGHT", hoverRight, "LEFT")

    button._styledNormalTextures = { left, middle, right }
    button._styledHoverTextures = { hoverLeft, hoverMiddle, hoverRight }

    function button:SetStyledText(newText)
        newText = newText or ""
        if button._styledText then
            button._styledText:SetText(newText)
        end
        if button._styledHighlightText then
            button._styledHighlightText:SetText(newText)
        end
    end

    button:HookScript("OnEnable", applyDisabledState)
    button:HookScript("OnDisable", applyDisabledState)
    applyDisabledState(button)

    if type(options.onClick) == "function" then
        button:SetScript("OnClick", options.onClick)
    end

    return button
end

-- Creates tab buttons with Anniversary compatibility
-- Matches Blizzard's PanelTabButtonTemplate structure
function addon:CreateTabButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(115, 32)

    -- Inactive state: Left piece (matches uiframe-tab-left)
    local left = button:CreateTexture(nil, "BACKGROUND")
    left:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    left:SetSize(35, 36)
    left:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 0)
    left:SetTexCoord(0.015625, 0.5625, 0.816406, 0.957031)
    button.Left = left

    -- Inactive state: Right piece (matches uiframe-tab-right)
    local right = button:CreateTexture(nil, "BACKGROUND")
    right:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    right:SetSize(37, 36)
    right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 7, 0)
    right:SetTexCoord(0.015625, 0.59375, 0.667969, 0.808594)
    button.Right = right

    -- Inactive state: Middle piece (matches _uiframe-tab-center)
    local middle = button:CreateTexture(nil, "BACKGROUND")
    middle:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middle:SetHeight(36)
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
    middle:SetPoint("TOPRIGHT", right, "TOPLEFT")
    middle:SetTexCoord(0, 0.015625, 0.175781, 0.316406)
    button.Middle = middle

    -- Active state: Left piece (matches uiframe-activetab-left)
    local leftActive = button:CreateTexture(nil, "BACKGROUND")
    leftActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    leftActive:SetSize(35, 42)
    leftActive:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 0)
    leftActive:SetTexCoord(0.015625, 0.5625, 0.496094, 0.660156)
    leftActive:Hide()
    button.LeftActive = leftActive

    -- Active state: Right piece (matches uiframe-activetab-right)
    local rightActive = button:CreateTexture(nil, "BACKGROUND")
    rightActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    rightActive:SetSize(37, 42)
    rightActive:SetPoint("TOPRIGHT", button, "TOPRIGHT", 8, 0)
    rightActive:SetTexCoord(0.015625, 0.59375, 0.324219, 0.488281)
    rightActive:Hide()
    button.RightActive = rightActive

    -- Active state: Middle piece (matches _uiframe-activetab-center)
    local middleActive = button:CreateTexture(nil, "BACKGROUND")
    middleActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middleActive:SetHeight(42)
    middleActive:SetPoint("TOPLEFT", leftActive, "TOPRIGHT")
    middleActive:SetPoint("TOPRIGHT", rightActive, "TOPLEFT")
    middleActive:SetTexCoord(0, 0.015625, 0.00390625, 0.167969)
    middleActive:Hide()
    button.MiddleActive = middleActive

    -- Highlight textures (hover state)
    local leftHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    leftHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    leftHighlight:SetSize(35, 36)
    leftHighlight:SetPoint("TOPLEFT", left, "TOPLEFT")
    leftHighlight:SetTexCoord(0.015625, 0.5625, 0.816406, 0.957031)
    leftHighlight:SetBlendMode("ADD")
    leftHighlight:SetAlpha(0.4)
    button.LeftHighlight = leftHighlight

    local rightHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    rightHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    rightHighlight:SetSize(37, 36)
    rightHighlight:SetPoint("TOPRIGHT", right, "TOPRIGHT")
    rightHighlight:SetTexCoord(0.015625, 0.59375, 0.667969, 0.808594)
    rightHighlight:SetBlendMode("ADD")
    rightHighlight:SetAlpha(0.4)
    button.RightHighlight = rightHighlight

    local middleHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    middleHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middleHighlight:SetHeight(36)
    middleHighlight:SetPoint("TOPLEFT", middle, "TOPLEFT")
    middleHighlight:SetPoint("TOPRIGHT", middle, "TOPRIGHT")
    middleHighlight:SetTexCoord(0, 0.015625, 0.175781, 0.316406)
    middleHighlight:SetBlendMode("ADD")
    middleHighlight:SetAlpha(0.4)
    button.MiddleHighlight = middleHighlight

    -- Text
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetDisabledFontObject("GameFontDisableSmall")

    return button
end

-- Creates top tab buttons (for keyboard/controller frames) with Anniversary compatibility
-- Matches Blizzard's PanelTopTabButtonMixin behavior:
-- - Uses BOTTOMLEFT/BOTTOMRIGHT anchors (not TOPLEFT!)
-- - Vertically flipped texture coords (vMax, vMin instead of vMin, vMax)
-- - 75% height of normal tabs
function addon:CreateTopTabButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(115, 32)

    local TOP_TAB_HEIGHT_PERCENT = 0.75

    -- Inactive state: Left piece
    local left = button:CreateTexture(nil, "BACKGROUND")
    left:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    left:SetSize(35, 36 * TOP_TAB_HEIGHT_PERCENT)
    left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -3, 0)
    left:SetTexCoord(0.015625, 0.5625, 0.957031, 0.816406)  -- V-flipped from CreateTabButton
    button.Left = left

    -- Inactive state: Right piece
    local right = button:CreateTexture(nil, "BACKGROUND")
    right:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    right:SetSize(37, 36 * TOP_TAB_HEIGHT_PERCENT)
    right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 7, 0)
    right:SetTexCoord(0.015625, 0.59375, 0.808594, 0.667969)  -- V-flipped from CreateTabButton
    button.Right = right

    -- Inactive state: Middle piece
    local middle = button:CreateTexture(nil, "BACKGROUND")
    middle:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middle:SetHeight(36 * TOP_TAB_HEIGHT_PERCENT)
    middle:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT")
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
    middle:SetTexCoord(0, 0.015625, 0.316406, 0.175781)  -- V-flipped from CreateTabButton
    button.Middle = middle

    -- Active state: Left piece
    local leftActive = button:CreateTexture(nil, "BACKGROUND")
    leftActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    leftActive:SetSize(35, 42 * TOP_TAB_HEIGHT_PERCENT)
    leftActive:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -1, 0)
    leftActive:SetTexCoord(0.015625, 0.5625, 0.660156, 0.496094)  -- V-flipped from CreateTabButton
    leftActive:Hide()
    button.LeftActive = leftActive

    -- Active state: Right piece
    local rightActive = button:CreateTexture(nil, "BACKGROUND")
    rightActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    rightActive:SetSize(37, 42 * TOP_TAB_HEIGHT_PERCENT)
    rightActive:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, 0)
    rightActive:SetTexCoord(0.015625, 0.59375, 0.488281, 0.324219)  -- V-flipped from CreateTabButton
    rightActive:Hide()
    button.RightActive = rightActive

    -- Active state: Middle piece
    local middleActive = button:CreateTexture(nil, "BACKGROUND")
    middleActive:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middleActive:SetHeight(42 * TOP_TAB_HEIGHT_PERCENT)
    middleActive:SetPoint("BOTTOMLEFT", leftActive, "BOTTOMRIGHT")
    middleActive:SetPoint("BOTTOMRIGHT", rightActive, "BOTTOMLEFT")
    middleActive:SetTexCoord(0, 0.015625, 0.167969, 0.00390625)  -- V-flipped from CreateTabButton
    middleActive:Hide()
    button.MiddleActive = middleActive

    -- Highlight textures
    local leftHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    leftHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    leftHighlight:SetSize(35, 36 * TOP_TAB_HEIGHT_PERCENT)
    leftHighlight:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT")
    leftHighlight:SetTexCoord(0.015625, 0.5625, 0.957031, 0.816406)  -- V-flipped from CreateTabButton
    leftHighlight:SetBlendMode("ADD")
    leftHighlight:SetAlpha(0.4)
    button.LeftHighlight = leftHighlight

    local rightHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    rightHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    rightHighlight:SetSize(37, 36 * TOP_TAB_HEIGHT_PERCENT)
    rightHighlight:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT")
    rightHighlight:SetTexCoord(0.015625, 0.59375, 0.808594, 0.667969)  -- V-flipped from CreateTabButton
    rightHighlight:SetBlendMode("ADD")
    rightHighlight:SetAlpha(0.4)
    button.RightHighlight = rightHighlight

    local middleHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    middleHighlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\UIFrameTabs")
    middleHighlight:SetHeight(36 * TOP_TAB_HEIGHT_PERCENT)
    middleHighlight:SetPoint("BOTTOMLEFT", middle, "BOTTOMLEFT")
    middleHighlight:SetPoint("BOTTOMRIGHT", middle, "BOTTOMRIGHT")
    middleHighlight:SetTexCoord(0, 0.015625, 0.316406, 0.175781)  -- V-flipped from CreateTabButton
    middleHighlight:SetBlendMode("ADD")
    middleHighlight:SetAlpha(0.4)
    button.MiddleHighlight = middleHighlight

    -- Text
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetDisabledFontObject("GameFontDisableSmall")

    return button
end

-- Creates close buttons using redbutton2x atlas (used by Controls frame)
function addon:CreateCloseButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)

    local texture_path = "Interface\\AddOns\\KeyUI\\Media\\Atlas\\redbutton2x"

    -- Normal state
    local normal = button:CreateTexture(nil, "ARTWORK")
    normal:SetTexture(texture_path)
    normal:SetTexCoord(0.152344, 0.292969, 0.0078125, 0.304688)
    normal:SetAllPoints()
    button:SetNormalTexture(normal)

    -- Pushed state
    local pushed = button:CreateTexture(nil, "ARTWORK")
    pushed:SetTexture(texture_path)
    pushed:SetTexCoord(0.152344, 0.292969, 0.632812, 0.929688)
    pushed:SetAllPoints()
    button:SetPushedTexture(pushed)

    -- Disabled state
    local disabled = button:CreateTexture(nil, "ARTWORK")
    disabled:SetTexture(texture_path)
    disabled:SetTexCoord(0.152344, 0.292969, 0.320312, 0.617188)
    disabled:SetAllPoints()
    button:SetDisabledTexture(disabled)

    -- Highlight state
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(texture_path)
    highlight:SetTexCoord(0.449219, 0.589844, 0.0078125, 0.304688)
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints()
    button:SetHighlightTexture(highlight)

    return button
end

-- Creates exit button using 128redbutton atlas (matches ArrowDownButton style)
function addon:CreateExitButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)

    local texture_path = "Interface\\AddOns\\KeyUI\\Media\\Atlas\\128redbutton"

    -- Normal state
    local normal = button:CreateTexture(nil, "ARTWORK")
    normal:SetTexture(texture_path)
    normal:SetTexCoord(0.509766, 0.759766, 0.508301, 0.570801)
    normal:SetAllPoints()
    button:SetNormalTexture(normal)

    -- Pushed state
    local pushed = button:CreateTexture(nil, "ARTWORK")
    pushed:SetTexture(texture_path)
    pushed:SetTexCoord(0.509766, 0.759766, 0.571777, 0.634277)
    pushed:SetAllPoints()
    button:SetPushedTexture(pushed)

    -- Disabled state
    local disabled = button:CreateTexture(nil, "ARTWORK")
    disabled:SetTexture(texture_path)
    disabled:SetTexCoord(0.00195312, 0.251953, 0.571777, 0.634277)
    disabled:SetAllPoints()
    button:SetDisabledTexture(disabled)

    -- Highlight state
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(texture_path)
    highlight:SetTexCoord(0.255859, 0.505859, 0.571777, 0.634277)
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints()
    button:SetHighlightTexture(highlight)

    return button
end

function addon:CreateArrowDownButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)

    local texture_path = "Interface\\AddOns\\KeyUI\\Media\\Atlas\\128redbutton"

    -- Normal state
    local normal = button:CreateTexture(nil, "ARTWORK")
    normal:SetTexture(texture_path)
    normal:SetTexCoord(0.576172, 0.826172, 0.254395, 0.316895)
    normal:SetAllPoints()
    button:SetNormalTexture(normal)

    -- Pushed state
    local pushed = button:CreateTexture(nil, "ARTWORK")
    pushed:SetTexture(texture_path)
    pushed:SetTexCoord(0.00195312, 0.251953, 0.444824, 0.507324)
    pushed:SetAllPoints()
    button:SetPushedTexture(pushed)

    -- Disabled state
    local disabled = button:CreateTexture(nil, "ARTWORK")
    disabled:SetTexture(texture_path)
    disabled:SetTexCoord(0.576172, 0.826172, 0.317871, 0.380371)
    disabled:SetAllPoints()
    button:SetDisabledTexture(disabled)

    -- Highlight state
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(texture_path)
    highlight:SetTexCoord(0.576172, 0.826172, 0.381348, 0.443848)
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints()
    button:SetHighlightTexture(highlight)

    return button
end

