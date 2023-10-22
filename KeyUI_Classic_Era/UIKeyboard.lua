local name, addon = ...

KeyboardPosition = {}

AltCheckbox = false
CtrlCheckbox = false
ShiftCheckbox = false

function addon:SaveKeyboard()
    KeyboardPosition.x, KeyboardPosition.y = KeyUIMainFrame:GetCenter()
    KeyboardPosition.scale = KeyUIMainFrame:GetScale()
end

function addon:CreateKeyboard()
    local Keyboard = CreateFrame("Frame", 'KeyUIMainFrame', UIParent, "TooltipBorderedFrameTemplate") -- the frame holding the keys
    tinsert(UISpecialFrames, "KeyUIMainFrame")
 
    Keyboard:SetWidth(1100)
    Keyboard:SetHeight(500)
    Keyboard:SetBackdropColor(0, 0, 0, 0.7)

    -- Load the saved position if it exists
    if KeyboardPosition.x and KeyboardPosition.y then
        Keyboard:SetPoint("CENTER", UIParent, "BOTTOMLEFT", KeyboardPosition.x, KeyboardPosition.y)
        Keyboard:SetScale(KeyboardPosition.scale)
    else
        Keyboard:SetPoint("CENTER", UIParent, "CENTER", -300, 50)
        Keyboard:SetScale(1)
    end
    
    Keyboard:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    Keyboard:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    Keyboard:SetMovable(true)

    addon.keyboardFrame = Keyboard

    return Keyboard
end

function addon:RefreshControls()
    if KBControlsFrame then
        KBControlsFrame.LayoutName:SetText(KeyBindSettings.currentboard)
    end
end

function addon:CreateControls()
    local Controls = CreateFrame("Frame", 'KBControlsFrame', KeyUIMainFrame, "TooltipBorderedFrameTemplate")
    tinsert(UISpecialFrames, "KBControlsFrame")
    local Keyboard = addon.keyboardFrame
    local modif = self.modif
    Controls:SetBackdropColor(0, 0, 0, 1)
    Controls:SetPoint("BOTTOM", Keyboard, "TOP", 0, -2)

    Controls.LayoutName = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Controls.LayoutName:SetText(KeyBindSettings.currentboard)
    Controls.LayoutName:SetPoint("CENTER", Controls)
    Controls.LayoutName:SetTextColor(1, 1, 1)
    Controls.LayoutName:SetAlpha(0.75)
    Controls.LayoutName:Show()
 
    local function SetCheckboxTooltip(checkbox, tooltipText)
        checkbox.tooltipText = tooltipText
        checkbox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText)
            GameTooltip:Show()
        end)
        checkbox:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    local function OnMaximize()
        maximizeFlag = true

        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            KBControlsFrame:SetHeight(80)  
        else
            KBControlsFrame:SetHeight(210)
        end
        Controls:SetWidth(Keyboard:GetWidth())
        
        Controls.Slider = CreateFrame("Slider", "KBControlSlider", Controls, "OptionsSliderTemplate")
        Controls.Slider:SetMinMaxValues(0.5, 1.5)
        Controls.Slider:SetValueStep(0.01)
        Controls.Slider:SetValue(Keyboard:GetScale())
        _G[Controls.Slider:GetName().."Low"]:SetText("0.5")
        _G[Controls.Slider:GetName().."High"]:SetText("1.5")
        Controls.Slider:SetScript("OnValueChanged", function(self)
            Keyboard:SetScale(self:GetValue())
            Controls.EditBox:SetText(string.format("%.2f", self:GetValue()))
        end)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.Slider:SetWidth(370)
        else
            Controls.Slider:SetWidth(340)
        end
        Controls.Slider:SetHeight(24)
        
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.Slider:SetPoint("BOTTOMRIGHT", Controls, "BOTTOMRIGHT", -76, 22)
        else
            Controls.Slider:SetPoint("CENTER", Controls, "CENTER", 0, -20)
        end

        Controls.EditBox = CreateFrame("EditBox", "KUI_EditBox1", Controls, "InputBoxTemplate")
        Controls.EditBox:SetSize(60, 12)
        Controls.EditBox:SetPoint("BOTTOM", Controls.Slider, "TOP", 28, 6)
        Controls.EditBox:SetMaxLetters(4)
        Controls.EditBox:SetAutoFocus(false)
        Controls.EditBox:SetText(string.format("%.2f", Keyboard:GetScale()))
        Controls.EditBox:SetJustifyH("CENTER")
        Controls.EditBox:SetFrameLevel(Controls.Slider:GetFrameLevel() + 1)
            
        -- Add a function to update the slider value when the user types in the edit box
        Controls.EditBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if value then
                if value < 0.5 then
                    value = 0.5
                elseif value > 1 then
                    value = 1
                end
                    Controls.Slider:SetValue(value)
                Keyboard:SetScale(value)
            end
            self:ClearFocus()
        end)

        Controls.AltCB = CreateFrame("CheckButton", "KeyBindAltCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.AltCB:SetSize(32, 36)
        Controls.AltCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.AltCB:SetPoint("BOTTOMLEFT", Controls, "BOTTOMLEFT", 24, 14)
        else
            Controls.AltCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 10, -26)
        end
        -- Create a font string for the text "Alt" and position it below the checkbutton
        local altText = Controls.AltCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        altText:SetText("Alt")
        altText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        altText:SetPoint("BOTTOM", Controls.AltCB, "TOP", 0, 2)
        -- Set the OnClick script for the checkbutton
        Controls.AltCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = "ALT-"
                modif.CTRL = ""
                modif.SHIFT = ""
                AltCheckbox = true
                --print("AltCheckbox = true")
                --print("CtrlCheckbox = false")
                --print("ShiftCheckbox = false")
                Controls.CtrlCB:SetChecked(false)
                Controls.ShiftCB:SetChecked(false)
            else
                modif.ALT = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
                --print("AltCheckbox = false")
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.AltCB, "Toggle Alt key modifier")

        Controls.CtrlCB = CreateFrame("CheckButton", "KeyBindCtrlCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.CtrlCB:SetSize(32, 36)
        Controls.CtrlCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.CtrlCB:SetPoint("BOTTOMLEFT", Controls, "BOTTOMLEFT", 74, 14)
        else
            Controls.CtrlCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 50, -26)
        end
        -- Create a font string for the text "Ctrl" and position it below the checkbutton
        local ctrlText = Controls.CtrlCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        ctrlText:SetText("Ctrl")
        ctrlText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        ctrlText:SetPoint("BOTTOM", Controls.CtrlCB, "TOP", 0, 0)
        -- Set the OnClick script for the checkbutton
        Controls.CtrlCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = ""
                modif.CTRL = "CTRL-"
                modif.SHIFT = ""
                CtrlCheckbox = true
                --print("AltCheckbox = false")
                --print("CtrlCheckbox = true")
                --print("ShiftCheckbox = false")
                Controls.AltCB:SetChecked(false)
                Controls.ShiftCB:SetChecked(false)
            else
                modif.CTRL = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
                --print("CtrlCheckbox = false")
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.CtrlCB, "Toggle Ctrl key modifier")
        
        Controls.ShiftCB = CreateFrame("CheckButton", "KeyBindShiftCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.ShiftCB:SetSize(32, 36)
        Controls.ShiftCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.ShiftCB:SetPoint("BOTTOMLEFT", Controls, "BOTTOMLEFT", 124, 14)
        else
            Controls.ShiftCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 90, -26)
        end
        -- Create a font string for the text "Shift" and position it below the checkbutton
        local shiftText = Controls.ShiftCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        shiftText:SetText("Shift")
        shiftText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        shiftText:SetPoint("BOTTOM", Controls.ShiftCB, "TOP", 0, 0)
        -- Set the OnClick script for the checkbutton
        Controls.ShiftCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = ""
                modif.CTRL = ""
                modif.SHIFT = "SHIFT-"
                ShiftCheckbox = true
                --print("AltCheckbox = false")
                --print("CtrlCheckbox = false")
                --print("ShiftCheckbox = true")
                Controls.AltCB:SetChecked(false)
                Controls.CtrlCB:SetChecked(false)
            else
                modif.SHIFT = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
                --print("ShiftCheckbox = false")
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.ShiftCB, "Toggle Shift key modifier")
        
        Controls.SwitchEmptyBinds = CreateFrame("Button", "SwitchEmptyBinds", Controls, "UIPanelButtonTemplate")
        Controls.SwitchEmptyBinds:SetSize(146, 26)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.SwitchEmptyBinds:SetPoint("LEFT", Controls.ShiftCB, "RIGHT", 16, 0)
        else
            Controls.SwitchEmptyBinds:SetPoint("LEFT", Controls.ShiftCB, "RIGHT", 28, -2)
        end

        local SwitchBindsText = Controls.SwitchEmptyBinds:CreateFontString(nil, "OVERLAY")
        SwitchBindsText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
        SwitchBindsText:SetPoint("CENTER", 0, 1)

        if ShowEmptyBinds == true then
            SwitchBindsText:SetText("Hide empty Keys")
        else
            SwitchBindsText:SetText("Show empty Keys")
        end 
        
        local function ToggleEmptyBinds()
            if ShowEmptyBinds ~= true then
                SwitchBindsText:SetText("Hide empty Keys")
                ShowEmptyBinds = true
            else
                SwitchBindsText:SetText("Show empty Keys")
                ShowEmptyBinds = false
            end
            addon:RefreshKeys()
        end
        
        Controls.SwitchEmptyBinds:SetScript("OnClick", ToggleEmptyBinds)
        Controls.SwitchEmptyBinds:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Toggle highlighting of keys without keybinds")
            GameTooltip:Show()
        end)
        Controls.SwitchEmptyBinds:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        Controls.SwitchInterfaceBinds = CreateFrame("Button", "SwitchInterfaceBinds", Controls, "UIPanelButtonTemplate")
        Controls.SwitchInterfaceBinds:SetSize(146, 26)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.SwitchInterfaceBinds:SetPoint("LEFT", Controls.SwitchEmptyBinds, "RIGHT", 6, 0)
        else
            Controls.SwitchInterfaceBinds:SetPoint("BOTTOM", Controls.SwitchEmptyBinds, "TOP", 0, 0)
        end

        local SwitchInterfaceText = Controls.SwitchInterfaceBinds:CreateFontString(nil, "OVERLAY")
        SwitchInterfaceText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
        SwitchInterfaceText:SetPoint("CENTER", 0, 1)

        if ShowInterfaceBinds == true then
            SwitchInterfaceText:SetText("Hide Interface Binds")
        else
            SwitchInterfaceText:SetText("Show Interface Binds")
        end 

        local function ToggleInterfaceBinds()
            if ShowInterfaceBinds ~= true then
                SwitchInterfaceText:SetText("Hide Interface Binds")
                ShowInterfaceBinds = true
            else
                SwitchInterfaceText:SetText("Show Interface Binds")
                ShowInterfaceBinds = false
            end
            addon:RefreshKeys()
        end

        Controls.SwitchInterfaceBinds:SetScript("OnClick", ToggleInterfaceBinds)
        Controls.SwitchInterfaceBinds:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Show/Hide the Interface Action of Keys")
            GameTooltip:Show()
        end)
        Controls.SwitchInterfaceBinds:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        --Controls.Refresh = CreateFrame("Button", "#parentRefresh", Controls, "BigRedRefreshButtonTemplate")
        --Controls.Refresh:SetSize(40, 40)
        --Controls.Refresh:SetPoint("RIGHT", Controls.Layout, "LEFT", 0, 0)
        --Controls.Refresh:SetScript("OnClick", function(s) addon:RefreshKeys() end)

        Controls.Layout = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Layout:SetText("Layout")
        Controls.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.Layout:SetPoint("BOTTOM", KBChangeBoardDD, "TOP", 0, 6)
        else
            Controls.Layout:SetPoint("RIGHT", KBChangeBoardDD, "LEFT", 0, 2)
        end
        Controls.Layout:SetTextColor(1, 1, 1)

        Controls.Display = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Display:SetText("Display Options")
        Controls.Display:SetFont("Fonts\\FRIZQT__.TTF", 14)
        Controls.Display:SetPoint("BOTTOM", Controls.SwitchInterfaceBinds, "TOPLEFT", -2, 6)
        Controls.Display:SetTextColor(1, 1, 1)

        Controls.Size = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Size:SetText("Size")
        Controls.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
        Controls.Size:SetPoint("RIGHT", Controls.EditBox, "LEFT", -10, 0)
        Controls.Size:SetTextColor(1, 1, 1)
        
        Controls.Slider:Show()
        Controls.EditBox:Show()
        Controls.AltCB:Show()
        Controls.CtrlCB:Show()
        Controls.ShiftCB:Show()
        Controls.Layout:Show()
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" then
            Controls.Display:Show()
        else
            Controls.Display:Hide()
        end
        Controls.Size:Show()
        Controls.SwitchEmptyBinds:Show()
        Controls.SwitchInterfaceBinds:Show()
        --Controls.Refresh:Show()
        Controls.LayoutName:Hide() -- REVERSED
        Controls.Layout:Show()

        if KBChangeBoardDD then
            KBChangeBoardDD:Show()
        end

    end
    
    local function OnMinimize()
        maximizeFlag = false
        
        Controls:SetHeight(26)
        Controls:SetWidth(Keyboard:GetWidth())

        if Controls.Slider then
            Controls.Slider:Hide()
            Controls.EditBox:Hide()
            Controls.AltCB:Hide()
            Controls.CtrlCB:Hide()
            Controls.ShiftCB:Hide()
            Controls.Layout:Hide()
            Controls.Display:Hide()
            Controls.Size:Hide()
            Controls.SwitchEmptyBinds:Hide()
            Controls.SwitchInterfaceBinds:Hide()
            --Controls.Refresh:Hide()
            Controls.LayoutName:Show() -- REVERSED
            Controls.Layout:Hide()

            if KBChangeBoardDD then
                KBChangeBoardDD:Hide()
            end
        end
    end    

    Controls.Close = CreateFrame("Button", "$parentClose", Controls, "UIPanelCloseButton")
    Controls.Close:SetSize(42, 42)
    Controls.Close:SetPoint("TOPRIGHT", 8, 8)
    Controls.Close:SetScript("OnClick", function(s) KeyUIMainFrame:Hide() KBControlsFrame:Hide() end) -- Toggle the Keyboard frame show/hide
 
    Controls.MinMax = CreateFrame("Frame", "#parentMinMax", Controls, "MaximizeMinimizeButtonFrameTemplate")
    Controls.MinMax:SetSize(42, 42)
    Controls.MinMax:SetPoint("RIGHT", Controls.Close, "LEFT", 18, 0)
    Controls.MinMax:SetOnMaximizedCallback(OnMaximize)
    Controls.MinMax:SetOnMinimizedCallback(OnMinimize)
    
    Controls.MinMax:Maximize() -- Set the MinMax button & control frame size to Minimize
    Controls.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize

    Controls:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    Controls:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    addon.controlsFrame = KBControlsFrame

    return Controls
end