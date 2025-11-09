local name, addon = ...

-- Initialize libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
local LDB = LibStub("LibDataBroker-1.1")

local PROFILE_EXPORT_VERSION = 1
local LAYOUT_EXPORT_VERSION = 1

local get_layout_meta
local layout_type_labels = {
    keyboard = "Keyboard",
    mouse = "Mouse",
    controller = "Controller",
}

local function sanitize_layout_name(name)
    if type(name) ~= "string" then
        return ""
    end
    return (name:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Create the options frame and add it to the Interface Options
local optionsFrame = AceConfigDialog:AddToBlizOptions("KeyUI", "KeyUI")

-- Minimap button setup using LibDataBroker
local miniButton = LDB:NewDataObject("KeyUI", {
    type = "data source",
    text = "KeyUI",
    icon = "Interface\\AddOns\\KeyUI\\Media\\keyui_icon.blp",
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

local function deep_copy(value, copies)
    if type(value) ~= "table" then
        return value
    end

    copies = copies or {}
    if copies[value] then
        return copies[value]
    end

    local clone = {}
    copies[value] = clone

    for key, inner in pairs(value) do
        clone[deep_copy(key, copies)] = deep_copy(inner, copies)
    end

    return clone
end

local serialize_value -- forward declaration

local function serialize_table(tbl)
    local out = { "{" }

    for index = 1, #tbl do
        out[#out + 1] = serialize_value(index)
        out[#out + 1] = serialize_value(tbl[index])
    end

    local extra_keys = {}
    for key in pairs(tbl) do
        if not (type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #tbl) then
            extra_keys[#extra_keys + 1] = key
        end
    end

    table.sort(extra_keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, key in ipairs(extra_keys) do
        out[#out + 1] = serialize_value(key)
        out[#out + 1] = serialize_value(tbl[key])
    end

    out[#out + 1] = "}"
    return table.concat(out)
end

serialize_value = function(value)
    local value_type = type(value)
    if value_type == "string" then
        return "s" .. #value .. ":" .. value
    elseif value_type == "number" then
        return "n" .. tostring(value) .. ";"
    elseif value_type == "boolean" then
        return value and "b1;" or "b0;"
    elseif value_type == "table" then
        return serialize_table(value)
    else
        error("Unsupported type: " .. value_type)
    end
end

local function deserialize_value(data, index)
    local prefix = data:sub(index, index)

    if prefix == "s" then
        local colon = data:find(":", index + 1, true)
        if not colon then error("Malformed string token") end
        local length = tonumber(data:sub(index + 1, colon - 1))
        if not length then error("Invalid string length") end

        local start_pos = colon + 1
        local end_pos = start_pos + length - 1
        if end_pos > #data then error("String length exceeds payload") end

        local value = data:sub(start_pos, end_pos)
        return value, end_pos + 1
    elseif prefix == "n" then
        local semi = data:find(";", index + 1, true)
        if not semi then error("Malformed number token") end
        local number_value = tonumber(data:sub(index + 1, semi - 1))
        if not number_value then error("Invalid number value") end
        return number_value, semi + 1
    elseif prefix == "b" then
        local semi = data:find(";", index + 1, true)
        if not semi then error("Malformed boolean token") end
        local bool_value = data:sub(index + 1, semi - 1)
        if bool_value ~= "1" and bool_value ~= "0" then
            error("Invalid boolean value")
        end
        return bool_value == "1", semi + 1
    elseif prefix == "{" then
        local tbl = {}
        local cursor = index + 1
        while cursor <= #data do
            local control = data:sub(cursor, cursor)
            if control == "}" then
                return tbl, cursor + 1
            end
            local key
            key, cursor = deserialize_value(data, cursor)
            local value
            value, cursor = deserialize_value(data, cursor)
            tbl[key] = value
        end
        error("Unterminated table token")
    else
        error("Unknown token '" .. prefix .. "'")
    end
end

function addon:BuildProfileSnapshot()
    return {
        version = PROFILE_EXPORT_VERSION,
        settings = deep_copy(keyui_settings),
    }
end

function addon:SerializeProfile(snapshot)
    return self:SerializeTable(snapshot)
end

function addon:DeserializeProfile(serialized)
    return self:DeserializeTable(serialized)
end

function addon:GetProfileExportString()
    local snapshot = self:BuildProfileSnapshot()
    local ok, payload = pcall(self.SerializeProfile, self, snapshot)
    if not ok then
        return nil, payload
    end
    return payload
end

function addon:ApplyProfileSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false, "Invalid profile data"
    end

    if snapshot.version ~= PROFILE_EXPORT_VERSION then
        return false, "Unsupported profile version"
    end

    if type(snapshot.settings) ~= "table" then
        return false, "Profile missing settings data"
    end

    local sanitized = deep_copy(snapshot.settings)

    wipe(keyui_settings)
    for key, value in pairs(sanitized) do
        keyui_settings[key] = value
    end

    self:InitializeSettings()

    self.keyboard_layout_dirty = true
    self.mouse_layout_dirty = true
    self.controller_layout_dirty = true

    self:hide_all_frames()

    self:SyncMinimapButton()

    if keyui_settings.show_keyboard or keyui_settings.show_mouse or keyui_settings.show_controller then
        self:load()
    end

    print("KeyUI: Profile imported.")
    return true
end

function addon:ImportProfileString(serialized)
    if type(serialized) ~= "string" then
        return false, "Invalid profile string"
    end

    local trimmed = serialized:match("^%s*(.-)%s*$")
    if trimmed == "" then
        return false, "Profile string is empty"
    end

    local ok, data_or_error = self:DeserializeProfile(trimmed)
    if not ok then
        return false, data_or_error
    end

    local success, apply_error = self:ApplyProfileSnapshot(data_or_error)
    if not success then
        return false, apply_error
    end

    if Settings and SettingsPanel and SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end

    return true
end

function addon:RenameLayout(layout_type, old_name, new_name)
    local meta = get_layout_meta(layout_type)
    if not meta then
        return false, "Unsupported layout type."
    end

    local container = meta.edited()
    local layout = container and container[old_name]
    if not layout then
        return false, "Layout not found."
    end

    new_name = sanitize_layout_name(new_name)
    if new_name == "" then
        return false, "Name cannot be empty."
    end

    if container[new_name] then
        return false, "A layout with that name already exists."
    end

    container[new_name] = layout
    container[old_name] = nil

    local current_container = meta.current()
    if current_container[old_name] then
        current_container[new_name] = current_container[old_name]
        current_container[old_name] = nil
    end

    local keybind = meta.keybind()
    if keybind.currentboard == old_name then
        keybind.currentboard = new_name
    end

    local selector_field = meta.selector
    if selector_field and addon[selector_field] then
        addon[selector_field]:SetDefaultText(new_name)
    end

    print(("KeyUI: Renamed %s layout '%s' to '%s'."):format(layout_type_labels[layout_type] or layout_type, old_name, new_name))
    addon:refresh_layouts()
    return true
end

function addon:CopyLayout(layout_type, source_name, new_name)
    local meta = get_layout_meta(layout_type)
    if not meta then
        return false, "Unsupported layout type."
    end

    local container = meta.edited()
    local source = container and container[source_name]
    if not source then
        return false, "Layout not found."
    end

    new_name = sanitize_layout_name(new_name)
    if new_name == "" then
        return false, "Name cannot be empty."
    end

    if container[new_name] then
        return false, "A layout with that name already exists."
    end

    container[new_name] = deep_copy(source)

    local current_container = meta.current()
    wipe(current_container)
    current_container[new_name] = container[new_name]

    local keybind = meta.keybind()
    keybind.currentboard = new_name

    local selector_field = meta.selector
    if selector_field and addon[selector_field] then
        addon[selector_field]:SetDefaultText(new_name)
    end

    print(("KeyUI: Copied %s layout '%s' to '%s'."):format(layout_type_labels[layout_type] or layout_type, source_name, new_name))
    addon:refresh_layouts()
    return true
end

function addon:ShowProfileExportPopup()
    StaticPopup_Show("KEYUI_EXPORT_PROFILE")
end

function addon:ShowProfileImportPopup()
    StaticPopup_Show("KEYUI_IMPORT_PROFILE")
end

function addon:ShowLayoutRenamePopup(layout_type, layout_name)
    StaticPopup_Show("KEYUI_LAYOUT_RENAME", nil, nil, {
        layoutType = layout_type,
        layoutName = layout_name,
    })
end

function addon:ShowLayoutCopyPopup(layout_type, layout_name)
    StaticPopup_Show("KEYUI_LAYOUT_COPY", nil, nil, {
        layoutType = layout_type,
        layoutName = layout_name,
    })
end

function addon:SerializeTable(payload)
    return serialize_value(payload)
end

function addon:DeserializeTable(serialized)
    local success, value_or_error = pcall(function()
        local value, position = deserialize_value(serialized, 1)
        if position <= #serialized then
            local remainder = serialized:sub(position):match("^%s*(.-)%s*$")
            if remainder ~= "" then
                error("Trailing data in serialized string")
            end
        end
        return value
    end)

    if not success then
        return false, value_or_error
    end

    return true, value_or_error
end

local layout_meta_map = {
    keyboard = {
        edited = function()
            keyui_settings.layout_edited_keyboard = keyui_settings.layout_edited_keyboard or {}
            return keyui_settings.layout_edited_keyboard
        end,
        current = function()
            keyui_settings.layout_current_keyboard = keyui_settings.layout_current_keyboard or {}
            return keyui_settings.layout_current_keyboard
        end,
        keybind = function()
            keyui_settings.key_bind_settings_keyboard = keyui_settings.key_bind_settings_keyboard or {}
            return keyui_settings.key_bind_settings_keyboard
        end,
        selector = "keyboard_selector",
        show_setting = "show_keyboard",
    },
    mouse = {
        edited = function()
            keyui_settings.layout_edited_mouse = keyui_settings.layout_edited_mouse or {}
            return keyui_settings.layout_edited_mouse
        end,
        current = function()
            keyui_settings.layout_current_mouse = keyui_settings.layout_current_mouse or {}
            return keyui_settings.layout_current_mouse
        end,
        keybind = function()
            keyui_settings.key_bind_settings_mouse = keyui_settings.key_bind_settings_mouse or {}
            return keyui_settings.key_bind_settings_mouse
        end,
        selector = "mouse_selector",
        show_setting = "show_mouse",
    },
    controller = {
        edited = function()
            keyui_settings.layout_edited_controller = keyui_settings.layout_edited_controller or {}
            return keyui_settings.layout_edited_controller
        end,
        current = function()
            keyui_settings.layout_current_controller = keyui_settings.layout_current_controller or {}
            return keyui_settings.layout_current_controller
        end,
        keybind = function()
            keyui_settings.key_bind_settings_controller = keyui_settings.key_bind_settings_controller or {}
            return keyui_settings.key_bind_settings_controller
        end,
        selector = "controller_selector",
        show_setting = "show_controller",
    },
}

get_layout_meta = function(layout_type)
    return layout_meta_map[layout_type]
end

local function get_layout_container(layout_type)
    local meta = get_layout_meta(layout_type)
    if not meta then return end
    return meta.edited()
end

local function ensure_unique_layout_name(container, base_name)
    local candidate = base_name
    if not container[candidate] then
        return candidate
    end
    local suffix = 2
    repeat
        candidate = ("%s (%d)"):format(base_name, suffix)
        suffix = suffix + 1
    until not container[candidate]
    return candidate
end

function addon:SerializeLayoutPayload(layout_type, layout_name, layout_data)
    if type(layout_data) ~= "table" then
        return nil, "Layout data is invalid."
    end

    local payload = {
        version = LAYOUT_EXPORT_VERSION,
        layoutType = layout_type,
        name = layout_name,
        layout = deep_copy(layout_data),
    }

    local ok, encoded = pcall(self.SerializeTable, self, payload)
    if not ok then
        return nil, encoded
    end
    return encoded
end

function addon:DeserializeLayoutPayload(serialized)
    local ok, payload = self:DeserializeTable(serialized)
    if not ok then
        return false, payload
    end

    if type(payload) ~= "table" then
        return false, "Layout payload malformed."
    end

    if payload.version ~= LAYOUT_EXPORT_VERSION then
        return false, "Unsupported layout version."
    end

    if type(payload.layoutType) ~= "string" then
        return false, "Layout type missing."
    end

    if type(payload.layout) ~= "table" then
        return false, "Layout data missing."
    end

    return true, payload
end

function addon:ImportLayoutString(layout_type, serialized)
    if type(serialized) ~= "string" then
        return false, "Invalid layout string."
    end

    local trimmed = serialized:match("^%s*(.-)%s*$")
    if trimmed == "" then
        return false, "Layout string is empty."
    end

    local ok, payload = self:DeserializeLayoutPayload(trimmed)
    if not ok then
        return false, payload
    end

    if payload.layoutType ~= layout_type then
        local expected = layout_type_labels[layout_type] or layout_type
        local actual = layout_type_labels[payload.layoutType] or payload.layoutType
        return false, ("Layout is for %s, not %s."):format(actual, expected)
    end

    local meta = get_layout_meta(layout_type)
    if not meta then
        return false, "Unsupported layout category."
    end

    local container = meta.edited()

    local base_name = payload.name
    if type(base_name) ~= "string" or base_name == "" then
        base_name = ("Imported %s Layout"):format(layout_type_labels[layout_type] or "")
    end

    local unique_name = ensure_unique_layout_name(container, base_name)
    container[unique_name] = deep_copy(payload.layout)

    local current_container = meta.current()
    wipe(current_container)
    current_container[unique_name] = container[unique_name]

    local keybind = meta.keybind()
    keybind.currentboard = unique_name

    local selector_field = meta.selector
    if selector_field and addon[selector_field] then
        addon[selector_field]:SetDefaultText(unique_name)
    end

    print(("KeyUI: Imported %s layout '%s'."):format(layout_type_labels[layout_type] or layout_type, unique_name))
    if addon.open then
        addon:refresh_layouts()
    elseif meta.show_setting and keyui_settings[meta.show_setting] then
        addon:load()
    end
    return true
end

function addon:ShowLayoutExportPopup(layout_type, layout_name, layout_data)
    local encoded, err = self:SerializeLayoutPayload(layout_type, layout_name, layout_data)
    if not encoded then
        print(("KeyUI: Unable to export layout - %s"):format(err or "Unknown error"))
        return
    end

    StaticPopup_Show("KEYUI_EXPORT_LAYOUT", nil, nil, {
        payload = encoded,
        name = layout_name,
        layoutType = layout_type,
    })
end

function addon:ShowLayoutImportPopup(layout_type)
    StaticPopup_Show("KEYUI_IMPORT_LAYOUT", nil, nil, {
        layoutType = layout_type,
    })
end

function addon:SyncMinimapButton()
    if not LibDBIcon then
        return
    end

    if keyui_settings.minimap and keyui_settings.minimap.hide then
        LibDBIcon:Hide("KeyUI")
    else
        LibDBIcon:Show("KeyUI")
    end
end

local function hide_widget(widget)
    if widget and widget.Hide then
        widget:Hide()
    end
end

local function clear_key_collection(collection)
    if not collection then return end
    for i = #collection, 1, -1 do
        local button = collection[i]
        if button and button.Hide then
            button:Hide()
        end
        collection[i] = nil
    end
end

local function hide_resettable_frames(self)
    hide_widget(self.keyboard_frame)
    hide_widget(self.mouse_image)
    hide_widget(self.mouse_frame)
    hide_widget(self.controller_frame)
    hide_widget(self.controller_image)
    hide_widget(self.controls_frame)
    hide_widget(self.selection_frame)
    hide_widget(self.keyui_tooltip_frame)
    hide_widget(self.dropdown)
    hide_widget(self.name_input_dialog)
    hide_widget(self.edit_layout_dialog)
    hide_widget(self.keyboard_selector)
    hide_widget(self.mouse_selector)
    hide_widget(self.controller_selector)

    self.dropdown = nil
    self.keyboard_selector = nil
    self.mouse_selector = nil
    self.controller_selector = nil
    self.keyui_tooltip_frame = nil
    self.name_input_dialog = nil
    self.edit_layout_dialog = nil
    self.current_clicked_key = nil
    self.current_hovered_button = nil
    self.current_pushed_button = nil
end

local function reset_saved_variables()
    local minimap_db = keyui_settings.minimap
    wipe(keyui_settings)
    keyui_settings.minimap = minimap_db or {}
    wipe(keyui_settings.minimap)
    keyui_settings.minimap.hide = false

    addon:InitializeSettings()
end

local function reset_runtime_flags(self)
    clear_key_collection(self.keys_keyboard)
    clear_key_collection(self.keys_mouse)
    clear_key_collection(self.keys_controller)

    self.keys_keyboard = {}
    self.keys_mouse = {}
    self.keys_controller = {}

    self.keyboard_locked = true
    self.mouse_locked = true
    self.controller_locked = true

    self.keys_keyboard_edited = false
    self.keys_mouse_edited = false
    self.keys_controller_edited = false

    self.open = false
    self.in_combat = false
    self.is_keyboard_visible = false
    self.is_mouse_visible = false
    self.is_controller_visible = false

    self.controller_system = nil

    self.modif = { ALT = false, CTRL = false, SHIFT = false }
    self.current_modifier_string = ""
    self.alt_checkbox = false
    self.ctrl_checkbox = false
    self.shift_checkbox = false
    self.active_control_tab = ""

    self.tutorial_frame1_created = false
    self.tutorial_frame2_created = false
end

local function reset_frame_positions(self)
    if self.keyboard_frame then
        self.keyboard_frame:ClearAllPoints()
        self.keyboard_frame:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
        self.keyboard_frame:SetScale(1)
        if self.keyboard_frame.edit_frame then
            self.keyboard_frame.edit_frame:Hide()
        end
    end

    if self.mouse_image then
        self.mouse_image:ClearAllPoints()
        self.mouse_image:SetPoint("CENTER", UIParent, "CENTER", 450, 0)
        self.mouse_image:SetScale(1)
        if self.mouse_image.edit_frame then
            self.mouse_image.edit_frame:Hide()
        end
    end

    if self.mouse_frame then
        self.mouse_frame:ClearAllPoints()
        if self.mouse_image then
            self.mouse_frame:SetPoint("RIGHT", self.mouse_image, "LEFT", 5, -25)
        else
            self.mouse_frame:SetPoint("RIGHT", UIParent, "CENTER", 0, -25)
        end
        self.mouse_frame:SetScale(1)
    end

    if self.controller_frame then
        self.controller_frame:ClearAllPoints()
        self.controller_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self.controller_frame:SetScale(1)
        if self.controller_frame.edit_frame then
            self.controller_frame.edit_frame:Hide()
        end
    end

    if self.controller_image then
        self.controller_image:Hide()
    end

    if self.controls_frame then
        self.controls_frame:ClearAllPoints()
        self.controls_frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        local expanded_height = keyui_settings.controls_expanded and 320 or 200
        self.controls_frame:SetHeight(expanded_height)
    end

    if self.selection_frame then
        self.selection_frame:ClearAllPoints()
        self.selection_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 160)
    end
end

function addon:ResetAddonSettings()
    hide_resettable_frames(self)
    reset_saved_variables()
    reset_runtime_flags(self)
    reset_frame_positions(self)
    self:SyncMinimapButton()

    print("KeyUI: Settings reset to defaults.")
end

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
            order = 7,
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
            order = 8,
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
                addon:ResetAddonSettings()
            end,
        },
        prevent_esc_close = {
            type = "toggle",
            name = "Enable ESC",
            desc = "Enable or disable the addon window closing when pressing ESC",
            order = 9,
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
        show_keyboard_background = {
            type = "toggle",
            name = "Keyboard Background",
            desc = "Show or hide the background and border of the keyboard frame",
            order = 4,
            get = function() return keyui_settings.show_keyboard_background end,
            set = function(_, value)
                keyui_settings.show_keyboard_background = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Keyboard background", status)
            end,
        },
        show_mouse_graphic = {
            type = "toggle",
            name = " Mouse Graphic",
            desc = "Show or hide the graphical representation of the mouse",
            order = 5,
            get = function() return keyui_settings.show_mouse_graphic end,
            set = function(_, value)
                keyui_settings.show_mouse_graphic = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Mouse graphic", status)
            end,
        },
        show_controller_background = {
            type = "toggle",
            name = "Controller Background",
            desc = "Show or hide the background and border of the controller frame",
            order = 6,
            get = function() return keyui_settings.show_controller_background end,
            set = function(_, value)
                keyui_settings.show_controller_background = value
                local status = value and "enabled" or "disabled"
                print("KeyUI: Controller background", status)
            end,
        },
        profile_header = {
            type = "header",
            name = "Profiles",
            order = 20,
        },
        export_profile = {
            type = "execute",
            name = "Export Profile",
            desc = "Copy your current KeyUI configuration as a sharable string",
            order = 21,
            func = function()
                addon:ShowProfileExportPopup()
            end,
        },
        import_profile = {
            type = "execute",
            name = "Import Profile",
            desc = "Paste a profile string to apply someone else's configuration",
            order = 22,
            func = function()
                addon:ShowProfileImportPopup()
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
    if addon.is_keyboard_visible == false and addon.is_mouse_visible == false and addon.is_controller_visible == false then
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
        addon.is_keyboard_visible = true
        keyboard_frame:Show()
        if keyui_settings.show_keyboard_background ~= true then
            -- Remove the background and border if graphics are disabled
            keyboard_frame:SetBackdrop(nil)
        else
            -- Restore the background and border if graphics are enabled
            keyboard_frame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
                tile = true,
                tileSize = 8,
                edgeSize = 14,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            keyboard_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)
        end
    end

    if keyui_settings.show_mouse == true then
        addon.is_mouse_visible = true
        mouse_image:Show()
        mouse_frame:Show()
        if keyui_settings.show_mouse_graphic ~= true then
            mouse_image.Texture:Hide()
        else
            mouse_image.Texture:Show()
        end
    end

    if keyui_settings.show_controller == true then
        addon.is_controller_visible = true
        controller_frame:Show()
        if controller_image then
            controller_image:Show()
        end
        if keyui_settings.show_controller_background ~= true then
            -- Remove the background and border if graphics are disabled
            controller_frame:SetBackdrop(nil)
        else
            -- Restore the background and border if graphics are enabled
            controller_frame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
                tile = true,
                tileSize = 8,
                edgeSize = 14,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            controller_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)
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
    addon.is_keyboard_visible = false
    addon.is_mouse_visible = false
    addon.is_controller_visible = false
end

local function on_frame_hide(self)
    if (addon.is_keyboard_visible == false or keyui_settings.show_keyboard == false) and (addon.is_mouse_visible == false or keyui_settings.show_mouse == false) and (addon.is_controller_visible == false or keyui_settings.show_controller == false) then
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
            addon.is_keyboard_visible = false
            on_frame_hide()
        end)

        addon.keyboard_frame:SetScript("OnShow", function()
            addon.is_keyboard_visible = true
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
            addon.is_mouse_visible = false
            on_frame_hide()
        end)

        addon.mouse_image:SetScript("OnShow", function()
            addon.is_mouse_visible = true
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
            addon.is_controller_visible = false
            on_frame_hide()
        end)

        addon.controller_frame:SetScript("OnShow", function()
            addon.is_controller_visible = true
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
    local readable_key = (addon.short_keys and addon.short_keys[raw_key]) or _G["KEY_" .. raw_key] or raw_key
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
    if short_key then
        if addon.no_modifier_keys[raw_key] then
            addon.keyui_tooltip_frame.key:SetText(short_key)
        else
            if keyui_settings.dynamic_modifier then
                addon.keyui_tooltip_frame.key:SetText(short_modifier_string .. (readable_key or short_key))
            else
                addon.keyui_tooltip_frame.key:SetText(short_modifier_string .. short_key)
            end
        end
    else
        addon.keyui_tooltip_frame.key:SetText("")
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
    elseif addon.current_hovered_button.spellid then
        GameTooltip:SetOwner(addon.current_hovered_button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetSpellByID(addon.current_hovered_button.spellid)
        GameTooltip:Show()
    elseif addon.current_hovered_button.pet_action_index then
        GameTooltip:SetOwner(addon.current_hovered_button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetPetAction(addon.current_hovered_button.pet_action_index)
        GameTooltip:Show()
    else
        -- Hide the GameTooltip if no active slot is found
        GameTooltip:Hide()
    end
end

-- Determines the texture displayed on the button based on the key binding.
function addon:set_key(button)

    -- Reset button state
    addon:reset_button_state(button)

    -- Reset the buttons original icon size
    if button.original_icon_size then
        button.icon:SetSize(button.original_icon_size.width, button.original_icon_size.height)
    else
        button.icon:SetSize(50, 50) -- Fallback
    end

    -- Get the binding string
    local binding = addon:get_binding(button.raw_key)

    -- Store the interface command (Blizzard Interface Commands)
    button.binding = binding

    -- Centralized keybind mapping table
    local keybind_patterns = {

        -- ACTIONBUTTON
        ["^ACTIONBUTTON(%d+)$"] = function(binding, button)
            local slot = tonumber(binding:match("ACTIONBUTTON(%d+)"))
            return addon:process_actionbutton_slot(slot, button)
        end,

        -- MULTIACTIONBARBUTTON
        ["MULTIACTIONBAR(%d+)BUTTON(%d+)"] = function(binding, button)
            local bar, bar_button = binding:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
            if not bar or not bar_button then return end
            return addon:process_multiactionbar_slot(tonumber(bar), tonumber(bar_button), button)
        end,

        -- BONUSACTIONBUTTON
        ["^BONUSACTIONBUTTON(%d+)$"] = function(binding, button)
            return addon:process_pet_action_slot(binding, button)
        end,

        -- SHAPESHIFTBUTTON
        ["^SHAPESHIFTBUTTON(%d+)$"] = function(binding, button)
            local slot = tonumber(binding:match("SHAPESHIFTBUTTON(%d+)"))
            return addon:process_shapeshift_slot(slot, button)
        end,

        -- Spell
        ["^Spell (.+)$"] = function(binding, button)
            local spell_name = binding:match("^Spell (.+)$")
            return addon:process_spell(spell_name, button)
        end,

        -- Macro
        ["^Macro (.+)$"] = function(binding, button)
            local macro_name = binding:match("^Macro (.+)$")
            return addon:process_macro(macro_name, button)
        end,
    }

    --ElvUI
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        keybind_patterns["^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$"] = function(binding, button)
            return addon:process_elvui(binding, button)
        end
    end

    -- Bartender
    if C_AddOns.IsAddOnLoaded("Bartender4") then
        keybind_patterns["^CLICK BT4Button(%d+):Keybind$"] = function(binding, button)
            return addon:process_bartender(binding, button)
        end
    end

    -- Dominos
    if C_AddOns.IsAddOnLoaded("Dominos") then
        keybind_patterns["^DominosActionButton(%d+)$"] = function(binding, button)
            return addon:process_dominos(binding, button)
        end
    end

    -- OPie
    if C_AddOns.IsAddOnLoaded("OPie") then
        keybind_patterns["CLICK ORL_RProxy"] = function(binding, button)
            return addon:process_opie(button)
        end
    end

    -- BindPad
    if C_AddOns.IsAddOnLoaded("BindPad") then
        -- Macro names can include anything; capture everything after "BindPadMacro:"
        keybind_patterns["^CLICK BindPadMacro:(.+)$"] = function(binding, button)
            return addon:process_bindpad(binding, button)
        end

        -- Spell names can also be arbitrary; capture everything after "BindPadKey:SPELL "
        keybind_patterns["^CLICK BindPadKey:SPELL (.+)$"] = function(binding, button)
            return addon:process_bindpad(binding, button)
        end

        -- Item names can be arbitrary; capture everything after "BindPadKey:ITEM "
        keybind_patterns["^CLICK BindPadKey:ITEM (.+)$"] = function(binding, button)
            return addon:process_bindpad(binding, button)
        end
    end

    -- Loop through the keybind patterns and process the binding if the binding is not empty
    if binding ~= "" then

        for pattern, handler in pairs(keybind_patterns) do
            if binding:find(pattern) then
                handler(binding, button)
                break -- Exit loop once a match is found
            end
        end

        -- Check for specific bindings and set the icon
        local specific_bindings = {
            EXTRAACTIONBUTTON1 = 4200126,
            MOVEFORWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_up",
            MOVEBACKWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_down",
            STRAFELEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_left",
            STRAFERIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_right",
            TURNLEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_left",
            TURNRIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_right",
        }

        if specific_bindings[binding] then
            button.icon:SetTexture(specific_bindings[binding])
            button.icon:SetSize(30, 30)
            button.icon:Show()
        end

        -- Handle interface action labels
        addon:create_action_labels(binding, button)
    else
        -- Handle empty bindings if the option is enabled
        if keyui_settings.show_empty_binds then
            addon:update_empty_binds(button)
        end

        -- Highlight the modifier button if it is pressed
        if keyui_settings.listen_to_modifier == true then

            local function highlight_modifier_button(button)
                button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\yellow_bg")
                button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)
                button.highlight:Show()
            end

            if IsLeftAltKeyDown() and button.raw_key == "LALT" then
                highlight_modifier_button(button)
            end
            if IsRightAltKeyDown() and button.raw_key == "RALT" then
                highlight_modifier_button(button)
            end
            if IsLeftControlKeyDown() and button.raw_key == "LCTRL" then
                highlight_modifier_button(button)
            end
            if IsRightControlKeyDown() and button.raw_key == "RCTRL" then
                highlight_modifier_button(button)
            end
            if IsLeftShiftKeyDown() and button.raw_key == "LSHIFT" then
                highlight_modifier_button(button)
            end
            if IsRightShiftKeyDown() and button.raw_key == "RSHIFT" then
                highlight_modifier_button(button)
            end
        end
    end

    -- Update key text at the end
    addon:update_button_key_text(button)
end

-- Resets the button's state
function addon:reset_button_state(button)
    button.slot = nil
    button.active_slot = nil
    button.icon:SetTexture(nil)
    button.icon:Hide()
    button.readable_binding:Hide()
    button.readable_binding:SetText("")
    button.highlight:Hide()
end

-- Retrieves the binding action
function addon:get_binding(raw_key)
    return GetBindingAction(self.current_modifier_string .. (raw_key or ""), true) or ""
end

-- Handles processing for ACTIONBUTTON
function addon:process_actionbutton_slot(slot, button)
    if not slot then return end

    -- Adjust the slot based on bonus bar offset and action bar page
    local adjusted_slot = addon:get_action_button_slot(slot)
    button.slot = adjusted_slot

    -- Check if the slot has an action assigned
    if HasAction(adjusted_slot) then
        button.active_slot = adjusted_slot
        button.icon:SetTexture(GetActionTexture(adjusted_slot))
        button.icon:Show()
    end
end

-- Adjusts the slot for ACTIONBUTTON bindings based on the class, stance, or action bar page
function addon:get_action_button_slot(action_slot)
    if (addon.class_name == "ROGUE" or addon.class_name == "DRUID") and addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
        if addon.bonusbar_offset == 1 then
            return action_slot + 72
        elseif addon.bonusbar_offset == 2 then
            return action_slot + 84
        elseif addon.bonusbar_offset == 3 then
            return action_slot + 96
        elseif addon.bonusbar_offset == 4 then
            return action_slot + 108
        end
    end

    if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then
        return action_slot + 120
    end

    if addon.current_actionbar_page == 2 then
        return action_slot + 12
    elseif addon.current_actionbar_page == 3 then
        return action_slot + 24
    elseif addon.current_actionbar_page == 4 then
        return action_slot + 36
    elseif addon.current_actionbar_page == 5 then
        return action_slot + 48
    elseif addon.current_actionbar_page == 6 then
        return action_slot + 60
    end

    return action_slot -- Default 1-12
end

-- Handles processing for MULTIACTIONBAR
function addon:process_multiactionbar_slot(bar, bar_button, button)
    if not bar or not bar_button then return end

    -- Calculate the slot based on the bar and button
    local slot
    if bar == 0 then
        slot = bar_button
    elseif bar == 1 then
        slot = 60 + bar_button
    elseif bar == 2 then
        slot = 48 + bar_button
    elseif bar == 3 then
        slot = 24 + bar_button
    elseif bar == 4 then
        slot = 36 + bar_button
    elseif bar == 5 then
        slot = 144 + bar_button
    elseif bar == 6 then
        slot = 156 + bar_button
    elseif bar == 7 then
        slot = 168 + bar_button
    else
        return
    end

    button.slot = slot

    -- Check if the slot has an action assigned
    if slot and HasAction(slot) then
        button.active_slot = slot
        button.icon:SetTexture(GetActionTexture(slot))
        button.icon:Show()
    end
end

-- Handles processing for BONUSACTIONBUTTON
function addon:process_pet_action_slot(binding, button)
    if not PetHasActionBar() then
        button.icon:Hide()
        button.slot = nil
        button.spellid = nil
        button.pet_action_index = nil -- Clear pet action index when no pet action bar
        return
    end

    -- Match the button index from the binding
    local pet_action_index = tonumber(binding:match("^BONUSACTIONBUTTON(%d+)$"))
    if not pet_action_index then return end

    -- Get pet action information
    local pet_name, pet_texture, is_token, is_active, auto_cast_allowed, auto_cast_enabled, spell_id =
        GetPetActionInfo(pet_action_index)

    -- Handle the texture if it's a token
    if is_token then
        pet_texture = _G[pet_texture] or "Interface\\Icons\\" .. pet_texture -- Fallback to WoW's icon folder
    end

    if pet_texture then
        button.icon:SetTexture(pet_texture)
        button.icon:Show()

        if spell_id then
            -- Pet spell
            button.slot = nil -- No slot for pet spells
            button.spellid = spell_id
            button.pet_action_index = nil -- Not a pet mode
        else
            -- Pet mode (e.g., Stay, Follow, Move To)
            button.slot = nil
            button.spellid = nil
            button.pet_action_index = pet_action_index -- Set pet action index
        end
    end
end

-- Handles processing for SHAPESHIFTBUTTON bindings
function addon:process_shapeshift_slot(slot, button)
    if not slot then return end

    -- Retrieve information about the shapeshift form
    local icon, is_active, is_castable, spellID = GetShapeshiftFormInfo(slot)

    if icon then
        button.icon:SetTexture(icon)         -- Set the icon texture
        button.icon:Show()                   -- Show the icon
        button.spellid = spellID             -- Store the spell ID
        button.is_active = is_active         -- Track whether the form is active
        button.is_castable = is_castable     -- Track whether the form is castable
    end
end

-- Handles processing for Spell bindings
function addon:process_spell(spell_name, button)
    if not spell_name then return end

    -- Retrieve the spell's icon
    local spell_icon = C_Spell.GetSpellTexture(spell_name)

    if spell_icon then
        button.icon:SetTexture(spell_icon)  -- Set the icon texture
        button.icon:Show()                  -- Show the icon
    end
end

-- Handles processing for Macro bindings
function addon:process_macro(macro_name, button)
    if not macro_name then return end

    -- Retrieve the macro's info
    local name, icon = GetMacroInfo(macro_name)

    if icon then
        button.icon:SetTexture(icon)  -- Set the icon texture
        button.icon:Show()            -- Show the icon
    end
end

-- Handles processing for ElvUI action bar buttons
function addon:process_elvui(binding, button)
    local barIndex, buttonIndex = binding:match("CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton")
    if barIndex and buttonIndex then
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
end

-- Handles processing for Bartender 4 button bindings
function addon:process_bartender(binding, button)
    local bt4_slot = binding:match("CLICK BT4Button(%d+):Keybind")
    button.slot = tonumber(bt4_slot)  -- Set the slot for BT4Button
    if HasAction(button.slot) then
        button.active_slot = button.slot -- Active if there's an action
        button.icon:SetTexture(GetActionTexture(button.slot))
        button.icon:Show()
    end
end

-- Handles processing for Dominos action button bindings
function addon:process_dominos(binding, button)
    local dominos_slot = tonumber(binding:match("DominosActionButton(%d+)"))
    if dominos_slot then
        button.slot = dominos_slot  -- Set the slot for DominosActionButton
        if HasAction(button.slot) then
            button.active_slot = button.slot  -- Mark as active if an action exists for the slot
            local actionTexture = GetActionTexture(button.slot)
            if actionTexture then
                button.icon:SetTexture(actionTexture)  -- Set the action icon
                button.icon:Show()                     -- Show the icon
            end
        end
    end
end

-- Handles processing for OPie ring bindings
function addon:process_opie(button)
    -- Assign the OPie ring icon to the button
    local opie_icon = "Interface\\AddOns\\OPie\\gfx\\opie_ring_icon.tga"
    button.icon:SetTexture(opie_icon)   -- Set the texture to the OPie ring icon
    button.icon:Show()                  -- Display the icon on the button
end

-- Logic for BindPad key bindings
function addon:process_bindpad(binding, button)
    -- Iterate over all BindPad slots to find a matching action
    for slot in BindPadCore.AllSlotInfoIter() do
        -- Check if the slot's action matches the current binding
        if slot.action == binding then

            -- If the slot has a texture, set it on the button icon
            if slot.texture then
                button.icon:SetTexture(slot.texture)
                button.icon:Show()
            end

            break  -- Exit the loop once the matching slot is found
        end
    end
end

-- Determines the text displayed on the button based on the button and binding
function addon:update_button_key_text(button)

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

        -- Check if the button's width or height is 42 or less
        if (button:GetWidth() <= 42) or (button:GetHeight() <= 42) then
            -- Hide the short_key if the button is too small
            button.short_key:Hide()
        else
            -- Adjust the width of the short_key based on the button's width
            button.short_key:SetWidth(button:GetWidth() - 6)
            button.short_key:Show() -- Ensure it is visible if not hidden
        end

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

-- Sets and displays the interface action label
function addon:create_action_labels(binding, button)
    -- Adjust the width of the readable_binding based on button width
    button.readable_binding:SetWidth(button:GetWidth() - 4)

    local binding_name

    -- Check if ElvUI is loaded and handle its bindings
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        if binding:match("^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$") then
            local bar_index, button_index = binding:match("^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$")
            binding_name = "ElvUI ActionBar " .. bar_index .. " Button " .. button_index
        end
    end

    -- Check if Dominos is loaded and handle its bindings
    if C_AddOns.IsAddOnLoaded("Dominos") then
        if binding:match("^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$") then
            local button_index = binding:match("^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$")
            binding_name = "Dominos Action Button " .. button_index
        end
    end

    -- Check if BindPad is loaded and handle its bindings
    if C_AddOns.IsAddOnLoaded("BindPad") then
        if binding:match("^CLICK BindPadMacro:([^:]+)$") then
            local macro_name = binding:match("^CLICK BindPadMacro:([^:]+)$")
            binding_name = "BindPad Macro: " .. macro_name

        elseif binding:match("^CLICK BindPadKey:SPELL (.+)$") then
            local spell_name = binding:match("^CLICK BindPadKey:SPELL (.+)$")
            binding_name = "BindPad Spell: " .. spell_name

        elseif binding:match("^CLICK BindPadKey:ITEM (.+)$") then
            local item_name = binding:match("^CLICK BindPadKey:ITEM (.+)$")
            binding_name = "BindPad Item: " .. item_name
        end
    end

    -- Fallback if no special pattern is matched
    if not binding_name then
        binding_name = _G["BINDING_NAME_" .. binding] or binding
    end

    -- Set the readable binding text
    button.readable_binding:SetText(binding_name)

    -- Show the readable binding if the option is enabled
    if keyui_settings.show_interface_binds then
        button.readable_binding:Show()
    end
end

-- Highlights empty key binds by changing the background color of unused keys.
function addon:update_empty_binds(button)

    -- Check if the key is not on the excluded list
    if not addon.no_highlight[button.raw_key] then  -- Skip keys that are in the excluded list
        button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\red_bg")  -- Apply a red background to indicate empty keys
        button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)  -- Adjust the highlight size to fit the key dimensions with a margin
        button.highlight:Show()  -- Display the highlight for the key
    end
end

-- Updates the textures/texts of the keys bindings.
function addon:refresh_keys()
    --print("refresh_keys function called")  -- print statement for debbuging

    -- if the keyboard is visible we create the keys
    if addon.is_keyboard_visible ~= false then -- true
        -- Set the keys
        for i = 1, #addon.keys_keyboard do
            addon:set_key(addon.keys_keyboard[i])
        end
    end

    -- if the mouse is visible we create the keys
    if addon.is_mouse_visible ~= false then -- true
        for j = 1, #addon.keys_mouse do
            addon:set_key(addon.keys_mouse[j])
        end
    end

    -- if the controller is visible we create the keys
    if addon.is_controller_visible ~= false then -- true
        for k = 1, #addon.keys_controller do
            addon:set_key(addon.keys_controller[k])
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
    LALT = { mod = "ALT", control_key = "alt_cb" },
    RALT = { mod = "ALT", control_key = "alt_cb" },
    LCTRL = { mod = "CTRL", control_key = "ctrl_cb" },
    RCTRL = { mod = "CTRL", control_key = "ctrl_cb" },
    LSHIFT = { mod = "SHIFT", control_key = "shift_cb" },
    RSHIFT = { mod = "SHIFT", control_key = "shift_cb" },
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
                            local binding_name = addon.current_clicked_key.readable_binding:GetText()
                            if addon.current_slot ~= nil then
                                C_Spell.PickupSpell(spell_id)
                                PlaceAction(addon.current_slot)
                                ClearCursor()
                                -- Print notification for new spell binding
                                print("KeyUI: Bound |cffa335ee" .. spell_name .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
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
                        local binding_name = addon.current_clicked_key.readable_binding:GetText()
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            ClearCursor()
                            -- Print notification for new macro binding
                            print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
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
                        local binding_name = addon.current_clicked_key.readable_binding:GetText()
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            ClearCursor()
                            -- Print notification for new macro binding
                            print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
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

StaticPopupDialogs["KEYUI_EXPORT_PROFILE"] = {
    text = "Copy the profile string below to share your KeyUI configuration.",
    button1 = CLOSE,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        local editBox = self.editBox or self.EditBox
        if not editBox then
            return
        end
        local text, err = addon:GetProfileExportString()
        if text then
            editBox:SetText(text)
        else
            editBox:SetText(err or "Failed to generate profile string.")
        end
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        self:ClearFocus()
    end,
}

StaticPopupDialogs["KEYUI_IMPORT_PROFILE"] = {
    text = "Paste a KeyUI profile string to import:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        local editBox = self.editBox or self.EditBox
        if not editBox then
            return
        end
        editBox:SetText("")
        editBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    OnAccept = function(self)
        local editBox = self.editBox or self.EditBox
        local text = editBox and editBox:GetText() or ""
        local ok, err = addon:ImportProfileString(text)
        if not ok then
            print(("KeyUI: Import failed - %s"):format(err or "Unknown error"))
        end
    end,
}

StaticPopupDialogs["KEYUI_EXPORT_LAYOUT"] = {
    text = "Copy the layout string below.",
    button1 = CLOSE,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self, data)
        local editBox = self.editBox or self.EditBox
        if not editBox then
            return
        end

        local layout_label = data and layout_type_labels[data.layoutType] or "KeyUI"
        local layout_name = data and data.name or "Layout"
        if self.text then
            self.text:SetFormattedText("Copy the %s layout '%s' string below:", layout_label, layout_name)
        end

        editBox:SetText(data and data.payload or "Failed to build layout string.")
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        self:ClearFocus()
    end,
}

StaticPopupDialogs["KEYUI_IMPORT_LAYOUT"] = {
    text = "Paste a layout string below:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self, data)
        local editBox = self.editBox or self.EditBox
        if not editBox then
            return
        end

        local layout_label = data and layout_type_labels[data.layoutType] or "KeyUI"
        if self.text then
            self.text:SetFormattedText("Paste a %s layout string to import:", layout_label)
        end

        editBox:SetText("")
        editBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    OnAccept = function(self, data)
        local editBox = self.editBox or self.EditBox
        local text = editBox and editBox:GetText() or ""
        local layout_type = data and data.layoutType or "keyboard"
        local ok, err = addon:ImportLayoutString(layout_type, text)
        if not ok then
            print(("KeyUI: Layout import failed - %s"):format(err or "Unknown error"))
        end
    end,
}

StaticPopupDialogs["KEYUI_LAYOUT_RENAME"] = {
    text = "Enter a new name for this layout:",
    button1 = SAVE,
    button2 = CANCEL,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self, data)
        local editBox = self.editBox or self.EditBox
        if not editBox then return end
        editBox:SetText(data and data.layoutName or "")
        editBox:HighlightText()
        editBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    OnAccept = function(self, data)
        local editBox = self.editBox or self.EditBox
        local new_name = editBox and editBox:GetText() or ""
        local layout_type = data and data.layoutType or "keyboard"
        local old_name = data and data.layoutName or ""
        local ok, err = addon:RenameLayout(layout_type, old_name, new_name)
        if not ok then
            print(("KeyUI: Unable to rename layout - %s"):format(err or "Unknown error"))
        else
            self:Hide()
        end
    end,
}

StaticPopupDialogs["KEYUI_LAYOUT_COPY"] = {
    text = "Enter a name for the copied layout:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self, data)
        local editBox = self.editBox or self.EditBox
        if not editBox then return end
        local base = data and data.layoutName and (data.layoutName .. " Copy") or "New Layout"
        local layout_type = data and data.layoutType or "keyboard"
        local container = get_layout_container(layout_type) or {}
        local suggestion = ensure_unique_layout_name(container, sanitize_layout_name(base))
        editBox:SetText(suggestion)
        editBox:HighlightText()
        editBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    OnAccept = function(self, data)
        local editBox = self.editBox or self.EditBox
        local new_name = editBox and editBox:GetText() or ""
        local layout_type = data and data.layoutType or "keyboard"
        local source_name = data and data.layoutName or ""
        local ok, err = addon:CopyLayout(layout_type, source_name, new_name)
        if not ok then
            print(("KeyUI: Unable to copy layout - %s"):format(err or "Unknown error"))
        else
            self:Hide()
        end
    end,
}


--------------------------------------------------------------------------------------------------------------------

-- button.binding           -- Stores the binding name (e.g., MOVEFORWARD, ACTIONBUTTON1, OPENCHAT, ...)
-- Can be translated to a readable format via _G["BINDING_NAME_" ...]

-- button.readable_binding  -- Displays the readable binding text in the center of the button when toggled on

-- button.raw_key           -- Stores the raw key name (e.g., A, B, C, ESCAPE, PRINTSCREEN, ...)
-- Can be made readable via _G["KEY_" ...]

-- button.short_key         -- Displays the abbreviated key name with short modifiers in the top-right of the button

-- button.slot              -- Stores the action slot ID associated with the binding, regardless of action presence

-- button.active_slot       -- Holds the action slot ID only if the slot contains an active action, otherwise nil

-- button.icon              -- Stores the icon texture ID for the action slot
