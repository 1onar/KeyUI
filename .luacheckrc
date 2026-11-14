-- luacheck configuration (luacheck 1.2.0). Run from the repository root: `luacheck .`
--
-- WoW globals come from tools/luacheck/wow_globals.lua, generated from the Blizzard
-- resources of all five clients (tools/luacheck-globals.lua). A call to a WoW global that
-- is not listed there shows up as "accessing undefined variable": regenerate the list if
-- the name is real, and check the guard if it is missing on some client.

std = "lua51"
max_line_length = false
-- Script handlers and menu callbacks have fixed signatures.
unused_args = false
-- SetScript("OnX", function(self) ...) inside a method that has its own self.
ignore = { "432/self" }

exclude_files = {
    "API/",
    "Addons/",
    "Libs/",
    "Layouts/",   -- data tables only; checked by ValidateLayoutData in the harness
    ".luarocks/",
}

-- KeyUI's own globals: the saved variables and what the client reads from addons.
globals = {
    "keyui_settings",
    "SLASH_KeyUI1",
    "SLASH_KeyUI2",
    "SlashCmdList",
    "StaticPopupDialogs",
}

local wow = { globals = {}, deprecated = {} }
if os.getenv("KEYUI_LUACHECK_BARE") ~= "1" then
    wow = dofile("tools/luacheck/wow_globals.lua")
end

-- Libraries loaded through embeds.xml and optional integrations, read only when present.
local libraries = {
    "LibStub",
    "BindPadCore",
}

read_globals = {}
for _, list in ipairs({ wow.globals, libraries }) do
    for _, name in ipairs(list) do
        read_globals[#read_globals + 1] = name
    end
end

-- Action buttons are created in Lua from name prefixes (Blizzard_ActionBar/Shared/
-- ActionButtonUtil.lua), so no resource file lists them. Mappings.lua reads them once.
local action_buttons = {}
for _, prefix in ipairs({ "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
    "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button" }) do
    for i = 1, 12 do
        action_buttons[#action_buttons + 1] = prefix .. i
    end
end
files["Mappings.lua"] = { read_globals = action_buttons }

-- Deprecated forwarders, used only as fallbacks behind the C_ActionBar functions and
-- runtime checks (COMPATIBILITY.md, "Deprecated names"). Anywhere else they are an error.
local deprecated_fallbacks = { read_globals = wow.deprecated }
files["Core.lua"] = deprecated_fallbacks
files["Frames/ActionButton.lua"] = deprecated_fallbacks

-- The headless harness: wow.lua is the stand-in client and sets the WoW globals it
-- emulates (print included, to capture chat output); run.lua drives it. No
-- allow_defined here: luacheck shares implicitly defined globals between the files of one
-- run, which would hide undefined globals in the addon itself.
local stand_in = {
    "print",
    -- Lua aliases and globals the client defines in C, or that KeyUI reaches only
    -- through _G[...]; the stand-in sets them like the client does.
    "tremove", "format", "strsplit", "strtrim", "WorldFrame", "IsModifiedClick", "IsSpellKnown",
    "SPELLS", "UNBIND", "INTERFACE_LABEL", "ToggleAutoCastPetAction",
}
for _, list in ipairs({ wow.globals, wow.deprecated, libraries }) do
    for _, name in ipairs(list) do
        stand_in[#stand_in + 1] = name
    end
end
files["tools/harness/wow.lua"] = { globals = stand_in }
