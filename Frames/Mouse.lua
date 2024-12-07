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
    if keyui_settings.prevent_esc_close ~= false then
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
        mouse_image:SetPoint("CENTER", UIParent, "CENTER", 450, 50)
        mouse_image:SetScale(1)
    end

    mouse_image:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    mouse_image:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    mouse_image:SetMovable(true)
    mouse_image:SetClampedToScreen(true)

    mouse_image.Texture = mouse_image:CreateTexture()
    mouse_image.Texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Frame\\mouse.tga")
    mouse_image.Texture:SetPoint("Center", mouse_image, "Center", 0, 0)
    mouse_image.Texture:SetSize(390, 390)

    mouse_image.close_button = CreateFrame("Button", nil, mouse_image, "UIPanelCloseButton")
    mouse_image.close_button:SetSize(30, 30)
    mouse_image.close_button:SetPoint("TOPRIGHT", 0, 0)
    mouse_image.close_button:SetScript("OnClick", function(s)
        addon:discard_keyboard_changes()
        if addon.controls_frame then
            addon.controls_frame:Hide()
        end
        mouse_image:Hide()
    end)

    return mouse_image
end

function addon:create_mouse_frame()
    local mouse_frame = CreateFrame("Frame", "keyui_mouse_frame", addon.mouse_image)
    addon.mouse_frame = mouse_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_mouse_frame")
    end

    mouse_frame:SetWidth(50)
    mouse_frame:SetHeight(50)
    mouse_frame:SetPoint("RIGHT", addon.mouse_image, "LEFT", 5, -25)
    mouse_frame:SetScale(1)
    mouse_frame:Hide()

    return mouse_frame
end

local function drag_or_size(self, Mousebutton)
    if self.mouse_locked then
        return -- Do nothing if not MouseLocked is selected
    end

    if Mousebutton == "LeftButton" and IsShiftKeyDown() then
        self.keys_mouse = nil
        self:Hide()
    elseif Mousebutton == "LeftButton" then
        self:StartMoving()
        addon.isMoving = true -- Add a flag to indicate the frame is being moved
    end
end

local function release(self, Mousebutton)
    if Mousebutton == "LeftButton" then
        self:StopMovingOrSizing()
        addon.isMoving = false -- Reset the flag when the movement is stopped
    end
end

function addon:save_mouse_layout()
    local msg = addon.controls_frame.Input:GetText()

    if addon.mouse_locked == true then
        if msg ~= "" then
            -- Clear the input field and focus
            addon.controls_frame.Input:SetText("")
            addon.controls_frame.Input:ClearFocus()

            print("KeyUI: Saved the new layout '" .. msg .. "'.")

            -- Initialize a new table for the saved layout
            keyui_settings.layout_edited_mouse[msg] = {}

            -- Iterate through all mouse buttons to save their data
            for _, Mousebutton in ipairs(addon.keys_mouse) do
                if Mousebutton:IsVisible() then
                    -- Save button properties: label, position, width, and height
                    keyui_settings.layout_edited_mouse[msg][#keyui_settings.layout_edited_mouse[msg] + 1] = {
                        Mousebutton.raw_key,                                                -- Button name
                        floor(Mousebutton:GetLeft() - addon.mouse_frame:GetLeft() + 0.5),   -- X position
                        floor(Mousebutton:GetTop() - addon.mouse_frame:GetTop() + 0.5),     -- Y position
                        floor(Mousebutton:GetWidth() + 0.5),                                -- Width
                        floor(Mousebutton:GetHeight() + 0.5)                                -- Height
                    }
                end
            end

            -- Clear the current layout and assign the new one
            wipe(keyui_settings.layout_current_mouse)
            keyui_settings.layout_current_mouse[msg] = keyui_settings.layout_edited_mouse[msg]

            -- Remove Keyboard edited flag
            addon.keys_mouse_edited = false

            -- Remove Save Button and Input Field Glow
            addon.controls_frame.glowBoxSave:Hide()
            addon.controls_frame.glowBoxInput:Hide()

            -- Refresh the keys and update the dropdown menu
            addon:refresh_layouts()
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
    end
end

-- Discards any changes made to the mouse layout and resets the Control UI state
function addon:discard_mouse_changes()
    
    if addon.keys_mouse_edited == true or addon.mouse_locked == false then
        -- Print message to the player
        print("KeyUI: Changes discarded. The mouse is reset and locked.")
    end

    -- Remove mouse locked flag
    addon.mouse_locked = true

    -- Remove mouse edited flag
    addon.keys_mouse_edited = false

    -- Remove Lock Button, Save Button and Input Field Glow
    if addon.controls_frame.glowBoxLock then
        addon.controls_frame.glowBoxLock:Hide()
    end
    if addon.controls_frame.glowBoxSave then
        addon.controls_frame.glowBoxSave:Hide()
    end
    if addon.controls_frame.glowBoxInput then
        addon.controls_frame.glowBoxInput:Hide()
    end

    -- Update the Lock button text
    if addon.controls_frame.LockText then
        addon.controls_frame.LockText:SetText("Unlock")
    end

    -- clear mouse text input field (name)
    if addon.controls_frame.Input then
        addon.controls_frame.Input:SetText("")
        addon.controls_frame.Input:ClearFocus()
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

    mouse_button:SetMovable(true)
    mouse_button:SetClampedToScreen(true)
    mouse_button:EnableMouse(true)
    mouse_button:EnableKeyboard(true)

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
    mouse_button.readable_binding:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF", 12, "OUTLINE")
    mouse_button.readable_binding:SetTextColor(1, 1, 1)
    mouse_button.readable_binding:SetHeight(25)
    --mouse_button.readable_binding:SetWidth(46)    -- will be calculated in addon:create_action_labels
    mouse_button.readable_binding:SetPoint("BOTTOM", mouse_button, "BOTTOM", 1, 6)
    mouse_button.readable_binding:SetJustifyV("BOTTOM")
    mouse_button.readable_binding:SetText("")

    -- Icon texture for the button.
    mouse_button.icon = mouse_button:CreateTexture(nil, "ARTWORK")
    mouse_button.icon:SetSize(44, 44)
    mouse_button.icon:SetPoint("CENTER", mouse_button, "CENTER", 0, 0)
    mouse_button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Highlight texture for the button.
    mouse_button.highlight = mouse_button:CreateTexture(nil, "ARTWORK")
    mouse_button.highlight:SetSize(44, 44)
    mouse_button.highlight:SetPoint("CENTER", mouse_button, "CENTER", 0, 0)
    mouse_button.highlight:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    mouse_button.highlight:Hide()

    mouse_button:SetScript("OnEnter", function(self)
        addon.current_hovered_button = mouse_button -- save the current hovered button to re-trigger tooltip
        addon:button_mouse_over(mouse_button)
        mouse_button:EnableKeyboard(true)
        mouse_button:EnableMouseWheel(true)

        local active_slot = self.active_slot

        if addon.mouse_locked == false and not addon.isMoving then

            mouse_button:SetScript("OnKeyDown", function(_, key)
                addon:handle_key_down(mouse_button, key)
                addon.keys_mouse_edited = true
            end)
        
            mouse_button:SetScript("OnMouseWheel", function(_, delta)
                addon:handle_mouse_wheel(mouse_button, delta)
                addon.keys_mouse_edited = true
            end)

        end

        -- Only show the PushedTexture if the setting is enabled
        if keyui_settings.show_pushed_texture then
            -- Look up the correct button in TextureMappings using the adjusted slot number
            local mapped_button = addon.button_texture_mapping[tostring(active_slot)]
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

    mouse_button:SetScript("OnMouseDown", function(self, button)

        local slot = self.slot

        if button == "LeftButton" then
            if addon.mouse_locked == false then
                drag_or_size(self, button)
                addon.keys_mouse_edited = true
            else
                if slot then
                    PickupAction(slot)
                end
            end
        else
            if addon.mouse_locked == false then
                addon:handle_key_down(self, button)
                addon.keys_mouse_edited = true
            end
        end
    end)

    mouse_button:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if addon.mouse_locked == false then
                release(self, button)
            end
        elseif button == "RightButton" then
            addon.current_clicked_key = self    -- save the current clicked key
            addon.current_slot = self.slot      -- save the current clicked slot
            ToggleDropDownMenu(1, nil, addon.dropdown, self, 30, 20)
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
    else
        if addon.mouse_control_frame then
            -- clear text input field (discard_mouse_changes does it already)
            addon.mouse_control_frame.Input:SetText("")
            addon.mouse_control_frame.Input:ClearFocus()
        end
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