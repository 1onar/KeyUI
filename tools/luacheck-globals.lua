-- Writes tools/luacheck/wow_globals.lua: the WoW globals KeyUI reads, checked against the
-- Blizzard resources of all five clients in API/<flavor>/_resources (see
-- tools/update-api.sh resources). Run from the repository root after adding a call to a
-- new WoW global:
--
--   luajit tools/luacheck-globals.lua      (or lua5.1)
--
-- It runs luacheck with .luacheckrc but without the generated list
-- (KEYUI_LUACHECK_BARE=1) and sorts every "undefined variable" name into:
--   globals     exists on at least one client (resources: GlobalAPI, FrameXML, Frames,
--               Mixins, LuaEnum, GlobalStrings/enUS)
--   deprecated  defined only by Blizzard_Deprecated* forwarders, which load only while
--               the loadDeprecationFallbacks CVar is on; .luacheckrc allows them where
--               KeyUI uses them as guarded fallbacks
-- Anything else stays undefined, and luacheck keeps reporting it.
-- The comment beside each name lists the clients that have it; a name missing on some
-- client needs a guard (API_COMPAT, `C_X.Y or Y`, ...).

local FLAVORS = { "retail", "forever", "mists", "anniversary", "classic_era" }
local LIST_FILES = { "GlobalAPI.lua", "FrameXML.lua", "Frames.lua", "Mixins.lua" }
local OUTPUT = "tools/luacheck/wow_globals.lua"

local function read(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return (s:gsub("\r", ""))
end

-- name -> { [flavor] = true }
local known = {}
local function add(name, flavor)
    if not name or not name:match("^[%a_][%w_]*$") then return end
    known[name] = known[name] or {}
    known[name][flavor] = true
end

for _, flavor in ipairs(FLAVORS) do
    local dir = "API/" .. flavor .. "/_resources/"
    for _, file in ipairs(LIST_FILES) do
        local s = read(dir .. file) or error("missing " .. dir .. file .. "; run tools/update-api.sh resources")
        for entry in s:gmatch('\n%s*"([^"\n]+)"') do
            add(entry:match("^[%a_][%w_]*"), flavor)
        end
    end
    local enum = read(dir .. "LuaEnum.lua") or error("missing " .. dir .. "LuaEnum.lua")
    for name in ("\n" .. enum):gmatch("\n([%a_][%w_]*)%s*=") do add(name, flavor) end
    local strings = read(dir .. "GlobalStrings/enUS.lua") or error("missing " .. dir .. "GlobalStrings/enUS.lua")
    for name in ("\n" .. strings):gmatch('\n_G%["([^"]+)"%]%s*=') do add(name, flavor) end
    for name in ("\n" .. strings):gmatch("\n([%a_][%w_]*)%s*=") do add(name, flavor) end
end

-- The resource lists hold functions, not tables or constants (UISpecialFrames,
-- Settings, ATTRIBUTE_NOOP, ...). Take those from the UI source itself: top-level
-- assignments and function definitions, outside the deprecation forwarders.
for _, flavor in ipairs(FLAVORS) do
    local cmd = "grep -rhoE '^(function +[A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]* *=[^=])'"
        .. " --include='*.lua' --exclude-dir='Blizzard_Deprecated*' --exclude-dir=_resources API/" .. flavor
    local p = assert(io.popen(cmd))
    for line in p:lines() do
        add(line:match("^function +([%a_][%w_]*)") or line:match("^([%a_][%w_]*)"), flavor)
    end
    p:close()
    -- Constants set in <Script> blocks of XML files (GameFonts.xml: STANDARD_TEXT_FONT).
    p = assert(io.popen("grep -rhoE '^[[:space:]]*[A-Z][A-Z0-9_]* *=[^=]' --include='*.xml' API/" .. flavor))
    for line in p:lines() do
        add(line:match("^%s*([%a_][%w_]*)"), flavor)
    end
    p:close()
end

-- Globals defined by the deprecation forwarders, per client.
local deprecated_defs = {}
for _, flavor in ipairs(FLAVORS) do
    local p = io.popen("find API/" .. flavor .. " -path '*Blizzard_Deprecated*' -name '*.lua'")
    for path in p:lines() do
        local s = "\n" .. (read(path) or "")
        for name in s:gmatch("\nfunction%s+([%a_][%w_]*)%s*%(") do
            deprecated_defs[name] = deprecated_defs[name] or {}
            deprecated_defs[name][flavor] = true
        end
        for name in s:gmatch("\n%s*([%a_][%w_]*)%s*=[^=]") do
            deprecated_defs[name] = deprecated_defs[name] or {}
            deprecated_defs[name][flavor] = true
        end
    end
    p:close()
end

-- What KeyUI reads without the generated list.
local p = assert(io.popen("KEYUI_LUACHECK_BARE=1 luacheck . --formatter plain --codes 2>&1"))
local used = {}
for line in p:lines() do
    local name = line:match("%(W113%) accessing undefined variable '([^']+)'")
    if name then used[name] = true end
end
p:close()

local function flavors_of(set)
    local out = {}
    for _, flavor in ipairs(FLAVORS) do
        if set[flavor] then out[#out + 1] = flavor end
    end
    return out
end

local globals, deprecated, unknown = {}, {}, {}
for name in pairs(used) do
    if known[name] then
        globals[#globals + 1] = name
    elseif deprecated_defs[name] then
        deprecated[#deprecated + 1] = name
    else
        unknown[#unknown + 1] = name
    end
end
table.sort(globals)
table.sort(deprecated)
table.sort(unknown)

local out = {
    "-- Generated by tools/luacheck-globals.lua from API/<flavor>/_resources. Do not edit.",
    "-- The WoW globals KeyUI reads; the comment lists the clients that define each one.",
    "return {",
    "    globals = {",
}
local partial = {}
for _, name in ipairs(globals) do
    local fl = flavors_of(known[name])
    if #fl < #FLAVORS then partial[#partial + 1] = name .. " (" .. table.concat(fl, ", ") .. ")" end
    out[#out + 1] = ('        "%s", -- %s'):format(name, #fl == #FLAVORS and "all" or table.concat(fl, ", "))
end
out[#out + 1] = "    },"
out[#out + 1] = "    -- Only in Blizzard_Deprecated* (loadDeprecationFallbacks); see COMPATIBILITY.md."
out[#out + 1] = "    deprecated = {"
for _, name in ipairs(deprecated) do
    out[#out + 1] = ('        "%s", -- %s'):format(name, table.concat(flavors_of(deprecated_defs[name]), ", "))
end
out[#out + 1] = "    },"
out[#out + 1] = "}"

local f = assert(io.open(OUTPUT, "wb"))
f:write(table.concat(out, "\n"), "\n")
f:close()

print(("%s: %d globals, %d deprecated"):format(OUTPUT, #globals, #deprecated))
if #partial > 0 then
    print("Not on every client (check the guards):")
    for _, line in ipairs(partial) do print("  " .. line) end
end
if #unknown > 0 then
    print("Unknown to every client (luacheck keeps reporting these):")
    print("  " .. table.concat(unknown, " "))
end
