local _, addon = ...

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
    -- Not in combat: the frame parents secure buttons, as in Keyboard.lua and Mouse.lua.
    controller_frame:SetScript("OnMouseDown", function(self)
        if not keyui_settings.position_locked and not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    controller_frame:SetScript("OnMouseUp", function(self)
        if not keyui_settings.position_locked and not InCombatLockdown() then
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

    -- Apply custom font to the tab buttons. Reuse the named font on a rebuild so the font
    -- registry, keyed by object, keeps one entry for it however CreateFont treats a taken name.
    local custom_font = _G["controller_tab_custom_font"] or CreateFont("controller_tab_custom_font")
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
        addon:SafeHideFrame(controller_frame)
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

    text = controller_frame.controls_button:GetFontString()
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

    text = controller_frame.options_button:GetFontString()
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

    -- Closing (discarding edits) and showing are handled by the hooks in
    -- addon:get_controller_frame and on_frame_hide (Core.lua).

    -- Create toggle menu button (top-left)
    addon:CreateToggleMenuButton(controller_frame, "show_controller_background")

    -- Fade all tab buttons when mouse is not over the frame
    addon:SetupButtonFade(controller_frame)

    return controller_frame
end

-- Artwork per controller system: the controller body and its button lines, with anchors
-- relative to controller_frame, plus the frame size each one needs.
local CONTROLLER_ARTWORK = {
    xbox = {
        body  = { file = "xbox", point = { "BOTTOM", "BOTTOM", -1, 40 }, size = { 512, 512 } },
        lines = { file = "lines_xbox", offset = { -2, 0 }, size = { 1200, 600 } },
        height = 530,
    },
    ds4 = {
        body  = { file = "ds4", point = { "BOTTOM", "BOTTOM", -2, 0 }, size = { 512, 512 } },
        lines = { file = "lines_ds4", offset = { -2, 0 }, size = { 1200, 590 } },
        height = 516,
    },
    ds5 = {
        body  = { file = "ds5", point = { "BOTTOM", "BOTTOM", -3, 0 }, size = { 512, 512 } },
        lines = { file = "lines_ds5", offset = { -1, 0 }, size = { 1150, 590 } },
        height = 516,
        width = 920,
    },
    deck = {
        -- The deck has no line overlay yet (Media/Frame/Controller/lines_deck.blp is unused).
        body  = { file = "deck", point = { "CENTER", "CENTER", 0, 10 }, size = { 512, 512 } },
        height = 600,
        width = 920,
    },
    -- "generic": coming soon
}

local CONTROLLER_MEDIA = "Interface\\AddOns\\KeyUI\\Media\\Frame\\Controller\\"

-- Builds the controller artwork for addon.controller_system on a single, reused frame.
--
-- This used to create a new named frame on every call, and show_frames calls it on every
-- open: with no controller layout selected it returned nil, so the next open made yet
-- another one. WoW never frees frames, so each open leaked a frame (and, with ESC-close
-- on, another UISpecialFrames entry). Now there is one frame, its two textures are
-- re-pointed, and the frame is always returned.
function addon:create_controller_image()
    local controller_image = addon.controller_image
    if not controller_image then
        controller_image = CreateFrame("Frame", "keyui_controller_image", addon.controller_frame)
        controller_image.body = controller_image:CreateTexture(nil, "ARTWORK")
        controller_image.lines = controller_image:CreateTexture(nil, "OVERLAY")
        addon.controller_image = controller_image

        -- Add to UISpecialFrames to allow closing with ESC key if the setting permits
        if keyui_settings.close_on_esc == true then
            tinsert(UISpecialFrames, "keyui_controller_image")
        end
    end

    local artwork = CONTROLLER_ARTWORK[addon.controller_system]
    controller_image.shown_system = addon.controller_system

    local body, lines = controller_image.body, controller_image.lines
    body:Hide()
    lines:Hide()
    if not artwork then
        return controller_image
    end

    local frame = addon.controller_frame
    local point = artwork.body.point
    body:SetTexture(CONTROLLER_MEDIA .. artwork.body.file .. ".blp")
    body:ClearAllPoints()
    body:SetPoint(point[1], frame, point[2], point[3], point[4])
    body:SetSize(artwork.body.size[1], artwork.body.size[2])
    body:Show()

    if artwork.lines then
        lines:SetTexture(CONTROLLER_MEDIA .. artwork.lines.file .. ".blp")
        lines:ClearAllPoints()
        lines:SetPoint("CENTER", body, "CENTER", artwork.lines.offset[1], artwork.lines.offset[2])
        lines:SetSize(artwork.lines.size[1], artwork.lines.size[2])
        lines:Show()
    end

    frame:SetHeight(artwork.height)
    if artwork.width then
        frame:SetWidth(artwork.width)
    end
    frame.edit_frame:SetSize(frame:GetWidth(), frame:GetHeight())

    return controller_image
end

function addon:update_controller_image()
    -- Already showing this system: nothing to redo.
    local controller_image = addon.controller_image
    if controller_image and controller_image.shown_system == addon.controller_system then
        return
    end
    addon:create_controller_image()
end

function addon:set_controller_system(system_type)
    -- Set the controller system type
    addon.controller_system = system_type
    -- Update the controller image to match the new system type
    addon:update_controller_image()
end

function addon:save_controller_layout(layout_name)
    local name, name_error = addon:NormalizeLayoutName(layout_name)
    if not name then
        print("KeyUI: " .. (name_error or "Please enter a name for the layout before saving."))
        return
    end

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
end

-- Discards any changes made to the controller layout and resets the Control UI state
function addon:discard_controller_changes()
    -- Nothing moved while the device stayed locked and unedited, so the keys on screen
    -- already match the saved layout. Rebuilding them anyway made every close button run
    -- a full refresh_layouts right before hiding the frame.
    local needs_rebuild = addon.controller_locked == false or addon.keys_controller_edited == true

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

    if needs_rebuild then
        addon:refresh_layouts()
    end
end

local modifier_keys = {
    LALT = true, RALT = true,
    LCTRL = true, RCTRL = true,
    LSHIFT = true, RSHIFT = true,
}

-- This function updates the controller layout by creating, positioning, and resizing button frames based on the current configuration.
function addon:generate_controller_key_frames()
    local active_count = 0

    if addon.open == true and addon.controller_frame then
        local layout_data = addon:GetCurrentLayout(keyui_settings.layout_current_controller)

        for i = 1, layout_data and #layout_data or 0 do
            local button_data = layout_data[i]
            active_count = active_count + 1

            local button = addon:AcquireKeyButton("controller", active_count)
            if not button then
                active_count = active_count - 1
                break
            end

            button:SetWidth(button_data[4] or 50)
            button:SetHeight(button_data[5] or 50)

            -- Set the controller button's icon size
            local icon_width, icon_height = 44, 44
            button.icon:SetSize(icon_width, icon_height)

            -- If the button doesn't have an original icon size, set it
            if not button.original_icon_size then
                button.original_icon_size = { width = icon_width, height = icon_height }
            end

            addon.keys_controller[active_count] = button
            button:ClearAllPoints()
            -- Set the button position relative to the controller frame
            button:SetPoint("BOTTOM", addon.controller_frame, "BOTTOM", button_data[2], button_data[3])
            button.raw_key = button_data[1]
            button.is_modifier = modifier_keys[button.raw_key] or false

            -- Determine the position of the short_key text based on the X-coordinate in button_data[2]
            button.short_key:ClearAllPoints()
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
                else
                    button.short_key:SetPoint("BOTTOM", button, "TOP", 0, 10)
                end
            end

            button:Show()
        end
    end

    -- Click-through is applied once by the caller (refresh_layouts), not once per device.
    addon:ReleaseUnusedKeyButtons("controller", active_count, addon.keys_controller)
end

-- Create a new button to the main controller image frame.
function addon:create_controller_buttons(index)

    -- Secure action button: allows combat clicks and drag/drop on action slots.
    -- ActionButtonSpellFXTemplate adds spell cast/channel/empower animations (Mainline clients: Retail, Forever).
    local name = "KeyUIButton_controller_" .. (index or 0)
    local templates = addon.VERSION.isModern
        and "SecureActionButtonTemplate, ActionButtonSpellFXTemplate"
        or  "SecureActionButtonTemplate"
    local controller_button = CreateFrame("CheckButton", name, addon.controller_frame, templates)

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
    -- Keyboard, wheel and gamepad input only while hovered in edit mode; see
    -- SetKeyCaptureEnabled.

    -- Release-only clicks, and no action on right-click; see InitSecureClickAttributes.
    -- Drag registration so dragging picks up the action instead of casting the spell.
    addon:InitSecureClickAttributes(controller_button)
    controller_button:RegisterForDrag("LeftButton", "RightButton")

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

    -- Cooldown overlay
    controller_button.cooldown = addon.CreateCooldownFrame(controller_button, 44)
    -- Stack / charge count
    controller_button.count_text = addon.CreateCountText(controller_button)
    -- Charge recharge cooldown (separate ring, no swipe)
    controller_button.charge_cooldown = addon.CreateChargeCooldownFrame(controller_button)
    -- Loss-of-Control cooldown (red swipe for stun/fear/etc.)
    controller_button.loc_cooldown = addon.CreateLoCCooldownFrame(controller_button)
    -- Auto-attack / auto-shot flash overlay
    controller_button.flash_texture = addon.CreateFlashTexture(controller_button)
    -- Equipped item border (green border when item is equipped)
    controller_button.equipped_border = addon.CreateEquippedBorder(controller_button)
    -- Pet auto-cast rotating dots overlay
    controller_button.autocast_overlay = addon.CreateAutoCastOverlay(controller_button, name)

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

    -- Edit mode: hover a key and press a key, turn the wheel or press a gamepad button
    -- to rename it.
    addon:InstallKeyEditHandlers(controller_button,
        function() return addon.controller_locked == false end,
        function() addon.keys_controller_edited = true end)

    controller_button:SetScript("OnEnter", function(self)
        addon.current_hovered_button = controller_button -- save the current hovered button to re-trigger tooltip
        addon:button_mouse_over(controller_button)

        -- Only in edit mode; see create_mouse_buttons for what the unconditional
        -- switch-on did.
        addon:SetKeyCaptureEnabled(controller_button, addon.controller_locked == false and not addon.is_moving)

        addon:show_pushed_texture(self.active_slot)
    end)

    controller_button:SetScript("OnLeave", function()
        addon.current_hovered_button = nil -- Clear the current hovered button
        GameTooltip:Hide()
        if addon.keyui_tooltip_frame then addon.keyui_tooltip_frame:Hide() end
        addon:SetKeyCaptureEnabled(controller_button, false)

        if addon.current_pushed_button then
            addon.current_pushed_button:Hide()
            addon.current_pushed_button = nil -- Clear the current pushed button
        end
    end)

    -- Drag start: pick up action from slot (locked mode only, outside combat).
    controller_button:SetScript("OnDragStart", function(self, mousebutton)
        if addon.controller_locked ~= false and mousebutton == "LeftButton" then
            addon:handle_action_drag(self)
        end
    end)

    -- Receive drag: place action into slot (locked mode only, outside combat).
    controller_button:SetScript("OnReceiveDrag", function(self)
        if addon.controller_locked ~= false then
            addon:handle_action_drag(self)
        end
    end)

    controller_button:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if addon.controller_locked == false then
                addon:handle_drag_or_size(self, button)
                addon.keys_controller_edited = true
            end
        elseif button ~= "RightButton" then
            -- Right-click opens the context menu on release; see create_keyboard_buttons.
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
