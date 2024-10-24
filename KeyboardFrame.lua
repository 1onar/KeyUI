local name, addon = ...

-- Function to save the keyboard's position and scale
function addon:SaveKeyboardPosition()
    local x, y = addon.keyboard_frame:GetCenter()
    keyui_settings.keyboard_position.x = x
    keyui_settings.keyboard_position.y = y
    keyui_settings.keyboard_position.scale = addon.keyboard_frame:GetScale()
end

-- Function to create a glowing tutorial highlight around the MinMax button
local function ShowGlowAroundMinMax(Controls)
    local glowFrame = CreateFrame("Frame", nil, Controls.MinMax, "GlowBoxTemplate")
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
                keyui_settings.tutorial_completed = true -- Mark the tutorial as completed
            end
        end)
    end

    if MaximizeButton then
        MaximizeButton:HookScript("OnClick", function()
            if glowFrame then
                glowFrame:Hide()
                keyui_settings.tutorial_completed = true -- Mark the tutorial as completed
            end
        end)
    end
end

function addon:CreateKeyboardFrame()
    -- Create the keyboard frame and assign it to the addon table
    local keyboard_frame = CreateFrame("Frame", "keyui_keyboard_frame", UIParent, "TooltipBorderedFrameTemplate")
    addon.keyboard_frame = keyboard_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_keyboard_frame")
    end

    keyboard_frame:SetHeight(382)
    keyboard_frame:SetWidth(940)
    keyboard_frame:SetBackdropColor(0, 0, 0, 0.9)

    -- Load the saved position if it exists
    if keyui_settings.keyboard_position.x and keyui_settings.keyboard_position.y then
        keyboard_frame:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            keyui_settings.keyboard_position.x,
            keyui_settings.keyboard_position.y
        )
        keyboard_frame:SetScale(keyui_settings.keyboard_position.scale)
    else
        keyboard_frame:SetPoint("CENTER", UIParent, "CENTER", -300, 50)
        keyboard_frame:SetScale(1)
    end

    keyboard_frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    keyboard_frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    keyboard_frame:SetMovable(true)

    return keyboard_frame
end

function addon:CreateKeyboardControl()
    local keyboard_control_frame = CreateFrame("Frame", "keyui_keyboard_control_frame", addon.keyboard_frame, "TooltipBorderedFrameTemplate")
    addon.keyboard_control_frame = keyboard_control_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_keyboard_control_frame")
    end

    keyboard_control_frame:SetBackdropColor(0, 0, 0, 1)
    keyboard_control_frame:SetPoint("BOTTOMRIGHT", addon.keyboard_frame, "TOPRIGHT", 0, -2)
    keyboard_control_frame:SetScript("OnMouseDown", function(self) addon.keyboard_frame:StartMoving() end)
    keyboard_control_frame:SetScript("OnMouseUp", function(self) addon.keyboard_frame:StopMovingOrSizing() end)

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
        addon.keyboard_maximize_flag = true

        keyboard_control_frame:SetHeight(260)
        keyboard_control_frame:SetWidth(500)

        -- Calculate 1/3 and 2/3 of the width of keyboard_control_frame
        local offset_one_third = keyboard_control_frame:GetWidth() * (1 / 3)
        local offset_two_thirds = keyboard_control_frame:GetWidth() * (2 / 3)

        -- Text "Layout"
        keyboard_control_frame.Layout = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keyboard_control_frame.Layout:SetText("Layout")
        keyboard_control_frame.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.Layout:SetPoint("CENTER", keyboard_control_frame, "LEFT", 380, 25)
        keyboard_control_frame.Layout:SetTextColor(1, 1, 1)

        --Size

        keyboard_control_frame.Size = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keyboard_control_frame.Size:SetText("Size")
        keyboard_control_frame.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.Size:SetPoint("CENTER", keyboard_control_frame, "LEFT", offset_one_third, 25)
        keyboard_control_frame.Size:SetTextColor(1, 1, 1)

        keyboard_control_frame.EditBox = CreateFrame("EditBox", nil, keyboard_control_frame, "InputBoxTemplate")
        keyboard_control_frame.EditBox:SetWidth(60)
        keyboard_control_frame.EditBox:SetHeight(20)
        keyboard_control_frame.EditBox:SetPoint("CENTER", keyboard_control_frame.Size, "CENTER", 0, -29)
        keyboard_control_frame.EditBox:SetMaxLetters(4)
        keyboard_control_frame.EditBox:SetAutoFocus(false)
        keyboard_control_frame.EditBox:SetText(string.format("%.2f", addon.keyboard_frame:GetScale()))
        keyboard_control_frame.EditBox:SetJustifyH("CENTER")

        -- Add a function to update the scale when the user types in the edit box
        keyboard_control_frame.EditBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if value then
                if value < 0.5 then
                    value = 0.5
                elseif value > 1.5 then
                    value = 1.5
                end
                addon.keyboard_frame:SetScale(value)
                self:SetText(string.format("%.2f", value))
            end
            self:ClearFocus()
        end)

        keyboard_control_frame.LeftButton = CreateFrame("Button", nil, keyboard_control_frame)
        keyboard_control_frame.LeftButton:SetSize(26, 26)
        keyboard_control_frame.LeftButton:SetPoint("CENTER", keyboard_control_frame.EditBox, "CENTER", -58, 0)
        keyboard_control_frame.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        keyboard_control_frame.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        keyboard_control_frame.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        keyboard_control_frame.RightButton = CreateFrame("Button", nil, keyboard_control_frame)
        keyboard_control_frame.RightButton:SetSize(26, 26)
        keyboard_control_frame.RightButton:SetPoint("CENTER", keyboard_control_frame.EditBox, "CENTER", 54, 0)
        keyboard_control_frame.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        keyboard_control_frame.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        keyboard_control_frame.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        keyboard_control_frame.LeftButton:SetScript("OnClick", function()
            local currentValue = addon.keyboard_frame:GetScale()
            local step = 0.05
            local newValue = currentValue - step
            if newValue < 0.5 then
                newValue = 0.5
            end
            addon.keyboard_frame:SetScale(newValue)
            keyboard_control_frame.EditBox:SetText(string.format("%.2f", newValue))
        end)

        keyboard_control_frame.RightButton:SetScript("OnClick", function()
            local currentValue = addon.keyboard_frame:GetScale()
            local step = 0.05
            local newValue = currentValue + step
            if newValue > 1.5 then
                newValue = 1.5
            end
            addon.keyboard_frame:SetScale(newValue)
            keyboard_control_frame.EditBox:SetText(string.format("%.2f", newValue))
        end)

        --Size

        --Buttons

        keyboard_control_frame.Display = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keyboard_control_frame.Display:SetText("Display Options")
        keyboard_control_frame.Display:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.Display:SetPoint("CENTER", keyboard_control_frame, "BOTTOMLEFT", offset_one_third, 60)
        keyboard_control_frame.Display:SetTextColor(1, 1, 1)

        keyboard_control_frame.SwitchEmptyBinds = CreateFrame("Button", nil, keyboard_control_frame,
            "UIPanelButtonTemplate")
        keyboard_control_frame.SwitchEmptyBinds:SetSize(150, 26)
        keyboard_control_frame.SwitchEmptyBinds:SetPoint("LEFT", keyboard_control_frame.Display, "CENTER", 4, -30)

        local SwitchBindsText = keyboard_control_frame.SwitchEmptyBinds:CreateFontString(nil, "OVERLAY")
        SwitchBindsText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
        SwitchBindsText:SetPoint("CENTER", 0, 0)

        -- Check the state of show_empty_binds in KeyUI_Settings
        if keyui_settings.show_empty_binds == true then
            SwitchBindsText:SetText("Hide empty Keys")
        else
            SwitchBindsText:SetText("Show empty Keys")
        end

        -- Function to toggle the empty binds setting
        local function ToggleEmptyBinds()
            if keyui_settings.show_empty_binds ~= true then
                SwitchBindsText:SetText("Hide empty Keys")
                keyui_settings.show_empty_binds = true
            else
                SwitchBindsText:SetText("Show empty Keys")
                keyui_settings.show_empty_binds = false
            end
            addon:RefreshKeys()
        end

        keyboard_control_frame.SwitchEmptyBinds:SetScript("OnClick", ToggleEmptyBinds)
        keyboard_control_frame.SwitchEmptyBinds:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Toggle highlighting of keys without keybinds")
            GameTooltip:Show()
        end)
        keyboard_control_frame.SwitchEmptyBinds:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        keyboard_control_frame.SwitchInterfaceBinds = CreateFrame("Button", nil, keyboard_control_frame,
            "UIPanelButtonTemplate")
        keyboard_control_frame.SwitchInterfaceBinds:SetSize(150, 26)
        keyboard_control_frame.SwitchInterfaceBinds:SetPoint("RIGHT", keyboard_control_frame.Display, "CENTER", -4, -30)

        local SwitchInterfaceText = keyboard_control_frame.SwitchInterfaceBinds:CreateFontString(nil, "OVERLAY")
        SwitchInterfaceText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
        SwitchInterfaceText:SetPoint("CENTER", 0, 0)

        -- Handle showing/hiding interface binds
        if keyui_settings.show_interface_binds then
            SwitchInterfaceText:SetText("Hide Interface Binds")
        else
            SwitchInterfaceText:SetText("Show Interface Binds")
        end

        -- Function to toggle interface binds visibility
        local function ToggleInterfaceBinds()
            if not keyui_settings.show_interface_binds then
                SwitchInterfaceText:SetText("Hide Interface Binds")
                keyui_settings.show_interface_binds = true
            else
                SwitchInterfaceText:SetText("Show Interface Binds")
                keyui_settings.show_interface_binds = false
            end
            addon:RefreshKeys()
        end

        keyboard_control_frame.SwitchInterfaceBinds:SetScript("OnClick", ToggleInterfaceBinds)
        keyboard_control_frame.SwitchInterfaceBinds:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Show/Hide the Interface Action of Keys")
            GameTooltip:Show()
        end)
        keyboard_control_frame.SwitchInterfaceBinds:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        --Buttons

        --Modifier

        --alt
        -- Create a font string for the text "Alt" and position it below the checkbutton
        keyboard_control_frame.AltText = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        keyboard_control_frame.AltText:SetText("Alt")
        keyboard_control_frame.AltText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.AltText:SetPoint("CENTER", keyboard_control_frame.Display, "CENTER", 192, 0)

        keyboard_control_frame.AltCB = CreateFrame("CheckButton", nil, keyboard_control_frame,
            "ChatConfigCheckButtonTemplate")
        keyboard_control_frame.AltCB:SetSize(32, 36)
        keyboard_control_frame.AltCB:SetHitRectInsets(0, 0, 0, -10)
        keyboard_control_frame.AltCB:SetPoint("CENTER", keyboard_control_frame.AltText, "CENTER", 0, -30)

        -- Set the OnClick script for the checkbutton
        keyboard_control_frame.AltCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                addon.modif.ALT = "ALT-"
                addon.modif.CTRL = ""
                addon.modif.SHIFT = ""
                addon.alt_checkbox = true
                keyboard_control_frame.CtrlCB:SetChecked(false)
                keyboard_control_frame.ShiftCB:SetChecked(false)
            else
                addon.modif.ALT = ""
                addon.alt_checkbox = false
                addon.ctrl_checkbox = false
                addon.shift_checkbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(keyboard_control_frame.AltCB, "Toggle Alt key modifier")
        --alt

        --ctrl
        -- Create a font string for the text "Ctrl" and position it below the checkbutton
        keyboard_control_frame.CtrlText = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        keyboard_control_frame.CtrlText:SetText("Ctrl")
        keyboard_control_frame.CtrlText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.CtrlText:SetPoint("CENTER", keyboard_control_frame.AltText, "CENTER", 50, 0)

        keyboard_control_frame.CtrlCB = CreateFrame("CheckButton", nil, keyboard_control_frame,
            "ChatConfigCheckButtonTemplate")
        keyboard_control_frame.CtrlCB:SetSize(32, 36)
        keyboard_control_frame.CtrlCB:SetHitRectInsets(0, 0, 0, -10)
        keyboard_control_frame.CtrlCB:SetPoint("CENTER", keyboard_control_frame.CtrlText, "CENTER", 0, -30)

        -- Set the OnClick script for the checkbutton
        keyboard_control_frame.CtrlCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                addon.modif.ALT = ""
                addon.modif.CTRL = "CTRL-"
                addon.modif.SHIFT = ""
                addon.ctrl_checkbox = true
                keyboard_control_frame.AltCB:SetChecked(false)
                keyboard_control_frame.ShiftCB:SetChecked(false)
            else
                addon.modif.CTRL = ""
                addon.alt_checkbox = false
                addon.ctrl_checkbox = false
                addon.shift_checkbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(keyboard_control_frame.CtrlCB, "Toggle Ctrl key modifier")
        --ctrl

        --shift
        -- Create a font string for the text "Shift" and position it below the checkbutton
        keyboard_control_frame.ShiftText = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        keyboard_control_frame.ShiftText:SetText("Shift")
        keyboard_control_frame.ShiftText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.ShiftText:SetPoint("CENTER", keyboard_control_frame.CtrlText, "CENTER", 50, 0)

        keyboard_control_frame.ShiftCB = CreateFrame("CheckButton", nil, keyboard_control_frame,
            "ChatConfigCheckButtonTemplate")
        keyboard_control_frame.ShiftCB:SetSize(32, 36)
        keyboard_control_frame.ShiftCB:SetHitRectInsets(0, 0, 0, -10)
        keyboard_control_frame.ShiftCB:SetPoint("CENTER", keyboard_control_frame.ShiftText, "CENTER", 0, -30)

        -- Set the OnClick script for the checkbutton
        keyboard_control_frame.ShiftCB:SetScript("OnClick", function(s)
            if s:GetChecked() then
                addon.modif.ALT = ""
                addon.modif.CTRL = ""
                addon.modif.SHIFT = "SHIFT-"
                addon.shift_checkbox = true
                keyboard_control_frame.AltCB:SetChecked(false)
                keyboard_control_frame.CtrlCB:SetChecked(false)
            else
                addon.modif.SHIFT = ""
                addon.alt_checkbox = false
                addon.ctrl_checkbox = false
                addon.shift_checkbox = false
            end
            addon:RefreshKeys()
        end)
        SetCheckboxTooltip(keyboard_control_frame.ShiftCB, "Toggle Shift key modifier")
        --shift

        --Modifier

        --Edit Menu

        keyboard_control_frame.InputText = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keyboard_control_frame.InputText:SetText("Name")
        keyboard_control_frame.InputText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.InputText:SetPoint("CENTER", keyboard_control_frame, "TOPLEFT", 380, -20)
        keyboard_control_frame.InputText:SetTextColor(1, 1, 1)

        keyboard_control_frame.Input = CreateFrame("EditBox", nil, keyboard_control_frame, "InputBoxInstructionsTemplate")
        keyboard_control_frame.Input:SetSize(130, 30)
        keyboard_control_frame.Input:SetPoint("CENTER", keyboard_control_frame.InputText, "CENTER", 0, -30)
        keyboard_control_frame.Input:SetAutoFocus(false)

        keyboard_control_frame.EditText = keyboard_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keyboard_control_frame.EditText:SetText("Edit Menu")
        keyboard_control_frame.EditText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        keyboard_control_frame.EditText:SetPoint("CENTER", keyboard_control_frame, "TOPLEFT", offset_one_third, -20)
        keyboard_control_frame.EditText:SetTextColor(1, 1, 1)

        keyboard_control_frame.Save = CreateFrame("Button", nil, keyboard_control_frame, "UIPanelButtonTemplate")
        keyboard_control_frame.Save:SetSize(70, 26)
        keyboard_control_frame.Save:SetPoint("CENTER", keyboard_control_frame.EditText, "CENTER", 0, -30)
        keyboard_control_frame.Save:SetScript("OnClick", function() addon:SaveKeyboardLayout() end)
        local SaveText = keyboard_control_frame.Save:CreateFontString(nil, "OVERLAY")
        SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
        SaveText:SetPoint("CENTER", 0, 1)
        SaveText:SetText("Save")

        keyboard_control_frame.Save:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Save the current layout.")
            GameTooltip:Show()
        end)

        keyboard_control_frame.Save:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Define the confirmation dialog
        StaticPopupDialogs["KEYUI_KEYBOARD_CONFIRM_DELETE"] = {
            text = "Are you sure you want to delete the selected layout?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                -- delete edited changes and remove glowboxes
                addon:DiscardKeyboardChanges()

                -- Function to delete the selected layout
                local selectedLayout = UIDropDownMenu_GetText(addon.keyboard_selector)

                -- Ensure selectedLayout is not nil before proceeding
                if selectedLayout then
                    -- Remove the selected layout from the KeyboardEditLayouts table.
                    keyui_settings.layout_edited_keyboard[selectedLayout] = nil

                    -- Clear the text in the Mouse.Input field.
                    keyboard_control_frame.Input:SetText("")

                    -- Print a message indicating which layout was deleted.
                    print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")

                    wipe(keyui_settings.layout_current_keyboard)
                    UIDropDownMenu_SetText(addon.keyboard_selector, "")
                    addon:RefreshKeys()
                else
                    print("KeyUI: Error - No layout selected to delete.")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3, -- Avoids conflicts with other popups
        }

        keyboard_control_frame.Delete = CreateFrame("Button", nil, keyboard_control_frame, "UIPanelSquareButton")
        keyboard_control_frame.Delete:SetSize(28, 28)
        keyboard_control_frame.Delete:SetPoint("LEFT", addon.keyboard_selector, "RIGHT", -12, 2)  

        -- OnClick handler to show confirmation dialog
        keyboard_control_frame.Delete:SetScript("OnClick", function(self)
            if not addon.keyboard_selector then
                print("KeyUI: Error - No layout selected.")
                return
            end

            -- Show the confirmation dialog
            StaticPopup_Show("KEYUI_KEYBOARD_CONFIRM_DELETE")
        end)

        keyboard_control_frame.Delete:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Delete Layout")
            GameTooltip:AddLine("- Remove the current layout if it's custom", 1, 1, 1)
            GameTooltip:Show()
        end)

        keyboard_control_frame.Delete:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        keyboard_control_frame.Lock = CreateFrame("Button", nil, keyboard_control_frame, "UIPanelButtonTemplate")
        keyboard_control_frame.Lock:SetSize(70, 26)
        keyboard_control_frame.Lock:SetPoint("RIGHT", keyboard_control_frame.Save, "LEFT", -5, 0)

        -- Create and store the LockText in the frame table
        keyboard_control_frame.LockText = keyboard_control_frame.Lock:CreateFontString(nil, "OVERLAY")
        keyboard_control_frame.LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)
        keyboard_control_frame.LockText:SetPoint("CENTER", 0, 1)

        if addon.keyboard_locked == false then
            keyboard_control_frame.LockText:SetText("Lock")
        else
            keyboard_control_frame.LockText:SetText("Unlock")
        end

        local function ToggleLock()
            if addon.keyboard_locked then
                addon.keyboard_locked = false
                keyboard_control_frame.LockText:SetText("Lock")
                if keyboard_control_frame.glowBoxLock then
                    keyboard_control_frame.glowBoxLock:Show()
                    keyboard_control_frame.glowBoxSave:Hide()
                    keyboard_control_frame.glowBoxInput:Hide()
                end
                print("KeyUI: The keyboard is now unlocked! You can edit key bindings. 'Lock' the changes when done.")
            else
                addon.keyboard_locked = true
                keyboard_control_frame.LockText:SetText("Unlock")
                if keyboard_control_frame.glowBoxLock then
                    keyboard_control_frame.glowBoxLock:Hide()
                end
                if addon.keys_keyboard_edited == true then
                    keyboard_control_frame.glowBoxSave:Show()
                    keyboard_control_frame.glowBoxInput:Show()
                    print("KeyUI: Changes are now locked. Please enter a name and save your layout.")
                else
                    keyboard_control_frame.glowBoxSave:Hide()
                    keyboard_control_frame.glowBoxInput:Hide()
                    print("KeyUI: No Changes detected (Keyboard).")
                end
            end
        end

        keyboard_control_frame.Lock:SetScript("OnClick", function(self) ToggleLock() end)

        keyboard_control_frame.Lock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Toggle Editor Mode")
            GameTooltip:AddLine("- Assign new keybindings by pushing keys", 1, 1, 1)
            GameTooltip:Show()
        end)

        keyboard_control_frame.Lock:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Create the Discard button
        keyboard_control_frame.Discard = CreateFrame("Button", nil, keyboard_control_frame, "UIPanelButtonTemplate")
        keyboard_control_frame.Discard:SetSize(70, 26)  -- Set the size of the button
        keyboard_control_frame.Discard:SetPoint("LEFT", keyboard_control_frame.Save, "RIGHT", 5, 0)

        -- Create the font string for the button text
        local DiscardText = keyboard_control_frame.Discard:CreateFontString(nil, "OVERLAY")
        DiscardText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set the font
        DiscardText:SetPoint("CENTER", 0, 1)  -- Center the text in the button
        DiscardText:SetText("Discard")  -- Set the button text

        -- Set the script to call the Discard function when clicked
        keyboard_control_frame.Discard:SetScript("OnClick", function()
            addon:DiscardKeyboardChanges()  -- Call the DiscardKeyboardChanges function
        end)

        keyboard_control_frame.Discard:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Discard Changes")
            GameTooltip:AddLine("- Revert any unsaved keybinding changes", 1, 1, 1)
            GameTooltip:AddLine("- Reset the keyboard layout to the last saved state", 1, 1, 1)
            GameTooltip:Show()
        end)
        
        keyboard_control_frame.Discard:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        keyboard_control_frame.glowBoxLock = CreateFrame("Frame", nil, keyboard_control_frame, "GlowBorderTemplate")
        keyboard_control_frame.glowBoxLock:SetSize(68, 24)
        keyboard_control_frame.glowBoxLock:SetPoint("CENTER", keyboard_control_frame.Lock, "CENTER", 0, 0)
        keyboard_control_frame.glowBoxLock:Hide()
        keyboard_control_frame.glowBoxLock:SetFrameLevel(keyboard_control_frame.Lock:GetFrameLevel() - 1)

        keyboard_control_frame.glowBoxSave = CreateFrame("Frame", nil, keyboard_control_frame, "GlowBorderTemplate")
        keyboard_control_frame.glowBoxSave:SetSize(68, 24)
        keyboard_control_frame.glowBoxSave:SetPoint("CENTER", keyboard_control_frame.Save, "CENTER", 0, 0)
        keyboard_control_frame.glowBoxSave:Hide()
        keyboard_control_frame.glowBoxSave:SetFrameLevel(keyboard_control_frame.Save:GetFrameLevel() - 1)

        keyboard_control_frame.glowBoxInput = CreateFrame("Frame", nil, keyboard_control_frame, "GlowBorderTemplate")
        keyboard_control_frame.glowBoxInput:SetSize(136, 18)
        keyboard_control_frame.glowBoxInput:SetPoint("CENTER", keyboard_control_frame.Input, "CENTER", -2, 0)
        keyboard_control_frame.glowBoxInput:Hide()
        keyboard_control_frame.glowBoxInput:SetFrameLevel(keyboard_control_frame.Input:GetFrameLevel() - 1)

        --Edit Menu

        if addon.keyboard_selector then
            addon.keyboard_selector:Show()
            addon.keyboard_selector:SetPoint("CENTER", keyboard_control_frame.Layout, "CENTER", -18, -30)
        end

        keyboard_control_frame.EditBox:Show()
        keyboard_control_frame.LeftButton:Show()
        keyboard_control_frame.RightButton:Show()

        keyboard_control_frame.AltText:Show()
        keyboard_control_frame.AltCB:Show()
        keyboard_control_frame.CtrlText:Show()
        keyboard_control_frame.CtrlCB:Show()
        keyboard_control_frame.ShiftText:Show()
        keyboard_control_frame.ShiftCB:Show()

        keyboard_control_frame.SwitchEmptyBinds:Show()
        keyboard_control_frame.SwitchInterfaceBinds:Show()
        keyboard_control_frame.Display:Show()

        keyboard_control_frame.InputText:Show()
        keyboard_control_frame.EditText:Show()
        keyboard_control_frame.Input:Show()
        keyboard_control_frame.Save:Show()
        keyboard_control_frame.Delete:Show()
        keyboard_control_frame.Lock:Show()
        keyboard_control_frame.Discard:Show()
    end

    local function OnMinimize()
        addon.keyboard_maximize_flag = false

        keyboard_control_frame:SetHeight(22)
        keyboard_control_frame:SetWidth(addon.keyboard_frame:GetWidth())

        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
            -- Discard any Editor Changes
            addon:DiscardKeyboardChanges()
        end

        if keyboard_control_frame.EditBox then
            if addon.keyboard_selector then
                addon.keyboard_selector:Hide()
            end
            keyboard_control_frame.Layout:Hide()

            keyboard_control_frame.EditBox:Hide()
            keyboard_control_frame.LeftButton:Hide()
            keyboard_control_frame.RightButton:Hide()
            keyboard_control_frame.Size:Hide()

            keyboard_control_frame.AltText:Hide()
            keyboard_control_frame.AltCB:Hide()
            keyboard_control_frame.CtrlText:Hide()
            keyboard_control_frame.CtrlCB:Hide()
            keyboard_control_frame.ShiftText:Hide()
            keyboard_control_frame.ShiftCB:Hide()

            keyboard_control_frame.SwitchEmptyBinds:Hide()
            keyboard_control_frame.SwitchInterfaceBinds:Hide()
            keyboard_control_frame.Display:Hide()

            keyboard_control_frame.InputText:Hide()
            keyboard_control_frame.EditText:Hide()
            keyboard_control_frame.Input:Hide()
            keyboard_control_frame.Save:Hide()
            keyboard_control_frame.Delete:Hide()
            keyboard_control_frame.Lock:Hide()
            keyboard_control_frame.Discard:Hide()
        end
    end

    keyboard_control_frame.Close = CreateFrame("Button", nil, keyboard_control_frame, "UIPanelCloseButton")
    keyboard_control_frame.Close:SetSize(22, 22)
    keyboard_control_frame.Close:SetPoint("TOPRIGHT", 0, 0)
    keyboard_control_frame.Close:SetScript("OnClick", function(s)
        addon:DiscardKeyboardChanges()
        addon.keyboard_frame:Hide()
        keyboard_control_frame:Hide()
    end) -- Toggle the Keyboard frame show/hide

    keyboard_control_frame.MinMax = CreateFrame("Frame", nil, keyboard_control_frame,
        "MaximizeMinimizeButtonFrameTemplate")
    keyboard_control_frame.MinMax:SetSize(22, 22)
    keyboard_control_frame.MinMax:SetPoint("RIGHT", keyboard_control_frame.Close, "LEFT", 2, 0)
    keyboard_control_frame.MinMax:SetOnMaximizedCallback(OnMaximize)
    keyboard_control_frame.MinMax:SetOnMinimizedCallback(OnMinimize)

    keyboard_control_frame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
    --Controls.MinMax:SetMaximizedLook() -- Set the MinMax button & control frame size to Minimize

    -- Show tutorial if not completed
    if keyui_settings.tutorial_completed ~= true then
        ShowGlowAroundMinMax(keyboard_control_frame)
    end

    return keyboard_control_frame
end

function addon:SaveKeyboardLayout()
    local msg = addon.keyboard_control_frame.Input:GetText()

    if addon.keyboard_locked == true then
        if msg ~= "" then
            -- Clear the input field and focus
            addon.keyboard_control_frame.Input:SetText("")
            addon.keyboard_control_frame.Input:ClearFocus()

            print("KeyUI: Saved the new layout '" .. msg .. "'.")

            -- Initialize a new table for the saved layout
            keyui_settings.layout_edited_keyboard[msg] = {}

            -- Iterate through all keyboard buttons to save their data
            for _, button in ipairs(addon.keys_keyboard) do
                if button:IsVisible() then
                    -- Save button properties: label, position, width, and height
                    keyui_settings.layout_edited_keyboard[msg][#keyui_settings.layout_edited_keyboard[msg] + 1] = {
                        button.label:GetText(),                                         -- Button name
                        floor(button:GetLeft() - addon.keyboard_frame:GetLeft() + 0.5), -- X position
                        floor(button:GetTop() - addon.keyboard_frame:GetTop() + 0.5),   -- Y position
                        floor(button:GetWidth() + 0.5),                                 -- Width
                        floor(button:GetHeight() + 0.5)                                 -- Height
                    }
                end
            end

            -- Clear the current layout and assign the new one
            wipe(keyui_settings.layout_current_keyboard)
            keyui_settings.layout_current_keyboard[msg] = keyui_settings.layout_edited_keyboard[msg]

            -- Remove Keyboard edited flag
            addon.keys_keyboard_edited = false

            -- Remove Save Button and Input Field Glow
            addon.keyboard_control_frame.glowBoxSave:Hide()
            addon.keyboard_control_frame.glowBoxInput:Hide()

            -- Refresh the keys and update the dropdown menu
            addon:RefreshKeys()
            UIDropDownMenu_SetText(addon.keyboard_selector, msg)
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
    end
end

-- Discards any changes made to the keyboard layout and resets the Control UI state
function addon:DiscardKeyboardChanges()

    if addon.keys_keyboard_edited == true or addon.keyboard_locked == false then
        -- Print message to the player
        print("KeyUI: Changes discarded. The keyboard is reset and locked.")
    end

    -- Remove Keyboard locked flag
    addon.keyboard_locked = true

    -- Remove Keyboard edited flag
    addon.keys_keyboard_edited = false

    -- Remove Lock Button, Save Button and Input Field Glow
    if addon.keyboard_control_frame.glowBoxLock then
        addon.keyboard_control_frame.glowBoxLock:Hide()
    end
    if addon.keyboard_control_frame.glowBoxSave then
        addon.keyboard_control_frame.glowBoxSave:Hide()
    end
    if addon.keyboard_control_frame.glowBoxInput then
        addon.keyboard_control_frame.glowBoxInput:Hide()
    end

    -- Update the Lock button text
    if addon.keyboard_control_frame.LockText then
        addon.keyboard_control_frame.LockText:SetText("Unlock")
    end

    -- clear keyboard text input field (name)
    if addon.keyboard_control_frame.Input then
        addon.keyboard_control_frame.Input:SetText("")
        addon.keyboard_control_frame.Input:ClearFocus()
    end

    addon:RefreshKeys()
end

-- This function switches the key binding board to display different key bindings.
function addon:UpdateKeyboardLayout()
    -- Clear the existing key array to avoid leftover data from previous layouts.
    for i = 1, #addon.keys_keyboard do
        addon.keys_keyboard[i]:Hide()
        addon.keys_keyboard[i] = nil
    end
    addon.keys_keyboard = {}

    -- Set up the new layout if a valid configuration is available.
    if keyui_settings.layout_current_keyboard and addon.open and addon.keyboard_frame then
        -- Set a default small size before calculating the dynamic size.
        addon.keyboard_frame:SetWidth(100)
        addon.keyboard_frame:SetHeight(100)

        -- Check if the layout contains any data.
        local layout_not_empty = false
        for _, layout_data in pairs(keyui_settings.layout_current_keyboard) do
            if #layout_data > 0 then
                layout_not_empty = true
                break
            end
        end

        -- Proceed only if the layout is not empty.
        if layout_not_empty then
            local cx, cy = addon.keyboard_frame:GetCenter()
            local left, right, top, bottom = cx, cx, cy, cy

            -- Loop through each key in the layout and position it within the frame.
            for _, layout_data in pairs(keyui_settings.layout_current_keyboard) do
                for i = 1, #layout_data do
                    local key = addon.keys_keyboard[i] or addon:CreateKeyboardButtons()
                    local key_data = layout_data[i]

                    -- Set the size of the key based on the provided data or use defaults.
                    if key_data[4] then
                        key:SetWidth(key_data[4])
                        key:SetHeight(key_data[5])
                    else
                        key:SetWidth(60)
                        key:SetHeight(60)
                    end

                    -- Store the key in the array if it's not already present.
                    if not addon.keys_keyboard[i] then
                        addon.keys_keyboard[i] = key
                    end

                    -- Position the key within the frame.
                    key:SetPoint("TOPLEFT", addon.keyboard_frame, "TOPLEFT", key_data[2], key_data[3])
                    key.label:SetText(key_data[1])
                    key:Show()

                    -- Update the boundaries for resizing the frame.
                    local l, r, t, b = key:GetLeft(), key:GetRight(), key:GetTop(), key:GetBottom()
                    if l < left then left = l end
                    if r > right then right = r end
                    if t > top then top = t end
                    if b < bottom then bottom = b end
                end
            end

            -- Adjust the frame size based on the extreme positions of the keys.
            addon.keyboard_frame:SetWidth(right - left + 12)
            addon.keyboard_frame:SetHeight(top - bottom + 12)
        else
            -- Set a fallback size if the layout is empty.
            addon.keyboard_frame:SetWidth(940)
            addon.keyboard_frame:SetHeight(382)
        end
    end
end

-- Create a new button to the main keyboard frame.
function addon:CreateKeyboardButtons()

    -- Create a frame that acts as a button with a tooltip border.
    local keyboard_button = CreateFrame("Frame", nil, addon.keyboard_frame, "TooltipBorderedFrameTemplate")
    keyboard_button:EnableMouse(true)
    keyboard_button:EnableKeyboard(true)
    keyboard_button:SetBackdropColor(0, 0, 0, 1)

    -- Create a label to display the full name of the action.
    keyboard_button.label = keyboard_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyboard_button.label:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    keyboard_button.label:SetTextColor(1, 1, 1, 0.9)
    keyboard_button.label:SetHeight(50)
    keyboard_button.label:SetWidth(56)
    keyboard_button.label:SetPoint("TOPRIGHT", keyboard_button, "TOPRIGHT", -4, -6)
    keyboard_button.label:SetJustifyH("RIGHT")
    keyboard_button.label:SetJustifyV("TOP")

    -- Hidden font string to store the macro text.
    keyboard_button.macro = keyboard_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyboard_button.macro:SetText("")
    keyboard_button.macro:Hide()

    -- Font string to display the interface action text.
    keyboard_button.interfaceaction = keyboard_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyboard_button.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    keyboard_button.interfaceaction:SetTextColor(1, 1, 1)
    keyboard_button.interfaceaction:SetHeight(58)
    keyboard_button.interfaceaction:SetWidth(58)
    keyboard_button.interfaceaction:SetPoint("CENTER", keyboard_button, "CENTER", 0, -6)
    keyboard_button.interfaceaction:SetText("")

    -- Icon texture for the button.
    keyboard_button.icon = keyboard_button:CreateTexture(nil, "ARTWORK")
    keyboard_button.icon:SetSize(50, 50)
    keyboard_button.icon:SetPoint("TOPLEFT", keyboard_button, "TOPLEFT", 5, -5)

    -- Define the mouse hover behavior to show tooltips.
    keyboard_button:SetScript("OnEnter", function()
        addon:ButtonMouseOver(keyboard_button)
        keyboard_button:EnableKeyboard(true)
        keyboard_button:EnableMouseWheel(true)

        if addon.keyboard_locked == false then

            keyboard_button:SetScript("OnKeyDown", function(_, key)
                addon:HandleKeyDown(keyboard_button, key)
                addon.keys_keyboard_edited = true
            end)

            keyboard_button:SetScript("OnMouseWheel", function(_, delta)
                addon:HandleMouseWheel(keyboard_button, delta)
                addon.keys_keyboard_edited = true
            end)

        end

        if keyui_settings.show_pushed_texture then
            -- Only proceed if button.slot is valid
            if keyboard_button.slot then
                -- Adjust the slot mapping based on the current action bar page
                local adjustedSlot = keyboard_button.slot

                if addon.current_actionbar_page == 3 and keyboard_button.slot >= 25 and keyboard_button.slot <= 36 then
                    adjustedSlot = keyboard_button.slot - 24 -- Map to ActionButton1-12
                elseif addon.current_actionbar_page == 4 and keyboard_button.slot >= 37 and keyboard_button.slot <= 48 then
                    adjustedSlot = keyboard_button.slot - 36 -- Map to ActionButton1-12
                elseif addon.current_actionbar_page == 5 and keyboard_button.slot >= 49 and keyboard_button.slot <= 60 then
                    adjustedSlot = keyboard_button.slot - 48 -- Map to ActionButton1-12
                elseif addon.current_actionbar_page == 6 and keyboard_button.slot >= 61 and keyboard_button.slot <= 72 then
                    adjustedSlot = keyboard_button.slot - 60 -- Map to ActionButton1-12
                end

                -- Look up the correct button in TextureMappings using the adjusted slot number
                local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
                if mappedButton then
                    local normalTexture = mappedButton:GetNormalTexture()
                    if normalTexture and normalTexture:IsVisible() then
                        local pushedTexture = mappedButton:GetPushedTexture()
                        if pushedTexture then
                            pushedTexture:Show() -- Show the pushed texture
                        end
                    end
                end
            end
        end
    end)

    keyboard_button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        addon.tooltip:Hide()
        keyboard_button:EnableKeyboard(false)
        keyboard_button:EnableMouseWheel(false)
        if not addon.keyboard_locked then -- insure modifier work when locked and hovering a key
            keyboard_button:SetScript("OnKeyDown", nil)
        end

        if keyui_settings.show_pushed_texture then
            -- Only proceed if button.slot is valid
            if keyboard_button.slot then
                local adjustedSlot = keyboard_button.slot

                if addon.current_actionbar_page == 3 and keyboard_button.slot >= 25 and keyboard_button.slot <= 36 then
                    adjustedSlot = keyboard_button.slot - 24
                elseif addon.current_actionbar_page == 4 and keyboard_button.slot >= 37 and keyboard_button.slot <= 48 then
                    adjustedSlot = keyboard_button.slot - 36
                elseif addon.current_actionbar_page == 5 and keyboard_button.slot >= 49 and keyboard_button.slot <= 60 then
                    adjustedSlot = keyboard_button.slot - 48
                elseif addon.current_actionbar_page == 6 and keyboard_button.slot >= 61 and keyboard_button.slot <= 72 then
                    adjustedSlot = keyboard_button.slot - 60
                end

                local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
                if mappedButton then
                    local pushedTexture = mappedButton:GetPushedTexture()
                    if pushedTexture then
                        pushedTexture:Hide() -- Hide the pushed texture
                    end
                end
            end
        end
    end)

    -- Define behavior for mouse down actions (left-click).
    keyboard_button:SetScript("OnMouseDown", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            if addon.keyboard_locked == false then
                return
            else
                addon.currentKey = self
                local key = addon.currentKey.macro:GetText()

                -- Check if 'key' is non-nil and non-empty before proceeding.
                if key and key ~= "" then
                    local actionSlot = addon.action_slot_mapping[key]
                    if actionSlot then
                        -- Adjust action slot based on current action bar page
                        local adjustedSlot = tonumber(actionSlot)

                        -- Handle bonus bar offsets for ROGUE and DRUID
                        if (addon.class_name == "ROGUE" or addon.class_name == "DRUID") and addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
                            if addon.bonusbar_offset == 1 then
                                adjustedSlot = adjustedSlot + 72  -- Maps to 73-84
                            elseif addon.bonusbar_offset == 2 then
                                adjustedSlot = adjustedSlot       -- No change for offset 2
                            elseif addon.bonusbar_offset == 3 then
                                adjustedSlot = adjustedSlot + 96  -- Maps to 97-108
                            elseif addon.bonusbar_offset == 4 then
                                adjustedSlot = adjustedSlot + 108 -- Maps to 109-120
                            end
                        end

                        -- Adjust based on current action bar page
                        if addon.current_actionbar_page == 2 then
                            adjustedSlot = adjustedSlot + 12 -- For ActionBarPage 2, adjust slots by +12 (13-24)
                        elseif addon.current_actionbar_page == 3 then
                            adjustedSlot = adjustedSlot + 24 -- For ActionBarPage 3, adjust slots by +24 (25-36)
                        elseif addon.current_actionbar_page == 4 then
                            adjustedSlot = adjustedSlot + 36 -- For ActionBarPage 4, adjust slots by +36 (37-48)
                        elseif addon.current_actionbar_page == 5 then
                            adjustedSlot = adjustedSlot + 48 -- For ActionBarPage 5, adjust slots by +48 (49-60)
                        elseif addon.current_actionbar_page == 6 then
                            adjustedSlot = adjustedSlot + 60 -- For ActionBarPage 6, adjust slots by +60 (61-72)
                        end

                        -- Check if Dragonriding
                        if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then
                            adjustedSlot = adjustedSlot + 120 -- Maps to 121-132
                        end

                        -- Ensure adjustedSlot is valid before picking up
                        if adjustedSlot >= 1 and adjustedSlot <= 132 then -- Adjust the upper limit as necessary
                            PickupAction(adjustedSlot)
                            --print(adjustedSlot)  -- Debug print to check if the slot is correctly adjusted
                            addon:RefreshKeys()
                        else
                            -- Optionally handle cases where the adjusted slot is out of range
                            PickupAction(actionSlot)
                            addon:RefreshKeys()
                        end
                    elseif keyboard_button.petActionIndex then
                        -- Pickup a pet action
                        print(
                            "KeyUI: Due to limitations in the Blizzard API, pet actions cannot placed by addons. Please drag them manually.")
                        return
                    elseif keyboard_button.spellid then
                        print(
                            "KeyUI: Due to limitations in the Blizzard API, pet actions cannot placed by addons. Please drag them manually.")
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
            if addon.keyboard_locked == false then
                addon:HandleKeyDown(self, Mousebutton)
                addon.keys_keyboard_edited = true
            end
        end
    end)

    -- Define behavior for mouse up actions (left-click and right-click).
    keyboard_button:SetScript("OnMouseUp", function(self, Mousebutton)
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
                    spellBookType = Enum.SpellBookSpellBank.Player -- Default to player spells.
                elseif info2 == "pet" then
                    spellBookType = Enum.SpellBookSpellBank.Pet    -- For pet spells.
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
                            local actionSlot = addon.action_slot_mapping[key]
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
            if addon.modif.ALT == "" and addon.modif.CTRL == "" and addon.modif.SHIFT == "" then
                ToggleDropDownMenu(1, nil, addon.dropdown, self, 30, 20)
            end
        end
    end)

    return keyboard_button
end

function addon:KeyboardLayoutSelecter()
    local KeyboardLayoutSelecter = CreateFrame("Frame", nil, addon.keyboard_control_frame, "UIDropDownMenuTemplate")
    addon.keyboard_selector = KeyboardLayoutSelecter

    UIDropDownMenu_SetWidth(KeyboardLayoutSelecter, 120)
    UIDropDownMenu_SetButtonWidth(KeyboardLayoutSelecter, 120)
    KeyboardLayoutSelecter:Hide()

    local boardCategories = {
        ISO = {
            QWERTZ = { "QWERTZ_100%", "QWERTZ_96%", "QWERTZ_80%", "QWERTZ_75%", "QWERTZ_60%", "QWERTZ_1800", "QWERTZ_HALF", "QWERTZ_PRIMARY" },
            AZERTY = { "AZERTY_100%", "AZERTY_96%", "AZERTY_80%", "AZERTY_75%", "AZERTY_60%", "AZERTY_1800", "AZERTY_HALF", "AZERTY_PRIMARY" },
        },
        ANSI = {
            QWERTY = { "QWERTY_100%", "QWERTY_96%", "QWERTY_80%", "QWERTY_75%", "QWERTY_60%", "QWERTY_1800", "QWERTY_HALF", "QWERTY_PRIMARY" },
        },
        DVORAK = {
            Standard = { "DVORAK_100%", "DVORAK_PRIMARY" },
            RightHand = { "DVORAK_RIGHT_100%", "DVORAK_RIGHT_PRIMARY" },
            LeftHand = { "DVORAK_LEFT_100%", "DVORAK_LEFT_PRIMARY" }
        },
        Razer = { "Tartarus_v1", "Tartarus_v2" },
        Azeron = { "Cyborg", "Cyborg_II" }
    }

    local categoryOrder = { "ISO", "ANSI", "DVORAK", "Razer", "Azeron" }

    local function KeyboardLayoutSelecter_Initialize(self, level)
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
            if type(keyui_settings.layout_edited_keyboard) == "table" then
                for name, layout in pairs(keyui_settings.layout_edited_keyboard) do
                    info = UIDropDownMenu_CreateInfo() -- Reset info
                    info.text = name
                    info.value = name
                    info.colorCode = "|cffff8000"
                    info.notCheckable = true
                    info.func = function()
                        -- Discard Keyboard Editor Changes
                        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
                            addon:DiscardKeyboardChanges()
                        else
                            -- clear text input field (DiscardKeyboardChanges does it already)
                            addon.keyboard_control_frame.Input:SetText("")
                            addon.keyboard_control_frame.Input:ClearFocus()
                        end
                        wipe(keyui_settings.layout_current_keyboard)
                        keyui_settings.layout_current_keyboard[name] = layout
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, name)
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
                        info.text = "Right Hand" -- Display with space
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
                        info.text = layout -- For other layouts, keep the original text
                    end

                    info.value = layout -- Keep the actual value as is
                    info.notCheckable = true
                    info.func = function()
                        -- Discard Keyboard Editor Changes
                        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
                            addon:DiscardKeyboardChanges()
                        else
                            -- clear text input field (DiscardKeyboardChanges does it already)
                            addon.keyboard_control_frame.Input:SetText("")
                            addon.keyboard_control_frame.Input:ClearFocus()
                        end
                        keyui_settings.key_bind_settings_keyboard.currentboard = layout
                        wipe(keyui_settings.layout_current_keyboard)
                        keyui_settings.layout_current_keyboard[layout] = addon.default_keyboard_layouts[layout]
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, layout)
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
                        local displayText = layout:gsub("QWERTZ_", "") -- Removes "QWERTZ_" from the layout name
                        info.text = displayText
                    elseif subcategory == "AZERTY" then
                        local displayText = layout:gsub("AZERTY_", "") -- Removes "AZERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "QWERTY" then
                        local displayText = layout:gsub("QWERTY_", "") -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "Standard" then
                        local displayText = layout:gsub("DVORAK_", "") -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "RightHand" then
                        local displayText = layout:gsub("DVORAK_RIGHT_", "") -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    elseif subcategory == "LeftHand" then
                        local displayText = layout:gsub("DVORAK_LEFT_", "") -- Removes "QWERTY" from the layout name
                        info.text = displayText
                    else
                        info.text = layout -- For other subcategories, keep the original text
                    end

                    info.value = layout -- Keep the actual value as is
                    info.notCheckable = true
                    info.func = function()
                        -- Discard Keyboard Editor Changes
                        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
                            addon:DiscardKeyboardChanges()
                        else
                            -- clear text input field (DiscardKeyboardChanges does it already)
                            addon.keyboard_control_frame.Input:SetText("")
                            addon.keyboard_control_frame.Input:ClearFocus()
                        end
                        keyui_settings.key_bind_settings_keyboard.currentboard = layout
                        wipe(keyui_settings.layout_current_keyboard)
                        keyui_settings.layout_current_keyboard[layout] = addon.default_keyboard_layouts[layout]
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(self, layout)
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end

    UIDropDownMenu_Initialize(KeyboardLayoutSelecter, KeyboardLayoutSelecter_Initialize)

    return KeyboardLayoutSelecter
end
