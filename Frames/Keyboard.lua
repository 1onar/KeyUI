local name, addon = ...

-- Function to save the keyboard's position and scale
function addon:save_keyboard_position()
    local x, y = addon.keyboard_frame:GetCenter()
    keyui_settings.keyboard_position.x = x
    keyui_settings.keyboard_position.y = y
    keyui_settings.keyboard_position.scale = addon.keyboard_frame:GetScale()
end

function addon:create_keyboard_frame()
    -- Create the keyboard frame and assign it to the addon table
    local keyboard_frame = CreateFrame("Frame", "keyui_keyboard_frame", UIParent, "BackdropTemplate")
    addon.keyboard_frame = keyboard_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_keyboard_frame")
    end

    keyboard_frame:SetHeight(382)
    keyboard_frame:SetWidth(940)
    keyboard_frame:Hide()

    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }

    keyboard_frame:SetBackdrop(backdropInfo)
    keyboard_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)

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
    keyboard_frame:SetClampedToScreen(true)

    -- Border frame to be toggled with selected texture from Editmode
    keyboard_frame.edit_frame = CreateFrame("Frame", nil, keyboard_frame, "GlowBorderTemplate")
    keyboard_frame.edit_frame:SetSize(keyboard_frame:GetWidth(), keyboard_frame:GetHeight())
    keyboard_frame.edit_frame:SetPoint("CENTER", keyboard_frame, "CENTER")
    keyboard_frame.edit_frame:Hide()

    -- Helper function to toggle visibility of tab button textures
    local function toggle_button_textures(button, showInactive)
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

    -- Apply custom font to the tab buttons
    local custom_font = CreateFont("keyboard_tab_custom_font")
    custom_font:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 12, "OUTLINE")

    -- Get Keyboard Frame Level
    local keyboard_level = addon.keyboard_frame:GetFrameLevel()

    -- Create the close tab button
    keyboard_frame.close_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    keyboard_frame.close_button:SetPoint("BOTTOMRIGHT", keyboard_frame, "TOPRIGHT", -8, 0)
    keyboard_frame.close_button:SetFrameLevel(keyboard_level - 1)

    -- Set button text
    keyboard_frame.close_button:SetText("Close")

    -- Apply custom font to the controls button
    keyboard_frame.close_button:SetNormalFontObject(custom_font)
    keyboard_frame.close_button:SetHighlightFontObject(custom_font)
    keyboard_frame.close_button:SetDisabledFontObject(custom_font)

    local text = keyboard_frame.close_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", keyboard_frame.close_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for close button
    keyboard_frame.close_button:SetScript("OnClick", function(s)
        addon:discard_keyboard_changes()
        if addon.controls_frame then
            addon.controls_frame:Hide()
        end
        keyboard_frame:Hide()
    end)

    -- Ensure the close button always appears inactive
    toggle_button_textures(keyboard_frame.close_button, true)

    -- Set initial transparency for close button (out of focus)
    keyboard_frame.close_button:SetAlpha(0.5)

    -- Set behavior when mouse enters and leaves the close button
    keyboard_frame.close_button:SetScript("OnEnter", function()
        keyboard_frame.close_button:SetAlpha(1) -- Make the button fully visible on hover
        toggle_button_textures(keyboard_frame.close_button, false) -- Show active textures
    end)

    keyboard_frame.close_button:SetScript("OnLeave", function()
        keyboard_frame.close_button:SetAlpha(0.5) -- Fade out when the mouse leaves
        toggle_button_textures(keyboard_frame.close_button, true) -- Show inactive textures
    end)

    -- Create the settings tab button
    keyboard_frame.controls_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    keyboard_frame.controls_button:SetPoint("BOTTOMRIGHT", keyboard_frame.close_button, "BOTTOMLEFT", -4, 0)
    keyboard_frame.controls_button:SetFrameLevel(keyboard_level - 1)

    -- Set button text
    keyboard_frame.controls_button:SetText("Controls")

    -- Apply custom font to the controls button
    keyboard_frame.controls_button:SetNormalFontObject(custom_font)
    keyboard_frame.controls_button:SetHighlightFontObject(custom_font)
    keyboard_frame.controls_button:SetDisabledFontObject(custom_font)

    local text = keyboard_frame.controls_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", keyboard_frame.controls_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for controls button
    keyboard_frame.controls_button:SetScript("OnClick", function()
        addon.active_control_tab = "keyboard"
        addon:update_tab_textures()

        -- Check if the controls frame exists
        if addon.controls_frame then
            -- If the controls frame is visible, hide it
            if addon.controls_frame:IsVisible() then
                addon.controls_frame:Hide()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:fade_controls_button_highlight(keyboard_frame)
            else
                -- Otherwise, show the controls frame
                addon.controls_frame:Show()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:show_controls_button_highlight(keyboard_frame)

            end
        else
            -- If the controls frame doesn't exist, create and show it
            addon:get_controls_frame()

            -- Change the style of other tab buttons, excluding the current button's frame
            addon:show_controls_button_highlight(keyboard_frame)
        end

        addon:update_tab_visibility()
    end)

    -- Ensure the controls button always appears inactive
    toggle_button_textures(keyboard_frame.controls_button, true)

    -- Set initial transparency (out of focus) for controls button
    keyboard_frame.controls_button:SetAlpha(0.5)

    -- Set behavior when mouse enters and leaves the controls button
    keyboard_frame.controls_button:SetScript("OnEnter", function()
        keyboard_frame.controls_button:SetAlpha(1) -- Make the button fully visible on hover
        toggle_button_textures(keyboard_frame.controls_button, false) -- Show active textures
    end)

    keyboard_frame.controls_button:SetScript("OnLeave", function()
        if addon.controls_frame and addon.controls_frame:IsVisible() then
            return
        else
            keyboard_frame.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
            toggle_button_textures(keyboard_frame.controls_button, true) -- Show inactive textures
        end
    end)

    keyboard_frame.controls_button:SetScript("OnHide", function()
        keyboard_frame.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
        toggle_button_textures(keyboard_frame.controls_button, true) -- Show inactive textures
    end)

    -- Create the options tab button
    keyboard_frame.options_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    keyboard_frame.options_button:SetPoint("BOTTOMRIGHT", keyboard_frame.controls_button, "BOTTOMLEFT", -4, 0)
    keyboard_frame.options_button:SetFrameLevel(keyboard_level - 1)

    -- Set button text
    keyboard_frame.options_button:SetText("Options")

    -- Apply custom font to the options button
    keyboard_frame.options_button:SetNormalFontObject(custom_font)
    keyboard_frame.options_button:SetHighlightFontObject(custom_font)
    keyboard_frame.options_button:SetDisabledFontObject(custom_font)

    local text = keyboard_frame.options_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", keyboard_frame.options_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for options button
    keyboard_frame.options_button:SetScript("OnClick", function()
        Settings.OpenToCategory("KeyUI")
    end)

    -- Ensure the options button always appears inactive
    toggle_button_textures(keyboard_frame.options_button, true)

    -- Set initial transparency (out of focus) for options button
    keyboard_frame.options_button:SetAlpha(0.5)

    -- Set behavior when mouse enters and leaves the options button
    keyboard_frame.options_button:SetScript("OnEnter", function()
        keyboard_frame.options_button:SetAlpha(1) -- Make the button fully visible on hover
        toggle_button_textures(keyboard_frame.options_button, false) -- Show active textures
    end)

    keyboard_frame.options_button:SetScript("OnLeave", function()
        keyboard_frame.options_button:SetAlpha(0.5) -- Fade out when the mouse leaves
        toggle_button_textures(keyboard_frame.options_button, true) -- Show inactive textures
    end)

    keyboard_frame:SetScript("OnHide", function()
        -- Call the discard changes function
        if addon.controller_locked == false or addon.keys_keyboard_edited == true then
            addon:discard_keyboard_changes()
        end
    end)

    return keyboard_frame
end

function addon:save_keyboard_layout(layout_name)
    local name = layout_name

    if name ~= "" then

        print("KeyUI: Saved the new keyboard layout '" .. name .. "'.")

        -- Initialize a new table for the saved layout
        keyui_settings.layout_edited_keyboard[name] = {}

        -- Iterate through all keyboard buttons to save their data
        for _, button in ipairs(addon.keys_keyboard) do
            if button:IsVisible() then
                -- Save button properties: label, position, width, and height
                keyui_settings.layout_edited_keyboard[name][#keyui_settings.layout_edited_keyboard[name] + 1] = {
                    button.raw_key,                                                 -- Button name
                    floor(button:GetLeft() - addon.keyboard_frame:GetLeft() + 0.5), -- X position
                    floor(button:GetTop() - addon.keyboard_frame:GetTop() + 0.5),   -- Y position
                    floor(button:GetWidth() + 0.5),                                 -- Width
                    floor(button:GetHeight() + 0.5)                                 -- Height
                }
            end
        end

        -- Clear the current layout and assign the new one
        wipe(keyui_settings.layout_current_keyboard)
        keyui_settings.layout_current_keyboard[name] = keyui_settings.layout_edited_keyboard[name]

        -- Remove Keyboard edited flag
        addon.keys_keyboard_edited = false
        if addon.keyboard_frame.edit_frame then
            addon.keyboard_frame.edit_frame:Hide()
        end

        -- Refresh the keys and update the dropdown menu
        addon:refresh_layouts()

        if addon.keyboard_selector then
            addon.keyboard_selector:SetDefaultText(name)
        end

    else
        print("KeyUI: Please enter a name for the layout before saving.")
    end
end

-- Discards any changes made to the keyboard layout and resets the Control UI state
function addon:discard_keyboard_changes()

    if addon.keys_keyboard_edited == true then
        -- Print message to the player
        print("KeyUI: Changes discarded.")
    end

    -- Remove Keyboard locked flag
    addon.keyboard_locked = true

    -- Remove Keyboard edited flag
    addon.keys_keyboard_edited = false
    if addon.keyboard_frame.edit_frame then
        addon.keyboard_frame.edit_frame:Hide()
    end

    addon:refresh_layouts()
end

local modifier_keys = {
    LALT = true, RALT = true,
    LCTRL = true, RCTRL = true,
    LSHIFT = true, RSHIFT = true,
}

-- This function updates the keyboard layout by creating, positioning, and resizing key frames based on the current configuration.
function addon:generate_keyboard_key_frames()
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
                    local button = addon.keys_keyboard[i] or addon:create_keyboard_buttons()
                    local button_data = layout_data[i]

                    -- Set the size of the key based on the provided data or use defaults.
                    if button_data[4] then
                        button:SetWidth(button_data[4])
                        button:SetHeight(button_data[5])
                    else
                        button:SetWidth(60)
                        button:SetHeight(60)
                    end

                    -- Store the key in the array if it's not already present.
                    if not addon.keys_keyboard[i] then
                        addon.keys_keyboard[i] = button
                    end

                    -- Position the key within the frame.
                    button:SetPoint("TOPLEFT", addon.keyboard_frame, "TOPLEFT", button_data[2], button_data[3])
                    button.raw_key= button_data[1]
                    button.is_modifier = modifier_keys[button.raw_key] or false
                    button:Show()

                    -- Update the boundaries for resizing the frame.
                    local l, r, t, b = button:GetLeft(), button:GetRight(), button:GetTop(), button:GetBottom()
                    if l < left then left = l end
                    if r > right then right = r end
                    if t > top then top = t end
                    if b < bottom then bottom = b end
                end
            end

            -- Adjust the frame size based on the extreme positions of the keys.
            addon.keyboard_frame:SetWidth(right - left + 12)
            addon.keyboard_frame:SetHeight(top - bottom + 12)

            addon.keyboard_frame.edit_frame:SetSize( addon.keyboard_frame:GetWidth(),  addon.keyboard_frame:GetHeight())
        else
            -- Set a fallback size if the layout is empty.
            addon.keyboard_frame:SetWidth(940)
            addon.keyboard_frame:SetHeight(382)

            addon.keyboard_frame.edit_frame:SetSize( addon.keyboard_frame:GetWidth(),  addon.keyboard_frame:GetHeight())
        end
    end
end

-- Create a new button to the main keyboard frame.
function addon:create_keyboard_buttons()

    -- Create a frame that acts as a button with a tooltip border.
    local keyboard_button = CreateFrame("Frame", nil, addon.keyboard_frame, "BackdropTemplate")

    keyboard_button:EnableMouse(true)
    keyboard_button:EnableKeyboard(true)
    keyboard_button:EnableGamePadButton(true)

    -- Create the backdrop for the background only (no edge)
    local backdropInfo = {
        bgFile = "Interface\\AddOns\\KeyUI\\Media\\Background\\darkgrey_bg",
        tile = true,
        tileSize = 8,
        insets = { left = 4, right = 4, top = 0, bottom = 4 }
    }
    keyboard_button:SetBackdrop(backdropInfo)

    -- Create a separate frame for the edge and apply only the edge (no background)
    keyboard_button.edge = CreateFrame("Frame", nil, keyboard_button, "BackdropTemplate")
    keyboard_button.edge:SetAllPoints()
    local edgeBackdropInfo = {
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\keycap_edge",
        edgeSize = 30,
    }
    keyboard_button.edge:SetBackdrop(edgeBackdropInfo)
    keyboard_button.edge:SetFrameLevel(keyboard_button:GetFrameLevel() + 1)  -- Set this higher than the background

    -- Keyboard Keybind text string on the top right of the button (e.g. a-c-s-1)
    keyboard_button.short_key = keyboard_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyboard_button.short_key:SetTextColor(1, 1, 1)
    keyboard_button.short_key:SetHeight(20)
    --keyboard_button.short_key:SetWidth(52)    -- will be calculated in addon:set_key
    keyboard_button.short_key:SetPoint("TOPRIGHT", keyboard_button, "TOPRIGHT", -4, -6)
    keyboard_button.short_key:SetJustifyH("RIGHT")
    keyboard_button.short_key:SetJustifyV("TOP")
    keyboard_button.short_key:Show()

    -- Font string to display the interface action text (toggled by function addon:create_action_labels)
    keyboard_button.readable_binding = keyboard_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyboard_button.readable_binding:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF", 12, "OUTLINE")
    keyboard_button.readable_binding:SetTextColor(1, 1, 1)
    keyboard_button.readable_binding:SetHeight(30)
    --keyboard_button.readable_binding:SetWidth(56)     -- will be calculated in addon:create_action_labels
    keyboard_button.readable_binding:SetPoint("BOTTOM", keyboard_button, "BOTTOM", 1, 12)
    keyboard_button.readable_binding:SetJustifyV("BOTTOM")
    keyboard_button.readable_binding:SetText("")

    -- Icon texture for the button.
    keyboard_button.icon = keyboard_button:CreateTexture(nil, "ARTWORK")
    keyboard_button.icon:SetSize(50, 50)
    keyboard_button.icon:SetPoint("CENTER", keyboard_button, "CENTER", 0, 4)
    keyboard_button.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)

    -- Highlight texture for the button.
    keyboard_button.highlight = keyboard_button:CreateTexture(nil, "ARTWORK")
    keyboard_button.highlight:SetPoint("CENTER", keyboard_button, "CENTER", 0, 4)
    keyboard_button.highlight:SetTexCoord(0.075, 0.925, 0.075, 0.925)
    keyboard_button.highlight:Hide()

    -- Define the mouse hover behavior to show tooltips.
    keyboard_button:SetScript("OnEnter", function(self)
        addon.current_hovered_button = keyboard_button -- save the current hovered button to re-trigger tooltip
        addon:button_mouse_over(keyboard_button)

        local slot = self.slot

        if addon.keyboard_locked == false then

            keyboard_button:SetScript("OnKeyDown", function(_, key)
                addon:handle_key_down(addon.current_hovered_button, key)
                addon.keys_keyboard_edited = true
            end)

            keyboard_button:SetScript("OnGamePadButtonDown", function(_, key)
                addon:handle_gamepad_down(addon.current_hovered_button, key)
                addon.keys_keyboard_edited = true
            end)

            keyboard_button:SetScript("OnMouseWheel", function(_, delta)
                addon:handle_mouse_wheel(addon.current_hovered_button, delta)
                addon.keys_keyboard_edited = true
            end)

        end

        -- Only show the PushedTexture if the setting is enabled
        if keyui_settings.show_pushed_texture then
            -- Look up the correct button in TextureMappings using the adjusted slot number
            local mapped_button = addon.button_texture_mapping[tostring(slot)]
            if mapped_button then
                local normal_texture = mapped_button:GetNormalTexture()
                if normal_texture and normal_texture:IsVisible() then
                    local pushed_texture = mapped_button:GetPushedTexture()
                    if pushed_texture then
                        pushed_texture:Show() -- Show the pushed texture
                        addon.current_pushed_button = pushed_texture -- save the current pushed button to hide when modifier pushed
                    end
                end
            end
        end
    end)

    keyboard_button:SetScript("OnLeave", function()
        addon.current_hovered_button = nil -- Clear the current hovered button
        GameTooltip:Hide()
        addon.keyui_tooltip_frame:Hide()
        keyboard_button:EnableKeyboard(false)
        keyboard_button:EnableMouseWheel(false)

        if addon.current_pushed_button then
            addon.current_pushed_button:Hide()
            addon.current_pushed_button = nil -- Clear the current pushed button
        end
    end)

    -- Define behavior for mouse down actions (left-click).
    keyboard_button:SetScript("OnMouseDown", function(self, Mousebutton)

        local slot = self.slot

        if Mousebutton == "LeftButton" then
            if addon.keyboard_locked == false then
                return
            else
                if slot then
                    PickupAction(slot)
                end
            end
        else
            if addon.keyboard_locked == false then
                addon:handle_key_down(self, Mousebutton)
                addon.keys_keyboard_edited = true
            end
        end
    end)

    -- Define behavior for mouse up actions (left-click and right-click).
    keyboard_button:SetScript("OnMouseUp", function(self, Mousebutton)
        if Mousebutton == "RightButton" then
            addon.current_clicked_key = self    -- save the current clicked key
            addon.current_slot = self.slot      -- save the current clicked slot
            ToggleDropDownMenu(1, nil, addon.dropdown, self, 30, 20)
        end
    end)

    -- Store the created button in the keyboard_buttons table
    if not self.keyboard_buttons then
        self.keyboard_buttons = {}  -- Initialize the table if it doesn't exist
    end
    table.insert(self.keyboard_buttons, keyboard_button)  -- Add the new button to the table

    return keyboard_button
end

function addon:generate_keyboard_layout(layout_name)
    -- Validate layout_name
    if not layout_name or layout_name == "" then
        return
    end

    -- Discard Keyboard Editor Changes
    if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
        addon:discard_keyboard_changes()
    end

    -- Check whether the layout exists
    local layout = addon.default_keyboard_layouts[layout_name] or keyui_settings.layout_edited_keyboard[layout_name]
    if not layout then
        print("Error: Layout " .. layout_name .. " not found.")
        return
    end

    -- Update settings
    wipe(keyui_settings.layout_current_keyboard)
    keyui_settings.layout_current_keyboard[layout_name] = layout
    keyui_settings.key_bind_settings_keyboard.currentboard = layout_name

    -- Reload layouts
    --addon:refresh_layouts()
end