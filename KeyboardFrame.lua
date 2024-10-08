local name, addon = ...

KeyboardPosition = {}

KeyboardLocked = true
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

local function GetCursorScaledPosition()
	local scale, x, y = UIParent:GetScale(), GetCursorPosition()
	return x / scale, y / scale
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

local function KeyDown(self, key)
    if not KeyboardLocked then
        if key == "RightButton" then
            return
        elseif key == "MiddleButton" then
            self.label:SetText("Button3")
        else
            -- For all other keys, set the label to the key itself
            self.label:SetText(key)
        end
    end
end

local function OnMouseWheel(self, delta)
    if not KeyboardLocked then
        if delta > 0 then
            -- Mouse wheel scrolled up
            self.label:SetText("MouseWheelUp")
        elseif delta < 0 then
            -- Mouse wheel scrolled down
            self.label:SetText("MouseWheelDown")
        end
    end
end

-- SwitchBoard(board) - This function switches the key binding board to display different key bindings.
function addon:SwitchBoard(board)
    -- Clear the existing Keys array to avoid leftover data from previous layouts
    for i = 1, #Keys do
        Keys[i]:Hide()
        Keys[i] = nil
    end
    Keys = {}

    -- Proceed with setting up the new layout

    if KeyBindAllBoards[board] and addonOpen == true and addon.keyboardFrame then
        board = KeyBindAllBoards[board]
        
        addon.keyboardFrame:SetWidth(100)
        addon.keyboardFrame:SetHeight(100)

        local cx, cy = addon.keyboardFrame:GetCenter()
        local left, right, top, bottom = cx, cx, cy, cy

        for i = 1, #board do
            local Key = Keys[i] or self:NewButton()

            if board[i][5] then
                Key:SetWidth(board[i][5])
                Key:SetHeight(board[i][6])
            else
                Key:SetWidth(60)
                Key:SetHeight(60)
            end

            if not Keys[i] then
                Keys[i] = Key
            end

            Key:SetPoint("TOPLEFT", self.keyboardFrame, "TOPLEFT", board[i][3], board[i][4])
            Key.label:SetText(board[i][1])
            local tempframe = Key
            tempframe:Show()

            local l, r, t, b = Key:GetLeft(), Key:GetRight(), Key:GetTop(), Key:GetBottom()

            if l < left then
                left = l
            end
            if r > right then
                right = r
            end
            if t > top then
                top = t
            end
            if b < bottom then
                bottom = b
            end
        end

        self.keyboardFrame:SetWidth(right - left + 12)
        self.keyboardFrame:SetHeight(top - bottom + 12)
        KBControlsFrame:SetWidth(self.keyboardFrame:GetWidth())

    end
end

-- Create a new button on the given parent frame or default to the main keyboard frame.
function addon:NewButton(parent)
    if not parent then
        parent = self.keyboardFrame
    end

    -- Create a frame that acts as a button with a tooltip border.
    local button = CreateFrame("FRAME", nil, parent, "TooltipBorderedFrameTemplate")
    button:EnableMouse(true)
    button:EnableKeyboard(true)
    button:SetBackdropColor(0, 0, 0, 1)

    -- Create a label to display the full name of the action.
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.label:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    button.label:SetTextColor(1, 1, 1, 0.9)
    button.label:SetHeight(50)
    button.label:SetWidth(100)
    button.label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -4, -6)
    button.label:SetJustifyH("RIGHT")
    button.label:SetJustifyV("TOP")

    -- Create a shorter label, possibly for abbreviations or shorter texts.
    button.ShortLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.ShortLabel:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    button.ShortLabel:SetTextColor(1, 1, 1, 0.9)
    button.ShortLabel:SetHeight(50)
    button.ShortLabel:SetWidth(100)
    button.ShortLabel:SetPoint("TOPRIGHT", button, "TOPRIGHT", -4, -6)
    button.ShortLabel:SetJustifyH("RIGHT")
    button.ShortLabel:SetJustifyV("TOP")

    -- Hidden font string to store the macro text.
    button.macro = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.macro:SetText("")
    button.macro:Hide()

    -- Font string to display the interface action text.
    button.interfaceaction = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    button.interfaceaction:SetTextColor(1, 1, 1)
    button.interfaceaction:SetHeight(58)
    button.interfaceaction:SetWidth(58)
    button.interfaceaction:SetPoint("CENTER", button, "CENTER", 0, -6)
    button.interfaceaction:SetText("")

    -- Icon texture for the button.
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(50, 50)
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)

    -- Define the mouse hover behavior to show tooltips.
    button:SetScript("OnEnter", function()
        addon:ButtonMouseOver(button)
        button:EnableKeyboard(true)
        button:EnableMouseWheel(true)
        button:SetScript("OnKeyDown", KeyDown)
        button:SetScript("OnMouseWheel", OnMouseWheel)
    
        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()
    
        if KeyUI_Settings.showPushedTexture then
            -- Only proceed if button.slot is valid
            if button.slot then
                -- Adjust the slot mapping based on the current action bar page
                local adjustedSlot = button.slot
    
                if currentActionBarPage == 3 and button.slot >= 25 and button.slot <= 36 then
                    adjustedSlot = button.slot - 24  -- Map to ActionButton1-12
                elseif currentActionBarPage == 4 and button.slot >= 37 and button.slot <= 48 then
                    adjustedSlot = button.slot - 36  -- Map to ActionButton1-12
                elseif currentActionBarPage == 5 and button.slot >= 49 and button.slot <= 60 then
                    adjustedSlot = button.slot - 48  -- Map to ActionButton1-12
                elseif currentActionBarPage == 6 and button.slot >= 61 and button.slot <= 72 then
                    adjustedSlot = button.slot - 60  -- Map to ActionButton1-12
                end
    
                -- Look up the correct button in TextureMappings using the adjusted slot number
                local mappedButton = TextureMappings[tostring(adjustedSlot)]
                if mappedButton then
                    local normalTexture = mappedButton:GetNormalTexture()
                    if normalTexture and normalTexture:IsVisible() then
                        local pushedTexture = mappedButton:GetPushedTexture()
                        if pushedTexture then
                            pushedTexture:Show()  -- Show the pushed texture
                        end
                    end
                end
            end
        end
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        KeyUITooltip:Hide()
        button:EnableKeyboard(false)
        button:EnableMouseWheel(false)
        button:SetScript("OnKeyDown", nil)
    
        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()
    
        if KeyUI_Settings.showPushedTexture then
            -- Only proceed if button.slot is valid
            if button.slot then
                local adjustedSlot = button.slot
    
                if currentActionBarPage == 3 and button.slot >= 25 and button.slot <= 36 then
                    adjustedSlot = button.slot - 24
                elseif currentActionBarPage == 4 and button.slot >= 37 and button.slot <= 48 then
                    adjustedSlot = button.slot - 36
                elseif currentActionBarPage == 5 and button.slot >= 49 and button.slot <= 60 then
                    adjustedSlot = button.slot - 48
                elseif currentActionBarPage == 6 and button.slot >= 61 and button.slot <= 72 then
                    adjustedSlot = button.slot - 60
                end
    
                local mappedButton = TextureMappings[tostring(adjustedSlot)]
                if mappedButton then
                    local pushedTexture = mappedButton:GetPushedTexture()
                    if pushedTexture then
                        pushedTexture:Hide()  -- Hide the pushed texture
                    end
                end
            end
        end
    end)

    -- Define behavior for mouse down actions (left-click).
    button:SetScript("OnMouseDown", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            if KeyboardLocked == false then
                return
            else
                addon.currentKey = self
                local key = addon.currentKey.macro:GetText()

                -- Define class and bonus bar offset and action bar page
                local classFilename = UnitClassBase("player")
                local bonusBarOffset = GetBonusBarOffset()
                local currentActionBarPage = GetActionBarPage()

                -- Check if 'key' is non-nil and non-empty before proceeding.
                if key and key ~= "" then
                    local actionSlot = SlotMappings[key]
                    if actionSlot then
                        -- Adjust action slot based on current action bar page
                        local adjustedSlot = tonumber(actionSlot)

                        -- Handle bonus bar offsets for ROGUE and DRUID
                        if (classFilename == "ROGUE" or classFilename == "DRUID") and bonusBarOffset ~= 0 and currentActionBarPage == 1 then
                            if bonusBarOffset == 1 then
                                adjustedSlot = adjustedSlot + 72 -- Maps to 73-84
                            elseif bonusBarOffset == 2 then
                                adjustedSlot = adjustedSlot -- No change for offset 2
                            elseif bonusBarOffset == 3 then
                                adjustedSlot = adjustedSlot + 96 -- Maps to 97-108
                            elseif bonusBarOffset == 4 then
                                adjustedSlot = adjustedSlot + 108 -- Maps to 109-120
                            elseif bonusBarOffset == 5 then
                                adjustedSlot = adjustedSlot -- No change for offset 5
                            end
                        end

                        -- Adjust based on current action bar page
                        if currentActionBarPage == 2 then
                            adjustedSlot = adjustedSlot + 12 -- For ActionBarPage 2, adjust slots by +12 (13-24)
                        elseif currentActionBarPage == 3 then
                            adjustedSlot = adjustedSlot + 24 -- For ActionBarPage 3, adjust slots by +24 (25-36)
                        elseif currentActionBarPage == 4 then
                            adjustedSlot = adjustedSlot + 36 -- For ActionBarPage 4, adjust slots by +36 (37-48)
                        elseif currentActionBarPage == 5 then
                            adjustedSlot = adjustedSlot + 48 -- For ActionBarPage 5, adjust slots by +48 (49-60)
                        elseif currentActionBarPage == 6 then
                            adjustedSlot = adjustedSlot + 60 -- For ActionBarPage 6, adjust slots by +60 (61-72)
                        end

                        -- Ensure adjustedSlot is valid before picking up
                        if adjustedSlot >= 1 and adjustedSlot <= 120 then  -- Adjust the upper limit as necessary
                            PickupAction(adjustedSlot)
                            --print(adjustedSlot)  -- Debug print to check if the slot is correctly adjusted
                            addon:RefreshKeys()
                        else
                            -- Optionally handle cases where the adjusted slot is out of range
                            PickupAction(actionSlot)
                            addon:RefreshKeys()
                        end
                    elseif button.petActionIndex then
                        -- Pickup a pet action
                        print("KeyUI: Due to limitations in the Blizzard API, pet actions cannot placed by addons. Please drag them manually.")
                        return
                    elseif button.spellid then
                        print("KeyUI: Due to limitations in the Blizzard API, pet actions cannot placed by addons. Please drag them manually.")
                        -- Pickup a pet spell
                        return
                    elseif string.match(key, "^ELVUIBAR%d+BUTTON%d+$") then
                        -- Handle ElvUI Buttons
                        local barIndex, buttonIndex = string.match(key, "^ELVUIBAR(%d+)BUTTON(%d+)$")
                        local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
                        if elvUIButton and elvUIButton._state_action then
                            PickupAction(elvUIButton._state_action)
                            addon:RefreshKeys()
                        end
                    end
                end
            end
        else
            KeyDown(self, Mousebutton)
        end
    end)

    -- Define behavior for mouse up actions (left-click and right-click).
    button:SetScript("OnMouseUp", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            local infoType, info1, info2 = GetCursorInfo()

            -- Debug output to check values (optional)
            --print("infoType:", infoType)
            --print("info1 (expected spellbook slot):", info1)
            --print("info2 (expected spellbook type):", info2)

            if infoType == "spell" then
                local slotIndex = tonumber(info1)

                -- Determine the correct spell book type based on info2.
                local spellBookType
                if info2 == "spell" then
                    spellBookType = Enum.SpellBookSpellBank.Player  -- Default to player spells.
                elseif info2 == "pet" then
                    spellBookType = Enum.SpellBookSpellBank.Pet     -- For pet spells.
                else
                    --print("Unknown spell book type:", info2)
                    return
                end

                -- Ensure slotIndex is valid before using it.
                if slotIndex then
                    local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, spellBookType)

                    -- Check if spellBookItemInfo is valid before accessing its properties.
                    if spellBookItemInfo then
                        local spellname = spellBookItemInfo.name
                        addon.currentKey = self
                        local key = addon.currentKey.macro:GetText()
                        if key and key ~= "" then
                            local actionSlot = SlotMappings[key]
                            if actionSlot then
                                PlaceAction(actionSlot)
                                ClearCursor()
                                addon:RefreshKeys()
                            elseif string.match(key, "^ELVUIBAR%d+BUTTON%d+$") then
                                -- Handle ElvUI Buttons.
                                local barIndex, buttonIndex = string.match(key, "^ELVUIBAR(%d+)BUTTON(%d+)$")
                                local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
                                if elvUIButton and elvUIButton._state_action then
                                    PlaceAction(elvUIButton._state_action)
                                    ClearCursor()
                                    addon:RefreshKeys()
                                end
                            end
                        else
                            -- Handle the case where the key is nil or empty
                            --print("No valid macro text found for the button.")
                        end
                    else
                        --print("spellBookItemInfo is nil")
                    end
                else
                    --print("Invalid slotIndex:", slotIndex)
                end
            end
        elseif Mousebutton == "RightButton" then
            addon.currentKey = self
            ToggleDropDownMenu(1, nil, KBDropDown, self, 30, 20)
        end
    end)

    return button
end

function addon:CreateChangerDD() 
    local KBChangeBoardDD = CreateFrame("Frame", "KBChangeBoardDD", KBControlsFrame, "UIDropDownMenuTemplate")

    KBChangeBoardDD:SetPoint("BOTTOM", KBControlsFrame, "BOTTOM", 0, 14)
    UIDropDownMenu_SetWidth(KBChangeBoardDD, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDD, 120)
    KBChangeBoardDD:Hide()

    local boardCategories = {
        QWERTZ = {"QWERTZ_PRIMARY", "QWERTZ_HALF", "QWERTZ_1800", "QWERTZ_60%", "QWERTZ_75%", "QWERTZ_80%", "QWERTZ_96%", "QWERTZ_100%"},
        QWERTY = {"QWERTY_PRIMARY", "QWERTY_HALF", "QWERTY_1800", "QWERTY_60%", "QWERTY_75%", "QWERTY_80%", "QWERTY_96%", "QWERTY_100%"},
        AZERTY = {"AZERTY_PRIMARY", "AZERTY_HALF", "AZERTY_1800", "AZERTY_60%", "AZERTY_75%", "AZERTY_80%", "AZERTY_96%", "AZERTY_100%"},
        DVORAK = {
            Standard = {"DVORAK_PRIMARY", "DVORAK_100%"},
            RightHand = {"DVORAK_RIGHT_PRIMARY", "DVORAK_RIGHT_100%"},
            LeftHand = {"DVORAK_LEFT_PRIMARY", "DVORAK_LEFT_100%"}
        },
        Razer = {"Razer_Tartarus", "Razer_Tartarus2"},
        Azeron = {"Azeron", "Azeron2"}
    }

    local categoryOrder = {"QWERTZ", "QWERTY", "AZERTY", "DVORAK", "Razer", "Azeron"}

    local function ChangeBoardDD_Initialize(self, level, menuList)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
    
        if level == 1 then
            for _, category in ipairs(categoryOrder) do 
                info.text = category
                info.value = category
                info.hasArrow = true
                info.notCheckable = true
                info.menuList = category
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 then
            if menuList == "DVORAK" then
                for subcategory, _ in pairs(boardCategories.DVORAK) do
                    info.text = subcategory
                    info.value = subcategory
                    info.hasArrow = true
                    info.notCheckable = true
                    info.menuList = subcategory
                    UIDropDownMenu_AddButton(info, level)
                end
            else
                local layouts = boardCategories[menuList]
                if layouts then
                    for _, name in ipairs(layouts) do
                        info.text = name
                        info.value = name
                        info.func = function()
                            KeyBindSettings.currentboard = name
                            addon:RefreshKeys()
                            UIDropDownMenu_SetText(KBChangeBoardDD, name)
                            if maximizeFlag == true then
                                KBControlsFrame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
                            else
                                return
                            end
                        end
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        elseif level == 3 then
            local layouts = boardCategories.DVORAK[menuList]
            if layouts then
                for _, name in ipairs(layouts) do
                    info.text = name
                    info.value = name
                    info.func = function()
                        KeyBindSettings.currentboard = name
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(KBChangeBoardDD, name)
                        if maximizeFlag == true then
                            KBControlsFrame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
                        else
                            return
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end

    UIDropDownMenu_Initialize(KBChangeBoardDD, ChangeBoardDD_Initialize)
    self.ddChanger = KBChangeBoardDD
    return KBChangeBoardDD
end