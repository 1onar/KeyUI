local name, addon = ...

-- Use centralized version detection from VersionCompat.lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

-- Save the position and scale of the controller
function addon:save_controller_position()
    if not addon.controller_frame then
        return
    end

    local x, y = addon.controller_frame:GetCenter()
    if not x or not y then
        return
    end

    keyui_settings.controller_position = keyui_settings.controller_position or {}
    keyui_settings.controller_position.x = x
    keyui_settings.controller_position.y = y
    keyui_settings.controller_position.scale = addon.controller_frame:GetScale()
end

function addon:create_controller_frame()
    local controller_frame = CreateFrame("Frame", "keyui_controller_frame", UIParent, "BackdropTemplate")
    addon.controller_frame = controller_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.close_on_esc == true then
        tinsert(UISpecialFrames, "keyui_controller_frame")
    end

    -- Set initial size and hide frame
    controller_frame:SetWidth(950)
    controller_frame:SetHeight(500)
    controller_frame:Hide()

    -- Configure backdrop with background and border
    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }
    controller_frame:SetBackdrop(backdropInfo)
    controller_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)

    -- Load the saved position if it exists
    local controller_position = keyui_settings.controller_position or {}
    keyui_settings.controller_position = controller_position
    if controller_position.x and controller_position.y then
        controller_frame:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            controller_position.x,
            controller_position.y
        )
        controller_frame:SetScale(controller_position.scale or 1)
    else
        controller_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        controller_frame:SetScale(1)
    end

    -- Enable dragging and movement (respects position lock)
    controller_frame:SetScript("OnMouseDown", function(self)
        if not keyui_settings.position_locked then
            self:StartMoving()
        end
    end)
    controller_frame:SetScript("OnMouseUp", function(self)
        if not keyui_settings.position_locked then
            self:StopMovingOrSizing()
        end
    end)
    controller_frame:SetMovable(true)
    controller_frame:SetClampedToScreen(true)

    -- Create edit mode glow border frame
    controller_frame.edit_frame = addon:CreateGlowFrame(controller_frame, {
        point = { "CENTER", controller_frame, "CENTER" },
        width = controller_frame:GetWidth(),
        height = controller_frame:GetHeight(),
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
    local custom_font = CreateFont("controller_tab_custom_font")
    custom_font:SetFont(addon:GetFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(custom_font, 0.75, false, "OUTLINE")

    -- Get controller Frame Level
    local controller_level = addon.controller_frame:GetFrameLevel()

    -- Create the close tab button
    if USE_ATLAS then
        controller_frame.close_button = CreateFrame("Button", nil, controller_frame, "PanelTopTabButtonTemplate")
    else
        controller_frame.close_button = addon:CreateTopTabButton(controller_frame)
    end
    controller_frame.close_button:SetPoint("BOTTOMRIGHT", controller_frame, "TOPRIGHT", -8, 0)
    controller_frame.close_button:SetFrameLevel(controller_level - 1)

    -- Set button text
    controller_frame.close_button:SetText("Close")

    -- Apply custom font to the controls button
    controller_frame.close_button:SetNormalFontObject(custom_font)
    controller_frame.close_button:SetHighlightFontObject(custom_font)
    controller_frame.close_button:SetDisabledFontObject(custom_font)

    local text = controller_frame.close_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", controller_frame.close_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for close button
    controller_frame.close_button:SetScript("OnClick", function(s)
        addon:discard_controller_changes()
        if addon.controls_frame then
            addon.controls_frame:Hide()
        end
        controller_frame:Hide()
    end)

    toggle_button_textures(controller_frame.close_button, true)

    controller_frame.close_button:SetScript("OnEnter", function()
        toggle_button_textures(controller_frame.close_button, false)
    end)

    controller_frame.close_button:SetScript("OnLeave", function()
        toggle_button_textures(controller_frame.close_button, true)
    end)

    -- Create the settings tab button
    if USE_ATLAS then
        controller_frame.controls_button = CreateFrame("Button", nil, controller_frame, "PanelTopTabButtonTemplate")
    else
        controller_frame.controls_button = addon:CreateTopTabButton(controller_frame)
    end
    controller_frame.controls_button:SetPoint("BOTTOMRIGHT", controller_frame.close_button, "BOTTOMLEFT", -4, 0)
    controller_frame.controls_button:SetFrameLevel(controller_level - 1)

    -- Set button text
    controller_frame.controls_button:SetText("Controls")

    -- Apply custom font to the controls button
    controller_frame.controls_button:SetNormalFontObject(custom_font)
    controller_frame.controls_button:SetHighlightFontObject(custom_font)
    controller_frame.controls_button:SetDisabledFontObject(custom_font)

    local text = controller_frame.controls_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", controller_frame.controls_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for controls button
    controller_frame.controls_button:SetScript("OnClick", function()
        addon.active_control_tab = "controller"
        addon:update_tab_textures()

        -- Check if the controls frame exists
        if addon.controls_frame then
            -- If the controls frame is visible, hide it
            if addon.controls_frame:IsVisible() then
                addon.controls_frame:Hide()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:fade_controls_button_highlight(controller_frame)
            else
                -- Otherwise, show the controls frame
                addon.controls_frame:Show()

                -- Change the style of other tab buttons, excluding the current button's frame
                addon:show_controls_button_highlight(controller_frame)
            end
        else
            -- If the controls frame doesn't exist, create and show it
            addon:get_controls_frame()

            -- Change the style of other tab buttons, excluding the current button's frame
            addon:show_controls_button_highlight(controller_frame)
        end

        addon:update_tab_visibility()
    end)

    toggle_button_textures(controller_frame.controls_button, true)

    controller_frame.controls_button:SetScript("OnEnter", function()
        toggle_button_textures(controller_frame.controls_button, false)
    end)

    controller_frame.controls_button:SetScript("OnLeave", function()
        if addon.controls_frame and addon.controls_frame:IsVisible() then
            return
        end
        toggle_button_textures(controller_frame.controls_button, true)
    end)

    -- Create the options tab button
    if USE_ATLAS then
        controller_frame.options_button = CreateFrame("Button", nil, controller_frame, "PanelTopTabButtonTemplate")
    else
        controller_frame.options_button = addon:CreateTopTabButton(controller_frame)
    end
    controller_frame.options_button:SetPoint("BOTTOMRIGHT", controller_frame.controls_button, "BOTTOMLEFT", -4, 0)
    controller_frame.options_button:SetFrameLevel(controller_level - 1)

    -- Set button text
    controller_frame.options_button:SetText("Options")

    -- Apply custom font to the options button
    controller_frame.options_button:SetNormalFontObject(custom_font)
    controller_frame.options_button:SetHighlightFontObject(custom_font)
    controller_frame.options_button:SetDisabledFontObject(custom_font)

    local text = controller_frame.options_button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", controller_frame.options_button, "BOTTOM", 0, 4)
    text:SetTextColor(1, 1, 1) -- Set text color to white

    -- Set OnClick behavior for options button
    controller_frame.options_button:SetScript("OnClick", function()
        addon:OpenSettings()
    end)

    toggle_button_textures(controller_frame.options_button, true)

    controller_frame.options_button:SetScript("OnEnter", function()
        toggle_button_textures(controller_frame.options_button, false)
    end)

    controller_frame.options_button:SetScript("OnLeave", function()
        toggle_button_textures(controller_frame.options_button, true)
    end)

    controller_frame:SetScript("OnHide", function()
        if addon.controller_locked == false or addon.keys_controller_edited == true then
            addon:discard_controller_changes()
        end
        addon.controller_layout_dirty = true
    end)

    -- Create all left-side toggle buttons (top-left)
    addon:CreateLockToggleButtons(controller_frame, controller_level, custom_font, false, "show_controller_background")

    -- Fade all tab buttons when mouse is not over the frame
    addon:SetupButtonFade(controller_frame)

    controller_frame:HookScript("OnShow", function()
        if addon.controller_layout_dirty == true then
            addon:generate_controller_key_frames()
            addon.controller_layout_dirty = false
        end
    end)

    return controller_frame
end

function addon:create_controller_image()
    -- Create controller_image as a child of controller_frame
    local controller_image = CreateFrame("Frame", "keyui_controller_image", addon.controller_frame)
    addon.controller_image = controller_image

    -- Add to UISpecialFrames to allow closing with ESC key if the setting permits
    if keyui_settings.close_on_esc == true then
        tinsert(UISpecialFrames, "keyui_controller_image")
    end

    -- Check for the controller system type
    if addon.controller_system == "generic" then
        -- coming soon

    elseif addon.controller_system == "xbox" then
        -- Add Xbox controller texture
        controller_image.xbox = controller_image:CreateTexture(nil, "ARTWORK")
        controller_image.xbox:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\xbox.blp")
        controller_image.xbox:SetPoint("BOTTOM", addon.controller_frame, "BOTTOM", -1, 40)
        controller_image.xbox:SetSize(512, 512)

        -- Add lines overlay texture for the Xbox controller
        controller_image.xbox_lines = controller_image:CreateTexture(nil, "OVERLAY")
        controller_image.xbox_lines:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\lines_xbox.blp")
        controller_image.xbox_lines:SetPoint("CENTER", controller_image.xbox, "CENTER", -2, 0)
        controller_image.xbox_lines:SetSize(1200, 600)

        addon.controller_frame:SetHeight(530)

        addon.controller_frame.edit_frame:SetSize(addon.controller_frame:GetWidth(), addon.controller_frame:GetHeight())

    elseif addon.controller_system == "ds4" then
        -- Add ds4 controller texture
        controller_image.ds4 = controller_image:CreateTexture(nil, "ARTWORK")
        controller_image.ds4:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\ds4.blp")
        controller_image.ds4:SetPoint("BOTTOM", addon.controller_frame, "BOTTOM", -2, 0)
        controller_image.ds4:SetSize(512, 512)

        -- Add lines overlay texture for the ds4 controller
        controller_image.ds4_lines = controller_image:CreateTexture(nil, "OVERLAY")
        controller_image.ds4_lines:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\lines_ds4.blp")
        controller_image.ds4_lines:SetPoint("CENTER", controller_image.ds4, "CENTER", -2, 0)
        controller_image.ds4_lines:SetSize(1200, 590)

        addon.controller_frame:SetHeight(516)

        addon.controller_frame.edit_frame:SetSize(addon.controller_frame:GetWidth(), addon.controller_frame:GetHeight())

    elseif addon.controller_system == "ds5" then
        -- Add ds5 controller texture
        controller_image.ds5 = controller_image:CreateTexture(nil, "ARTWORK")
        controller_image.ds5:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\ds5.blp")
        controller_image.ds5:SetPoint("BOTTOM", addon.controller_frame, "BOTTOM", -3, 0)
        controller_image.ds5:SetSize(512, 512)

        -- Add lines overlay texture for the ds5 controller
        controller_image.ds5_lines = controller_image:CreateTexture(nil, "OVERLAY")
        controller_image.ds5_lines:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\lines_ds5.blp")
        controller_image.ds5_lines:SetPoint("CENTER", controller_image.ds5, "CENTER", -1, 0)
        controller_image.ds5_lines:SetSize(1150, 590)

        addon.controller_frame:SetHeight(516)
        addon.controller_frame:SetWidth(920)

        addon.controller_frame.edit_frame:SetSize(addon.controller_frame:GetWidth(), addon.controller_frame:GetHeight())

    elseif addon.controller_system == "deck" then
        -- Add deck controller texture
        controller_image.deck = controller_image:CreateTexture(nil, "ARTWORK")
        controller_image.deck:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\deck.blp")
        controller_image.deck:SetPoint("CENTER", addon.controller_frame, "CENTER", 0, 10)
        controller_image.deck:SetSize(512, 512)

        -- Add lines overlay texture for the deck controller
        -- controller_image.deck_lines = controller_image:CreateTexture(nil, "OVERLAY")
        -- controller_image.deck_lines:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\lines_deck.blp")
        -- controller_image.deck_lines:SetPoint("CENTER", controller_image.deck, "CENTER", -1, 0)
        -- controller_image.deck_lines:SetSize(1150, 590)

        addon.controller_frame:SetHeight(600)
        addon.controller_frame:SetWidth(920)

        addon.controller_frame.edit_frame:SetSize(addon.controller_frame:GetWidth(), addon.controller_frame:GetHeight())

    else
        return
    end

    return controller_image
end

function addon:update_controller_image()
    -- Check if a controller image already exists and hide it if so
    if addon.controller_image then
        addon.controller_image:Hide()
        addon.controller_image:ClearAllPoints()
        addon.controller_image:SetParent(nil)
    end

    -- Create a new controller image based on the current system type
    addon:create_controller_image()
end

function addon:set_controller_system(system_type)
    -- Set the controller system type
    addon.controller_system = system_type
    -- Update the controller image to match the new system type
    addon:update_controller_image()
end

function addon:save_controller_layout(layout_name)
    local name = layout_name

    if name ~= "" then
        print("KeyUI: Saved the new controller layout '" .. name .. "'.")

        -- Initialize a new table for the saved layout
        keyui_settings.layout_edited_controller[name] = {}

        -- Get the center of the controller frame for relative X calculation
        local controller_center_x = addon.controller_frame:GetLeft() + (addon.controller_frame:GetWidth() / 2)
        local controller_bottom_y = addon.controller_frame:GetBottom()

        -- Iterate through all controller buttons to save their data
        for _, button in ipairs(addon.keys_controller) do
            if button:IsVisible() then
                -- Save button properties: label, position, width, and height
                keyui_settings.layout_edited_controller[name][#keyui_settings.layout_edited_controller[name] + 1] = {
                    button.raw_key,                                                     -- Button name
                    floor(button:GetCenter() - controller_center_x + 0.5),              -- X position relative to CENTER
                    floor(button:GetBottom() - controller_bottom_y + 0.5),              -- Y position relative to BOTTOM
                    floor(button:GetWidth() + 0.5),                                     -- Width
                    floor(button:GetHeight() + 0.5)                                     -- Height
                }
            end
        end

        -- Set the layout_type for the saved layout
        keyui_settings.layout_edited_controller[name].layout_type = addon.controller_system or "generic"

        -- Clear the current layout and assign the new one
        wipe(keyui_settings.layout_current_controller)
        keyui_settings.layout_current_controller[name] = keyui_settings.layout_edited_controller[name]

        -- Remove Controller edited flag
        addon.keys_controller_edited = false
        if addon.controller_frame.edit_frame then
            addon.controller_frame.edit_frame:Hide()
        end

        -- Refresh the keys and update the dropdown menu
        addon:refresh_layouts()

        if addon.controller_selector then
            addon.controller_selector:SetDefaultText(name)
        end
    else
        print("KeyUI: Please enter a name for the layout before saving.")
    end
end

-- Discards any changes made to the controller layout and resets the Control UI state
function addon:discard_controller_changes()

    if addon.keys_controller_edited == true then
        -- Print message to the player
        print("KeyUI: Changes discarded.")
    end

    -- Remove controller locked flag
    addon.controller_locked = true

    -- Remove controller edited flag
    addon.keys_controller_edited = false
    if addon.controller_frame.edit_frame then
        addon.controller_frame.edit_frame:Hide()
    end

    addon:refresh_layouts()
end

local modifier_keys = {
    LALT = true, RALT = true,
    LCTRL = true, RCTRL = true,
    LSHIFT = true, RSHIFT = true,
}

-- This function updates the controller layout by creating, positioning, and resizing button frames based on the current configuration.
function addon:generate_controller_key_frames()
    -- Clear existing keys to avoid leftover data from previous layouts
    for i = 1, #addon.keys_controller do
        addon.keys_controller[i]:Hide()
        addon.keys_controller[i] = nil
    end
    addon.keys_controller = {}

    if addon.open == true and addon.controller_frame then
        -- Check if the layout is empty
        local layout_not_empty = false
        for _, layoutData in pairs(keyui_settings.layout_current_controller) do
            if #layoutData > 0 then
                layout_not_empty = true
                break
            end
        end

        -- Only proceed if there is a valid layout
        if layout_not_empty then
            for _, layoutData in pairs(keyui_settings.layout_current_controller) do
                for i = 1, #layoutData do
                    local button = addon.keys_controller[i] or addon:create_controller_buttons()
                    local button_data = layoutData[i]

                    button:SetWidth(button_data[4] or 50)
                    button:SetHeight(button_data[5] or 50)

                    -- Set the controller button's icon size
                    local icon_width, icon_height = 44, 44
                    button.icon:SetSize(icon_width, icon_height)

                    -- If the button doesn't have an original icon size, set it
                    if not button.original_icon_size then
                        button.original_icon_size = { width = icon_width, height = icon_height }
                    end

                    if not addon.keys_controller[i] then
                        addon.keys_controller[i] = button
                    end

                    -- Set the button position relative to the controller frame
                    button:SetPoint("BOTTOM", addon.controller_frame, "BOTTOM", button_data[2], button_data[3])
                    button.raw_key = button_data[1]
                    button.is_modifier = modifier_keys[button.raw_key] or false

                    -- Determine the position of the short_key text based on the X-coordinate in button_data[2]
                    if button_data[2] < -200 then
                        -- If the X-coordinate is negative, position the short_key to the left of the button
                        button.short_key:SetPoint("LEFT", button, "RIGHT", 10, 0)
                    elseif button_data[2] > 200 then
                        -- If the X-coordinate is positive, position the short_key to the right of the button
                        button.short_key:SetPoint("RIGHT", button, "LEFT", -10, 0)
                    else
                        if button_data[3] < 100 then
                            button.short_key:SetPoint("BOTTOM", button, "TOP", 0, 10)
                        elseif button_data[3] > 100 then
                            button.short_key:SetPoint("TOP", button, "BOTTOM", 0, -10)
                        end
                    end

                    button:Show()
                end
            end
        end
    end

    addon:ApplyClickThrough()
end

-- Create a new button to the main controller image frame.
function addon:create_controller_buttons()

    -- Use a non-secure button to avoid combat lockdown on interaction state changes.
    local controller_button = CreateFrame("Button", nil, addon.controller_frame)

    -- Add Background Texture
    local background = controller_button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\actionbutton_bg")
    background:SetWidth(44)
    background:SetHeight(44)
    background:SetPoint("CENTER", controller_button, "CENTER", 0, 0)
    controller_button.background = background

    -- Add Border Texture
    local border = controller_button:CreateTexture(nil, "OVERLAY")
    addon:SetTexture(border, "UI-HUD-ActionBar-IconFrame",
        "Interface\\AddOns\\KeyUI\\Media\\Atlas\\CombatAssistantSingleButton",
        {0.707031, 0.886719, 0.248047, 0.291992})
    border:SetAllPoints()
    controller_button.border = border

    controller_button:SetMovable(true)
    controller_button:EnableMouse(true)
    controller_button:EnableKeyboard(true)
    controller_button:EnableGamePadButton(true)

    -- controller Keybind text string on the top right of the button (e.g. a-c-s-1)
    controller_button.short_key = controller_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controller_button.short_key:SetTextColor(1, 1, 1)
    controller_button.short_key:SetScale(1.4)
    -- controller_button.short_key:SetPoint("LEFT", controller_button, "RIGHT", 10, 0)
    -- controller_button.short_key:SetJustifyH("RIGHT")
    -- controller_button.short_key:SetJustifyV("TOP")
    controller_button.short_key:Show()

    -- Font string to display the interface action text (toggled by function addon:create_action_labels)
    controller_button.readable_binding = controller_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    controller_button.readable_binding:SetFont(addon:GetCondensedFont(), addon:GetFontSize(0.75), "OUTLINE")
    addon:RegisterFontString(controller_button.readable_binding, 0.75, true, "OUTLINE")
    controller_button.readable_binding:SetTextColor(1, 1, 1)
    controller_button.readable_binding:SetHeight(25)
    --controller_button.readable_binding:SetWidth(46)    -- will be calculated in addon:create_action_labels
    controller_button.readable_binding:SetPoint("BOTTOM", controller_button, "BOTTOM", 1, 6)
    controller_button.readable_binding:SetJustifyV("BOTTOM")
    controller_button.readable_binding:SetText("")

    -- Icon texture for the button.
    controller_button.icon = controller_button:CreateTexture(nil, "ARTWORK")
    --controller_button.icon:SetSize(44, 44)    -- Default size will be set in addon:generate_controller_key_frames
    controller_button.icon:SetPoint("CENTER", controller_button, "CENTER", 0, 0)
    controller_button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Highlight texture for the button.
    controller_button.highlight = controller_button:CreateTexture(nil, "ARTWORK")
    controller_button.highlight:SetSize(44, 44)
    controller_button.highlight:SetPoint("CENTER", controller_button, "CENTER", 0, 0)
    controller_button.highlight:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    controller_button.highlight:Hide()

    -- Keypress highlight border (brief glow when key is pressed)
    controller_button.keypress_highlight = CreateFrame("Frame", nil, controller_button, "BackdropTemplate")
    controller_button.keypress_highlight:SetPoint("TOPLEFT", controller_button, "TOPLEFT", -3, 3)
    controller_button.keypress_highlight:SetPoint("BOTTOMRIGHT", controller_button, "BOTTOMRIGHT", 3, -3)
    controller_button.keypress_highlight:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
    controller_button.keypress_highlight:SetBackdropBorderColor(1, 1, 1, 1)
    controller_button.keypress_highlight:SetFrameLevel(controller_button:GetFrameLevel() + 5)
    controller_button.keypress_highlight:Hide()

    controller_button:SetScript("OnEnter", function(self)
        addon.current_hovered_button = controller_button -- save the current hovered button to re-trigger tooltip
        addon:button_mouse_over(controller_button)
        controller_button:EnableKeyboard(true)
        controller_button:EnableMouseWheel(true)

        local active_slot = self.active_slot

        if addon.controller_locked == false and not addon.is_moving then

            controller_button:SetScript("OnKeyDown", function(_, key)
                addon:handle_key_down(addon.current_hovered_button, key)
                addon.keys_controller_edited = true
            end)

            controller_button:SetScript("OnGamePadButtonDown", function(_, key)
                addon:handle_gamepad_down(addon.current_hovered_button, key)
                addon.keys_controller_edited = true
            end)

            controller_button:SetScript("OnMouseWheel", function(_, delta)
                addon:handle_mouse_wheel(addon.current_hovered_button, delta)
                addon.keys_controller_edited = true
            end)

        end

        addon:show_pushed_texture(active_slot)
    end)

    controller_button:SetScript("OnLeave", function()
        addon.current_hovered_button = nil -- Clear the current hovered button
        GameTooltip:Hide()
        addon.keyui_tooltip_frame:Hide()
        controller_button:EnableKeyboard(false)
        controller_button:EnableMouseWheel(false)

        if addon.current_pushed_button then
            addon.current_pushed_button:Hide()
            addon.current_pushed_button = nil -- Clear the current pushed button
        end
    end)

    controller_button:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if addon.controller_locked == false then
                addon:handle_drag_or_size(self, button)
                addon.keys_controller_edited = true
            else
                addon:handle_action_drag(self)
            end
        else
            if addon.controller_locked == false then
                addon:handle_key_down(self, button)
                addon.keys_controller_edited = true
            end
        end
    end)

    controller_button:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if addon.controller_locked == false then
                addon:handle_release(self, button)
            end
        elseif button == "RightButton" then
            addon.current_clicked_key = self    -- save the current clicked key
            addon.current_slot = self.slot      -- save the current clicked slot
            MenuUtil.CreateContextMenu(self, addon.context_menu_generator)
        end
    end)

    -- Store the created button in the keyboard_buttons table
    if not self.controller_buttons then
        self.controller_buttons = {}  -- Initialize the table if it doesn't exist
    end
    table.insert(self.controller_buttons, controller_button)  -- Add the new button to the table

    return controller_button
end

function addon:generate_controller_layout(layout_name)
    -- Validate layout_name
    if not layout_name or layout_name == "" then
        return
    end

    -- Discard controller Editor Changes
    if addon.controller_locked == false or addon.keys_controller_edited == true then
        addon:discard_controller_changes()
    end

    -- Check whether the layout exists
    local layout = addon.default_controller_layouts[layout_name] or keyui_settings.layout_edited_controller[layout_name]
    if not layout then
        print("Error: controller layout " .. layout_name .. " not found.")
        return
    end

    -- Set the controller system type based on the layout's type
    if layout.layout_type then
        addon.controller_system = layout.layout_type
        addon:update_controller_image()
    else
        addon.controller_system = nil  -- Set to nil if the layout_type is not defined
    end

    -- Update settings
    wipe(keyui_settings.layout_current_controller)
    keyui_settings.layout_current_controller[layout_name] = layout
    keyui_settings.key_bind_settings_controller.currentboard = layout_name

    -- Reload layouts
    --addon:refresh_layouts()
end
