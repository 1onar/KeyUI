# KeyUI - WoW Version Compatibility Guide

## Overview

KeyUI uses an **All-in-One approach** with runtime version detection to support all active WoW versions from a single codebase:

- **Retail** (12.1.5 and 12.1.0 Midnight) - Build 120105 / 120100
- **Forever** (1.60.1) - Build 16001
- **MoP Classic** (5.5.4) - Build 50504
- **Anniversary Edition** (2.5.6) - Build 20506
- **Classic Era** (1.15.9) - Build 11509

**Forever is not a Classic client.** Its content is classic Azeroth, but it runs the Mainline
client: the 12.1.5 API with secret values, the Mainline templates and the Mainline atlases.
Its build number only looks like Classic. Code that follows the *client* therefore checks
`addon.VERSION.isModern` (Retail or Forever), not `isRetail`. The Forever UI adds a handful of
`Camelot` overrides (`Blizzard_ActionBar/Camelot/`) that change looks, not action slots.

### Local API Snapshots Used for Compatibility Validation

`API/` (gitignored) holds one Blizzard UI source snapshot per client, used as source-of-truth
during compatibility audits. Last refreshed 2026-11-22:

| Folder | Client | Build | `_resources` build |
|---|---|---|---|
| `API/retail` | Retail | 12.1.5.70961 | 12.1.5 (70448) |
| `API/forever` | Forever | 1.60.1.71037 | 1.60.1 (70938) |
| `API/mists` | MoP Classic | 5.5.4.71060 | 5.5.4 (69155) |
| `API/anniversary` | Anniversary | 2.5.6.70577 | 2.5.6 (68575) |
| `API/classic_era` | Classic Era | 1.15.9.70576 | 1.15.9 (69109) |

Each folder holds:

- the `Interface/AddOns` tree of the matching [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source)
  branch (`live`, `forever`, `classic`, `classic_anniversary`, `classic_era`)
- `version.txt` with that build
- `_resources/` with `AtlasInfo.lua`, `GlobalAPI.lua`, `Templates.lua`, `Events.lua`,
  `FrameXML.lua`, `Frames.lua`, `Mixins.lua`, `LuaEnum.lua` and `GlobalStrings/enUS.lua` from
  [Ketho/BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources), the
  source for atlas names and for the luacheck globals list. That repository trails the clients
  by weeks at times, so its build is recorded separately in `_resources/version.txt`.

Unlike the older client exports, wow-ui-source keeps Blizzard's flavor subfolders, e.g.
`Blizzard_ActionBar/Shared/ActionButton.lua` instead of `Blizzard_ActionBar/ActionButton.lua`.
The `classic_anniversary` branch is stored with CRLF line endings.

#### Keeping the snapshots current

```sh
tools/update-api.sh check            # upstream build vs. KeyUI.toc and API/
tools/update-api.sh update           # refresh every flavor that changed
tools/update-api.sh update forever   # refresh one flavor
tools/update-api.sh resources        # refresh only _resources/ (e.g. after adding a file)
```

`update` prints which files in `Blizzard_APIDocumentationGenerated` changed (`~`), appeared (`+`)
or disappeared (`-`) before it replaces a snapshot. Review that list for anything KeyUI calls,
then update the table above. `check` exits 1 when an upstream interface version is missing from
`## Interface` in `KeyUI.toc`.

The **API Watch** workflow (`.github/workflows/api-watch.yml`) runs `check` every Monday and
opens one issue per missing interface version. To track another client (a PTR,
`classic_titan`, a Forever PTR after launch), add a line to `FLAVORS` in `tools/update-api.sh`.

## Version Detection System

### VersionCompat.lua

All version detection is centralized in `VersionCompat.lua`. This module runs at addon load and provides the `addon.VERSION` table:

```lua
addon.VERSION = {
    build = 120105,              -- Raw build number
    isRetail = true,             -- Build >= 100000
    isForever = false,           -- Build 16000-17000 (WoW Forever)
    isModern = true,             -- isRetail or isForever: the Mainline client family
    isClassic = false,           -- not isModern
    isVanilla = false,           -- Build 11500-16000
    isAnniversary = false,       -- Build 20500-30000
    isMoP = false,               -- Build 50500-60000
    USE_ATLAS = true,            -- Atlas API available (isModern)
    string = "Retail (Build 120105)"  -- Human-readable version
}
```

### How to Use in Code

**Check for Mainline client vs Classic:**
```lua
if addon.VERSION.isModern then
    -- Mainline client (Retail, Forever): modern APIs, secret values, combat lockdown rules
else
    -- Use Classic fallback
end
```

Use `isRetail` only for things that really belong to the Retail *game* (its content and
features), not to the client. Everything else, such as templates, atlases and combat restrictions,
goes on `isModern`.

**Check for Atlas support (textures):**
```lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

if USE_ATLAS then
    texture:SetAtlas("Interface/Atlas/Name")
else
    texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\name")
end
```

**Check for specific version:**
```lua
if addon.VERSION.isAnniversary then
    -- Anniversary-specific code
end
```

## API Compatibility Layer

### Core.lua - API_COMPAT

The `API_COMPAT` table in `Core.lua` detects available WoW APIs:

```lua
local API_COMPAT = {
    has_modern_spellbook = (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines ~= nil),
    has_legacy_spell_api = (_G.GetSpellBookItemInfo ~= nil and _G.GetNumSpellTabs ~= nil),
    has_assisted_combat = (C_AssistedCombat and C_AssistedCombat.IsAvailable ~= nil),
    has_actionbar_getspell = (C_ActionBar and C_ActionBar.GetSpell ~= nil),
}
```

### API Differences by Version

| Feature | Retail API | Classic API | Availability Flag |
|---------|------------|-------------|-------------------|
| **Spellbook** | `C_SpellBook.GetNumSpellBookSkillLines()` | `GetNumSpellTabs()` | `API_COMPAT.has_modern_spellbook` |
| **Spell Info** | `C_SpellBook.GetSpellBookItemInfo(i, bank)` | `GetSpellBookItemInfo(i, "spell")` | `API_COMPAT.has_legacy_spell_api` |
| **Spell Pickup** | `C_SpellBook.PickupSpellBookItem(slot, bank)` | `PickupSpellBookItem(slot, "spell")` | `API_COMPAT.has_modern_spellbook` |
| **Spell Rank** | `spellBookItemInfo.subName` | `GetSpellBookItemName(slot, "spell")` (2nd return) | `API_COMPAT.has_modern_spellbook` |
| **Actionbar GetSpell** | `C_ActionBar.GetSpell(slot)` | `GetActionInfo(slot)` fallback | `API_COMPAT.has_actionbar_getspell` |
| **Assisted Combat Action** | `C_ActionBar.IsAssistedCombatAction(slot)` | Availability depends on runtime APIs | Runtime guard (`C_AssistedCombat.IsAvailable()` + `C_ActionBar` checks) |
| **PutActionInSlot** | `C_ActionBar.PutActionInSlot(slot)` | N/A | Runtime guard (`C_ActionBar.PutActionInSlot`) |
| **Addon Check** | `C_AddOns.IsAddOnLoaded(name)` | `IsAddOnLoaded(name)` | Both versions |

### Feature Audit from Local API Dumps

Re-validated 2026-11-22 against the five snapshots listed above; every point below still holds.
The Forever update (70450 → 70707) made `GetActiveLossOfControlData` secret and changed
`IsSpellCrowdControl`, neither of which KeyUI calls. The 2026-11-22 updates add only APIs KeyUI
does not call: `EncodingDeserializeSizeLimit` (Retail, Forever), `C_BattleNet.IsGameAccountOnSameRealm`
and `C_Mail.IsCODEnabled` (Forever); MoP changed no file. Forever matches Retail on every point:

- `BINDINGS_LOADED` exists in **all five** dumps. `addon.compat.has_event` still reports it only
  for Anniversary, Forever and Retail, the clients it was verified on in-game.
- `C_ActionBar.GetSpell` and `C_ActionBar.IsAssistedCombatAction` exist in **all five** dumps.
- `C_ActionBar.PutActionInSlot` exists **only** in `retail` and `forever`.
- `C_AssistedCombat.IsAvailable` exists in all five dumps; actual availability is determined
  at runtime.
- `C_SpellBook.GetNumSpellBookSkillLines` exists **only** in `retail` and `forever`. Forever
  also lacks the legacy globals (`GetSpellInfo`, `GetSpellTabInfo`, `PickupSpell`, ...), so it
  takes the `has_modern_spellbook` path.
- `C_ActionBar.GetActionCooldown`, `IsUsableAction`, `IsActionInRange`,
  `GetActionDisplayCount`, `GetActionCharges` and `C_Spell.GetSpellCooldown` /
  `GetSpellCharges` exist in **all five** dumps. Feature-detecting these therefore does not
  distinguish Retail from Classic -- see the note on secret values below.
- Forever's key bindings are a superset of Retail's (extra: `GAMEPADACTIONBUTTON1-8`,
  `TOGGLECOREABILITIESBOOK`, `TOGGLELEGACYSYSTEM`, ...). Unknown bindings use the generic label.

Developer note:

- Re-run API checks from the repository root before changing compatibility guards:
  - `rg -n "BINDINGS_LOADED" API/*/Blizzard_APIDocumentationGenerated/KeyBindingsDocumentation.lua`
  - `rg -n "Name = \"(PutActionInSlot|IsAssistedCombatAction|GetSpell)\"" API/*/Blizzard_APIDocumentationGenerated/ActionBarFrameDocumentation.lua`
  - `rg -n "Name = \"IsAvailable\"" API/*/Blizzard_APIDocumentationGenerated/AssistedCombatDocumentation.lua`

### Secret Values (Retail 12.x and Forever)

Retail 12.0 introduced *secret values*: cooldown and charge timings that tainted (addon) code
may not read. Forever inherits them with the Mainline client. This is the single biggest
behavioural difference between the Mainline clients and Classic today, and it is **not**
detectable by checking whether a function exists.

**What is readable.** In `API/retail/Blizzard_APIDocumentationGenerated/SpellSharedDocumentation.lua`
(identical in `API/forever`) the fields of `SpellCooldownInfo`, `SpellChargeInfo` and `SpellLossOfControlInfo` that carry
`NeverSecret = true` stay readable under all circumstances:

| Struct | Always readable | May be secret |
|---|---|---|
| `SpellCooldownInfo` | `isEnabled`, `isActive`, `isOnGCD` | `startTime`, `duration`, `modRate` |
| `SpellChargeInfo` | `maxCharges`, `isActive` | `currentCharges`, `cooldownStartTime`, `cooldownDuration`, `chargeModRate` |
| `SpellLossOfControlInfo` | `isActive`, `shouldReplaceNormalCooldown` | `startTime`, `duration`, `modRate` |

The same file in the Classic dumps is identical except that every `NeverSecret` marker is
absent -- on those clients nothing is secret in the first place.

**Why `SetCooldown` is not a way out.** `SetCooldown`, `SetCooldownDuration` and
`SetCooldownFromDurationObject` are all annotated `SecretArguments = "AllowedWhenUntainted"`
(`FrameAPICooldownDocumentation.lua:281-319`). Blizzard's own untainted code may pass secret
values straight through; **addon code may not**. Passing one raises, and because
`UpdateButtonCooldown` runs first in `addon:set_key`, that error takes the whole refresh loop
with it.

**The addon-safe pattern.** Read only the `NeverSecret` booleans to decide *whether* to draw,
and obtain the timings as an opaque duration object:

```lua
-- C_ActionBar.GetActionCooldownDuration carries no SecretWhenCooldownsRestricted,
-- so the handle it returns is not itself secret and may be passed through.
if C_ActionBar.GetActionCooldown(slot).isActive then
    cooldown:SetCooldownFromDurationObject(C_ActionBar.GetActionCooldownDuration(slot))
else
    cooldown:Clear()
end
```

Note that Blizzard's own action bars do **not** use duration objects -- being untainted, they
read `isActive` and pass the possibly-secret numbers directly to `SetCooldown`
(`Blizzard_ActionBar/Shared/ActionButton.lua:845-867`, in Forever `:889-911`). That code is
identical across all five dumps, apart from line endings, and is therefore *not* a template
an addon can copy.

**Deciding which path to take.** The duration-object APIs
(`GetActionCooldownDuration`, `GetActionChargeDuration`, `GetActionLossOfControlCooldownInfo`,
`SetCooldownFromDurationObject`) are documented in **all five** dumps, so their presence says
nothing about whether secret values are in play. Use `C_Secrets` instead
(`SecretPredicateAPIDocumentation.lua`):

- `C_Secrets.HasSecretRestrictions()` -- false on Classic, i.e. the numeric path is safe
- `C_Secrets.ShouldCooldownsBeSecret()` -- whether cooldown queries generally produce secrets
- `C_Secrets.ShouldActionCooldownBeSecret(actionID)` -- per-slot

**Deprecated names.** `Blizzard_DeprecatedActionBar/Deprecated_ActionBar.lua` is identical on
**all five** clients ("Deprecated in 12.0.0"): the bare action bar globals -- `HasAction`,
`GetActionTexture`, `GetActionBarPage`, `GetBonusBarOffset`, `IsUsableAction`,
`IsActionInRange`, `IsAttackAction`, `IsCurrentAction`, `IsAutoRepeatAction`,
`IsEquippedAction`, `GetActionCooldown`, `GetActionCharges`, `GetActionCount`, ... -- exist
only as forwarders to `C_ActionBar` there. The file returns early unless
`GetCVarBool("loadDeprecationFallbacks")`, and its TOC says the functions "will be removed at
the next expansion". The same holds for `IsSpellKnown` on the Classic clients
(`Blizzard_DeprecatedSpellBook`, forwarding to
`C_SpellBook.IsSpellInSpellBook(id, Player, false)`), and for
`C_ActionBar.GetActionLossOfControlCooldown`.

The CVar defaults to on and is not saved, so today the forwarders are normally there -- but
KeyUI must not depend on them: without `HasAction`/`GetActionTexture` every key is empty.
`Core.lua` and `Frames/ActionButton.lua` therefore bind file-local names to the `C_ActionBar`
functions (all present in the five `GlobalAPI.lua` dumps), keeping the global only as a
fallback, and the Classic spell menu calls `IsSpellInSpellBook` directly. The headless
harness runs without the forwarders by default (`KEYUI_DEPRECATION_FALLBACKS=1` adds them).
To find other dependencies of this kind, look for globals that are defined only under
`API/*/Blizzard_Deprecated*`.

### Combat Lockdown, Bindings and Clicks on KeyUI Keys

**Reading is free, writing is not.** `GetBindingAction` is a plain global: it is not
protected and appears in none of the 12.x secret annotations, so KeyUI may read bindings in
combat on every client. What combat lockdown blocks is writing: `SetBinding`, `SetAttribute`
on secure frames, and `Show`/`Hide`/`SetPoint` on frames that are or parent secure buttons.
KeyUI asks `GetBindingAction` afresh on every refresh. 4.4.0-beta1 cached key → action and
relied on `UPDATE_BINDINGS` to drop the cache, so a single missed event froze a key on its old
binding; only `binding_info_cache` (binding string → pattern, label) remains, dropped on
`UPDATE_BINDINGS` and whenever the pattern list changes.

**What follows that:**

- `UPDATE_BINDINGS` redraws only the keys whose binding changed (`refresh_changed_bindings`).
  It does not go through `refresh_layouts`, which is deferred in combat, so binding changes
  made during a fight (override bindings from Clique, vehicles, other addons) show at once.
- Every KeyUI key is a `SecureActionButtonTemplate`, and its `type`/`action` attributes can
  only be written out of combat. `addon:SyncSecureAttributes` is the only writer. With
  "Detect Modifier" on and no modifier checkbox pinned, it writes all eight modifier layers
  ahead of time as prefixed attributes (`shift-type*`/`shift-action*`,
  `alt-ctrl-type*`/`alt-ctrl-action*`, ...; the bare layer stays `type`/`action`).
  `SecureButton_GetModifiedAttribute` then picks the right one per click, in combat too.
- **The `*` is required.** A click asks `GetAttribute(prefix, name, suffix)`, which tries
  `prefix..name..suffix`, `"*"..name..suffix`, `prefix..name.."*"`, `"*"..name.."*"` and
  then the bare `name` (warcraft.wiki.gg, API Frame:GetAttribute) -- never `prefix..name`
  alone. 4.4.0-beta1 wrote `shift-type`/`shift-action`, which no click ever read: a
  Shift+click fell through to the bare layer's `type`/`action`. The names live in one place,
  `addon.SECURE_MODIFIER_LAYERS` (`Frames/ActionButton.lua`), as `type_attr`/`action_attr`.
- Layers without a slot get `<prefix>type* = ATTRIBUTE_NOOP`, because
  `SecureActionButtonMixin:CalculateAction` would otherwise fall back to slot 1. Every prefix
  carries `<prefix>type2 = ATTRIBUTE_NOOP`: that exact name is the first one a right-click
  tries, so it wins over `<prefix>type*` and right-click never uses an action (4.3.1 set only
  the bare `type2`, so Shift+right-click used the action).
- Syncs run one frame after a structural refresh, at `PLAYER_REGEN_DISABLED` (before
  lockdown starts) and at `PLAYER_REGEN_ENABLED`.
- **Known limitation:** paging during combat (druid forms, stealth, Bartender/Dominos/ElvUI
  paging, vehicles) changes which slot a key shows, and KeyUI draws that, but a click still
  uses the slot from the last sync until combat ends. Fixing that would mean delegating
  the click to the real action button (`type = "click"`), which is a separate change.

**Controls that only work out of combat.** With "Stay open in combat" the whole UI stays
reachable during a fight. Everything that moves, scales or hides a device frame or a key
(size slider, dragging the controller frame, Edit Layout and the edit-mode drag/delete),
and every `SetBinding`/`SaveBindings` from the right-click menu (`#nocombat`), goes through
`addon:IsBlockedByCombat()` first: it refuses during lockdown and prints one chat line per
fight. The settings reset and the profile import refuse as well; both close and rebuild
KeyUI. Keyboard and mouse frames check `InCombatLockdown()` before `StartMoving` directly.

**Keys never take key input while locked.** A key that takes keyboard input swallows it
(it does not propagate), so no binding fires. Since 4.4.0-beta1 every key gets its
`OnKeyDown`/`OnMouseWheel`/`OnGamePadButtonDown` handler at creation; beta4 on Forever
then lost every keypress while KeyUI was open, until each key had swallowed one ("no
input for the first 30 seconds"). Nothing documents whether setting such a handler turns
the input on, so KeyUI does not rely on either answer: `InstallKeyEditHandlers` switches
input off right after setting them, and `addon:ReleaseKeyCapture()` switches it off on
every key when KeyUI opens, when a device leaves edit mode and at combat start. Only the
key hovered in edit mode takes input. The harness assumes the pessimistic answer and
checks this; `/keyui report` shows `capture=<keys taking input> keypress=<on|off>`.

**Secret strings.** `C_ActionBar.GetActionDisplayCount` is `SecretWhenCooldownsRestricted`
and returns a secret string in combat. It goes to `SetText` untouched (which accepts
secrets) -- no `or ""`, no comparison.

**Popups.** Blizzard pools its popups and applies `maxLetters` only when a dialog defines
it (`GameDialog.lua`, all five clients), so every KeyUI popup with an edit box sets one
(0 = no limit for import/export strings). Dialog text is a format string
(`SetFormattedText`): user text such as a layout name goes in as `text_arg1`, never
concatenated into `text`.

**Closed means idle.** Only start-up, integration loading, combat transitions and binding
events stay registered while KeyUI is closed; everything else is registered in
`addon:on_open_state_changed`. Anything those events keep current (bonus bar offset, action
bar page, held modifiers, charge/LoC cooldowns, flash, pet autocast, equipped border) is read
again when KeyUI opens. Hiding UIParent (Alt+Z, cinematics) fires `OnHide` on KeyUI's frames
too; that is not a close, and the hooks in `get_*_frame` skip it while the frame itself is
still shown.

**Icons that arrive late.** Item and spell textures can be missing on the first query.
State events get the light `refresh_icons` pass rather than a full `set_key`, so that pass
also rebuilds a key whose icon is hidden while its slot, spell or macro now has a texture
(`addon:IconBecameAvailable`).

### Headless Harness (`tools/harness`)

Nobody can test in-game before a release, so `tools/harness/check.sh` runs KeyUI under plain
Lua 5.1 in a stand-in client (`wow.lua`) through a fixed session (`run.lua`): open,
modifiers, paging, bonus bar, slot and binding changes, late icons, Bartender paging, Alt+Z,
combat (staying open and closing), reopening, `/keyui report`. After each step every visible
bound key is compared with what the game state says it should show and what a click should
use. Lua errors and calls the client would block in combat count as failures. It runs on all
five client flavors in `pr-check.yml`.

- `tools/harness/check.sh` -- check the working tree (exit 1 on any problem)
- `tools/harness/check.sh diff [ref]` -- what each step shows in `ref` (default: latest
  release tag) versus the working tree, for reviewing behaviour changes before a release

The stand-in models visibility (`IsShown` vs `IsVisible`, `OnShow`/`OnHide` through
ancestors), protected frames in combat (including `StartMoving`, `SetBinding` and
`SaveBindings`), the `GetAttribute(prefix, name, suffix)` lookup, secure click resolution,
pooled popups (inherited letter limit, formatted text) and the Gamepad atlases missing on
Anniversary and Classic Era. The session also uses the Controls window during combat,
pins Shift with its checkbox and opens Edit Layout, exports a profile, deletes a layout
named with a `%`, saves a layout on each device, tries the built-in layout names, reopens a
custom layout that shares a built-in name as after `/reload`, and saves over custom layouts
(the one being edited, another one confirmed and cancelled). It does not model rendering, real API return values beyond what the
session sets up, or secret values. A green run says the logic holds for these steps, not that
the client agrees -- testers' `/keyui report` stays the final word.

### Lint (`luacheck`)

`.luacheckrc` runs luacheck 1.2.0 over KeyUI's own Lua (not `Layouts/`, `Libs/`, `API/`);
`pr-check.yml` runs it as its own job. Run it from the repository root: `luacheck .`

The useful warning is *accessing undefined variable*. `tools/luacheck/wow_globals.lua` lists
the WoW globals KeyUI reads, each with the clients that define it. It is generated, not
written by hand:

```sh
tools/update-api.sh resources        # once, fetches the resource files below
luajit tools/luacheck-globals.lua    # rewrites tools/luacheck/wow_globals.lua
```

The generator collects names from all five `_resources` folders (GlobalAPI, FrameXML, Frames,
Mixins, LuaEnum, GlobalStrings) and from top-level assignments in the UI source, then keeps the
ones KeyUI uses. It prints the names that some client lacks (today only the Classic spell
globals, all behind `API_COMPAT`) and those no client defines, which stay luacheck errors.
Names defined only by the `Blizzard_Deprecated*` forwarders go into a separate `deprecated`
list that `.luacheckrc` allows in `Core.lua` and `Frames/ActionButton.lua` only, where they
are fallbacks behind `C_ActionBar` (see "Deprecated names" above). Action buttons
(`ActionButton1`, `MultiBar5Button1`, ...) are created from name prefixes in Lua, so no
resource lists them; `.luacheckrc` builds them for `Mappings.lua`.

`tools/harness/wow.lua` sets the globals it emulates and is allowed to. It must not use
`allow_defined`: luacheck shares implicitly defined globals between all files of a run, which
would hide undefined globals in the addon.

### Example: Spellbook Loading

```lua
if API_COMPAT.has_modern_spellbook then
    -- RETAIL: Modern API
    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
        local spellName = skillLineInfo.name
        local spellID = skillLineInfo.actionID
    end
elseif API_COMPAT.has_legacy_spell_api then
    -- CLASSIC: Legacy API
    for i = 1, GetNumSpellTabs() do
        local name, texture, offset, numSpells = GetSpellTabInfo(i)
        for j = offset + 1, offset + numSpells do
            local spellName, _, spellID = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
        end
    end
end
```

## Texture System

### Retail vs Classic Textures

**Retail and Forever (`USE_ATLAS`, i.e. `isModern`):**
- Uses `SetAtlas(atlasName)` with Blizzard's internal atlas system
- Example: `texture:SetAtlas("Interface/TutorialFrame/UIFrameTutorialGlow")`

**Classic (Classic Era, Anniversary, MoP):**
- Uses `SetTexture(filePath)` with extracted BLP files
- Example: `texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\uiframetutorialglow")`

### Texture Files in Media/Atlas/

These files are **extracted from Retail** and bundled for Classic compatibility:

| File | Size | Purpose |
|------|------|---------|
| `combatassistantsinglebutton.blp` | 8.1MB | Action bar button styling |
| `newplayerexperienceparts.blp` | 2.1MB | Tutorial pointer arrows |
| `dropdown.blp` | 66KB | Button dropdown styling |
| `128redbutton.blp` | 4.1MB | Exit, arrow, and menu button states |
| `redbutton2x.blp` | 130KB | Close button states |
| `uiframetabs.blp` | 66KB | Tab button textures |
| `uiframetutorialglow.blp` | 5.2KB | Glow border effects |
| `uiframetutorialglowvertical.blp` | 2.2KB | Vertical glow effects |
| `minimalsliderbar.blp` | 5.2KB | Slider controls |

### Example: Conditional Texture Loading

```lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

local GLOW_TEXTURE = USE_ATLAS
    and "Interface/TutorialFrame/UIFrameTutorialGlow"
    or "Interface\\AddOns\\KeyUI\\Media\\Atlas\\uiframetutorialglow"

local texture = frame:CreateTexture(nil, "BORDER")
texture:SetTexture(GLOW_TEXTURE)
texture:SetTexCoord(0.03125, 0.53125, 0.570312, 0.695312)
```

## UI Templates

### Blizzard Templates Availability

| Template | Retail/Forever | Classic | Fallback |
|----------|--------|---------|----------|
| `PanelTabButtonTemplate` | ✅ | ✅ (but styled differently) | `addon:CreateTabButton()` |
| `PanelTopTabButtonTemplate` | ✅ | ✅ (but styled differently) | `addon:CreateTopTabButton()` |
| `Tutorial_PointerDown` | ✅ | ❌ | Manual texture construction |
| `Tutorial_PointerLeft` | ✅ | ❌ | Manual texture construction |

Both tab templates exist in all five `_resources/Templates.lua` dumps today. KeyUI still
uses its own tabs on Classic (`USE_ATLAS` is false there), because they draw from the
bundled Retail art in `Media/Atlas/`.

### Atlases on Classic

`SetAtlas` is only used on the Mainline client, but the controller key glyphs
(`addon.playstation_buttons`, `xbox_buttons`, `deck_buttons` in `Mappings.lua`) are shown
as `|A:name:32:32|a` markup on every client. MoP Classic has all `Gamepad_*` atlases;
Anniversary and Classic Era have none, and markup for an unknown atlas draws nothing.
`update_button_key_text` therefore asks `C_Texture.GetAtlasInfo` (present on all five
clients) once per name and keeps the text label where the atlas is missing.

### Creating Version-Agnostic Buttons

```lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

if USE_ATLAS then
    -- Retail: Use Blizzard template
    button = CreateFrame("Button", nil, parent, "PanelTabButtonTemplate")
else
    -- Classic: Use custom implementation
    button = addon:CreateTabButton(parent)
end
```

### Custom Implementations (UIHelpers.lua)

KeyUI provides custom fallback implementations for Classic:

- `addon:CreateTabButton(parent)` - Standard horizontal tabs
- `addon:CreateTopTabButton(parent)` - Vertical/top-anchored tabs (75% height, flipped TexCoords)
- `addon:CreateCloseButton(parent)` - Close button with 4 states
- `addon:CreateExitButton(parent)` - Exit button using 128redbutton atlas
- `addon:CreateArrowDownButton(parent)` - Arrow-down menu button using 128redbutton atlas
- `addon:create_glow_border(frame)` - Tutorial glow border effect
- `addon:CreateStyledButton(parent, options)` - Styled dropdown-style buttons

## Testing Checklist

Before releasing, test on **all 5 WoW versions**:

### Retail (Build 120105, `API/retail`)
- [ ] Addon loads without Lua errors
- [ ] Atlas textures load correctly (no custom BLP files used)
- [ ] `C_SpellBook` API functions correctly
- [ ] Assisted Combat feature appears (if enabled in settings)
- [ ] Tab buttons use `PanelTabButtonTemplate`
- [ ] Tutorial arrows use `Tutorial_Pointer*` templates
- [ ] Settings panel appears in Interface options

### Forever (Build 16001, `API/forever`)
- [ ] Addon loads without Lua errors and is not listed as out of date
- [ ] Atlas textures load correctly (no custom BLP files used)
- [ ] Spellbook loads through `C_SpellBook` (`has_modern_spellbook`), no legacy spell API calls
- [ ] Tab buttons use `PanelTabButtonTemplate`, tutorial arrows use `Tutorial_Pointer*`
- [ ] Action buttons show cast animations (`ActionButtonSpellFXTemplate`)
- [ ] Cooldowns and charges render in combat without secret-value errors
- [ ] Changing an action in combat prints "Action changes are blocked during combat." once
- [ ] Keybinds on action bars 1-8 (`MultiBar5-7` included) resolve to the right slots

### Anniversary (Build 20506, `API/anniversary`)
- [ ] Addon loads without Lua errors
- [ ] Custom BLP textures from `Media/Atlas/` load correctly
- [ ] Legacy spell API (`GetSpellTabInfo`, `GetSpellBookItemInfo`) works
- [ ] Assisted Combat appears only when `C_AssistedCombat.IsAvailable()` returns true; otherwise the entry/indicator stays hidden without errors
- [ ] Custom tab buttons (`CreateTabButton`) render correctly
- [ ] Custom tutorial arrows with manual textures work
- [ ] All frames render with correct textures

### MoP Classic (Build 50504, `API/mists`)
- [ ] Addon loads without Lua errors
- [ ] Custom BLP textures load correctly
- [ ] Legacy spell API works
- [ ] Keybind visualization works
- [ ] All UI elements render correctly

### Classic Era (Build 11509, `API/classic_era`)
- [ ] Addon loads without Lua errors
- [ ] Custom BLP textures load correctly
- [ ] Legacy spell API works
- [ ] All frames render correctly
- [ ] No Atlas-dependent code executes

### Addon Integration Regression Tests

Frame names and binding formats are hard-coded in `Core.lua` (the `binding_handlers`
table), so they need re-checking after every major patch. Last verified 2026-09-22 against:

| Addon | Source checked | Pattern still valid |
|---|---|---|
| Dominos | `tullamods/Dominos` @ 3830240 (2026-08-12) | yes - `CLICK %s:HOTKEY` (`core/bindableButton.lua:4`), buttons named `DominosActionButton%d` (`bars/actionBar/buttons.lua:5`) |
| ElvUI | `tukui-org/ElvUI` @ a739a68 (2026-09-22) | yes - bars `ElvUI_Bar%d`, buttons `%sButton%d` (`Game/Shared/Modules/ActionBars/ActionBars.lua:413,435`) |
| Bartender4 | `Nevcairiel/Bartender4` @ 763e807 (2026-08-23) | yes - `CLICK BT4Button%d:Keybind` and `CLICK BT4StanceButton%d:LeftButton` (`Bartender4.lua:85,92`) |
| OPie | not checked - not published on GitHub | unverified |

Notes from that pass:

- ElvUI maps its bars to very different binding prefixes: bar1 uses `ACTIONBUTTON`, bar2 and
  bars 7-10 use `ELVUIBAR%dBUTTON`, and bars 3-6 and 13-15 borrow `MULTIACTIONBAR1-7BUTTON`
  (`ActionBars.lua:88-100`). `Mappings.lua` covers `MULTIACTIONBAR1BUTTON` through
  `MULTIACTIONBAR7BUTTON`, so bars 13-15 resolve.
- Dominos migrates its own bindings from `:LeftButton` to `:HOTKEY` (`Dominos.lua:341-348`),
  which is why both forms must keep resolving.
- Resolution goes through `addon:resolve_addon_slot`, which prefers live frame attributes over
  the name patterns. The patterns only have to yield a frame name that exists.

#### Dominos (verified against 3830240, 2026-08-12)
- [ ] Binding format `CLICK DominosActionButtonN:HOTKEY` resolves to a valid slot
- [ ] Binding format `CLICK DominosActionButtonNHotkey:HOTKEY` resolves to the same slot
- [ ] Binding format `CLICK MultiBarRightActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBarLeftActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBarBottomRightActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBarBottomLeftActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBar5ActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBar6ActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `CLICK MultiBar7ActionButtonNHotkey:HOTKEY` resolves to the expected slot
- [ ] Binding format `ACTIONBUTTONN` resolves to the live Dominos action slot for bar 1-12
- [ ] KeyUI shows the action icon for both Dominos binding formats
- [ ] Label regression: Dominos bar 1 (`DominosActionButton1-12`) shows `Dominos Action Button N` (not generic `Action Button N`)
- [ ] Drag & drop from KeyUI onto Dominos-bound keys works for both formats
- [ ] Repro test: pick up an action from a Dominos key and place it onto an empty Dominos key, icon appears on the real Dominos button immediately
- [ ] Repro test: pick up icon from a Dominos key and drop it back on the same key, icon remains visible and slot remains stable
- [ ] Fallback regression: when a CLICK binding cannot resolve via live frame attributes, fallback slot equals the frame-attribute slot for the same button
- [ ] Fallback regression: `frame_attr_chain` and numeric/MultiBar fallback produce the same final slot for equivalent Dominos bindings

#### Combat and refresh paths
- [ ] `/keyui perf on`, "Stay open in combat" on, 60 s on a training dummy: `refresh_keys` only counts structural changes (page, form, slot, bindings), not one per cast
- [ ] Icons still follow: talent replacement spells, macro icon edits, macros with conditions, druid forms, stealth, vehicle/skyriding, pet bar, Bartender/Dominos/ElvUI paging
- [ ] A binding changed in combat (Clique hover-cast, vehicle) shows at once
- [ ] Shift+click on a key in combat uses the Shift layer's action; a layer without an action does nothing (not slot 1); right-click with or without modifiers never uses an action
- [ ] Shift into Cat Form in combat, leave combat, click key 1: the Cat Form slot is used
- [ ] With KeyUI closed in combat, the Retail AddOn performance view shows no KeyUI CPU
- [ ] Reopening after a closed fight: modifiers, page, cooldowns, charge/LoC, flash and equipped border are right
- [ ] No `ADDON_ACTION_BLOCKED` (BugSack, `/console taintLog 1`)
- [ ] "Stay open in combat" + "Close on ESC": ESC during combat does nothing to KeyUI and raises nothing; after combat ESC closes it again
- [ ] Hovering mouse and controller keys in combat raises nothing; in locked mode a keypress over any key goes to the game, also after an edit session
- [ ] `/reload`, open KeyUI without moving the pointer over it, press a movement key or an ability at once: it works; `/keyui report` with KeyUI open shows `capture=0`
- [ ] Edit Layout, hover a key, Cancel or Save without leaving the key: keypresses reach the game again at once
- [ ] Edit mode, all three devices: hover a key, leave, hover again, press a key: the key is renamed
- [ ] "Stay open in combat", in a fight: size slider, dragging the controller frame, Edit Layout and right-click → Unbind each print "This can't be changed during combat." once and raise nothing
- [ ] Tick Shift in Controls, click Edit Layout: the keys leave the Shift layer at once, and stay on the base layer after Cancel
- [ ] After using a Blizzard dialog with a name field (pet rename, guild bank tab), Import Profile still accepts a full profile string
- [ ] Anniversary and Classic Era: controller layout keys show text labels (PAD1, ...), not blanks; Retail, Forever and MoP show the glyphs
- [ ] A custom layout named with a `%` can be deleted
- [ ] Closing the Controls window while editing the mouse or controller layout discards those edits
- [ ] Saving, renaming or copying a layout as `QWERTZ_100%`, `Layout_4x3` or `xbox` is refused with a chat line; the Save Layout dialog stays open
- [ ] Importing a layout string named like a built-in layout stores it as `<name> (2)`
- [ ] A custom layout saved under a built-in name with an older KeyUI is still shown after `/reload`
- [ ] Saving under the name of another custom layout asks "Replace it?"; Cancel returns to the name dialog; saving the edited custom layout under its own name does not ask

### In-Game Test Commands

```lua
/reload                  -- Reload UI to test addon load
/keyui                   -- Open KeyUI
-- Test: Open Keyboard/Mouse/Controller frames
-- Test: Verify keybinds display correctly
-- Test: Drag & drop spells onto action bars
-- Test: Click through tutorial
-- Test: Change settings and verify persistence
```

## Adding New Features

### Checklist for New Code

When adding new features, consider version compatibility:

1. **Check if the API exists in all versions**
   - Use `API_COMPAT` flags for API feature detection
   - Example: Only call `C_AssistedCombat` if `API_COMPAT.has_assisted_combat`

2. **Use centralized version detection**
   - Always use `addon.VERSION.USE_ATLAS` instead of calling `GetBuildInfo()` directly
   - Refer to `addon.VERSION.isModern` or `addon.VERSION.isClassic` for version checks (`isRetail` only for Retail game content)

3. **Provide fallbacks for Classic**
   - If using Blizzard templates, provide custom implementations
   - If using Atlas textures, bundle extracted BLP files in `Media/Atlas/`

4. **Test on all versions**
   - Use the testing checklist above
   - Verify both Retail and Classic code paths execute correctly

### Example: Adding a New UI Element

```lua
local USE_ATLAS = addon.VERSION.USE_ATLAS

local button
if USE_ATLAS then
    -- Retail: Use Blizzard template
    button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
else
    -- Classic: Create custom styled button
    button = addon:CreateStyledButton(parent, {
        width = 120,
        height = 30,
        label = "Click Me"
    })
end
```

## Packaging for Distribution

### Multi-Version TOC

The `KeyUI.toc` file supports multiple WoW versions via a single multi-value interface entry:

```
## Interface: 120105, 120100, 50504, 20506, 16001, 11509
```

This allows a **single addon package** to work on all WoW versions automatically.

Two Retail interface versions are listed on purpose. `120105` is the current target, but
`120100` clients are still in circulation, and a TOC that names only one of them gets flagged
as out of date on the other. Bartender4 and AdvancedInterfaceOptions do the same. The Classic
values were cross-checked against ElvUI, Dominos, Bartender4 and AdvancedInterfaceOptions,
which all declare `50504`, `20506` and `11509`.

### Building with BigWigsMods/packager

The packager automatically detects multi-version TOCs and creates a single package:

```bash
# Install packager
curl -s https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh | bash

# Package will be uploaded to CurseForge/Wago with multi-version support
```

Users downloading from CurseForge/Wago will automatically receive the correct version for their client.

## Version History

### All-in-One Strategy (Current)

- Single codebase supports all WoW versions
- Runtime version detection via `addon.VERSION`
- API compatibility layer via `API_COMPAT`
- Custom fallback implementations for Classic
- Total size: ~21MB (11MB textures + 10MB code)

### Why All-in-One?

1. **Maintainability**: Bug fixes apply to all versions instantly
2. **No code duplication**: DRY principle maintained
3. **Simplified testing**: One codebase to test across clients
4. **Feature parity**: All versions get same features
5. **User convenience**: Works everywhere without version checking
6. **Small team reality**: 1-2 developers can maintain efficiently

## Troubleshooting

### Common Issues

**"attempt to index field 'VERSION' (a nil value)"**
- Cause: `VersionCompat.lua` not loaded before other files
- Fix: Ensure `VersionCompat.lua` is listed in TOC before `UIHelpers.lua`

**Textures not loading on Classic**
- Cause: Missing BLP files in `Media/Atlas/`
- Fix: Ensure all 8 texture files are committed to git and included in package

**Lua error on Retail with "SetTexture"**
- Cause: Wrong texture path (Classic path used on Retail)
- Fix: Check `USE_ATLAS` conditional is correct

**Tab buttons look wrong**
- Cause: Wrong button template or custom implementation
- Fix: Verify `USE_ATLAS` check and correct template/fallback used

## Further Reading

- [TOC Format - Warcraft Wiki](https://warcraft.wiki.gg/wiki/TOC_format)
- [Multi-TOC Support - CurseForge](https://support.curseforge.com/support/solutions/articles/9000209856)
- [BigWigsMods Packager - GitHub](https://github.com/BigWigsMods/packager)
- [WoW API Changes by Version - Warcraft Wiki](https://warcraft.wiki.gg/wiki/Patch)

---

**Maintained by:** KeyUI Development Team
**Last Updated:** 2026-11-14
**Supported Versions:** Retail 12.1.5 + 12.1.0, Forever 1.60.1, MoP 5.5.4, Anniversary 2.5.6, Classic Era 1.15.9
