local _, addon = ...

local MAX_LAYOUT_NAME_LENGTH = 120
local MAX_LAYOUT_ENTRIES = 600
local MAX_LAYOUT_ABS_COORD = 10000
local MAX_LAYOUT_DIMENSION = 4000

local VALID_LAYOUT_TYPES = {
    keyboard = true,
    mouse = true,
    controller = true,
}

local CONTROLLER_LAYOUT_TYPES = {
    generic = true,
    xbox = true,
    ds4 = true,
    ds5 = true,
    deck = true,
}

local function trim(value)
    if type(value) ~= "string" then
        return ""
    end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalize_bool(settings, key, default)
    if settings[key] == nil then
        settings[key] = default
    elseif type(settings[key]) ~= "boolean" then
        settings[key] = default
    end
end

local function normalize_number(settings, key, default, min_value, max_value)
    local value = settings[key]
    if type(value) ~= "number" then
        value = default
    end
    if min_value and value < min_value then
        value = min_value
    end
    if max_value and value > max_value then
        value = max_value
    end
    settings[key] = value
end

local function normalize_table(settings, key)
    if type(settings[key]) ~= "table" then
        settings[key] = {}
    end
end

local function validate_keybind_settings(settings, key)
    local bucket = settings[key]
    if bucket == nil then
        return true
    end
    if type(bucket) ~= "table" then
        return false, ("Invalid settings bucket '%s'."):format(key)
    end
    if bucket.currentboard ~= nil and type(bucket.currentboard) ~= "string" then
        return false, ("Invalid currentboard type in '%s'."):format(key)
    end
    return true
end

function addon:NormalizeSettingTypes(settings)
    if type(settings) ~= "table" then
        return false, "Settings payload is invalid."
    end

    normalize_bool(settings, "show_keyboard", false)
    normalize_bool(settings, "show_mouse", false)
    normalize_bool(settings, "show_controller", false)
    normalize_bool(settings, "show_keyboard_background", true)
    normalize_bool(settings, "show_mouse_graphic", true)
    normalize_bool(settings, "show_controller_background", true)
    normalize_bool(settings, "stay_open_in_combat", false)
    normalize_bool(settings, "show_pushed_texture", true)
    normalize_bool(settings, "close_on_esc", true)
    normalize_bool(settings, "show_empty_binds", false)
    normalize_bool(settings, "show_interface_binds", false)
    normalize_bool(settings, "tutorial_completed", false)
    normalize_bool(settings, "listen_to_modifier", true)
    normalize_bool(settings, "dynamic_modifier", false)
    normalize_bool(settings, "controls_expanded", false)
    normalize_bool(settings, "show_keypress_highlight", true)
    normalize_bool(settings, "show_actionbar_mode", true)
    normalize_bool(settings, "position_locked", false)
    normalize_bool(settings, "click_through", false)
    normalize_bool(settings, "performance_debug", false)

    normalize_number(settings, "font_base_size", 16, 10, 24)

    if type(settings.font_face) ~= "string" or settings.font_face == "" then
        settings.font_face = "Expressway"
    end

    normalize_table(settings, "keyboard_position")
    normalize_table(settings, "mouse_position")
    normalize_table(settings, "controller_position")
    normalize_table(settings, "layout_current_keyboard")
    normalize_table(settings, "layout_current_mouse")
    normalize_table(settings, "layout_current_controller")
    normalize_table(settings, "layout_edited_keyboard")
    normalize_table(settings, "layout_edited_mouse")
    normalize_table(settings, "layout_edited_controller")
    normalize_table(settings, "key_bind_settings_keyboard")
    normalize_table(settings, "key_bind_settings_mouse")
    normalize_table(settings, "key_bind_settings_controller")

    if type(settings.minimap) ~= "table" then
        settings.minimap = {}
    end
    normalize_bool(settings.minimap, "hide", false)

    local schema_version = settings.schema_version
    if type(schema_version) ~= "number" then
        schema_version = 0
    end
    if schema_version > addon.SETTINGS_SCHEMA_VERSION then
        return false, "Settings schema is newer than this addon version."
    end
    settings.schema_version = addon.SETTINGS_SCHEMA_VERSION

    return true
end

function addon:ValidateLayoutData(layout_type, layout_data)
    if not VALID_LAYOUT_TYPES[layout_type] then
        return false, "Unsupported layout type."
    end

    if type(layout_data) ~= "table" then
        return false, "Layout data must be a table."
    end

    local entry_count = 0
    for index, row in ipairs(layout_data) do
        entry_count = entry_count + 1
        if entry_count > MAX_LAYOUT_ENTRIES then
            return false, "Layout has too many entries."
        end
        if type(row) ~= "table" then
            return false, ("Layout entry %d must be a table."):format(index)
        end

        local key = row[1]
        local x = row[2]
        local y = row[3]
        local width = row[4]
        local height = row[5]

        if type(key) ~= "string" then
            return false, ("Layout entry %d has invalid key label."):format(index)
        end
        if type(x) ~= "number" or type(y) ~= "number" then
            return false, ("Layout entry %d has invalid coordinates."):format(index)
        end
        if math.abs(x) > MAX_LAYOUT_ABS_COORD or math.abs(y) > MAX_LAYOUT_ABS_COORD then
            return false, ("Layout entry %d coordinates exceed bounds."):format(index)
        end

        if type(width) ~= "number" or type(height) ~= "number" then
            return false, ("Layout entry %d has invalid dimensions."):format(index)
        end
        if width <= 0 or height <= 0 or width > MAX_LAYOUT_DIMENSION or height > MAX_LAYOUT_DIMENSION then
            return false, ("Layout entry %d dimensions exceed bounds."):format(index)
        end

        if layout_type == "keyboard" then
            local icon_width = row[6]
            local icon_height = row[7]
            if icon_width ~= nil and (type(icon_width) ~= "number" or icon_width <= 0 or icon_width > MAX_LAYOUT_DIMENSION) then
                return false, ("Keyboard layout entry %d has invalid icon width."):format(index)
            end
            if icon_height ~= nil and (type(icon_height) ~= "number" or icon_height <= 0 or icon_height > MAX_LAYOUT_DIMENSION) then
                return false, ("Keyboard layout entry %d has invalid icon height."):format(index)
            end
        end
    end

    if layout_type == "controller" then
        local controller_type = layout_data.layout_type
        if controller_type ~= nil then
            if type(controller_type) ~= "string" or not CONTROLLER_LAYOUT_TYPES[controller_type] then
                return false, "Controller layout_type is invalid."
            end
        end
    end

    return true
end

local function validate_layout_bucket(settings, layout_type, key)
    local bucket = settings[key]
    if bucket == nil then
        return true
    end
    if type(bucket) ~= "table" then
        return false, ("Layout bucket '%s' is invalid."):format(key)
    end

    for name, layout_data in pairs(bucket) do
        local normalized_name = trim(name)
        if normalized_name == "" then
            return false, ("Layout in '%s' has empty name."):format(key)
        end
        if #normalized_name > MAX_LAYOUT_NAME_LENGTH then
            return false, ("Layout name in '%s' is too long."):format(key)
        end

        local ok, err = addon:ValidateLayoutData(layout_type, layout_data)
        if not ok then
            return false, ("Layout '%s' in '%s' is invalid: %s"):format(normalized_name, key, err)
        end
    end

    return true
end

function addon:ValidateProfileSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false, "Invalid profile data."
    end

    if type(snapshot.version) ~= "number" then
        return false, "Profile version is invalid."
    end

    if snapshot.schemaVersion ~= nil and type(snapshot.schemaVersion) ~= "number" then
        return false, "Profile schema version is invalid."
    end

    if type(snapshot.settings) ~= "table" then
        return false, "Profile missing settings data."
    end

    local settings = snapshot.settings
    local ok, err = self:NormalizeSettingTypes(settings)
    if not ok then
        return false, err
    end

    ok, err = validate_keybind_settings(settings, "key_bind_settings_keyboard")
    if not ok then return false, err end
    ok, err = validate_keybind_settings(settings, "key_bind_settings_mouse")
    if not ok then return false, err end
    ok, err = validate_keybind_settings(settings, "key_bind_settings_controller")
    if not ok then return false, err end

    ok, err = validate_layout_bucket(settings, "keyboard", "layout_edited_keyboard")
    if not ok then return false, err end
    ok, err = validate_layout_bucket(settings, "mouse", "layout_edited_mouse")
    if not ok then return false, err end
    ok, err = validate_layout_bucket(settings, "controller", "layout_edited_controller")
    if not ok then return false, err end
    ok, err = validate_layout_bucket(settings, "keyboard", "layout_current_keyboard")
    if not ok then return false, err end
    ok, err = validate_layout_bucket(settings, "mouse", "layout_current_mouse")
    if not ok then return false, err end
    ok, err = validate_layout_bucket(settings, "controller", "layout_current_controller")
    if not ok then return false, err end

    return true
end

function addon:ValidateLayoutPayload(payload)
    if type(payload) ~= "table" then
        return false, "Layout payload malformed."
    end
    if type(payload.layoutType) ~= "string" then
        return false, "Layout type missing."
    end
    if not VALID_LAYOUT_TYPES[payload.layoutType] then
        return false, "Unsupported layout type."
    end
    if type(payload.layout) ~= "table" then
        return false, "Layout data missing."
    end

    local name = payload.name
    if name ~= nil then
        local normalized_name = trim(name)
        if normalized_name == "" then
            return false, "Layout name cannot be empty."
        end
        if #normalized_name > MAX_LAYOUT_NAME_LENGTH then
            return false, "Layout name is too long."
        end
        payload.name = normalized_name
    end

    return self:ValidateLayoutData(payload.layoutType, payload.layout)
end
