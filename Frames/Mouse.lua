local name, addon = ...

-- Use centralized version detection from VersionCompat.lua

-- Save the position and scale of the mouse holder
function addon:save_mouse_position()
    if not addon.mouse_image then
        return
    end

    local x, y = addon.mouse_image:GetCenter()
    if not x or not y then
        return
    end

    keyui_settings.mouse_position = keyui_settings.mouse_position or {}
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
    local mouse_position = keyui_settings.mouse_position or {}
    keyui_settings.mouse_position = mouse_position
    if mouse_position.x and mouse_position.y then
        mouse_image:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            mouse_position.x,
            mouse_position.y
        )
        mouse_image:SetScale(mouse_position.scale or 1)
    else
        mouse_image:SetPoint("CENTER", UIParent, "CENTER", 450, 0)
        mouse_image:SetScale(1)
    end

    -- Enable dragging and movement (respects position lock)
    mouse_image:SetScript("OnMouseDown", function(self)
        if not keyui_settings.position_locked then
            self:StartMoving()
        end
    end)
    mouse_image:SetScript("OnMouseUp", function(self)
        if not keyui_settings.position_locked then
            self:StopMovingOrSizing()
        end
    end)
    mouse_image:SetMovable(true)
    mouse_image:SetClampedToScreen(true)

    -- Set mouse texture
    mouse_image.Texture = mouse_image:CreateTexture()
    mouse_image.Texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\mouse.tga")
    mouse_image.Texture:SetPoint("CENTER", mouse_image, "CENTER", 0, 0)
    mouse_image.Texture:SetSize(390, 390)

    -- Create close button
    mouse_image.close_button = addon:CreateExitButton(mouse_image)
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


    mouse_image:SetScript("OnHide", function()
        if addon.mouse_locked == false or addon.keys_mouse_edited == true then
            addon:discard_mouse_changes()
        end
        addon.mouse_layout_dirty = true
    end)

    -- Create arrow-down button for toggle menu (left of close button)
    mouse_image.menu_button = addon:CreateArrowDownButton(mouse_image)
    mouse_image.menu_button:SetPoint("TOPRIGHT", mouse_image.close_button, "TOPLEFT", -2, 0)

    -- Store the bg_setting on the frame for UpdateAllToggleVisuals compatibility
    mouse_image._bg_setting = "show_mouse_graphic"

    -- Open native WoW context menu with toggle checkboxes on arrow button click
    mouse_image.menu_button:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            local bg = rootDescription:CreateCheckbox("Background",
                function() return keyui_settings.show_mouse_graphic end,
                function()
                    keyui_settings.show_mouse_graphic = not keyui_settings.show_mouse_graphic
                    addon:ApplyFrameBackgrounds()
                    addon:UpdateAllToggleVisuals()
                end)
            bg:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Background")
                GameTooltip_AddNormalLine(tooltip, "Show or hide the mouse graphic")
            end)

            local esc = rootDescription:CreateCheckbox("ESC",
                function() return keyui_settings.close_on_esc end,
                function()
                    keyui_settings.close_on_esc = not keyui_settings.close_on_esc
                    addon:ApplyEscClose()
                    addon:UpdateAllToggleVisuals()
                end)
            esc:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "ESC")
                GameTooltip_AddNormalLine(tooltip, "Close windows with the ESC key")
            end)

            local combat = rootDescription:CreateCheckbox("Combat",
                function() return keyui_settings.stay_open_in_combat end,
                function()
                    keyui_settings.stay_open_in_combat = not keyui_settings.stay_open_in_combat
                    addon:UpdateAllToggleVisuals()
                end)
            combat:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Combat")
                GameTooltip_AddNormalLine(tooltip, "Stay open during combat")
            end)

            local lock = rootDescription:CreateCheckbox("Lock",
                function() return keyui_settings.position_locked end,
                function()
                    keyui_settings.position_locked = not keyui_settings.position_locked
                    if not keyui_settings.position_locked then
                        keyui_settings.click_through = false
                        addon:ApplyClickThrough()
                    end
                    addon:UpdateAllToggleVisuals()
                end)
            lock:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Lock")
                GameTooltip_AddNormalLine(tooltip, "Lock frame positions to prevent accidental movement")
            end)

            local ghost = rootDescription:CreateCheckbox("Ghost",
                function() return keyui_settings.click_through end,
                function()
                    if not keyui_settings.position_locked then return end
                    keyui_settings.click_through = not keyui_settings.click_through
                    addon:ApplyClickThrough()
                    addon:UpdateAllToggleVisuals()
                end)
            ghost:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Ghost")
                GameTooltip_AddNormalLine(tooltip, "Make visualization frames click-through (requires Lock)")
            end)

            rootDescription:CreateDivider()

            rootDescription:CreateButton("Controls", function()
                addon.active_control_tab = "mouse"
                addon:update_tab_textures()

                if addon.controls_frame then
                    if addon.controls_frame:IsVisible() then
                        addon.controls_frame:Hide()
                        addon:fade_controls_button_highlight(mouse_image)
                    else
                        addon.controls_frame:Show()
                        addon:show_controls_button_highlight(mouse_image)
                    end
                else
                    addon:get_controls_frame()
                    addon:show_controls_button_highlight(mouse_image)
                end

                addon:update_tab_visibility()
            end)

            rootDescription:CreateButton("Options", function()
                addon:OpenSettings()
            end)
        end)
    end)

    -- Fade all tab buttons when mouse is not over the frame
    addon:SetupButtonFade(mouse_image)

    mouse_image:HookScript("OnShow", function()
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
    local active_count = 0

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
                    local button_data = layoutData[i]
                    active_count = active_count + 1

                    local button = addon:AcquireKeyButton("mouse", active_count)
                    if not button then
                        active_count = active_count - 1
                        break
                    end

                    button:SetWidth(button_data[4] or 50)
                    button:SetHeight(button_data[5] or 50)

                    -- Set the mouse button's icon size
                    local icon_width, icon_height = 44, 44
                    button.icon:SetSize(icon_width, icon_height)

                    -- If the button doesn't have an original icon size, set it
                    if not button.original_icon_size then
                        button.original_icon_size = { width = icon_width, height = icon_height }
                    end

                    addon.keys_mouse[active_count] = button
                    button:ClearAllPoints()
                    button:SetPoint("TOPRIGHT", addon.mouse_frame, "TOPRIGHT", button_data[2], button_data[3])
                    button.raw_key = button_data[1]
                    button.is_modifier = modifier_keys[button.raw_key] or false
                    button:Show()
                end
            end
        end
    end

    addon:ReleaseUnusedKeyButtons("mouse", active_count, addon.keys_mouse)
    addon:ApplyClickThrough()
end

-- Create a new button to the main mouse image frame.
function addon:create_mouse_buttons()

    -- Use a non-secure button to avoid combat lockdown on mouse interaction updates.
    local mouse_button = CreateFrame("Button", nil, addon.mouse_image)

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
    addon:SetTexture(border, "UI-HUD-ActionBar-IconFrame",
        "Interface\\AddOns\\KeyUI\\Media\\Atlas\\CombatAssistantSingleButton",
        {0.707031, 0.886719, 0.248047, 0.291992})
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
