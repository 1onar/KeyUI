local name, addon = ...

-- Use centralized version detection from VersionCompat.lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

-- Function to save the keyboard's position and scale
function addon:save_keyboard_position()
    if not addon.keyboard_frame then
        return
    end

    local x, y = addon.keyboard_frame:GetCenter()
    if not x or not y then
        return
    end

    keyui_settings.keyboard_position = keyui_settings.keyboard_position or {}
    keyui_settings.keyboard_position.x = x
    keyui_settings.keyboard_position.y = y
    keyui_settings.keyboard_position.scale = addon.keyboard_frame:GetScale()
end

function addon:create_keyboard_frame()
    local keyboard_frame = CreateFrame("Frame", "keyui_keyboard_frame", UIParent, "BackdropTemplate")
    addon.keyboard_frame = keyboard_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.close_on_esc == true then
        tinsert(UISpecialFrames, "keyui_keyboard_frame")
    end

    -- Set initial size and hide frame
    keyboard_frame:SetHeight(382)
    keyboard_frame:SetWidth(940)
    keyboard_frame:Hide()

    -- Configure backdrop with background and border
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
    local keyboard_position = keyui_settings.keyboard_position or {}
    keyui_settings.keyboard_position = keyboard_position
    if keyboard_position.x and keyboard_position.y then
        keyboard_frame:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            keyboard_position.x,
            keyboard_position.y
        )
        keyboard_frame:SetScale(keyboard_position.scale or 1)
    else
        keyboard_frame:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
        keyboard_frame:SetScale(1)
    end

    -- Enable dragging and movement (respects position lock)
    keyboard_frame:SetScript("OnMouseDown", function(self)
        if not keyui_settings.position_locked then
            self:StartMoving()
        end
    end)
    keyboard_frame:SetScript("OnMouseUp", function(self)
        if not keyui_settings.position_locked then
            self:StopMovingOrSizing()
        end
    end)
    keyboard_frame:SetMovable(true)
    keyboard_frame:SetClampedToScreen(true)

    -- Create edit mode glow border frame
    keyboard_frame.edit_frame = addon:CreateGlowFrame(keyboard_frame, {
        point = { "CENTER", keyboard_frame, "CENTER" },
        width = keyboard_frame:GetWidth(),
        height = keyboard_frame:GetHeight(),
    })

    -- Helper function to toggle visibility of tab button textures
    local function toggle_button_textures(button, showInactive)
        -- Check if button has texture properties (only in Retail or custom buttons)
        if not button.LeftActive then return end

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
    custom_font:SetFont(addon:GetFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(custom_font, 0.75, false, "OUTLINE")

    -- Get Keyboard Frame Level
    local keyboard_level = addon.keyboard_frame:GetFrameLevel()

    -- Create the close tab button
    if USE_ATLAS then
        keyboard_frame.close_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    else
        keyboard_frame.close_button = addon:CreateTopTabButton(keyboard_frame)
    end
    keyboard_frame.close_button:SetPoint("BOTTOMRIGHT", keyboard_frame, "TOPRIGHT", -8, 0)
    keyboard_frame.close_button:SetFrameLevel(keyboard_level - 1)

    keyboard_frame.close_button:SetText("Close")

    keyboard_frame.close_button:SetNormalFontObject(custom_font)
    keyboard_frame.close_button:SetHighlightFontObject(custom_font)
    keyboard_frame.close_button:SetDisabledFontObject(custom_font)

    local text = keyboard_frame.close_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", keyboard_frame.close_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    keyboard_frame.close_button:SetScript("OnClick", function(s)
        addon:discard_keyboard_changes()
        if addon.controls_frame then
            addon.controls_frame:Hide()
        end
        keyboard_frame:Hide()
    end)

    toggle_button_textures(keyboard_frame.close_button, true)

    keyboard_frame.close_button:SetScript("OnEnter", function()
        toggle_button_textures(keyboard_frame.close_button, false)
    end)

    keyboard_frame.close_button:SetScript("OnLeave", function()
        toggle_button_textures(keyboard_frame.close_button, true)
    end)

    -- Create the settings tab button
    if USE_ATLAS then
        keyboard_frame.controls_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    else
        keyboard_frame.controls_button = addon:CreateTopTabButton(keyboard_frame)
    end
    keyboard_frame.controls_button:SetPoint("BOTTOMRIGHT", keyboard_frame.close_button, "BOTTOMLEFT", -4, 0)
    keyboard_frame.controls_button:SetFrameLevel(keyboard_level - 1)

    keyboard_frame.controls_button:SetText("Controls")

    keyboard_frame.controls_button:SetNormalFontObject(custom_font)
    keyboard_frame.controls_button:SetHighlightFontObject(custom_font)
    keyboard_frame.controls_button:SetDisabledFontObject(custom_font)

    local text = keyboard_frame.controls_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", keyboard_frame.controls_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

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

    toggle_button_textures(keyboard_frame.controls_button, true)

    keyboard_frame.controls_button:SetScript("OnEnter", function()
        toggle_button_textures(keyboard_frame.controls_button, false)
    end)

    keyboard_frame.controls_button:SetScript("OnLeave", function()
        if addon.controls_frame and addon.controls_frame:IsVisible() then
            return
        end
        toggle_button_textures(keyboard_frame.controls_button, true)
    end)

    -- Create the options tab button
    if USE_ATLAS then
        keyboard_frame.options_button = CreateFrame("Button", nil, keyboard_frame, "PanelTopTabButtonTemplate")
    else
        keyboard_frame.options_button = addon:CreateTopTabButton(keyboard_frame)
    end
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
        addon:OpenSettings()
    end)

    toggle_button_textures(keyboard_frame.options_button, true)

    keyboard_frame.options_button:SetScript("OnEnter", function()
        toggle_button_textures(keyboard_frame.options_button, false)
    end)

    keyboard_frame.options_button:SetScript("OnLeave", function()
        toggle_button_textures(keyboard_frame.options_button, true)
    end)

    keyboard_frame:SetScript("OnHide", function()
        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
            addon:discard_keyboard_changes()
        end
        addon.keyboard_layout_dirty = true
    end)

    -- Create all left-side toggle buttons (top-left)
    addon:CreateLockToggleButtons(keyboard_frame, keyboard_level, custom_font, false, "show_keyboard_background")

    -- Fade all tab buttons when mouse is not over the frame
    addon:SetupButtonFade(keyboard_frame)

    keyboard_frame:HookScript("OnShow", function()
        if addon.keyboard_layout_dirty == true then
            addon:generate_keyboard_key_frames()
            addon.keyboard_layout_dirty = false
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

        -- First pass: Find minimum X and maximum Y (closest to 0) of visible buttons
        -- This allows us to normalize positions so deleted top/left rows don't leave empty space
        local min_x = nil
        local max_y = nil  -- Y is negative, so "max" means closest to 0

        for _, button in ipairs(addon.keys_keyboard) do
            if button:IsVisible() then
                local x = button:GetLeft() - addon.keyboard_frame:GetLeft()
                local y = button:GetTop() - addon.keyboard_frame:GetTop()

                if min_x == nil or x < min_x then
                    min_x = x
                end
                if max_y == nil or y > max_y then
                    max_y = y
                end
            end
        end

        -- Default to standard layout padding (original layouts use X=6, Y=-6)
        local padding = 6
        min_x = min_x or padding
        max_y = max_y or -padding

        -- Calculate offset to normalize positions (shift everything so top-left starts at padding)
        local x_offset = min_x - padding
        local y_offset = max_y + padding  -- Y is negative, so we add to move up

        -- Second pass: Save button data with normalized positions
        for _, button in ipairs(addon.keys_keyboard) do
            if button:IsVisible() then
                local x = floor(button:GetLeft() - addon.keyboard_frame:GetLeft() - x_offset + 0.5)
                local y = floor(button:GetTop() - addon.keyboard_frame:GetTop() - y_offset + 0.5)

                -- Save button properties: label, position, width, height, and icon sizes
                keyui_settings.layout_edited_keyboard[name][#keyui_settings.layout_edited_keyboard[name] + 1] = {
                    button.raw_key,                         -- Button name (column 1)
                    x,                                      -- X position normalized (column 2)
                    y,                                      -- Y position normalized (column 3)
                    floor(button:GetWidth() + 0.5),         -- Width (column 4)
                    floor(button:GetHeight() + 0.5),        -- Height (column 5)
                    floor(button.icon:GetWidth() + 0.5),    -- Icon Width (column 6)
                    floor(button.icon:GetHeight() + 0.5)    -- Icon Height (column 7)
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

-- Recalculates the keyboard frame size based on visible keys
-- Called after deleting a key to immediately adjust the background
function addon:recalculate_keyboard_frame_size()
    if not addon.keyboard_frame or not addon.keys_keyboard then return end

    local max_horizontal_extent = 0
    local max_vertical_extent = 0

    for _, button in ipairs(addon.keys_keyboard) do
        if button:IsVisible() then
            local left = button:GetLeft() - addon.keyboard_frame:GetLeft()
            local top = button:GetTop() - addon.keyboard_frame:GetTop()
            local width = button:GetWidth()
            local height = button:GetHeight()

            if left + width > max_horizontal_extent then
                max_horizontal_extent = left + width
            end
            if top - height < max_vertical_extent then
                max_vertical_extent = top - height
            end
        end
    end

    if max_horizontal_extent > 0 then
        addon.keyboard_frame:SetWidth(max_horizontal_extent + 6)
        addon.keyboard_frame:SetHeight(math.abs(max_vertical_extent) + 6)

        -- Also update the edit frame if it exists
        if addon.keyboard_frame.edit_frame then
            addon.keyboard_frame.edit_frame:SetSize(addon.keyboard_frame:GetWidth(), addon.keyboard_frame:GetHeight())
        end
    end
end

local modifier_keys = {
    LALT = true, RALT = true,
    LCTRL = true, RCTRL = true,
    LSHIFT = true, RSHIFT = true,
}

-- Updates the keyboard layout by creating, positioning, and resizing key frames based on the current configuration
function addon:generate_keyboard_key_frames()
    local active_count = 0

    if keyui_settings.layout_current_keyboard and addon.open and addon.keyboard_frame then
        -- Set temporary small size before calculating the dynamic size
        addon.keyboard_frame:SetWidth(100)
        addon.keyboard_frame:SetHeight(100)

        -- Check if the layout contains any data
        local layout_not_empty = false
        for _, layout_data in pairs(keyui_settings.layout_current_keyboard) do
            if #layout_data > 0 then
                layout_not_empty = true
                break
            end
        end

        if layout_not_empty then
            local max_horizontal_extent = 0
            local max_vertical_extent = 0

            -- Loop through each key in the layout and position it within the frame
            for _, layout_data in pairs(keyui_settings.layout_current_keyboard) do
                for i = 1, #layout_data do
                    local button_data = layout_data[i]
                    active_count = active_count + 1

                    local button = addon:AcquireKeyButton("keyboard", active_count)
                    if not button then
                        active_count = active_count - 1
                        break
                    end

                    local key_label, offset_x, offset_y, key_width, key_height, icon_width, icon_height =
                        button_data[1], button_data[2], button_data[3], button_data[4], button_data[5], button_data[6], button_data[7]

                    if key_width and key_height then
                        button:SetWidth(key_width)
                        button:SetHeight(key_height)
                    else
                        button:SetWidth(60)
                        button:SetHeight(60)
                    end

                    if icon_width and icon_height then
                        button.icon:SetWidth(icon_width)
                        button.icon:SetHeight(icon_height)
                        button.original_icon_size = { width = icon_width, height = icon_height }
                    else
                        button.icon:SetWidth(50)
                        button.icon:SetHeight(50)
                        button.original_icon_size = { width = 50, height = 50 }
                    end

                    addon.keys_keyboard[active_count] = button
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", addon.keyboard_frame, "TOPLEFT", offset_x, offset_y)
                    button.raw_key = key_label
                    button.is_modifier = modifier_keys[button.raw_key] or false
                    button:Show()

                    -- Track maximum extents for frame size calculation
                    if offset_x + (key_width or 60) > max_horizontal_extent then
                        max_horizontal_extent = offset_x + (key_width or 60)
                    end
                    if offset_y - (key_height or 60) < max_vertical_extent then
                        max_vertical_extent = offset_y - (key_height or 60)
                    end
                end
            end

            -- Set frame size based on calculated extents (use abs for height due to negative offset_y)
            addon.keyboard_frame:SetWidth(max_horizontal_extent + 6)
            addon.keyboard_frame:SetHeight(math.abs(max_vertical_extent) + 6)

            addon.keyboard_frame.edit_frame:SetSize(addon.keyboard_frame:GetWidth(), addon.keyboard_frame:GetHeight())
        else
            -- Set fallback size if the layout is empty
            addon.keyboard_frame:SetWidth(940)
            addon.keyboard_frame:SetHeight(382)

            addon.keyboard_frame.edit_frame:SetSize(addon.keyboard_frame:GetWidth(), addon.keyboard_frame:GetHeight())
        end
    end

    addon:ReleaseUnusedKeyButtons("keyboard", active_count, addon.keys_keyboard)
    addon:ApplyClickThrough()
end

-- Create a new button to the main keyboard frame.
function addon:create_keyboard_buttons()

    -- Create a frame that acts as a button with a tooltip border.
    local keyboard_button = CreateFrame("Frame", nil, addon.keyboard_frame, "BackdropTemplate")

    keyboard_button:EnableMouse(true)
    keyboard_button:EnableKeyboard(true)
    keyboard_button:EnableGamePadButton(true)
    keyboard_button:SetMovable(true)
    keyboard_button:SetClampedToScreen(true)

    -- Create the backdrop for the background only (no edge)
    local backdropInfo = {
        bgFile = "Interface\\AddOns\\KeyUI\\Media\\Background\\darkgrey_bg",
        tile = true,
        tileSize = 8,
        insets = { left = 3, right = 3, top = 0, bottom = 4 }
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
    keyboard_button.readable_binding:SetFont(addon:GetCondensedFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(keyboard_button.readable_binding, 0.75, true, "OUTLINE")
    keyboard_button.readable_binding:SetTextColor(1, 1, 1)
    keyboard_button.readable_binding:SetHeight(30)
    --keyboard_button.readable_binding:SetWidth(56)     -- will be calculated in addon:create_action_labels
    keyboard_button.readable_binding:SetPoint("BOTTOM", keyboard_button, "BOTTOM", 1, 12)
    keyboard_button.readable_binding:SetJustifyV("BOTTOM")
    keyboard_button.readable_binding:SetText("")

    -- Icon texture for the button.
    keyboard_button.icon = keyboard_button:CreateTexture(nil, "ARTWORK")
    --keyboard_button.icon:SetSize(50, 50)  -- Default size, will be set in addon:generate_keyboard_key_frames
    keyboard_button.icon:SetPoint("CENTER", keyboard_button, "CENTER", 0, 4)
    keyboard_button.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)

    -- Cooldown overlay
    keyboard_button.cooldown = addon.CreateCooldownFrame(keyboard_button, 50)
    -- Stack / charge count
    keyboard_button.count_text = addon.CreateCountText(keyboard_button)

    -- Highlight texture for the button.
    keyboard_button.highlight = keyboard_button:CreateTexture(nil, "ARTWORK")
    keyboard_button.highlight:SetPoint("CENTER", keyboard_button, "CENTER", 0, 4)
    keyboard_button.highlight:SetTexCoord(0.075, 0.925, 0.075, 0.925)
    keyboard_button.highlight:Hide()

    -- Keypress highlight border (brief glow when key is pressed)
    keyboard_button.keypress_highlight = CreateFrame("Frame", nil, keyboard_button, "BackdropTemplate")
    keyboard_button.keypress_highlight:SetPoint("TOPLEFT", keyboard_button, "TOPLEFT", -3, 3)
    keyboard_button.keypress_highlight:SetPoint("BOTTOMRIGHT", keyboard_button, "BOTTOMRIGHT", 3, -3)
    keyboard_button.keypress_highlight:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
    keyboard_button.keypress_highlight:SetBackdropBorderColor(1, 1, 1, 1)
    keyboard_button.keypress_highlight:SetFrameLevel(keyboard_button:GetFrameLevel() + 5)
    keyboard_button.keypress_highlight:Hide()

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

        addon:show_pushed_texture(slot)
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
    keyboard_button:SetScript("OnMouseDown", function(self, mousebutton)
        if mousebutton == "LeftButton" then
            if addon.keyboard_locked == false then
                addon:handle_drag_or_size(self, mousebutton)
                addon.keys_keyboard_edited = true
            else
                addon:handle_action_drag(self)
            end
        else
            if addon.keyboard_locked == false then
                addon:handle_key_down(self, mousebutton)
                addon.keys_keyboard_edited = true
            end
        end
    end)

    -- Define behavior for mouse up actions (left-click and right-click).
    keyboard_button:SetScript("OnMouseUp", function(self, mousebutton)
        if mousebutton == "LeftButton" then
            if addon.keyboard_locked == false then
                addon:handle_release(self, mousebutton)
            end
        elseif mousebutton == "RightButton" then
            addon.current_clicked_key = self    -- save the current clicked key
            addon.current_slot = self.slot      -- save the current clicked slot
            MenuUtil.CreateContextMenu(self, addon.context_menu_generator)
        end
    end)

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
