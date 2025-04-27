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