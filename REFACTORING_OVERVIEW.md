# KeyUI Frühjahrsputz - Übersicht

**Datum:** 2026-01-02
**Codebase:** 12.204 Zeilen Lua in 13 Dateien
**WoW Version:** 11.2.7 → 12.0.0 (Midnight Patch)

---

## 🎯 Hauptziele

1. **Patch 12.0.0 Kompatibilität** - UIDropDownMenu ist deprecated und wird entfernt
2. **Code-Qualität verbessern** - 150+ Zeilen Duplikation eliminieren
3. **Core.lua aufteilen** - 2730 Zeilen sind zu viel für eine Datei
4. **Fehlerbehandlung** - Addon-Integrationen absichern

---

## 🔴 Kritische Probleme (SOFORT)

### 1. UIDropDownMenu ist DEPRECATED
**Betroffen:** Core.lua Zeilen 2183-2408
**Problem:** Blizzard entfernt UIDropDownMenu in Patch 12.0.0
**Lösung:** Migration zu Menu-System (wird bereits in Controls.lua verwendet)
**Aufwand:** 4 Stunden

### 2. Fehlende Nil-Checks
**Betroffen:** Core.lua:1593, 1744, 2312, 2342
**Problem:** `GetActionTexture()` kann nil zurückgeben → Errors
**Lösung:** Nil-Prüfung hinzufügen
**Aufwand:** 1 Stunde

### 3. Keine Fehlerbehandlung bei Addons
**Betroffen:** Core.lua:1454-1928 (ElvUI, Bartender, Dominos, BindPad, OPie)
**Problem:** Wenn externe Addons Errors haben, crashed KeyUI
**Lösung:** pcall() Wrapper
**Aufwand:** 2 Stunden

**Sprint 1 Gesamt:** ~7 Stunden

---

## 🟡 Code-Duplikation (HOCH)

### 1. Checkbox Visibility (150+ Zeilen Duplikation!)
**Betroffen:** Controls.lua:460-615
**Problem:** Identischer Code wiederholt sich 3x
```lua
controls_frame.empty_keys_cb:Show()
controls_frame.empty_keys_text:Show()
// ... 13 Zeilen × 3 Wiederholungen = 39 Zeilen statt 13!
```
**Lösung:** Helper-Funktion `set_checkbox_visibility(visible)`
**Aufwand:** 1 Stunde

### 2. Layout-Selektoren (700+ Zeilen Duplikation!)
**Betroffen:** Core.lua:1417-1928
**Problem:** 3 fast identische Funktionen:
- `keyboard_layout_selector()` (243 Zeilen)
- `mouse_layout_selector()` (110 Zeilen)
- `controller_layout_selector()` (108 Zeilen)

**90% identischer Code!**

**Lösung:** Generische Funktion `create_layout_selector(device_type, layouts, settings_key)`
**Aufwand:** 3 Stunden

### 3. Keybind Pattern Cache
**Betroffen:** Core.lua:1454-1502
**Problem:** Addon-Checks werden bei JEDEM Button wiederholt
```lua
// Bei JEDEM set_key() Aufruf:
if C_AddOns.IsAddOnLoaded("ElvUI") then
    keybind_patterns["^CLICK ElvUI_Bar"] = ...
end
```
**Lösung:** Einmal beim Laden cachen
**Aufwand:** 1 Stunde

**Sprint 2 Gesamt:** ~9 Stunden

---

## 🟡 Code-Lesbarkeit & Naming (HOCH)

### 1. Inkonsistente Namensgebung

**Problem:** Wilder Mix aus snake_case und camelCase
```lua
addon.keyboard_locked      -- snake_case
addon.isMoving             -- camelCase
keyui_settings             -- snake_case
addon.is_mouse_visible     -- snake_case
addon.keyui_tooltip_frame  -- snake_case (aber keyui_ redundant!)
```

**Entscheidung:** Konsistent **snake_case** verwenden

**Umbenennungen nötig:**
```lua
addon.isMoving -> addon.is_moving
addon.keyui_tooltip_frame -> addon.tooltip_frame
addon.currentHoveredButton -> addon.current_hovered_button
```

**Aufwand:** 3 Stunden
**Dateien:** Alle .lua Dateien

---

### 2. Deutsche Kommentare → Englisch

**Problem:** Mix aus Deutsch und Englisch
```lua
Core.lua:1676: -- Logik zur Auswahl eines benutzerdefinierten Layouts
Core.lua:1811: -- Logik zur Auswahl eines benutzerdefinierten Layouts
```

**Lösung:** Alle Kommentare auf Englisch
```lua
-- Logic for selecting a custom layout
```

**Aufwand:** 2 Stunden

---

### 3. Unklare Funktionsnamen

**Problem:** Namen sagen nicht, was die Funktion macht
```lua
addon:set_key()           -- Setzt es den Key oder die Texture?
addon:refresh_layouts()   -- Refreshed oder regeneriert?
addon:load()              -- Zu generisch - lädt was?
```

**Bessere Namen:**
```lua
addon:set_key() -> addon:update_button_display()
addon:refresh_layouts() -> addon:regenerate_layout_frames()
addon:load() -> addon:initialize()
```

**Aufwand:** 2 Stunden

---

### 4. Magic Numbers überall

**Problem:** Hunderte von Hard-coded Werten
```lua
Core.lua:1539: button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)
Core.lua:1981: button.highlight:SetSize(button:GetWidth() - 10, button:GetHeight() - 10)
Keyboard.lua: { 'ESCAPE', 6, -6, u, u }  -- Was ist 6 und -6?
```

**Lösung:** Constants.lua
```lua
local BUTTON_HIGHLIGHT_INSET = 10
local KEYBOARD_ESCAPE_X = 6
local KEYBOARD_ESCAPE_Y = -6

button.highlight:SetSize(
    button:GetWidth() - BUTTON_HIGHLIGHT_INSET,
    button:GetHeight() - BUTTON_HIGHLIGHT_INSET
)
```

**Aufwand:** 4 Stunden

**Sprint 2b Gesamt:** ~11 Stunden

---

## 🟢 Code-Organisation (MITTEL)

### Core.lua ist zu groß (2730 Zeilen)

**Aktuell alles in Core.lua:**
- Binding-System
- Action Bar Logik
- Spell-System
- Macro-System
- 5 Addon-Integrationen (ElvUI, Bartender, Dominos, BindPad, OPie)
- Layout-System
- Export/Import
- Settings
- Tooltip-Logic

**Neue Struktur:**
```
KeyUI/
├── Core.lua                    (~300 Zeilen)
├── Systems/
│   ├── ActionBarSystem.lua
│   ├── SpellSystem.lua
│   └── TooltipSystem.lua
├── Integrations/
│   ├── ElvUI.lua
│   ├── Bartender.lua
│   ├── Dominos.lua
│   ├── BindPad.lua
│   └── OPie.lua
└── Utils/
    ├── Serialization.lua
    └── Constants.lua
```

**Aufwand:** ~11 Stunden
**Ziel:** Core.lua < 1000 Zeilen

---

## 📊 Code-Statistiken

### Vor Refactoring:
- **Core.lua:** 2730 Zeilen
- **Controls.lua:** 1968 Zeilen
- **Code-Duplikation:** ~850 Zeilen
- **Magic Numbers:** Hunderte
- **Naming:** Inkonsistent (snake_case + camelCase)

### Nach Refactoring (Ziel):
- **Core.lua:** < 1000 Zeilen
- **Controls.lua:** < 1800 Zeilen
- **Code-Duplikation:** < 50 Zeilen
- **Magic Numbers:** In Constants.lua
- **Naming:** Konsistent snake_case

---

## 🗓️ Zeitplan

| Sprint | Fokus | Aufwand | Priorität |
|--------|-------|---------|-----------|
| **Sprint 1** | Kritische API-Kompatibilität | ~7h | 🔴 KRITISCH |
| **Sprint 2a** | Code-Duplikation | ~9h | 🟡 HOCH |
| **Sprint 2b** | Code-Lesbarkeit & Naming | ~11h | 🟡 HOCH |
| **Sprint 3** | Code-Organisation | ~11h | 🟢 MITTEL |
| **Sprint 4** | Polish (Optional) | ~5h | 🟢 NIEDRIG |

**Gesamtaufwand:** ~43 Stunden aktive Arbeit

---

## ✅ Test-Checkliste

Nach jedem Sprint testen:
- [ ] Addon lädt ohne Errors
- [ ] Keyboard Layout angezeigt
- [ ] Mouse Layout angezeigt
- [ ] Controller Layout angezeigt
- [ ] Keybinds korrekt
- [ ] Icons laden
- [ ] Export/Import funktioniert
- [ ] ElvUI Integration
- [ ] Bartender Integration
- [ ] Combat-Tests

---

## 🚀 Nächste Schritte

### Sofort starten:
```bash
git checkout -b refactor/sprint-1-critical
```

### Task 1 (30 Min):
Nil-Checks hinzufügen in Core.lua:
- Zeile 1593-1595
- Zeile 1744
- Zeile 2312, 2342

```lua
if HasAction(adjusted_slot) then
    local texture = GetActionTexture(adjusted_slot)
    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
    end
end
```

### Task 2 (2h):
Fehlerbehandlung für Addon-Integration:
```lua
if C_AddOns.IsAddOnLoaded("BindPad") then
    local success, err = pcall(function()
        for slot in BindPadCore.AllSlotInfoIter() do
            -- ... code
        end
    end)
    if not success then
        print("KeyUI: BindPad integration error:", err)
    end
end
```

### Task 3 (4h):
UIDropDownMenu Migration:
- Entferne alle `UIDropDownMenu_*` aus Core.lua:2183-2408
- Verwende Menu-System wie in Controls.lua

---

## 📝 Wichtige Notizen

### ✅ Bereits gut gemacht:
- Moderne APIs verwendet (C_SpellBook, C_Spell, C_AddOns)
- 5 große Action Bar Addons unterstützt
- Combat-Safe Design
- Gute Kommentare

### ⚠️ Nicht anfassen:
- Layout-Daten (Keyboard.lua, Mouse.lua, Controller.lua) - funktioniert
- SavedVariables Struktur - User-Daten nicht brechen!

### 🎓 Gelerntes aus Analyse:
- UIDropDownMenu wird entfernt in 12.0.0
- Secret Values System betrifft KeyUI NICHT stark (Keybindings bleiben zugänglich)
- Blizzard lockert viele Restriktionen wieder

---

## 📈 Success Metrics

### Sprint 1 (Kritisch):
✅ Keine Errors mit Patch 12.0.0
✅ Alle Dropdowns funktionieren
✅ Keine nil-Texture Crashes

### Sprint 2a (Duplikation):
✅ -350 Zeilen Code
✅ 5 Addon-Integrationen gesichert
✅ Performance verbessert

### Sprint 2b (Lesbarkeit):
✅ Konsistente snake_case Namensgebung
✅ Alle Kommentare auf Englisch
✅ Klare Funktionsnamen
✅ Constants.lua erstellt - keine Magic Numbers

### Sprint 3 (Organisation):
✅ Core.lua < 1000 Zeilen
✅ Klare Dateistruktur
✅ Wartbarkeit erhöht

---

**Bereit für Sprint 1!** 🚀
