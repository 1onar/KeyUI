local name, addon = ...

-- Save the position and scale of the mouse holder
function addon:save_mouse_position()
    local x, y = addon.mouse_image:GetCenter()
    keyui_settings.mouse_position.x = x
    keyui_settings.mouse_position.y = y
    keyui_settings.mouse_position.scale = addon.mouse_image:GetScale()
end

function addon:create_mouse_image()
    local mouse_image = CreateFrame("Frame", "keyui_mouse_image", UIParent)
    addon.mouse_image = mouse_image

    -- Manage ESC key behavior based on the setting
    if keyui_settings.close_on_esc == true then
        tinsert(UISpecialFrames, "keyui_mouse_image")
    end

    mouse_image:SetWidth(260)
    mouse_image:SetHeight(382)
    mouse_image:Hide()

    -- Load the saved position if it exists
    if keyui_settings.mouse_position.x and keyui_settings.mouse_position.y then
        mouse_image:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            keyui_settings.mouse_position.x,
            keyui_settings.mouse_position.y
        )
        mouse_image:SetScale(keyui_settings.mouse_position.scale)
    else
        mouse_image:SetPoint("CENTER", UIParent, "CENTER", 450, 0)
        mouse_image:SetScale(1)
    end

    -- Enable dragging and movement
    mouse_image:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    mouse_image:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    mouse_image:SetMovable(true)
    mouse_image:SetClampedToScreen(true)

    -- Set mouse texture
    mouse_image.Texture = mouse_image:CreateTexture()
    mouse_image.Texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\mouse.tga")
    mouse_image.Texture:SetPoint("CENTER", mouse_image, "CENTER", 0, 0)
    mouse_image.Texture:SetSize(390, 390)

    -- Create close button
    mouse_image.close_button = CreateFrame("Button", nil, mouse_image, "UIPanelCloseButton")
    mouse_image.close_button:SetSize(22, 22)
    mouse_image.close_button:SetPoint("TOPRIGHT", mouse_image, "TOPRIGHT", 0, 0)
    mouse_image.close_button:SetScript("OnClick", function(s)
        addon:discard_mouse_changes()
        if addon.controls_frame then
            addon.controls_frame:Hide()
        end
        mouse_image:Hide()
    end)

    -- Create edit mode glow border frame
    mouse_image.edit_frame = addon:CreateGlowFrame(mouse_image, {
        point = { "RIGHT", mouse_image, "RIGHT" },
        width = 500,
        height = mouse_image:GetHeight(),
    })

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
    local custom_font = CreateFont("mouse_tab_custom_font")
    custom_font:SetFont(addon:GetFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(custom_font, 0.75, false, "OUTLINE")

    -- Get mouse Frame Level
    local mouse_level = addon.mouse_image:GetFrameLevel()

    -- Create the settings tab button
    mouse_image.controls_button = CreateFrame("Button", nil, mouse_image, "PanelTabButtonTemplate")
    mouse_image.controls_button:SetPoint("TOPLEFT", mouse_image, "BOTTOM", -12, 0)
    mouse_image.controls_button:SetFrameLevel(mouse_level - 1)
    mouse_image.controls_button:SetScale(0.8)

    -- Set button text
    mouse_image.controls_button:SetText("Controls")

    -- Apply custom font to the controls button
    mouse_image.controls_button:SetNormalFontObject(custom_font)
    mouse_image.controls_button:SetHighlightFontObject(custom_font)
    mouse_image.controls_button:SetDisabledFontObject(custom_font)

    local text = mouse_image.controls_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("CENTER", mouse_image.controls_button, "CENTER", 0, 0)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for controls button
    mouse_image.controls_button:SetScript("OnClick", function()
        addon.active_control_tab = "mouse"
        addon:update_tab_textures()

        -- Check if the controls frame exists
        if addon.controls_frame then
            -- If the controls frame is visible, hide it
            if addon.controls_frame:IsVisible() then
                addon.controls_frame:Hide()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:fade_controls_button_highlight(mouse_image)
            else
                -- Otherwise, show the controls frame
                addon.controls_frame:Show()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:show_controls_button_highlight(mouse_image)
            end
        else
            -- If the controls frame doesn't exist, create and show it
            addon:get_controls_frame()

            -- Change the style of other tab buttons, excluding the current button's frame
            addon:show_controls_button_highlight(mouse_image)
        end

        addon:update_tab_visibility()
    end)

    -- Ensure the controls button always appears inactive
    toggle_button_textures(mouse_image.controls_button, true)

    -- Set initial transparency (out of focus) for controls button
    mouse_image.controls_button:SetAlpha(0.5)

    -- Set behavior when mouse enters and leaves the controls button
    mouse_image.controls_button:SetScript("OnEnter", function()
        mouse_image.controls_button:SetAlpha(1) -- Make the button fully visible on hover
        toggle_button_textures(mouse_image.controls_button, false) -- Show active textures
    end)

    mouse_image.controls_button:SetScript("OnLeave", function()
        if addon.controls_frame and addon.controls_frame:IsVisible() then
            return
        else
            mouse_image.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
            toggle_button_textures(mouse_image.controls_button, true) -- Show inactive textures
        end
    end)

    mouse_image.controls_button:SetScript("OnHide", function()
        mouse_image.controls_button:SetAlpha(0.5) -- Fade out when the mouse leaves
        toggle_button_textures(mouse_image.controls_button, true) -- Show inactive textures
    end)

    -- Create the options tab button
    mouse_image.options_button = CreateFrame("Button", nil, mouse_image, "PanelTabButtonTemplate")
    mouse_image.options_button:SetPoint("BOTTOMRIGHT", mouse_image.controls_button, "BOTTOMLEFT", -4, 0)
    mouse_image.options_button:SetFrameLevel(mouse_level - 1)
    mouse_image.options_button:SetScale(0.8)

    -- Set button text
    mouse_image.options_button:SetText("Options")

    -- Apply custom font to the options button
    mouse_image.options_button:SetNormalFontObject(custom_font)
    mouse_image.options_button:SetHighlightFontObject(custom_font)
    mouse_image.options_button:SetDisabledFontObject(custom_font)

    local text = mouse_image.options_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("CENTER", mouse_image.options_button, "CENTER", 0, 0)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for options button
    mouse_image.options_button:SetScript("OnClick", function()
        addon:OpenSettings()
    end)

    -- Ensure the options button always appears inactive
    toggle_button_textures(mouse_image.options_button, true)

    -- Set initial transparency (out of focus) for options button
    mouse_image.options_button:SetAlpha(0.5)

    -- Set behavior when mouse enters and leaves the options button
    mouse_image.options_button:SetScript("OnEnter", function()
        mouse_image.options_button:SetAlpha(1) -- Make the button fully visible on hover
        toggle_button_textures(mouse_image.options_button, false) -- Show active textures
    end)

    mouse_image.options_button:SetScript("OnLeave", function()
        mouse_image.options_button:SetAlpha(0.5) -- Fade out when the mouse leaves
        toggle_button_textures(mouse_image.options_button, true) -- Show inactive textures
    end)

    mouse_image:SetScript("OnHide", function()
        if addon.mouse_locked == false or addon.keys_mouse_edited == true then
            addon:discard_mouse_changes()
        end
        addon.mouse_layout_dirty = true
    end)

    mouse_image:SetScript("OnShow", function()
        if addon.mouse_layout_dirty == true then
            addon:generate_mouse_key_frames()
            addon.mouse_layout_dirty = false
        end
    end)

    return mouse_image
end

function addon:create_mouse_frame()
    local mouse_frame = CreateFrame("Frame", "keyui_mouse_frame", addon.mouse_image)
    addon.mouse_frame = mouse_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.close_on_esc == true then
        tinsert(UISpecialFrames, "keyui_mouse_frame")
    end

    mouse_frame:SetWidth(50)
    mouse_frame:SetHeight(50)
    mouse_frame:SetPoint("RIGHT", addon.mouse_image, "LEFT", 5, -25)
    mouse_frame:SetScale(1)
    mouse_frame:Hide()

    mouse_frame:SetScript("OnShow", function()
        if addon.mouse_layout_dirty == true then
            addon:generate_mouse_key_frames()
            addon.mouse_layout_dirty = false
        end
    end)

    return mouse_frame
end

function addon:save_mouse_layout(layout_name)
    local name = layout_name

    if name ~= "" then

        print("KeyUI: Saved the new mouse layout '" .. name .. "'.")

        -- Initialize a new table for the saved layout
        keyui_settings.layout_edited_mouse[name] = {}

        -- Iterate through all mouse buttons to save their data
        for _, button in ipairs(addon.keys_mouse) do
            if button:IsVisible() then
                -- Save button properties: label, position, width, and height
                keyui_settings.layout_edited_mouse[name][#keyui_settings.layout_edited_mouse[name] + 1] = {
                    button.raw_key,                                                -- Button name
                    floor(button:GetLeft() - addon.mouse_frame:GetLeft() + 0.5),   -- X position
                    floor(button:GetTop() - addon.mouse_frame:GetTop() + 0.5),     -- Y position
                    floor(button:GetWidth() + 0.5),                                -- Width
                    floor(button:GetHeight() + 0.5)                                -- Height
                }
            end
        end

        -- Clear the current layout and assign the new one
        wipe(keyui_settings.layout_current_mouse)
        keyui_settings.layout_current_mouse[name] = keyui_settings.layout_edited_mouse[name]

        -- Remove Mouse edited flag
        addon.keys_mouse_edited = false
        if addon.mouse_image.edit_frame then
            addon.mouse_image.edit_frame:Hide()
        end

        -- Refresh the keys and update the dropdown menu
        addon:refresh_layouts()

        if addon.mouse_selector then
            addon.mouse_selector:SetDefaultText(name)
        end

    else
        print("KeyUI: Please enter a name for the layout before saving.")
    end
end

-- Discards any changes made to the mouse layout and resets the Control UI state
function addon:discard_mouse_changes()

    if addon.keys_mouse_edited == true then
        -- Print message to the player
        print("KeyUI: Changes discarded.")
    end

    -- Remove mouse locked flag
    addon.mouse_locked = true

    -- Remove mouse edited flag
    addon.keys_mouse_edited = false
    if addon.mouse_image.edit_frame then
        addon.mouse_image.edit_frame:Hide()
    end

    addon:refresh_layouts()
end

local modifier_keys = {
    LALT = true, RALT = true,
    LCTRL = true, RCTRL = true,
    LSHIFT = true, RSHIFT = true,
}

function addon:generate_mouse_key_frames()
    -- Clear existing Keys to avoid leftover data from previous layouts
    for i = 1, #addon.keys_mouse do
        addon.keys_mouse[i]:Hide()
        addon.keys_mouse[i] = nil
    end
    addon.keys_mouse = {}

    if addon.open == true and addon.mouse_frame then
        -- Check if the layout is empty
        local layout_not_empty = false
        for _, layoutData in pairs(keyui_settings.layout_current_mouse) do
            if #layoutData > 0 then
                layout_not_empty = true
                break
            end
        end

        -- Only proceed if there is a valid layout
        if layout_not_empty then
            for _, layoutData in pairs(keyui_settings.layout_current_mouse) do
                for i = 1, #layoutData do
                    local button = addon.keys_mouse[i] or addon:create_mouse_buttons()
                    local button_data = layoutData[i]

                    button:SetWidth(button_data[4] or 50)
                    button:SetHeight(button_data[5] or 50)

                    -- Set the mouse button's icon size
                    local icon_width, icon_height = 44, 44
                    button.icon:SetSize(icon_width, icon_height)

                    -- If the button doesn't have an original icon size, set it
                    if not button.original_icon_size then
                        button.original_icon_size = { width = icon_width, height = icon_height }
                    end

                    if not addon.keys_mouse[i] then
                        addon.keys_mouse[i] = button
                    end

                    button:SetPoint("TOPRIGHT", addon.mouse_frame, "TOPRIGHT", button_data[2], button_data[3])
                    button.raw_key = button_data[1]
                    button.is_modifier = modifier_keys[button.raw_key] or false
                    button:Show()
                end
            end
        end
    end
end

-- Create a new button to the main mouse image frame.
function addon:create_mouse_buttons()

    -- Create a frame that acts as a button with a tooltip border.
    local mouse_button = CreateFrame("BUTTON", nil, addon.mouse_image, "SecureActionButtonTemplate")

    mouse_button:EnableMouse(true)
    mouse_button:EnableKeyboard(true)
    mouse_button:EnableGamePadButton(true)
    mouse_button:SetMovable(true)
    mouse_button:SetClampedToScreen(true)

    -- Add Background Texture
    local background = mouse_button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\actionbutton_bg")
    background:SetWidth(44)
    background:SetHeight(44)
    background:SetPoint("CENTER", mouse_button, "CENTER", 0, 0)
    mouse_button.background = background

    -- Add Border Texture
    local border = mouse_button:CreateTexture(nil, "OVERLAY")
    border:SetAtlas("UI-HUD-ActionBar-IconFrame")
    border:SetAllPoints()
    mouse_button.border = border

    -- Mouse Keybind text string on the top right of the button (e.g. a-c-s-1)
    mouse_button.short_key = mouse_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mouse_button.short_key:SetTextColor(1, 1, 1)
    mouse_button.short_key:SetHeight(20)
    --mouse_button.short_key:SetWidth(42)   -- will be calculated in addon:set_key
    mouse_button.short_key:SetPoint("TOP", mouse_button, "TOP", 0, -6)
    mouse_button.short_key:SetJustifyH("RIGHT")
    mouse_button.short_key:SetJustifyV("TOP")
    mouse_button.short_key:Show()

    -- Font string to display the interface action text (toggled by function addon:create_action_labels)
    mouse_button.readable_binding = mouse_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mouse_button.readable_binding:SetFont(addon:GetCondensedFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(mouse_button.readable_binding, 0.75, true, "OUTLINE")
    mouse_button.readable_binding:SetTextColor(1, 1, 1)
    mouse_button.readable_binding:SetHeight(25)
    --mouse_button.readable_binding:SetWidth(46)    -- will be calculated in addon:create_action_labels
    mouse_button.readable_binding:SetPoint("BOTTOM", mouse_button, "BOTTOM", 1, 6)
    mouse_button.readable_binding:SetJustifyV("BOTTOM")
    mouse_button.readable_binding:SetText("")

    -- Icon texture for the button.
    mouse_button.icon = mouse_button:CreateTexture(nil, "ARTWORK")
    --mouse_button.icon:SetSize(44, 44) -- Default size will be set in addon:generate_mouse_key_frames
    mouse_button.icon:SetPoint("CENTER", mouse_button, "CENTER", 0, 0)
    mouse_button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Highlight texture for the button.
    mouse_button.highlight = mouse_button:CreateTexture(nil, "ARTWORK")
    mouse_button.highlight:SetSize(44, 44)
    mouse_button.highlight:SetPoint("CENTER", mouse_button, "CENTER", 0, 0)
    mouse_button.highlight:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    mouse_button.highlight:Hide()

    -- Keypress highlight border (brief glow when key is pressed)
    mouse_button.keypress_highlight = CreateFrame("Frame", nil, mouse_button, "BackdropTemplate")
    mouse_button.keypress_highlight:SetPoint("TOPLEFT", mouse_button, "TOPLEFT", -3, 3)
    mouse_button.keypress_highlight:SetPoint("BOTTOMRIGHT", mouse_button, "BOTTOMRIGHT", 3, -3)
    mouse_button.keypress_highlight:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
    mouse_button.keypress_highlight:SetBackdropBorderColor(1, 1, 1, 1)
    mouse_button.keypress_highlight:SetFrameLevel(mouse_button:GetFrameLevel() + 5)
    mouse_button.keypress_highlight:Hide()

    mouse_button:SetScript("OnEnter", function(self)
        addon.current_hovered_button = mouse_button -- save the current hovered button to re-trigger tooltip
        addon:button_mouse_over(mouse_button)
        mouse_button:EnableKeyboard(true)
        mouse_button:EnableMouseWheel(true)

        local active_slot = self.active_slot

        if addon.mouse_locked == false and not addon.is_moving then

            mouse_button:SetScript("OnKeyDown", function(_, key)
                addon:handle_key_down(addon.current_hovered_button, key)
                addon.keys_mouse_edited = true
            end)

            mouse_button:SetScript("OnGamePadButtonDown", function(_, key)
                addon:handle_gamepad_down(addon.current_hovered_button, key)
                addon.keys_mouse_edited = true
            end)

            mouse_button:SetScript("OnMouseWheel", function(_, delta)
                addon:handle_mouse_wheel(addon.current_hovered_button, delta)
                addon.keys_mouse_edited = true
            end)

        end

        addon:show_pushed_texture(active_slot)
    end)

    mouse_button:SetScript("OnLeave", function()
        addon.current_hovered_button = nil -- Clear the current hovered button
        GameTooltip:Hide()
        addon.keyui_tooltip_frame:Hide()
        mouse_button:EnableKeyboard(false)
        mouse_button:EnableMouseWheel(false)

        if addon.current_pushed_button then
            addon.current_pushed_button:Hide()
            addon.current_pushed_button = nil -- Clear the current pushed button
        end
    end)

    mouse_button:SetScript("OnMouseDown", function(self, mousebutton)
        if mousebutton == "LeftButton" then
            if addon.mouse_locked == false then
                addon:handle_drag_or_size(self, mousebutton)
                addon.keys_mouse_edited = true
            else
                addon:handle_action_drag(self)
            end
        else
            if addon.mouse_locked == false then
                addon:handle_key_down(self, mousebutton)
                addon.keys_mouse_edited = true
            end
        end
    end)

    mouse_button:SetScript("OnMouseUp", function(self, mousebutton)
        if mousebutton == "LeftButton" then
            if addon.mouse_locked == false then
                addon:handle_release(self, mousebutton)
            end
        elseif mousebutton == "RightButton" then
            addon.current_clicked_key = self    -- save the current clicked key
            addon.current_slot = self.slot      -- save the current clicked slot
            MenuUtil.CreateContextMenu(self, addon.context_menu_generator)
        end
    end)

    -- Store the created button in the keyboard_buttons table
    if not self.mouse_buttons then
        self.mouse_buttons = {}  -- Initialize the table if it doesn't exist
    end
    table.insert(self.mouse_buttons, mouse_button)  -- Add the new button to the table

    return mouse_button
end

function addon:generate_mouse_layout(layout_name)
    -- Validate layout_name
    if not layout_name or layout_name == "" then
        return
    end

    -- Discard Mouse Editor Changes
    if addon.mouse_locked == false or addon.keys_mouse_edited == true then
        addon:discard_mouse_changes()
    end

    -- Check whether the layout exists
    local layout = addon.default_mouse_layouts[layout_name] or keyui_settings.layout_edited_mouse[layout_name]
    if not layout then
        print("Error: Mouse layout " .. layout_name .. " not found.")
        return
    end

    -- Update settings
    wipe(keyui_settings.layout_current_mouse)
    keyui_settings.layout_current_mouse[layout_name] = layout
    keyui_settings.key_bind_settings_mouse.currentboard = layout_name

    -- Reload layouts
    --addon:refresh_layouts()
end
