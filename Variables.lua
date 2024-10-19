-- Initialize SavedVariables for KeyUI settings
keyui_settings = keyui_settings or {}

local name, addon = ...

local function set_if_nil(setting, default)
    if keyui_settings[setting] == nil then
        keyui_settings[setting] = default
    end
end

-- Initialize SavedVariables
function addon:InitializeSettings()
    -- Set default values only if they are nil
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

    -- Initialize other SavedVariables
    key_bind_settings_keyboard = key_bind_settings_keyboard or {}
    key_bind_settings_mouse = key_bind_settings_mouse or {}
    layout_current_keyboard = layout_current_keyboard or {}
    layout_current_mouse = layout_current_mouse or {}
    layout_edited_keyboard = layout_edited_keyboard or {}
    layout_edited_mouse = layout_edited_mouse or {}
end

-- Initialize global variables
addon.keys_keyboard = {}
addon.keys_mouse = {}
addon.keyboard_locked = true
addon.mouse_locked = true
addon.alt_checkbox = false
addon.ctrl_checkbox = false
addon.shift_checkbox = false
addon.keys_edited = false
addon.open = false
addon.in_combat = false
