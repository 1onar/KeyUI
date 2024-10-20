local name, addon = ...

-- Initialize SavedVariables for KeyUI settings
keyui_settings = keyui_settings or {}

local function set_if_nil(setting, default)
    if keyui_settings[setting] == nil then
        keyui_settings[setting] = default
    end
end

-- Initialize general settings with default values if they are nil
function addon:InitializeGeneralSettings()
    set_if_nil("show_keyboard", true)
    set_if_nil("show_mouse", true)
    set_if_nil("stay_open_in_combat", true)
    set_if_nil("show_pushed_texture", true)
    set_if_nil("prevent_esc_close", true)
    set_if_nil("keyboard_position", {})
    set_if_nil("mouse_position", {})
    set_if_nil("minimap", { hide = false })
    set_if_nil("show_empty_binds", false)
    set_if_nil("show_interface_binds", false)
    set_if_nil("tutorial_completed", false)
end

-- Initialize key binding and layout settings
function addon:InitializeKeyBindSettings()
    keyui_settings.key_bind_settings_keyboard = keyui_settings.key_bind_settings_keyboard or {}
    keyui_settings.key_bind_settings_mouse = keyui_settings.key_bind_settings_mouse or {}
    keyui_settings.layout_current_keyboard = keyui_settings.layout_current_keyboard or {}
    keyui_settings.layout_current_mouse = keyui_settings.layout_current_mouse or {}
    keyui_settings.layout_edited_keyboard = keyui_settings.layout_edited_keyboard or {}
    keyui_settings.layout_edited_mouse = keyui_settings.layout_edited_mouse or {}
end

-- Initialize all settings
function addon:InitializeSettings()
    self:InitializeGeneralSettings()
    self:InitializeKeyBindSettings()
end

-- Initialize global variables
addon.keys_keyboard = {}
addon.keys_mouse = {}
addon.keyboard_locked = true
addon.mouse_locked = true
addon.alt_checkbox = false
addon.ctrl_checkbox = false
addon.shift_checkbox = false
addon.keys_keyboard_edited = false
addon.keys_mouse_edited = false
addon.open = false
addon.in_combat = false
addon.bonusbar_offset = {}
addon.current_actionbar_page = {}
addon.class_name = {}