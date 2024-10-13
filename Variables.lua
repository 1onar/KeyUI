-- Initialize SavedVariables for KeyUI settings
KeyUI_Settings = KeyUI_Settings or {}

local name, addon = ...

local function set_if_nil(setting, default)
    if KeyUI_Settings[setting] == nil then
        KeyUI_Settings[setting] = default
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
    KeyBindSettings = KeyBindSettings or {}
    KeyBindSettingsMouse = KeyBindSettingsMouse or {}
    CurrentLayoutMouse = CurrentLayoutMouse or {}
    CurrentLayoutKeyboard = CurrentLayoutKeyboard or {}
    MouseKeyEditLayouts = MouseKeyEditLayouts or {}
    KeyboardEditLayouts = KeyboardEditLayouts or {}
end

-- Initialize global variables
Keys = {}
KeysMouse = {}
MousePosition = {}
KeyboardLocked = true
AltCheckbox = false
CtrlCheckbox = false
ShiftCheckbox = false
MouseLocked = true
edited = false
addonOpen = false
fighting = false