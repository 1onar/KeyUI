local name, addon = ...

-- Handles visual effects like manual glow borders for frames
-- Replaces the removed GlowBorderTemplate (thanks, Blizzard)
function addon:create_glow_border(frame)
    -- top left corner
    local topLeft = frame:CreateTexture(nil, "BORDER")
    topLeft:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    topLeft:SetSize(16, 16)
    topLeft:SetTexCoord(0.03125, 0.53125, 0.570312, 0.695312)
    topLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", -8, 8)

    -- top right corner
    local topRight = frame:CreateTexture(nil, "BORDER")
    topRight:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    topRight:SetSize(16, 16)
    topRight:SetTexCoord(0.03125, 0.53125, 0.710938, 0.835938)
    topRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 7, 8)

    -- bottom left corner
    local bottomLeft = frame:CreateTexture(nil, "BORDER")
    bottomLeft:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    bottomLeft:SetSize(16, 16)
    bottomLeft:SetTexCoord(0.03125, 0.53125, 0.289062, 0.414062)
    bottomLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -8, -8)

    -- bottom right corner
    local bottomRight = frame:CreateTexture(nil, "BORDER")
    bottomRight:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    bottomRight:SetSize(16, 16)
    bottomRight:SetTexCoord(0.03125, 0.53125, 0.429688, 0.554688)
    bottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -8)

    -- top edge
    local top = frame:CreateTexture(nil, "BORDER")
    top:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    top:SetSize(16, 16)
    top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
    top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
    top:SetTexCoord(0, 0.5, 0.148438, 0.273438)

    -- bottom edge
    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlow")
    bottom:SetSize(16, 16)
    bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
    bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")
    bottom:SetTexCoord(0, 0.5, 0.0078125, 0.132812)

    -- left edge
    local left = frame:CreateTexture(nil, "BORDER")
    left:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlowVertical")
    left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
    left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
    left:SetTexCoord(0.015625, 0.265625, 0, 1)

    -- right edge
    local right = frame:CreateTexture(nil, "BORDER")
    right:SetTexture("Interface/TutorialFrame/UIFrameTutorialGlowVertical")
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

-- Button styling helper using dropdown textures
local BUTTON_TEXTURE = "Interface/Buttons/Dropdown"
local DEFAULT_FONT = "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF"

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

    local font = options.font or DEFAULT_FONT
    local fontSize = options.fontSize or 16
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

    local highlightText = button:CreateFontString(nil, highlightLayer)
    highlightText:SetFont(font, fontSize)
    highlightText:SetPoint("CENTER", button, "CENTER", textOffsetX, textOffsetY)
    highlightText:SetText(options.label or "")
    button._styledHighlightText = highlightText

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
