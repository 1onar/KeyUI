-- A small stand-in for the WoW client, enough to load KeyUI under plain Lua 5.1 and drive
-- it through events. It is not an emulator: widgets keep the state KeyUI reads back
-- (shown, text, texture, attributes, scripts) and do nothing else.
--
-- What it does model, because KeyUI's behaviour depends on it:
--   * visibility: IsShown vs IsVisible, OnShow/OnHide reaching descendants when an
--     ancestor (UIParent) is hidden or shown
--   * combat lockdown: protected frames (secure templates and their ancestors) refuse
--     Show/Hide/SetAttribute/... while InCombatLockdown() is true; each refusal is
--     recorded the way the client raises ADDON_ACTION_BLOCKED
--   * Frame:GetAttribute(prefix, name, suffix) with the documented five-step lookup, and
--     the secure action button's click resolution built on it (SecureTemplates.lua)
--   * events, C_Timer.After (run by H.flush), OnUpdate
--
-- Game state (bindings, action slots, page, modifiers, spells, macros) lives in H.state
-- and is changed by the scenarios in run.lua.

local H = {}
_G.HARNESS = H

H.flavor = os.getenv("KEYUI_FLAVOR") or "forever"
local BUILDS = {
    retail      = { "12.1.5", "70783", "Nov 1 2026", 120105 },
    forever     = { "1.60.1", "70938", "Nov 1 2026", 16001 },
    mists       = { "5.5.4", "70631", "Nov 1 2026", 50504 },
    anniversary = { "2.5.6", "70577", "Nov 1 2026", 20506 },
    classic_era = { "1.15.9", "70576", "Nov 1 2026", 11509 },
}
local build = assert(BUILDS[H.flavor], "unknown KEYUI_FLAVOR " .. H.flavor)
local MODERN = H.flavor == "retail" or H.flavor == "forever"
H.modern = MODERN

H.errors = {}
H.blocked = {}
H.unknown_methods = {}
H.printed = {}

H.state = {
    bindings = {},      -- full key ("SHIFT-1") -> action string
    actions = {},       -- slot -> { texture = ..., kind = "spell", id = ... }; texture may be nil
    bonusbar = 0,
    page = 1,
    mods = { alt = false, ctrl = false, shift = false },
    lockdown = false,
    combat = false,
    spells = {},        -- name -> { id = ..., texture = ... }
    macros = {},        -- name -> icon
    addons = {},        -- loaded addon names
}

local function record_error(err)
    H.errors[#H.errors + 1] = tostring(err)
end

local function traceback(err)
    return debug.traceback(tostring(err), 2)
end

-- Runs fn like the client runs a script handler: an error is reported, the caller goes on.
local function protected_call(fn, ...)
    local args, n = { ... }, select("#", ...)
    local ok, err = xpcall(function() return fn(unpack(args, 1, n)) end, traceback)
    if not ok then
        record_error(err)
    end
end
H.protected_call = protected_call

---------------------------------------------------------------------------
-- Lua aliases the client provides
---------------------------------------------------------------------------

wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
tinsert = table.insert
tremove = table.remove
floor = math.floor
format = string.format
strsplit = function(sep, s)
    local out = {}
    for piece in (s .. sep):gmatch("(.-)" .. sep:gsub("%p", "%%%0")) do out[#out + 1] = piece end
    return unpack(out)
end
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
debugprofilestop = function() return os.clock() * 1000 end
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    H.printed[#H.printed + 1] = table.concat(parts, " ")
end

---------------------------------------------------------------------------
-- Widgets
---------------------------------------------------------------------------

local all_frames = {}       -- creation order, for event dispatch and OnUpdate
local Widget = {}
local widget_mt = {}

local function new_widget(kind, name, parent)
    local w = {
        _kind = kind,
        _name = name,
        _parent = parent,
        _shown = true,
        _children = {},
        _scripts = {},
        _hooks = {},
        _attrs = {},
        _events = {},
        _width = 0,
        _height = 0,
        _alpha = 1,
        _scale = 1,
        _level = parent and ((parent._level or 0) + 1) or 0,
    }
    setmetatable(w, widget_mt)
    if parent then
        parent._children[#parent._children + 1] = w
    end
    if name then
        _G[name] = w
    end
    return w
end

-- Unknown keys stay nil: KeyUI tests template fields such as LeftActive for existence, so
-- inventing them would send it down the wrong branch. A missing method then fails loudly.
widget_mt.__index = Widget

local function is_visible(w)
    while w do
        if not w._shown then
            return false
        end
        w = w._parent
    end
    return true
end

local function run_script(w, script, ...)
    local fn = w._scripts[script]
    if fn then
        protected_call(fn, w, ...)
    end
    local hooks = w._hooks[script]
    if hooks then
        for i = 1, #hooks do
            protected_call(hooks[i], w, ...)
        end
    end
end
H.run_script = run_script

-- OnShow/OnHide reach every shown descendant whose visibility changed with w.
local function fire_visibility(w, script)
    if w._kind ~= "Texture" and w._kind ~= "FontString" then
        run_script(w, script)
    end
    for i = 1, #w._children do
        local child = w._children[i]
        if child._shown then
            fire_visibility(child, script)
        end
    end
end

local PROTECTED_METHODS = {
    Show = true, Hide = true, SetShown = true, SetPoint = true, ClearAllPoints = true,
    SetAllPoints = true, SetWidth = true, SetHeight = true, SetSize = true, SetScale = true,
    SetParent = true, SetAttribute = true, EnableMouse = true, EnableKeyboard = true,
    EnableMouseWheel = true, EnableGamePadButton = true, SetFrameLevel = true,
    RegisterForClicks = true,
}

local function blocked(w, method)
    if H.state.lockdown and w._protected and PROTECTED_METHODS[method] then
        H.blocked[#H.blocked + 1] = ("%s:%s()"):format(w._name or w._kind, method)
        return true
    end
    return false
end

local function mark_protected(w)
    while w do
        w._protected = true
        w = w._parent
    end
end

function Widget:GetName() return self._name end
function Widget:GetObjectType() return self._kind end
function Widget:IsObjectType(t) return self._kind == t end
function Widget:GetParent() return self._parent end
function Widget:SetParent(p)
    if blocked(self, "SetParent") then return end
    if self._parent then
        local siblings = self._parent._children
        for i = #siblings, 1, -1 do
            if siblings[i] == self then table.remove(siblings, i) end
        end
    end
    self._parent = p
    if p then
        p._children[#p._children + 1] = self
        if self._protected then mark_protected(p) end
    end
end

function Widget:IsShown() return self._shown end
function Widget:IsVisible() return is_visible(self) end
function Widget:Show()
    if blocked(self, "Show") then return end
    if self._shown then return end
    self._shown = true
    if is_visible(self) then fire_visibility(self, "OnShow") end
end
function Widget:Hide()
    if blocked(self, "Hide") then return end
    if not self._shown then return end
    local was_visible = is_visible(self)
    self._shown = false
    if was_visible then fire_visibility(self, "OnHide") end
end
function Widget:SetShown(shown)
    if shown then self:Show() else self:Hide() end
end

function Widget:SetPoint(...) if blocked(self, "SetPoint") then return end self._point = { ... } end
function Widget:ClearAllPoints() if blocked(self, "ClearAllPoints") then return end self._point = nil end
function Widget:SetAllPoints() if blocked(self, "SetAllPoints") then return end end
function Widget:GetPoint() if self._point then return unpack(self._point) end end
function Widget:GetNumPoints() return self._point and 1 or 0 end
function Widget:SetWidth(v) if blocked(self, "SetWidth") then return end self._width = v end
function Widget:SetHeight(v) if blocked(self, "SetHeight") then return end self._height = v end
function Widget:SetSize(w, h) if blocked(self, "SetSize") then return end self._width, self._height = w, h or w end
function Widget:GetWidth() return self._width end
function Widget:GetHeight() return self._height end
function Widget:GetSize() return self._width, self._height end
function Widget:GetLeft() return 0 end
function Widget:GetRight() return self._width end
function Widget:GetTop() return 0 end
function Widget:GetBottom() return -self._height end
function Widget:GetCenter() return 500, 400 end
function Widget:SetAlpha(a) self._alpha = a end
function Widget:GetAlpha() return self._alpha end
function Widget:SetScale(s) if blocked(self, "SetScale") then return end self._scale = s end
function Widget:GetScale() return self._scale end
function Widget:GetEffectiveScale() return self._scale end
function Widget:SetFrameLevel(l) if blocked(self, "SetFrameLevel") then return end self._level = l end
function Widget:GetFrameLevel() return self._level end
function Widget:SetFrameStrata(s) self._strata = s end
function Widget:GetFrameStrata() return self._strata or "MEDIUM" end
function Widget:IsMouseOver() return false end
function Widget:IsProtected() return self._protected == true end

-- Scripts and events
function Widget:SetScript(script, fn) self._scripts[script] = fn end
function Widget:GetScript(script)
    return self._scripts[script] or (self._hooks[script] and self._hooks[script][1])
end
function Widget:HookScript(script, fn)
    local hooks = self._hooks[script] or {}
    hooks[#hooks + 1] = fn
    self._hooks[script] = hooks
end
function Widget:RegisterEvent(event) self._events[event] = true end
function Widget:RegisterUnitEvent(event, unit) self._events[event] = unit or true end
function Widget:UnregisterEvent(event) self._events[event] = nil end
function Widget:UnregisterAllEvents() wipe(self._events) end
function Widget:IsEventRegistered(event) return self._events[event] ~= nil end

-- Attributes. The three-argument form follows the documented lookup order.
function Widget:SetAttribute(name, value)
    if blocked(self, "SetAttribute") then return end
    self._attrs[name] = value
    run_script(self, "OnAttributeChanged", name, value)
end
function Widget:GetAttribute(a, b, c)
    if b == nil and c == nil then
        return self._attrs[a]
    end
    local prefix, name, suffix = a, b, c
    local attrs = self._attrs
    local value = attrs[prefix .. name .. suffix]
    if value == nil then value = attrs["*" .. name .. suffix] end
    if value == nil then value = attrs[prefix .. name .. "*"] end
    if value == nil then value = attrs["*" .. name .. "*"] end
    if value == nil then value = attrs[name] end
    return value
end

-- Input
function Widget:EnableMouse(v) if blocked(self, "EnableMouse") then return end self._mouse = v end
function Widget:IsMouseEnabled() return self._mouse == true end
function Widget:EnableKeyboard(v) if blocked(self, "EnableKeyboard") then return end self._keyboard = v end
function Widget:IsKeyboardEnabled() return self._keyboard == true end
function Widget:EnableMouseWheel(v) if blocked(self, "EnableMouseWheel") then return end self._wheel = v end
function Widget:EnableGamePadButton(v) if blocked(self, "EnableGamePadButton") then return end self._gamepad = v end
function Widget:RegisterForClicks(...) if blocked(self, "RegisterForClicks") then return end self._clicks = { ... } end
function Widget:RegisterForDrag() end
function Widget:SetMovable() end
function Widget:SetClampedToScreen() end
function Widget:StartMoving() end
function Widget:StopMovingOrSizing() end
function Widget:SetPropagateKeyboardInput() end
function Widget:SetHitRectInsets() end
function Widget:SetClipsChildren() end

-- Children
function Widget:CreateTexture(name)
    local t = new_widget("Texture", name, self)
    return t
end
function Widget:CreateMaskTexture(name) return new_widget("Texture", name, self) end
function Widget:CreateFontString(name)
    local fs = new_widget("FontString", name, self)
    fs._text = nil
    return fs
end
function Widget:CreateAnimationGroup()
    local ag = new_widget("AnimationGroup", nil, nil)
    return ag
end
function Widget:CreateAnimation() return new_widget("Animation", nil, nil) end
function Widget:Play() self._playing = true end
function Widget:Stop() self._playing = false end
function Widget:IsPlaying() return self._playing == true end

-- Textures
function Widget:SetTexture(t) self._texture = t; self._atlas = nil end
function Widget:GetTexture() return self._texture end
function Widget:SetAtlas(a) self._atlas = a; self._texture = "atlas:" .. tostring(a) end
function Widget:GetAtlas() return self._atlas end
function Widget:SetColorTexture(r, g, b, a) self._texture = ("color:%s,%s,%s"):format(r, g, b) end
function Widget:SetVertexColor(r, g, b, a) self._vertex = { r, g, b, a } end
function Widget:GetVertexColor() local v = self._vertex or { 1, 1, 1, 1 } return v[1], v[2], v[3], v[4] end
function Widget:SetTexCoord() end
function Widget:SetBlendMode() end
function Widget:SetDesaturated(v) self._desaturated = v end

-- Font strings and buttons with text
function Widget:SetText(text) self._text = text end
function Widget:GetText() return self._text end
function Widget:SetFormattedText(fmt, ...) self._text = fmt:format(...) end
function Widget:SetFont(path, size, flags) self._font = { path, size, flags } return true end
function Widget:GetFont() if self._font then return unpack(self._font) end return "Fonts\\FRIZQT__.TTF", 12, "" end
function Widget:SetTextColor(r, g, b, a) self._color = { r, g, b, a } end
function Widget:GetTextColor() local c = self._color or { 1, 1, 1, 1 } return c[1], c[2], c[3], c[4] end
function Widget:GetStringWidth() return #(self._text or "") * 7 end
function Widget:GetStringHeight() return 12 end
function Widget:SetJustifyH() end
function Widget:SetJustifyV() end
function Widget:SetWordWrap() end
function Widget:SetFontObject(o) self._font_object = o end
function Widget:SetNormalFontObject() end
function Widget:SetHighlightFontObject() end
function Widget:SetDisabledFontObject() end
function Widget:GetFontString()
    if not self._fontstring then self._fontstring = self:CreateFontString() end
    return self._fontstring
end
local function texture_slot(field)
    return function(self, tex)
        if type(tex) == "table" then
            self[field] = tex
        else
            self[field] = self[field] or self:CreateTexture()
            self[field]:SetTexture(tex)
        end
    end, function(self)
        self[field] = self[field] or self:CreateTexture()
        return self[field]
    end
end
Widget.SetNormalTexture, Widget.GetNormalTexture = texture_slot("_normal_tex")
Widget.SetPushedTexture, Widget.GetPushedTexture = texture_slot("_pushed_tex")
Widget.SetHighlightTexture, Widget.GetHighlightTexture = texture_slot("_highlight_tex")
Widget.SetDisabledTexture, Widget.GetDisabledTexture = texture_slot("_disabled_tex")
function Widget:SetCheckedTexture() end

-- Buttons, check buttons, edit boxes, sliders
function Widget:Enable() self._disabled = false end
function Widget:Disable() self._disabled = true end
function Widget:SetEnabled(v) self._disabled = not v end
function Widget:IsEnabled() return not self._disabled end
function Widget:SetChecked(v) self._checked = v and true or false end
function Widget:GetChecked() return self._checked == true end
function Widget:Click(button) run_script(self, "OnClick", button or "LeftButton", false) end
function Widget:SetFocus() end
function Widget:ClearFocus() end
function Widget:HighlightText() end
function Widget:SetAutoFocus() end
function Widget:SetMaxLetters() end
function Widget:SetMinMaxValues(lo, hi) self._min, self._max = lo, hi end
function Widget:SetValueStep() end
function Widget:SetValue(v) self._value = v end
function Widget:GetValue() return self._value end
function Widget:GetID() return self._id or 0 end
function Widget:SetID(id) self._id = id end

-- Backdrop
function Widget:SetBackdrop(b) self._backdrop = b end
function Widget:SetBackdropColor() end
function Widget:SetBackdropBorderColor() end

-- Cooldowns
function Widget:SetCooldown(start, duration) self._cooldown = { start, duration } end
function Widget:Clear() self._cooldown = nil end
function Widget:SetDrawSwipe() end
function Widget:SetDrawEdge() end
function Widget:SetDrawBling() end
function Widget:SetSwipeColor() end
function Widget:SetHideCountdownNumbers() end
if MODERN then
    function Widget:SetCooldownFromDurationObject(d) self._cooldown = d end
end

-- Dropdowns (WowStyle1DropdownTemplate), auto-cast overlay
function Widget:SetupMenu(generator) self._menu_generator = generator end
function Widget:SetDefaultText(text) self._default_text = text end
function Widget:GenerateMenu() end
function Widget:ShowAutoCastEnabled(v) self._autocast = v end

-- Tooltip
function Widget:SetOwner() end
function Widget:SetAction(slot) self._tooltip = "action:" .. tostring(slot) end
function Widget:SetSpellByID(id) self._tooltip = "spell:" .. tostring(id) end
function Widget:SetPetAction(i) self._tooltip = "pet:" .. tostring(i) end
function Widget:AddLine() end
function Widget:AddDoubleLine() end
function Widget:ClearLines() end

---------------------------------------------------------------------------
-- CreateFrame and templates
---------------------------------------------------------------------------

-- Templates KeyUI uses, per client, as found in the five interface dumps (API/*/_resources/
-- Templates.lua and the UI source). Creating any other raises, as it does in the client.
local KNOWN_TEMPLATES = {
    BackdropTemplate = true, SecureActionButtonTemplate = true, CooldownFrameTemplate = true,
    GlowBoxTemplate = true, UICheckButtonArtTemplate = true, WowStyle1DropdownTemplate = true,
    ActionButtonSpellAlertTemplate = true, AutoCastOverlayTemplate = true,
    InputBoxTemplate = true, MinimalSliderTemplate = true,
    PanelTopTabButtonTemplate = true, PanelTabButtonTemplate = true,
}
if MODERN then
    KNOWN_TEMPLATES.ActionButtonSpellFXTemplate = true
    KNOWN_TEMPLATES.Tutorial_PointerDown = true
    KNOWN_TEMPLATES.Tutorial_PointerLeft = true
end
H.known_templates = KNOWN_TEMPLATES

function CreateFrame(kind, name, parent, templates)
    if H.state.lockdown and templates and templates:find("Secure") then
        H.blocked[#H.blocked + 1] = ("CreateFrame(%s) in combat"):format(templates)
    end
    local w = new_widget(kind, name, parent)
    w._templates = templates
    all_frames[#all_frames + 1] = w
    if templates then
        for template in templates:gmatch("[^,%s]+") do
            if not KNOWN_TEMPLATES[template] then
                error(("CreateFrame: template %s does not exist on %s"):format(template, H.flavor), 2)
            end
            if template:find("^Secure") then
                w._secure = true
                mark_protected(w)
            end
        end
        if templates:find("ActionButtonSpellAlertTemplate") then
            w.ProcStartFlipbook = w:CreateTexture()
            w.ProcLoopFlipbook = w:CreateTexture()
            w.ProcAltGlow = w:CreateTexture()
            w.ProcStartAnim = w:CreateAnimationGroup()
        end
    end
    return w
end

function CreateFont(name)
    local f = new_widget("Font", name, nil)
    return f
end

UIParent = CreateFrame("Frame", "UIParent")
WorldFrame = CreateFrame("Frame", "WorldFrame")
GameTooltip = CreateFrame("GameTooltip", "GameTooltip", UIParent)
GameTooltip:Hide()
SettingsPanel = CreateFrame("Frame", "SettingsPanel", UIParent)
SettingsPanel:Hide()
UISpecialFrames = {}
StaticPopupDialogs = {}
SlashCmdList = {}
ATTRIBUTE_NOOP = ""
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
ACCEPT, CANCEL, CLOSE, SAVE, TARGET, MACRO = "Accept", "Cancel", "Close", "Save", "Target", "Macro"
SPELLS, UNBIND, INTERFACE_LABEL = "Spells", "Unbind", "Interface"
HUD_EDIT_MODE_COLLAPSE_OPTIONS, HUD_EDIT_MODE_EXPAND_OPTIONS = "Collapse", "Expand"

-- One pooled dialog, as the client reuses its popups; OnShow runs like it does there.
local popup = CreateFrame("Frame", "StaticPopup1", UIParent)
popup:Hide()
popup.EditBox = CreateFrame("EditBox", nil, popup)
function popup:GetEditBox() return self.EditBox end
function StaticPopup_Show(which, text_arg1, text_arg2, data)
    local info = StaticPopupDialogs[which]
    if not info then return nil end
    H.last_popup = which
    popup.data = data
    popup.EditBox:SetText("")
    popup:Show()
    if info.OnShow then protected_call(info.OnShow, popup, data) end
    H.last_popup_text = popup.EditBox:GetText()
    return popup
end
function StaticPopup_OnClick() end
function HideUIPanel(f) if f then f:Hide() end end
function GameTooltip_SetTitle() end
function GameTooltip_AddNormalLine() end

---------------------------------------------------------------------------
-- Timers, events, frames per tick
---------------------------------------------------------------------------

local timers = {}
C_Timer = {
    After = function(_, fn) timers[#timers + 1] = fn end,
    NewTicker = function(_, fn)
        return { Cancel = function() end, IsCancelled = function() return false end }
    end,
    NewTimer = function(_, fn)
        timers[#timers + 1] = fn
        return { Cancel = function() end }
    end,
}

-- One rendered frame: OnUpdate on every visible frame, then the timers queued so far.
function H.frame(elapsed)
    elapsed = elapsed or 0.2
    for i = 1, #all_frames do
        local w = all_frames[i]
        if w._scripts.OnUpdate and is_visible(w) then
            run_script(w, "OnUpdate", elapsed)
        end
    end
    local due = timers
    timers = {}
    for i = 1, #due do
        protected_call(due[i])
    end
end

-- Runs frames until nothing is queued.
function H.flush()
    for _ = 1, 20 do
        H.frame()
        if #timers == 0 then
            return
        end
    end
    record_error("H.flush: timers keep rescheduling")
end

function H.fire(event, ...)
    for i = 1, #all_frames do
        local w = all_frames[i]
        local reg = w._events[event]
        if reg and (reg == true or reg == (...)) then
            run_script(w, "OnEvent", event, ...)
        end
    end
end

local addon_loaded_callbacks = {}
EventUtil = {
    ContinueOnAddOnLoaded = function(name, fn)
        addon_loaded_callbacks[#addon_loaded_callbacks + 1] = fn
    end,
}
function H.addon_loaded()
    for i = 1, #addon_loaded_callbacks do
        protected_call(addon_loaded_callbacks[i])
    end
    H.fire("ADDON_LOADED", "KeyUI")
end

---------------------------------------------------------------------------
-- Libraries KeyUI embeds (fetched by the packager, not in the repository)
---------------------------------------------------------------------------

local libs = {}
libs["LibDataBroker-1.1"] = { NewDataObject = function(_, name, obj) H.ldb = obj return obj end }
libs["LibDBIcon-1.0"] = {
    Register = function() end, Show = function() end, Hide = function() end,
    IsRegistered = function() return true end, Refresh = function() end,
}
LibStub = setmetatable({}, {
    __call = function(_, name, silent)
        local lib = libs[name]
        if not lib and not silent then error("LibStub: no library " .. name, 2) end
        return lib
    end,
})

---------------------------------------------------------------------------
-- Settings panel API (shape only)
---------------------------------------------------------------------------

local function settings_object()
    return setmetatable({}, { __index = function(t, k)
        return function() return settings_object() end
    end })
end
local category_id = 0
Settings = {
    VarType = { Boolean = "boolean", Number = "number", String = "string" },
    Default = { True = true, False = false },
    RegisterVerticalLayoutCategory = function(name)
        category_id = category_id + 1
        local layout = { AddInitializer = function(_, init) H.settings_initializers = (H.settings_initializers or 0) + 1 end }
        local category = { GetID = function() return category_id end }
        return category, layout
    end,
    RegisterAddOnCategory = function() end,
    RegisterProxySetting = function() return settings_object() end,
    RegisterAddOnSetting = function() return settings_object() end,
    CreateCheckbox = function() return settings_object() end,
    CreateDropdown = function() return settings_object() end,
    CreateSlider = function() return settings_object() end,
    CreateSliderOptions = function() return settings_object() end,
    CreateControlTextContainer = function()
        local data = {}
        return { Add = function(_, v, label) data[#data + 1] = { v, label } end, GetData = function() return data end }
    end,
    SetValue = function() end,
    OpenToCategory = function() H.opened_settings = true end,
}
function CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
    -- The client asserts the same (Blizzard_SettingControls.lua).
    assert(addSearchTags ~= nil)
    H.search_tagged_buttons = H.search_tagged_buttons or {}
    if addSearchTags then
        H.search_tagged_buttons[#H.search_tagged_buttons + 1] = name
    end
    return settings_object()
end
function CreateSettingsListSectionHeaderInitializer() return settings_object() end
MinimalSliderWithSteppersMixin = { Label = { Right = 1 } }
-- Menu descriptions: every builder call returns another description, so a generator can
-- build its whole tree. H.menu_entries counts the buttons it created.
local function menu_description()
    return setmetatable({}, { __index = function(_, method)
        return function(_, text)
            if method == "CreateButton" or method == "CreateCheckbox" then
                H.menu_entries = (H.menu_entries or 0) + 1
            end
            return menu_description()
        end
    end })
end
MenuUtil = {
    CreateContextMenu = function(owner, generator)
        protected_call(generator, owner, menu_description())
        return nil
    end,
}
MenuTemplates = {}

---------------------------------------------------------------------------
-- Game API backed by H.state
---------------------------------------------------------------------------

function GetBuildInfo() return unpack(build) end
function GetRealmName() return "Harness" end
function UnitName() return "Tester" end
function UnitAffectingCombat() return H.state.combat end
function InCombatLockdown() return H.state.lockdown end
function IsAltKeyDown() return H.state.mods.alt end
function IsControlKeyDown() return H.state.mods.ctrl end
function IsShiftKeyDown() return H.state.mods.shift end
IsLeftAltKeyDown, IsRightAltKeyDown = IsAltKeyDown, function() return false end
IsLeftControlKeyDown, IsRightControlKeyDown = IsControlKeyDown, function() return false end
IsLeftShiftKeyDown, IsRightShiftKeyDown = IsShiftKeyDown, function() return false end
function IsKeyDown() return false end
function IsModifiedClick() return false end

function GetBindingAction(key, check_override)
    return H.state.bindings[key] or ""
end
function GetNumBindings()
    return 0
end
function GetBinding() return nil end
function GetCurrentBindingSet() return 1 end
function SetBinding(key, action) H.state.bindings[key] = action return true end
function SaveBindings() end

function GetActionInfo(slot)
    local a = H.state.actions[slot]
    if a then return a.kind or "spell", a.id end
end
function PickupAction() end
function PlaceAction() end
function ClearCursor() end
function GetCursorInfo() return nil end
function PickupMacro() end
function ToggleAutoCastPetAction() end
function PetHasActionBar() return false end
function GetPetActionInfo() return nil end
function GetPetActionCooldown() return 0, 0, 0 end
function GetShapeshiftFormInfo() return nil end
function GetMacroInfo(name)
    local icon = H.state.macros[name]
    if icon ~= nil then return name, icon, "" end
end

C_ActionBar = {
    HasAction = function(slot) return H.state.actions[slot] ~= nil end,
    GetActionTexture = function(slot)
        local a = H.state.actions[slot]
        return a and a.texture
    end,
    GetActionText = function() return nil end,
    GetActionBarPage = function() return H.state.page end,
    GetBonusBarOffset = function() return H.state.bonusbar end,
    GetActionUseCount = function() return 0 end,
    IsConsumableAction = function() return false end,
    IsStackableAction = function() return false end,
    IsAttackAction = function() return false end,
    IsCurrentAction = function() return false end,
    IsAutoRepeatAction = function() return false end,
    GetActionCooldown = function() return { startTime = 0, duration = 0, isEnabled = true, modRate = 1, isActive = false } end,
    GetActionCharges = function() return { currentCharges = 0, maxCharges = 0, cooldownStartTime = 0, cooldownDuration = 0, chargeModRate = 1, isActive = false } end,
    GetActionDisplayCount = function() return "" end,
    IsUsableAction = function(slot) return H.state.actions[slot] ~= nil, false end,
    IsActionInRange = function() return nil end,
    GetSpell = function(slot)
        local a = H.state.actions[slot]
        if a and (a.kind or "spell") == "spell" then return a.id end
    end,
    IsAssistedCombatAction = function() return false end,
    HasAssistedCombatActionButtons = function() return false end,
    FindAssistedCombatActionButtons = function() return {} end,
    IsEquippedAction = function() return false end,
    GetActionAutocast = function() return false, false end,
    GetActionLossOfControlCooldownInfo = function() return { isActive = false, shouldReplaceNormalCooldown = false } end,
    ToggleAutoCastPetAction = function() end,
}
if MODERN then
    C_ActionBar.PutActionInSlot = function() end
    C_ActionBar.GetActionCooldownDuration = function() return nil end
    C_ActionBar.GetActionChargeDuration = function() return nil end
    C_ActionBar.GetActionLossOfControlCooldownDuration = function() return nil end
    C_Secrets = { HasSecretRestrictions = function() return true end }
    Constants = { MacroConsts = { MAX_ACCOUNT_MACROS = 120, MAX_CHARACTER_MACROS = 18 } }
else
    Constants = {}
end

local function spell_by(identifier)
    for name, s in pairs(H.state.spells) do
        if name == identifier or s.id == identifier then return name, s end
    end
end
C_Spell = {
    GetSpellIDForSpellIdentifier = function(identifier)
        local _, s = spell_by(identifier)
        return s and s.id
    end,
    GetSpellTexture = function(identifier)
        local _, s = spell_by(identifier)
        return s and s.texture
    end,
    GetSpellCooldown = function() return { startTime = 0, duration = 0, isEnabled = true, modRate = 1, isActive = false } end,
    PickupSpell = function() end,
}
if MODERN then
    C_Spell.GetSpellCooldownDuration = function() return nil end
end

local function spell_list()
    local list = {}
    for name, s in pairs(H.state.spells) do list[#list + 1] = { name = name, id = s.id, texture = s.texture } end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end
C_SpellBook = {
    IsSpellKnown = function() return true end,
    IsSpellInSpellBook = function() return true end,
}
Enum = { SpellBookSpellBank = { Player = 0, Pet = 1 } }
if MODERN then
    C_SpellBook.GetNumSpellBookSkillLines = function() return 1 end
    C_SpellBook.GetSpellBookSkillLineInfo = function()
        return { name = "General", itemIndexOffset = 0, numSpellBookItems = #spell_list() }
    end
    C_SpellBook.GetSpellBookItemInfo = function(i)
        local s = spell_list()[i]
        return { name = s and s.name, spellID = s and s.id, isPassive = false }
    end
else
    function GetNumSpellTabs() return 1 end
    function GetSpellTabInfo() return "General", nil, 0, #spell_list(), nil, 0 end
    function GetSpellBookItemInfo(i)
        local s = spell_list()[i]
        if s then return "SPELL", s.id end
    end
    function GetSpellInfo(id)
        local name, s = spell_by(id)
        if name then return name, nil, s.texture end
    end
    function IsPassiveSpell() return false end
    function GetSpellTexture(id) local _, s = spell_by(id) return s and s.texture end
    function GetSpellCooldown() return 0, 0, 1 end
    function PickupSpell() end
end

-- Blizzard_DeprecatedActionBar and Blizzard_DeprecatedSpellBook: since 12.0.0, on all five
-- clients, the bare action bar globals are only forwarders to C_ActionBar, and they exist
-- only while the loadDeprecationFallbacks CVar is on ("will be removed at the next
-- expansion"). The harness leaves them out unless KEYUI_DEPRECATION_FALLBACKS=1, so KeyUI
-- is checked against the client as it will be once they are gone.
H.deprecation_fallbacks = os.getenv("KEYUI_DEPRECATION_FALLBACKS") == "1"
if H.deprecation_fallbacks then
    for _, name in ipairs({
        "HasAction", "GetActionTexture", "GetActionText", "GetActionBarPage", "GetBonusBarOffset",
        "IsUsableAction", "IsActionInRange", "IsAttackAction", "IsCurrentAction",
        "IsAutoRepeatAction", "IsEquippedAction", "IsConsumableAction", "IsStackableAction",
        "GetActionAutocast",
    }) do
        _G[name] = C_ActionBar[name]
    end
    GetActionCount = C_ActionBar.GetActionUseCount
    function GetActionCooldown(slot)
        local info = C_ActionBar.GetActionCooldown(slot)
        return info.startTime, info.duration, info.isEnabled, info.modRate
    end
    function GetActionCharges(slot)
        local info = C_ActionBar.GetActionCharges(slot)
        return info.currentCharges, info.maxCharges, info.cooldownStartTime, info.cooldownDuration, info.chargeModRate
    end
    if not MODERN then
        function IsSpellKnown(id) return C_SpellBook.IsSpellInSpellBook(id, Enum.SpellBookSpellBank.Player, false) end
    end
end

C_AssistedCombat = {
    IsAvailable = function() return false end,
    GetRotationSpells = function() return {} end,
    GetActionSpell = function() return nil end,
}
C_AddOns = {
    IsAddOnLoaded = function(name)
        local loaded = H.state.addons[name] == true
        return loaded, loaded
    end,
    GetAddOnMetadata = function(name, field)
        if name == "KeyUI" and field == "Version" then return "harness" end
    end,
}

-- SecureTemplates.lua: the attribute a click with the held modifiers and this mouse
-- button finds, ATTRIBUTE_NOOP read as nil.
local MOUSE_SUFFIX = { LeftButton = "1", RightButton = "2", MiddleButton = "3" }
function SecureButton_GetModifierPrefix()
    local mods = H.state.mods
    return (mods.alt and "alt-" or "") .. (mods.ctrl and "ctrl-" or "") .. (mods.shift and "shift-" or "")
end
function SecureButton_GetModifiedAttribute(frame, name, button)
    local value = frame:GetAttribute(SecureButton_GetModifierPrefix(), name, MOUSE_SUFFIX[button] or "")
    if value == ATTRIBUTE_NOOP then return nil end
    return value
end
C_XMLUtil = {
    GetTemplateInfo = function(name)
        if KNOWN_TEMPLATES[name] then return { type = "Frame" } end
        return nil
    end,
}

---------------------------------------------------------------------------
-- What a player does
---------------------------------------------------------------------------

-- Holds or releases a modifier the way the client reports it to addons.
function H.set_modifier(which, down)
    H.state.mods[which] = down
    local key = ({ alt = "LALT", ctrl = "LCTRL", shift = "LSHIFT" })[which]
    H.fire("MODIFIER_STATE_CHANGED", key, down and 1 or 0)
end

-- Combat start as the client orders it: PLAYER_REGEN_DISABLED is handled while
-- protected changes are still allowed, lockdown begins right after.
function H.enter_combat()
    H.state.combat = true
    H.fire("PLAYER_REGEN_DISABLED")
    H.state.lockdown = true
    H.flush()
end

function H.leave_combat()
    H.state.lockdown = false
    H.state.combat = false
    H.fire("PLAYER_REGEN_ENABLED")
    H.flush()
end

-- The action slot a mouse click on a secure action button would use, following
-- SecureActionButton_OnClick: modifier prefix from the held keys, button suffix,
-- ATTRIBUTE_NOOP meaning "nothing". Returns nil when the click does nothing.
function H.click_slot(button, mouse_button)
    local action_type = SecureButton_GetModifiedAttribute(button, "type", mouse_button)
    if action_type ~= "action" then
        return nil
    end
    local action = SecureButton_GetModifiedAttribute(button, "action", mouse_button)
    -- SecureActionButtonMixin:CalculateAction falls back to slot 1 without an action.
    return tonumber(action) or 1
end

return H
