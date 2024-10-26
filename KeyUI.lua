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
    icon = "Interface\\AddOns\\KeyUI\\Media\\keyboard",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if addon.open then
                -- Close the addon regardless of the combat state
                addon:HideAll()
                addon.open = false
            else
                -- Open the addon if stay_open_in_combat is true OR if not in combat
                if not addon.in_combat or keyui_settings.stay_open_in_combat then
                    addon:Load()
                    addon.open = true
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

local function SetEscCloseEnabled(frame, enabled)
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
            order = 1,
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
            order = 2,
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
            desc = "Show or hide the keyboard interface",
            order = 4,
            get = function() return keyui_settings.show_keyboard end,
            set = function(_, value)
                keyui_settings.show_keyboard = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Keyboard visibility", status)
                if addon.open then
                    addon:UpdateInterfaceVisibility()
                end
            end,
        },
        show_mouse = {
            type = "toggle",
            name = "Show Mouse",
            desc = "Show or hide the mouse interface",
            order = 5,
            get = function() return keyui_settings.show_mouse end,
            set = function(_, value)
                keyui_settings.show_mouse = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Mouse visibility", status)
                if addon.open then
                    addon:UpdateInterfaceVisibility()
                end
            end,
        },
        -- toggle to enable or disable PushedTexture functionality
        show_pushed_texture = {
            type = "toggle",
            name = "Highlight Buttons",
            desc = "Enable or disable the highlight effect on action buttons",
            order = 3,
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
            desc = "Reset all settings to their default values",
            order = 7,
            confirm = true, -- Ask for confirmation
            confirmText = "Are you sure you want to reset all settings to default?",
            func = function()
                -- Reset all SavedVariables to their default values
                keyui_settings = {
                    show_keyboard = true,
                    show_mouse = true,
                    stay_open_in_combat = true,
                    show_pushed_texture = true,
                    prevent_esc_close = true,
                    keyboard_position = {},
                    mouse_position = {},
                    minimap = { hide = false },
                    show_empty_binds = false,
                    show_interface_binds = false,
                    tutorial_completed = false,
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
        prevent_esc_close = {
            type = "toggle",
            name = "Enable ESC",
            desc = "Enable or disable the addon window closing when pressing ESC",
            order = 6,
            get = function() return keyui_settings.prevent_esc_close end,
            set = function(_, value)
                keyui_settings.prevent_esc_close = value

                -- Immediately update the ESC closing behavior for all relevant frames
                SetEscCloseEnabled(addon.keyboard_frame, not keyui_settings.prevent_esc_close)
                SetEscCloseEnabled(addon.keyboard_control_frame, not keyui_settings.prevent_esc_close)
                SetEscCloseEnabled(addon.mouse_image, not keyui_settings.prevent_esc_close)
                SetEscCloseEnabled(addon.mouse_frame, not keyui_settings.prevent_esc_close)
                SetEscCloseEnabled(addon.mouse_control_frame, not keyui_settings.prevent_esc_close)

                local status = value and "enabled" or "disabled"
                print("KeyUI: Closing with ESC " .. status)
            end,
        }
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

    addon:UpdateInterfaceVisibility()
end)

-- Load() - Main function to load the addon.
function addon:Load()
    -- Prevent loading if in combat and 'stay_open_in_combat' is false.
    if addon.in_combat and not keyui_settings.stay_open_in_combat then
        return
    end

    addon.open = true -- Mark the addon as open
    addon:UpdateInterfaceVisibility()

    -- Initialize the keyboard layout selector if not already created.
    addon.keyboard_selector = addon.keyboard_selector or addon:KeyboardLayoutSelecter()
    local keyboard_active_board = next(keyui_settings.layout_current_keyboard)
    UIDropDownMenu_SetText(addon.keyboard_selector, keyboard_active_board)

    -- Initialize the mouse layout selector if not already created.
    addon.mouse_selector = addon.mouse_selector or addon:MouseLayoutSelecter()
    local mouse_active_board = next(keyui_settings.layout_current_mouse)
    UIDropDownMenu_SetText(addon.mouse_selector, mouse_active_board)

    -- Ensure the dropdown menu is created.
    addon:CreateDropDown()

    -- Initialize the tooltip if not already created.
    addon.tooltip = addon.tooltip or addon:CreateTooltip()

    -- Load spells and refresh the key bindings.
    addon:LoadSpells()
    addon:refresh_layouts()
end

-- Load all available spells and abilities of the player and store them in a table.
function addon:LoadSpells()
    addon.spells = {}
    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        local name = skillLineInfo.name
        local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems

        -- Ensure the skill line has a name before proceeding.
        if name then
            addon.spells[name] = {}

            for j = offset + 1, offset + numSlots do
                local spellName = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
                local isPassive = C_SpellBook.IsSpellBookItemPassive(j, Enum.SpellBookSpellBank.Player)
                if spellName and not isPassive then
                    table.insert(addon.spells[name], spellName)
                end
            end
        end
    end
end

-- Update the visibility of keyboard and mouse based on settings, only if addon is open
function addon:UpdateInterfaceVisibility()
    if not addon.open then
        return
    end

    local keyboard_frame = addon:GetKeyboardFrame()
    local keyboard_control = addon:GetKeyboardControl()
    local mouse_image = addon:GetMouseImage()
    local mouse_frame = addon:GetMouseFrame()
    local mouse_control = addon:GetMouseControl()

    if keyui_settings.show_keyboard then
        keyboard_frame:Show()
        keyboard_control:Show()
    else
        keyboard_frame:Hide()
        keyboard_control:Hide()
    end

    if keyui_settings.show_mouse then
        mouse_image:Show()
        mouse_frame:Show()
        mouse_control:Show()
    else
        mouse_image:Hide()
        mouse_frame:Hide()
        mouse_control:Hide()
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
        -- adjust the minimized control frame to the size of the (maybe) changed keyboard width
        if addon.keyboard_maximize_flag == false then
            addon.keyboard_control_frame:SetWidth(addon.keyboard_frame:GetWidth())
        end
    end

    -- if the mouse is locked and not edited we refresh the mouse board holding the keys
    if addon.mouse_locked ~= false and addon.keys_mouse_edited ~= true then
        addon:generate_mouse_key_frames(keyui_settings.key_bind_settings_mouse.currentboard)
    end

    -- update the textures/texts of the keys bindings.
    addon:refresh_keys()
end

-- Hides all UI elements when the addon is closed
function addon:HideAll()
    local keyboard_frame = addon:GetKeyboardFrame()
    local keyboard_control = addon:GetKeyboardControl()
    local mouse_image = addon:GetMouseImage()
    local mouse_frame = addon:GetMouseFrame()
    local mouse_control = addon:GetMouseControl()

    keyboard_frame:Hide()
    keyboard_control:Hide()
    mouse_image:Hide()
    mouse_frame:Hide()
    mouse_control:Hide()
end

local function OnFrameHide(self)
    if not addon.is_keyboard_frame_visible and not addon.is_mouse_image_visible then
        addon.open = false
        
        -- Discard Keyboard Editor Changes when closing
        if addon.keyboard_locked == false or addon.keys_keyboard_edited == true then
            addon:DiscardKeyboardChanges()
        end

        -- Discard Mouse Editor Changes when closing
        if addon.mouse_locked == false or addon.keys_mouse_edited == true then
            -- Discard any Editor Changes
            addon:DiscardMouseChanges()
        end
    end
end

-- Function to get or create the keyboard frame
function addon:GetKeyboardFrame()
    -- Check if the keyboard_frame already exists
    if not addon.keyboard_frame then
        -- Create the keyboard frame and assign it to the addon table
        addon.keyboard_frame = addon:CreateKeyboardFrame()

        addon.keyboard_frame:SetScript("OnHide", function()
            addon:SaveKeyboardPosition()
            addon.is_keyboard_frame_visible = false
            OnFrameHide()
        end)

        addon.keyboard_frame:SetScript("OnShow", function()
            addon.is_keyboard_frame_visible = true
        end)
    end
    return addon.keyboard_frame
end

-- Function to get or create the keyboard control
function addon:GetKeyboardControl()
    -- Check if the keyboard_control already exists
    if not addon.keyboard_control_frame then
        -- Create the keyboard control and assign it to the addon table
        addon.keyboard_control_frame = addon:CreateKeyboardControl()
    end
    return addon.keyboard_control_frame
end

-- Function to get or create the mouse image frame
function addon:GetMouseImage()
    -- Check if the mouse_image already exists
    if not addon.mouse_image then
        -- Create the mouse image and assign it to the addon table
        addon.mouse_image = addon:CreateMouseImage()

        addon.mouse_image:SetScript("OnHide", function()
            addon:SaveMousePosition()
            addon.is_mouse_image_visible = false
            OnFrameHide()
        end)

        addon.mouse_image:SetScript("OnShow", function()
            addon.is_mouse_image_visible = true
        end)
    end
    return addon.mouse_image
end

-- Function to get or create the mouse frame
function addon:GetMouseFrame()
    if not addon.mouse_frame then
        addon.mouse_frame = addon:CreateMouseFrame()
    end
    return addon.mouse_frame
end

-- Function to get or create the mouse control
function addon:GetMouseControl()
    if not addon.mouse_control_frame then
        addon.mouse_control_frame = addon:CreateMouseControl()
    end
    return addon.mouse_control_frame
end

function addon:CreateTooltip()
    -- Create the tooltip frame with the GlowBoxTemplate.
    local keyui_tooltip_frame = CreateFrame("Frame", nil, UIParent, "GlowBoxTemplate")
    addon.tooltip = keyui_tooltip_frame -- Save the tooltip to the addon table for reuse.

    -- Set the dimensions and appearance.
    keyui_tooltip_frame:SetWidth(200)
    keyui_tooltip_frame:SetHeight(25)
    keyui_tooltip_frame:SetScale(1)
    keyui_tooltip_frame:SetFrameStrata("TOOLTIP")

    -- Add a title to the tooltip.
    keyui_tooltip_frame.title = keyui_tooltip_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyui_tooltip_frame.title:SetPoint("TOPLEFT", keyui_tooltip_frame, "TOPLEFT", 10, -10)

    -- Hide the GameTooltip when this custom tooltip hides.
    keyui_tooltip_frame:SetScript("OnHide", function() GameTooltip:Hide() end)

    return keyui_tooltip_frame
end

-- This function is called when the Mouse cursor hovers over a key binding button. It displays a tooltip description of the spell or ability.
function addon:ButtonMouseOver(button)
    local keyui_tooltip_text = addon.tooltip

    local originalText = button.label:GetText()
    local readableText = _G["KEY_" .. originalText] or originalText
    local shortenedModifierString = (addon.current_modifier_string or "")
    -- Liste der Tasten, für die der Modifier nicht angezeigt werden soll
    local noModifierKeys = {
        ["ESC"] = true,
        ["LSHIFT"] = true,
        ["LCTRL"] = true,
        ["LALT"] = true,
        ["RALT"] = true,
        ["RCTRL"] = true,
        ["RSHIFT"] = true,
        ["LWIN"] = true,
        ["RWIN"] = true,
        ["MENU"] = true,
    }

    keyui_tooltip_text:SetPoint("TOPLEFT", button, "TOPRIGHT", 8, -4) -- Position for the Addon Tooltip

    if noModifierKeys[originalText] then
        keyui_tooltip_text.title:SetText((readableText or "") .. "\n" .. (button.action:GetText() or ""))
    else
        keyui_tooltip_text.title:SetText((shortenedModifierString .. readableText or "") .. "\n" .. (button.action:GetText() or ""))
    end

    keyui_tooltip_text.title:SetTextColor(1, 1, 1)
    keyui_tooltip_text.title:SetFont("Fonts\\ARIALN.TTF", 16)

    -- Set the size of the tooltip based on title dimensions
    keyui_tooltip_text:SetSize(keyui_tooltip_text.title:GetWidth() + 20, keyui_tooltip_text.title:GetHeight() + 20)

    -- Show or hide the tooltip based on conditions
    if (keyui_tooltip_text:GetWidth() < 15) or button.macro:GetText() == "" then
        keyui_tooltip_text:Hide()
    else
        keyui_tooltip_text:Show()
    end
end

-- Determines the texture or text displayed on the button based on the key binding.
function addon:SetKey(button)
    local spell = GetBindingAction(addon.current_modifier_string .. (button.label:GetText() or "")) or ""

    button.icon:Hide()

    -- Determine action button slot based on Class and Stance and Action Bar Page (only for Action Button 1-12)
    local function getActionButtonSlot(slot)
        
        -- Check if the class is Druid or Rogue in Stance and if we are on the first action bar page
        if (addon.class_name == "ROGUE" or addon.class_name == "DRUID") and addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
            if addon.bonusbar_offset == 1 then
                return slot + 72    -- Maps to 73-84
            elseif addon.bonusbar_offset == 2 then
                return slot + 84    -- Maps to 85-96
            elseif addon.bonusbar_offset == 3 then
                return slot + 96    -- Maps to 97-108
            elseif addon.bonusbar_offset == 4 then
                return slot + 108   -- Maps to 109-120
            end
        end

        -- Check if Dragonriding
        if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then    
            return slot + 120       -- Maps to 121-132
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
        if spell:find(a) then
            local slot = spell:match("ACTIONBUTTON(%d+)")
            local bar, bar2 = spell:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")

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
                -- Check if it's not a MULTIACTIONBAR case before applying bonusBarOffset
                if not bar then
                    slot = getActionButtonSlot(slot)
                end

                -- Set the action button texture
                button.icon:SetTexture(GetActionTexture(slot))
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                button.icon:Show()
                button.slot = slot
            end
        end
    end

    -- code for setting icons for other actions (movement, pets, etc.)
    local actionTextures = {
        EXTRAACTIONBUTTON1 = 4200126,
        MOVEFORWARD = "Interface\\AddOns\\KeyUI\\Media\\arrow_up",
        MOVEBACKWARD = "Interface\\AddOns\\KeyUI\\Media\\arrow_down",
        STRAFELEFT = "Interface\\AddOns\\KeyUI\\Media\\arrow_left",
        STRAFERIGHT = "Interface\\AddOns\\KeyUI\\Media\\arrow_right",
        TURNLEFT = "Interface\\AddOns\\KeyUI\\Media\\circle_left",
        TURNRIGHT = "Interface\\AddOns\\KeyUI\\Media\\circle_right",
    }

    if actionTextures[spell] then
        button.icon:SetTexture(actionTextures[spell])
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    end

    -- Handle Shapeshift Forms
    local shapeshift_slot = spell:match("SHAPESHIFTBUTTON(%d+)")
    if shapeshift_slot then
        local icon, active, castable, spellID = GetShapeshiftFormInfo(tonumber(shapeshift_slot))
        if icon then
            button.icon:SetTexture(icon)
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            button.icon:Show()
            button.spellid = spellID -- Set the spell ID for the shapeshift form
        else
            button.icon:Hide() -- Hide icon if there's no valid shapeshift form
        end
    end

    -- Pet Action Bar logic
    if PetHasActionBar() then
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            for i = 1, 10 do
                local petspellName = "BONUSACTIONBUTTON" .. i
                if spell:match(petspellName) then
                    -- GetPetActionInfo returns multiple values, including texture/token
                    local petName, petTexture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

                    -- If it's a token, use the token to get the texture
                    if isToken then
                        petTexture = _G[petTexture] or
                            "Interface\\Icons\\" ..
                            petTexture -- Use WoW's icon folder as fallback
                    end

                    if petTexture then
                        button.icon:SetTexture(petTexture)
                        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
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
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            button.icon:Hide()
            button.slot = nil
            button.spellid = nil
            button.petActionIndex = nil -- Clear petActionIndex when no pet action bar
        end
    end

    -- set hidden font string
    button.macro:SetText(spell)

    -- Set visible key name based on the current modifier string
    local originalText = button.label:GetText() or ""  -- Ensure originalText is never nil

    -- Check for shortcut label instead of global string
    local readableText = addon.shortcut_labels[originalText] or _G["KEY_" .. originalText] or originalText

    -- Liste der Tasten, für die der Modifier nicht angezeigt werden soll
    local noModifierKeys = {
        ["ESC"] = true,
        ["LSHIFT"] = true,
        ["LCTRL"] = true,
        ["LALT"] = true,
        ["RALT"] = true,
        ["RCTRL"] = true,
        ["RSHIFT"] = true,
        ["LWIN"] = true,
        ["RWIN"] = true,
        ["MENU"] = true,
    }

    if button.key then
        -- Überprüfen, ob der aktuelle Text in der Liste der Tasten ist, die keinen Modifier haben sollen
        if noModifierKeys[originalText] then
            button.key:SetText(readableText) -- Nur den lesbaren Text setzen, ohne Modifier
        else
            -- Kürze addon.current_modifier_string
            local shortenedModifierString = (addon.current_modifier_string or "")
                :gsub("ALT%-", "a-")
                :gsub("CTRL%-", "c-")
                :gsub("SHIFT%-", "s-")

            -- Append the shortened modifier string to the readable text
            if shortenedModifierString ~= "" then
                button.key:SetText(shortenedModifierString .. readableText)
            else
                button.key:SetText(readableText)
            end
        end
    end
end

-- Updates the textures/texts of the keys bindings.
function addon:refresh_keys()
    --print("refresh_keys function called")  -- print statement for debbuging

    -- if the keyboard is visible we create the keys
    if addon.is_keyboard_frame_visible ~= false then    -- true
        -- Set the keys
        for i = 1, #addon.keys_keyboard do
            addon:SetKey(addon.keys_keyboard[i])
        end
    end

    -- if the mouse is visible we create the keys
    if addon.is_mouse_image_visible ~= false then   -- true
        for j = 1, #addon.keys_mouse do
            addon:SetKey(addon.keys_mouse[j])
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
                if keyboard_button.label then
                    local labelText = keyboard_button.label:GetText() -- Get the label text

                    -- Get the macro text for the button
                    local macroText = keyboard_button.macro and keyboard_button.macro:GetText() or ""

                    -- Check if the bind is empty (replace with your actual spell retrieval logic)
                    local spell = "" -- Replace this with the actual check for the action

                    -- Check if the bind is empty and the key is not on the excluded list
                    if spell == "" and macroText == "" and not tContains({ "ESC", "CAPS", "CAPSLOCK", "LSHIFT", "LCTRL", "LALT", "RALT", "RCTRL", "RSHIFT", "BACKSPACE", "ENTER", "NUMPADENTER", "SPACE", "LWIN", "RWIN", "MENU" }, labelText) then
                        keyboard_button:SetBackdropColor(1, 0, 0, 1) -- Red color for empty keys
                    else
                        keyboard_button:SetBackdropColor(0, 0, 0, 1) -- Default color
                    end
                end
            end
        end

        -- Loop through all mouse buttons if they exist
        if self.mouse_buttons then
            for _, mouse_button in pairs(self.mouse_buttons) do
                if mouse_button.label then
                    local labelText = mouse_button.label:GetText() -- Get the label text

                    -- Get the macro text for the button
                    local macroText = mouse_button.macro and mouse_button.macro:GetText() or ""

                    -- Check if the bind is empty (replace with your actual spell retrieval logic)
                    local spell = "" -- Replace this with the actual check for the action

                    -- Check if the bind is empty and the key is not on the excluded list
                    if spell == "" and macroText == "" and not tContains({ "ESC", "CAPS", "CAPSLOCK", "LSHIFT", "LCTRL", "LALT", "RALT", "RCTRL", "RSHIFT", "BACKSPACE", "ENTER", "NUMPADENTER", "SPACE", "LWIN", "RWIN", "MENU" }, labelText) then
                        mouse_button:SetBackdropColor(1, 0, 0, 1) -- Red color for empty keys
                    else
                        mouse_button:SetBackdropColor(0, 0, 0, 1) -- Default color
                    end
                end
            end
        end
    else
        -- Reset color for all buttons when not showing empty binds
        if self.keyboard_buttons then
            for _, keyboard_button in pairs(self.keyboard_buttons) do
                keyboard_button:SetBackdropColor(0, 0, 0, 1) -- Default color
            end
        end

        if self.mouse_buttons then
            for _, mouse_button in pairs(self.mouse_buttons) do
                mouse_button:SetBackdropColor(0, 0, 0, 1) -- Default color
            end
        end
    end
end

-- Sets and displays the interface action label on all buttons, using the binding name or command name and toggles the visibility based on settings.
function addon:create_action_labels()
    -- Loop through all keyboard buttons if they exist
    if self.keyboard_buttons then
        for _, keyboard_button in pairs(self.keyboard_buttons) do
            if keyboard_button.action then
                local command = keyboard_button.macro and keyboard_button.macro:GetText()

                if command then
                    local binding_name = _G["BINDING_NAME_" .. command] or command
                    keyboard_button.action:SetText(binding_name)
                else
                    keyboard_button.action:SetText("")
                end

                -- Toggle visibility of the interface action label based on settings
                if keyui_settings.show_interface_binds then
                    keyboard_button.action:Show()
                else
                    keyboard_button.action:Hide()
                end
            end
        end
    end

    -- Loop through all mouse buttons if they exist
    if self.mouse_buttons then
        for _, mouse_button in pairs(self.mouse_buttons) do
            if mouse_button.action then
                local command = mouse_button.macro and mouse_button.macro:GetText()

                if command then
                    local binding_name = _G["BINDING_NAME_" .. command] or command
                    mouse_button.action:SetText(binding_name)
                else
                    mouse_button.action:SetText("")
                end

                -- Toggle visibility of the interface action label based on settings
                if keyui_settings.show_interface_binds then
                    mouse_button.action:Show()
                else
                    mouse_button.action:Hide()
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

-- Function to handle key press events
local function HandleKeyPress(key)
    if key == "LALT" or key == "RALT" then
        addon.modif.ALT = true
        if addon.keyboard_control_frame.AltCB then
            addon.keyboard_control_frame.AltCB:SetChecked(true)
        end
    elseif key == "LCTRL" or key == "RCTRL" then
        addon.modif.CTRL = true
        if addon.keyboard_control_frame.CtrlCB then
            addon.keyboard_control_frame.CtrlCB:SetChecked(true)
        end
    elseif key == "LSHIFT" or key == "RSHIFT" then
        addon.modif.SHIFT = true
        if addon.keyboard_control_frame.ShiftCB then
            addon.keyboard_control_frame.ShiftCB:SetChecked(true)
        end
    end
    addon:update_modifier_string()
    addon:refresh_keys()
end

-- Function to handle key release events
local function HandleKeyRelease(key)
    if key == "LALT" or key == "RALT" then
        addon.modif.ALT = false
        if addon.keyboard_control_frame.AltCB then
            addon.keyboard_control_frame.AltCB:SetChecked(false)
        end
    elseif key == "LCTRL" or key == "RCTRL" then
        addon.modif.CTRL = false
        if addon.keyboard_control_frame.CtrlCB then
            addon.keyboard_control_frame.CtrlCB:SetChecked(false)
        end
    elseif key == "LSHIFT" or key == "RSHIFT" then
        addon.modif.SHIFT = false
        if addon.keyboard_control_frame.ShiftCB then
            addon.keyboard_control_frame.ShiftCB:SetChecked(false)
        end
    end
    addon:update_modifier_string()
    addon:refresh_keys()
end

-- Shared KeyDown function for all buttons (keyboard + mouse)
function addon:HandleKeyDown(frame, key)
    -- Check if any modifier is held down
    local modifier = ""

    if IsAltKeyDown() and key ~= "LALT" and key ~= "RALT" then
        modifier = modifier .. "ALT-"
    end
    if IsControlKeyDown() and key ~= "LCTRL" and key ~= "RCTRL" then
        modifier = modifier .. "CTRL-"
    end
    if IsShiftKeyDown() and key ~= "LSHIFT" and key ~= "RSHIFT" then
        modifier = modifier .. "SHIFT-"
    end

    -- Set the label to the modifier and the pressed key
    if key == "MiddleButton" then
        frame.label:SetText(modifier .. "Button3") -- Handle middle mouse button
    else
        frame.label:SetText(modifier .. key) -- Set label to the pressed key with modifier
    end

    -- Hide pushed texture
    local adjustedSlot = frame.slot -- Assuming frame.slot is correctly set
    local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
    if mappedButton then
        local pushedTexture = mappedButton:GetPushedTexture()
        if pushedTexture then
            pushedTexture:Hide() -- Hide the pushed texture
        end
    end

    addon:refresh_keys()
end

-- Shared MouseWheel function with modifier support
function addon:HandleMouseWheel(frame, delta)
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
        frame.label:SetText(modifier .. "MouseWheelUp") -- Scrolled up with modifiers
    elseif delta < 0 then
        frame.label:SetText(modifier .. "MouseWheelDown") -- Scrolled down with modifiers
    end

    addon:refresh_keys()
end

local function DropDown_Initialize(self, level)
    level = level or 1
    local info = UIDropDownMenu_CreateInfo()
    local value = UIDROPDOWNMENU_MENU_VALUE

    if level == 1 then
        info.text = "Spell"
        info.value = "Spell"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Macro"
        info.value = "Macro"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Interface"
        info.value = "UIBind"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Clear Action Button"
        info.value = 1
        info.hasArrow = false
        info.func = function(self)
            local key = addon.currentKey.macro and addon.currentKey.macro:GetText()
            if key then
                local actionSlot = addon.action_slot_mapping[key]
                if actionSlot then
                    PickupAction(actionSlot)
        
                    -- Use the global binding name or fallback to "Unknown Action"
                    local mappedName = _G["BINDING_NAME_" .. key] or "Unknown Action"
                    
                    -- Print notification with the mapped name in purple
                    print("KeyUI: Cleared |cffa335ee" .. mappedName .. "|r")
                    addon:refresh_keys()
                end
            end
        end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Unbind Key"
        info.value = 1
        info.hasArrow = false
        info.func = function()
            if addon.currentKey.label ~= "" then
                SetBinding(addon.current_modifier_string .. (addon.currentKey.label:GetText() or ""))
                addon.currentKey.macro:SetText("")
                addon:refresh_keys()
                SaveBindings(2)
                -- Print notification of key unbinding
                local keyText = addon.current_modifier_string .. (addon.currentKey.label:GetText() or "")
                print("KeyUI: Unbound key |cffff8000" .. keyText .. "|r")
            end
        end
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        if value == "Spell" then
            for tabName, v in pairs(addon.spells) do
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
                "Movement Keys",
                "Action Bar",
                "Action Bar 2",
                "Action Bar 3",
                "Action Bar 4",
                "Action Bar 5",
                "Action Bar 6",
                "Action Bar 7",
                "Action Bar 8",
                "Interface Panel",
                "Chat",
                "Targeting",
                "Target Markers",
                "Vehicle Controls",
                "Camera",
                "Ping System",
                "Miscellaneous",
            }
            for _, category in ipairs(categories) do
                local keybindings = addon.action_mapping[category]
                if keybindings then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = category
                    info.hasArrow = true
                    info.value = category
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    elseif level == 3 then
        if value:find("^tab:") then
            local tabName = value:match('^tab:(.+)')
            for k, spellName in pairs(addon.spells[tabName]) do
                info.text = spellName
                info.value = spellName
                info.hasArrow = false
                info.func = function(self)
                    local actionbutton = addon.currentKey.macro:GetText()
                    local actionSlot = addon.action_slot_mapping[actionbutton]
                    local key = addon.current_modifier_string .. (addon.currentKey.label:GetText() or "")
                    local command = "Spell " .. spellName
                    if actionSlot then
                        C_Spell.PickupSpell(spellName)
                        PlaceAction(actionSlot)
                        --print(spellName)      -- Spellname
                        --print(key)            -- e.g. ACTIONBUTTON1
                        --print(actionSlot)     -- e.g. 1 (Actionslot)
                        -- Print notification for new spell binding
                        print("KeyUI: Bound |cffa335ee" .. spellName .. "|r to |cffff8000" .. key .. "|r")
                        addon:refresh_keys()
                    else
                        SetBinding(key, command)
                        SaveBindings(2)
                        -- Print notification for new spell binding
                        print("KeyUI: Bound |cffa335ee" .. spellName .. "|r to |cffff8000" .. key .. "|r")
                        addon:refresh_keys()
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif value == "General Macro" then
            for i = 1, 36 do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.currentKey.macro:GetText()
                        local actionSlot = addon.action_slot_mapping[actionbutton]
                        local key = addon.current_modifier_string .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            addon:refresh_keys()
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                            addon:refresh_keys()
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif value == "Player Macro" then
            for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.currentKey.macro:GetText()
                        local actionSlot = addon.action_slot_mapping[actionbutton]
                        local key = addon.current_modifier_string .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            addon:refresh_keys()
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                            addon:refresh_keys()
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif addon.action_mapping[value] then
            local keybindings = addon.action_mapping[value]
            for index, keybinding in ipairs(keybindings) do
                info.text = keybinding[1]
                info.value = keybinding[2]
                info.hasArrow = false
                info.func = function(self)
                    local key = addon.current_modifier_string .. (addon.currentKey.label:GetText() or "")
                    SetBinding(key, keybinding[2])
                    SaveBindings(2)
                    -- Print notification for interface binding
                    print("KeyUI: Bound |cffa335ee" .. keybinding[1] .. "|r to |cffff8000" .. key .. "|r")
                    addon:refresh_keys()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

-- CreateDropDown() - Creates the dropdown menu for selecting key bindings.
function addon:CreateDropDown()
    if not addon.dropdown then
        local dropdown = CreateFrame("Frame", nil, addon.keyboard_frame, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dropdown, 60)
        UIDropDownMenu_SetButtonWidth(dropdown, 20)
        UIDropDownMenu_Initialize(dropdown, DropDown_Initialize, "MENU")
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
        if event == "UPDATE_BONUS_ACTIONBAR" then           --refresh_keys only
            -- Check the BonusBarOffset
            addon.bonusbar_offset = GetBonusBarOffset()
            addon:refresh_keys()
        elseif event == "ACTIONBAR_PAGE_CHANGED" then       --refresh_keys only
            -- Update the current action bar page
            addon.current_actionbar_page = GetActionBarPage()
            addon:refresh_keys()
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then  --refresh_layouts
            addon:refresh_layouts()
        elseif event == "UPDATE_BINDINGS" then              --refresh_layouts
            addon:refresh_layouts()
        elseif event == "PLAYER_REGEN_ENABLED" then         --nothing
            addon.in_combat = false
        elseif event == "PLAYER_REGEN_DISABLED" then        --nothing
            addon.in_combat = true
            -- Only close the addon if stay_open_in_combat is false
            if not keyui_settings.stay_open_in_combat and addon.open then
                addon:HideAll()
            end
        elseif event == "PLAYER_LOGOUT" then                --nothing
            -- Save Keyboard and Mouse Position when logging out
            addon:SaveKeyboardPosition()
            addon:SaveMousePosition()
        elseif event == "MODIFIER_STATE_CHANGED" then       --refreshkeys only

            -- Handle the modifier state change
            local key, state = ...                    -- Get key and state from the event

            -- changed modifier states interferer when binding new keys and editing
            if addon.keyboard_locked ~= false and addon.mouse_locked ~= false then  -- true

                -- check if the modifier checkboxes are empty
                if addon.alt_checkbox == false and addon.ctrl_checkbox == false and addon.shift_checkbox == false then

                    if state == 1 then
                        -- Key press event
                        HandleKeyPress(key)
                    else
                        -- Key release event
                        HandleKeyRelease(key)
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
SlashCmdList["KeyUI"] = function() addon:Load() end
