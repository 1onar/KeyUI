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
during compatibility audits. Last refreshed 2026-10-21:

| Folder | Client | Build | `_resources` build |
|---|---|---|---|
| `API/retail` | Retail | 12.1.5.70448 | 12.1.0 (69587) |
| `API/forever` | Forever | 1.60.1.70450 | 1.60.1 (70338) |
| `API/mists` | MoP Classic | 5.5.4.70531 | 5.5.4 (69155) |
| `API/anniversary` | Anniversary | 2.5.6.70006 | 2.5.6 (68575) |
| `API/classic_era` | Classic Era | 1.15.9.70003 | 1.15.9 (69109) |

Each folder holds:

- the `Interface/AddOns` tree of the matching [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source)
  branch (`live`, `forever`, `classic`, `classic_anniversary`, `classic_era`)
- `version.txt` with that build
- `_resources/` with `AtlasInfo.lua`, `GlobalAPI.lua` and `Templates.lua` from
  [Ketho/BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources), the
  source for atlas names. That repository trails the clients by weeks at times, so its build is
  recorded separately in `_resources/version.txt`.

Unlike the older client exports, wow-ui-source keeps Blizzard's flavor subfolders, e.g.
`Blizzard_ActionBar/Shared/ActionButton.lua` instead of `Blizzard_ActionBar/ActionButton.lua`.
The `classic_anniversary` branch is stored with CRLF line endings.

#### Keeping the snapshots current

```sh
tools/update-api.sh check            # upstream build vs. KeyUI.toc and API/
tools/update-api.sh update           # refresh every flavor that changed
tools/update-api.sh update forever   # refresh one flavor
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
| **Spell Pickup** | `C_Spell.PickupSpell(spellID)` | `PickupSpell(spellID)` | `API_COMPAT.has_modern_spellbook` |
| **Actionbar GetSpell** | `C_ActionBar.GetSpell(slot)` | `GetActionInfo(slot)` fallback | `API_COMPAT.has_actionbar_getspell` |
| **Assisted Combat Action** | `C_ActionBar.IsAssistedCombatAction(slot)` | Availability depends on runtime APIs | Runtime guard (`C_AssistedCombat.IsAvailable()` + `C_ActionBar` checks) |
| **PutActionInSlot** | `C_ActionBar.PutActionInSlot(slot)` | N/A | Runtime guard (`C_ActionBar.PutActionInSlot`) |
| **Addon Check** | `C_AddOns.IsAddOnLoaded(name)` | `IsAddOnLoaded(name)` | Both versions |

### Feature Audit from Local API Dumps

Re-validated 2026-10-21 against the five snapshots listed above. Nothing changed for the four
existing clients since the 2026-09-22 audit. Forever matches Retail on every point:

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

**Deprecated names.** `C_ActionBar.GetActionLossOfControlCooldown` and the bare global
`GetActionLossOfControlCooldown` survive in 12.1.5 and Forever only as shims in
`Blizzard_DeprecatedActionBar/Deprecated_ActionBar.lua`, behind
`GetCVarBool("loadDeprecationFallbacks")`. Use `...GetActionLossOfControlCooldownInfo`.

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

| Template | Retail | Classic | Fallback |
|----------|--------|---------|----------|
| `PanelTabButtonTemplate` | ✅ | ❌ | `addon:CreateTabButton()` |
| `PanelTopTabButtonTemplate` | ✅ | ❌ | `addon:CreateTopTabButton()` |
| `Tutorial_PointerDown` | ✅ | ❌ | Manual texture construction |
| `Tutorial_PointerLeft` | ✅ | ❌ | Manual texture construction |

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
## Interface: 120105, 120100, 50504, 20506, 11509
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
**Last Updated:** 2026-09-22
**Supported Versions:** Retail 12.1.5 + 12.1.0, MoP 5.5.4, Anniversary 2.5.6, Classic Era 1.15.9
