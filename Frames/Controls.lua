local name, addon = ...

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

    controls_frame.text_size = controls_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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

    -- Function to update the slider value and text based on the active control tab
    local function update_slider_value()
        local scale_value = 1.0  -- Default scale value

        if addon.active_control_tab == "keyboard" then
            scale_value = addon.keyboard_frame:GetScale()
        elseif addon.active_control_tab == "mouse" then
            scale_value = addon.mouse_image:GetScale()
        elseif addon.active_control_tab == "controller" then
            scale_value = addon.controller_frame:GetScale()
        end

        -- Update the slider's value
        controls_frame.Slider:SetValue(scale_value)

        -- Update the displayed text
        controls_frame.text_size:SetText("Size: " .. string.format("%.2f", scale_value))
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
        elseif addon.active_control_tab == "controller" then
            -- Apply the rounded value to the controller frame's scale
            addon.controller_frame:SetScale(rounded_value)
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
    SwitchBindsText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 12)
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
    SwitchInterfaceText:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 12)
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

    controls_frame.Close = CreateFrame("Button", nil, controls_frame, "UIPanelCloseButton")
    controls_frame.Close:SetSize(22, 22)
    controls_frame.Close:SetPoint("TOPRIGHT", 0, 0)
    controls_frame.Close:SetScript("OnClick", function(s)
        addon:discard_keyboard_changes()
        controls_frame:Hide()
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

    addon.controls_frame:SetScript("OnLoad", function()
        addon:update_tab_visibility()
    end)

    addon.controls_frame:SetScript("OnShow", function()
        addon:update_tab_visibility()

        if addon.name_input_dialog and addon.name_input_dialog:IsVisible() then
            addon.name_input_dialog:Hide()
        end

        if addon.edit_layout_dialog and addon.edit_layout_dialog:IsVisible() then
            addon.edit_layout_dialog:Hide()
        end

        -- Call the discard changes function
        if addon.active_control_tab == "keyboard" and (addon.keys_keyboard_edited == true or addon.keyboard_locked == false) then
            addon:discard_keyboard_changes()
        elseif addon.active_control_tab == "mouse" and (addon.keys_mouse_edited == true or addon.mouse_locked == false) then
            addon:discard_mouse_changes()
        elseif addon.active_control_tab == "controller" and (addon.keys_controller_edited == true or addon.controller_locked == false) then
            addon:discard_controller_changes()
        end
    end)

    addon.controls_frame:SetScript("OnHide", function()

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

    -- Create the "Edit Layout" button
    addon.controls_frame.edit_layout_button = CreateFrame("Button", nil, addon.controls_frame, "UIPanelButtonTemplate")
    addon.controls_frame.edit_layout_button:SetSize(150, 26)
    addon.controls_frame.edit_layout_button:SetPoint("TOP", addon.controls_frame, "TOP", 0, -50)
    addon.controls_frame.edit_layout_button:SetText("Edit Layout")

    -- Access the FontString to modify font and color
    local font_string = addon.controls_frame.edit_layout_button:GetFontString()
    font_string:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 12)
    font_string:SetTextColor(1, 1, 1)

    -- Attach the OnClick handler to the "Edit Layout" button
    addon.controls_frame.edit_layout_button:SetScript("OnClick", function()

        if not addon.edit_layout_dialog then
            addon:create_edit_layout_dialog()
        else
            addon.edit_layout_dialog:Show()
        end

        if addon.active_control_tab == "keyboard" then
            addon.keyboard_locked = false

            if addon.keyboard_frame.edit_frame then
                addon.keyboard_frame.edit_frame:Show()
            end

        elseif addon.active_control_tab == "mouse" then
            addon.mouse_locked = false

            if addon.mouse_image.edit_frame then
                addon.mouse_image.edit_frame:Show()
            end

        elseif addon.active_control_tab == "controller" then
            addon.controller_locked = false

            if addon.controller_frame.edit_frame then
                addon.controller_frame.edit_frame:Show()
            end
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

        addon.controls_frame:Hide()
    end)

    return controls_frame
end

-- Define the function to show the Name Input dialog
function addon:create_name_input_dialog()

    -- Create the name input dialog frame
    local name_input_frame = CreateFrame("Frame", "keyui_name_input_frame", UIParent, "BackdropTemplate")
    name_input_frame:SetSize(400, 170)
    name_input_frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
    name_input_frame:SetFrameStrata("DIALOG")

    tinsert(UISpecialFrames, "keyui_name_input_frame")

    name_input_frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    name_input_frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    name_input_frame:SetMovable(true)
    name_input_frame:SetClampedToScreen(true)

    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }

    name_input_frame:SetBackdrop(backdropInfo)
    name_input_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)

    -- Title text
    name_input_frame.title = name_input_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name_input_frame.title:SetPoint("TOP", name_input_frame, "TOP", 0, -10)
    name_input_frame.title:SetText("Save Layout")
    name_input_frame.title:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 22)
    name_input_frame.title:SetTextColor(1, 1, 1)

    -- Instruction text
    name_input_frame.instruction = name_input_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name_input_frame.instruction:SetPoint("TOP", name_input_frame.title, "BOTTOM", 0, -20)
    name_input_frame.instruction:SetWidth(name_input_frame:GetWidth() - 20)
    name_input_frame.instruction:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 14)
    name_input_frame.instruction:SetTextColor(1, 1, 1)

    -- Function to dynamically update title and instructions
    local function update_input_content()
        -- Get the device name and format it (first letter uppercase, rest lowercase)
        local device_name = addon.active_control_tab:sub(1, 1):upper() .. addon.active_control_tab:sub(2):lower()

        -- Set instruction text
        local instructions = string.format("Enter a name to save the %s layout.", device_name)

        -- Update the instruction text
        name_input_frame.instruction:SetText(instructions)
    end

    -- Update content when the frame is shown
    name_input_frame:SetScript("OnShow", update_input_content)

    -- Update content immediately for the first load
    update_input_content()

    -- Input box
    name_input_frame.input_box = CreateFrame("EditBox", nil, name_input_frame, "InputBoxTemplate")
    name_input_frame.input_box:SetSize(220, 30)
    name_input_frame.input_box:SetScale(1.2)
    name_input_frame.input_box:SetPoint("TOP", name_input_frame.instruction, "BOTTOM", 3, 0)
    name_input_frame.input_box:SetAutoFocus(true)

    local input_name

    if addon.active_control_tab == "keyboard" then
        input_name = next(keyui_settings.layout_current_keyboard)
    elseif addon.active_control_tab == "mouse" then
        input_name = next(keyui_settings.layout_current_mouse)
    elseif addon.active_control_tab == "controller" then
        input_name = next(keyui_settings.layout_current_controller)
    end

    name_input_frame.input_box:SetText(input_name)

    local button_width = name_input_frame:GetWidth() / 2 - 30

    -- Save Button
    name_input_frame.save_button = CreateFrame("Button", nil, name_input_frame)
    name_input_frame.save_button:SetPoint("BOTTOMRIGHT", name_input_frame, "BOTTOM", -10, 20)
    name_input_frame.save_button:SetSize(button_width, 30)

    -- Save Button Text
    local save_text = name_input_frame.save_button:CreateFontString(nil, "OVERLAY")
    save_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    save_text:SetPoint("CENTER", name_input_frame.save_button, "CENTER", 0, 0)
    save_text:SetText("Save")

    -- Save Button Left Cap Texture
    local save_left = name_input_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_left:SetTexture("Interface/Buttons/Dropdown")
    save_left:SetTexCoord(0.03125, 0.53125, 0.470703, 0.560547)
    save_left:SetSize(16, 46)
    save_left:SetPoint("LEFT", name_input_frame.save_button, "LEFT")

    -- Save Button Right Cap Texture
    local save_right = name_input_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_right:SetTexture("Interface/Buttons/Dropdown")
    save_right:SetTexCoord(0.03125, 0.53125, 0.751953, 0.841797)
    save_right:SetSize(16, 46)
    save_right:SetPoint("RIGHT", name_input_frame.save_button, "RIGHT")

    -- Save Button Middle Texture
    local save_middle = name_input_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_middle:SetTexture("Interface/Buttons/Dropdown")
    save_middle:SetTexCoord(0, 0.5, 0.0957031, 0.185547)
    save_middle:SetPoint("LEFT", save_left, "RIGHT")
    save_middle:SetPoint("RIGHT", save_right, "LEFT")
    save_middle:SetHeight(46)

    -- Hover Textures for Save Button
    local save_hover_left = name_input_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_left:SetTexture("Interface/Buttons/Dropdown")
    save_hover_left:SetTexCoord(0.03125, 0.53125, 0.283203, 0.373047) -- TexCoords for "dropdown-hover-left-cap"
    save_hover_left:SetSize(16, 46)
    save_hover_left:SetPoint("LEFT", name_input_frame.save_button, "LEFT")

    local save_hover_right = name_input_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_right:SetTexture("Interface/Buttons/Dropdown")
    save_hover_right:SetTexCoord(0.03125, 0.53125, 0.376953, 0.466797) -- TexCoords for "dropdown-hover-right-cap"
    save_hover_right:SetSize(16, 46)
    save_hover_right:SetPoint("RIGHT", name_input_frame.save_button, "RIGHT")

    local save_hover_middle = name_input_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_middle:SetTexture("Interface/Buttons/Dropdown")
    save_hover_middle:SetTexCoord(0, 0.5, 0.00195312, 0.0917969) -- TexCoords for "_dropdown-hover-middle"
    save_hover_middle:SetPoint("LEFT", save_hover_left, "RIGHT")
    save_hover_middle:SetPoint("RIGHT", save_hover_right, "LEFT")
    save_hover_middle:SetHeight(46)

    local save_hover_text = name_input_frame.save_button:CreateFontString(nil, "HIGHLIGHT")
    save_hover_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    save_hover_text:SetPoint("CENTER", name_input_frame.save_button, "CENTER", 0, 0)
    save_hover_text:SetText("Save")

    name_input_frame.save_button:SetScript("OnClick", function()
        local layout_name = name_input_frame.input_box:GetText()

        -- Call the save function
        if layout_name ~= "" then
            if addon.active_control_tab == "keyboard" then
                addon:save_keyboard_layout(layout_name)
            elseif addon.active_control_tab == "mouse" then
                addon:save_mouse_layout(layout_name)
            elseif addon.active_control_tab == "controller" then
                addon:save_controller_layout(layout_name)
            end
        end

        name_input_frame:Hide()

        if addon.controls_frame then
            addon.controls_frame:Show()
        end
    end)

    -- Cancel Button
    name_input_frame.cancel_button = CreateFrame("Button", nil, name_input_frame)
    name_input_frame.cancel_button:SetPoint("BOTTOMLEFT", name_input_frame, "BOTTOM", 10, 20)
    name_input_frame.cancel_button:SetSize(button_width, 30)

    -- Cancel Button Text
    local cancel_text = name_input_frame.cancel_button:CreateFontString(nil, "OVERLAY")
    cancel_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    cancel_text:SetPoint("CENTER", name_input_frame.cancel_button, "CENTER", 0, 0)
    cancel_text:SetText("Cancel")

    -- Cancel Button Left Cap Texture
    local cancel_left = name_input_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_left:SetTexture("Interface/Buttons/Dropdown")
    cancel_left:SetTexCoord(0.03125, 0.53125, 0.470703, 0.560547)
    cancel_left:SetSize(16, 46)
    cancel_left:SetPoint("LEFT", name_input_frame.cancel_button, "LEFT")

    -- Cancel Button Right Cap Texture
    local cancel_right = name_input_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_right:SetTexture("Interface/Buttons/Dropdown")
    cancel_right:SetTexCoord(0.03125, 0.53125, 0.751953, 0.841797)
    cancel_right:SetSize(16, 46)
    cancel_right:SetPoint("RIGHT", name_input_frame.cancel_button, "RIGHT")

    -- Cancel Button Middle Texture
    local cancel_middle = name_input_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_middle:SetTexture("Interface/Buttons/Dropdown")
    cancel_middle:SetTexCoord(0, 0.5, 0.0957031, 0.185547)
    cancel_middle:SetPoint("LEFT", cancel_left, "RIGHT")
    cancel_middle:SetPoint("RIGHT", cancel_right, "LEFT")
    cancel_middle:SetHeight(46)

    -- Hover Textures for Cancel Button
    local cancel_hover_left = name_input_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_left:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_left:SetTexCoord(0.03125, 0.53125, 0.283203, 0.373047) -- TexCoords for "dropdown-hover-left-cap"
    cancel_hover_left:SetSize(16, 46)
    cancel_hover_left:SetPoint("LEFT", name_input_frame.cancel_button, "LEFT")

    local cancel_hover_right = name_input_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_right:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_right:SetTexCoord(0.03125, 0.53125, 0.376953, 0.466797) -- TexCoords for "dropdown-hover-right-cap"
    cancel_hover_right:SetSize(16, 46)
    cancel_hover_right:SetPoint("RIGHT", name_input_frame.cancel_button, "RIGHT")

    local cancel_hover_middle = name_input_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_middle:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_middle:SetTexCoord(0, 0.5, 0.00195312, 0.0917969) -- TexCoords for "_dropdown-hover-middle"
    cancel_hover_middle:SetPoint("LEFT", cancel_hover_left, "RIGHT")
    cancel_hover_middle:SetPoint("RIGHT", cancel_hover_right, "LEFT")
    cancel_hover_middle:SetHeight(46)

    local cancel_hover_text = name_input_frame.cancel_button:CreateFontString(nil, "HIGHLIGHT")
    cancel_hover_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    cancel_hover_text:SetPoint("CENTER", name_input_frame.cancel_button, "CENTER", 0, 0)
    cancel_hover_text:SetText("Cancel")

    name_input_frame.cancel_button:SetScript("OnClick", function()
        name_input_frame:Hide()

        if not addon.edit_layout_dialog then
            addon:create_edit_layout_dialog()
        else
            addon.edit_layout_dialog:Show()
        end

        if addon.active_control_tab == "keyboard" then
            addon.keyboard_locked = false

            if addon.keyboard_frame.edit_frame then
                addon.keyboard_frame.edit_frame:Show()
            end

        elseif addon.active_control_tab == "mouse" then
            addon.mouse_locked = false

            if addon.mouse_image.edit_frame then
                addon.mouse_image.edit_frame:Show()
            end

        elseif addon.active_control_tab == "controller" then
            addon.controller_locked = false

            if addon.controller_frame.edit_frame then
                addon.controller_frame.edit_frame:Show()
            end

        end
    end)

    name_input_frame:SetScript("OnHide", function()
        name_input_frame:Hide()
    end)

    addon.name_input_dialog = name_input_frame
end

-- Define the function to show the Edit Layout dialog
function addon:create_edit_layout_dialog()

    -- Create the dialog frame
    local dialog_frame = CreateFrame("Frame", "keyui_dialog_frame", UIParent, "BackdropTemplate")
    dialog_frame:SetSize(400, 170)
    dialog_frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
    dialog_frame:SetFrameStrata("DIALOG")
    dialog_frame:SetPropagateKeyboardInput(true)

    tinsert(UISpecialFrames, "keyui_dialog_frame")

    dialog_frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    dialog_frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    dialog_frame:SetMovable(true)
    dialog_frame:SetClampedToScreen(true)

    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }

    dialog_frame:SetBackdrop(backdropInfo)
    dialog_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)

    -- Title text
    dialog_frame.title = dialog_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog_frame.title:SetPoint("TOP", dialog_frame, "TOP", 0, -10)
    dialog_frame.title:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 22)
    dialog_frame.title:SetTextColor(1, 1, 1)

    -- Instruction text
    dialog_frame.instruction = dialog_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog_frame.instruction:SetPoint("TOP", dialog_frame.title, "BOTTOM", 0, -20)
    dialog_frame.instruction:SetWidth(dialog_frame:GetWidth() - 20)
    dialog_frame.instruction:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 14)
    dialog_frame.instruction:SetTextColor(1, 1, 1)

    -- Function to update title and instructions dynamically
    local function update_dialog_content()
        local device_name = addon.active_control_tab:sub(1, 1):upper() .. addon.active_control_tab:sub(2)
        local instructions = ""

        -- Add instructions for all device types
        instructions = instructions ..
            "- Hover over a button and press a key to bind it.\n"

        -- Add additional instructions for mouse or controller
        if addon.active_control_tab == "mouse" or addon.active_control_tab == "controller" then
            instructions = instructions ..
                "- Drag keys with the left mouse button.\n" ..
                "- Remove keys by holding Shift and left-clicking.\n"
        end

        -- Update title and instruction text
        dialog_frame.title:SetText(string.format("Edit %s Layout", device_name))
        dialog_frame.instruction:SetText(instructions)

        -- Ensure the instruction text is left-aligned
        dialog_frame.instruction:SetJustifyH("LEFT")
        dialog_frame.instruction:SetJustifyV("TOP")
    end

    -- Update content on show
    dialog_frame:SetScript("OnShow", update_dialog_content)

    -- Update content immediately for the first load
    update_dialog_content()

    local button_width = dialog_frame:GetWidth() / 2 - 30

    -- Save button
    dialog_frame.save_button = CreateFrame("Button", nil, dialog_frame)
    dialog_frame.save_button:SetPoint("BOTTOMRIGHT", dialog_frame, "BOTTOM", -10, 20)
    dialog_frame.save_button:SetSize(button_width, 30)

    -- Button Text
    local save_text = dialog_frame.save_button:CreateFontString(nil, "OVERLAY")
    save_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    save_text:SetPoint("CENTER", dialog_frame.save_button, "CENTER", 0, 0)
    save_text:SetText("Save")

    -- Left Cap Texture
    local save_left = dialog_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_left:SetTexture("Interface/Buttons/Dropdown")
    save_left:SetTexCoord(0.03125, 0.53125, 0.470703, 0.560547) -- TexCoords for "dropdown-left-cap"
    save_left:SetSize(16, 46)
    save_left:SetPoint("LEFT", dialog_frame.save_button, "LEFT")

    -- Right Cap Texture
    local save_right = dialog_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_right:SetTexture("Interface/Buttons/Dropdown")
    save_right:SetTexCoord(0.03125, 0.53125, 0.751953, 0.841797) -- TexCoords for "dropdown-right-cap"
    save_right:SetSize(16, 46)
    save_right:SetPoint("RIGHT", dialog_frame.save_button, "RIGHT")

    -- Middle Texture
    local save_middle = dialog_frame.save_button:CreateTexture(nil, "ARTWORK")
    save_middle:SetTexture("Interface/Buttons/Dropdown")
    save_middle:SetTexCoord(0, 0.5, 0.0957031, 0.185547) -- TexCoords for "_dropdown-middle"
    save_middle:SetPoint("LEFT", save_left, "RIGHT")
    save_middle:SetPoint("RIGHT", save_right, "LEFT")
    save_middle:SetHeight(46)

    -- Hover Texture for Save Button (Left)
    local save_hover_left = dialog_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_left:SetTexture("Interface/Buttons/Dropdown")
    save_hover_left:SetTexCoord(0.03125, 0.53125, 0.283203, 0.373047) -- TexCoords for "dropdown-hover-left-cap"
    save_hover_left:SetSize(16, 46)
    save_hover_left:SetPoint("LEFT", dialog_frame.save_button, "LEFT")

    -- Hover Texture for Save Button (Right)
    local save_hover_right = dialog_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_right:SetTexture("Interface/Buttons/Dropdown")
    save_hover_right:SetTexCoord(0.03125, 0.53125, 0.376953, 0.466797) -- TexCoords for "dropdown-hover-right-cap"
    save_hover_right:SetSize(16, 46)
    save_hover_right:SetPoint("RIGHT", dialog_frame.save_button, "RIGHT")

    -- Hover Middle Texture
    local save_hover_middle = dialog_frame.save_button:CreateTexture(nil, "HIGHLIGHT")
    save_hover_middle:SetTexture("Interface/Buttons/Dropdown")
    save_hover_middle:SetTexCoord(0, 0.5, 0.00195312, 0.0917969) -- TexCoords for "_dropdown-hover-middle"
    save_hover_middle:SetPoint("LEFT", save_hover_left, "RIGHT")
    save_hover_middle:SetPoint("RIGHT", save_hover_right, "LEFT")
    save_hover_middle:SetHeight(46)

    -- Hover Text
    local save_hover_text = dialog_frame.save_button:CreateFontString(nil, "HIGHLIGHT")
    save_hover_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    save_hover_text:SetPoint("CENTER", dialog_frame.save_button, "CENTER", 0, 0)
    save_hover_text:SetText("Save")

    dialog_frame.save_button:SetScript("OnClick", function()
        -- Close the edit dialog and open the name input dialog
        dialog_frame:Hide()

        if not addon.name_input_dialog then
            addon:create_name_input_dialog()
        end

        addon.name_input_dialog:Show()

        local input_name

        if addon.active_control_tab == "keyboard" then
            input_name = next(keyui_settings.layout_current_keyboard)
        elseif addon.active_control_tab == "mouse" then
            input_name = next(keyui_settings.layout_current_mouse)
        elseif addon.active_control_tab == "controller" then
            input_name = next(keyui_settings.layout_current_controller)
        end

        addon.name_input_dialog.input_box:SetText(input_name)

        if addon.active_control_tab == "keyboard" then
            addon.keyboard_locked = true
        elseif addon.active_control_tab == "mouse" then
            addon.mouse_locked = true
        elseif addon.active_control_tab == "controller" then
            addon.controller_locked = true
        end

    end)

    -- Cancel button
    dialog_frame.cancel_button = CreateFrame("Button", nil, dialog_frame)
    dialog_frame.cancel_button:SetPoint("BOTTOMLEFT", dialog_frame, "BOTTOM", 10, 20)
    dialog_frame.cancel_button:SetSize(button_width, 30)

    -- Button Text
    local cancel_text = dialog_frame.cancel_button:CreateFontString(nil, "OVERLAY")
    cancel_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    cancel_text:SetPoint("CENTER", dialog_frame.cancel_button, "CENTER", 0, 0)
    cancel_text:SetText("Cancel")

    -- Left Cap Texture
    local cancel_left = dialog_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_left:SetTexture("Interface/Buttons/Dropdown")
    cancel_left:SetTexCoord(0.03125, 0.53125, 0.470703, 0.560547) -- TexCoords for "dropdown-left-cap"
    cancel_left:SetSize(16, 46)
    cancel_left:SetPoint("LEFT", dialog_frame.cancel_button, "LEFT")

    -- Right Cap Texture
    local cancel_right = dialog_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_right:SetTexture("Interface/Buttons/Dropdown")
    cancel_right:SetTexCoord(0.03125, 0.53125, 0.751953, 0.841797) -- TexCoords for "dropdown-right-cap"
    cancel_right:SetSize(16, 46)
    cancel_right:SetPoint("RIGHT", dialog_frame.cancel_button, "RIGHT")

    -- Middle Texture
    local cancel_middle = dialog_frame.cancel_button:CreateTexture(nil, "ARTWORK")
    cancel_middle:SetTexture("Interface/Buttons/Dropdown")
    cancel_middle:SetTexCoord(0, 0.5, 0.0957031, 0.185547) -- TexCoords for "_dropdown-middle"
    cancel_middle:SetPoint("LEFT", cancel_left, "RIGHT")
    cancel_middle:SetPoint("RIGHT", cancel_right, "LEFT")
    cancel_middle:SetHeight(46)

    -- Hover Texture for Cancel Button (Left)
    local cancel_hover_left = dialog_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_left:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_left:SetTexCoord(0.03125, 0.53125, 0.283203, 0.373047) -- TexCoords for "dropdown-hover-left-cap"
    cancel_hover_left:SetSize(16, 46)
    cancel_hover_left:SetPoint("LEFT", dialog_frame.cancel_button, "LEFT")

    -- Hover Texture for Cancel Button (Right)
    local cancel_hover_right = dialog_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_right:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_right:SetTexCoord(0.03125, 0.53125, 0.376953, 0.466797) -- TexCoords for "dropdown-hover-right-cap"
    cancel_hover_right:SetSize(16, 46)
    cancel_hover_right:SetPoint("RIGHT", dialog_frame.cancel_button, "RIGHT")

    -- Hover Middle Texture
    local cancel_hover_middle = dialog_frame.cancel_button:CreateTexture(nil, "HIGHLIGHT")
    cancel_hover_middle:SetTexture("Interface/Buttons/Dropdown")
    cancel_hover_middle:SetTexCoord(0, 0.5, 0.00195312, 0.0917969) -- TexCoords for "_dropdown-hover-middle"
    cancel_hover_middle:SetPoint("LEFT", cancel_hover_left, "RIGHT")
    cancel_hover_middle:SetPoint("RIGHT", cancel_hover_right, "LEFT")
    cancel_hover_middle:SetHeight(46)

    -- Hover Text
    local cancel_hover_text = dialog_frame.cancel_button:CreateFontString(nil, "HIGHLIGHT")
    cancel_hover_text:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)
    cancel_hover_text:SetPoint("CENTER", dialog_frame.cancel_button, "CENTER", 0, 0)
    cancel_hover_text:SetText("Cancel")

    dialog_frame.cancel_button:SetScript("OnClick", function()
        dialog_frame:Hide()

        -- Call the discard changes function
        if addon.active_control_tab == "keyboard" then
            addon:discard_keyboard_changes()
        elseif addon.active_control_tab == "mouse" then
            addon:discard_mouse_changes()
        elseif addon.active_control_tab == "controller" then
            addon:discard_controller_changes()
        end

        if addon.controls_frame then
            addon.controls_frame:Show()
            addon:show_controls_button_highlight()
        end
    end)


    dialog_frame:SetScript("OnHide", function()
        dialog_frame:Hide()
    end)

    addon.edit_layout_dialog = dialog_frame
end

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

-- Helper function to update tab visibility and positioning
function addon:update_tab_visibility()
    local controls_frame = addon.controls_frame

    -- Hide all tabs initially
    controls_frame.keyboard_button:Hide()
    controls_frame.mouse_button:Hide()
    controls_frame.controller_button:Hide()

    -- Position tracker for leftmost tab
    local previous_button = nil

    -- Show and position the Keyboard tab if enabled
    if keyui_settings.show_keyboard == true then
        controls_frame.keyboard_button:ClearAllPoints() -- Reset previous points
        controls_frame.keyboard_button:Show()
        if not previous_button then
            controls_frame.keyboard_button:SetPoint("TOPLEFT", controls_frame, "BOTTOMLEFT", 8, 0)
        else
            controls_frame.keyboard_button:SetPoint("BOTTOMLEFT", previous_button, "BOTTOMRIGHT", 8, 0)
        end
        previous_button = controls_frame.keyboard_button
    end

    -- Show and position the Mouse tab if enabled
    if keyui_settings.show_mouse == true then
        controls_frame.mouse_button:ClearAllPoints() -- Reset previous points
        controls_frame.mouse_button:Show()
        if not previous_button then
            controls_frame.mouse_button:SetPoint("TOPLEFT", controls_frame, "BOTTOMLEFT", 8, 0)
        else
            controls_frame.mouse_button:SetPoint("BOTTOMLEFT", previous_button, "BOTTOMRIGHT", 8, 0)
        end
        previous_button = controls_frame.mouse_button
    end

    -- Show and position the Controller tab if enabled
    if keyui_settings.show_controller == true then
        controls_frame.controller_button:ClearAllPoints() -- Reset previous points
        controls_frame.controller_button:Show()
        if not previous_button then
            controls_frame.controller_button:SetPoint("TOPLEFT", controls_frame, "BOTTOMLEFT", 8, 0)
        else
            controls_frame.controller_button:SetPoint("BOTTOMLEFT", previous_button, "BOTTOMRIGHT", 8, 0)
        end
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