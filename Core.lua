local name, addon = ...

-- Initialize libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
local LDB = LibStub("LibDataBroker-1.1")

-- Create the options frame and add it to the Interface Options
local optionsFrame = AceConfigDialog:AddToBlizOptions("KeyUI", "KeyUI")

-- Minimap button setup using LibDataBroker
local miniButton = LDB:NewDataObject("KeyUI", {
    type = "data source",
    text = "KeyUI",
    icon = "Interface\\AddOns\\KeyUI\\Media\\keyui_icon",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if addon.open == true then
                -- Close the addon regardless of the combat state
                addon:hide_all_frames()
            else
                -- Open the addon if stay_open_in_combat is true OR if not in combat
                if not addon.in_combat or keyui_settings.stay_open_in_combat then
                    addon:load()
                else
                    print("KeyUI: Cannot open while in combat.")
                end
            end
        elseif btn == "RightButton" then
            -- Open the Blizzard settings page
            Settings.OpenToCategory("KeyUI")
        end
    end,

    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end

        -- Add the title
        tooltip:AddLine("KeyUI")

        -- Add blank line for spacing
        tooltip:AddLine(" ")

        -- Add description lines with custom colors
        tooltip:AddLine("|cffffffffLeft-Click|r |cFF00FF00to toggle addon|r")
        tooltip:AddLine("|cffffffffRight-Click|r |cFF00FF00to open options|r")
    end,
})

local function set_esc_close_enabled(frame, enabled)
    if not frame or not frame:GetName() then return end

    if enabled then
        -- Remove the frame from UISpecialFrames if ESC closing is disabled
        for i, frameName in ipairs(UISpecialFrames) do
            if frameName == frame:GetName() then
                tremove(UISpecialFrames, i)
                --print(frame:GetName() .. " removed from UISpecialFrames")
                break
            end
        end
    else
        -- Add the frame back to UISpecialFrames to allow ESC closing
        if not tContains(UISpecialFrames, frame:GetName()) then
            tinsert(UISpecialFrames, frame:GetName())
            --print(frame:GetName() .. " added to UISpecialFrames")
        end
    end
end

-- Define the options table for AceConfig
local options = {
    type = "group",
    name = "KeyUI",
    args = {
        minimap = {
            type = "toggle",
            name = "Minimap Button",
            desc = "Show or hide the minimap button",
            order = 4,
            get = function() return not keyui_settings.minimap.hide end,
            set = function(_, value)
                keyui_settings.minimap.hide = not value
                if value then
                    LibDBIcon:Show("KeyUI")
                    print("KeyUI: Minimap button enabled")
                else
                    LibDBIcon:Hide("KeyUI")
                    print("KeyUI: Minimap button disabled")
                end
            end,
        },
        stay_open_in_combat = {
            type = "toggle",
            name = "Stay Open In Combat",
            desc = "Allow KeyUI to stay open during combat",
            order = 5,
            get = function() return keyui_settings.stay_open_in_combat end,
            set = function(_, value)
                keyui_settings.stay_open_in_combat = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Stay open in combat " .. status)
            end,
        },
        show_keyboard = {
            type = "toggle",
            name = "Show Keyboard",
            desc = "Show or hide the keyboard frame",
            order = 1,
            get = function() return keyui_settings.show_keyboard end,
            set = function(_, value)
                keyui_settings.show_keyboard = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Keyboard visibility", status)
                addon:show_frames()
            end,
        },
        show_mouse = {
            type = "toggle",
            name = "Show Mouse",
            desc = "Show or hide the mouse frame",
            order = 2,
            get = function() return keyui_settings.show_mouse end,
            set = function(_, value)
                keyui_settings.show_mouse = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Mouse visibility", status)
                addon:show_frames()
            end,
        },
        show_controller = {
            type = "toggle",
            name = "Show Controller",
            desc = "Show or hide the controller frame",
            order = 3,
            get = function() return keyui_settings.show_controller end,
            set = function(_, value)
                keyui_settings.show_controller = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Controller visibility", status)
                addon:show_frames()
            end,
        },
        -- toggle to enable or disable PushedTexture functionality
        show_pushed_texture = {
            type = "toggle",
            name = "Highlight Buttons",
            desc = "Enable or disable the highlight effect on action buttons",
            order = 8,
            get = function() return keyui_settings.show_pushed_texture end,
            set = function(_, value)
                keyui_settings.show_pushed_texture = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Action button highlighting", status)
            end,
        },
        -- Add a button to reset all settings to defaults
        reset_settings = {
            type = "execute",
            name = "Reset Addon Settings",
            desc = "Reset all KeyUI settings to their default values",
            order = 10,
            confirm = true, -- Ask for confirmation
            confirmText = "Are you sure you want to reset all KeyUI settings to default?",
            func = function()
                -- Reset all SavedVariables to their default values
                keyui_settings = {
                    show_keyboard = false,
                    show_mouse = false,
                    show_controller = false,
                    stay_open_in_combat = true,
                    show_pushed_texture = true,
                    prevent_esc_close = true,
                    keyboard_position = {},
                    mouse_position = {},
                    minimap = { hide = false },
                    show_empty_binds = false,
                    show_interface_binds = false,
                    tutorial_completed = false,
                    listen_to_modifier = true,
                    dynamic_modifier = false,
                    key_bind_settings = {
                        keyboard = {},
                        mouse = {},
                    },
                    layout_current = {
                        keyboard = {},
                        mouse = {},
                    },
                    layout_edited = {
                        keyboard = {},
                        mouse = {},
                    },
                }

                -- Reload the UI to apply the changes
                ReloadUI()
            end,
        },
        detect_modifier = {
            type = "toggle",
            name = "Detect Modifier",
            desc = "Enable or disable detection of Shift, Ctrl, and Alt for key bindings",
            order = 8,
            get = function() return keyui_settings.listen_to_modifier end,
            set = function(_, value)
                keyui_settings.listen_to_modifier = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Modifier detection " .. status)
            end,
        },
        prevent_esc_close = {
            type = "toggle",
            name = "Enable ESC",
            desc = "Enable or disable the addon window closing when pressing ESC",
            order = 6,
            get = function() return keyui_settings.prevent_esc_close end,
            set = function(_, value)
                keyui_settings.prevent_esc_close = value

                -- Immediately update the ESC closing behavior for all relevant frames
                set_esc_close_enabled(addon.keyboard_frame, not keyui_settings.prevent_esc_close)
                set_esc_close_enabled(addon.controls_frame, not keyui_settings.prevent_esc_close)
                set_esc_close_enabled(addon.mouse_image, not keyui_settings.prevent_esc_close)
                set_esc_close_enabled(addon.mouse_frame, not keyui_settings.prevent_esc_close)
                set_esc_close_enabled(addon.mouse_control_frame, not keyui_settings.prevent_esc_close)

                local status = value and "enabled" or "disabled"
                print("KeyUI: Closing with ESC " .. status)
            end,
        },
        dynamic_modifier = {
            type = "toggle",
            name = "Dynamic Modifier",
            desc = "Enable or disable dynamic display of modified keys based on current modifiers.",
            order = 9,
            get = function() return keyui_settings.dynamic_modifier end,
            set = function(_, value)
                keyui_settings.dynamic_modifier = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Dynamic modifier " .. status)
            end,
        },
    },
}

-- Handle addon load event and initialize
EventUtil.ContinueOnAddOnLoaded(..., function()
    -- Load additional saved settings and update the UI
    addon:InitializeSettings()

    -- Register the minimap button using LibDBIcon
    LibDBIcon:Register("KeyUI", miniButton, keyui_settings.minimap)

    -- Register the options table
    AceConfig:RegisterOptionsTable("KeyUI", options)
end)

-- Main function to load the addon.
function addon:load()

    if keyui_settings.show_keyboard == false and keyui_settings.show_mouse == false and keyui_settings.show_controller == false then
        -- Create the selection frame if not already created.
        if not addon.selection_frame then
            addon.selection_frame = addon:create_selection_frame()
        else
            addon.selection_frame:Show()
        end
    else
        -- Prevent loading if in combat and 'stay_open_in_combat' is false.
        if addon.in_combat and not keyui_settings.stay_open_in_combat then
            return
        end

        addon.open = true -- Mark the addon as open
        addon:show_frames()

        if keyui_settings.show_keyboard == true then

            -- Generate keyboard layout directly if the dropdown has not been created yet
            local active_keyboard_board = next(keyui_settings.layout_current_keyboard)

            if not addon.keyboard_selector then
                addon:generate_keyboard_layout(active_keyboard_board)
            end
        end

        if keyui_settings.show_mouse == true then

            -- Generate mouse layout directly if the dropdown has not been created yet
            local active_mouse_board = next(keyui_settings.layout_current_mouse)

            if not addon.mouse_selector then
                addon:generate_mouse_layout(active_mouse_board)
            end
        end

        if keyui_settings.show_controller == true then

            -- Generate controller layout directly if the dropdown has not been created yet
            local active_controller_board = next(keyui_settings.layout_current_controller)

            if not addon.controller_selector then
                addon:generate_controller_layout(active_controller_board)
            end
        end

        -- Ensure the dropdown menu is created.
        addon:create_context_menu()

        -- Initialize the tooltip if not already created.
        addon.keyui_tooltip_frame = addon.keyui_tooltip_frame or addon:create_tooltip()

        -- Load spells and refresh the key bindings.
        addon:load_spellbook()
        addon:refresh_layouts()

        -- Show tutorial if not completed
        if keyui_settings.tutorial_completed ~= true and addon.tutorial_frame1_created ~= true then
            addon:create_tutorial_frame1()
        end
    end
end

function addon:load_spellbook()
    addon.spells = {}
    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        local name = skillLineInfo.name
        local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems

        -- Ensure the skill line has a name before proceeding.
        if name then
            addon.spells[name] = {}

            for j = offset + 1, offset + numSlots do
                local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
                local spellName = spellBookItemInfo.name
                local spellID = spellBookItemInfo.spellID
                local isPassive = spellBookItemInfo.isPassive

                if spellName and not isPassive then
                    table.insert(addon.spells[name], { name = spellName, id = spellID })
                end
            end
        end
    end
end

-- Triggers the functions to update the keyboard and mouse layouts on the current configuration.
function addon:refresh_layouts()
    --print("refresh_layouts function called")  -- print statement for debbuging

    -- stop if the addon is not open
    if addon.open == false then
        return
    end

    -- stop if keyboard and mouse are not visible
    if addon.is_keyboard_frame_visible == false and addon.is_mouse_image_visible == false then
        return
    end

    -- if the keyboard is locked and not edited we refresh the keyboard board holding the keys
    if addon.keyboard_locked ~= false and addon.keys_keyboard_edited ~= true then
        addon:generate_keyboard_key_frames(keyui_settings.key_bind_settings_keyboard.currentboard)
    end

    -- if the mouse is locked and not edited we refresh the mouse board holding the keys
    if addon.mouse_locked ~= false and addon.keys_mouse_edited ~= true then
        addon:generate_mouse_key_frames(keyui_settings.key_bind_settings_mouse.currentboard)
    end

    -- if the controller is locked and not edited we refresh the controller board holding the keys
    if addon.controller_locked ~= false and addon.keys_controller_edited ~= true then
        addon:generate_controller_key_frames(keyui_settings.key_bind_settings_controller.currentboard)
    end

    -- update the textures/texts of the keys bindings.
    addon:refresh_keys()
end

-- Update the visibility of keyboard and mouse based on settings, only if addon is open
function addon:show_frames()
    if addon.open == false then
        return
    end

    local keyboard_frame = addon:get_keyboard_frame()
    local mouse_image = addon:get_mouse_image()
    local mouse_frame = addon:get_mouse_frame()
    local controller_frame = addon:get_controller_frame()
    local controller_image = addon:get_controller_image()

    if keyui_settings.show_keyboard == true then
        addon.is_keyboard_frame_visible = true
        keyboard_frame:Show()
    end

    if keyui_settings.show_mouse == true then
        addon.is_mouse_image_visible = true
        mouse_image:Show()
        mouse_frame:Show()
    end

    if keyui_settings.show_controller == true then
        addon.is_controller_visible = true
        controller_frame:Show()
        if controller_image then
            controller_image:Show()
        end
    end
end

-- Hides all UI elements when the addon is closed
function addon:hide_all_frames()
    local keyboard_frame = addon:get_keyboard_frame()
    local mouse_image = addon:get_mouse_image()
    local mouse_frame = addon:get_mouse_frame()
    local controller_frame = addon:get_controller_frame()

    keyboard_frame:Hide()
    mouse_frame:Hide()
    mouse_image:Hide()
    controller_frame:Hide()

    if addon.controls_frame then
        addon.controls_frame:Hide()
    end

    if addon.selection_frame then
        addon.selection_frame:Hide()
    end

    if addon.name_input_dialog then
        addon.name_input_dialog:Hide()
    end

    if addon.edit_layout_dialog then
        addon.edit_layout_dialog:Hide()
    end

    addon.open = false
    addon.is_keyboard_frame_visible = false
    addon.is_mouse_image_visible = false
    addon.is_controller_visible = false
end

local function on_frame_hide(self)
    if (addon.is_keyboard_frame_visible == false or keyui_settings.show_keyboard == false) and (addon.is_mouse_image_visible == false or keyui_settings.show_mouse == false) and (addon.is_controller_frame_visible == false or keyui_settings.show_controller == false) then
        addon.open = false

        -- Discard Keyboard Editor Changes when closing
        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
            addon:discard_keyboard_changes()
        end

        -- Discard Mouse Editor Changes when closing
        if addon.mouse_locked == false or addon.keys_mouse_edited == true then
            -- Discard any Editor Changes
            addon:discard_mouse_changes()
        end

        -- Discard Controller Editor Changes when closing
        if addon.controller_locked == false or addon.keys_controller_edited == true then
            addon:discard_controller_changes()
        end
    end
end

-- Function to get or create the keyboard frame
function addon:get_keyboard_frame()
    -- Check if the keyboard_frame already exists
    if not addon.keyboard_frame then
        -- Create the keyboard frame and assign it to the addon table
        addon.keyboard_frame = addon:create_keyboard_frame()

        addon.keyboard_frame:SetScript("OnHide", function()
            addon:save_keyboard_position()
            addon.is_keyboard_frame_visible = false
            on_frame_hide()
        end)

        addon.keyboard_frame:SetScript("OnShow", function()
            addon.is_keyboard_frame_visible = true
        end)
    end
    return addon.keyboard_frame
end

-- Function to get or create the mouse image frame
function addon:get_mouse_image()
    -- Check if the mouse_image already exists
    if not addon.mouse_image then
        -- Create the mouse image and assign it to the addon table
        addon.mouse_image = addon:create_mouse_image()

        addon.mouse_image:SetScript("OnHide", function()
            addon:save_mouse_position()
            addon.is_mouse_image_visible = false
            on_frame_hide()
        end)

        addon.mouse_image:SetScript("OnShow", function()
            addon.is_mouse_image_visible = true
        end)
    end
    return addon.mouse_image
end

-- Function to get or create the mouse frame
function addon:get_mouse_frame()
    if not addon.mouse_frame then
        addon.mouse_frame = addon:create_mouse_frame()
    end
    return addon.mouse_frame
end

-- Function to get or create the controller frame
function addon:get_controller_frame()
    -- Check if the controller_frame already exists
    if not addon.controller_frame then
        -- Create the controller frame and assign it to the addon table
        addon.controller_frame = addon:create_controller_frame()

        addon.controller_frame:SetScript("OnHide", function()
            addon:save_controller_position()
            addon.is_controller_frame_visible = false
            on_frame_hide()
        end)

        addon.controller_frame:SetScript("OnShow", function()
            addon.is_controller_frame_visible = true
        end)
    end
    return addon.controller_frame
end

-- Function to get or create the controller image
function addon:get_controller_image()
    if not addon.controller_image then
        addon.controller_image = addon:create_controller_image()
    end
    return addon.controller_image
end

-- Function to get or create the keyboard control
function addon:get_controls_frame()
    -- Check if the controls frame already exists
    if not addon.controls_frame then
        -- If it doesn't exist, create the controls frame and assign it to the addon
        addon.controls_frame = addon:create_controls()
        -- Immediately show the newly created controls frame
        addon.controls_frame:Show()
    end
    -- Return the controls frame (either existing or newly created)
    return addon.controls_frame
end

function addon:create_tooltip()
    -- Create the tooltip frame with the GlowBoxTemplate.
    local keyui_tooltip_frame = CreateFrame("Frame", nil, UIParent, "GlowBoxTemplate")
    addon.keyui_tooltip_frame = keyui_tooltip_frame -- Save the tooltip to the addon table for reuse.

    keyui_tooltip_frame:SetFrameStrata("TOOLTIP")
    keyui_tooltip_frame:SetHeight(50)

    -- Add a text to the tooltip.
    keyui_tooltip_frame.key = keyui_tooltip_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyui_tooltip_frame.key:SetPoint("CENTER", keyui_tooltip_frame, "CENTER", 0, 10)
    keyui_tooltip_frame.key:SetTextColor(1, 1, 1)
    keyui_tooltip_frame.key:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)

    keyui_tooltip_frame.binding = keyui_tooltip_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyui_tooltip_frame.binding:SetPoint("CENTER", keyui_tooltip_frame, "CENTER", 0, -10)
    keyui_tooltip_frame.binding:SetTextColor(1, 1, 1)
    keyui_tooltip_frame.binding:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16)

    -- Hide the GameTooltip when this custom tooltip hides.
    keyui_tooltip_frame:SetScript("OnHide", function() GameTooltip:Hide() end)

    return keyui_tooltip_frame
end

-- This function is called when the Mouse cursor hovers over a key binding button. It displays a tooltip description of the spell or ability.
function addon:button_mouse_over(button)
    local raw_key = button.raw_key or ""
    local short_key = button.short_key:GetText()
    local readable_binding = button.readable_binding:GetText() or ""
    local short_modifier_string = (addon.current_modifier_string or "")

    -- Position the tooltip next to the hovered button
    addon.keyui_tooltip_frame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 6, 5)

    -- Adjust the tooltip size and text positions for gamepad buttons
    if addon.gamepad_buttons[raw_key] then
        addon.keyui_tooltip_frame:SetHeight(74) -- Increase height for gamepad buttons
        addon.keyui_tooltip_frame.key:SetScale(0.8)
        addon.keyui_tooltip_frame.key:SetPoint("CENTER", addon.keyui_tooltip_frame, "CENTER", 0, 14) -- Adjust key text position
        addon.keyui_tooltip_frame.binding:SetPoint("CENTER", addon.keyui_tooltip_frame, "CENTER", 0, -22) -- Adjust binding text position
    else
        addon.keyui_tooltip_frame:SetHeight(50) -- Default height for non-gamepad buttons
        addon.keyui_tooltip_frame.key:SetScale(1)
        addon.keyui_tooltip_frame.key:SetPoint("CENTER", addon.keyui_tooltip_frame, "CENTER", 0, 10) -- Default key text position
        addon.keyui_tooltip_frame.binding:SetPoint("CENTER", addon.keyui_tooltip_frame, "CENTER", 0, -10) -- Default binding text position
    end

    -- Display the key text with or without modifiers
    if addon.no_modifier_keys[raw_key] then
        -- For keys without modifiers, display only the key
        addon.keyui_tooltip_frame.key:SetText(short_key)
    else
        -- For keys with modifiers, display the modifier string followed by the key
        addon.keyui_tooltip_frame.key:SetText(short_modifier_string .. short_key)
    end

    -- Display the readable binding text
    addon.keyui_tooltip_frame.binding:SetText(readable_binding or "")

    -- Adjust tooltip width based on the longer text dimension + 20
    local binding_width = addon.keyui_tooltip_frame.binding:GetText() and addon.keyui_tooltip_frame.binding:GetWidth() or 0
    local key_width = addon.keyui_tooltip_frame.key:GetText() and addon.keyui_tooltip_frame.key:GetWidth() or 0
    addon.keyui_tooltip_frame:SetWidth(math.max(binding_width, key_width) + 20)

    -- Show the tooltip
    addon.keyui_tooltip_frame:Show()

    -- Display the GameTooltip if the hovered button has an active slot
    if addon.current_hovered_button.active_slot then
        GameTooltip:SetOwner(addon.current_hovered_button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetAction(addon.current_hovered_button.active_slot) -- Use SetAction for ActionButtons
        GameTooltip:Show()
    else
        -- Hide the GameTooltip if no active slot is found
        GameTooltip:Hide()
    end
end

-- Determines the texture and text displayed on the button based on the key binding.
function addon:set_key(button)
    -- Reset the button's slot and active_slot at the beginning
    button.slot = nil
    button.active_slot = nil

    local binding = GetBindingAction(addon.current_modifier_string .. (button.raw_key or "")) or ""

    button.icon:Hide()

    -- Determine action button slot based on Class and Stance and Action Bar Page (only for Action Button 1-12)
    local function getActionButtonSlot(slot)
        -- Check if the class is Druid or Rogue in Stance and if we are on the first action bar page
        if (addon.class_name == "ROGUE" or addon.class_name == "DRUID") and addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
            if addon.bonusbar_offset == 1 then
                return slot + 72  -- Maps to 73-84
            elseif addon.bonusbar_offset == 2 then
                return slot + 84  -- Maps to 85-96
            elseif addon.bonusbar_offset == 3 then
                return slot + 96  -- Maps to 97-108
            elseif addon.bonusbar_offset == 4 then
                return slot + 108 -- Maps to 109-120
            end
        end

        -- Check if Dragonriding
        if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then
            return slot + 120 -- Maps to 121-132
        end

        -- Handle other action bar pages for all classes
        if addon.current_actionbar_page == 2 then
            return slot + 12 -- Maps to 13-24
        elseif addon.current_actionbar_page == 3 then
            return slot + 24 -- Maps to 25-36
        elseif addon.current_actionbar_page == 4 then
            return slot + 36 -- Maps to 37-48
        elseif addon.current_actionbar_page == 5 then
            return slot + 48 -- Maps to 49-60
        elseif addon.current_actionbar_page == 6 then
            return slot + 60 -- Maps to 61-72
        end

        return slot -- Default 1-12
    end

    -- Standard ActionButton logic
    for i = 1, GetNumBindings() do
        local a = GetBinding(i)
        if binding:find(a) then
            -- Match for action button slots
            local slot = binding:match("ACTIONBUTTON(%d+)")
            local bar, bar2 = binding:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")

            -- Handle MULTIACTIONBAR case
            if bar and bar2 then
                if bar == "0" then slot = tonumber(bar2) end
                if bar == "1" then slot = 60 + tonumber(bar2) end
                if bar == "2" then slot = 48 + tonumber(bar2) end
                if bar == "3" then slot = 24 + tonumber(bar2) end
                if bar == "4" then slot = 36 + tonumber(bar2) end
                if bar == "5" then slot = 144 + tonumber(bar2) end
                if bar == "6" then slot = 156 + tonumber(bar2) end
                if bar == "7" then slot = 168 + tonumber(bar2) end
            end

            -- Apply class/bonus bar offset logic only for ACTIONBUTTON slots
            if slot then
                button.slot = slot -- Always stores the slot, regardless of whether an action is present

                -- Check if it's not a MULTIACTIONBAR case before applying bonusBarOffset
                if not bar then
                    slot = getActionButtonSlot(slot)
                    button.slot = slot
                end

                if HasAction(slot) then
                    button.active_slot = slot -- Stores the slot only if an action is present
                    button.icon:SetTexture(GetActionTexture(slot))
                    button.icon:Show()
                end
            end
        end
    end

    -- Check if the binding is a Spell
    local spell_name = binding:match("^Spell (.+)$")
    if spell_name then
        -- Get the icon for the spell
        local spell_icon = C_Spell.GetSpellTexture(spell_name)
        if spell_icon then
            button.icon:SetTexture(spell_icon)
            button.icon:Show()
        end
    end

    -- Logic for BT4Button Bindings
    local bt4_slot = binding:match("CLICK BT4Button(%d+):Keybind")
    if bt4_slot then
        button.slot = tonumber(bt4_slot)     -- Set the button slot based on BT4Button
        if HasAction(button.slot) then
            button.active_slot = button.slot -- Active if there's an action
            button.icon:SetTexture(GetActionTexture(button.slot))
            button.icon:Show()
        end
    end

    -- Logic to handle ElvUI action buttons
    local elvui_binding = binding:find("^ELVUIBAR%d+BUTTON%d+$")
    if elvui_binding then
        local barIndex, buttonIndex = binding:match("ELVUIBAR(%d+)BUTTON(%d+)")
        local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
        if elvUIButton then
            local actionID = elvUIButton._state_action
            if elvUIButton._state_type == "action" and actionID then
                button.icon:SetTexture(GetActionTexture(actionID))
                button.icon:Show()
                button.slot = actionID
            end
        end
    end

    -- Logic for Dominos ActionButton Bindings
    local dominos_slot = binding:match("CLICK DominosActionButton(%d+):HOTKEY")
    if dominos_slot then
        button.slot = tonumber(dominos_slot) -- Set the button slot based on DominosActionButton
        if HasAction(button.slot) then
            button.active_slot = button.slot -- Active if there's an action
            button.icon:SetTexture(GetActionTexture(button.slot))
            button.icon:Show()
        end
    end

    -- code for setting icons for other actions (movement, pets, etc.)
    local action_textures = {
        --EXTRAACTIONBUTTON1 = 4200126,
        MOVEFORWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_up",
        MOVEBACKWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_down",
        STRAFELEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_left",
        STRAFERIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_right",
        TURNLEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_left",
        TURNRIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_right",
    }

    if action_textures[binding] then
        button.icon:SetTexture(action_textures[binding])
        button.icon:SetSize(30, 30)
        button.icon:Show()
    end

    -- Handle Shapeshift Forms
    local shapeshift_slot = binding:match("SHAPESHIFTBUTTON(%d+)")
    if shapeshift_slot then
        local icon, active, castable, spellID = GetShapeshiftFormInfo(tonumber(shapeshift_slot))
        if icon then
            button.icon:SetTexture(icon)
            button.icon:Show()
            button.spellid = spellID -- Set the spell ID for the shapeshift form
        else
            button.icon:Hide()       -- Hide icon if there's no valid shapeshift form
        end
    end

    -- Pet Action Bar logic
    if PetHasActionBar() then
        if binding:match("^BONUSACTIONBUTTON%d+$") then
            for i = 1, 10 do
                local petspellName = "BONUSACTIONBUTTON" .. i
                if binding:match(petspellName) then
                    -- GetPetActionInfo returns multiple values, including texture/token
                    local petName, petTexture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID =
                        GetPetActionInfo(i)

                    -- If it's a token, use the token to get the texture
                    if isToken then
                        petTexture = _G[petTexture] or
                            "Interface\\Icons\\" ..
                            petTexture -- Use WoW's icon folder as fallback
                    end

                    if petTexture then
                        button.icon:SetTexture(petTexture)
                        button.icon:Show()

                        -- Check if it's a Pet Spell (spellID is present)
                        if spellID then
                            button.slot = nil           -- No slot for Pet Spells
                            button.spellid = spellID    -- Set spellID for Pet Spells
                            button.petActionIndex = nil -- Not a pet mode
                        else
                            -- For Pet Modes (e.g., Wait, Move To)
                            button.slot = nil
                            button.spellid = nil
                            button.petActionIndex = i -- Set petActionIndex for pet modes
                        end
                    else
                        -- Handle empty buttons by clearing the slot, spellID, and petActionIndex
                        button.icon:Hide()
                        button.slot = nil
                        button.spellid = nil
                        button.petActionIndex = nil
                    end
                end
            end
        end
    else
        if binding:match("^BONUSACTIONBUTTON%d+$") then
            button.icon:Hide()
            button.slot = nil
            button.spellid = nil
            button.petActionIndex = nil -- Clear petActionIndex when no pet action bar
        end
    end

    -- store the interface command (Blizzard Interface Commands)
    button.binding = binding

    -- Set visible key name based on the current modifier string
    local original_text = button.raw_key or "" -- Ensure original_text is never nil

    -- Check if the key is a PlayStation button and the controller system is DS4 or DS5
    if addon.playstation_buttons[original_text] and (addon.controller_system == "ds4" or addon.controller_system == "ds5") then
        -- Retrieve the PlayStation icon
        local texture = addon.playstation_buttons[original_text]
        -- Format the texture into an icon string
        local playstation_icon = string.format("|A:%s:32:32|a", texture)

        -- Set the PlayStation icon as the short key text
        if button.short_key then
            button.short_key:SetText(playstation_icon)
            return -- Exit here since we don't need further processing for PlayStation buttons
        end

    -- Check if the key is an Xbox button and the controller system is Xbox
    elseif addon.xbox_buttons[original_text] and addon.controller_system == "xbox" then
        -- Retrieve the Xbox icon
        local texture = addon.xbox_buttons[original_text]
        -- Format the texture into an icon string
        local xbox_icon = string.format("|A:%s:32:32|a", texture)

        -- Set the Xbox icon as the short key text
        if button.short_key then
            button.short_key:SetText(xbox_icon)
            return -- Exit here since we don't need further processing for Xbox buttons
        end

    -- Check if the key is a Deck button and the controller system is Deck
    elseif addon.deck_buttons[original_text] and addon.controller_system == "deck" then
        -- Retrieve the Deck icon
        local texture = addon.deck_buttons[original_text]
        -- Format the texture into an icon string
        local deck_icon = string.format("|A:%s:32:32|a", texture)

        -- Set the Deck icon as the short key text
        if button.short_key then
            button.short_key:SetText(deck_icon)
            return -- Exit here since we don't need further processing for Deck buttons
        end
    end

    -- For non-gamepad buttons, follow the usual logic for readable text
    local readable_text = addon.short_keys[original_text] or _G["KEY_" .. original_text] or original_text

    -- Set the short key format if button.short_key exists
    if button.short_key then
        -- Adjust the width of the short_key based on button width
        button.short_key:SetWidth(button:GetWidth() - 6)

        -- Check if the key should be displayed without modifiers
        if addon.no_modifier_keys[original_text] then
            -- If the key is in the no_modifier_keys list, display it without modifiers
            button.short_key:SetText(readable_text)
        else
            -- Process the key with modifiers based on the settings
            if not keyui_settings.dynamic_modifier then -- Check if dynamic modifier is disabled
                button.short_key:SetText(readable_text) -- Set only the readable text, without a modifier
            else
                -- Shorten existing modifiers in original_text
                local shorten_modifier_string = (addon.current_modifier_string or "")
                    :gsub("ALT%-", "a-")   -- Shorten ALT
                    :gsub("CTRL%-", "c-")  -- Shorten CTRL
                    :gsub("SHIFT%-", "s-") -- Shorten SHIFT

                -- Append the shortened modifier string to the readable text
                if shorten_modifier_string ~= "" then
                    button.short_key:SetText(shorten_modifier_string .. readable_text)
                else
                    button.short_key:SetText(readable_text) -- Fallback to just readable_text if no modifiers
                end
            end
        end
    end

    -- Calculate the maximum allowed characters based on button width
    local max_allowed_chars = math.floor(button:GetWidth() / 9)
    local combined_text = button.short_key:GetText() or "" -- Combined text with modifiers if present / Use empty string if GetText() returns nil

    -- Use Condensed font if the combined text exceeds max_allowed_chars
    if string.len(combined_text) > max_allowed_chars then
        -- Use the Condensed font for longer text
        button.short_key:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF", 16, "OUTLINE")
    else
        -- Use the Regular font for shorter text
        button.short_key:SetFont("Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF", 16, "OUTLINE")
    end
end

-- button.binding           -- Stores the binding name (e.g., MOVEFORWARD, ACTIONBUTTON1, OPENCHAT, ...)
-- Can be translated to a readable format via _G["BINDING_NAME_" ...]

-- button.readable_binding  -- Displays the readable binding text in the center of the button when toggled on

-- button.raw_key           -- Stores the raw key name (e.g., A, B, C, ESCAPE, PRINTSCREEN, ...)
-- Can be made readable via _G["KEY_" ...]

-- button.short_key         -- Displays the abbreviated key name with short modifiers in the top-right of the button

-- button.slot              -- Stores the action slot ID associated with the binding, regardless of action presence

-- button.active_slot       -- Holds the action slot ID only if the slot contains an active action, otherwise nil

-- button.icon              -- Stores the icon texture ID for the action slot

--------------------------------------------------------------------------------------------------------------------


-- Updates the textures/texts of the keys bindings.
function addon:refresh_keys()
    --print("refresh_keys function called")  -- print statement for debbuging

    -- if the keyboard is visible we create the keys
    if addon.is_keyboard_frame_visible ~= false then -- true
        -- Set the keys
        for i = 1, #addon.keys_keyboard do
            addon:set_key(addon.keys_keyboard[i])
        end
    end

    -- if the mouse is visible we create the keys
    if addon.is_mouse_image_visible ~= false then -- true
        for j = 1, #addon.keys_mouse do
            addon:set_key(addon.keys_mouse[j])
        end
    end

    -- if the controller is visible we create the keys
    if addon.is_controller_image_visible ~= false then -- true
        for k = 1, #addon.keys_controller do
            addon:set_key(addon.keys_controller[k])
        end
    end

    -- create/update action labels
    addon:create_action_labels()

    -- Highlight empty binds if the setting is enabled
    if keyui_settings.show_empty_binds then
        addon:highlight_empty_binds()
    end
end

-- Highlights empty key binds by changing the background color of unused keys.
function addon:highlight_empty_binds()
    if keyui_settings.show_empty_binds then
        -- Loop through all keyboard buttons if they exist
        if self.keyboard_buttons then
            for _, keyboard_button in pairs(self.keyboard_buttons) do
                if keyboard_button.raw_key then
                    local raw_key = keyboard_button.raw_key -- Get the label text

                    -- Get Blizzard Interface Command for the button
                    local binding = keyboard_button.binding and keyboard_button.binding or ""

                    local key_name = _G[raw_key] or raw_key -- Get the global name if it exists

                    -- reset background before highlighting
                    if not addon.no_highlight[key_name] then
                        keyboard_button.highlight:Hide()
                    end

                    -- Check if the bind is empty and the key is not on the excluded list
                    if binding == "" and not addon.no_highlight[key_name] then
                        keyboard_button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\red_bg") -- Red color for empty keys
                        keyboard_button.highlight:SetSize(keyboard_button:GetWidth() - 10,
                            keyboard_button:GetHeight() - 10)                                                       -- Dynamically set the size based on keyboard_button's width and height
                        keyboard_button.highlight:Show()
                    end
                end
            end
        end

        -- Loop through all mouse buttons if they exist
        if self.mouse_buttons then
            for _, mouse_button in pairs(self.mouse_buttons) do
                if mouse_button.raw_key then
                    local raw_key = mouse_button.raw_key -- Get the label text

                    -- Get the Blizzard Interface Command for the button
                    local binding = mouse_button.binding and mouse_button.binding or ""

                    local key_name = _G[raw_key] or raw_key -- Get the global name if it exists

                    -- reset background before highlighting
                    if not addon.no_highlight[key_name] then
                        mouse_button.highlight:Hide()
                    end

                    -- Check if the bind is empty and the key is not on the excluded list
                    if binding == "" and not addon.no_highlight[key_name] then
                        mouse_button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\red_bg") -- Red color for empty keys
                        mouse_button.highlight:Show()
                    end
                end
            end
        end

        -- Loop through all controller buttons if they exist
        if self.controller_buttons then
            for _, controller_button in pairs(self.controller_buttons) do
                if controller_button.raw_key then
                    local raw_key = controller_button.raw_key -- Get the label text

                    -- Get the Blizzard Interface Command for the button
                    local binding = controller_button.binding and controller_button.binding or ""

                    local key_name = _G[raw_key] or raw_key -- Get the global name if it exists

                    -- reset background before highlighting
                    if not addon.no_highlight[key_name] then
                        controller_button.highlight:Hide()
                    end

                    -- Check if the bind is empty and the key is not on the excluded list
                    if binding == "" and not addon.no_highlight[key_name] then
                        controller_button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\red_bg") -- Red color for empty keys
                        controller_button.highlight:Show()
                    end
                end
            end
        end

    else
        -- Reset color for all buttons when not showing empty binds
        if self.keyboard_buttons then
            for _, keyboard_button in pairs(self.keyboard_buttons) do
                keyboard_button.highlight:Hide()
            end
        end

        if self.mouse_buttons then
            for _, mouse_button in pairs(self.mouse_buttons) do
                mouse_button.highlight:Hide()
            end
        end

        if self.controller_buttons then
            for _, controller_button in pairs(self.controller_buttons) do
                controller_button.highlight:Hide()
            end
        end
    end
end

-- Sets and displays the interface action label on all buttons, using the binding name or command name and toggles the visibility based on settings.
function addon:create_action_labels()
    -- Loop through all keyboard buttons if they exist
    if self.keyboard_buttons then
        for _, keyboard_button in pairs(self.keyboard_buttons) do
            if keyboard_button.readable_binding then
                local command = keyboard_button.binding

                -- Adjust the width of the readable_binding based on button width
                keyboard_button.readable_binding:SetWidth(keyboard_button:GetWidth() - 4)

                -- Check if the command corresponds to a Dominos action button
                if command and command:match("CLICK DominosActionButton(%d+):HOTKEY") then
                    -- Handle the binding for Dominos action buttons
                    local dominos_slot = command:match("DominosActionButton(%d+)")
                    if dominos_slot then
                        -- Set a custom label for Dominos buttons
                        local binding_name = "Dominos Button " .. dominos_slot -- Customize this as needed
                        keyboard_button.readable_binding:SetText(binding_name)
                    else
                        keyboard_button.readable_binding:SetText("")
                    end
                else
                    -- Standard handling for other buttons
                    if command then
                        local binding_name = _G["BINDING_NAME_" .. command] or command
                        keyboard_button.readable_binding:SetText(binding_name)
                    else
                        keyboard_button.readable_binding:SetText("")
                    end
                end

                -- Toggle visibility of the interface action label based on settings
                if keyui_settings.show_interface_binds then
                    keyboard_button.readable_binding:Show()
                else
                    keyboard_button.readable_binding:Hide()
                end
            end
        end
    end

    -- Loop through all mouse buttons if they exist
    if self.mouse_buttons then
        for _, mouse_button in pairs(self.mouse_buttons) do
            if mouse_button.readable_binding then
                local command = mouse_button.binding

                -- Adjust the width of the readable_binding based on button width
                mouse_button.readable_binding:SetWidth(mouse_button:GetWidth() - 4)

                -- Check if the command corresponds to a Dominos action button
                if command and command:match("CLICK DominosActionButton(%d+):HOTKEY") then
                    -- Handle the binding for Dominos action buttons
                    local dominos_slot = command:match("DominosActionButton(%d+)")
                    if dominos_slot then
                        -- Set a custom label for Dominos buttons
                        local binding_name = "Dominos Button " .. dominos_slot -- Customize this as needed
                        mouse_button.readable_binding:SetText(binding_name)
                    else
                        mouse_button.readable_binding:SetText("")
                    end
                else
                    -- Standard handling for other buttons
                    if command then
                        local binding_name = _G["BINDING_NAME_" .. command] or command
                        mouse_button.readable_binding:SetText(binding_name)
                    else
                        mouse_button.readable_binding:SetText("")
                    end
                end

                -- Toggle visibility of the interface action label based on settings
                if keyui_settings.show_interface_binds then
                    mouse_button.readable_binding:Show()
                else
                    mouse_button.readable_binding:Hide()
                end
            end
        end
    end

    -- Loop through all controller buttons if they exist
    if self.controller_buttons then
        for _, controller_button in pairs(self.controller_buttons) do
            if controller_button.readable_binding then
                local command = controller_button.binding

                -- Adjust the width of the readable_binding based on button width
                controller_button.readable_binding:SetWidth(controller_button:GetWidth() - 4)

                -- Check if the command corresponds to a Dominos action button
                if command and command:match("CLICK DominosActionButton(%d+):HOTKEY") then
                    -- Handle the binding for Dominos action buttons
                    local dominos_slot = command:match("DominosActionButton(%d+)")
                    if dominos_slot then
                        -- Set a custom label for Dominos buttons
                        local binding_name = "Dominos Button " .. dominos_slot -- Customize this as needed
                        controller_button.readable_binding:SetText(binding_name)
                    else
                        controller_button.readable_binding:SetText("")
                    end
                else
                    -- Standard handling for other buttons
                    if command then
                        local binding_name = _G["BINDING_NAME_" .. command] or command
                        controller_button.readable_binding:SetText(binding_name)
                    else
                        controller_button.readable_binding:SetText("")
                    end
                end

                -- Toggle visibility of the interface action label based on settings
                if keyui_settings.show_interface_binds then
                    controller_button.readable_binding:Show()
                else
                    controller_button.readable_binding:Hide()
                end
            end
        end
    end
end

function addon:update_modifier_string()
    local modifiers = {}
    if addon.modif.ALT then table.insert(modifiers, "ALT-") end
    if addon.modif.CTRL then table.insert(modifiers, "CTRL-") end
    if addon.modif.SHIFT then table.insert(modifiers, "SHIFT-") end
    addon.current_modifier_string = table.concat(modifiers)
end

-- Define modifier keys used in HandleKeyPress and HandleKeyRelease
local modifier_keys = {
    LALT = { mod = "ALT", control_key = "AltCB" },
    RALT = { mod = "ALT", control_key = "AltCB" },
    LCTRL = { mod = "CTRL", control_key = "CtrlCB" },
    RCTRL = { mod = "CTRL", control_key = "CtrlCB" },
    LSHIFT = { mod = "SHIFT", control_key = "ShiftCB" },
    RSHIFT = { mod = "SHIFT", control_key = "ShiftCB" },
}

-- Function to handle key press events
local function handle_key_press(key)
    -- Check if the key is a modifier
    local modifier_data = modifier_keys[key]
    if modifier_data then
        -- Set the corresponding modifier flag
        addon.modif[modifier_data.mod] = true

        -- Update control frame checkbox
        if addon.controls_frame and addon.controls_frame[modifier_data.control_key] then
            addon.controls_frame[modifier_data.control_key]:SetChecked(true)
        end
    end

    -- Update background color for the pressed key (keyboard and mouse)
    local function update_key_background(buttons, is_mouse)
        for _, button in pairs(buttons) do
            if button.raw_key == key then
                button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\yellow_bg")

                -- Apply different size adjustments for keyboard and mouse buttons
                if is_mouse then
                    -- Mouse button size adjustment
                    button.highlight:SetSize(button:GetWidth() - 6, button:GetHeight() - 6)  -- Smaller margin for mouse keys
                    button.highlight:SetPoint("CENTER", button, "CENTER")   -- Set highlight to the center of the button
                else
                    -- Keyboard button size adjustment
                    button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)  -- Larger margin for keyboard keys
                end

                -- Show the highlight for the pressed key
                button.highlight:Show()
            end
        end
    end

    if addon.keyboard_buttons then
        update_key_background(addon.keyboard_buttons, false)  -- false indicates keyboard
    end
    if addon.keys_mouse then
        update_key_background(addon.keys_mouse, true)  -- true indicates mouse
    end

    -- Refresh modifiers and keys
    addon:update_modifier_string()
    addon:refresh_keys()
end

-- Function to handle key release events
local function handle_key_release(key)
    -- Check if the key is a modifier
    local modifier_data = modifier_keys[key]
    if modifier_data then
        -- Clear the corresponding modifier flag
        addon.modif[modifier_data.mod] = false

        -- Uncheck the control frame checkbox
        if addon.controls_frame and addon.controls_frame[modifier_data.control_key] then
            addon.controls_frame[modifier_data.control_key]:SetChecked(false)
        end

        -- Reset background color for the released key on both keyboard and mouse
        if addon.keyboard_buttons then
            for _, keyboard_button in pairs(addon.keyboard_buttons) do
                if keyboard_button.raw_key == key then
                    keyboard_button.highlight:Hide()
                end
            end
        end

        if addon.keys_mouse then
            for _, mouse_button in pairs(addon.keys_mouse) do
                if mouse_button.raw_key == key then
                    mouse_button.highlight:Hide()
                end
            end
        end
    end

    -- Refresh modifiers and keys
    addon:update_modifier_string()
    addon:refresh_keys()
end

-- Shared KeyDown function for all buttons (keyboard + mouse)
function addon:handle_key_down(frame, key)
    -- Check if any modifier is held down
    local modifier = ""

    -- Check for ALT modifier
    if IsAltKeyDown() and not addon.no_modifier_keys[key] then
        modifier = modifier .. "ALT-"
    end

    -- Check for CTRL modifier
    if IsControlKeyDown() and not addon.no_modifier_keys[key] then
        modifier = modifier .. "CTRL-"
    end

    -- Check for SHIFT modifier
    if IsShiftKeyDown() and not addon.no_modifier_keys[key] then
        modifier = modifier .. "SHIFT-"
    end

    -- Set the label to the modifier and the pressed key
    if key == "MiddleButton" then
        frame.raw_key = modifier .. "BUTTON3" -- Handle middle mouse button
    else
        frame.raw_key = modifier .. key       -- Set label to the pressed key with modifier
    end

    -- Hide pushed texture
    local adjustedSlot = frame.active_slot
    local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
    if mappedButton then
        local pushedTexture = mappedButton:GetPushedTexture()
        if pushedTexture then
            pushedTexture:Hide() -- Hide the pushed texture
        end
    end

    addon:refresh_keys()
end

function addon:handle_gamepad_down(frame, key)
    -- Check if any modifier is held down
    local modifier = ""

    print(frame)

    -- Check for ALT modifier
    if IsAltKeyDown() then
        modifier = modifier .. "ALT-"
    end

    -- Check for CTRL modifier
    if IsControlKeyDown() then
        modifier = modifier .. "CTRL-"
    end

    -- Check for SHIFT modifier
    if IsShiftKeyDown() then
        modifier = modifier .. "SHIFT-"
    end

    -- Set the raw key for Gamepad input
    frame.raw_key = modifier .. key

    addon:refresh_keys()
end

-- Shared MouseWheel function with modifier support
function addon:handle_mouse_wheel(frame, delta)
    -- Initialize the modifier string
    local modifier = ""

    -- Check the current state of modifier keys
    if IsAltKeyDown() then
        modifier = modifier .. "ALT-"
    end
    if IsControlKeyDown() then
        modifier = modifier .. "CTRL-"
    end
    if IsShiftKeyDown() then
        modifier = modifier .. "SHIFT-"
    end

    -- Combine with MouseWheel action
    if delta > 0 then
        frame.raw_key = modifier .. "MOUSEWHEELUP"   -- Scrolled up with modifiers
    elseif delta < 0 then
        frame.raw_key = modifier .. "MOUSEWHEELDOWN" -- Scrolled down with modifiers
    end

    addon:refresh_keys()
end

function addon:handle_drag_or_size(self, button)
    if self.mouse_locked then
        return -- Do nothing if not MouseLocked is selected
    end

    if button == "LeftButton" and IsShiftKeyDown() then
        self.keys_mouse = nil
        self:Hide()
    elseif button == "LeftButton" then
        self:StartMoving()
        addon.isMoving = true -- Add a flag to indicate the frame is being moved
    end
end

function addon:handle_release(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        addon.isMoving = false -- Reset the flag when the movement is stopped
    end
end

local function rightclick_initialize(self, level)
    level = level or 1
    local info = UIDropDownMenu_CreateInfo()
    local value = UIDROPDOWNMENU_MENU_VALUE

    if level == 1 then
        info.text = _G["SPELLS"]
        info.value = "Spell"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = _G["MACRO"]
        info.value = "Macro"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = _G["INTERFACE_LABEL"]
        info.value = "UIBind"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = _G["UNBIND"]
        info.value = 1
        info.hasArrow = false
        info.func = function()
            if addon.current_clicked_key.raw_key ~= "" then
                SetBinding(addon.current_modifier_string .. (addon.current_clicked_key.raw_key or ""))
                SaveBindings(2)
                -- Print notification of key unbinding
                local keyText = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                print("KeyUI: Unbound key |cffff8000" .. keyText .. "|r")
            end
        end
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        if value == "Spell" then
            for tabName, _ in pairs(addon.spells) do
                info.text = tabName
                info.value = 'tab:' .. tabName
                info.hasArrow = true
                info.func = function() end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        if value == "Macro" then
            info.text = "General Macro"
            info.value = "General Macro"
            info.hasArrow = true
            info.func = function() end
            UIDropDownMenu_AddButton(info, level)

            info.text = "Player Macro"
            info.value = "Player Macro"
            info.hasArrow = true
            info.func = function() end
            UIDropDownMenu_AddButton(info, level)
        end

        if value == "UIBind" then
            local categories = {
                "MOVEMENT",
                "INTERFACE",
                "ACTIONBAR",
                "ACTIONBAR2",
                "ACTIONBAR3",
                "ACTIONBAR4",
                "ACTIONBAR5",
                "ACTIONBAR6",
                "ACTIONBAR7",
                "ACTIONBAR8",
                "CHAT",
                "TARGETING",
                "RAID_TARGET",
                "VEHICLE",
                "CAMERA",
                "PING_SYSTEM",
                "MISC",
            }

            for _, category in ipairs(categories) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = _G["BINDING_HEADER_" .. category] or category
                info.hasArrow = true
                info.value = category
                UIDropDownMenu_AddButton(info, level)
            end
        end
    elseif level == 3 then
        if value:find("^tab:") then
            local tabName = value:match('^tab:(.+)')
            for _, spell in pairs(addon.spells[tabName]) do
                local spell_name = spell.name
                local spell_id = spell.id

                if spell_id then
                    if IsSpellKnown(spell_id) then
                        local spell_icon = C_Spell.GetSpellTexture(spell_id)

                        info.text = spell_name
                        info.value = spell_name
                        info.icon = spell_icon
                        info.hasArrow = false
                        info.func = function()
                            local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                            local spell = "Spell " .. spell_name
                            local command = addon.current_clicked_key.binding
                            local binding_name = _G["BINDING_NAME_" .. command] or command

                            if addon.current_slot ~= nil then
                                C_Spell.PickupSpell(spell_id)
                                PlaceAction(addon.current_slot)
                                ClearCursor()
                                -- Print notification for new spell binding
                                print("KeyUI: Bound |cffa335ee" ..
                                    spell_name .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
                            else
                                SetBinding(key, spell)
                                SaveBindings(2)
                                -- Print notification for new spell binding
                                print("KeyUI: Bound |cffa335ee" .. spell_name .. "|r to |cffff8000" .. key .. "|r")
                            end
                        end
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        elseif value == "General Macro" then
            for i = 1, 36 do
                local title, icon, _ = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.icon = icon
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.current_clicked_key.binding
                        local actionSlot = addon.action_slot_mapping[actionbutton]
                        local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif value == "Player Macro" then
            for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
                local title, _, _ = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.current_clicked_key.binding
                        local actionSlot = addon.action_slot_mapping[actionbutton]
                        local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif addon.binding_mapping[value] then
            local keybindings = addon.binding_mapping[value]
            for _, keybinding in ipairs(keybindings) do
                local binding_name = keybinding[1]
                local binding_readable = _G["BINDING_NAME_" .. binding_name]
                info.text = binding_readable or binding_name
                info.value = binding_name
                info.hasArrow = false
                info.func = function(self)
                    local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                    SetBinding(key, binding_name)
                    SaveBindings(2)
                    -- Print notification for interface binding
                    print("KeyUI: Bound |cffa335ee" .. binding_readable .. "|r to |cffff8000" .. key .. "|r")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

-- Creates the dropdown menu for selecting key bindings.
function addon:create_context_menu()
    if not addon.dropdown then
        local dropdown = CreateFrame("Frame", nil, addon.keyboard_frame, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dropdown, 60)
        UIDropDownMenu_SetButtonWidth(dropdown, 20)
        UIDropDownMenu_Initialize(dropdown, rightclick_initialize, "MENU")
        dropdown:Hide()
        addon.dropdown = dropdown -- Save the dropdown for later use
    end
    return addon.dropdown
end

-- Event frame to handle all relevant events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
eventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventFrame:RegisterEvent("UPDATE_BINDINGS")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
eventFrame:RegisterEvent("PET_BAR_UPDATE")

-- Shared event handler function
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if addon.open then
        if event == "UPDATE_BONUS_ACTIONBAR" then --refresh_keys only
            -- Check the BonusBarOffset
            addon.bonusbar_offset = GetBonusBarOffset()
            addon:refresh_keys()
        elseif event == "ACTIONBAR_PAGE_CHANGED" then --refresh_keys only
            -- Update the current action bar page
            addon.current_actionbar_page = GetActionBarPage()
            addon:refresh_keys()
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then --refresh_layouts
            addon:refresh_layouts()
        elseif event == "UPDATE_BINDINGS" then             --refresh_layouts
            addon:refresh_layouts()
        elseif event == "PLAYER_REGEN_ENABLED" then        --nothing
            addon.in_combat = false
        elseif event == "PLAYER_REGEN_DISABLED" then       --nothing
            addon.in_combat = true
            -- Only close the addon if stay_open_in_combat is false
            if not keyui_settings.stay_open_in_combat and addon.open then
                addon:hide_all_frames()
            end
        elseif event == "PLAYER_LOGOUT" then --nothing
            -- Save Keyboard and Mouse Position when logging out
            addon:save_keyboard_position()
            addon:save_mouse_position()
            addon:save_controller_position()
        elseif event == "MODIFIER_STATE_CHANGED" then --refreshkeys only
            -- Handle the modifier state change
            local key, state = ...                    -- Get key and state from the event

            -- changed modifier states interferer when binding new keys and editing
            if addon.keyboard_locked ~= false and addon.mouse_locked ~= false and addon.controller_locked ~= false then -- true
                -- check if modifier are enabled
                if keyui_settings.listen_to_modifier == true then
                    -- check if the modifier checkboxes are empty
                    if addon.alt_checkbox == false and addon.ctrl_checkbox == false and addon.shift_checkbox == false then
                        if state == 1 then
                            -- Key press event
                            handle_key_press(key)
                        else
                            -- Key release event
                            handle_key_release(key)
                        end

                        -- If a button is hovered, refresh tooltip to update modifier state
                        if addon.current_hovered_button then
                            addon:button_mouse_over(addon.current_hovered_button)
                        end

                        if addon.current_pushed_button then
                            addon.current_pushed_button:Hide()
                        end
                    end
                end
            end
        else
            addon:refresh_keys()
        end
    else
        if event == "UPDATE_BONUS_ACTIONBAR" then
            -- Check the BonusBarOffset
            addon.bonusbar_offset = GetBonusBarOffset()
        elseif event == "ACTIONBAR_PAGE_CHANGED" then
            -- Update the current action bar page
            addon.current_actionbar_page = GetActionBarPage()
        elseif event == "PLAYER_LOGIN" then
            -- Check which class
            addon.class_name = UnitClassBase("player")
            -- Check the BonusBarOffset
            addon.bonusbar_offset = GetBonusBarOffset()
            -- Update the current action bar page
            addon.current_actionbar_page = GetActionBarPage()
        elseif event == "PLAYER_REGEN_ENABLED" then
            addon.in_combat = false
        end
    end
end)

-- SlashCmdList["KeyUI"] - Registers a command to load the addon.
SLASH_KeyUI1 = "/kui"
SLASH_KeyUI2 = "/keyui"
SlashCmdList["KeyUI"] = function() addon:load() end
