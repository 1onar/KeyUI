-- Initialize SavedVariables for KeyUI settings and ensure all settings are present
KeyUI_Settings = KeyUI_Settings or {}

-- Ensure each setting is initialized if it doesn't exist
KeyUI_Settings.show_keyboard = KeyUI_Settings.show_keyboard or true
KeyUI_Settings.show_mouse = KeyUI_Settings.show_mouse or true
KeyUI_Settings.stay_open_in_combat = KeyUI_Settings.stay_open_in_combat or true
KeyUI_Settings.show_pushed_texture = KeyUI_Settings.show_pushed_texture or true
KeyUI_Settings.prevent_esc_close = KeyUI_Settings.prevent_esc_close or true
KeyUI_Settings.keyboard_position = KeyUI_Settings.keyboard_position or {}
KeyUI_Settings.mouse_position = KeyUI_Settings.mouse_position or {}
KeyUI_Settings.minimap = KeyUI_Settings.minimap or { hide = false }
KeyUI_Settings.show_empty_binds = KeyUI_Settings.show_empty_binds or false
KeyUI_Settings.show_interface_binds = KeyUI_Settings.show_interface_binds or false
KeyUI_Settings.tutorial_completed = KeyUI_Settings.tutorial_completed or false

-- Initialize SavedVariables
KeyBindSettings = KeyBindSettings or {}
KeyBindSettingsMouse = KeyBindSettingsMouse or {}
CurrentLayoutMouse = CurrentLayoutMouse or {}
CurrentLayoutKeyboard = CurrentLayoutKeyboard or {}
MouseKeyEditLayouts = MouseKeyEditLayouts or {}
KeyboardEditLayouts = KeyboardEditLayouts or {}

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