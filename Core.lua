local name, addon = ...

-- Initialize libraries
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
local LDB = LibStub("LibDataBroker-1.1")

local PROFILE_EXPORT_VERSION = 1
local LAYOUT_EXPORT_VERSION = 1
local UI_CONSTANTS = addon.UI_CONSTANTS or {
    controls_height_collapsed = 200,
    controls_height_expanded = 400,
}
addon.UI_CONSTANTS = UI_CONSTANTS
addon.key_button_pools = addon.key_button_pools or {
    keyboard = {},
    mouse = {},
    controller = {},
}

-- ============================================================================
-- API Compatibility Layer
-- ============================================================================
local API_COMPAT = {
    has_modern_spellbook = (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines ~= nil),
    has_legacy_spell_api = (_G.GetSpellBookItemInfo ~= nil and _G.GetNumSpellTabs ~= nil),
    has_assisted_combat = (C_AssistedCombat and C_AssistedCombat.IsAvailable ~= nil),
    has_actionbar_getspell = (C_ActionBar and C_ActionBar.GetSpell ~= nil),
    has_modern_action_cooldown = (C_ActionBar and C_ActionBar.GetActionCooldown ~= nil),
    has_modern_spell_cooldown  = (C_Spell and C_Spell.GetSpellCooldown ~= nil),
    has_modern_action_usable   = (C_ActionBar and C_ActionBar.IsUsableAction ~= nil),
    has_modern_action_in_range = (C_ActionBar and C_ActionBar.IsActionInRange ~= nil),
    has_modern_display_count   = (C_ActionBar and C_ActionBar.GetActionDisplayCount ~= nil),
    has_modern_action_charges  = (C_ActionBar and C_ActionBar.GetActionCharges ~= nil),
}
addon.api_compat = API_COMPAT
addon.compat = addon.compat or {}

do
    local compat_build = (addon.VERSION and addon.VERSION.build) or select(4, GetBuildInfo()) or 0

    function addon.compat.is_addon_loaded(addon_name)
        if C_AddOns and C_AddOns.IsAddOnLoaded then
            local _, loaded = C_AddOns.IsAddOnLoaded(addon_name)
            return loaded == true
        end
        if IsAddOnLoaded then
            return IsAddOnLoaded(addon_name)
        end
        return false
    end

    function addon.compat.has_event(event_name)
        if event_name == "BINDINGS_LOADED" then
            -- BINDINGS_LOADED exists in Anniversary (2.5.x) and Retail (10+/11+/12+)
            return (compat_build >= 20500 and compat_build < 30000) or compat_build >= 100000
        end
        return true
    end

    function addon.compat.register_event(frame, event_name)
        if not frame or not event_name then
            return false
        end
        if addon.compat.has_event(event_name) then
            frame:RegisterEvent(event_name)
            return true
        end
        return false
    end
end

-- Global keybind patterns cache (initialized on load)
local keybind_patterns = {}

-- Initialize keybind patterns with addon integrations
-- Addon integration patterns, registered dynamically when addons are loaded
local registered_addons = {}
addon.loaded_integrations = addon.loaded_integrations or {}

local addon_pattern_registry = {
    ElvUI = {
        { pattern = "^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$", handler = "process_elvui", error_prefix = "KeyUI: ElvUI integration error:" },
        { pattern = "^ELVUIBAR(%d+)BUTTON(%d+)$", handler = "process_elvui", error_prefix = "KeyUI: ElvUI integration error:" },
    },
    Bartender4 = {
        { pattern = "^CLICK BT4StanceButton(%d+):LeftButton$", handler = "process_addon_stance", error_prefix = "KeyUI: Bartender4 stance integration error:" },
        { pattern = "^CLICK BT4Button(%d+):Keybind$", handler = "process_bartender", error_prefix = "KeyUI: Bartender4 integration error:" },
    },
    Dominos = {
        { pattern = "^CLICK DominosActionButton(%d+):HOTKEY$", handler = "process_dominos", error_prefix = "KeyUI: Dominos integration error:" },
        { pattern = "^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$", handler = "process_dominos", error_prefix = "KeyUI: Dominos integration error:" },
    },
    OPie = {
        { pattern = "^CLICK ORL_RProxy.*$", handler = "process_opie", pass_binding = false, error_prefix = "KeyUI: OPie integration error:" },
    },
    BindPad = {
        { pattern = "^CLICK BindPadMacro:(.+)$", handler = "process_bindpad", error_prefix = "KeyUI: BindPad integration error:" },
        { pattern = "^CLICK BindPadKey:SPELL (.+)$", handler = "process_bindpad", error_prefix = "KeyUI: BindPad integration error:" },
        { pattern = "^CLICK BindPadKey:ITEM (.+)$", handler = "process_bindpad", error_prefix = "KeyUI: BindPad integration error:" },
        { pattern = "^CLICK BindPadKey:MACRO (.+)$", handler = "process_bindpad", error_prefix = "KeyUI: BindPad integration error:" },
    },
}

local function refresh_loaded_integrations()
    addon.loaded_integrations = addon.loaded_integrations or {}
    for addon_name in pairs(addon_pattern_registry) do
        addon.loaded_integrations[addon_name] = addon.compat.is_addon_loaded(addon_name)
    end
end

-- Registers patterns for a supported addon if it is loaded and not yet registered
local function register_addon_patterns(addon_name)
    if registered_addons[addon_name] then return end
    local specs = addon_pattern_registry[addon_name]
    if specs and addon.compat.is_addon_loaded(addon_name) then
        for _, spec in ipairs(specs) do
            keybind_patterns[spec.pattern] = function(binding, button)
                local method = addon[spec.handler]
                if type(method) ~= "function" then
                    return
                end

                local success, err
                if spec.pass_binding == false then
                    success, err = pcall(method, addon, button)
                else
                    success, err = pcall(method, addon, binding, button)
                end

                if not success then
                    print(spec.error_prefix or "KeyUI: Integration error:", err)
                end
            end
        end
        registered_addons[addon_name] = true
        addon.loaded_integrations[addon_name] = true
    end
end

local function initialize_keybind_patterns()
    keybind_patterns = {
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

    -- Register patterns for any supported addons already loaded
    for addon_name in pairs(addon_pattern_registry) do
        register_addon_patterns(addon_name)
    end
end

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

function addon:IsPerformanceDebugEnabled()
    return type(keyui_settings) == "table" and keyui_settings.performance_debug == true
end

function addon:DebugLog(prefix, message)
    if not self:IsPerformanceDebugEnabled() then
        return
    end
    if type(message) ~= "string" then
        message = tostring(message)
    end
    print(("KeyUI[%s]: %s"):format(prefix or "debug", message))
end

function addon:AcquireKeyButton(device, index)
    local pools = self.key_button_pools
    if type(pools) ~= "table" then
        return nil
    end

    local pool = pools[device]
    if type(pool) ~= "table" then
        return nil
    end

    local button = pool[index]
    if button then
        return button
    end

    local create_method = self["create_" .. device .. "_buttons"]
    if type(create_method) ~= "function" then
        return nil
    end

    button = create_method(self)
    pool[index] = button

    if self:IsPerformanceDebugEnabled() then
        local stats = self.perf_stats
        if not stats then
            self:ResetPerformanceStats()
            stats = self.perf_stats
        end
        local created = stats.pool_created or {}
        local peak = stats.pool_peak or {}
        created[device] = (created[device] or 0) + 1
        local current_size = #pool
        if current_size > (peak[device] or 0) then
            peak[device] = current_size
        end
        stats.pool_created = created
        stats.pool_peak = peak
    end

    return button
end

function addon:ReleaseUnusedKeyButtons(device, active_count, active_collection)
    local pool = self.key_button_pools and self.key_button_pools[device]
    if type(pool) ~= "table" then
        return
    end

    active_count = active_count or 0

    for index = active_count + 1, #pool do
        local button = pool[index]
        if button then
            if button.keypress_ticker then
                button.keypress_ticker:Cancel()
                button.keypress_ticker = nil
            end
            if button.keypress_highlight then
                button.keypress_highlight:Hide()
            end
            button:EnableKeyboard(false)
            button:EnableMouseWheel(false)
            button:Hide()
        end
    end

    if type(active_collection) == "table" then
        for index = 1, active_count do
            active_collection[index] = pool[index]
        end
        for index = active_count + 1, #active_collection do
            active_collection[index] = nil
        end
    end

    if self:IsPerformanceDebugEnabled() then
        local stats = self.perf_stats
        if not stats then
            self:ResetPerformanceStats()
            stats = self.perf_stats
        end
        local active = stats.pool_last_active or {}
        active[device] = active_count
        stats.pool_last_active = active
    end
end

-- Helper function to open settings panel (Midnight compatibility)
function addon:OpenSettings()
    if self.settingsCategory and self.settingsCategory.GetID then
        Settings.OpenToCategory(self.settingsCategory:GetID())
    else
        print("KeyUI: Settings panel not available. Please reload the UI with /reload")
    end
end

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
            -- Open the Blizzard settings page (Midnight 12.0+ compatibility)
            addon:OpenSettings()
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

local function get_perf_timestamp()
    if debugprofilestop then
        return debugprofilestop()
    end
    return nil
end

function addon:ResetPerformanceStats()
    self.perf_stats = {
        refresh_layouts_calls = 0,
        refresh_layouts_total_ms = 0,
        refresh_keys_calls = 0,
        refresh_keys_total_ms = 0,
        events = {},
        pool_created = {
            keyboard = 0,
            mouse = 0,
            controller = 0,
        },
        pool_peak = {
            keyboard = 0,
            mouse = 0,
            controller = 0,
        },
        pool_last_active = {
            keyboard = 0,
            mouse = 0,
            controller = 0,
        },
    }
end

function addon:RecordPerformanceSample(sample_key, elapsed_ms)
    if not self:IsPerformanceDebugEnabled() then
        return
    end
    if type(elapsed_ms) ~= "number" or elapsed_ms < 0 then
        return
    end

    local stats = self.perf_stats
    if not stats then
        self:ResetPerformanceStats()
        stats = self.perf_stats
    end

    if sample_key == "refresh_layouts" then
        stats.refresh_layouts_calls = stats.refresh_layouts_calls + 1
        stats.refresh_layouts_total_ms = stats.refresh_layouts_total_ms + elapsed_ms
    elseif sample_key == "refresh_keys" then
        stats.refresh_keys_calls = stats.refresh_keys_calls + 1
        stats.refresh_keys_total_ms = stats.refresh_keys_total_ms + elapsed_ms
    end
end

function addon:RecordPerformanceEvent(event_name)
    if not self:IsPerformanceDebugEnabled() then
        return
    end
    if type(event_name) ~= "string" then
        return
    end

    local stats = self.perf_stats
    if not stats then
        self:ResetPerformanceStats()
        stats = self.perf_stats
    end

    stats.events[event_name] = (stats.events[event_name] or 0) + 1
end

function addon:UpdatePerformanceOverlayText()
    local frame = self.performance_overlay
    if not frame or not frame.text then
        return
    end

    local stats = self.perf_stats or {}
    local layout_calls = stats.refresh_layouts_calls or 0
    local key_calls = stats.refresh_keys_calls or 0
    local layout_avg = layout_calls > 0 and ((stats.refresh_layouts_total_ms or 0) / layout_calls) or 0
    local key_avg = key_calls > 0 and ((stats.refresh_keys_total_ms or 0) / key_calls) or 0

    local top_event_name = "-"
    local top_event_count = 0
    for event_name, count in pairs(stats.events or {}) do
        if count > top_event_count then
            top_event_name = event_name
            top_event_count = count
        end
    end

    local pools = self.key_button_pools or {}
    local keyboard_pool_size = type(pools.keyboard) == "table" and #pools.keyboard or 0
    local mouse_pool_size = type(pools.mouse) == "table" and #pools.mouse or 0
    local controller_pool_size = type(pools.controller) == "table" and #pools.controller or 0

    local pool_created = stats.pool_created or {}
    local pool_peak = stats.pool_peak or {}
    local pool_last_active = stats.pool_last_active or {}

    frame.text:SetText((
        "KeyUI Performance\n" ..
        "refresh_layouts: %d (avg %.2f ms)\n" ..
        "refresh_keys: %d (avg %.2f ms)\n" ..
        "top event: %s (%d)\n" ..
        "pool size k/m/c: %d/%d/%d\n" ..
        "pool created k/m/c: %d/%d/%d\n" ..
        "pool active k/m/c: %d/%d/%d\n" ..
        "pool peak k/m/c: %d/%d/%d"
    ):format(
        layout_calls, layout_avg, key_calls, key_avg, top_event_name, top_event_count,
        keyboard_pool_size, mouse_pool_size, controller_pool_size,
        pool_created.keyboard or 0, pool_created.mouse or 0, pool_created.controller or 0,
        pool_last_active.keyboard or 0, pool_last_active.mouse or 0, pool_last_active.controller or 0,
        pool_peak.keyboard or 0, pool_peak.mouse or 0, pool_peak.controller or 0
    ))
end

function addon:EnsurePerformanceOverlay()
    if self.performance_overlay then
        return self.performance_overlay
    end

    local existing_frame = _G["KeyUIPerformanceOverlay"]
    if existing_frame then
        self.performance_overlay = existing_frame
        return existing_frame
    end

    local frame = CreateFrame("Frame", "KeyUIPerformanceOverlay", UIParent, "BackdropTemplate")
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -16)
    frame:SetSize(340, 145)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.75)

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")

    frame.text = text
    frame:Hide()
    self.performance_overlay = frame

    return frame
end

function addon:UpdatePerformanceOverlayVisibility()
    local enabled = self:IsPerformanceDebugEnabled() and self.open

    if enabled then
        local frame = self:EnsurePerformanceOverlay()
        frame:Show()
        if not self.performance_overlay_ticker and C_Timer and C_Timer.NewTicker then
            self.performance_overlay_ticker = C_Timer.NewTicker(1, function()
                addon:UpdatePerformanceOverlayText()
            end)
        end
        self:UpdatePerformanceOverlayText()
    else
        if self.performance_overlay then
            self.performance_overlay:Hide()
        end
        if self.performance_overlay_ticker then
            self.performance_overlay_ticker:Cancel()
            self.performance_overlay_ticker = nil
        end
    end
end

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
        schemaVersion = addon.SETTINGS_SCHEMA_VERSION or 1,
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

    if self.ValidateProfileSnapshot then
        local valid, validation_error = self:ValidateProfileSnapshot(snapshot)
        if not valid then
            return false, validation_error or "Profile validation failed"
        end
    end

    local sanitized = deep_copy(snapshot.settings)

    wipe(keyui_settings)
    for key, value in pairs(sanitized) do
        keyui_settings[key] = value
    end

    self:InitializeSettings()
    keyui_settings.schema_version = addon.SETTINGS_SCHEMA_VERSION or keyui_settings.schema_version

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

    if self.ValidateLayoutData then
        local valid, validation_error = self:ValidateLayoutData(layout_type, layout_data)
        if not valid then
            return nil, validation_error or "Layout validation failed."
        end
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

    if self.ValidateLayoutPayload then
        local valid, validation_error = self:ValidateLayoutPayload(payload)
        if not valid then
            return false, validation_error or "Layout validation failed."
        end
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
        if button then
            if button.keypress_ticker then
                button.keypress_ticker:Cancel()
                button.keypress_ticker = nil
            end
            if button.Hide then
                button:Hide()
            end
            button:EnableKeyboard(false)
            button:EnableMouseWheel(false)
        end
        collection[i] = nil
    end
end

local function clear_key_button_pool(pool)
    if type(pool) ~= "table" then
        return
    end
    for i = #pool, 1, -1 do
        local button = pool[i]
        if button then
            if button.keypress_ticker then
                button.keypress_ticker:Cancel()
                button.keypress_ticker = nil
            end
            if button.keypress_highlight then
                button.keypress_highlight:Hide()
            end
            button:EnableKeyboard(false)
            button:EnableMouseWheel(false)
            button:Hide()
        end
        pool[i] = nil
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
    hide_widget(self.performance_overlay)

    if self.performance_overlay_ticker then
        self.performance_overlay_ticker:Cancel()
        self.performance_overlay_ticker = nil
    end

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
    self.controls_frame = nil
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
    clear_key_button_pool(self.key_button_pools and self.key_button_pools.keyboard)
    clear_key_button_pool(self.key_button_pools and self.key_button_pools.mouse)
    clear_key_button_pool(self.key_button_pools and self.key_button_pools.controller)

    self.keys_keyboard = {}
    self.keys_mouse = {}
    self.keys_controller = {}
    self.key_button_pools = {
        keyboard = {},
        mouse = {},
        controller = {},
    }
    self.key_lookup = {}

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

    self.deferred_ui_updates = {
        refresh_layouts = false,
        apply_click_through = false,
    }
    self.retail_action_block_warned_this_combat = false

    self.tutorial_frame1_created = false
    self.tutorial_frame2_created = false
    self.unresolved_click_bindings = {}
    self:ResetPerformanceStats()
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
        local expanded_height = keyui_settings.controls_expanded
            and UI_CONSTANTS.controls_height_expanded
            or UI_CONSTANTS.controls_height_collapsed
        self.controls_frame:SetHeight(expanded_height)
    end

    if self.selection_frame then
        self.selection_frame:ClearAllPoints()
        self.selection_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

function addon:ResetAddonSettings()
    hide_resettable_frames(self)
    reset_saved_variables()
    reset_runtime_flags(self)
    reset_frame_positions(self)
    self:SyncMinimapButton()

    -- Refresh Settings Panel UI to reflect reset values
    if Settings and Settings.SetValue then
        -- Update all registered settings to trigger UI refresh
        Settings.SetValue("KEYUI_MINIMAP_BUTTON", not keyui_settings.minimap.hide)
        Settings.SetValue("KEYUI_SHOW_KEYBOARD", keyui_settings.show_keyboard)
        Settings.SetValue("KEYUI_SHOW_MOUSE", keyui_settings.show_mouse)
        Settings.SetValue("KEYUI_SHOW_CONTROLLER", keyui_settings.show_controller)
        Settings.SetValue("KEYUI_FONT_FACE", keyui_settings.font_face)
        Settings.SetValue("KEYUI_FONT_SIZE", keyui_settings.font_base_size)
    end

    addon:RefreshAllFonts()

    print("KeyUI: Settings reset to defaults.")
end

-- Handle addon load event and initialize
EventUtil.ContinueOnAddOnLoaded(..., function()
    -- Load additional saved settings and update the UI
    addon:InitializeSettings()

    -- Register the minimap button using LibDBIcon
    LibDBIcon:Register("KeyUI", miniButton, keyui_settings.minimap)

    -- Initialize Settings panel
    if addon.InitializeSettingsPanel then
        addon.InitializeSettingsPanel()
    end
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
        addon:UpdatePerformanceOverlayVisibility()
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

        -- Initialize the tooltip if not already created.
        addon.keyui_tooltip_frame = addon.keyui_tooltip_frame or addon:create_tooltip()

        -- Load spells and refresh the key bindings.
        addon:load_spellbook()
        addon:refresh_layouts()

        -- Enable keypress visualization if setting is on and not in combat
        if keyui_settings.show_keypress_highlight and not addon.in_combat then
            addon:enable_keypress_input()
        end

        -- Show tutorial if not completed
        if keyui_settings.tutorial_completed ~= true and addon.tutorial_frame1_created ~= true then
            addon:create_tutorial_frame1()
        end
    end
end

function addon:load_spellbook()
    addon.spells = {}

    if API_COMPAT.has_modern_spellbook then
        -- RETAIL: Modern C_SpellBook API
        for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
            local name = skillLineInfo.name
            local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems

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
    elseif API_COMPAT.has_legacy_spell_api then
        -- ANNIVERSARY/CLASSIC: Legacy global spell API
        local BOOKTYPE_SPELL = "spell"
        local numTabs = GetNumSpellTabs()

        for tabIndex = 1, numTabs do
            local name, texture, offset, numSlots, _, offSpecID = GetSpellTabInfo(tabIndex)

            -- Anniversary: offSpecID is 0 for normal tabs, not nil
            if name and (not offSpecID or offSpecID == 0) then  -- Skip off-spec tabs
                addon.spells[name] = {}

                for slotIndex = offset + 1, offset + numSlots do
                    local spellType, spellID = GetSpellBookItemInfo(slotIndex, BOOKTYPE_SPELL)

                    -- spellType: "SPELL", "PETACTION", "FUTURESPELL", "FLYOUT"
                    if spellType == "SPELL" or spellType == "FUTURESPELL" then
                        local spellName = GetSpellInfo(spellID)
                        local isPassive = IsPassiveSpell(slotIndex, BOOKTYPE_SPELL)

                        if spellName and not isPassive then
                            table.insert(addon.spells[name], { name = spellName, id = spellID })
                        end
                    end
                end
            end
        end
    else
        -- Fallback: No spell API available
        print("KeyUI: Warning - No compatible spell API found")
    end
end

local function is_in_combat_lockdown()
    if InCombatLockdown then
        return InCombatLockdown()
    end
    return addon.in_combat == true
end

function addon:IsRetailActionMutationBlocked()
    return addon.VERSION and addon.VERSION.isRetail and is_in_combat_lockdown()
end

function addon:WarnRetailActionMutationBlockedOnce()
    if not (addon.VERSION and addon.VERSION.isRetail) then
        return
    end
    if addon.retail_action_block_warned_this_combat then
        return
    end
    addon.retail_action_block_warned_this_combat = true
    print("KeyUI: Action changes are blocked during combat on Retail.")
end

function addon:MarkDeferredUiUpdate(flag)
    if not flag then
        return
    end
    if not self.deferred_ui_updates then
        self.deferred_ui_updates = {}
    end
    self.deferred_ui_updates[flag] = true
end

function addon:FlushDeferredUiUpdates()
    if is_in_combat_lockdown() then
        return
    end

    local deferred = self.deferred_ui_updates
    if not deferred then
        return
    end

    local should_refresh_layouts = deferred.refresh_layouts == true
    local should_apply_click_through = deferred.apply_click_through == true

    deferred.refresh_layouts = false
    deferred.apply_click_through = false

    if should_refresh_layouts then
        self:refresh_layouts()
    end

    if should_apply_click_through and not should_refresh_layouts then
        self:ApplyClickThrough()
    end
end

-- Triggers the functions to update the keyboard and mouse layouts on the current configuration.
function addon:refresh_layouts()
    local perf_start = get_perf_timestamp()
    local function finish()
        if perf_start then
            local perf_end = get_perf_timestamp()
            if perf_end then
                addon:RecordPerformanceSample("refresh_layouts", perf_end - perf_start)
            end
        end
    end

    -- stop if the addon is not open
    if addon.open == false then
        finish()
        return
    end

    -- stop if keyboard and mouse are not visible
    if addon.is_keyboard_visible == false and addon.is_mouse_visible == false and addon.is_controller_visible == false then
        finish()
        return
    end

    if is_in_combat_lockdown() then
        addon:MarkDeferredUiUpdate("refresh_layouts")
        finish()
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

    -- Rebuild key lookup for keypress visualization
    addon:build_key_lookup()
    finish()
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
    end

    if keyui_settings.show_mouse == true then
        addon.is_mouse_visible = true
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

    -- Apply visual and interaction settings
    addon:ApplyFrameBackgrounds()
    addon:ApplyClickThrough()
end

-- Apply click-through state to visualization frames and their child key buttons
function addon:ApplyClickThrough()
    if is_in_combat_lockdown() then
        addon:MarkDeferredUiUpdate("apply_click_through")
        return
    end

    local clickThrough = keyui_settings.click_through and keyui_settings.position_locked
    local enableMouse = not clickThrough

    -- Apply to keyboard frame and its key buttons
    if addon.keyboard_frame then
        addon.keyboard_frame:EnableMouse(enableMouse)
    end
    for _, button in ipairs(addon.keys_keyboard) do
        button:EnableMouse(enableMouse)
    end

    -- Apply to mouse image (main container) and its key buttons
    if addon.mouse_image then
        addon.mouse_image:EnableMouse(enableMouse)
    end
    for _, button in ipairs(addon.keys_mouse) do
        button:EnableMouse(enableMouse)
    end

    -- Apply to controller frame and its key buttons
    if addon.controller_frame then
        addon.controller_frame:EnableMouse(enableMouse)
    end
    for _, button in ipairs(addon.keys_controller) do
        button:EnableMouse(enableMouse)
    end

    -- Note: controls_frame is NOT affected - users must be able to interact with it
end

-- Apply frame background/graphic settings to each visualization frame
function addon:ApplyFrameBackgrounds()
    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface\\AddOns\\KeyUI\\Media\\Edge\\frame_edge",
        tile = true,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }

    if addon.keyboard_frame then
        if keyui_settings.show_keyboard_background then
            addon.keyboard_frame:SetBackdrop(backdropInfo)
            addon.keyboard_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)
        else
            addon.keyboard_frame:SetBackdrop(nil)
        end
    end

    if addon.mouse_image and addon.mouse_image.Texture then
        if keyui_settings.show_mouse_graphic then
            addon.mouse_image.Texture:Show()
        else
            addon.mouse_image.Texture:Hide()
        end
    end

    if addon.controller_frame then
        if keyui_settings.show_controller_background then
            addon.controller_frame:SetBackdrop(backdropInfo)
            addon.controller_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)
        else
            addon.controller_frame:SetBackdrop(nil)
        end
    end
end

-- Apply ESC close behavior to all named frames
function addon:ApplyEscClose()
    local function set_esc_close_enabled(frame, enabled)
        if not frame then return end
        local frame_name = frame:GetName()
        if not frame_name then return end

        for i = #UISpecialFrames, 1, -1 do
            if UISpecialFrames[i] == frame_name then
                table.remove(UISpecialFrames, i)
            end
        end

        if enabled then
            tinsert(UISpecialFrames, frame_name)
        end
    end

    local enabled = keyui_settings.close_on_esc
    set_esc_close_enabled(addon.keyboard_frame, enabled)
    set_esc_close_enabled(addon.controls_frame, enabled)
    set_esc_close_enabled(addon.mouse_image, enabled)
    set_esc_close_enabled(addon.mouse_frame, enabled)
    set_esc_close_enabled(addon.controller_frame, enabled)
end

-- Update the visual state of all toggle buttons across frames
function addon:UpdateAllToggleVisuals()
    local function update_visual(button, enabled, frame)
        if not button then return end
        if not button.LeftActive then return end
        if enabled then
            button.LeftActive:Show()
            button.MiddleActive:Show()
            button.RightActive:Show()
            button.Left:Hide()
            button.Middle:Hide()
            button.Right:Hide()
            button.LeftHighlight:Hide()
            button.MiddleHighlight:Hide()
            button.RightHighlight:Hide()
            -- Only change alpha if buttons are not in faded state
            if not (frame and frame._buttons_faded) then
                button:SetAlpha(1)
            end
        else
            button.LeftActive:Hide()
            button.MiddleActive:Hide()
            button.RightActive:Hide()
            button.Left:Show()
            button.Middle:Show()
            button.Right:Show()
            if not (frame and frame._buttons_faded) then
                button:SetAlpha(0.5)
            end
        end
    end

    local frames = { addon.keyboard_frame, addon.mouse_image, addon.controller_frame }
    for _, frame in ipairs(frames) do
        if frame then
            update_visual(frame.background_button, frame._bg_setting and keyui_settings[frame._bg_setting], frame)
            update_visual(frame.esc_button, keyui_settings.close_on_esc, frame)
            update_visual(frame.combat_button, keyui_settings.stay_open_in_combat, frame)
            update_visual(frame.lock_button, keyui_settings.position_locked, frame)
            update_visual(frame.ghost_button, keyui_settings.click_through, frame)
        end
    end
end

-- Setup frame-level button fade: all tab buttons nearly disappear when mouse is not over the frame
function addon:SetupButtonFade(frame)
    local FADE_ALPHA = 0.15
    local button_names = {
        "close_button", "controls_button", "options_button",
        "menu_button",
        "background_button", "esc_button", "combat_button",
        "lock_button", "ghost_button"
    }

    frame._buttons_faded = true

    local function is_any_hovered()
        if frame:IsMouseOver() then return true end
        for _, name in ipairs(button_names) do
            local btn = frame[name]
            if btn and btn:IsVisible() and btn:IsMouseOver() then return true end
        end
        return false
    end

    local function get_resting_alpha(name)
        if name == "menu_button" then return 1 end
        if name == "close_button" and frame == addon.mouse_image then return 1 end
        if name == "background_button" and frame._bg_setting and keyui_settings[frame._bg_setting] then return 1 end
        if name == "esc_button" and keyui_settings.close_on_esc then return 1 end
        if name == "combat_button" and keyui_settings.stay_open_in_combat then return 1 end
        if name == "lock_button" and keyui_settings.position_locked then return 1 end
        if name == "ghost_button" and keyui_settings.click_through then return 1 end
        if name == "controls_button" and addon.controls_frame and addon.controls_frame:IsVisible() then return 1 end
        return 0.5
    end

    local function fade_in()
        frame._buttons_faded = false
        for _, name in ipairs(button_names) do
            local btn = frame[name]
            if btn then
                if btn:IsMouseOver() then
                    btn:SetAlpha(1)
                else
                    btn:SetAlpha(get_resting_alpha(name))
                end
            end
        end
    end

    local function fade_out()
        frame._buttons_faded = true
        for _, name in ipairs(button_names) do
            local btn = frame[name]
            if btn then
                btn:SetAlpha(FADE_ALPHA)
            end
        end
    end

    local function schedule_fade()
        C_Timer.After(0.1, function()
            if not is_any_hovered() then
                fade_out()
            end
        end)
    end

    -- Set initial faded state and reset on every show
    fade_out()

    if frame:GetScript("OnShow") then
        frame:HookScript("OnShow", function()
            fade_out()
        end)
    else
        frame:SetScript("OnShow", function()
            fade_out()
        end)
    end

    -- Hook button OnEnter/OnLeave for immediate fade_in when hovering a tab button
    for _, name in ipairs(button_names) do
        local btn = frame[name]
        if btn then
            local function on_enter(self)
                if frame._buttons_faded then
                    fade_in()
                else
                    self:SetAlpha(1)
                end
            end
            local function on_leave(self)
                if not frame._buttons_faded then
                    self:SetAlpha(get_resting_alpha(name))
                end
                schedule_fade()
            end
            if btn:GetScript("OnEnter") then
                btn:HookScript("OnEnter", on_enter)
            else
                btn:SetScript("OnEnter", on_enter)
            end
            if btn:GetScript("OnLeave") then
                btn:HookScript("OnLeave", on_leave)
            else
                btn:SetScript("OnLeave", on_leave)
            end
        end
    end

    -- Use OnUpdate polling to detect frame hover (OnEnter/OnLeave on the frame
    -- is unreliable because child key buttons intercept mouse events)
    local elapsed_acc = 0
    local function on_update(self, elapsed)
        elapsed_acc = elapsed_acc + elapsed
        if elapsed_acc < 0.1 then return end
        elapsed_acc = 0

        local hovered = is_any_hovered()
        if hovered and frame._buttons_faded then
            fade_in()
        elseif not hovered and not frame._buttons_faded then
            fade_out()
        end
    end

    if frame:GetScript("OnUpdate") then
        frame:HookScript("OnUpdate", on_update)
    else
        frame:SetScript("OnUpdate", on_update)
    end
end

-- Create all left-side toggle buttons on a visualization frame
-- use_bottom_tabs: if true, creates PanelTabButtonTemplate (bottom tabs) instead of PanelTopTabButtonTemplate (top tabs)
-- bg_setting: the keyui_settings key for this frame's background toggle (e.g. "show_keyboard_background")
function addon:CreateLockToggleButtons(frame, frame_level, custom_font, use_bottom_tabs, bg_setting)
    local USE_ATLAS = addon.VERSION.USE_ATLAS

    -- Store the bg_setting on the frame for use by SetupButtonFade/UpdateAllToggleVisuals
    frame._bg_setting = bg_setting

    local function toggle_textures(button, showInactive)
        if not button.LeftActive then return end
        if showInactive then
            button.LeftActive:Hide()
            button.MiddleActive:Hide()
            button.RightActive:Hide()
            button.Left:Show()
            button.Middle:Show()
            button.Right:Show()
        else
            button.LeftActive:Show()
            button.MiddleActive:Show()
            button.RightActive:Show()
            button.Left:Hide()
            button.Middle:Hide()
            button.Right:Hide()
            button.LeftHighlight:Hide()
            button.MiddleHighlight:Hide()
            button.RightHighlight:Hide()
        end
    end

    -- Text anchor depends on tab style
    local text_anchor = use_bottom_tabs and "CENTER" or "BOTTOM"
    local text_offset_y = use_bottom_tabs and 0 or 4

    -- Helper: create a single toggle button and set up common properties
    local function create_toggle_button(field_name, label, tooltip_title, tooltip_desc, is_active_fn, on_click_fn, prev_button)
        local button
        if use_bottom_tabs then
            if USE_ATLAS then
                button = CreateFrame("Button", nil, frame, "PanelTabButtonTemplate")
            else
                button = addon:CreateTabButton(frame)
            end
        else
            if USE_ATLAS then
                button = CreateFrame("Button", nil, frame, "PanelTopTabButtonTemplate")
            else
                button = addon:CreateTopTabButton(frame)
            end
        end

        -- Positioning: first button anchors to frame, subsequent chain from previous
        if prev_button then
            button:SetPoint("BOTTOMLEFT", prev_button, "BOTTOMRIGHT", 4, 0)
        elseif not use_bottom_tabs then
            button:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 0)
        end

        button:SetFrameLevel(frame_level - 1)
        button:SetText(label)
        button:SetNormalFontObject(custom_font)
        button:SetHighlightFontObject(custom_font)
        button:SetDisabledFontObject(custom_font)

        local fontString = button:GetFontString()
        fontString:ClearAllPoints()
        fontString:SetPoint(text_anchor, button, text_anchor, 0, text_offset_y)
        fontString:SetTextColor(1, 1, 1)

        -- Initial inactive state
        toggle_textures(button, true)
        button:SetAlpha(0.5)

        button:SetScript("OnEnter", function(self)
            self:SetAlpha(1)
            toggle_textures(self, false)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, tooltip_title)
            GameTooltip_AddNormalLine(GameTooltip, tooltip_desc, true)
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if is_active_fn() then
                return
            end
            self:SetAlpha(0.5)
            toggle_textures(self, true)
        end)

        button:SetScript("OnClick", on_click_fn)

        frame[field_name] = button
        return button
    end

    -- 1. Background button (frame-specific setting)
    local bg_btn = create_toggle_button(
        "background_button", "Background",
        "Background", "Show or hide the frame background",
        function() return keyui_settings[bg_setting] end,
        function()
            keyui_settings[bg_setting] = not keyui_settings[bg_setting]
            addon:ApplyFrameBackgrounds()
            addon:UpdateAllToggleVisuals()
        end,
        nil -- first button, anchored to frame
    )

    -- 2. ESC button (global setting)
    local esc_btn = create_toggle_button(
        "esc_button", "ESC",
        "ESC", "Close windows with the ESC key",
        function() return keyui_settings.close_on_esc end,
        function()
            keyui_settings.close_on_esc = not keyui_settings.close_on_esc
            addon:ApplyEscClose()
            addon:UpdateAllToggleVisuals()
        end,
        bg_btn
    )

    -- 3. Combat button (global setting)
    local combat_btn = create_toggle_button(
        "combat_button", "Combat",
        "Combat", "Stay open during combat",
        function() return keyui_settings.stay_open_in_combat end,
        function()
            keyui_settings.stay_open_in_combat = not keyui_settings.stay_open_in_combat
            addon:UpdateAllToggleVisuals()
        end,
        esc_btn
    )

    -- 4. Lock button (global setting)
    local lock_btn = create_toggle_button(
        "lock_button", "Lock",
        "Lock", "Lock frame positions to prevent accidental movement",
        function() return keyui_settings.position_locked end,
        function()
            keyui_settings.position_locked = not keyui_settings.position_locked
            -- Disable ghost mode when unlocking
            if not keyui_settings.position_locked then
                keyui_settings.click_through = false
                addon:ApplyClickThrough()
            end
            addon:UpdateAllToggleVisuals()
        end,
        combat_btn
    )

    -- 5. Ghost button (global setting, requires Lock)
    create_toggle_button(
        "ghost_button", "Ghost",
        "Ghost", "Make visualization frames click-through (requires Lock)",
        function() return keyui_settings.click_through end,
        function()
            if not keyui_settings.position_locked then return end
            keyui_settings.click_through = not keyui_settings.click_through
            addon:ApplyClickThrough()
            addon:UpdateAllToggleVisuals()
        end,
        lock_btn
    )

    -- Set initial visuals
    addon:UpdateAllToggleVisuals()
end

-- Creates a single arrow-up menu button (left of Options tab) with Background/ESC/Combat/Lock/Ghost toggles.
-- Replaces CreateLockToggleButtons for Retail frames (Keyboard, Controller).
function addon:CreateToggleMenuButton(frame, bg_setting)
    frame._bg_setting = bg_setting

    local menu_button = addon:CreateArrowUpButton(frame)
    menu_button:SetPoint("BOTTOMRIGHT", frame.options_button, "BOTTOMLEFT", -3, -2)
    frame.menu_button = menu_button

    menu_button:SetScript("OnClick", function(self)
        local menu = MenuUtil.CreateContextMenu(self, function(_, rootDescription)
            local bg = rootDescription:CreateCheckbox("Background",
                function() return keyui_settings[bg_setting] end,
                function()
                    keyui_settings[bg_setting] = not keyui_settings[bg_setting]
                    addon:ApplyFrameBackgrounds()
                    addon:UpdateAllToggleVisuals()
                end)
            bg:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Background")
                GameTooltip_AddNormalLine(tooltip, "Show or hide the background")
            end)

            local esc = rootDescription:CreateCheckbox("ESC",
                function() return keyui_settings.close_on_esc end,
                function()
                    keyui_settings.close_on_esc = not keyui_settings.close_on_esc
                    addon:ApplyEscClose()
                    addon:UpdateAllToggleVisuals()
                end)
            esc:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "ESC")
                GameTooltip_AddNormalLine(tooltip, "Close windows with the ESC key")
            end)

            local combat = rootDescription:CreateCheckbox("Combat",
                function() return keyui_settings.stay_open_in_combat end,
                function()
                    keyui_settings.stay_open_in_combat = not keyui_settings.stay_open_in_combat
                    addon:UpdateAllToggleVisuals()
                end)
            combat:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Combat")
                GameTooltip_AddNormalLine(tooltip, "Stay open during combat")
            end)

            local lock = rootDescription:CreateCheckbox("Lock",
                function() return keyui_settings.position_locked end,
                function()
                    keyui_settings.position_locked = not keyui_settings.position_locked
                    if not keyui_settings.position_locked then
                        keyui_settings.click_through = false
                        addon:ApplyClickThrough()
                    end
                    addon:UpdateAllToggleVisuals()
                end)
            lock:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Lock")
                GameTooltip_AddNormalLine(tooltip, "Lock frame positions to prevent accidental movement")
            end)

            local ghost = rootDescription:CreateCheckbox("Ghost",
                function() return keyui_settings.click_through end,
                function()
                    if not keyui_settings.position_locked then return end
                    keyui_settings.click_through = not keyui_settings.click_through
                    addon:ApplyClickThrough()
                    addon:UpdateAllToggleVisuals()
                end)
            ghost:SetTooltip(function(tooltip)
                GameTooltip_SetTitle(tooltip, "Ghost")
                GameTooltip_AddNormalLine(tooltip, "Make visualization frames click-through (requires Lock)")
            end)
        end)

        -- Reposition menu above the button, opening upward to the left
        if menu then
            menu:ClearAllPoints()
            menu:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
        end
    end)
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

    addon:disable_keypress_input()

    addon.open = false
    addon.is_keyboard_visible = false
    addon.is_mouse_visible = false
    addon.is_controller_visible = false
    addon:UpdatePerformanceOverlayVisibility()
end

local function on_frame_hide(self)
    if (addon.is_keyboard_visible == false or keyui_settings.show_keyboard == false) and (addon.is_mouse_visible == false or keyui_settings.show_mouse == false) and (addon.is_controller_visible == false or keyui_settings.show_controller == false) then
        addon.open = false
        addon:UpdatePerformanceOverlayVisibility()

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
    keyui_tooltip_frame.key:SetFont(addon:GetFont(), addon:GetFontSize(1.0))
    addon:RegisterFontString(keyui_tooltip_frame.key, 1.0)

    keyui_tooltip_frame.binding = keyui_tooltip_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    keyui_tooltip_frame.binding:SetPoint("CENTER", keyui_tooltip_frame, "CENTER", 0, -10)
    keyui_tooltip_frame.binding:SetTextColor(1, 1, 1)
    keyui_tooltip_frame.binding:SetFont(addon:GetFont(), addon:GetFontSize(1.0))
    addon:RegisterFontString(keyui_tooltip_frame.binding, 1.0)

    -- Hide the GameTooltip when this custom tooltip hides.
    keyui_tooltip_frame:SetScript("OnHide", function() GameTooltip:Hide() end)

    return keyui_tooltip_frame
end

-- This function is called when the Mouse cursor hovers over a key binding button. It displays a tooltip description of the spell or ability.
function addon:button_mouse_over(button)
    if not addon.keyui_tooltip_frame then
        addon:create_tooltip()
    end
    if not addon.keyui_tooltip_frame then
        return
    end

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

-- Lookup table for bindings with specific icons (defined once, reused per call)
local specific_bindings = {
    EXTRAACTIONBUTTON1 = 4200126,
    MOVEFORWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_up",
    MOVEBACKWARD = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_down",
    STRAFELEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_left",
    STRAFERIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\arrow_right",
    TURNLEFT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_left",
    TURNRIGHT = "Interface\\AddOns\\KeyUI\\Media\\Icons\\circle_right",
}

local function matches_opie_binding(binding)
    if type(binding) ~= "string" or binding == "" then
        return false
    end

    if binding:match("^CLICK ORL_RProxy") then
        return true
    end

    local binding_name = _G["BINDING_NAME_" .. binding]
    return type(binding_name) == "string" and binding_name:lower():find("opie", 1, true) ~= nil
end

-- Highlights a modifier button when the corresponding key is held down
local function highlight_modifier_button(button)
    button.highlight:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Background\\yellow_bg")
    button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)
    button.highlight:Show()
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

    -- Loop through the keybind patterns and process the binding if the binding is not empty
    if binding ~= "" then
        local matched = false
        for pattern, handler in pairs(keybind_patterns) do
            if binding:find(pattern) then
                handler(binding, button)
                matched = true
                break -- Exit loop once a match is found
            end
        end

        if not matched then
            local click_frame_name, click_button = binding:match("^CLICK ([^:]+):(.+)$")
            if click_frame_name and (click_button == "HOTKEY" or click_button == "LeftButton") then
                local slot = addon:resolve_addon_slot(binding)
                if slot then
                    button.slot = slot

                    if HasAction(slot) then
                        local texture = GetActionTexture(slot)
                        if texture then
                            button.active_slot = slot
                            button.icon:SetTexture(texture)
                            button.icon:Show()
                        end
                    end

                    addon:update_assisted_combat_indicator(button, slot)
                    matched = true
                end
            end
        end

        if not matched and matches_opie_binding(binding) then
            addon:process_opie(button)
            matched = true
        end

        if specific_bindings[binding] then
            button.icon:SetTexture(specific_bindings[binding])
            if binding ~= "EXTRAACTIONBUTTON1" then
                button.icon:SetSize(30, 30)
            end
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

    -- Update overlays after binding is resolved
    addon:UpdateButtonCooldown(button)
    addon:UpdateButtonUsable(button)
    addon:UpdateButtonCount(button)
end

-- Resets the button's state
function addon:reset_button_state(button)
    button.slot = nil
    button.active_slot = nil
    button.spellid = nil
    button.pet_action_index = nil
    button.binding = nil
    button.is_active = nil
    button.is_castable = nil
    button.icon:SetTexture(nil)
    button.icon:Hide()
    button.icon:SetVertexColor(1, 1, 1)
    button.readable_binding:Hide()
    button.readable_binding:SetText("")
    button.highlight:Hide()
    if button.assisted_combat_clip then
        button.assisted_combat_clip:Hide()
    end
    if button.count_text then button.count_text:SetText("") end
    if button.short_key then button.short_key:SetTextColor(1, 1, 1) end
end

-- ============================================================================
-- Cooldown Overlay System
-- ============================================================================

-- Reads cooldown data for a button based on its resolved binding type.
-- Priority: active_slot > spellid > pet_action_index
-- Returns: start, duration, modRate  (nil, nil, nil if no cooldown source)
function addon:GetButtonCooldownData(button)
    if button.active_slot then
        local slot = button.active_slot
        local start, duration, modRate

        if API_COMPAT.has_modern_action_cooldown then
            local info = C_ActionBar.GetActionCooldown(slot)
            if info then
                start, duration, modRate = info.startTime, info.duration, info.modRate
            end
        else
            local _
            start, duration, _, modRate = GetActionCooldown(slot)
        end

        -- In Retail combat, values may be "secret" (WoW security restriction).
        -- pcall the comparison; on failure, pass through – SetCooldown accepts secret values.
        local ok, has_main = pcall(function()
            return start and start > 0 and duration and duration > 0
        end)
        if not ok then
            return start, duration, modRate  -- secret values: pass through directly
        end
        if has_main then
            return start, duration, modRate
        end

        -- No main cooldown – check charge recovery (covers charge-based spells).
        if API_COMPAT.has_modern_action_charges then
            local ci = C_ActionBar.GetActionCharges(slot)
            if ci and ci.maxCharges > 1 and ci.currentCharges < ci.maxCharges
                    and ci.cooldownStartTime and ci.cooldownStartTime > 0 then
                return ci.cooldownStartTime, ci.cooldownDuration, ci.chargeModRate or 1.0
            end
        else
            local charges, maxCharges, cs, cd, cr = GetActionCharges(slot)
            if maxCharges and maxCharges > 1 and charges and charges < maxCharges
                    and cs and cs > 0 then
                return cs, cd, cr or 1.0
            end
        end

        return start, duration, modRate  -- 0, 0, x → no cooldown
    end

    if button.spellid then
        if API_COMPAT.has_modern_spell_cooldown then
            local info = C_Spell.GetSpellCooldown(button.spellid)
            if info then
                return info.startTime, info.duration, info.modRate
            end
        else
            local start, duration = GetSpellCooldown(button.spellid)
            return start, duration, 1.0
        end
    end

    if button.pet_action_index then
        local start, duration = GetPetActionCooldown(button.pet_action_index)
        return start, duration, 1.0
    end

    return nil, nil, nil
end

-- Clears the cooldown overlay on a single button.
-- Creates and configures a cooldown overlay frame for a button icon.
-- CooldownFrameTemplate is required to initialize the C++ swipe renderer.
function addon.CreateCooldownFrame(button, size)
    local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cd:ClearAllPoints() -- override template's setAllPoints="true"
    cd:SetFrameLevel(button:GetFrameLevel() + 1)
    cd:SetSize(size, size)
    cd:SetPoint("CENTER", button.icon, "CENTER", 0, 0)
    cd:SetDrawBling(false)
    cd:SetDrawEdge(true)
    cd:SetDrawSwipe(true)
    cd:SetSwipeColor(0, 0, 0, 0.8)
    return cd
end

-- Creates a stack/charge count FontString anchored to the bottom-right of the icon.
function addon.CreateCountText(button)
    local ct = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    ct:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", -2, 2)
    ct:SetText("")
    return ct
end

function addon:ClearButtonCooldown(button)
    if button.cooldown then
        button.cooldown:Clear()
    end
end

-- Updates the cooldown overlay on a single button based on current game state.
function addon:UpdateButtonCooldown(button)
    if not button.cooldown then return end

    if not keyui_settings.show_actionbar_mode then
        button.cooldown:Clear()
        return
    end

    if not button.icon:IsShown() then
        button.cooldown:Clear()
        return
    end

    local start, duration, modRate = addon:GetButtonCooldownData(button)
    if not start then
        button.cooldown:Clear()
        return
    end
    -- In Retail combat, GetActionCooldown may return "secret values" that cannot be compared
    -- to literals with ==. pcall catches the error; when secret, SetCooldown accepts them directly.
    local ok, no_cooldown = pcall(function() return start == 0 or duration == 0 end)
    if ok and no_cooldown then
        button.cooldown:Clear()
        return
    end

    button.cooldown:SetCooldown(start, duration, modRate or 1.0)
end

-- Refreshes cooldown overlays on all visible buttons.
function addon:refresh_cooldowns()
    if not keyui_settings.show_actionbar_mode then
        addon:clear_all_cooldowns()
        return
    end
    for _, button in ipairs(addon.keys_keyboard) do
        addon:UpdateButtonCooldown(button)
    end
    for _, button in ipairs(addon.keys_mouse) do
        addon:UpdateButtonCooldown(button)
    end
    for _, button in ipairs(addon.keys_controller) do
        addon:UpdateButtonCooldown(button)
    end
end

-- Clears all cooldown overlays on all buttons.
function addon:clear_all_cooldowns()
    for _, button in ipairs(addon.keys_keyboard) do
        addon:ClearButtonCooldown(button)
    end
    for _, button in ipairs(addon.keys_mouse) do
        addon:ClearButtonCooldown(button)
    end
    for _, button in ipairs(addon.keys_controller) do
        addon:ClearButtonCooldown(button)
    end
end

-- ── Usable State ─────────────────────────────────────────────────────────────

function addon:GetButtonUsableColors(button)
    if not button.active_slot then return 1, 1, 1 end
    local isUsable, notEnoughMana
    if API_COMPAT.has_modern_action_usable then
        isUsable, notEnoughMana = C_ActionBar.IsUsableAction(button.active_slot)
    else
        isUsable, notEnoughMana = IsUsableAction(button.active_slot)
    end
    if isUsable then return 1.0, 1.0, 1.0
    elseif notEnoughMana then return 0.5, 0.5, 1.0
    else return 0.4, 0.4, 0.4 end
end

function addon:UpdateButtonUsable(button)
    if not button.icon:IsShown() or not keyui_settings.show_actionbar_mode then
        button.icon:SetVertexColor(1, 1, 1); return
    end
    button.icon:SetVertexColor(addon:GetButtonUsableColors(button))
end

function addon:refresh_usable()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonUsable(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonUsable(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonUsable(b) end
end

function addon:clear_all_usable()
    for _, b in ipairs(addon.keys_keyboard)    do b.icon:SetVertexColor(1, 1, 1) end
    for _, b in ipairs(addon.keys_mouse)       do b.icon:SetVertexColor(1, 1, 1) end
    for _, b in ipairs(addon.keys_controller)  do b.icon:SetVertexColor(1, 1, 1) end
end

-- ── Stack / Charge Counter ────────────────────────────────────────────────────

function addon:GetButtonCountText(button)
    if not button.active_slot then return "" end
    local slot = button.active_slot
    if API_COMPAT.has_modern_display_count then
        return C_ActionBar.GetActionDisplayCount(slot) or ""
    end
    if IsConsumableAction(slot) or IsStackableAction(slot) then
        local count = GetActionCount(slot)
        if count > 9999 then return "*" end
        return count > 0 and tostring(count) or ""
    end
    local charges, maxCharges = GetActionCharges(slot)
    if maxCharges and maxCharges > 1 then return tostring(charges) end
    return ""
end

function addon:UpdateButtonCount(button)
    if not button.count_text then return end
    if not keyui_settings.show_actionbar_mode or not button.icon:IsShown() then
        button.count_text:SetText(""); return
    end
    button.count_text:SetText(addon:GetButtonCountText(button))
end

function addon:refresh_counts()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonCount(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonCount(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonCount(b) end
end

function addon:clear_all_counts()
    for _, b in ipairs(addon.keys_keyboard)    do if b.count_text then b.count_text:SetText("") end end
    for _, b in ipairs(addon.keys_mouse)       do if b.count_text then b.count_text:SetText("") end end
    for _, b in ipairs(addon.keys_controller)  do if b.count_text then b.count_text:SetText("") end end
end

-- ── Range Indicator ───────────────────────────────────────────────────────────

function addon:UpdateButtonRange(button)
    if not button.short_key then return end
    if not keyui_settings.show_actionbar_mode or not button.active_slot then
        button.short_key:SetTextColor(1, 1, 1); return
    end
    local inRange
    if API_COMPAT.has_modern_action_in_range then
        inRange = C_ActionBar.IsActionInRange(button.active_slot)
    else
        inRange = IsActionInRange(button.active_slot)
    end
    if inRange == false then
        button.short_key:SetTextColor(1, 0.2, 0.2)
    else
        button.short_key:SetTextColor(1, 1, 1)
    end
end

function addon:refresh_range()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonRange(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonRange(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonRange(b) end
end

function addon:clear_all_range()
    for _, b in ipairs(addon.keys_keyboard)    do if b.short_key then b.short_key:SetTextColor(1, 1, 1) end end
    for _, b in ipairs(addon.keys_mouse)       do if b.short_key then b.short_key:SetTextColor(1, 1, 1) end end
    for _, b in ipairs(addon.keys_controller)  do if b.short_key then b.short_key:SetTextColor(1, 1, 1) end end
end

-- Shows the pushed texture on the mapped action bar button when hovering a KeyUI button
function addon:show_pushed_texture(active_slot)
    if not keyui_settings.show_pushed_texture then return end
    if not active_slot then return end

    local mapped_button = addon.button_texture_mapping[tostring(active_slot)]
    if mapped_button then
        local normal_texture = mapped_button:GetNormalTexture()
        if normal_texture and normal_texture:IsVisible() then
            local pushed_texture = mapped_button:GetPushedTexture()
            if pushed_texture then
                pushed_texture:Show()
                addon.current_pushed_button = pushed_texture
            end
        end
    end
end

-- Handles drag-drop actions on a KeyUI button (place or pickup action)
function addon:handle_action_drag(button)
    if addon:IsRetailActionMutationBlocked() then
        addon:WarnRetailActionMutationBlockedOnce()
        return
    end

    local target_slot = button and tonumber(button.slot)
    if not target_slot or target_slot <= 0 then
        return
    end

    local cursor_kind, cursor_data = GetCursorInfo()
    local source_slot = nil
    if cursor_kind == "action" then
        source_slot = tonumber(cursor_data)
        if not source_slot or source_slot <= 0 then
            source_slot = nil
        end
    end

    local affected_slots = {
        [target_slot] = true,
    }
    if source_slot and source_slot ~= target_slot then
        affected_slots[source_slot] = true
    end

    if cursor_kind then
        if C_ActionBar and C_ActionBar.PutActionInSlot then
            C_ActionBar.PutActionInSlot(target_slot)
        else
            PlaceAction(target_slot)
        end
    else
        PickupAction(target_slot)
    end

    addon:sync_dragged_action_slots(button, affected_slots)
end

-- Retrieves the binding action
function addon:get_binding(raw_key)
    return GetBindingAction(self.current_modifier_string .. (raw_key or ""), true) or ""
end

-- Shows or hides the Assisted Combat (Single-Button Assistant) indicator on a KeyUI button
function addon:update_assisted_combat_indicator(button, slot)
    if not slot then return end

    -- Assisted Combat only exists in Retail & Anniversary
    if not C_ActionBar or not C_ActionBar.IsAssistedCombatAction then
        return
    end

    local isAssistedCombat = C_ActionBar.IsAssistedCombatAction(slot)

    if isAssistedCombat then
        if not button.assisted_combat_clip then
            -- Clip frame constrains the overlay to the icon area
            local clip = CreateFrame("Frame", nil, button)
            clip:SetClipsChildren(true)
            clip:SetSize(button.icon:GetWidth(), button.icon:GetHeight())
            clip:SetPoint("CENTER", button, "CENTER", 0, 4)
            button.assisted_combat_clip = clip

            local overlay = clip:CreateTexture(nil, "OVERLAY")
            addon:SetTexture(overlay, "UI-HUD-RotationHelper-Inactive",
                "Interface\\AddOns\\KeyUI\\Media\\Atlas\\CombatAssistantSingleButton",
                {0.905273, 0.967773, 0.0766602, 0.10791})
            overlay:SetSize(button:GetWidth() * 1.3, button:GetHeight() * 1.3)
            overlay:SetPoint("CENTER", clip, "CENTER")
            button.assisted_combat_overlay = overlay
        end
        button.assisted_combat_clip:Show()
    elseif button.assisted_combat_clip then
        button.assisted_combat_clip:Hide()
    end
end

-- Get spell ID from action slot (version-compatible)
-- Retail & Anniversary have C_ActionBar.GetSpell, Cata Classic & Classic Era don't
local function GetSpellFromActionSlot(slot)
    if API_COMPAT.has_actionbar_getspell then
        return C_ActionBar.GetSpell(slot)
    else
        local actionType, actionID = GetActionInfo(slot)
        if actionType == "spell" then
            return actionID
        end
    end
    return nil
end

-- Handles processing for ACTIONBUTTON
function addon:process_actionbutton_slot(slot, button)
    if not slot then return end

    local resolved_slot = nil
    local loaded_integrations = addon.loaded_integrations or {}

    -- Dominos can remap ACTIONBUTTON1-12 through secure frame state/paging.
    -- Prefer the live Dominos frame action slot when available.
    if loaded_integrations.Dominos and slot >= 1 and slot <= 12 then
        local dominos_frame_name = ("DominosActionButton%d"):format(slot)
        if _G[dominos_frame_name] then
            local dominos_binding = ("CLICK %s:HOTKEY"):format(dominos_frame_name)
            resolved_slot = addon:resolve_addon_slot(dominos_binding)
        end
    end

    -- Adjust the slot based on bonus bar offset and action bar page
    local adjusted_slot = resolved_slot or addon:get_action_button_slot(slot)
    button.slot = adjusted_slot

    -- Check if the slot has an action assigned
    if HasAction(adjusted_slot) then
        local texture = GetActionTexture(adjusted_slot)
        if texture then
            button.active_slot = adjusted_slot
            button.icon:SetTexture(texture)
            button.icon:Show()

            -- Store the spell ID if the action contains a spell
            local spellID = GetSpellFromActionSlot(adjusted_slot)
            if spellID then
                button.spellid = spellID
            end
        end

        -- Show Assisted Combat indicator if this slot contains the rotation helper
        addon:update_assisted_combat_indicator(button, adjusted_slot)
    end
end

-- Number of buttons per action bar page (Blizzard standard)
local NUM_ACTIONBAR_BUTTONS = 12

-- Adjusts the slot for ACTIONBUTTON bindings based on the class, stance, or action bar page
function addon:get_action_button_slot(action_slot)
    -- Stance/form bonus bars (Rogue Stealth, Druid forms, etc.)
    if addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
        if addon.bonusbar_offset >= 1 and addon.bonusbar_offset <= 4 then
            return action_slot + (addon.bonusbar_offset + 5) * NUM_ACTIONBAR_BUTTONS
        end
    end

    -- Special bonus bar (e.g. Dragonriding)
    if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then
        return action_slot + 10 * NUM_ACTIONBAR_BUTTONS
    end

    -- Standard action bar pages 2-6
    if addon.current_actionbar_page >= 2 and addon.current_actionbar_page <= 6 then
        return action_slot + (addon.current_actionbar_page - 1) * NUM_ACTIONBAR_BUTTONS
    end

    return action_slot -- Default page 1, slots 1-12
end

-- Slot offsets for each multi-action bar index (Blizzard's bar-to-slot mapping)
local multiactionbar_offsets = {
    [0] = 0,     -- Main action bar
    [1] = 60,    -- Bottom left action bar
    [2] = 48,    -- Bottom right action bar
    [3] = 24,    -- Right action bar
    [4] = 36,    -- Right action bar 2
    [5] = 144,   -- Action bar 5
    [6] = 156,   -- Action bar 6
    [7] = 168,   -- Action bar 7
}

-- Handles processing for MULTIACTIONBAR
function addon:process_multiactionbar_slot(bar, bar_button, button)
    if not bar or not bar_button then return end

    local offset = multiactionbar_offsets[bar]
    if not offset then return end

    local slot = offset + bar_button

    button.slot = slot

    -- Check if the slot has an action assigned
    if slot and HasAction(slot) then
        button.active_slot = slot
        button.icon:SetTexture(GetActionTexture(slot))
        button.icon:Show()

        -- Store the spell ID if the action contains a spell
        local spellID = GetSpellFromActionSlot(slot)
        if spellID then
            button.spellid = spellID
        end

        -- Show Assisted Combat indicator if this slot contains the rotation helper
        addon:update_assisted_combat_indicator(button, slot)
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
        pet_texture = _G[pet_texture] or ("Interface\\Icons\\" .. pet_texture) -- Fallback to WoW's icon folder
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
        button.slot = nil
        button.active_slot = nil
        button.pet_action_index = nil
        button.spellid = spellID             -- Store the spell ID
        button.is_active = is_active         -- Track whether the form is active
        button.is_castable = is_castable     -- Track whether the form is castable
    end
end

-- Handles processing for addon stance bindings that mirror SHAPESHIFTBUTTON actions
function addon:process_addon_stance(binding, button)
    if type(binding) ~= "string" then
        return
    end

    local stance_index = binding:match("^CLICK BT4StanceButton(%d+):LeftButton$")
    stance_index = tonumber(stance_index)
    if not stance_index then
        return
    end

    local icon, is_active, is_castable, spellID = GetShapeshiftFormInfo(stance_index)
    if icon then
        button.icon:SetTexture(icon)
        button.icon:Show()
        button.slot = nil
        button.active_slot = nil
        button.pet_action_index = nil
        button.spellid = spellID
        button.is_active = is_active
        button.is_castable = is_castable
    end
end

-- Handles processing for Spell bindings
function addon:process_spell(spell_name, button)
    if not spell_name then return end

    -- Retrieve and store the spell ID for cooldown tracking
    local spellID = C_Spell.GetSpellIDForSpellIdentifier(spell_name)
    if spellID then
        button.spellid = spellID
    end

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

local function parse_click_binding(binding)
    if type(binding) ~= "string" then
        return nil, nil
    end

    local frame_name, click_button = binding:match("^CLICK ([^:]+):(.+)$")
    return frame_name, click_button
end

local function normalize_action_slot(value)
    local slot = tonumber(value)
    if slot and slot > 0 then
        return slot
    end
    return nil
end

function addon:refresh_keys_for_slots(slot_changes)
    if type(slot_changes) ~= "table" then
        return false
    end

    local normalized_slots = {}
    for slot in pairs(slot_changes) do
        local normalized = normalize_action_slot(slot)
        if normalized then
            normalized_slots[normalized] = true
        end
    end

    if not next(normalized_slots) then
        return false
    end

    local refreshed = false
    local function refresh_collection(collection)
        if type(collection) ~= "table" then
            return
        end

        for i = 1, #collection do
            local button = collection[i]
            if button then
                local slot = normalize_action_slot(button.active_slot) or normalize_action_slot(button.slot)
                if slot and normalized_slots[slot] then
                    addon:set_key(button)
                    refreshed = true
                end
            end
        end
    end

    if addon.is_keyboard_visible ~= false then
        refresh_collection(addon.keys_keyboard)
    end
    if addon.is_mouse_visible ~= false then
        refresh_collection(addon.keys_mouse)
    end
    if addon.is_controller_visible ~= false then
        refresh_collection(addon.keys_controller)
    end

    return refreshed
end

local function collect_click_binding_frames(binding)
    local frame_name = parse_click_binding(binding)
    if not frame_name then
        return nil
    end

    local frames = {}
    local seen = {}

    local function add_frame(frame)
        if frame and not seen[frame] then
            seen[frame] = true
            table.insert(frames, frame)
        end
    end

    local frame = _G[frame_name]
    add_frame(frame)

    if frame and frame.GetParent then
        add_frame(frame:GetParent())
    end

    local base_frame_name = frame_name:match("^(.-)Hotkey$")
    if base_frame_name and base_frame_name ~= "" then
        local base_frame = _G[base_frame_name]
        add_frame(base_frame)

        if base_frame and base_frame.GetParent then
            add_frame(base_frame:GetParent())
        end
    end

    return frames
end

local function sorted_slot_list(slot_set)
    local slots = {}

    if type(slot_set) ~= "table" then
        return slots
    end

    for slot in pairs(slot_set) do
        local normalized = normalize_action_slot(slot)
        if normalized then
            table.insert(slots, normalized)
        end
    end

    table.sort(slots)
    return slots
end

local function try_frame_refresh(frame, method_name)
    if not frame then
        return
    end

    local method = frame[method_name]
    if type(method) == "function" then
        pcall(method, frame)
    end
end

local function get_action_slot_from_frame(frame)
    local current = frame
    local depth = 0

    while current and depth < 8 do
        if current.GetAttribute then
            local action = current:GetAttribute("action")
            local slot = normalize_action_slot(action)
            if slot then
                return slot
            end
        end

        local frame_action_slot = normalize_action_slot(current.action)
        if frame_action_slot then
            return frame_action_slot
        end

        if current._state_type == "action" then
            local state_action_slot = normalize_action_slot(current._state_action)
            if state_action_slot then
                return state_action_slot
            end
        end

        if not current.GetParent then
            break
        end

        local parent = current:GetParent()
        if not parent or parent == current then
            break
        end

        current = parent
        depth = depth + 1
    end

    return nil
end

function addon:refresh_binding_frames_for_slot(binding, slot)
    local normalized_slot = normalize_action_slot(slot)
    if not normalized_slot then
        return
    end

    local frames = collect_click_binding_frames(binding)
    if not frames then
        return
    end

    for _, frame in ipairs(frames) do
        local frame_slot = get_action_slot_from_frame(frame)
        if frame_slot == normalized_slot then
            try_frame_refresh(frame, "UpdateIcon")
            try_frame_refresh(frame, "UpdateShown")
        end
    end
end

function addon:refresh_dominos_slot(slot)
    local normalized_slot = normalize_action_slot(slot)
    if not normalized_slot then
        return
    end

    local dominos = _G.Dominos
    local action_buttons = dominos and dominos.ActionButtons
    if not action_buttons or type(action_buttons.ForActionSlot) ~= "function" then
        return
    end

    pcall(action_buttons.ForActionSlot, action_buttons, normalized_slot, "UpdateShown")
    pcall(action_buttons.ForActionSlot, action_buttons, normalized_slot, "UpdateIcon")
end

function addon:sync_dragged_action_slots(button, slot_set)
    local binding = button and button.binding

    for _, slot in ipairs(sorted_slot_list(slot_set)) do
        if binding and binding ~= "" then
            addon:refresh_binding_frames_for_slot(binding, slot)
        end
        addon:refresh_dominos_slot(slot)
    end
end

-- Last-resort CLICK fallback when no live frame attributes are available.
-- Offsets intentionally reuse `multiactionbar_offsets` to stay in sync with the
-- primary MULTIACTIONBAR resolver and avoid drift in slot arithmetic.
local function resolve_multibar_click_slot(binding)
    if type(binding) ~= "string" then
        return nil, nil
    end

    local multibar_right = binding:match("^CLICK MultiBarRightActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBarRightActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBarRightActionButton(%d+):LeftButton$")
    if multibar_right then
        return multiactionbar_offsets[3] + tonumber(multibar_right), "multibar_right_click_fallback"
    end

    local multibar_left = binding:match("^CLICK MultiBarLeftActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBarLeftActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBarLeftActionButton(%d+):LeftButton$")
    if multibar_left then
        return multiactionbar_offsets[4] + tonumber(multibar_left), "multibar_left_click_fallback"
    end

    local multibar_bottom_right = binding:match("^CLICK MultiBarBottomRightActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBarBottomRightActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBarBottomRightActionButton(%d+):LeftButton$")
    if multibar_bottom_right then
        return multiactionbar_offsets[2] + tonumber(multibar_bottom_right), "multibar_bottom_right_click_fallback"
    end

    local multibar_bottom_left = binding:match("^CLICK MultiBarBottomLeftActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBarBottomLeftActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBarBottomLeftActionButton(%d+):LeftButton$")
    if multibar_bottom_left then
        return multiactionbar_offsets[1] + tonumber(multibar_bottom_left), "multibar_bottom_left_click_fallback"
    end

    local multibar5 = binding:match("^CLICK MultiBar5ActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBar5ActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBar5ActionButton(%d+):LeftButton$")
    if multibar5 then
        return multiactionbar_offsets[5] + tonumber(multibar5), "multibar5_click_fallback"
    end

    local multibar6 = binding:match("^CLICK MultiBar6ActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBar6ActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBar6ActionButton(%d+):LeftButton$")
    if multibar6 then
        return multiactionbar_offsets[6] + tonumber(multibar6), "multibar6_click_fallback"
    end

    local multibar7 = binding:match("^CLICK MultiBar7ActionButton(%d+)Hotkey:HOTKEY$")
        or binding:match("^CLICK MultiBar7ActionButton(%d+):HOTKEY$")
        or binding:match("^CLICK MultiBar7ActionButton(%d+):LeftButton$")
    if multibar7 then
        return multiactionbar_offsets[7] + tonumber(multibar7), "multibar7_click_fallback"
    end

    return nil, nil
end

local MAX_UNRESOLVED_CLICK_BINDINGS = 200

local function unresolved_count(bindings)
    local count = 0
    if type(bindings) ~= "table" then
        return count
    end
    for _ in pairs(bindings) do
        count = count + 1
    end
    return count
end

function addon:TrackUnresolvedClickBinding(binding, reason)
    if type(binding) ~= "string" or binding == "" then
        return
    end

    if type(self.unresolved_click_bindings) ~= "table" then
        self.unresolved_click_bindings = {}
    end

    local unresolved = self.unresolved_click_bindings
    local existing = unresolved[binding]
    if existing then
        existing.count = (existing.count or 0) + 1
        existing.reason = reason or existing.reason or "unknown"
        return
    end

    if unresolved_count(unresolved) >= MAX_UNRESOLVED_CLICK_BINDINGS then
        return
    end

    unresolved[binding] = {
        count = 1,
        reason = reason or "unknown",
    }
end

function addon:PrintUnresolvedClickBindings(limit)
    local unresolved = self.unresolved_click_bindings
    if type(unresolved) ~= "table" or not next(unresolved) then
        print("KeyUI: No unresolved CLICK bindings recorded.")
        return
    end

    local entries = {}
    for binding, info in pairs(unresolved) do
        table.insert(entries, {
            binding = binding,
            count = (type(info) == "table" and info.count) or 1,
            reason = (type(info) == "table" and info.reason) or "unknown",
        })
    end

    table.sort(entries, function(a, b)
        if a.count == b.count then
            return a.binding < b.binding
        end
        return a.count > b.count
    end)

    local max_items = tonumber(limit) or 15
    if max_items < 1 then
        max_items = 1
    end
    if max_items > MAX_UNRESOLVED_CLICK_BINDINGS then
        max_items = MAX_UNRESOLVED_CLICK_BINDINGS
    end

    print(("KeyUI: Unresolved CLICK bindings (%d tracked, showing up to %d):"):format(#entries, max_items))
    for i = 1, math.min(max_items, #entries) do
        local entry = entries[i]
        print(("  %dx [%s] %s"):format(entry.count, entry.reason, entry.binding))
    end
end

local function clear_resolved_click_binding(binding)
    if type(addon.unresolved_click_bindings) == "table" and type(binding) == "string" then
        addon.unresolved_click_bindings[binding] = nil
    end
end

function addon:resolve_addon_slot(binding)
    if type(binding) ~= "string" then
        return nil
    end

    local unresolved_reason = "no_resolver_match"
    local is_click_binding = binding:match("^CLICK ") ~= nil
    local is_elvui_binding = binding:match("^ELVUIBAR(%d+)BUTTON(%d+)$") ~= nil

    local function resolve_slot(slot, reason)
        if slot then
            clear_resolved_click_binding(binding)
            return slot
        end
        if reason then
            unresolved_reason = reason
        end
        return nil
    end

    -- Resolver priority (high -> low):
    -- 1) Live frame attributes (`frame_attr_chain`) from CLICK target/parents
    -- 2) HOTKEY child -> base frame fallback (`base_frame_hotkey_trim`)
    -- 3) Addon-specific numeric fallbacks (BT4/Dominos direct patterns)
    -- 4) Generic MultiBar CLICK fallback offsets as a last resort
    if binding:match("^CLICK BT4StanceButton(%d+):LeftButton$") then
        return nil
    end

    local frame_name = nil
    local click_frame_name = parse_click_binding(binding)
    if click_frame_name then
        frame_name = click_frame_name
    else
        local elv_bar, elv_button = binding:match("^ELVUIBAR(%d+)BUTTON(%d+)$")
        if elv_bar and elv_button then
            frame_name = ("ElvUI_Bar%sButton%s"):format(elv_bar, elv_button)
        end
    end

    if frame_name then
        local frame = _G[frame_name]
        local slot = get_action_slot_from_frame(frame)
        local resolved = resolve_slot(slot, "frame_attr_chain")
        if resolved then return resolved end

        local base_frame_name = frame_name:match("^(.-)Hotkey$")
        if base_frame_name and base_frame_name ~= "" then
            local base_frame = _G[base_frame_name]
            slot = get_action_slot_from_frame(base_frame)
            resolved = resolve_slot(slot, "base_frame_hotkey_trim")
            if resolved then return resolved end
        end
    end

    local bt4_slot = binding:match("^CLICK BT4Button(%d+):Keybind$")
    if bt4_slot then
        return resolve_slot(tonumber(bt4_slot), "bartender_numeric_fallback")
    end

    local dominos_slot = binding:match("^CLICK DominosActionButton(%d+):HOTKEY$")
    if dominos_slot then
        return resolve_slot(tonumber(dominos_slot), "dominos_numeric_fallback")
    end

    local dominos_hotkey_slot = binding:match("^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$")
    if dominos_hotkey_slot then
        return resolve_slot(tonumber(dominos_hotkey_slot), "dominos_hotkey_numeric_fallback")
    end

    local multibar_slot, multibar_reason = resolve_multibar_click_slot(binding)
    if multibar_slot then
        return resolve_slot(multibar_slot, multibar_reason)
    end

    if is_click_binding or is_elvui_binding then
        addon:TrackUnresolvedClickBinding(binding, unresolved_reason)
    end

    return nil
end

-- Handles processing for ElvUI action bar buttons
function addon:process_elvui(binding, button)
    local slot = addon:resolve_addon_slot(binding)
    if slot then
        button.slot = slot

        if HasAction(slot) then
            local texture = GetActionTexture(slot)
            if texture then
                button.active_slot = slot
                button.icon:SetTexture(texture)
                button.icon:Show()
            end
        end

        addon:update_assisted_combat_indicator(button, slot)
    end
end

-- Handles processing for Bartender 4 button bindings
function addon:process_bartender(binding, button)
    local slot = addon:resolve_addon_slot(binding)
    if slot then
        button.slot = slot

        if HasAction(slot) then
            local texture = GetActionTexture(slot)
            if texture then
                button.active_slot = slot
                button.icon:SetTexture(texture)
                button.icon:Show()
            end
        end

        addon:update_assisted_combat_indicator(button, slot)
    end
end

-- Handles processing for Dominos action button bindings
function addon:process_dominos(binding, button)
    local slot = addon:resolve_addon_slot(binding)
    if slot then
        button.slot = slot

        if HasAction(slot) then
            local texture = GetActionTexture(slot)
            if texture then
                button.active_slot = slot
                button.icon:SetTexture(texture)
                button.icon:Show()
            end
        end

        addon:update_assisted_combat_indicator(button, slot)
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
        button.short_key:SetFont(addon:GetCondensedFont(), addon:GetFontSize(1.0), "OUTLINE")
    else
        -- Use the Regular font for shorter text
        button.short_key:SetFont(addon:GetFont(), addon:GetFontSize(1.0), "OUTLINE")
    end
end

local function get_dominos_button_index_from_frame(frame_name, parent)
    local dominos_button_index = frame_name and (
        frame_name:match("^DominosActionButton(%d+)Hotkey$")
        or frame_name:match("^DominosActionButton(%d+)$")
    ) or nil

    if not dominos_button_index and parent and parent.GetName then
        local parent_name = parent:GetName()
        if type(parent_name) == "string" then
            dominos_button_index = parent_name:match("^DominosActionButton(%d+)Hotkey$")
                or parent_name:match("^DominosActionButton(%d+)$")
        end
    end

    return dominos_button_index
end

local function resolve_click_binding_label(binding)
    local frame_name = parse_click_binding(binding)
    if not frame_name then
        return nil
    end

    local frame = _G[frame_name]
    local parent = frame and frame.GetParent and frame:GetParent() or nil

    -- Dominos bar 1 can expose commandName=ACTIONBUTTONN; prefer Dominos label
    -- for Dominos frames to avoid regressing to the generic Blizzard wording.
    local dominos_button_index = get_dominos_button_index_from_frame(frame_name, parent)
    if dominos_button_index then
        return "Dominos Action Button " .. dominos_button_index
    end

    local command_name = nil
    if frame and frame.GetAttribute then
        command_name = frame:GetAttribute("commandName")
    end
    if (not command_name or command_name == "") and parent and parent.GetAttribute then
        command_name = parent:GetAttribute("commandName")
    end

    if command_name and command_name ~= "" then
        local readable = _G["BINDING_NAME_" .. command_name]
        if type(readable) == "string" and readable ~= "" then
            return readable
        end
    end

    return nil
end

-- Sets and displays the interface action label
function addon:create_action_labels(binding, button)
    -- Adjust the width of the readable_binding based on button width
    button.readable_binding:SetWidth(button:GetWidth() - 4)

    local binding_name = resolve_click_binding_label(binding)
    local loaded_integrations = addon.loaded_integrations or {}

    -- Check if ElvUI is loaded and handle its bindings
    if loaded_integrations.ElvUI and not binding_name then
        local function resolve_elvui_binding_name(bar_index, button_index)
            local elv_binding = ("ELVUIBAR%sBUTTON%s"):format(bar_index, button_index)
            return _G["BINDING_NAME_" .. elv_binding] or ("ElvUI ActionBar " .. bar_index .. " Button " .. button_index)
        end

        if binding:match("^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$") then
            local bar_index, button_index = binding:match("^CLICK ElvUI_Bar(%d+)Button(%d+):LeftButton$")
            binding_name = resolve_elvui_binding_name(bar_index, button_index)
        elseif binding:match("^ELVUIBAR(%d+)BUTTON(%d+)$") then
            local bar_index, button_index = binding:match("^ELVUIBAR(%d+)BUTTON(%d+)$")
            binding_name = resolve_elvui_binding_name(bar_index, button_index)
        end
    end

    -- Check if Bartender4 is loaded and handle its bindings
    if loaded_integrations.Bartender4 and not binding_name then
        if binding:match("^CLICK BT4Button(%d+):Keybind$") then
            local button_index = binding:match("^CLICK BT4Button(%d+):Keybind$")
            binding_name = _G["BINDING_NAME_" .. binding] or ("Bartender Action Button " .. button_index)
        elseif binding:match("^CLICK BT4StanceButton(%d+):LeftButton$") then
            local stance_index = binding:match("^CLICK BT4StanceButton(%d+):LeftButton$")
            binding_name = _G["BINDING_NAME_" .. binding] or ("Bartender Stance Button " .. stance_index)
        end
    end

    -- Check if Dominos is loaded and handle its bindings
    if loaded_integrations.Dominos and not binding_name then
        if binding:match("^CLICK DominosActionButton(%d+):HOTKEY$") then
            local button_index = binding:match("^CLICK DominosActionButton(%d+):HOTKEY$")
            binding_name = "Dominos Action Button " .. button_index
        elseif binding:match("^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$") then
            local button_index = binding:match("^CLICK DominosActionButton(%d+)Hotkey:HOTKEY$")
            binding_name = "Dominos Action Button " .. button_index
        end
    end

    -- Check if BindPad is loaded and handle its bindings
    if loaded_integrations.BindPad and not binding_name then
        if binding:match("^CLICK BindPadMacro:([^:]+)$") then
            local macro_name = binding:match("^CLICK BindPadMacro:([^:]+)$")
            binding_name = "BindPad Macro: " .. macro_name

        elseif binding:match("^CLICK BindPadKey:SPELL (.+)$") then
            local spell_name = binding:match("^CLICK BindPadKey:SPELL (.+)$")
            binding_name = "BindPad Spell: " .. spell_name

        elseif binding:match("^CLICK BindPadKey:ITEM (.+)$") then
            local item_name = binding:match("^CLICK BindPadKey:ITEM (.+)$")
            binding_name = "BindPad Item: " .. item_name
        elseif binding:match("^CLICK BindPadKey:MACRO (.+)$") then
            local macro_name = binding:match("^CLICK BindPadKey:MACRO (.+)$")
            binding_name = "BindPad Macro Key: " .. macro_name
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
    local perf_start = get_perf_timestamp()

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

    if perf_start then
        local perf_end = get_perf_timestamp()
        if perf_end then
            addon:RecordPerformanceSample("refresh_keys", perf_end - perf_start)
        end
    end
end

local function refresh_modifier_layer_for_collection(collection)
    if type(collection) ~= "table" then
        return 0
    end

    local changed_count = 0
    for i = 1, #collection do
        local button = collection[i]
        if button then
            local old_binding = button.binding or ""
            local new_binding = addon:get_binding(button.raw_key) or ""

            if old_binding ~= new_binding then
                addon:set_key(button)
                changed_count = changed_count + 1
            else
                button.binding = new_binding

                if new_binding == "" then
                    button.highlight:Hide()
                    button.readable_binding:Hide()
                    button.readable_binding:SetText("")

                    if keyui_settings.show_empty_binds then
                        addon:update_empty_binds(button)
                    end

                    if keyui_settings.listen_to_modifier == true then
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

                addon:update_button_key_text(button)
            end
        end
    end

    return changed_count
end

function addon:refresh_modifier_layers()
    local changed_count = 0
    if addon.is_keyboard_visible ~= false then
        changed_count = changed_count + refresh_modifier_layer_for_collection(addon.keys_keyboard)
    end
    if addon.is_mouse_visible ~= false then
        changed_count = changed_count + refresh_modifier_layer_for_collection(addon.keys_mouse)
    end
    if addon.is_controller_visible ~= false then
        changed_count = changed_count + refresh_modifier_layer_for_collection(addon.keys_controller)
    end
    return changed_count
end

function addon:update_modifier_string()
    local modifiers = {}
    if addon.modif.ALT then table.insert(modifiers, "ALT-") end
    if addon.modif.CTRL then table.insert(modifiers, "CTRL-") end
    if addon.modif.SHIFT then table.insert(modifiers, "SHIFT-") end
    addon.current_modifier_string = table.concat(modifiers)
end

local function add_button_to_lookup(lookup, button)
    if not lookup or not button or not button.raw_key then
        return
    end

    local existing = lookup[button.raw_key]
    if not existing then
        lookup[button.raw_key] = button
        return
    end

    if existing.raw_key then
        lookup[button.raw_key] = { existing, button }
        return
    end

    table.insert(existing, button)
end

local function for_each_lookup_button(entry, callback)
    if not entry or type(callback) ~= "function" then
        return
    end

    if entry.raw_key then
        callback(entry)
        return
    end

    for i = 1, #entry do
        local button = entry[i]
        if button then
            callback(button)
        end
    end
end

local function pick_primary_lookup_button(entry)
    if not entry then
        return nil
    end
    if entry.raw_key then
        return entry
    end
    for i = 1, #entry do
        local button = entry[i]
        if button and button.active_slot then
            return button
        end
    end
    for i = 1, #entry do
        if entry[i] then
            return entry[i]
        end
    end
    return nil
end

-- Keypress visualization: builds a lookup from raw_key to one-or-many buttons for all visible devices
function addon:build_key_lookup()
    addon.key_lookup = {}
    if addon.is_keyboard_visible ~= false then
        for i = 1, #addon.keys_keyboard do
            local button = addon.keys_keyboard[i]
            add_button_to_lookup(addon.key_lookup, button)
        end
    end
    if addon.is_mouse_visible ~= false then
        for i = 1, #addon.keys_mouse do
            local button = addon.keys_mouse[i]
            add_button_to_lookup(addon.key_lookup, button)
        end
    end
    if addon.is_controller_visible ~= false then
        for i = 1, #addon.keys_controller do
            local button = addon.keys_controller[i]
            add_button_to_lookup(addon.key_lookup, button)
        end
    end
end

-- Interval in seconds for polling IsKeyDown to detect key release
local KEYPRESS_POLL_INTERVAL = 0.05

-- Shows a border highlight on a KeyUI button while its key is held down
local function flash_keypress_highlight(button, key)
    if not button.keypress_highlight then return end
    -- Skip modifier keys — they are already highlighted via the modifier system
    if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then return end
    button.keypress_highlight:Show()
    -- Cancel any existing ticker for this button
    if button.keypress_ticker then button.keypress_ticker:Cancel() end
    -- Poll IsKeyDown to hide highlight when key is released
    button.keypress_ticker = C_Timer.NewTicker(KEYPRESS_POLL_INTERVAL, function()
        if not IsKeyDown(key) then
            button.keypress_highlight:Hide()
            button.keypress_ticker:Cancel()
            button.keypress_ticker = nil
        end
    end)
end

-- Hides the keypress highlight on a button
local function hide_keypress_highlight(button)
    if not button.keypress_highlight then return end
    button.keypress_highlight:Hide()
end

-- Creates and manages the invisible input frame for keypress visualization
function addon:enable_keypress_input()
    if addon.keypress_frame then
        addon.keypress_frame:Show()
        addon.keypress_frame:EnableKeyboard(true)
        return
    end

    local frame = CreateFrame("Frame", "KeyUIKeypressFrame", UIParent)
    frame:SetSize(1, 1)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(true)

    frame:SetScript("OnKeyDown", function(_, key)
        if not addon.key_lookup then return end
        local lookup_entry = addon.key_lookup[key]
        local primary_button = pick_primary_lookup_button(lookup_entry)
        for_each_lookup_button(lookup_entry, function(button)
            flash_keypress_highlight(button, key)
        end)

        -- Also show the PushedTexture on the mapped action bar button
        if primary_button and primary_button.active_slot and keyui_settings.show_pushed_texture then
            addon:show_pushed_texture(primary_button.active_slot)
            -- Hide pushed texture when key is released
            if addon.pushed_ticker then addon.pushed_ticker:Cancel() end
            addon.pushed_ticker = C_Timer.NewTicker(KEYPRESS_POLL_INTERVAL, function()
                if not IsKeyDown(key) then
                    if addon.current_pushed_button then
                        addon.current_pushed_button:Hide()
                        addon.current_pushed_button = nil
                    end
                    addon.pushed_ticker:Cancel()
                    addon.pushed_ticker = nil
                end
            end)
        end
    end)

    addon.keypress_frame = frame
end

-- Disables the keypress input frame
function addon:disable_keypress_input()
    if addon.keypress_frame then
        addon.keypress_frame:EnableKeyboard(false)
        addon.keypress_frame:Hide()
    end
    -- Cancel pushed texture ticker
    if addon.pushed_ticker then
        addon.pushed_ticker:Cancel()
        addon.pushed_ticker = nil
    end
    if addon.current_pushed_button then
        addon.current_pushed_button:Hide()
        addon.current_pushed_button = nil
    end
    -- Clear any active highlights and cancel their tickers
    if addon.key_lookup then
        for _, entry in pairs(addon.key_lookup) do
            for_each_lookup_button(entry, function(button)
                if button.keypress_ticker then
                    button.keypress_ticker:Cancel()
                    button.keypress_ticker = nil
                end
                hide_keypress_highlight(button)
            end)
        end
    end
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

local function refresh_after_modifier_change()
    if keyui_settings.dynamic_modifier then
        addon:refresh_keys()
        return
    end

    local changed_count = addon:refresh_modifier_layers()
    if changed_count > 0 and addon.current_hovered_button then
        addon:button_mouse_over(addon.current_hovered_button)
    end
end

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
    refresh_after_modifier_change()
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
    refresh_after_modifier_change()
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
        self:Hide()
    elseif button == "LeftButton" then
        self:StartMoving()
        addon.is_moving = true -- Add a flag to indicate the frame is being moved
    end
end

function addon:handle_release(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        addon.is_moving = false -- Reset the flag when the movement is stopped
    end
end

-- ============================================================================
-- MenuUtil Context Menu System (Modern WoW 11.0.0+ API)
-- ============================================================================

-- Helper function: Build spells submenu
local function build_spells_submenu(parentMenu)
    -- Guard: Ensure addon.spells is loaded
    if not addon.spells or next(addon.spells) == nil then
        -- Fallback: Load spellbook on-demand if not already loaded
        addon:load_spellbook()
    end

    for tabName, _ in pairs(addon.spells) do
        local tabButton = parentMenu:CreateButton(tabName)

        -- Add individual spells for this tab
        for _, spell in pairs(addon.spells[tabName]) do
            local spell_name = spell.name
            local spell_id = spell.id

            -- IMPORTANT: Check spell_id exists BEFORE calling any APIs
            if spell_id then
                local is_known = false
                local spell_icon = nil

                -- Version-aware spell checking
                if API_COMPAT.has_modern_spellbook then
                    -- RETAIL: Use C_SpellBook API
                    is_known = C_SpellBook.IsSpellKnown(spell_id)
                    spell_icon = C_Spell.GetSpellTexture(spell_id)
                elseif API_COMPAT.has_legacy_spell_api then
                    -- ANNIVERSARY: Use legacy API
                    is_known = IsSpellKnown(spell_id)
                    spell_icon = GetSpellTexture(spell_id)
                end

            if is_known then
                local spellButton = tabButton:CreateButton(spell_name, function()
                    local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                    local spell = "Spell " .. spell_name
                    local binding_name = addon.current_clicked_key.readable_binding:GetText()
                    local actionbutton = addon.current_clicked_key.binding
                    local targetSlot = addon.current_slot or addon.action_slot_mapping[actionbutton]

                    if targetSlot ~= nil then
                        if addon:IsRetailActionMutationBlocked() then
                            addon:WarnRetailActionMutationBlockedOnce()
                            return
                        end

                        -- Version-aware spell pickup
                        if API_COMPAT.has_modern_spellbook then
                            C_Spell.PickupSpell(spell_id)
                        else
                            PickupSpell(spell_id)  -- Legacy API
                        end
                        PlaceAction(targetSlot)
                        ClearCursor()
                        print("KeyUI: Bound |cffa335ee" .. spell_name .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
                    else
                        SetBinding(key, spell)
                        SaveBindings(2)
                        print("KeyUI: Bound |cffa335ee" .. spell_name .. "|r to |cffff8000" .. key .. "|r")
                    end
                end)

                -- Add icon via initializer
                if spell_icon then
                    spellButton:AddInitializer(function(button, description, menu)
                        local iconTexture = button:AttachTexture()
                        iconTexture:SetSize(16, 16)
                        iconTexture:SetPoint("LEFT", button, "LEFT", 4, 0)
                        iconTexture:SetTexture(spell_icon)

                        if button.fontString then
                            button.fontString:ClearAllPoints()
                            button.fontString:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
                        end
                    end)
                end
            end
            end  -- Close the new 'if spell_id then' block
        end
    end

    -- Assisted Combat (Single-Button Assistant) entry at the bottom of the spells menu
    -- Only available in Retail
    if API_COMPAT.has_modern_spellbook and C_AssistedCombat and C_AssistedCombat.IsAvailable and C_AssistedCombat.IsAvailable() and C_ActionBar and C_ActionBar.FindAssistedCombatActionButtons then
        local acSpellID = C_AssistedCombat.GetActionSpell()
        local acIcon = acSpellID and C_Spell.GetSpellTexture(acSpellID)

        local acButton = parentMenu:CreateButton(_G["ASSISTED_COMBAT_ROTATION"] or "Assisted Combat", function()
            local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")

            if addon.current_slot ~= nil then
                if addon:IsRetailActionMutationBlocked() then
                    addon:WarnRetailActionMutationBlockedOnce()
                    return
                end

                -- Copy the Assisted Combat action from an existing slot to the target slot
                local acSlots = C_ActionBar.FindAssistedCombatActionButtons()
                if acSlots and #acSlots > 0 then
                    PickupAction(acSlots[1])
                    PlaceAction(addon.current_slot)
                    ClearCursor()
                    local acName = _G["ASSISTED_COMBAT_ROTATION"] or "Assisted Combat"
                    print("KeyUI: Bound |cffa335ee" .. acName .. "|r to |cffff8000" .. key .. "|r")
                end
            else
                local acName = _G["ASSISTED_COMBAT_ROTATION"] or "Assisted Combat"
                print("KeyUI: " .. acName .. " can only be bound to action bar slots.")
                print("KeyUI: Right-click on an action bar button (ACTIONBUTTON1-12 etc.), not on unbound keys.")
            end
        end)

        if acIcon then
            acButton:AddInitializer(function(button, description, menu)
                local iconTexture = button:AttachTexture()
                iconTexture:SetSize(16, 16)
                iconTexture:SetPoint("LEFT", button, "LEFT", 4, 0)
                iconTexture:SetTexture(acIcon)

                if button.fontString then
                    button.fontString:ClearAllPoints()
                    button.fontString:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
                end
            end)
        end
    end
end

-- Helper function: Build macros submenu
local function build_macros_submenu(parentMenu)
    -- General Macros (1-36)
    local generalMacroMenu = parentMenu:CreateButton("General Macro")
    for i = 1, 36 do
        local title, icon, _ = GetMacroInfo(i)
        if title then
            local macroButton = generalMacroMenu:CreateButton(title, function()
                local actionbutton = addon.current_clicked_key.binding
                local actionSlot = addon.current_slot or addon.action_slot_mapping[actionbutton]
                local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                local command = "Macro " .. title
                local binding_name = addon.current_clicked_key.readable_binding:GetText()

                if actionSlot then
                    if addon:IsRetailActionMutationBlocked() then
                        addon:WarnRetailActionMutationBlockedOnce()
                        return
                    end

                    PickupMacro(title)
                    PlaceAction(actionSlot)
                    ClearCursor()
                    print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
                else
                    SetBinding(key, command)
                    SaveBindings(2)
                    print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                end
            end)

            -- Add icon if available
            if icon then
                macroButton:AddInitializer(function(button, description, menu)
                    local iconTexture = button:AttachTexture()
                    iconTexture:SetSize(16, 16)
                    iconTexture:SetPoint("LEFT", button, "LEFT", 4, 0)
                    iconTexture:SetTexture(icon)

                    if button.fontString then
                        button.fontString:ClearAllPoints()
                        button.fontString:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
                    end
                end)
            end
        end
    end

    -- Player Macros (37-54)
    local playerMacroMenu = parentMenu:CreateButton("Player Macro")
    for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local title, icon, _ = GetMacroInfo(i)
        if title then
            local macroButton = playerMacroMenu:CreateButton(title, function()
                local actionbutton = addon.current_clicked_key.binding
                local actionSlot = addon.current_slot or addon.action_slot_mapping[actionbutton]
                local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                local command = "Macro " .. title
                local binding_name = addon.current_clicked_key.readable_binding:GetText()

                if actionSlot then
                    if addon:IsRetailActionMutationBlocked() then
                        addon:WarnRetailActionMutationBlockedOnce()
                        return
                    end

                    PickupMacro(title)
                    PlaceAction(actionSlot)
                    ClearCursor()
                    print("KeyUI: Bound Macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r (" .. binding_name .. ")")
                else
                    SetBinding(key, command)
                    SaveBindings(2)
                    print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                end
            end)

            if icon then
                macroButton:AddInitializer(function(button, description, menu)
                    local iconTexture = button:AttachTexture()
                    iconTexture:SetSize(16, 16)
                    iconTexture:SetPoint("LEFT", button, "LEFT", 4, 0)
                    iconTexture:SetTexture(icon)

                    if button.fontString then
                        button.fontString:ClearAllPoints()
                        button.fontString:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
                    end
                end)
            end
        end
    end
end

-- Helper function: Build interface bindings submenu
local function build_interface_bindings_submenu(parentMenu)
    -- Dynamically enumerate all keybinding categories and commands from WoW
    local categories = {}       -- { [categoryKey] = { {command, readableName}, ... } }
    local category_order = {}   -- preserve WoW's category order

    for i = 1, GetNumBindings() do
        local command, category = GetBinding(i)
        if command and category
            and not command:find("HEADER_BLANK") and not category:find("HEADER_BLANK")
            and not command:find("^PREFACE_") then
            if not categories[category] then
                categories[category] = {}
                table.insert(category_order, category)
            end
            local readable = _G["BINDING_NAME_" .. command] or command
            table.insert(categories[category], { command, readable })
        end
    end

    for _, category in ipairs(category_order) do
        local categoryName = _G[category] or category
        local categoryMenu = parentMenu:CreateButton(categoryName)

        for _, binding in ipairs(categories[category]) do
            local binding_name = binding[1]
            local binding_readable = binding[2]

            categoryMenu:CreateButton(binding_readable, function()
                local key = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
                SetBinding(key, binding_name)
                SaveBindings(2)
                print("KeyUI: Bound |cffa335ee" .. binding_readable .. "|r to |cffff8000" .. key .. "|r")
            end)
        end
    end
end

-- Main context menu generator for MenuUtil
function addon.context_menu_generator(owner, rootDescription)
    -- Spells submenu
    local spellsMenu = rootDescription:CreateButton(_G["SPELLS"] or "Spells")
    build_spells_submenu(spellsMenu)

    -- Macros submenu
    local macrosMenu = rootDescription:CreateButton(_G["MACRO"])
    build_macros_submenu(macrosMenu)

    -- Interface Bindings submenu
    local uiBindMenu = rootDescription:CreateButton(_G["INTERFACE_LABEL"])
    build_interface_bindings_submenu(uiBindMenu)

    -- Unbind action (direct button)
    rootDescription:CreateButton(_G["UNBIND"], function()
        if addon.current_clicked_key.raw_key ~= "" then
            SetBinding(addon.current_modifier_string .. (addon.current_clicked_key.raw_key or ""))
            SaveBindings(2)
            local keyText = addon.current_modifier_string .. (addon.current_clicked_key.raw_key or "")
            print("KeyUI: Unbound key |cffff8000" .. keyText .. "|r")
        end
    end)
end

-- Event frame to handle all relevant events
local eventFrame = CreateFrame("Frame")
local function reset_pending_updates()
    addon.pending = {
        bindings = false,
        layout = false,
        keys = false,
        spellbook = false,
        tooltip = false,
        cooldowns = false,
        usable = false,
        counts = false,
        slot_changes = {},
    }
end

reset_pending_updates()
addon.flush_scheduled = false

local function mark_pending(flag)
    addon.pending[flag] = true
end

local function mark_slot_changed(slot)
    if type(slot) == "number" then
        addon.pending.slot_changes[slot] = true
    end
    mark_pending("keys")
end

local function has_ambiguous_slot_mappings()
    local loaded = addon.loaded_integrations or {}
    return loaded.Dominos or loaded.Bartender4 or loaded.ElvUI
end

local flush_pending_updates
local function schedule_flush()
    if addon.flush_scheduled then
        return
    end

    addon.flush_scheduled = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0, flush_pending_updates)
    else
        flush_pending_updates()
    end
end

flush_pending_updates = function()
    addon.flush_scheduled = false

    local pending = addon.pending
    local should_refresh_layouts = pending.layout or pending.bindings
    local should_refresh_keys = pending.keys
    local should_refresh_tooltip = pending.tooltip
    local should_reload_spellbook = pending.spellbook
    local should_refresh_cooldowns = pending.cooldowns
    local should_refresh_usable = pending.usable
    local should_refresh_counts = pending.counts
    local pending_slot_changes = pending.slot_changes

    reset_pending_updates()

    -- Avoid expensive spellbook rebuilds while closed unless we do not have any cache yet.
    if should_reload_spellbook and (addon.open or not addon.spells or next(addon.spells) == nil) then
        addon:load_spellbook()
    end

    if not addon.open then
        return
    end

    if should_refresh_layouts then
        addon:refresh_layouts()
    elseif should_refresh_keys then
        local did_partial_refresh = false
        if pending_slot_changes and next(pending_slot_changes) and not has_ambiguous_slot_mappings() then
            did_partial_refresh = addon:refresh_keys_for_slots(pending_slot_changes)
        end
        if not did_partial_refresh then
            addon:refresh_keys()
        end
    end

    if should_refresh_cooldowns then
        addon:refresh_cooldowns()
    end

    if should_refresh_usable then
        addon:refresh_usable()
    end

    if should_refresh_counts then
        addon:refresh_counts()
    end

    if should_refresh_tooltip and addon.current_hovered_button then
        addon:button_mouse_over(addon.current_hovered_button)
    end
end

-- Range indicator polling (0.1 s throttle, mirrors Blizzard Classic approach)
do
    local t = 0
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(_, elapsed)
        t = t + elapsed
        if t >= 0.1 then
            t = 0
            addon:refresh_range()
        end
    end)
end

local shared_events = {
    "UPDATE_BONUS_ACTIONBAR",
    "ACTIONBAR_PAGE_CHANGED",
    "ACTIVE_TALENT_GROUP_CHANGED",
    "SPELLS_CHANGED",
    "UPDATE_BINDINGS",
    "MODIFIER_STATE_CHANGED",
    "ACTIONBAR_SLOT_CHANGED",
    "ACTIONBAR_UPDATE_STATE",
    "UPDATE_SHAPESHIFT_FORM",
    "UPDATE_SHAPESHIFT_FORMS",
    "UPDATE_SHAPESHIFT_USABLE",
    "UPDATE_SHAPESHIFT_COOLDOWN",
    "ACTIONBAR_UPDATE_USABLE",
    "SPELL_UPDATE_COOLDOWN",
    "SPELL_UPDATE_CHARGES",
    "PET_BAR_UPDATE",
    "PET_BAR_UPDATE_COOLDOWN",
    "PET_BAR_UPDATE_USABLE",
    "UNIT_PET",
    "UPDATE_VEHICLE_ACTIONBAR",
    "ADDON_LOADED",
    "PLAYER_REGEN_ENABLED",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_LOGOUT",
    "PLAYER_LOGIN",
}

for _, event_name in ipairs(shared_events) do
    addon.compat.register_event(eventFrame, event_name)
end
addon.compat.register_event(eventFrame, "BINDINGS_LOADED")

-- Shared event handler function
eventFrame:SetScript("OnEvent", function(self, event, ...)
    addon:RecordPerformanceEvent(event)

    if event == "PLAYER_LOGIN" then
        refresh_loaded_integrations()
        initialize_keybind_patterns()

        addon.class_name = UnitClassBase("player")
        addon.bonusbar_offset = GetBonusBarOffset()
        addon.current_actionbar_page = GetActionBarPage()

        if not addon.spells or next(addon.spells) == nil then
            addon:load_spellbook()
        end
        return
    end

    if event == "ADDON_LOADED" then
        local loaded_addon_name = ...
        if loaded_addon_name and addon_pattern_registry[loaded_addon_name] then
            addon.loaded_integrations[loaded_addon_name] = true
            register_addon_patterns(loaded_addon_name)
            mark_pending("layout")
            schedule_flush()
        end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        addon.in_combat = false
        addon.retail_action_block_warned_this_combat = false
        addon:FlushDeferredUiUpdates()
        if addon.open and keyui_settings.show_keypress_highlight then
            addon:enable_keypress_input()
        end
        return
    end

    if event == "PLAYER_REGEN_DISABLED" then
        addon.in_combat = true
        addon.retail_action_block_warned_this_combat = false
        addon:disable_keypress_input()
        if addon.open and not keyui_settings.stay_open_in_combat then
            addon:hide_all_frames()
        end
        return
    end

    if event == "PLAYER_LOGOUT" then
        addon:save_keyboard_position()
        addon:save_mouse_position()
        addon:save_controller_position()
        return
    end

    if event == "MODIFIER_STATE_CHANGED" then
        local key, state = ...

        if addon.keyboard_locked ~= false and addon.mouse_locked ~= false and addon.controller_locked ~= false then
            if keyui_settings.listen_to_modifier == true then
                if addon.alt_checkbox == false and addon.ctrl_checkbox == false and addon.shift_checkbox == false then
                    if state == 1 then
                        handle_key_press(key)
                    else
                        handle_key_release(key)
                    end

                    if addon.current_hovered_button then
                        mark_pending("tooltip")
                        schedule_flush()
                    end

                    if addon.current_pushed_button then
                        addon.current_pushed_button:Hide()
                    end
                end
            end
        end
        return
    end

    if event == "UPDATE_BONUS_ACTIONBAR" then
        addon.bonusbar_offset = GetBonusBarOffset()
        mark_pending("keys")
    elseif event == "ACTIONBAR_PAGE_CHANGED" then
        addon.current_actionbar_page = GetActionBarPage()
        mark_pending("keys")
    elseif event == "ACTIONBAR_SLOT_CHANGED" then
        mark_slot_changed(...)
    elseif event == "UPDATE_BINDINGS" or event == "BINDINGS_LOADED" then
        mark_pending("bindings")
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        mark_pending("layout")
        if addon.open or not addon.spells or next(addon.spells) == nil then
            mark_pending("spellbook")
        end
    elseif event == "SPELLS_CHANGED" then
        if addon.open or not addon.spells or next(addon.spells) == nil then
            mark_pending("spellbook")
        end
        mark_pending("keys")
    elseif event == "UNIT_PET" then
        local unit = ...
        if unit == "player" then
            mark_pending("keys")
        else
            return
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        mark_pending("cooldowns")
    elseif event == "SPELL_UPDATE_CHARGES" then
        mark_pending("cooldowns")
        mark_pending("counts")
    elseif event == "ACTIONBAR_UPDATE_USABLE" then
        mark_pending("usable")
    elseif event == "ACTIONBAR_UPDATE_STATE" or event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS" or event == "UPDATE_SHAPESHIFT_USABLE" or event == "UPDATE_SHAPESHIFT_COOLDOWN" or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "PET_BAR_UPDATE" or event == "PET_BAR_UPDATE_COOLDOWN" or event == "PET_BAR_UPDATE_USABLE" then
        mark_pending("keys")
        mark_pending("usable")
    else
        return
    end

    schedule_flush()
end)

-- SlashCmdList["KeyUI"] - Registers a command to load the addon.
SLASH_KeyUI1 = "/kui"
SLASH_KeyUI2 = "/keyui"
local function print_keyui_command_help()
    print("KeyUI: /keyui")
    print("KeyUI: /keyui help")
    print("KeyUI: /keyui perf [on|off|reset]")
    print("KeyUI: /keyui diag [limit]")
    print("KeyUI: /keyui diagreset")
end

SlashCmdList["KeyUI"] = function(msg)
    local trimmed = type(msg) == "string" and msg:match("^%s*(.-)%s*$") or ""
    if trimmed == "" then
        addon:load()
        return
    end

    local command, argument = trimmed:match("^(%S+)%s*(.-)%s*$")
    command = command and command:lower() or ""
    argument = argument or ""

    if command == "help" then
        print_keyui_command_help()
        return
    end

    if command == "open" or command == "toggle" then
        addon:load()
        return
    end

    if command == "perf" then
        local mode = argument:lower()
        if mode == "on" then
            keyui_settings.performance_debug = true
            addon:ResetPerformanceStats()
            addon:UpdatePerformanceOverlayVisibility()
            print("KeyUI: performance_debug enabled.")
        elseif mode == "off" then
            keyui_settings.performance_debug = false
            addon:UpdatePerformanceOverlayVisibility()
            print("KeyUI: performance_debug disabled.")
        elseif mode == "reset" then
            addon:ResetPerformanceStats()
            addon:UpdatePerformanceOverlayText()
            print("KeyUI: performance stats reset.")
        else
            keyui_settings.performance_debug = not keyui_settings.performance_debug
            addon:UpdatePerformanceOverlayVisibility()
            print(("KeyUI: performance_debug %s."):format(keyui_settings.performance_debug and "enabled" or "disabled"))
        end
        return
    end

    if command == "diag" then
        addon:PrintUnresolvedClickBindings(tonumber(argument) or 15)
        return
    end

    if command == "diagreset" then
        addon.unresolved_click_bindings = {}
        print("KeyUI: unresolved CLICK binding diagnostics cleared.")
        return
    end

    print(("KeyUI: Unknown command '%s'."):format(command))
    print_keyui_command_help()
end

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
