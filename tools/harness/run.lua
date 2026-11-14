-- Loads one copy of KeyUI into the stand-in client (wow.lua) and plays a fixed session:
-- open, modifiers, paging, slot and binding changes, late icons, Alt+Z, combat, closing
-- and reopening. After every step it prints what each bound key shows and checks it
-- against an oracle: what the game state says the key should show and what a click on it
-- should use.
--
--   lua5.1 tools/harness/run.lua <addon dir> [dump|check]
--
-- dump   prints the per-step state, for diffing two versions (check.sh diff)
-- check  prints only problems: Lua errors, blocked actions, oracle mismatches.
--        Exit status 1 when there are any.
-- KEYUI_FLAVOR selects the client (retail, forever, mists, anniversary, classic_era).

local addon_dir = assert(arg[1], "usage: run.lua <addon dir> [dump|check]")
local mode = arg[2] or "check"
local harness_dir = arg[0]:match("^(.*)/[^/]+$") or "."

local H = dofile(harness_dir .. "/wow.lua")
local out = {}
local function emit(line) out[#out + 1] = line end

-- Bartender4 loads before KeyUI (folders load alphabetically). Its button pages by
-- rewriting its "action" attribute from a state driver; no Blizzard event says so.
H.state.addons.Bartender4 = true
local bt4_button = CreateFrame("CheckButton", "BT4Button13", UIParent, "SecureActionButtonTemplate")
bt4_button:SetAttribute("action", 13)

---------------------------------------------------------------------------
-- Load the addon the way the client does
---------------------------------------------------------------------------

local addon = {}
local toc = assert(io.open(addon_dir .. "/KeyUI.toc"))
for line in toc:lines() do
    line = line:gsub("\r", ""):gsub("%s+$", "")
    if line ~= "" and not line:match("^#") and not line:match("%.xml$") then
        local path = addon_dir .. "/" .. line:gsub("\\", "/")
        local chunk = assert(loadfile(path))
        H.protected_call(chunk, "KeyUI", addon)
    end
end
toc:close()

local function pick(layouts, preferred)
    if layouts[preferred] then return preferred end
    local names = {}
    for name in pairs(layouts) do names[#names + 1] = name end
    table.sort(names)
    return names[1]
end
local kb = pick(addon.default_keyboard_layouts, "QWERTZ_100%")
local mouse = pick(addon.default_mouse_layouts, "Layout_4x3")
local pad = pick(addon.default_controller_layouts, "xbox")

-- SavedVariables arrive after the files ran and before ADDON_LOADED.
keyui_settings = {
    show_keyboard = true,
    show_mouse = true,
    show_controller = true,
    tutorial_completed = true,
    stay_open_in_combat = false,
    layout_current_keyboard = { [kb] = addon.default_keyboard_layouts[kb] },
    key_bind_settings_keyboard = { currentboard = kb },
    layout_current_mouse = { [mouse] = addon.default_mouse_layouts[mouse] },
    key_bind_settings_mouse = { currentboard = mouse },
    layout_current_controller = { [pad] = addon.default_controller_layouts[pad] },
    key_bind_settings_controller = { currentboard = pad },
}

---------------------------------------------------------------------------
-- Game state
---------------------------------------------------------------------------

local S = H.state
S.spells = {
    Fireball = { id = 133, texture = 135812 },
    Frostbolt = { id = 116, texture = 135846 },
    Blink = { id = 1953, texture = 135736 },
    ["Arcane Shot"] = { id = 3044, texture = nil },   -- icon not loaded yet
}
S.macros = { Heal = 135907 }

local function spell_action(id, texture) return { kind = "spell", id = id, texture = texture } end
S.actions = {
    [1] = spell_action(133, 135812),
    [2] = spell_action(116, 135846),
    [3] = { kind = "item", id = 6948, texture = nil },  -- item whose icon arrives later
    [4] = spell_action(1953, 135736),
    -- 5 empty
    [6] = spell_action(2139, 135856),
    [13] = spell_action(1459, 135932),                 -- page 2 slot 1, Bartender BT4Button13
    [14] = spell_action(1460, 135933),
    [25] = spell_action(122, 135848),                  -- MULTIACTIONBAR3BUTTON1
    [61] = spell_action(118, 136071),                  -- MULTIACTIONBAR1BUTTON1
    [62] = spell_action(475, 136082),                  -- MULTIACTIONBAR1BUTTON2
    [73] = spell_action(1752, 132282),                 -- bonus bar 1 (stealth) slot 1
}
S.bindings = {
    ["1"] = "ACTIONBUTTON1", ["2"] = "ACTIONBUTTON2", ["3"] = "ACTIONBUTTON3",
    ["4"] = "ACTIONBUTTON4", ["5"] = "ACTIONBUTTON5", ["6"] = "ACTIONBUTTON6",
    ["SHIFT-1"] = "MULTIACTIONBAR1BUTTON1", ["SHIFT-2"] = "MULTIACTIONBAR3BUTTON1",
    ["CTRL-1"] = "MULTIACTIONBAR1BUTTON2", ["ALT-CTRL-1"] = "Spell Blink",
    ["Q"] = "Spell Fireball", ["E"] = "Macro Heal", ["R"] = "Spell Arcane Shot",
    ["W"] = "MOVEFORWARD", ["F"] = "CLICK BT4Button13:Keybind",
    ["F1"] = "ACTIONBUTTON2", ["SHIFT-F1"] = "MULTIACTIONBAR1BUTTON1",
    ["BUTTON3"] = "ACTIONBUTTON4", ["PADDUP"] = "ACTIONBUTTON1", ["PADLSHOULDER"] = "Spell Frostbolt",
}

---------------------------------------------------------------------------
-- Oracle
---------------------------------------------------------------------------

local MULTIBAR_OFFSETS = { [1] = 60, [2] = 48, [3] = 24, [4] = 36, [5] = 144, [6] = 156, [7] = 168 }

local function modifier_string()
    return (S.mods.alt and "ALT-" or "") .. (S.mods.ctrl and "CTRL-" or "") .. (S.mods.shift and "SHIFT-" or "")
end

-- Blizzard's ACTIONBUTTON paging (ActionButton.lua: page and bonus bar offset).
local function actionbutton_slot(n)
    if S.page == 1 and S.bonusbar >= 1 and S.bonusbar <= 4 then
        return n + (S.bonusbar + 5) * 12
    elseif S.page == 1 and S.bonusbar == 5 then
        return n + 10 * 12
    end
    return n + (S.page - 1) * 12
end

-- What the key bound to `binding` should show and what clicking it should use.
-- Returns texture (nil: no icon), click slot (nil: click does nothing) and whether the
-- oracle knows this kind of binding at all.
local function expect(binding)
    local n = binding:match("^ACTIONBUTTON(%d+)$")
    if n then
        local slot = actionbutton_slot(tonumber(n))
        local a = S.actions[slot]
        return a and a.texture, slot, true
    end
    local bar, b = binding:match("^MULTIACTIONBAR(%d+)BUTTON(%d+)$")
    if bar then
        local slot = MULTIBAR_OFFSETS[tonumber(bar)] + tonumber(b)
        local a = S.actions[slot]
        return a and a.texture, a and slot or nil, true
    end
    local bt4 = binding:match("^CLICK BT4Button(%d+):Keybind$")
    if bt4 then
        local frame = _G["BT4Button" .. bt4]
        local slot = frame and tonumber(frame:GetAttribute("action")) or tonumber(bt4)
        local a = S.actions[slot]
        return a and a.texture, (a and a.texture) and slot or nil, true
    end
    local spell = binding:match("^Spell (.+)$")
    if spell then
        local s = S.spells[spell]
        return s and s.texture, nil, true
    end
    local macro = binding:match("^Macro (.+)$")
    if macro then
        return S.macros[macro], nil, true
    end
    return nil, nil, false
end

local DEVICES = {
    { "kb", "keys_keyboard" },
    { "mouse", "keys_mouse" },
    { "pad", "keys_controller" },
}

local MODIFIER_KEYS = { LALT = true, RALT = true, LCTRL = true, RCTRL = true, LSHIFT = true, RSHIFT = true }

local problems = 0
local function problem(line)
    problems = problems + 1
    emit("PROBLEM " .. line)
end

-- check_clicks: false skips the click comparison (paging during combat is a documented
-- limitation: the click keeps the slot of the last out-of-combat sync).
local function inspect(step, opts)
    opts = opts or {}
    emit(("== %s  open=%s mods=%s page=%d bonus=%d lockdown=%s"):format(step, tostring(addon.open),
        modifier_string() == "" and "-" or modifier_string(), S.page, S.bonusbar, tostring(S.lockdown)))

    local mods = modifier_string()
    for _, device in ipairs(DEVICES) do
        local tag, field = device[1], device[2]
        local keys = addon[field] or {}
        for i = 1, #keys do
            local button = keys[i]
            local raw = button.raw_key or ""
            local shown_icon = button.icon and button.icon:IsShown() and button.icon:GetTexture() or nil
            local left, right = H.click_slot(button, "LeftButton"), H.click_slot(button, "RightButton")
            local binding = button.binding or ""
            if binding ~= "" or shown_icon or left then
                emit(("  %s %-10s bind=%-26s slot=%-4s icon=%-8s text=%-8s click=%s/%s"):format(
                    tag, raw, binding, tostring(button.active_slot or button.slot),
                    tostring(shown_icon), tostring(button.short_key and button.short_key:GetText()),
                    tostring(left), tostring(right)))
            end

            -- Whatever is on screen has to be right, whether or not KeyUI thinks it is open.
            if opts.oracle ~= false and button:IsVisible() and raw ~= "" and not MODIFIER_KEYS[raw] then
                local want_binding = S.bindings[mods .. raw] or ""
                local where = ("%s %s %s"):format(step, tag, mods .. raw)
                if binding ~= want_binding then
                    problem(("%s: binding %q, expected %q"):format(where, binding, want_binding))
                elseif want_binding ~= "" then
                    local want_tex, want_click, known = expect(want_binding)
                    if known then
                        if shown_icon ~= want_tex then
                            problem(("%s (%s): icon %s, expected %s"):format(where, want_binding,
                                tostring(shown_icon), tostring(want_tex)))
                        end
                        if opts.check_clicks ~= false and left ~= want_click then
                            problem(("%s (%s): left click uses %s, expected %s"):format(where, want_binding,
                                tostring(left), tostring(want_click)))
                        end
                    end
                end
                if opts.check_clicks ~= false and right ~= nil then
                    problem(("%s: right click uses slot %s, expected nothing"):format(where, tostring(right)))
                end
            end
        end
    end

    for i = 1, #H.errors do
        problem(step .. ": Lua error: " .. H.errors[i])
    end
    for i = 1, #H.blocked do
        problem(step .. ": ADDON_ACTION_BLOCKED " .. H.blocked[i])
    end
    wipe(H.errors)
    wipe(H.blocked)
end

local function step(name, fn, opts)
    H.protected_call(fn)
    H.flush()
    inspect(name, opts)
end

local function toggle_minimap()
    H.ldb.OnClick(nil, "LeftButton")
end

---------------------------------------------------------------------------
-- The session
---------------------------------------------------------------------------

step("01 login", function()
    H.addon_loaded()
    H.fire("PLAYER_LOGIN")
    H.fire("UPDATE_BINDINGS")
end, { oracle = false })

if H.search_tagged_buttons and #H.search_tagged_buttons > 0 then
    problem("settings: buttons with search tags taint the Options search (WoWUIBugs#873): "
        .. table.concat(H.search_tagged_buttons, ", "))
end

step("02 open", function() SlashCmdList["KeyUI"]("") end)

step("03 hold shift", function() H.set_modifier("shift", true) end)
step("04 hold ctrl+shift", function() H.set_modifier("ctrl", true) end)
step("05 release shift", function() H.set_modifier("shift", false) end)
step("06 hold alt+ctrl", function() H.set_modifier("alt", true) end)
step("07 release all", function()
    H.set_modifier("alt", false)
    H.set_modifier("ctrl", false)
end)

step("08 page 2", function()
    S.page = 2
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)
step("09 page 1", function()
    S.page = 1
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)

step("10 stealth bonus bar", function()
    S.bonusbar = 1
    H.fire("UPDATE_BONUS_ACTIONBAR")
end)
step("11 bonus bar off", function()
    S.bonusbar = 0
    H.fire("UPDATE_BONUS_ACTIONBAR")
end)

step("12 slot 5 filled", function()
    S.actions[5] = spell_action(10, 135857)
    H.fire("ACTIONBAR_SLOT_CHANGED", 5)
end)

-- An icon that was not available when the key was drawn: item data and spell textures
-- can arrive after the first query. Nothing announces it to KeyUI directly; the frequent
-- state events have to pick it up.
step("13 late icons arrive", function()
    S.actions[3].texture = 133971
    S.spells["Arcane Shot"].texture = 132218
    H.fire("ACTIONBAR_UPDATE_STATE")
    H.fire("SPELL_UPDATE_ICON")
end)

step("13b Bartender pages its button", function()
    bt4_button:SetAttribute("action", 14)
    H.fire("ACTIONBAR_UPDATE_STATE")
end)
step("13c Bartender pages back", function()
    bt4_button:SetAttribute("action", 13)
    H.fire("ACTIONBAR_UPDATE_STATE")
end)

step("14 binding added", function()
    S.bindings["T"] = "ACTIONBUTTON6"
    H.fire("UPDATE_BINDINGS")
end)

-- A binding that changed without UPDATE_BINDINGS reaching KeyUI. The next full refresh
-- has to show it.
step("15 binding changed silently", function()
    S.bindings["G"] = "ACTIONBUTTON2"
    S.page = 1
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)

-- Alt+Z (or a cinematic) hides UIParent and shows it again; KeyUI never closed.
step("16 UIParent hidden and shown", function()
    UIParent:Hide()
    H.flush()
    UIParent:Show()
end)
step("17 page 2 after Alt+Z", function()
    S.page = 2
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)
step("18 page 1 after Alt+Z", function()
    S.page = 1
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)

-- Make sure KeyUI is open whatever the Alt+Z steps left behind.
step("19 reopen", function()
    if not addon.open then SlashCmdList["KeyUI"]("") end
end)

step("20 combat, stay open", function()
    keyui_settings.stay_open_in_combat = true
    H.enter_combat()
end)
step("21 shift in combat", function() H.set_modifier("shift", true) end)
step("22 ctrl+shift in combat", function() H.set_modifier("ctrl", true) end)
step("23 release in combat", function()
    H.set_modifier("ctrl", false)
    H.set_modifier("shift", false)
end)
-- The controls that move, scale or hide KeyUI's frames, and the menu entries that call
-- SetBinding, are all refused by the client in combat (issue #74). Using them during a
-- fight must not reach the client at all.
step("23b controls used in combat", function()
    local controls = addon:get_controls_frame()
    controls:Show()
    addon.active_control_tab = "keyboard"
    H.run_script(controls.size_slider, "OnValueChanged", 1.25)
    H.run_script(addon.controller_frame, "OnMouseDown", "LeftButton")
    H.run_script(addon.controller_frame, "OnMouseUp", "LeftButton")
    local key
    for _, button in ipairs(addon.keys_keyboard) do
        if button.raw_key == "Q" then key = button end
    end
    addon:handle_drag_or_size(key, "LeftButton")
    addon:handle_release(key, "LeftButton")
    wipe(H.menu_actions)
    H.run_script(key, "OnMouseUp", "RightButton")
    if H.menu_actions.Unbind then H.menu_actions.Unbind() end
    controls:Hide()
end)
if (addon.keyboard_frame and addon.keyboard_frame:GetScale() or 1) ~= 1 then
    problem("23b controls used in combat: keyboard frame scaled in combat")
end

step("24 page 2 in combat", function()
    S.page = 2
    H.fire("ACTIONBAR_PAGE_CHANGED")
end, { check_clicks = false })
step("25 combat ends", function()
    H.leave_combat()
end)
step("26 page 1", function()
    S.page = 1
    H.fire("ACTIONBAR_PAGE_CHANGED")
end)

step("27 combat closes KeyUI", function()
    keyui_settings.stay_open_in_combat = false
    H.enter_combat()
    S.page = 2
    H.fire("ACTIONBAR_PAGE_CHANGED")
    S.actions[7] = spell_action(11, 135858)
    H.fire("ACTIONBAR_SLOT_CHANGED", 7)
    H.leave_combat()
end, { oracle = false })
step("28 reopened after combat", function()
    if not addon.open then SlashCmdList["KeyUI"]("") end
end)

step("29 closed by minimap", function() toggle_minimap() end, { oracle = false })
step("30 reopened after changes", function()
    S.page = 1
    H.fire("ACTIONBAR_PAGE_CHANGED")
    S.bindings["7"] = "ACTIONBUTTON7"
    H.fire("UPDATE_BINDINGS")
    H.set_modifier("shift", true)   -- pressed while KeyUI was closed
    toggle_minimap()
end)

-- The Controls window: built on first use, so nothing above ran its code.
step("30b controls window", function()
    local controls = addon:get_controls_frame()
    controls:Show()
    addon.keyboard_frame.controls_button:Click()
    controls.empty_keys_cb:SetChecked(true)
    controls.empty_keys_cb:Click()
    controls.empty_keys_cb:SetChecked(false)
    controls.empty_keys_cb:Click()
    controls.close_button:Click()
end)

-- Right-click on a key: the assignment menu (spells, macros, interface bindings) is built.
step("30c right-click menu", function()
    H.menu_entries = 0
    local key
    for _, button in ipairs(addon.keys_keyboard) do
        if button.raw_key == "Q" then key = button end
    end
    H.run_script(key, "OnMouseUp", "RightButton")
end, { oracle = false })
-- Spells, Macro, Interface and Unbind, plus at least one spell tab.
if (H.menu_entries or 0) < #(addon.spells_tab_order or {}) + 4 then
    problem(("30c right-click menu: only %d entries built"):format(H.menu_entries or 0))
end

-- The report a tester sends: it must build, and mention every visible bound key.
step("31 /keyui report", function()
    H.last_popup_text = nil
    SlashCmdList["KeyUI"]("report")
end, { oracle = false })
if addon.BuildDiagnosticReport then
    local report = H.last_popup_text or ""
    -- Shift is still held from step 30, so key 1 shows and clicks its Shift layer.
    if not report:find("^KeyUI ") or not report:find("kb[", 1, true)
        or not report:find("1=MULTIACTIONBAR1BUTTON1 s61 H+ I+ C61", 1, true) then
        problem("31 /keyui report: unexpected report text: " .. report:sub(1, 200))
    end
    if report:find("\n", 1, true) then
        problem("31 /keyui report: contains a line break; the popup edit box is single-line")
    end
    emit("  report: " .. report:sub(1, 400))
end

if mode == "dump" then
    io.write(table.concat(out, "\n"), "\n")
else
    for _, line in ipairs(out) do
        if line:match("^PROBLEM") then io.write(line, "\n") end
    end
end

local unknown = {}
for name in pairs(H.unknown_methods) do unknown[#unknown + 1] = name end
table.sort(unknown)
if #unknown > 0 then
    io.stderr:write("harness: widget methods without a stub (returned nil): " .. table.concat(unknown, " ") .. "\n")
end
io.stderr:write(("harness: %s, %d problem(s)\n"):format(H.flavor, problems))
os.exit(problems > 0 and 1 or 0)
