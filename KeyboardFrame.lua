local name, addon = ...

-- Function to save the keyboard's position and scale
function addon:SaveKeyboard()
    local x, y = KeyUIMainFrame:GetCenter()
    KeyUI_Settings.keyboard_position.x = x
    KeyUI_Settings.keyboard_position.y = y
    KeyUI_Settings.keyboard_position.scale = KeyUIMainFrame:GetScale()
end

function addon:CreateKeyboard()
    local Keyboard = CreateFrame("Frame", 'KeyUIMainFrame', UIParent, "TooltipBorderedFrameTemplate") -- the frame holding the keys
 
    -- Manage ESC key behavior based on the setting
    if KeyUI_Settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "KeyUIMainFrame")
    end

    Keyboard:SetHeight(382)
    Keyboard:SetWidth(940)
    Keyboard:SetBackdropColor(0, 0, 0, 0.9)

    -- Load the saved position if it exists
    if KeyUI_Settings.keyboard_position.x and KeyUI_Settings.keyboard_position.y then
        Keyboard:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            KeyUI_Settings.keyboard_position.x,
            KeyUI_Settings.keyboard_position.y
        )
        Keyboard:SetScale(KeyUI_Settings.keyboard_position.scale)
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

local function GetCursorScaledPosition()
	local scale, x, y = UIParent:GetScale(), GetCursorPosition()
	return x / scale, y / scale
end

function addon:CreateControls()
    local Controls = CreateFrame("Frame", 'KBControlsFrame', KeyUIMainFrame, "TooltipBorderedFrameTemplate")

    local Keyboard = addon.keyboardFrame
    local modif = self.modif

    -- Manage ESC key behavior based on the setting
    if KeyUI_Settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "KBControlsFrame")
    end

    Controls:SetBackdropColor(0, 0, 0, 1)
    Controls:SetPoint("BOTTOMRIGHT", Keyboard, "TOPRIGHT", 0, -2)
 
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

        Controls:SetHeight(260)
        Controls:SetWidth(500)

        -- Calculate 1/3 and 2/3 of the width of KBControlsFrame
        local offsetOneThird = Controls:GetWidth() * (1/3)
        local offsetTwoThirds = Controls:GetWidth() * (2/3)

        -- Text "Layout"
        Controls.Layout = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Controls.Layout:SetText("Layout")
        Controls.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
        Controls.Layout:SetPoint("CENTER", KBControlsFrame, "LEFT", 380, 25)
        Controls.Layout:SetTextColor(1, 1, 1)

        --Size

            Controls.Size = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            Controls.Size:SetText("Size")
            Controls.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
            Controls.Size:SetPoint("CENTER", KBControlsFrame, "LEFT", offsetOneThird, 25)
            Controls.Size:SetTextColor(1, 1, 1)

            Controls.EditBox = CreateFrame("EditBox", "KeyboardEditInput", Controls, "InputBoxTemplate")
            Controls.EditBox:SetWidth(60)
            Controls.EditBox:SetHeight(20)
            Controls.EditBox:SetPoint("CENTER", Controls.Size, "CENTER", 0, -29)
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
            Controls.LeftButton:SetSize(26, 26)
            Controls.LeftButton:SetPoint("CENTER", Controls.EditBox, "CENTER", -58, 0)
            Controls.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
            Controls.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
            Controls.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

            Controls.RightButton = CreateFrame("Button", "KBControlRightButton", Controls)
            Controls.RightButton:SetSize(26, 26)
            Controls.RightButton:SetPoint("CENTER", Controls.EditBox, "CENTER", 54, 0)
            Controls.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
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

        --Size
      
        --Buttons

            Controls.Display = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            Controls.Display:SetText("Display Options")
            Controls.Display:SetFont("Fonts\\FRIZQT__.TTF", 14)
            Controls.Display:SetPoint("CENTER", KBControlsFrame, "BOTTOMLEFT", offsetOneThird, 60)
            Controls.Display:SetTextColor(1, 1, 1)

            Controls.SwitchEmptyBinds = CreateFrame("Button", "SwitchEmptyBinds", Controls, "UIPanelButtonTemplate")
            Controls.SwitchEmptyBinds:SetSize(150, 26)
            Controls.SwitchEmptyBinds:SetPoint("LEFT", Controls.Display, "CENTER", 4, -30)

            local SwitchBindsText = Controls.SwitchEmptyBinds:CreateFontString(nil, "OVERLAY")
            SwitchBindsText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            SwitchBindsText:SetPoint("CENTER", 0, 0)

            -- Check the state of show_empty_binds in KeyUI_Settings
            if KeyUI_Settings.show_empty_binds == true then
                SwitchBindsText:SetText("Hide empty Keys")
            else
                SwitchBindsText:SetText("Show empty Keys")
            end 

            -- Function to toggle the empty binds setting
            local function ToggleEmptyBinds()
                if KeyUI_Settings.show_empty_binds ~= true then
                    SwitchBindsText:SetText("Hide empty Keys")
                    KeyUI_Settings.show_empty_binds = true
                else
                    SwitchBindsText:SetText("Show empty Keys")
                    KeyUI_Settings.show_empty_binds = false
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
            Controls.SwitchInterfaceBinds:SetSize(150, 26)
            Controls.SwitchInterfaceBinds:SetPoint("RIGHT", Controls.Display, "CENTER", -4, -30)

            local SwitchInterfaceText = Controls.SwitchInterfaceBinds:CreateFontString(nil, "OVERLAY")
            SwitchInterfaceText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            SwitchInterfaceText:SetPoint("CENTER", 0, 0)

            -- Handle showing/hiding interface binds
            if KeyUI_Settings.show_interface_binds then
                SwitchInterfaceText:SetText("Hide Interface Binds")
            else
                SwitchInterfaceText:SetText("Show Interface Binds")
            end

            -- Function to toggle interface binds visibility
            local function ToggleInterfaceBinds()
                if not KeyUI_Settings.show_interface_binds then
                    SwitchInterfaceText:SetText("Hide Interface Binds")
                    KeyUI_Settings.show_interface_binds = true
                else
                    SwitchInterfaceText:SetText("Show Interface Binds")
                    KeyUI_Settings.show_interface_binds = false
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

        --Buttons

        --Modifier

            --alt
                -- Create a font string for the text "Alt" and position it below the checkbutton
                Controls.AltText = Controls:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                Controls.AltText:SetText("Alt")
                Controls.AltText:SetFont("Fonts\\FRIZQT__.TTF", 14)
                Controls.AltText:SetPoint("CENTER", Controls.Display, "CENTER", 192, 0)

                Controls.AltCB = CreateFrame("CheckButton", "KeyBindAltCB", Controls, "ChatConfigCheckButtonTemplate")
                Controls.AltCB:SetSize(32, 36)
                Controls.AltCB:SetHitRectInsets(0, 0, 0, -10)
                Controls.AltCB:SetPoint("CENTER", Controls.AltText, "CENTER", 0, -30)

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
            --alt
            
            --ctrl
                -- Create a font string for the text "Ctrl" and position it below the checkbutton
                Controls.CtrlText = Controls:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                Controls.CtrlText:SetText("Ctrl")
                Controls.CtrlText:SetFont("Fonts\\FRIZQT__.TTF", 14)
                Controls.CtrlText:SetPoint("CENTER", Controls.AltText, "CENTER", 50, 0)

                Controls.CtrlCB = CreateFrame("CheckButton", "KeyBindCtrlCB", Controls, "ChatConfigCheckButtonTemplate")
                Controls.CtrlCB:SetSize(32, 36)
                Controls.CtrlCB:SetHitRectInsets(0, 0, 0, -10)
                Controls.CtrlCB:SetPoint("CENTER", Controls.CtrlText, "CENTER", 0, -30)

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
            --ctrl

            --shift
                -- Create a font string for the text "Shift" and position it below the checkbutton
                Controls.ShiftText = Controls:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                Controls.ShiftText:SetText("Shift")
                Controls.ShiftText:SetFont("Fonts\\FRIZQT__.TTF", 14)
                Controls.ShiftText:SetPoint("CENTER", Controls.CtrlText, "CENTER", 50, 0)

                Controls.ShiftCB = CreateFrame("CheckButton", "KeyBindShiftCB", Controls, "ChatConfigCheckButtonTemplate")
                Controls.ShiftCB:SetSize(32, 36)
                Controls.ShiftCB:SetHitRectInsets(0, 0, 0, -10)
                Controls.ShiftCB:SetPoint("CENTER", Controls.ShiftText, "CENTER", 0, -30)

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
            --shift

        --Modifier

        --Edit Menu

            Controls.InputText = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            Controls.InputText:SetText("Name")
            Controls.InputText:SetFont("Fonts\\FRIZQT__.TTF", 14)
            Controls.InputText:SetPoint("CENTER", KBControlsFrame, "TOPLEFT", 380, -20)
            Controls.InputText:SetTextColor(1, 1, 1)

            Controls.Input  = CreateFrame("EditBox", "KeyboardEditInput", Controls, "InputBoxInstructionsTemplate")
            Controls.Input:SetSize(130, 30)
            Controls.Input:SetPoint("CENTER", Controls.InputText, "CENTER", 0, -30)
            Controls.Input:SetAutoFocus(false)

            Controls.EditText = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            Controls.EditText:SetText("Edit Menu")
            Controls.EditText:SetFont("Fonts\\FRIZQT__.TTF", 14)
            Controls.EditText:SetPoint("CENTER", KBControlsFrame, "TOPLEFT", offsetOneThird, -20)
            Controls.EditText:SetTextColor(1, 1, 1)
            
            Controls.Save = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
            Controls.Save:SetSize(70, 26)
            Controls.Save:SetPoint("CENTER", Controls.EditText, "CENTER", 0, -30)
            Controls.Save:SetScript("OnClick", function() addon:KeyboardSaveLayout() end)
            local SaveText = Controls.Save:CreateFontString(nil, "OVERLAY")
            SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            SaveText:SetPoint("CENTER", 0, 1)
            SaveText:SetText("Save")

            Controls.Save:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Save the current layout.")
                GameTooltip:Show()
            end)
            
            Controls.Save:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            Controls.Delete = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
            Controls.Delete:SetSize(70, 26)
            Controls.Delete:SetPoint("LEFT", Controls.Save, "RIGHT", 5, 0)

            Controls.Delete:SetScript("OnClick", function(self)
                -- Check if KBChangeBoardDD is not nil
                if not KBChangeBoardDD then
                    print("Error: KBChangeBoardDD is nil.")
                    return -- Exit the function early if KBChangeBoardDD is nil
                end
                
                -- Get the text from the KBChangeBoardDD dropdown menu.
                local selectedLayout = UIDropDownMenu_GetText(KBChangeBoardDD)
            
                -- Ensure selectedLayout is not nil before proceeding
                if selectedLayout then
                    -- Remove the selected layout from the KeyboardEditLayouts table.
                    KeyboardEditLayouts[selectedLayout] = nil
            
                    -- Clear the text in the Mouse.Input field.
                    Controls.Input:SetText("")
            
                    -- Print a message indicating which layout was deleted.
                    print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")
            
                    wipe(CurrentLayoutKeyboard)
                    UIDropDownMenu_SetText(KBChangeBoardDD, "")
                    addon:RefreshKeys()
                else
                    print("KeyUI: Error - No layout selected to delete.")
                end
            end)
            
            local DeleteText = Controls.Delete:CreateFontString(nil, "OVERLAY")
            DeleteText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            DeleteText:SetPoint("CENTER", 0, 1)
            DeleteText:SetText("Delete")

            Controls.Delete:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Delete the current layout if it's a self-made layout.")
                GameTooltip:Show()
            end)
            
            Controls.Delete:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            Controls.Lock = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
            Controls.Lock:SetSize(70, 26)
            Controls.Lock:SetPoint("RIGHT", Controls.Save, "LEFT", -5, 0)

            local LockText = Controls.Lock:CreateFontString(nil, "OVERLAY")
            LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            LockText:SetPoint("CENTER", 0, 1)
            if KeyboardLocked == false then
                LockText:SetText("Lock")
            else
                LockText:SetText("Unlock")
            end

            local function ToggleLock()
                if KeyboardLocked then
                    KeyboardLocked = false
                    edited = true
                    LockText:SetText("Lock")
                    if Controls.glowBoxLock then
                        Controls.glowBoxLock:Show()
                    end
                else
                    KeyboardLocked = true
                    LockText:SetText("Unlock")
                    if Controls.glowBoxLock then
                        Controls.glowBoxLock:Hide()
                    end  
                end
            end

            Controls.Lock:SetScript("OnClick", function(self) ToggleLock() end)

            Controls.Lock:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Toggle Editor Mode")
                GameTooltip:AddLine("- Assign new keybindings by pushing keys")
                GameTooltip:Show()
            end)
            
            Controls.Lock:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            Controls.glowBoxLock = CreateFrame("Frame", nil, Controls, "GlowBorderTemplate")
            Controls.glowBoxLock:SetSize(72, 28)
            Controls.glowBoxLock:SetPoint("CENTER", Controls.Lock, "CENTER", 0, 0)
            Controls.glowBoxLock:Hide()
            Controls.glowBoxLock:SetFrameLevel(Controls.Lock:GetFrameLevel()+1)
            
        --Edit Menu

        if KBChangeBoardDD then
            KBChangeBoardDD:Show()
            KBChangeBoardDD:SetPoint("CENTER", KBControlsFrame.Layout, "CENTER", 0, -30)
        end

        Controls.EditBox:Show()
        Controls.LeftButton:Show()
        Controls.RightButton:Show()

        Controls.AltText:Show()
        Controls.AltCB:Show()
        Controls.CtrlText:Show()
        Controls.CtrlCB:Show()
        Controls.ShiftText:Show()
        Controls.ShiftCB:Show()

        Controls.SwitchEmptyBinds:Show()
        Controls.SwitchInterfaceBinds:Show()
        Controls.Display:Show()

        Controls.InputText:Show()
        Controls.EditText:Show()
        Controls.Input:Show()
        Controls.Save:Show()
        Controls.Delete:Show()
        Controls.Lock:Show()

        if KeyboardLocked == false then
            if Controls.glowBoxLock then
                Controls.glowBoxLock:Show()
            end
        end
    end
    
    local function OnMinimize()
        maximizeFlag = false
        
        Controls:SetHeight(22)
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

            Controls.AltText:Hide()
            Controls.AltCB:Hide()
            Controls.CtrlText:Hide()
            Controls.CtrlCB:Hide()
            Controls.ShiftText:Hide()
            Controls.ShiftCB:Hide()

            Controls.SwitchEmptyBinds:Hide()
            Controls.SwitchInterfaceBinds:Hide()
            Controls.Display:Hide()

            Controls.InputText:Hide()
            Controls.EditText:Hide()
            Controls.Input:Hide()
            Controls.Save:Hide()
            Controls.Delete:Hide()
            Controls.Lock:Hide()

            if Controls.glowBoxLock then
                Controls.glowBoxLock:Hide()
            end

        end
    end

    Controls.Close = CreateFrame("Button", "$parentClose", Controls, "UIPanelCloseButton")
    Controls.Close:SetSize(22, 22)
    Controls.Close:SetPoint("TOPRIGHT", 0, 0)
    Controls.Close:SetScript("OnClick", function(s) KeyUIMainFrame:Hide() KBControlsFrame:Hide() end) -- Toggle the Keyboard frame show/hide
 
    Controls.MinMax = CreateFrame("Frame", "#parentMinMax", Controls, "MaximizeMinimizeButtonFrameTemplate")
    Controls.MinMax:SetSize(22, 22)
    Controls.MinMax:SetPoint("RIGHT", Controls.Close, "LEFT", 2, 0)
    Controls.MinMax:SetOnMaximizedCallback(OnMaximize)
    Controls.MinMax:SetOnMinimizedCallback(OnMinimize)
    
    Controls.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
    --Controls.MinMax:SetMaximizedLook() -- Set the MinMax button & control frame size to Minimize

    -- Show tutorial if not completed
    if KeyUI_Settings.tutorial_completed ~= true then
        ShowGlowAroundMinMax(Controls)
    end

    Controls:SetScript("OnMouseDown", function(self) Keyboard:StartMoving() end)
    Controls:SetScript("OnMouseUp", function(self) Keyboard:StopMovingOrSizing() end)

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
                KeyUI_Settings.tutorial_completed = true -- Mark the tutorial as completed
            end
        end)
    end

    if MaximizeButton then
        MaximizeButton:HookScript("OnClick", function()
            if glowFrame then
                glowFrame:Hide()
                KeyUI_Settings.tutorial_completed = true -- Mark the tutorial as completed
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

function addon:KeyboardSaveLayout()
    local msg = KBControlsFrame.Input:GetText()
    if KeyboardLocked == true then
        if msg ~= "" then
            KBControlsFrame.Input:SetText("")
            KBControlsFrame.Input:ClearFocus()
            print("KeyUI: Saved the new layout '" .. msg .. "'.")
            KeyboardEditLayouts[msg] = {}
            for _, button in ipairs(Keys) do
                if button:IsVisible() then
                    KeyboardEditLayouts[msg][#KeyboardEditLayouts[msg] + 1] = {
                        button.label:GetText(),
                        "Keyboard",
                        floor(button:GetLeft() - KeyUIMainFrame:GetLeft() + 0.5),
                        floor(button:GetTop() - KeyUIMainFrame:GetTop() + 0.5),
                        floor(button:GetWidth() + 0.5),
                        floor(button:GetHeight() + 0.5)
                    }
                end
            end
            wipe(CurrentLayoutKeyboard)
            CurrentLayoutKeyboard[msg] = KeyboardEditLayouts[msg]
            addon:RefreshKeys()
            UIDropDownMenu_SetText(self.ddChanger, msg)
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
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
    if CurrentLayoutKeyboard and addonOpen == true and addon.keyboardFrame then

        -- Set default small size before calculating dynamic size
        addon.keyboardFrame:SetWidth(100)
        addon.keyboardFrame:SetHeight(100)

        -- Ensure the layout isn't empty
        local layoutNotEmpty = false
        for _, layoutData in pairs(CurrentLayoutKeyboard) do
            if #layoutData > 0 then
                layoutNotEmpty = true
                break
            end
        end

        -- Only proceed if there is a valid layout
        if layoutNotEmpty then
            local cx, cy = addon.keyboardFrame:GetCenter()
            local left, right, top, bottom = cx, cx, cy, cy

            for _, layoutData in pairs(CurrentLayoutKeyboard) do
                for i = 1, #layoutData do
                    local Key = Keys[i] or self:NewButton()
                    local keyData = layoutData[i]

                    if keyData[5] then
                        Key:SetWidth(keyData[5])
                        Key:SetHeight(keyData[6])
                    else
                        Key:SetWidth(60)
                        Key:SetHeight(60)
                    end

                    if not Keys[i] then
                        Keys[i] = Key
                    end

                    Key:SetPoint("TOPLEFT", addon.keyboardFrame, "TOPLEFT", keyData[3], keyData[4])
                    Key.label:SetText(keyData[1])
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
            end

            -- Adjust the keyboardFrame size based on the keys' positions
            addon.keyboardFrame:SetWidth(right - left + 12)
            addon.keyboardFrame:SetHeight(top - bottom + 12)

        else
            -- Fallback size if the layout is empty
            addon.keyboardFrame:SetHeight(382)
            addon.keyboardFrame:SetWidth(940)
        end
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
    
        if KeyUI_Settings.show_pushed_texture then
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
    
        if KeyUI_Settings.show_pushed_texture then
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

                        -- Check if Dragonriding
                        if bonusBarOffset == 5 and currentActionBarPage == 1 then
                            adjustedSlot = adjustedSlot + 120 -- Maps to 121-132
                        end

                        -- Ensure adjustedSlot is valid before picking up
                        if adjustedSlot >= 1 and adjustedSlot <= 132 then  -- Adjust the upper limit as necessary
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

    UIDropDownMenu_SetWidth(KBChangeBoardDD, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDD, 120)
    KBChangeBoardDD:Hide()

    local boardCategories = {
        ISO = {
            QWERTZ = {"QWERTZ_100%", "QWERTZ_96%", "QWERTZ_80%", "QWERTZ_75%", "QWERTZ_60%", "QWERTZ_1800", "QWERTZ_HALF", "QWERTZ_PRIMARY"},
            AZERTY = {"AZERTY_100%", "AZERTY_96%", "AZERTY_80%", "AZERTY_75%", "AZERTY_60%", "AZERTY_1800", "AZERTY_HALF", "AZERTY_PRIMARY"},
        },
        ANSI = {
            QWERTY = {"QWERTY_100%", "QWERTY_96%", "QWERTY_80%", "QWERTY_75%", "QWERTY_60%", "QWERTY_1800", "QWERTY_HALF", "QWERTY_PRIMARY"},
        },
        DVORAK = {
            Standard = {"DVORAK_100%", "DVORAK_PRIMARY"},
            RightHand = {"DVORAK_RIGHT_100%", "DVORAK_RIGHT_PRIMARY"},
            LeftHand = {"DVORAK_LEFT_100%", "DVORAK_LEFT_PRIMARY"}
        },
        Razer = {"Tartarus_v1", "Tartarus_v2"},
        Azeron = {"Cyborg", "Cyborg_II"}
    }

    local categoryOrder = {"ISO", "ANSI", "DVORAK", "Razer", "Azeron"}

    local function ChangeBoardDD_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
    
        if level == 1 then
            for _, category in ipairs(categoryOrder) do
                info.text = category
                info.value = category
                info.hasArrow = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
            end
    
            -- Add custom layouts at the end of Level 1
            if type(KeyboardEditLayouts) == "table" then
                for name, layout in pairs(KeyboardEditLayouts) do
                    info = UIDropDownMenu_CreateInfo() -- Reset info
                    info.text = name
                    info.value = name
                    info.colorCode = "|cffff8000"
                    info.notCheckable = true
                    info.func = function()
                        wipe(CurrentLayoutKeyboard)
                        CurrentLayoutKeyboard[name] = layout
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, name)
                        KBControlsFrame.Input:SetText("")
                        KBControlsFrame.Input:ClearFocus()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
    
        elseif level == 2 then
            local category = UIDROPDOWNMENU_MENU_VALUE
            local layouts = boardCategories[category]
            
            if category == "ISO" or category == "ANSI" or category == "DVORAK" then
                for subcategory, _ in pairs(layouts) do
                    info = UIDropDownMenu_CreateInfo()
        
                    -- Check for special cases where you want to display different text
                    if subcategory == "RightHand" then
                        info.text = "Right Hand"  -- Display with space
                    elseif subcategory == "LeftHand" then
                        info.text = "Left Hand"  -- Display with space
                    else
                        info.text = subcategory
                    end
        
                    info.value = subcategory
                    info.hasArrow = true
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
            elseif layouts then
                for _, layout in ipairs(layouts) do
                    info = UIDropDownMenu_CreateInfo() -- Reset info

                    -- Check if we are in QWERTZ and adjust the display text
                    if layout == "Tartarus_v1" then
                        info.text = "Tartarus v1"
                    elseif layout == "Tartarus_v2" then
                        info.text = "Tartarus v2"
                    elseif layout == "Cyborg_II" then
                        info.text = "Cyborg II"
                    else
                        info.text = layout  -- For other layouts, keep the original text
                    end

                    info.value = layout  -- Keep the actual value as is
                    info.notCheckable = true
                    info.func = function()
                        KeyBindSettings.currentboard = layout
                        wipe(CurrentLayoutKeyboard)
                        CurrentLayoutKeyboard[layout] = KeyBindAllBoards[layout]
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, layout)
                        KBControlsFrame.Input:SetText("")
                        KBControlsFrame.Input:ClearFocus()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
    
        elseif level == 3 then
            local subcategory = UIDROPDOWNMENU_MENU_VALUE
            local layouts
            
            if boardCategories["ISO"][subcategory] then
                layouts = boardCategories["ISO"][subcategory]
            elseif boardCategories["ANSI"][subcategory] then
                layouts = boardCategories["ANSI"][subcategory]
            elseif boardCategories["DVORAK"][subcategory] then
                layouts = boardCategories["DVORAK"][subcategory]
            end
        
            if layouts then
                for _, layout in ipairs(layouts) do
                    info = UIDropDownMenu_CreateInfo()
        
                    -- Check if we are in QWERTZ and adjust the display text
                    if subcategory == "QWERTZ" then
                        local displayText = layout:gsub("QWERTZ_", "")  -- Removes "QWERTZ_" from the layout name
                        info.text = displayText
                    elseif subcategory == "AZERTY" then
                        local displayText = layout:gsub("AZERTY_", "")  -- Removes "AZERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "QWERTY" then
                        local displayText = layout:gsub("QWERTY_", "")  -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "Standard" then
                        local displayText = layout:gsub("DVORAK_", "")  -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "RightHand" then
                        local displayText = layout:gsub("DVORAK_RIGHT_", "")  -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "LeftHand" then
                        local displayText = layout:gsub("DVORAK_LEFT_", "")  -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    else
                        info.text = layout  -- For other subcategories, keep the original text
                    end
        
                    info.value = layout  -- Keep the actual value as is
                    info.notCheckable = true
                    info.func = function()
                        KeyBindSettings.currentboard = layout
                        wipe(CurrentLayoutKeyboard)
                        CurrentLayoutKeyboard[layout] = KeyBindAllBoards[layout]
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, layout)
                        KBControlsFrame.Input:SetText("")
                        KBControlsFrame.Input:ClearFocus()
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