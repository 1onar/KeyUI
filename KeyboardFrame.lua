local name, addon = ...

KeyboardPosition = {}

AltCheckbox = false
CtrlCheckbox = false
ShiftCheckbox = false

-- Initialize tutorialCompleted if it doesn't exist
if tutorialCompleted == nil then
    tutorialCompleted = false
end

function addon:SaveKeyboard()
    KeyboardPosition.x, KeyboardPosition.y = KeyUIMainFrame:GetCenter()
    KeyboardPosition.scale = KeyUIMainFrame:GetScale()
end

function addon:CreateKeyboard()
    local Keyboard = CreateFrame("Frame", 'KeyUIMainFrame', UIParent, "TooltipBorderedFrameTemplate") -- the frame holding the keys
 
    -- Manage ESC key behavior based on the setting
    if KeyUI_Settings.preventEscClose ~= false then
        tinsert(UISpecialFrames, "KeyUIMainFrame")
    end

    Keyboard:SetWidth(1100)
    Keyboard:SetHeight(500)
    Keyboard:SetBackdropColor(0, 0, 0, 0.9)

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

    local Keyboard = addon.keyboardFrame
    local modif = self.modif

    -- Manage ESC key behavior based on the setting
    if KeyUI_Settings.preventEscClose ~= false then
        tinsert(UISpecialFrames, "KBControlsFrame")
    end

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

        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            KBControlsFrame:SetHeight(80)  
        else
            KBControlsFrame:SetHeight(210)
        end
        Controls:SetWidth(Keyboard:GetWidth())
        
        Controls.Layout = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Layout:SetText("Layout")
        Controls.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.Layout:SetPoint("BOTTOM", KBChangeBoardDD, "CENTER", 0, 22)
        else
            Controls.Layout:SetPoint("RIGHT", KBChangeBoardDD, "LEFT", -10, 2)
        end
        Controls.Layout:SetTextColor(1, 1, 1)

    --Size start
        Controls.EditBox = CreateFrame("EditBox", "KUI_EditBox1", Controls, "InputBoxTemplate")
        Controls.EditBox:SetWidth(60)
        Controls.EditBox:SetHeight(20)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.EditBox:SetPoint("CENTER", KBChangeBoardDD, "CENTER", 176, 2)
        else
            Controls.EditBox:SetPoint("BOTTOM", KBChangeBoardDD, "TOP", 0, 20)
        end
        Controls.EditBox:SetMaxLetters(4)
        Controls.EditBox:SetAutoFocus(false)
        Controls.EditBox:SetText(string.format("%.2f", Keyboard:GetScale()))
        Controls.EditBox:SetJustifyH("CENTER")
        
        -- Add a function to update the scale when the user types in the edit box
        Controls.EditBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if value then
                if value < 0.5 then
                    value = 0.5
                elseif value > 1.5 then
                    value = 1.5
                end
                Keyboard:SetScale(value)
                self:SetText(string.format("%.2f", value))
            end
            self:ClearFocus()
        end)

        Controls.LeftButton = CreateFrame("Button", "KBControlLeftButton", Controls)
        Controls.LeftButton:SetSize(32, 32)
        Controls.LeftButton:SetPoint("CENTER", Controls.EditBox, "CENTER", -58, 0)
        Controls.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        Controls.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        Controls.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        Controls.RightButton = CreateFrame("Button", "KBControlRightButton", Controls)
        Controls.RightButton:SetSize(32, 32)
        Controls.RightButton:SetPoint("CENTER", Controls.EditBox, "CENTER", 54, 0)
        Controls.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        Controls.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        Controls.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        
        Controls.LeftButton:SetScript("OnClick", function()
            local currentValue = Keyboard:GetScale()
            local step = 0.05
            local newValue = currentValue - step
            if newValue < 0.5 then
                newValue = 0.5
            end
            Keyboard:SetScale(newValue)
            Controls.EditBox:SetText(string.format("%.2f", newValue))
        end)
        
        Controls.RightButton:SetScript("OnClick", function()
            local currentValue = Keyboard:GetScale()
            local step = 0.05
            local newValue = currentValue + step
            if newValue > 1.5 then
                newValue = 1.5
            end
            Keyboard:SetScale(newValue)
            Controls.EditBox:SetText(string.format("%.2f", newValue))
        end)

        Controls.Size = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Size:SetText("Size")
        Controls.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.Size:SetPoint("BOTTOM", Controls.EditBox, "CENTER", 0, 20)
        else
            Controls.Size:SetPoint("TOPLEFT", Controls.Layout, "TOPLEFT", 0, 44)
        end
        Controls.Size:SetTextColor(1, 1, 1)
    --Size end
    
    --Modifier start
        Controls.AltCB = CreateFrame("CheckButton", "KeyBindAltCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.AltCB:SetSize(32, 36)
        Controls.AltCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.AltCB:SetPoint("CENTER", KBChangeBoardDD, "CENTER", 290, 2)
        else
            Controls.AltCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 10, -50)
        end
        -- Create a font string for the text "Alt" and position it below the checkbutton
        local altText = Controls.AltCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        altText:SetText("Alt")
        altText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        altText:SetPoint("BOTTOM", Controls.AltCB, "CENTER", 0, 20)
        -- Set the OnClick script for the checkbutton
        Controls.AltCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = "ALT-"
                modif.CTRL = ""
                modif.SHIFT = ""
                AltCheckbox = true
                Controls.CtrlCB:SetChecked(false)
                Controls.ShiftCB:SetChecked(false)
            else
                modif.ALT = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.AltCB, "Toggle Alt key modifier")

        Controls.CtrlCB = CreateFrame("CheckButton", "KeyBindCtrlCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.CtrlCB:SetSize(32, 36)
        Controls.CtrlCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.CtrlCB:SetPoint("CENTER", Controls.AltCB, "CENTER", 50, 0)
        else
            Controls.CtrlCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 50, -50)
        end
        -- Create a font string for the text "Ctrl" and position it below the checkbutton
        local ctrlText = Controls.CtrlCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        ctrlText:SetText("Ctrl")
        ctrlText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        ctrlText:SetPoint("BOTTOM", Controls.CtrlCB, "CENTER", 0, 20)
        -- Set the OnClick script for the checkbutton
        Controls.CtrlCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = ""
                modif.CTRL = "CTRL-"
                modif.SHIFT = ""
                CtrlCheckbox = true
                Controls.AltCB:SetChecked(false)
                Controls.ShiftCB:SetChecked(false)
            else
                modif.CTRL = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.CtrlCB, "Toggle Ctrl key modifier")
        
        Controls.ShiftCB = CreateFrame("CheckButton", "KeyBindShiftCB", Controls, "ChatConfigCheckButtonTemplate")
        Controls.ShiftCB:SetSize(32, 36)
        Controls.ShiftCB:SetHitRectInsets(0, 0, 0, -10)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.ShiftCB:SetPoint("CENTER", Controls.CtrlCB, "CENTER", 50, 0)
        else
            Controls.ShiftCB:SetPoint("TOPLEFT", Controls, "TOPLEFT", 90, -50)
        end
        -- Create a font string for the text "Shift" and position it below the checkbutton
        local shiftText = Controls.ShiftCB:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        shiftText:SetText("Shift")
        shiftText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        shiftText:SetPoint("BOTTOM", Controls.ShiftCB, "CENTER", 0, 20)
        -- Set the OnClick script for the checkbutton
        Controls.ShiftCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                modif.ALT = ""
                modif.CTRL = ""
                modif.SHIFT = "SHIFT-"
                ShiftCheckbox = true
                Controls.AltCB:SetChecked(false)
                Controls.CtrlCB:SetChecked(false)
            else
                modif.SHIFT = ""
                AltCheckbox = false
                CtrlCheckbox = false
                ShiftCheckbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(Controls.ShiftCB, "Toggle Shift key modifier")
    --Modifier end
        
    --Buttons start
        Controls.SwitchEmptyBinds = CreateFrame("Button", "SwitchEmptyBinds", Controls, "UIPanelButtonTemplate")
        Controls.SwitchEmptyBinds:SetSize(146, 26)
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.SwitchEmptyBinds:SetPoint("CENTER", KBChangeBoardDD, "CENTER", -200, 2)
        else
            Controls.SwitchEmptyBinds:SetPoint("LEFT", Controls.ShiftCB, "RIGHT", 28, -2)
        end

        local SwitchBindsText = Controls.SwitchEmptyBinds:CreateFontString(nil, "OVERLAY")
        SwitchBindsText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
        SwitchBindsText:SetPoint("CENTER", 0, 0)

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
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.SwitchInterfaceBinds:SetPoint("RIGHT", Controls.SwitchEmptyBinds, "LEFT", -6, 0)
        else
            Controls.SwitchInterfaceBinds:SetPoint("BOTTOM", Controls.SwitchEmptyBinds, "TOP", 0, 0)
        end

        local SwitchInterfaceText = Controls.SwitchInterfaceBinds:CreateFontString(nil, "OVERLAY")
        SwitchInterfaceText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
        SwitchInterfaceText:SetPoint("CENTER", 0, 0)

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

        Controls.Display = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Display:SetText("Display Options")
        Controls.Display:SetFont("Fonts\\FRIZQT__.TTF", 14)
        Controls.Display:SetPoint("BOTTOM", Controls.SwitchInterfaceBinds, "RIGHT", 2, 20)
        Controls.Display:SetTextColor(1, 1, 1)

    --Buttons end

        if KBChangeBoardDD then
            KBChangeBoardDD:Show()
        end

        Controls.EditBox:Show()
        Controls.LeftButton:Show()
        Controls.RightButton:Show()

        Controls.AltCB:Show()
        Controls.CtrlCB:Show()
        Controls.ShiftCB:Show()

        Controls.SwitchEmptyBinds:Show()
        Controls.SwitchInterfaceBinds:Show()
        if KeyBindSettings.currentboard ~= "Razer_Tartarus" and KeyBindSettings.currentboard ~= "Razer_Tartarus2" and KeyBindSettings.currentboard ~= "Azeron" and KeyBindSettings.currentboard ~= "Azeron2" and KeyBindSettings.currentboard ~= "QWERTZ_HALF" and KeyBindSettings.currentboard ~= "QWERTY_HALF" and KeyBindSettings.currentboard ~= "AZERTY_HALF" and KeyBindSettings.currentboard ~= "DVORAK_HALF" then
            Controls.Display:Show()
        else
            Controls.Display:Hide()
        end

        Controls.LayoutName:Hide() -- REVERSED
    end
    
    local function OnMinimize()
        maximizeFlag = false
        
        Controls:SetHeight(26)
        Controls:SetWidth(Keyboard:GetWidth())

        if Controls.EditBox then
            if KBChangeBoardDD then
                KBChangeBoardDD:Hide()
            end
            Controls.Layout:Hide()

            Controls.EditBox:Hide()
            Controls.LeftButton:Hide()
            Controls.RightButton:Hide()
            Controls.Size:Hide()

            Controls.AltCB:Hide()
            Controls.CtrlCB:Hide()
            Controls.ShiftCB:Hide()


            Controls.SwitchEmptyBinds:Hide()
            Controls.SwitchInterfaceBinds:Hide()
            Controls.Display:Hide()

            Controls.LayoutName:Show() -- REVERSED
        end
    end

    Controls.Close = CreateFrame("Button", "$parentClose", Controls, "UIPanelCloseButton")
    Controls.Close:SetSize(26, 26)
    Controls.Close:SetPoint("TOPRIGHT", 0, 0)
    Controls.Close:SetScript("OnClick", function(s) KeyUIMainFrame:Hide() KBControlsFrame:Hide() end) -- Toggle the Keyboard frame show/hide
 
    Controls.MinMax = CreateFrame("Frame", "#parentMinMax", Controls, "MaximizeMinimizeButtonFrameTemplate")
    Controls.MinMax:SetSize(26, 26)
    Controls.MinMax:SetPoint("RIGHT", Controls.Close, "LEFT", 2, 0)
    Controls.MinMax:SetOnMaximizedCallback(OnMaximize)
    Controls.MinMax:SetOnMinimizedCallback(OnMinimize)
    
    Controls.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
    Controls.MinMax:SetMaximizedLook() -- Set the MinMax button & control frame size to Minimize

    -- Show tutorial if not completed
    if not tutorialCompleted then
        ShowGlowAroundMinMax(Controls)
    end

    Controls:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    Controls:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    addon.controlsFrame = KBControlsFrame

    return Controls
end

-- Function to create a glowing tutorial highlight around the MinMax button
function ShowGlowAroundMinMax(Controls)
    local glowFrame = CreateFrame("Frame", "OVERLAY", Controls.MinMax, "GlowBoxTemplate")
    glowFrame:SetPoint("TOPLEFT", -1, 1)
    glowFrame:SetPoint("BOTTOMRIGHT", 1, 0)
    glowFrame.Text = glowFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    glowFrame.Text:SetPoint("BOTTOM", glowFrame, "TOP", 0, 10)
    glowFrame.Text:SetText("Click here to open settings")
    glowFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    glowFrame.Text:SetTextColor(1, 1, 0)

    -- Attach to the MinimizeButton and MaximizeButton individually
    local MinimizeButton = Controls.MinMax.MinimizeButton
    local MaximizeButton = Controls.MinMax.MaximizeButton

    -- Hook the click event for the MinimizeButton and MaximizeButton
    if MinimizeButton then
        MinimizeButton:HookScript("OnClick", function()
            if glowFrame then
                glowFrame:Hide()
                tutorialCompleted = true -- Mark the tutorial as completed
            end
        end)
    end

    if MaximizeButton then
        MaximizeButton:HookScript("OnClick", function()
            if glowFrame then
                glowFrame:Hide()
                tutorialCompleted = true -- Mark the tutorial as completed
            end
        end)
    end
end
