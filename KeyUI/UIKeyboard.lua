local name, addon = ...;

local UIParent = UIParent

function addon:CreateKeyboard()
    local Keyboard = CreateFrame("Frame", 'KBMainFrame', UIParent, BackdropTemplateMixin and "BackdropTemplate") -- the frame holding the keys

    Keyboard:SetWidth(1490)
    Keyboard:SetHeight(600)
    Keyboard:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    Keyboard:SetBackdropColor(0, 0, 0, 0.8)
    Keyboard:SetPoint("CENTER", UIParent, "CENTER")
    Keyboard:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    Keyboard:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    Keyboard:SetMovable(true) -- make the keyboard moveable

    Keyboard:HookScript("OnShow", function() addon:Load() end)
    tinsert(UISpecialFrames, Keyboard:GetName())
    Keyboard:SetScale(1)
    Keyboard:Hide()

    addon.keyboardFrame = Keyboard
    return Keyboard
end
