local name, addon = ...

function addon:CreateControls()
    local Controls = CreateFrame("Frame", 'KBControlsFrame', UIParent, BackdropTemplateMixin and "BackdropTemplate")
    tinsert(UISpecialFrames, Controls:GetName())
    local Keyboard = addon.keyboardFrame
    local Mouse = self.mouseFrame
    local modif = self.modif

    Controls:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    Controls:SetBackdropColor(0, 0, 0, 0.8)
    Controls:EnableMouse(true)
    Controls:SetMovable(true)
    Controls:SetSize(250, 110)
    Controls:SetPoint("TOPLEFT", UIParent, "CENTER", -400, 400)
    Controls:SetScript("OnMouseDown", function(s) s:StartMoving() end)
    Controls:SetScript("OnMouseUp", function(s) s:StopMovingOrSizing() end)

--    Controls.Close = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
--    Controls.Close:SetSize(26, 18)
--    Controls.Close:SetText("X")
--    Controls.Close:SetScript("OnClick", function(s) Controls:Hide() Keyboard:Hide() end)
--    Controls.Close:SetPoint("TOPRIGHT", Controls, "TOPRIGHT")

    Controls.Close = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    Controls.Close:SetSize(60, 26)
    Controls.Close:SetText("Hide")
    Controls.Close:SetScript("OnClick", function(s) Controls:Hide() end)
    Controls.Close:SetPoint("TOPRIGHT", Controls, "TOPRIGHT", -8, -10)

    Controls.Close = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    Controls.Close:SetSize(60, 26)
    Controls.Close:SetText("Refresh")
    Controls.Close:SetScript("OnClick", function(s) Keyboard:Hide() Keyboard:Show() end)
    Controls.Close:SetPoint("TOPRIGHT", Controls, "TOPRIGHT", -73, -10)

    Controls.Slider = CreateFrame("Slider", "KeyBind_Slider1", Controls, "OptionsSliderTemplate", BackdropTemplateMixin and "BackdropTemplate")

    Controls.Slider:SetMinMaxValues(0.5, 1)
    Controls.Slider:SetValueStep(0.05)
    Controls.Slider:SetValue(1)
    _G[Controls.Slider:GetName().."Low"]:SetText("0.5")
    _G[Controls.Slider:GetName().."High"]:SetText("1")
    Controls.Slider:SetScript("OnValueChanged", function(self) Keyboard:SetScale(self:GetValue()) end)
    Controls.Slider:SetWidth(224)
    Controls.Slider:SetHeight(20)
    Controls.Slider:SetPoint("BOTTOMLEFT", Controls, "BOTTOMLEFT", 15, 15)

    Controls.ShiftCB = CreateFrame("CheckButton", "KeyBindShiftCB", Controls, "ChatConfigCheckButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    _G[Controls.ShiftCB:GetName().."Text"]:SetText("Shift")
    Controls.ShiftCB:SetHitRectInsets(0, -40, 0, 0)
    Controls.ShiftCB:SetPoint("TOP", Controls, "TOPLEFT", 26, -44)
    Controls.ShiftCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            modif.SHIFT = "SHIFT-"
        else
            modif.SHIFT = ""
        end
        addon:RefreshKeys()
    end)
    Controls.ShiftCB:SetSize(30, 30)

    Controls.CtrlCB = CreateFrame("CheckButton", "KeyBindCtrlCB", Controls, "ChatConfigCheckButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    _G[Controls.CtrlCB:GetName().."Text"]:SetText("Ctrl")
    Controls.CtrlCB:SetHitRectInsets(0, -40, 0, 0)
    Controls.CtrlCB:SetPoint("TOP", Controls, "TOP", 0, -44)
    Controls.CtrlCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            modif.CTRL = "CTRL-"
        else
            modif.CTRL = ""
        end
        addon:RefreshKeys()
    end)
    Controls.CtrlCB:SetSize(30, 30)

    Controls.AltCB = CreateFrame("CheckButton", "KeyBindAltCB", Controls, "ChatConfigCheckButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    _G[Controls.AltCB:GetName().."Text"]:SetText("Alt")
    Controls.AltCB:SetHitRectInsets(0, -40, 0, 0)
    Controls.AltCB:SetPoint("TOP", Controls, "TOPRIGHT", -46, -44)
    Controls.AltCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            modif.ALT = "ALT-"
        else
            modif.ALT = ""
        end
        addon:RefreshKeys()
    end)
    Controls.AltCB:SetSize(30, 30)

    Controls.Keyboard = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate")
    Controls.Keyboard:SetSize(80, 20)
    Controls.Keyboard:SetPoint("TOPRIGHT", Controls.Mouse, "BOTTOMRIGHT", 0, -5)
    Controls.Keyboard:SetText("Keyboard")
    Controls.Keyboard:SetScript("OnClick", function(s)
        if Keyboard:IsShown() then
            Keyboard:Hide()
        else
            Keyboard:Show()
        end
    end)

    Controls:Hide()
    addon.controlsFrame = Controls
    return Controls
end
