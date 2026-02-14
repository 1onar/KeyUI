local name, addon = ...

-- Initialize SavedVariables for KeyUI settings
keyui_settings = keyui_settings or {}

local function set_if_nil(setting, default)
    if keyui_settings[setting] == nil then
        keyui_settings[setting] = default
    end
end

local VALID_SPEC_ACTION_RESTORE_MODE = {
    safe_auto = true,
    bindings_only = true,
    force = true,
}

local function sanitize_slot_payload(payload)
    if type(payload) ~= "table" then
        return nil
    end

    local payload_type = payload.type
    if payload_type == "spell" and type(payload.spellID) == "number" then
        return {
            type = "spell",
            spellID = payload.spellID,
        }
    end

    if payload_type == "macro" and type(payload.macroName) == "string" and payload.macroName ~= "" then
        return {
            type = "macro",
            macroName = payload.macroName,
        }
    end

    if payload_type == "item" and type(payload.itemID) == "number" then
        return {
            type = "item",
            itemID = payload.itemID,
        }
    end

    if payload_type == "empty" then
        return {
            type = "empty",
        }
    end

    return nil
end

local function sanitize_spec_profiles()
    if type(keyui_settings.spec_profiles) ~= "table" then
        keyui_settings.spec_profiles = {}
    end

    local profiles = keyui_settings.spec_profiles
    if type(profiles.by_character) ~= "table" then
        profiles.by_character = {}
    end

    for character_key, store in pairs(profiles.by_character) do
        if type(character_key) ~= "string" or type(store) ~= "table" then
            profiles.by_character[character_key] = nil
        else
            if type(store.last_spec_key) ~= "string" then
                store.last_spec_key = nil
            end
            if type(store.specs) ~= "table" then
                store.specs = {}
            end

            for spec_key, snapshot in pairs(store.specs) do
                if type(spec_key) ~= "string" or type(snapshot) ~= "table" then
                    store.specs[spec_key] = nil
                else
                    if type(snapshot.bindings) ~= "table" then
                        snapshot.bindings = {}
                    end
                    for binding_key, command in pairs(snapshot.bindings) do
                        if type(binding_key) ~= "string" or type(command) ~= "string" or binding_key == "" or command == "" then
                            snapshot.bindings[binding_key] = nil
                        end
                    end

                    if type(snapshot.slots) ~= "table" then
                        snapshot.slots = {}
                    end
                    for slot, payload in pairs(snapshot.slots) do
                        local normalized_slot = tonumber(slot)
                        local sanitized_payload = sanitize_slot_payload(payload)
                        if not normalized_slot or normalized_slot <= 0 or normalized_slot % 1 ~= 0 or not sanitized_payload then
                            snapshot.slots[slot] = nil
                        elseif normalized_slot ~= slot then
                            snapshot.slots[slot] = nil
                            snapshot.slots[normalized_slot] = sanitized_payload
                        else
                            snapshot.slots[slot] = sanitized_payload
                        end
                    end

                    if type(snapshot.ts) ~= "number" then
                        snapshot.ts = time()
                    end
                end
            end
        end
    end
end

-- Initialize general settings with default values if they are nil
function addon:InitializeGeneralSettings()
    -- Migrate old setting to new name
    if keyui_settings.prevent_esc_close ~= nil then
        keyui_settings.close_on_esc = not keyui_settings.prevent_esc_close
        keyui_settings.prevent_esc_close = nil
    end

    set_if_nil("show_keyboard", false)
    set_if_nil("show_mouse", false)
    set_if_nil("show_controller", false)
    set_if_nil("show_keyboard_background", true)
    set_if_nil("show_mouse_graphic", true)
    set_if_nil("show_controller_background", true)
    set_if_nil("stay_open_in_combat", false)
    set_if_nil("show_pushed_texture", true)
    set_if_nil("close_on_esc", true)
    set_if_nil("keyboard_position", {})
    set_if_nil("mouse_position", {})
    set_if_nil("controller_position", {})
    set_if_nil("minimap", { hide = false })
    set_if_nil("show_empty_binds", false)
    set_if_nil("show_interface_binds", false)
    set_if_nil("tutorial_completed", false)
    set_if_nil("listen_to_modifier", true)
    set_if_nil("dynamic_modifier", false)
    set_if_nil("controls_expanded", false)
    set_if_nil("font_face", "Expressway")
    set_if_nil("font_base_size", 16)
    set_if_nil("show_keypress_highlight", true)
    set_if_nil("position_locked", false)
    set_if_nil("click_through", false)
    set_if_nil("spec_auto_swap", false)
    set_if_nil("spec_action_restore_mode", "safe_auto")
    set_if_nil("spec_profiles_version", 1)
    set_if_nil("spec_profiles", { by_character = {} })
    set_if_nil("spec_feature_explained", false)

    if not VALID_SPEC_ACTION_RESTORE_MODE[keyui_settings.spec_action_restore_mode] then
        keyui_settings.spec_action_restore_mode = "safe_auto"
    end
    if type(keyui_settings.spec_auto_swap) ~= "boolean" then
        keyui_settings.spec_auto_swap = false
    end
    if type(keyui_settings.spec_feature_explained) ~= "boolean" then
        keyui_settings.spec_feature_explained = false
    end
    if type(keyui_settings.spec_profiles_version) ~= "number" then
        keyui_settings.spec_profiles_version = 1
    end
    sanitize_spec_profiles()
end

-- Initialize key binding and layout settings
function addon:InitializeKeyBindSettings()
    keyui_settings.key_bind_settings_keyboard = keyui_settings.key_bind_settings_keyboard or {}
    keyui_settings.key_bind_settings_mouse = keyui_settings.key_bind_settings_mouse or {}
    keyui_settings.key_bind_settings_controller = keyui_settings.key_bind_settings_controller or {}
    keyui_settings.layout_current_keyboard = keyui_settings.layout_current_keyboard or {}
    keyui_settings.layout_current_mouse = keyui_settings.layout_current_mouse or {}
    keyui_settings.layout_current_controller = keyui_settings.layout_current_controller or {}
    keyui_settings.layout_edited_keyboard = keyui_settings.layout_edited_keyboard or {}
    keyui_settings.layout_edited_mouse = keyui_settings.layout_edited_mouse or {}
    keyui_settings.layout_edited_controller = keyui_settings.layout_edited_controller or {}
end

-- Initialize all settings
function addon:InitializeSettings()
    self:InitializeGeneralSettings()
    self:InitializeKeyBindSettings()
end

-- Initialize global variables
addon.keys_keyboard = {}
addon.keys_mouse = {}
addon.keys_controller = {}

addon.keyboard_locked = true
addon.mouse_locked = true
addon.controller_locked = true

addon.keys_keyboard_edited = false
addon.keys_mouse_edited = false
addon.keys_controller_edited = false

addon.controller_system = nil

addon.open = false
addon.in_combat = false
addon.retail_action_block_warned_this_combat = false

addon.bonusbar_offset = {}
addon.current_actionbar_page = {}
addon.class_name = {}

addon.modif = addon.modif or { ALT = false, CTRL = false, SHIFT = false }
addon.current_modifier_string = ""
addon.alt_checkbox = false
addon.ctrl_checkbox = false
addon.shift_checkbox = false

addon.active_control_tab = ""

addon.tutorial_frame1_created = false
addon.tutorial_frame2_created = false

addon.keyboard_layout_dirty = false
addon.mouse_layout_dirty = false
addon.controller_layout_dirty = false
addon.deferred_ui_updates = addon.deferred_ui_updates or {
    refresh_layouts = false,
    apply_click_through = false,
}
addon.spec_snapshot_apply_in_progress = false
addon.spec_capture_pending = false
addon.spec_capture_timer_active = false
addon.spec_pending_apply_key = nil
addon.spec_last_switch_key = nil
addon.spec_last_switch_at = 0

-- Spellbook data (loaded on demand via load_spellbook)
addon.spells = {}

-- Font system
addon.FONT_OPTIONS = {
    ["Expressway"] = {
        regular = "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Regular.TTF",
        condensed = "Interface\\AddOns\\KeyUI\\Media\\Fonts\\Expressway Condensed.TTF",
    },
    ["System Default"] = {
        regular = STANDARD_TEXT_FONT,
        condensed = STANDARD_TEXT_FONT,
    },
    ["Friz Quadrata"] = {
        regular = "Fonts\\FRIZQT__.TTF",
        condensed = "Fonts\\FRIZQT__.TTF",
    },
    ["Arial Narrow"] = {
        regular = "Fonts\\ARIALN.TTF",
        condensed = "Fonts\\ARIALN.TTF",
    },
    ["Morpheus"] = {
        regular = "Fonts\\MORPHEUS.TTF",
        condensed = "Fonts\\MORPHEUS.TTF",
    },
    ["Skurri"] = {
        regular = "Fonts\\SKURRI.TTF",
        condensed = "Fonts\\SKURRI.TTF",
    },
}

addon.FONT_OPTIONS_ORDER = { "Expressway", "System Default", "Friz Quadrata", "Arial Narrow", "Morpheus", "Skurri" }

function addon:GetFont()
    local entry = self.FONT_OPTIONS[keyui_settings.font_face]
    return entry and entry.regular or self.FONT_OPTIONS["Expressway"].regular
end

function addon:GetCondensedFont()
    local entry = self.FONT_OPTIONS[keyui_settings.font_face]
    return entry and entry.condensed or self.FONT_OPTIONS["Expressway"].condensed
end

function addon:GetFontSize(ratio)
    return math.floor((keyui_settings.font_base_size or 16) * ratio + 0.5)
end

addon._fontRegistry = {}

function addon:RegisterFontString(fontString, ratio, isCondensed, flags)
    table.insert(self._fontRegistry, {
        obj = fontString,
        ratio = ratio,
        condensed = isCondensed or false,
        flags = flags,
    })
end

function addon:RefreshAllFonts()
    for _, entry in ipairs(self._fontRegistry) do
        local path = entry.condensed and self:GetCondensedFont() or self:GetFont()
        local size = self:GetFontSize(entry.ratio)
        entry.obj:SetFont(path, size, entry.flags or "")
    end

    if self.keyboard_frame and self.keyboard_frame.RefreshLayout then
        self.keyboard_frame:RefreshLayout()
    end
    if self.mouse_frame and self.mouse_frame.RefreshLayout then
        self.mouse_frame:RefreshLayout()
    end
    if self.controller_frame and self.controller_frame.RefreshLayout then
        self.controller_frame:RefreshLayout()
    end
end
