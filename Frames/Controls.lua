local name, addon = ...

-- -- Function to create a glowing tutorial highlight around the MinMax button
-- local function ShowTutorialFrame(Controls)

--     local arrow = CreateFrame("Frame", nil, Controls.MinMax, "GlowBoxArrowTemplate")
--     arrow:SetPoint("BOTTOM", Controls.MinMax, "TOP", 0, 4)

--     local frame = CreateFrame("Frame", nil, Controls.MinMax, "GlowBoxTemplate")
--     frame:SetPoint("BOTTOM", arrow, "TOP", 0, -6)
--     frame:SetSize(200, 50)

--     local frametext = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
--     frametext:SetPoint("CENTER", frame, "CENTER")
--     frametext:SetText("Click to open settings")

--     local MaximizeButton = Controls.MinMax.MaximizeButton
--     local MinimizeButton = Controls.MinMax.MinimizeButton

--     local frame2 = CreateFrame("Frame", nil, Controls.MinMax, "GlowBoxTemplate")
--     frame2:SetPoint("CENTER", frame, "CENTER")
--     frame2:SetSize(200, 70)
--     frame2:Hide()

--     if MaximizeButton then
--         MaximizeButton:HookScript("OnClick", function()
--             if frame then
--                 arrow:Hide()
--                 frame:Hide()

--                 frame2:SetPoint("LEFT", addon.keyboard_selector, "RIGHT", 3, 2)
--                 frame2:Show()

--                 local arrow_texture = frame2:CreateTexture(nil, "ARTWORK")
--                 arrow_texture:SetTexture("Interface\\HelpFrame\\Helptip")
--                 arrow_texture:SetSize(128, 32)
--                 arrow_texture:SetPoint("CENTER", frame2, "BOTTOMLEFT", -10, 5)
--                 arrow_texture:SetRotation(math.rad(270))

--                 local frametext2 = frame2:CreateFontString(nil, "ARTWORK", "GameFontWhite")
--                 frametext2:SetPoint("CENTER", frame2, "CENTER")
--                 frametext2:SetText("Click to select a layout")

--                 local close_frame = CreateFrame("Button", nil, frame2, "UIPanelCloseButton")
--                 close_frame:SetPoint("TOPRIGHT", 0, 0)
--                 close_frame:SetFrameLevel(frame2:GetFrameLevel() + 1)
--                 close_frame:SetScript("OnClick", function(s)
--                     frame2:Hide()
--                     keyui_settings.tutorial_completed = true
--                 end)
--             end
--         end)
--     end

--     if MinimizeButton then
--         MinimizeButton:HookScript("OnClick", function()
--             if frame then
--                 arrow:Hide()
--                 frame:Hide()
--                 frame2:Hide()
--             end
--         end)
--     end
-- end

    -- -- Show tutorial if not completed
    -- if keyui_settings.tutorial_completed ~= true then
    --     ShowTutorialFrame(keyboard_control_frame)
    -- end

function addon:create_controls()
    local controls_frame = CreateFrame("Frame", "keyui_keyboard_control_frame", UIParent, "BackdropTemplate")
    addon.controls_frame = controls_frame

    if addon.keyboard_frame then
        local keyboard_level = addon.keyboard_frame:GetFrameLevel()
        controls_frame:SetFrameLevel(keyboard_level + 3)
    end

    controls_frame:SetHeight(260)
    controls_frame:SetWidth(500)
    controls_frame:SetPoint("TOP", UIParent, "TOP", 0, -50)

    controls_frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    controls_frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    controls_frame:SetMovable(true)
    controls_frame:SetClampedToScreen(true)

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_keyboard_control_frame")
    end

    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }

    controls_frame:SetBackdrop(backdropInfo)
    controls_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)

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

    -- Calculate 1/3 and 2/3 of the width of keyboard_control_frame
    local offset_one_third = controls_frame:GetWidth() * (1 / 3)
    local offset_two_thirds = controls_frame:GetWidth() * (2 / 3)

    -- Text "Layout"
    controls_frame.Layout = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controls_frame.Layout:SetText("Layout")
    controls_frame.Layout:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.Layout:SetPoint("CENTER", controls_frame, "LEFT", 380, 25)
    controls_frame.Layout:SetTextColor(1, 1, 1)

    addon:switch_layout_selector()

    --Size

    controls_frame.text_size = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controls_frame.text_size:SetText("Size: " .. string.format("%.2f", addon.keyboard_frame:GetScale()))
    controls_frame.text_size:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.text_size:SetPoint("CENTER", controls_frame, "LEFT", offset_one_third, 25)
    controls_frame.text_size:SetTextColor(1, 1, 1)

    local minValue = 0.5  -- Minimum slider value
    local maxValue = 1.5  -- Maximum slider value
    local stepSize = 0.01  -- Minimum step size for slider value change

    -- Create the slider control
    controls_frame.Slider = CreateFrame("Slider", nil, controls_frame, "MinimalSliderTemplate")
    controls_frame.Slider:SetSize(180, 40)
    controls_frame.Slider:SetPoint("CENTER", controls_frame.text_size, "CENTER", 0, -30)
    controls_frame.Slider:Show()

    -- Set the min and max values for the slider
    controls_frame.Slider:SetMinMaxValues(minValue, maxValue)
    controls_frame.Slider:SetValueStep(stepSize)  -- Set the step size for the slider

    -- Function to update the slider value based on the active control tab
    local function update_slider_value()
        if addon.active_control_tab == "keyboard" then
            controls_frame.Slider:SetValue(addon.keyboard_frame:GetScale())  -- Initial value for the keyboard frame scale
        elseif addon.active_control_tab == "mouse" then
            controls_frame.Slider:SetValue(addon.mouse_image:GetScale())  -- Initial value for the mouse image scale
        end
    end

    -- Initialize slider value based on the active control tab
    update_slider_value()

    -- Set the slider value when it changes
    controls_frame.Slider:SetScript("OnValueChanged", function(self, value)
        -- Round the value to the nearest multiple of the step size (0.01)
        local rounded_value = math.floor(value / stepSize + 0.5) * stepSize

        -- Check the active control tab and apply the scale change to the appropriate frame
        if addon.active_control_tab == "keyboard" then
            -- Apply the rounded value to the keyboard frame's scale
            addon.keyboard_frame:SetScale(rounded_value)
        elseif addon.active_control_tab == "mouse" then
            -- Apply the rounded value to the mouse image's scale
            addon.mouse_image:SetScale(rounded_value)
        end

        -- Update the displayed text with the new value
        controls_frame.text_size:SetText("Size: " .. string.format("%.2f", rounded_value))

        -- Set the slider to the rounded value to ensure it matches the step size
        self:SetValue(rounded_value)
    end)

    -- Create the 'Back' button (left arrow button)
    local back_button = CreateFrame("Button", nil, controls_frame, "BackdropTemplate")
    back_button:SetSize(11, 19)
    back_button:SetPoint("RIGHT", controls_frame.Slider, "LEFT", -4, 0)

    -- Set the texture for the 'Back' button using the Atlas
    local back_texture = back_button:CreateTexture(nil, "BACKGROUND")
    back_texture:SetAtlas("Minimal_SliderBar_Button_Left")  -- Use the Atlas for the back button
    back_texture:SetAllPoints(back_button)

    -- Action for back button click
    back_button:SetScript("OnClick", function()
        local current_value = controls_frame.Slider:GetValue()
        controls_frame.Slider:SetValue(current_value - 0.05)  -- Adjust the step if needed
    end)

    -- Create the 'Forward' button (right arrow button)
    local forward_button = CreateFrame("Button", nil, controls_frame, "BackdropTemplate")
    forward_button:SetSize(9, 18)
    forward_button:SetPoint("LEFT", controls_frame.Slider, "RIGHT", 4, 0)

    -- Set the texture for the 'Forward' button using the Atlas
    local forward_texture = forward_button:CreateTexture(nil, "BACKGROUND")
    forward_texture:SetAtlas("Minimal_SliderBar_Button_Right")  -- Use the Atlas for the forward button
    forward_texture:SetAllPoints(forward_button)

    -- Action for forward button click
    forward_button:SetScript("OnClick", function()
        local current_value = controls_frame.Slider:GetValue()
        controls_frame.Slider:SetValue(current_value + 0.05)  -- Adjust the step if needed
    end)

    --Size

    --Buttons

    controls_frame.Display = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controls_frame.Display:SetText("Display Options")
    controls_frame.Display:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.Display:SetPoint("CENTER", controls_frame, "BOTTOMLEFT", offset_one_third, 60)
    controls_frame.Display:Show()
    controls_frame.Display:SetTextColor(1, 1, 1)

    controls_frame.SwitchEmptyBinds = CreateFrame("Button", nil, controls_frame, "UIPanelButtonTemplate")
    controls_frame.SwitchEmptyBinds:SetSize(150, 26)
    controls_frame.SwitchEmptyBinds:SetPoint("LEFT", controls_frame.Display, "CENTER", 4, -30)
    controls_frame.SwitchEmptyBinds:Show()

    local SwitchBindsText = controls_frame.SwitchEmptyBinds:CreateFontString(nil, "OVERLAY")
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
        addon:highlight_empty_binds()
    end

    controls_frame.SwitchEmptyBinds:SetScript("OnClick", ToggleEmptyBinds)
    controls_frame.SwitchEmptyBinds:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Toggle highlighting of keys without keybinds")
        GameTooltip:Show()
    end)
    controls_frame.SwitchEmptyBinds:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    controls_frame.SwitchInterfaceBinds = CreateFrame("Button", nil, controls_frame,
        "UIPanelButtonTemplate")
    controls_frame.SwitchInterfaceBinds:SetSize(150, 26)
    controls_frame.SwitchInterfaceBinds:SetPoint("RIGHT", controls_frame.Display, "CENTER", -4, -30)
    controls_frame.SwitchInterfaceBinds:Show()

    local SwitchInterfaceText = controls_frame.SwitchInterfaceBinds:CreateFontString(nil, "OVERLAY")
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
        addon:create_action_labels()
    end

    controls_frame.SwitchInterfaceBinds:SetScript("OnClick", ToggleInterfaceBinds)
    controls_frame.SwitchInterfaceBinds:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Show/Hide the Interface Action of Keys")
        GameTooltip:Show()
    end)
    controls_frame.SwitchInterfaceBinds:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    --Buttons

    --Modifier

    --alt
    -- Create a font string for the text "Alt" and position it below the checkbutton
    controls_frame.AltText = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    controls_frame.AltText:SetText("Alt")
    controls_frame.AltText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.AltText:SetPoint("CENTER", controls_frame.Display, "CENTER", 192, 0)
    controls_frame.AltText:Show()

    controls_frame.AltCB = CreateFrame("CheckButton", nil, controls_frame, "UICheckButtonArtTemplate")
    controls_frame.AltCB:SetSize(32, 36)
    controls_frame.AltCB:SetHitRectInsets(0, 0, 0, -10)
    controls_frame.AltCB:SetPoint("CENTER", controls_frame.AltText, "CENTER", 0, -30)
    controls_frame.AltCB:Show()

    -- Set the OnClick script for the checkbutton
    controls_frame.AltCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            -- Set ALT modifier and update checkbox state
            addon.modif.ALT = true
            addon.alt_checkbox = true
        else
            -- Disable ALT modifier and reset checkbox states
            addon.modif.ALT = false
            addon.alt_checkbox = false
        end
        
        -- Update the current modifier string and refresh keys based on the new state
        addon:update_modifier_string()
        addon:refresh_keys()

    end)
    SetCheckboxTooltip(controls_frame.AltCB, "Toggle Alt key modifier")
    --alt

    --ctrl
    -- Create a font string for the text "Ctrl" and position it below the checkbutton
    controls_frame.CtrlText = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    controls_frame.CtrlText:SetText("Ctrl")
    controls_frame.CtrlText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.CtrlText:SetPoint("CENTER", controls_frame.AltText, "CENTER", 50, 0)
    controls_frame.CtrlText:Show()

    controls_frame.CtrlCB = CreateFrame("CheckButton", nil, controls_frame, "UICheckButtonArtTemplate")
    controls_frame.CtrlCB:SetSize(32, 36)
    controls_frame.CtrlCB:SetHitRectInsets(0, 0, 0, -10)
    controls_frame.CtrlCB:SetPoint("CENTER", controls_frame.CtrlText, "CENTER", 0, -30)
    controls_frame.CtrlCB:Show()

    -- Set the OnClick script for the checkbutton
    controls_frame.CtrlCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            -- Set CTRL modifier and update checkbox state
            addon.modif.CTRL = true
            addon.ctrl_checkbox = true
        else
            -- Disable CTRL modifier and reset checkbox state
            addon.modif.CTRL = false
            addon.ctrl_checkbox = false
        end

        -- Update the current modifier string and refresh keys based on the new state
        addon:update_modifier_string()
        addon:refresh_keys()
    end)
    SetCheckboxTooltip(controls_frame.CtrlCB, "Toggle Ctrl key modifier")
    --ctrl

    --shift
    -- Create a font string for the text "Shift" and position it below the checkbutton
    controls_frame.ShiftText = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    controls_frame.ShiftText:SetText("Shift")
    controls_frame.ShiftText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.ShiftText:SetPoint("CENTER", controls_frame.CtrlText, "CENTER", 50, 0)
    controls_frame.ShiftText:Show()

    controls_frame.ShiftCB = CreateFrame("CheckButton", nil, controls_frame, "UICheckButtonArtTemplate")
    controls_frame.ShiftCB:SetSize(32, 36)
    controls_frame.ShiftCB:SetHitRectInsets(0, 0, 0, -10)
    controls_frame.ShiftCB:SetPoint("CENTER", controls_frame.ShiftText, "CENTER", 0, -30)
    controls_frame.ShiftCB:Show()

    -- Set the OnClick script for the checkbutton
    controls_frame.ShiftCB:SetScript("OnClick", function(s)
        if s:GetChecked() then
            -- Set SHIFT modifier and update checkbox state
            addon.modif.SHIFT = true
            addon.shift_checkbox = true
        else
            -- Disable SHIFT modifier and reset checkbox state
            addon.modif.SHIFT = false
            addon.shift_checkbox = false
        end

        -- Update the current modifier string and refresh keys based on the new state
        addon:update_modifier_string()
        addon:refresh_keys()
    end)
    SetCheckboxTooltip(controls_frame.ShiftCB, "Toggle Shift key modifier")
    --shift

    --Modifier

    --Edit Menu

    controls_frame.InputText = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controls_frame.InputText:SetText("Name")
    controls_frame.InputText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.InputText:SetPoint("CENTER", controls_frame, "TOPLEFT", 380, -20)
    controls_frame.InputText:Show()
    controls_frame.InputText:SetTextColor(1, 1, 1)

    controls_frame.Input = CreateFrame("EditBox", nil, controls_frame, "InputBoxInstructionsTemplate")
    controls_frame.Input:SetSize(130, 30)
    controls_frame.Input:SetPoint("CENTER", controls_frame.InputText, "CENTER", 0, -30)
    controls_frame.Input:Show()
    controls_frame.Input:SetAutoFocus(false)

    controls_frame.EditText = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controls_frame.EditText:SetText("Edit Menu")
    controls_frame.EditText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    controls_frame.EditText:SetPoint("CENTER", controls_frame, "TOPLEFT", offset_one_third, -20)
    controls_frame.EditText:Show()
    controls_frame.EditText:SetTextColor(1, 1, 1)

    controls_frame.Save = CreateFrame("Button", nil, controls_frame, "UIPanelButtonTemplate")
    controls_frame.Save:SetSize(70, 26)
    controls_frame.Save:SetPoint("CENTER", controls_frame.EditText, "CENTER", 0, -30)
    controls_frame.Save:Show()

    controls_frame.Save:SetScript("OnClick", function() addon:save_keyboard_layout() end)
    local SaveText = controls_frame.Save:CreateFontString(nil, "OVERLAY")
    SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
    SaveText:SetPoint("CENTER", 0, 1)
    SaveText:SetText("Save")

    controls_frame.Save:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Save the current layout.")
        GameTooltip:Show()
    end)

    controls_frame.Save:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Define the confirmation dialog
    StaticPopupDialogs["KEYUI_LAYOUT_CONFIRM_DELETE"] = {
        text = "Are you sure you want to delete the selected layout?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            -- delete edited changes and remove glowboxes
            if addon.active_control_tab == "keyboard" then
                addon:discard_keyboard_changes()

                -- Function to delete the selected keyboard layout
                local selectedLayout = UIDropDownMenu_GetText(addon.keyboard_selector)

                -- Ensure selectedLayout is not nil before proceeding
                if selectedLayout then
                    -- Remove the selected layout from the KeyboardEditLayouts table
                    keyui_settings.layout_edited_keyboard[selectedLayout] = nil

                    -- Clear the text in the Input field for the keyboard
                    controls_frame.Input:SetText("")

                    -- Print a message indicating which layout was deleted
                    print("KeyUI: Deleted the keyboard layout '" .. selectedLayout .. "'.")

                    wipe(keyui_settings.layout_current_keyboard)

                    if addon.keyboard_selector then
                        addon.keyboard_selector:SetDefaultText("Select Layout")
                        addon.keyboard_selector:Hide()
                        addon.keyboard_selector:Show()
                    end

                    addon:refresh_layouts()
                else
                    print("KeyUI: Error - No keyboard layout selected to delete.")
                end
            elseif addon.active_control_tab == "mouse" then
                addon:discard_mouse_changes()

                -- Function to delete the selected mouse layout
                local selectedMouseLayout = UIDropDownMenu_GetText(addon.mouse_selector)

                -- Ensure selectedMouseLayout is not nil before proceeding
                if selectedMouseLayout then
                    -- Remove the selected layout from the MouseEditLayouts table
                    keyui_settings.layout_edited_mouse[selectedMouseLayout] = nil

                    -- Clear the text in the Input field for the mouse
                    controls_frame.Input:SetText("")

                    -- Print a message indicating which layout was deleted
                    print("KeyUI: Deleted the mouse layout '" .. selectedMouseLayout .. "'.")

                    wipe(keyui_settings.layout_current_mouse)

                    if addon.mouse_selector then
                        addon.mouse_selector:SetDefaultText("Select Layout")
                        addon.mouse_selector:Hide()
                        addon.mouse_selector:Show()
                    end

                    addon:refresh_layouts()
                else
                    print("KeyUI: Error - No mouse layout selected to delete.")
                end
            elseif addon.active_control_tab == "controller" then
                addon:discard_controller_changes()

                -- Function to delete the selected controller layout
                local selectedcontrollerLayout = UIDropDownMenu_GetText(addon.controller_selector)

                -- Ensure selectedcontrollerLayout is not nil before proceeding
                if selectedcontrollerLayout then
                    -- Remove the selected layout from the controllerEditLayouts table
                    keyui_settings.layout_edited_controller[selectedcontrollerLayout] = nil

                    -- Clear the text in the Input field for the controller
                    controls_frame.Input:SetText("")

                    -- Print a message indicating which layout was deleted
                    print("KeyUI: Deleted the controller layout '" .. selectedcontrollerLayout .. "'.")

                    wipe(keyui_settings.layout_current_controller)

                    addon.controller_system = nil  -- Set to nil if the layout_type is not defined
                    addon:update_controller_image()

                    if addon.controller_selector then
                        addon.controller_selector:SetDefaultText("Select Layout")
                        addon.controller_selector:Hide()
                        addon.controller_selector:Show()
                    end

                    addon:refresh_layouts()
                else
                    print("KeyUI: Error - No controller layout selected to delete.")
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- Avoids conflicts with other popups
    }

    controls_frame.Delete = CreateFrame("Button", nil, controls_frame, "UIPanelSquareButton")
    controls_frame.Delete:SetSize(28, 28)
    controls_frame.Delete:Show()

    if addon.active_control_tab == "keyboard" then
        addon.controls_frame.Delete:SetPoint("LEFT", addon.keyboard_selector, "RIGHT", 8, 0)
    elseif addon.active_control_tab == "mouse" then
        addon.controls_frame.Delete:SetPoint("LEFT", addon.mouse_selector, "RIGHT", 8, 0)
    elseif addon.active_control_tab == "controller" then
        addon.controls_frame.Delete:SetPoint("LEFT", addon.controller_selector, "RIGHT", 8, 0)
    end

    -- OnClick handler to show confirmation dialog
    controls_frame.Delete:SetScript("OnClick", function(self)
        if addon.active_control_tab == "keyboard" then
            if not addon.keyboard_selector then
                print("KeyUI: Error - No keyboard layout selected.")
                return
            end
        elseif addon.active_control_tab == "mouse" then
            if not addon.mouse_selector then
                print("KeyUI: Error - No mouse layout selected.")
                return
            end
        elseif addon.active_control_tab == "controller" then
            if not addon.controller_selector then
                print("KeyUI: Error - No controller layout selected.")
                return
            end
        end

        -- Show the confirmation dialog
        StaticPopup_Show("KEYUI_LAYOUT_CONFIRM_DELETE")
    end)

    controls_frame.Delete:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Delete Layout")
        GameTooltip:AddLine("- Delete the current layout if it's custom", 1, 1, 1)
        GameTooltip:Show()
    end)

    controls_frame.Delete:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    controls_frame.Lock = CreateFrame("Button", nil, controls_frame, "UIPanelButtonTemplate")
    controls_frame.Lock:SetSize(70, 26)
    controls_frame.Lock:SetPoint("RIGHT", controls_frame.Save, "LEFT", -5, 0)
    controls_frame.Lock:Show()

    -- Create and store the LockText in the frame table
    controls_frame.LockText = controls_frame.Lock:CreateFontString(nil, "OVERLAY")
    controls_frame.LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    controls_frame.LockText:SetPoint("CENTER", 0, 1)

    if addon.keyboard_locked == false then
        controls_frame.LockText:SetText("Lock")
    else
        controls_frame.LockText:SetText("Unlock")
    end

    local function ToggleLock()
        if addon.keyboard_locked then
            addon.keyboard_locked = false
            controls_frame.LockText:SetText("Lock")
            if controls_frame.glowBoxLock then
                controls_frame.glowBoxLock:Show()
                controls_frame.glowBoxSave:Hide()
                controls_frame.glowBoxInput:Hide()
            end

            -- disable modifier
            addon.modif.ALT = false
            addon.modif.CTRL = false
            addon.modif.SHIFT = false

            -- reset checkbox states
            addon.alt_checkbox = false
            addon.ctrl_checkbox = false
            addon.shift_checkbox = false
            if addon.controls_frame.AltCB then
                addon.controls_frame.AltCB:SetChecked(false)
            end
            if addon.controls_frame.CtrlCB then
                addon.controls_frame.CtrlCB:SetChecked(false)
            end
            if addon.controls_frame.ShiftCB then
                addon.controls_frame.ShiftCB:SetChecked(false)
            end

            print("KeyUI: The keyboard is now unlocked! You can edit key bindings. 'Lock' the changes when done.")
        else
            addon.keyboard_locked = true
            controls_frame.LockText:SetText("Unlock")
            if controls_frame.glowBoxLock then
                controls_frame.glowBoxLock:Hide()
            end
            if addon.keys_keyboard_edited == true then
                controls_frame.glowBoxSave:Show()
                controls_frame.glowBoxInput:Show()
                print("KeyUI: Changes are now locked. Please enter a name and save your layout.")
            else
                controls_frame.glowBoxSave:Hide()
                controls_frame.glowBoxInput:Hide()
                print("KeyUI: No Changes detected (Keyboard).")
            end
        end
    end

    controls_frame.Lock:SetScript("OnClick", function(self) ToggleLock() end)

    controls_frame.Lock:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Toggle Editor Mode")
        GameTooltip:AddLine("- Assign new keybindings by pushing keys", 1, 1, 1)
        GameTooltip:Show()
    end)

    controls_frame.Lock:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Create the Discard button
    controls_frame.Discard = CreateFrame("Button", nil, controls_frame, "UIPanelButtonTemplate")
    controls_frame.Discard:SetSize(70, 26)  -- Set the size of the button
    controls_frame.Discard:SetPoint("LEFT", controls_frame.Save, "RIGHT", 5, 0)
    controls_frame.Discard:Show()

    -- Create the font string for the button text
    local DiscardText = controls_frame.Discard:CreateFontString(nil, "OVERLAY")
    DiscardText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set the font
    DiscardText:SetPoint("CENTER", 0, 1)  -- Center the text in the button
    DiscardText:SetText("Discard")  -- Set the button text

    -- Set the script to call the Discard function when clicked
    controls_frame.Discard:SetScript("OnClick", function()
        addon:discard_keyboard_changes()  -- Call the discard_keyboard_changes function
    end)

    controls_frame.Discard:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Discard Changes")
        GameTooltip:AddLine("- Revert any unsaved keybinding changes", 1, 1, 1)
        GameTooltip:AddLine("- Reset the keyboard layout to the last saved state", 1, 1, 1)
        GameTooltip:Show()
    end)

    controls_frame.Discard:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    controls_frame.glowBoxLock = CreateFrame("Frame", nil, controls_frame, "GlowBorderTemplate")
    controls_frame.glowBoxLock:SetSize(68, 24)
    controls_frame.glowBoxLock:SetPoint("CENTER", controls_frame.Lock, "CENTER", 0, 0)
    controls_frame.glowBoxLock:Hide()
    controls_frame.glowBoxLock:SetFrameLevel(controls_frame.Lock:GetFrameLevel() - 1)

    controls_frame.glowBoxSave = CreateFrame("Frame", nil, controls_frame, "GlowBorderTemplate")
    controls_frame.glowBoxSave:SetSize(68, 24)
    controls_frame.glowBoxSave:SetPoint("CENTER", controls_frame.Save, "CENTER", 0, 0)
    controls_frame.glowBoxSave:Hide()
    controls_frame.glowBoxSave:SetFrameLevel(controls_frame.Save:GetFrameLevel() - 1)

    controls_frame.glowBoxInput = CreateFrame("Frame", nil, controls_frame, "GlowBorderTemplate")
    controls_frame.glowBoxInput:SetSize(136, 18)
    controls_frame.glowBoxInput:SetPoint("CENTER", controls_frame.Input, "CENTER", -2, 0)
    controls_frame.glowBoxInput:Hide()
    controls_frame.glowBoxInput:SetFrameLevel(controls_frame.Input:GetFrameLevel() - 1)

    --Edit Menu

    controls_frame.Close = CreateFrame("Button", nil, controls_frame, "UIPanelCloseButton")
    controls_frame.Close:SetSize(22, 22)
    controls_frame.Close:SetPoint("TOPRIGHT", 0, 0)
    controls_frame.Close:SetScript("OnClick", function(s)
        addon:discard_keyboard_changes()
        controls_frame:Hide()

        if addon.keyboard_frame and addon.keyboard_frame.controls_button then
            addon.keyboard_frame.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
            addon.keyboard_frame.controls_button.LeftActive:Hide()
            addon.keyboard_frame.controls_button.MiddleActive:Hide()
            addon.keyboard_frame.controls_button.RightActive:Hide()
            addon.keyboard_frame.controls_button.Left:Show()
            addon.keyboard_frame.controls_button.Middle:Show()
            addon.keyboard_frame.controls_button.Right:Show()
        end

        if addon.mouse_image and addon.mouse_image.controls_button then
            addon.mouse_image.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
            addon.mouse_image.controls_button.LeftActive:Hide()
            addon.mouse_image.controls_button.MiddleActive:Hide()
            addon.mouse_image.controls_button.RightActive:Hide()
            addon.mouse_image.controls_button.Left:Show()
            addon.mouse_image.controls_button.Middle:Show()
            addon.mouse_image.controls_button.Right:Show()
        end

        if addon.controller_frame and addon.controller_frame.controls_button then
            addon.controller_frame.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
            addon.controller_frame.controls_button.LeftActive:Hide()
            addon.controller_frame.controls_button.MiddleActive:Hide()
            addon.controller_frame.controls_button.RightActive:Hide()
            addon.controller_frame.controls_button.Left:Show()
            addon.controller_frame.controls_button.Middle:Show()
            addon.controller_frame.controls_button.Right:Show()
        end

    end)

    -- Helper function to adjust button and text widths
    local function adjust_button_width(button, frame_width)
        local button_width = (frame_width - 32) / 3 -- Calculate 1/3 of the frame width
        button:SetWidth(button_width) -- Set the button width

        local font_string = button:GetFontString()
        if font_string then
            font_string:SetWidth(button_width) -- Adjust the text width with some padding
            font_string:SetJustifyH("CENTER") -- Ensure the text is centered
        end
    end

    -- Apply custom font to the tab buttons
    local custom_font = CreateFont("controls_tab_custom_font")
    custom_font:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16, "OUTLINE")

    -- Create the keyboard tab button
    controls_frame.keyboard_button = CreateFrame("Button", nil, controls_frame, "PanelTabButtonTemplate")
    controls_frame.keyboard_button:SetPoint("TOPLEFT", controls_frame, "BOTTOMLEFT", 8, 0)

    -- Create the mouse tab button
    controls_frame.mouse_button = CreateFrame("Button", nil, controls_frame, "PanelTabButtonTemplate")
    controls_frame.mouse_button:SetPoint("BOTTOMLEFT", controls_frame.keyboard_button, "BOTTOMRIGHT", 8, 0)

    -- Create the controller tab button
    controls_frame.controller_button = CreateFrame("Button", nil, controls_frame, "PanelTabButtonTemplate")
    controls_frame.controller_button:SetPoint("BOTTOMLEFT", controls_frame.mouse_button, "BOTTOMRIGHT", 8, 0)

    -- Show active textures for the current tab
    addon:update_tab_textures()

    -- Now, adjust button widths after all buttons are created
    local frame_width = controls_frame:GetWidth()
    adjust_button_width(controls_frame.keyboard_button, frame_width)
    adjust_button_width(controls_frame.mouse_button, frame_width)
    adjust_button_width(controls_frame.controller_button, frame_width)

    -- Set button text and font for the keyboard tab button
    controls_frame.keyboard_button:SetText("Keyboard")
    controls_frame.keyboard_button:SetNormalFontObject(custom_font)
    controls_frame.keyboard_button:SetHighlightFontObject(custom_font)
    controls_frame.keyboard_button:SetDisabledFontObject(custom_font)

    -- Adjust text properties for the keyboard tab button
    local text = controls_frame.keyboard_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("TOP", controls_frame.keyboard_button, "TOP", 0, -6)
    text:SetTextColor(1, 1, 1) -- Set text color to white
    text:SetJustifyH("CENTER") -- Ensure text is centered

    -- Set OnClick behavior for keyboard tab button
    controls_frame.keyboard_button:SetScript("OnClick", function(s)
        addon.active_control_tab = "keyboard"  -- Set the active tab to "keyboard"
        addon:update_tab_textures()  -- Call the function to update the textures
        update_slider_value()   -- After switching, update the slider value
    end)

    -- Set OnShow behavior for keyboard tab button
    controls_frame.keyboard_button:SetScript("OnShow", function(s)
        local frame_width = controls_frame:GetWidth()
        adjust_button_width(controls_frame.keyboard_button, frame_width)
    end)

    -- Set button text and font for the mouse tab button
    controls_frame.mouse_button:SetText("Mouse")
    controls_frame.mouse_button:SetNormalFontObject(custom_font)
    controls_frame.mouse_button:SetHighlightFontObject(custom_font)
    controls_frame.mouse_button:SetDisabledFontObject(custom_font)

    -- Adjust text properties for the mouse tab button
    local text = controls_frame.mouse_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("TOP", controls_frame.mouse_button, "TOP", 0, -6)
    text:SetTextColor(1, 1, 1) -- Set text color to white
    text:SetJustifyH("CENTER") -- Ensure text is centered

    -- Set OnClick behavior for mouse tab button
    controls_frame.mouse_button:SetScript("OnClick", function(s)
        addon.active_control_tab = "mouse"  -- Set the active tab to "mouse"
        addon:update_tab_textures()  -- Call the function to update the textures
        update_slider_value()   -- After switching, update the slider value
    end)

    -- Set OnShow behavior for mouse tab button
    controls_frame.mouse_button:SetScript("OnShow", function(s)
        local frame_width = controls_frame:GetWidth()
        adjust_button_width(controls_frame.mouse_button, frame_width)
    end)

    -- Set button text and font for the controller tab button
    controls_frame.controller_button:SetText("Controller")
    controls_frame.controller_button:SetNormalFontObject(custom_font)
    controls_frame.controller_button:SetHighlightFontObject(custom_font)
    controls_frame.controller_button:SetDisabledFontObject(custom_font)

    -- Adjust text properties for the controller tab button
    local text = controls_frame.controller_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("TOP", controls_frame.controller_button, "TOP", 0, -6)
    text:SetTextColor(1, 1, 1) -- Set text color to white
    text:SetJustifyH("CENTER") -- Ensure text is centered

    -- Set OnClick behavior for controller tab button
    controls_frame.controller_button:SetScript("OnClick", function(s)
        addon.active_control_tab = "controller"  -- Set the active tab to "controller"
        addon:update_tab_textures()  -- Call the function to update the textures
        update_slider_value()   -- After switching, update the slider value
    end)

    -- Set OnShow behavior for controller tab button
    controls_frame.controller_button:SetScript("OnShow", function(s)
        local frame_width = controls_frame:GetWidth()
        adjust_button_width(controls_frame.controller_button, frame_width)
    end)

    return controls_frame
end

-- function addon:CreateMouseControl()
--     local mouse_control_frame = CreateFrame("Frame", "keyui_mouse_control_frame", UIParent, "TooltipBorderedFrameTemplate")
--     addon.mouse_control_frame = mouse_control_frame

--     mouse_control_frame:SetWidth((addon.mouse_image:GetWidth() + 40))
--     mouse_control_frame:SetHeight(190)
--     mouse_control_frame:SetBackdropColor(0, 0, 0, 1);
--     mouse_control_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

--     mouse_control_frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
--     mouse_control_frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
--     mouse_control_frame:SetMovable(true)

--     -- Manage ESC key behavior based on the setting
--     if keyui_settings.prevent_esc_close ~= false then
--         tinsert(UISpecialFrames, "keyui_mouse_control_frame")
--     end

--     -- Calculate 1/2 of the width of keyui_mouse_control_frame
--     local offset_half = mouse_control_frame:GetWidth() * (1 / 2)

--     --Size start
--     mouse_control_frame.EditBox = CreateFrame("EditBox", nil, mouse_control_frame, "InputBoxTemplate")
--     mouse_control_frame.EditBox:SetWidth(60)
--     mouse_control_frame.EditBox:SetHeight(20)
--     mouse_control_frame.EditBox:SetPoint("CENTER", mouse_control_frame, "BOTTOMLEFT", offset_half, 30)
--     mouse_control_frame.EditBox:Show()
--     mouse_control_frame.EditBox:SetMaxLetters(4)
--     mouse_control_frame.EditBox:SetAutoFocus(false)
--     mouse_control_frame.EditBox:SetText(string.format("%.2f", addon.mouse_image:GetScale()))
--     mouse_control_frame.EditBox:SetJustifyH("CENTER")

--     mouse_control_frame.EditBox:SetScript("OnEnterPressed", function(self)
--         local value = tonumber(self:GetText())
--         if value then
--             if value < 0.5 then
--                 value = 0.5
--             elseif value > 1.5 then
--                 value = 1.5
--             end
--             addon.mouse_image:SetScale(value)
--             self:SetText(string.format("%.2f", value))
--         end
--         self:ClearFocus()
--     end)

--     mouse_control_frame.LeftButton = CreateFrame("Button", nil, mouse_control_frame)
--     mouse_control_frame.LeftButton:SetSize(26, 26)
--     mouse_control_frame.LeftButton:SetPoint("CENTER", mouse_control_frame.EditBox, "CENTER", -58, 0)
--     mouse_control_frame.LeftButton:Show()
--     mouse_control_frame.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
--     mouse_control_frame.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
--     mouse_control_frame.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

--     mouse_control_frame.RightButton = CreateFrame("Button", nil, mouse_control_frame)
--     mouse_control_frame.RightButton:SetSize(26, 26)
--     mouse_control_frame.RightButton:SetPoint("CENTER", mouse_control_frame.EditBox, "CENTER", 54, 0)
--     mouse_control_frame.RightButton:Show()
--     mouse_control_frame.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
--     mouse_control_frame.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
--     mouse_control_frame.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

--     mouse_control_frame.LeftButton:SetScript("OnClick", function()
--         local currentValue = addon.mouse_image:GetScale()
--         local step = 0.05
--         local newValue = currentValue - step
--         if newValue < 0.5 then
--             newValue = 0.5
--         end
--         addon.mouse_image:SetScale(newValue)
--         mouse_control_frame.EditBox:SetText(string.format("%.2f", newValue))
--     end)

--     mouse_control_frame.RightButton:SetScript("OnClick", function()
--         local currentValue = addon.mouse_image:GetScale()
--         local step = 0.05
--         local newValue = currentValue + step
--         if newValue > 1.5 then
--             newValue = 1.5
--         end
--         addon.mouse_image:SetScale(newValue)
--         mouse_control_frame.EditBox:SetText(string.format("%.2f", newValue))
--     end)
--     --Size end

--     --Text start
--     mouse_control_frame.Layout = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     mouse_control_frame.Layout:SetText("Layout")
--     mouse_control_frame.Layout:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
--     mouse_control_frame.Layout:SetPoint("LEFT", mouse_control_frame, "BOTTOMLEFT", 10, 160)
--     mouse_control_frame.Layout:SetTextColor(1, 1, 1)

--     mouse_control_frame.Name = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     mouse_control_frame.Name:SetText("Name")
--     mouse_control_frame.Name:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
--     mouse_control_frame.Name:SetPoint("LEFT", mouse_control_frame, "BOTTOMLEFT", 10, 110)
--     mouse_control_frame.Name:SetTextColor(1, 1, 1)

--     mouse_control_frame.Size = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     mouse_control_frame.Size:SetText("Size")
--     mouse_control_frame.Size:SetFont("Fonts\\FRFIZQT__.TTF", 14)
--     mouse_control_frame.Size:SetPoint("LEFT", mouse_control_frame, "BOTTOMLEFT", 10, 30)
--     mouse_control_frame.Size:SetTextColor(1, 1, 1)
--     --Text end

--     --Edit start
--     mouse_control_frame.Input = CreateFrame("EditBox", nil, mouse_control_frame, "InputBoxInstructionsTemplate")
--     mouse_control_frame.Input:SetSize(130, 30)
--     mouse_control_frame.Input:SetPoint("CENTER", mouse_control_frame, "BOTTOMLEFT", offset_half, 110)
--     mouse_control_frame.Input:Show()
--     mouse_control_frame.Input:SetAutoFocus(false)

--     mouse_control_frame.Save = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
--     mouse_control_frame.Save:SetSize(70, 26)
--     mouse_control_frame.Save:SetPoint("CENTER", mouse_control_frame, "BOTTOMLEFT", offset_half, 75)
--     mouse_control_frame.Save:Show()

--     mouse_control_frame.Save:SetScript("OnClick", function() addon:save_mouse_layout() end)
--     local SaveText = mouse_control_frame.Save:CreateFontString(nil, "OVERLAY")
--     SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
--     SaveText:SetPoint("CENTER", 0, 1)
--     SaveText:SetText("Save")

--     mouse_control_frame.Save:SetScript("OnEnter", function(self)
--         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--         GameTooltip:SetText("Save the current layout.")
--         GameTooltip:Show()
--     end)

--     mouse_control_frame.Save:SetScript("OnLeave", function(self)
--         GameTooltip:Hide()
--     end)

--     -- Define the confirmation dialog
--     StaticPopupDialogs["KEYUI_MOUSE_CONFIRM_DELETE"] = {
--         text = "Are you sure you want to delete the selected layout?",
--         button1 = "Yes",
--         button2 = "No",
--         OnAccept = function()
--             -- delete edited changes and remove glowboxes
--             addon:discard_mouse_changes()

--             -- Function to delete the selected layout
--             local selectedLayout = UIDropDownMenu_GetText(addon.mouse_selector)

--             -- Ensure selectedLayout is not nil before proceeding
--             if selectedLayout then
--                 -- Remove the selected layout from the KeyboardEditLayouts table.
--                 keyui_settings.layout_edited_mouse[selectedLayout] = nil

--                 -- Clear the text in the Mouse.Input field.
--                 mouse_control_frame.Input:SetText("")

--                 -- Print a message indicating which layout was deleted.
--                 print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")

--                 wipe(keyui_settings.layout_current_mouse)
--                 UIDropDownMenu_SetText(addon.mouse_selector, "")
--                 addon:refresh_layouts()
--             else
--                 print("KeyUI: Error - No layout selected to delete.")
--             end
--         end,
--         timeout = 0,
--         whileDead = true,
--         hideOnEscape = true,
--         preferredIndex = 3, -- Avoids conflicts with other popups
--     }

--     mouse_control_frame.Delete = CreateFrame("Button", nil, mouse_control_frame, "UIPanelSquareButton")
--     mouse_control_frame.Delete:SetSize(28, 28)
--     mouse_control_frame.Delete:SetPoint("LEFT", addon.mouse_selector, "RIGHT", -12, 2)
--     mouse_control_frame.Delete:Show()

--     -- OnClick handler to show confirmation dialog
--     mouse_control_frame.Delete:SetScript("OnClick", function(self)
--         if not addon.mouse_selector then
--             print("KeyUI: Error - No layout selected.")
--             return
--         end

--         -- Show the confirmation dialog
--         StaticPopup_Show("KEYUI_MOUSE_CONFIRM_DELETE")
--     end)

--     mouse_control_frame.Delete:SetScript("OnEnter", function(self)
--         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--         GameTooltip:SetText("Delete Layout")
--         GameTooltip:AddLine("- Remove the current layout if it's custom", 1, 1, 1)
--         GameTooltip:Show()
--     end)

--     mouse_control_frame.Delete:SetScript("OnLeave", function(self)
--         GameTooltip:Hide()
--     end)

--     mouse_control_frame.Lock = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
--     mouse_control_frame.Lock:SetSize(70, 26)
--     mouse_control_frame.Lock:SetPoint("RIGHT", mouse_control_frame.Save, "LEFT", -5, 0)
--     mouse_control_frame.Lock:Show()

--     -- Create and store the LockText in the frame table
--     mouse_control_frame.LockText = mouse_control_frame.Lock:CreateFontString(nil, "OVERLAY")
--     mouse_control_frame.LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)
--     mouse_control_frame.LockText:SetPoint("CENTER", 0, 1)

--     if addon.mouse_locked == false then
--         mouse_control_frame.LockText:SetText("Lock")
--     else
--         mouse_control_frame.LockText:SetText("Unlock")
--     end

--     local function ToggleLock()
--         if addon.mouse_locked then
--             addon.mouse_locked = false
--             mouse_control_frame.LockText:SetText("Lock")
--             if mouse_control_frame.glowBoxLock then
--                 mouse_control_frame.glowBoxLock:Show()
--                 mouse_control_frame.glowBoxSave:Hide()
--                 mouse_control_frame.glowBoxInput:Hide()
--             end
--             print("KeyUI: The mouse is now unlocked! You can edit key bindings. 'Lock' the changes when done.")
--         else
--             addon.mouse_locked = true
--             mouse_control_frame.LockText:SetText("Unlock")
--             if mouse_control_frame.glowBoxLock then
--                 mouse_control_frame.glowBoxLock:Hide()
--             end
--             if addon.keys_mouse_edited == true then
--                 mouse_control_frame.glowBoxSave:Show()
--                 mouse_control_frame.glowBoxInput:Show()
--                 print("KeyUI: Changes are now locked. Please enter a name and save your layout.")
--             else
--                 mouse_control_frame.glowBoxSave:Hide()
--                 mouse_control_frame.glowBoxInput:Hide()
--                 print("KeyUI: No Changes detected (Mouse).")
--             end
--         end
--     end

--     mouse_control_frame.Lock:SetScript("OnClick", function(self) ToggleLock() end)

--     mouse_control_frame.Lock:SetScript("OnEnter", function(self)
--         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--         GameTooltip:SetText("Toggle Editor Mode")
--         GameTooltip:AddLine("- Drag the keys with left mouse", 1, 1, 1)
--         GameTooltip:AddLine("- Delete keys with Shift + left-click mouse", 1, 1, 1)
--         GameTooltip:AddLine("- Assign new keybindings by pushing keys", 1, 1, 1)
--         GameTooltip:Show()
--     end)

--     mouse_control_frame.Lock:SetScript("OnLeave", function(self)
--         GameTooltip:Hide()
--     end)

--     -- Create the Discard button
--     mouse_control_frame.Discard = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
--     mouse_control_frame.Discard:SetSize(70, 26)  -- Set the size of the button
--     mouse_control_frame.Discard:SetPoint("LEFT", mouse_control_frame.Save, "RIGHT", 5, 0)
--     mouse_control_frame.Discard:Show()

--     -- Create the font string for the button text
--     local DiscardText = mouse_control_frame.Discard:CreateFontString(nil, "OVERLAY")
--     DiscardText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set the font
--     DiscardText:SetPoint("CENTER", 0, 1)  -- Center the text in the button
--     DiscardText:SetText("Discard")  -- Set the button text

--     -- Set the script to call the Discard function when clicked
--     mouse_control_frame.Discard:SetScript("OnClick", function()
--         addon:discard_mouse_changes()  -- Call the discard_mouse_changes function
--     end)

--     mouse_control_frame.Discard:SetScript("OnEnter", function(self)
--         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--         GameTooltip:SetText("Discard Changes")
--         GameTooltip:AddLine("- Revert any unsaved keybinding changes", 1, 1, 1)
--         GameTooltip:AddLine("- Reset the keyboard layout to the last saved state", 1, 1, 1)
--         GameTooltip:Show()
--     end)

--     mouse_control_frame.Discard:SetScript("OnLeave", function(self)
--         GameTooltip:Hide()
--     end)

--     mouse_control_frame.glowBoxLock = CreateFrame("Frame", nil, mouse_control_frame, "GlowBorderTemplate")
--     mouse_control_frame.glowBoxLock:SetSize(68, 24)
--     mouse_control_frame.glowBoxLock:SetPoint("CENTER", mouse_control_frame.Lock, "CENTER", 0, 0)
--     mouse_control_frame.glowBoxLock:Hide()
--     mouse_control_frame.glowBoxLock:SetFrameLevel(mouse_control_frame.Lock:GetFrameLevel() - 1)

--     mouse_control_frame.glowBoxSave = CreateFrame("Frame", nil, mouse_control_frame, "GlowBorderTemplate")
--     mouse_control_frame.glowBoxSave:SetSize(68, 24)
--     mouse_control_frame.glowBoxSave:SetPoint("CENTER", mouse_control_frame.Save, "CENTER", 0, 0)
--     mouse_control_frame.glowBoxSave:Hide()
--     mouse_control_frame.glowBoxSave:SetFrameLevel(mouse_control_frame.Save:GetFrameLevel() - 1)

--     mouse_control_frame.glowBoxInput = CreateFrame("Frame", nil, mouse_control_frame, "GlowBorderTemplate")
--     mouse_control_frame.glowBoxInput:SetSize(136, 18)
--     mouse_control_frame.glowBoxInput:SetPoint("CENTER", mouse_control_frame.Input, "CENTER", -2, 0)
--     mouse_control_frame.glowBoxInput:Hide()
--     mouse_control_frame.glowBoxInput:SetFrameLevel(mouse_control_frame.Input:GetFrameLevel() - 1)

--     --Edit end

--     mouse_control_frame.Close = CreateFrame("Button", nil, mouse_control_frame, "UIPanelCloseButton")
--     mouse_control_frame.Close:SetSize(22, 22)
--     mouse_control_frame.Close:SetPoint("TOPRIGHT", 0, 0)
--     mouse_control_frame.Close:SetScript("OnClick", function(s)
--         addon:discard_mouse_changes()
--         mouse_control_frame:Hide()
--     end)

--     return mouse_control_frame
-- end

-- Helper function to toggle visibility of tab button textures
function addon:toggle_control_tab_button(button, showInactive)
    if showInactive then
        button.LeftActive:Hide()
        button.MiddleActive:Hide()
        button.RightActive:Hide()
        button.Left:Show()
        button.Middle:Show()
        button.Right:Show()
    else
        button.LeftActive:Show()
        button.MiddleActive:Show()
        button.RightActive:Show()
        button.Left:Hide()
        button.Middle:Hide()
        button.Right:Hide()
        button.LeftHighlight:Hide()
        button.MiddleHighlight:Hide()
        button.RightHighlight:Hide()
    end
end

-- Helper function to toggle highlight of controls tab buttons, excluding the caller
function addon:show_controls_button_highlight(excluded_frame)
    local frames = {addon.keyboard_frame, addon.mouse_image, addon.controller_frame}

    for _, frame in ipairs(frames) do
        if frame and frame.controls_button and frame ~= excluded_frame then
            frame.controls_button:SetAlpha(1)
            frame.controls_button.LeftActive:Show()
            frame.controls_button.MiddleActive:Show()
            frame.controls_button.RightActive:Show()
            frame.controls_button.Left:Hide()
            frame.controls_button.Middle:Hide()
            frame.controls_button.Right:Hide()
        end
    end
end

-- Helper function to toggle fade of controls tab buttons, excluding the caller
function addon:fade_controls_button_highlight(excluded_frame)
    local frames = {addon.keyboard_frame, addon.mouse_image, addon.controller_frame}

    for _, frame in ipairs(frames) do
        if frame and frame.controls_button and frame ~= excluded_frame then
            frame.controls_button:SetAlpha(0.5)
            frame.controls_button.LeftActive:Hide()
            frame.controls_button.MiddleActive:Hide()
            frame.controls_button.RightActive:Hide()
            frame.controls_button.Left:Show()
            frame.controls_button.Middle:Show()
            frame.controls_button.Right:Show()
        end
    end
end

-- Function to update the textures based on the active control tab
function addon:update_tab_textures()
    if addon.controls_frame then
        -- Reset all buttons to inactive
        addon:toggle_control_tab_button(addon.controls_frame.keyboard_button, true)
        addon:toggle_control_tab_button(addon.controls_frame.mouse_button, true)
        addon:toggle_control_tab_button(addon.controls_frame.controller_button, true)

        -- Show active textures for the current tab
        if addon.active_control_tab == "keyboard" then
            addon:toggle_control_tab_button(addon.controls_frame.keyboard_button, false)
        elseif addon.active_control_tab == "mouse" then
            addon:toggle_control_tab_button(addon.controls_frame.mouse_button, false)
        elseif addon.active_control_tab == "controller" then
            addon:toggle_control_tab_button(addon.controls_frame.controller_button, false)
        end

        -- Function to handle layout selection based on the active control tab
        addon:switch_layout_selector()
    end
end

-- Function to handle layout selection based on the active control tab
function addon:switch_layout_selector()
    -- Hide both the keyboard and mouse selectors before showing the correct one
    if addon.keyboard_selector then
        addon.keyboard_selector:Hide()
    end

    if addon.mouse_selector then
        addon.mouse_selector:Hide()
    end

    if addon.controller_selector then
        addon.controller_selector:Hide()
    end

    if addon.controls_frame.Delete then
        addon.controls_frame.Delete:Hide()
    end

    -- Check if the active control tab is "keyboard"
    if addon.active_control_tab == "keyboard" then
        -- Create the keyboard layout selector if it doesn't exist yet
        if not addon.keyboard_selector then
            addon:keyboard_layout_selector()  -- Call the function to create it
        end

        -- Set the position of the keyboard selector UI element
        addon.keyboard_selector:SetPoint("CENTER", addon.controls_frame.Layout, "CENTER", -18, -30)

        -- Show the keyboard layout selector
        addon.keyboard_selector:Show()

        -- Set the position of the delete button and show it
        if addon.controls_frame.Delete then
            addon.controls_frame.Delete:SetPoint("LEFT", addon.keyboard_selector, "RIGHT", 8, 0)
            addon.controls_frame.Delete:Show()
        end

        -- Get and set the active layout
        -- local keyboard_active_board = next(keyui_settings.layout_current_keyboard)
        -- if keyboard_active_board == nil then
        --     addon.keyboard_selector:SetText("")
        -- else
        --     addon.keyboard_selector:SetText(keyboard_active_board)
        -- end

    -- Check if the active control tab is "mouse"
    elseif addon.active_control_tab == "mouse" then
        -- Create the mouse layout selector if it doesn't exist yet
        if not addon.mouse_selector then
            addon:mouse_layout_selector()  -- Call the function to create it
        end

        -- Set the position of the mouse selector UI element
        addon.mouse_selector:SetPoint("CENTER", addon.controls_frame.Layout, "CENTER", -18, -30)

        -- Show the mouse layout selector
        addon.mouse_selector:Show()

        if addon.controls_frame.Delete then
            -- Set the position of the delete button and show it
            addon.controls_frame.Delete:SetPoint("LEFT", addon.mouse_selector, "RIGHT", 8, 0)
            addon.controls_frame.Delete:Show()
        end

        -- Get and set the active layout
        -- local mouse_active_board = next(keyui_settings.layout_current_mouse)
        -- if mouse_active_board == nil then
        --     addon.mouse_selector:SetText("")
        -- else
        --     addon.mouse_selector:SetText(mouse_active_board)
        -- end

    -- Check if the active control tab is "controller"
    elseif addon.active_control_tab == "controller" then
        -- Create the controller layout selector if it doesn't exist yet
        if not addon.controller_selector then
            addon:controller_layout_selector()  -- Call the function to create it
        end

        -- Set the position of the controller selector UI element
        addon.controller_selector:SetPoint("CENTER", addon.controls_frame.Layout, "CENTER", -18, -30)

        -- Show the controller layout selector
        addon.controller_selector:Show()

        if addon.controls_frame.Delete then
            -- Set the position of the delete button and show it
            addon.controls_frame.Delete:SetPoint("LEFT", addon.controller_selector, "RIGHT", 8, 0)
            addon.controls_frame.Delete:Show()
        end

        -- Get and set the active layout
        -- local controller_active_board = next(keyui_settings.layout_current_controller)
        -- if controller_active_board == nil then
        --     addon.controller_selector:SetText("")
        -- else
        --     addon.controller_selector:SetText(controller_active_board)
        -- end
        
    end
end

function addon:keyboard_layout_selector()
    -- Create the dropdown button frame
    local keyboard_selector = CreateFrame("DropdownButton", nil, addon.controls_frame, "WowStyle1DropdownTemplate")
    addon.keyboard_selector = keyboard_selector

    keyboard_selector:SetWidth(150)

    -- Order of keyboard layout categories
    local category_order = { "ISO", "ANSI", "DVORAK", "Razer", "Azeron", "ZSA" }
    local board_categories = {
        ["ISO"] = {
            ["QWERTZ"] = { "QWERTZ_100%", "QWERTZ_96%", "QWERTZ_80%", "QWERTZ_75%", "QWERTZ_60%", "QWERTZ_1800", "QWERTZ_HALF", "QWERTZ_PRIMARY" },
            ["AZERTY"] = { "AZERTY_100%", "AZERTY_96%", "AZERTY_80%", "AZERTY_75%", "AZERTY_60%", "AZERTY_1800", "AZERTY_HALF", "AZERTY_PRIMARY" },
        },
        ["ANSI"] = {
            ["QWERTY"] = { "QWERTY_100%", "QWERTY_96%", "QWERTY_80%", "QWERTY_75%", "QWERTY_60%", "QWERTY_1800", "QWERTY_HALF", "QWERTY_PRIMARY" },
        },
        ["DVORAK"] = {
            ["Standard"] = { "DVORAK_100%", "DVORAK_PRIMARY" },
            ["Right Hand"] = { "DVORAK_RIGHT_100%", "DVORAK_RIGHT_PRIMARY" },
            ["Left Hand"] = { "DVORAK_LEFT_100%", "DVORAK_LEFT_PRIMARY" },
        },
        ["Razer"] = { "Tartarus_v1", "Tartarus_v2" },
        ["Azeron"] = { "Cyborg", "Cyborg_II" },
        ["ZSA"] = { "Moonlander_MK_I" },
    }

    -- Mapping table for user-friendly names
    local layout_display_names = {
        ["QWERTZ_100%"] = "QWERTZ 100%",
        ["QWERTZ_96%"] = "QWERTZ 96%",
        ["QWERTZ_80%"] = "QWERTZ 80%",
        ["QWERTZ_75%"] = "QWERTZ 75%",
        ["QWERTZ_60%"] = "QWERTZ 60%",
        ["QWERTZ_1800"] = "QWERTZ 1800",
        ["QWERTZ_HALF"] = "QWERTZ Half",
        ["QWERTZ_PRIMARY"] = "QWERTZ Primary",

        ["AZERTY_100%"] = "AZERTY 100%",
        ["AZERTY_96%"] = "AZERTY 96%",
        ["AZERTY_80%"] = "AZERTY 80%",
        ["AZERTY_75%"] = "AZERTY 75%",
        ["AZERTY_60%"] = "AZERTY 60%",
        ["AZERTY_1800"] = "AZERTY 1800",
        ["AZERTY_HALF"] = "AZERTY Half",
        ["AZERTY_PRIMARY"] = "AZERTY Primary",

        ["QWERTY_100%"] = "QWERTY 100%",
        ["QWERTY_96%"] = "QWERTY 96%",
        ["QWERTY_80%"] = "QWERTY 80%",
        ["QWERTY_75%"] = "QWERTY 75%",
        ["QWERTY_60%"] = "QWERTY 60%",
        ["QWERTY_1800"] = "QWERTY 1800",
        ["QWERTY_HALF"] = "QWERTY Half",
        ["QWERTY_PRIMARY"] = "QWERTY Primary",

        ["DVORAK_100%"] = "100%",
        ["DVORAK_PRIMARY"] = "Primary",
        ["DVORAK_RIGHT_100%"] = "100%",
        ["DVORAK_RIGHT_PRIMARY"] = "Primary",
        ["DVORAK_LEFT_100%"] = "100%",
        ["DVORAK_LEFT_PRIMARY"] = "Primary",

        ["Tartarus_v1"] = "Tartarus v1",
        ["Tartarus_v2"] = "Tartarus v2",
        ["Cyborg"] = "Cyborg",
        ["Cyborg_II"] = "Cyborg II",

        ["Moonlander_MK_I"] = "Moonlander Mark I",
    }

    -- Function to retrieve the user-friendly name
    local function get_display_name(internal_name)
        return layout_display_names[internal_name] or internal_name
    end

    local active_keyboard_board = next(keyui_settings.layout_current_keyboard)

    -- Check if active_keyboard_board contains a valid value and set the default text
    if active_keyboard_board then
        keyboard_selector:SetDefaultText(get_display_name(active_keyboard_board))
    else
        keyboard_selector:SetDefaultText("Select Layout")
    end

    -- Dropdown menu setup function with user-friendly names
    local function keyboard_layout_selector_initialize(dropdown, rootDescription)
        -- Create title
        rootDescription:CreateTitle("Default Layouts")

        -- Add standard layouts by category
        for _, category in ipairs(category_order) do
            local layouts = board_categories[category]

            if type(layouts) == "table" then
                -- Create the main category button
                local categoryButton = rootDescription:CreateButton(category)

                -- For each subcategory or layout, create a submenu or button
                for subcategory, layout_list in pairs(layouts) do
                    -- If the subcategory is a table, it's a second-level submenu
                    if type(layout_list) == "table" then
                        -- Create a submenu for the subcategory
                        local submenuButton = categoryButton:CreateButton(subcategory)

                        -- Add the layouts to this submenu
                        for _, layout in ipairs(layout_list) do
                            local display_name = get_display_name(layout) -- Get the user-friendly name
                            submenuButton:CreateButton(display_name, function()
                                addon:select_keyboard_layout(layout) -- Use the original name
                                keyboard_selector:SetDefaultText(display_name)
                            end)
                        end
                    else
                        -- If it's a simple layout (not a table), create a button for it
                        local display_name = get_display_name(layout_list)
                        categoryButton:CreateButton(display_name, function()
                            addon:select_keyboard_layout(layout_list)
                            keyboard_selector:SetDefaultText(display_name)
                        end)
                    end
                end
            end
        end

        -- Create divider
        rootDescription:CreateDivider()

        -- Create title for custom layouts
        rootDescription:CreateTitle("Custom Layouts")

        -- Add custom layouts
        if type(keyui_settings.layout_edited_keyboard) == "table" then
            for name, layout in pairs(keyui_settings.layout_edited_keyboard) do
                local display_name = get_display_name(name)
                rootDescription:CreateButton(display_name, function()
                    addon:select_custom_keyboard_layout(name, layout)
                    keyboard_selector:SetDefaultText(display_name)
                end)
            end
        end
    end

    -- Initialize the dropdown menu
    keyboard_selector:SetupMenu(keyboard_layout_selector_initialize)

    return keyboard_selector
end

function addon:select_keyboard_layout(layout)
    -- Discard Keyboard Editor Changes
    if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
        addon:discard_keyboard_changes()
    else
        -- clear text input field (discard_keyboard_changes does it already)
        addon.controls_frame.Input:SetText("")
        addon.controls_frame.Input:ClearFocus()
    end

    keyui_settings.key_bind_settings_keyboard.currentboard = layout
    wipe(keyui_settings.layout_current_keyboard)
    keyui_settings.layout_current_keyboard[layout] = addon.default_keyboard_layouts[layout]
    addon:refresh_layouts()
end

function addon:select_custom_keyboard_layout(name, layout)
    -- Logik zur Auswahl eines benutzerdefinierten Layouts
    if not addon.keyboard_locked or addon.keys_keyboard_edited then
        addon:discard_keyboard_changes()
    end
    wipe(keyui_settings.layout_current_keyboard)
    keyui_settings.layout_current_keyboard[name] = layout
    addon:refresh_layouts()
end

function addon:mouse_layout_selector()
    -- Create the dropdown button frame
    local mouse_selector = CreateFrame("DropdownButton", nil, addon.controls_frame, "WowStyle1DropdownTemplate")
    addon.mouse_selector = mouse_selector

    mouse_selector:SetWidth(150)

    -- Order of layouts
    local category_order = { "Layout_2+4x3", "Layout_4x3", "Layout_3x3", "Layout_3x2", "Layout_1+2x2", "Layout_2x2", "Layout_2x1", "Layout_Circle" }

    -- Mapping table for user-friendly names
    local layout_display_names = {
        ["Layout_2+4x3"] = "14 Buttons",
        ["Layout_4x3"] = "12 Buttons",
        ["Layout_3x3"] = "9 Buttons",
        ["Layout_3x2"] = "6 Buttons",
        ["Layout_1+2x2"] = "5 Buttons",
        ["Layout_2x2"] = "4 Buttons",
        ["Layout_2x1"] = "3 Buttons",
        ["Layout_Circle"] = "Circle",
    }

    -- Function to get the user-friendly name
    local function get_display_name(internal_name)
        return layout_display_names[internal_name] or internal_name
    end

    local active_mouse_board = next(keyui_settings.layout_current_mouse)

    -- Check if active_mouse_board contains a valid value and set the default text
    if active_mouse_board then
        mouse_selector:SetDefaultText(get_display_name(active_mouse_board))
    else
        mouse_selector:SetDefaultText("Select Layout")
    end

    -- Dropdown menu setup function
    local function mouse_layout_selector_initialize(dropdown, rootDescription)
        -- Create title
        rootDescription:CreateTitle("Default Layouts")

        for _, layout in ipairs(category_order) do
            local display_name = get_display_name(layout)  -- Get user-friendly name
            rootDescription:CreateButton(display_name, function()
                addon:select_mouse_layout(layout)  -- Select the layout
                mouse_selector:SetDefaultText(display_name)
            end)
        end

        -- Create Divider
        rootDescription:CreateDivider()

        -- Create title
        rootDescription:CreateTitle("Custom Layouts")

        -- Add custom layouts
        if type(keyui_settings.layout_edited_mouse) == "table" then
            for name, layout in pairs(keyui_settings.layout_edited_mouse) do
                local display_name = get_display_name(name)  -- Get user-friendly name
                rootDescription:CreateButton(display_name, function()
                    addon:select_custom_mouse_layout(name, layout)  -- Select the custom layout
                    mouse_selector:SetDefaultText(display_name)
                end)
            end
        end
    end

    -- Initialize the dropdown menu
    mouse_selector:SetupMenu(mouse_layout_selector_initialize)

    return mouse_selector
end

function addon:select_mouse_layout(layout)
    -- Discard mouse Editor Changes
    if addon.mouse_locked == false or addon.keys_mouse_edited == true then
        addon:discard_mouse_changes()
    else
        -- clear text input field (discard_mouse_changes does it already)
        addon.controls_frame.Input:SetText("")
        addon.controls_frame.Input:ClearFocus()
    end

    keyui_settings.key_bind_settings_mouse.currentboard = layout
    wipe(keyui_settings.layout_current_mouse)
    keyui_settings.layout_current_mouse[layout] = addon.default_mouse_layouts[layout]
    addon:refresh_layouts()
end

function addon:select_custom_mouse_layout(name, layout)
    -- Logik zur Auswahl eines benutzerdefinierten Layouts
    if not addon.mouse_locked or addon.keys_mouse_edited then
        addon:discard_mouse_changes()
    end
    wipe(keyui_settings.layout_current_mouse)
    keyui_settings.layout_current_mouse[name] = layout
    addon:refresh_layouts()
end

function addon:controller_layout_selector()
    -- Create the dropdown button frame
    local controller_selector = CreateFrame("DropdownButton", nil, addon.controls_frame, "WowStyle1DropdownTemplate")
    addon.controller_selector = controller_selector

    controller_selector:SetWidth(150)

    -- Order of layouts (including the layout type "xbox")
    local category_order = { "xbox", "ds4", "ds5", "deck" }

    -- Mapping table for user-friendly names
    local layout_display_names = {
        ["xbox"] = "Xbox",
        ["ds4"] = "Playstation 4",
        ["ds5"] = "Playstation 5",
        ["deck"] = "Steam Deck",
    }

    -- Function to get the user-friendly name
    local function get_display_name(internal_name)
        return layout_display_names[internal_name] or internal_name
    end

    local active_controller_board = next(keyui_settings.layout_current_controller)

    -- Check if active_controller_board contains a valid value and set the default text
    if active_controller_board then
        controller_selector:SetDefaultText(get_display_name(active_controller_board))
    else
        controller_selector:SetDefaultText("Select Layout")
    end

    -- Dropdown menu setup function
    local function controller_layout_selector_initialize(dropdown, rootDescription)
        -- Create title
        rootDescription:CreateTitle("Default Layouts")

        for _, layout in ipairs(category_order) do
            local display_name = get_display_name(layout)  -- Get user-friendly name
            rootDescription:CreateButton(display_name, function()
                addon:select_controller_layout(layout)  -- Select the layout
                controller_selector:SetDefaultText(display_name)
            end)
        end

        -- Create Divider
        rootDescription:CreateDivider()

        -- Create title
        rootDescription:CreateTitle("Custom Layouts")

        -- Add custom layouts
        if type(keyui_settings.layout_edited_controller) == "table" then
            for name, layout in pairs(keyui_settings.layout_edited_controller) do
                -- Ensure we check the layout_type if it exists
                if layout.layout_type then
                    local display_name = get_display_name(name)  -- Get user-friendly name
                    rootDescription:CreateButton(display_name, function()
                        addon:select_custom_controller_layout(name, layout)  -- Select the custom layout
                        controller_selector:SetDefaultText(display_name)
                    end)
                end
            end
        end
    end

    -- Initialize the dropdown menu
    controller_selector:SetupMenu(controller_layout_selector_initialize)

    return controller_selector
end

function addon:select_controller_layout(layout)
    -- Discard controller Editor Changes
    if addon.controller_locked == false or addon.keys_controller_edited == true then
        addon:discard_controller_changes()
    else
        -- clear text input field (discard_controller_changes does it already)
        addon.controls_frame.Input:SetText("")
        addon.controls_frame.Input:ClearFocus()
    end

    -- Set the controller system type based on the layout's type if it exists
    if addon.default_controller_layouts[layout] and addon.default_controller_layouts[layout].layout_type then
        addon.controller_system = addon.default_controller_layouts[layout].layout_type
        addon:update_controller_image()
    else
        addon.controller_system = nil
    end

    keyui_settings.key_bind_settings_controller.currentboard = layout
    wipe(keyui_settings.layout_current_controller)
    keyui_settings.layout_current_controller[layout] = addon.default_controller_layouts[layout]
    addon:refresh_layouts()
end

function addon:select_custom_controller_layout(name, layout)
    -- Logik zur Auswahl eines benutzerdefinierten Layouts
    if not addon.controller_locked or addon.keys_controller_edited then
        addon:discard_controller_changes()
    end

    -- Set the controller system type based on the layout's type if it exists
    if layout.layout_type then
        addon.controller_system = layout.layout_type
        addon:update_controller_image()
    else
        addon.controller_system = nil
    end

    wipe(keyui_settings.layout_current_controller)
    keyui_settings.layout_current_controller[name] = layout
    addon:refresh_layouts()
end