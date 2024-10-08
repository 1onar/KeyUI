local name, addon = ...

-- Initialize libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
local LDB = LibStub("LibDataBroker-1.1")

-- Initialize global variables and SavedVariables
KeyBindSettings = KeyBindSettings or {}
KeyBindSettingsMouse = KeyBindSettingsMouse or {}
CurrentLayout = CurrentLayout or {}
MouseKeyEditLayouts = MouseKeyEditLayouts or {}
Keys = {}
KeysMouse = {}
addonOpen = false
fighting = false

-- Initialize SavedVariables for KeyUI settings and ensure all settings are present
KeyUI_Settings = KeyUI_Settings or {}

-- Ensure each setting is initialized if it doesn't exist (maintain existing settings)
KeyUI_Settings.showKeyboard = KeyUI_Settings.showKeyboard ~= nil and KeyUI_Settings.showKeyboard or true
KeyUI_Settings.showMouse = KeyUI_Settings.showMouse ~= nil and KeyUI_Settings.showMouse or true
KeyUI_Settings.stayOpenInCombat = KeyUI_Settings.stayOpenInCombat ~= nil and KeyUI_Settings.stayOpenInCombat or true
KeyUI_Settings.showPushedTexture = KeyUI_Settings.showPushedTexture ~= nil and KeyUI_Settings.showPushedTexture or true
KeyUI_Settings.preventEscClose = KeyUI_Settings.preventEscClose ~= nil and KeyUI_Settings.preventEscClose or true

-- Initialize modif table to avoid nil errors
local modif = modif or {}
modif.CTRL = modif.CTRL or ""
modif.SHIFT = modif.SHIFT or ""
modif.ALT = modif.ALT or ""
addon.modif = modif

local function SetEscCloseEnabled(frame, enabled)
    if not frame or not frame:GetName() then return end

    if enabled then
        -- Remove the frame from UISpecialFrames if ESC closing is disabled
        for i, frameName in ipairs(UISpecialFrames) do
            if frameName == frame:GetName() then
                tremove(UISpecialFrames, i)
                --print(frame:GetName() .. " removed from UISpecialFrames")
                break
            end
        end
    else
        -- Add the frame back to UISpecialFrames to allow ESC closing
        if not tContains(UISpecialFrames, frame:GetName()) then
            tinsert(UISpecialFrames, frame:GetName())
            --print(frame:GetName() .. " added to UISpecialFrames")
        end
    end
end

-- Define the options table for AceConfig
local options = {
    type = "group",
    name = "KeyUI",
    args = {
        minimap = {
            type = "toggle",
            name = "Minimap Button",
            desc = "Show or hide the minimap button",
            order = 1,
            get = function() return not MiniMapDB.hide end,
            set = function(_, value)
                MiniMapDB.hide = not value
                if value then
                    LibDBIcon:Show("KeyUI")
                    print("KeyUI: Minimap button enabled")
                else
                    LibDBIcon:Hide("KeyUI")
                    print("KeyUI: Minimap button disabled")
                end
            end,
        },
        stayOpenInCombat = {
            type = "toggle",
            name = "Stay Open In Combat",
            desc = "Allow KeyUI to stay open during combat",
            order = 2,
            get = function() return KeyUI_Settings.stayOpenInCombat end,
            set = function(_, value)
                KeyUI_Settings.stayOpenInCombat = value
                addon:SaveSettings()
                local status = value and "enabled" or "disabled"
                print("KeyUI: Stay open in combat " .. status)
            end,
        },
        showKeyboard = {
            type = "toggle",
            name = "Show Keyboard",
            desc = "Show or hide the keyboard interface",
            order = 4,
            get = function() return KeyUI_Settings.showKeyboard end,
            set = function(_, value)
                KeyUI_Settings.showKeyboard = value
                addon:SaveSettings()
                local status = value and "enabled" or "disabled"
                print("KeyUI: Keyboard visibility", status)
                if addonOpen then
                    addon:UpdateInterfaceVisibility()
                end
            end,
        },
        showMouse = {
            type = "toggle",
            name = "Show Mouse",
            desc = "Show or hide the mouse interface",
            order = 5,
            get = function() return KeyUI_Settings.showMouse end,
            set = function(_, value)
                KeyUI_Settings.showMouse = value
                addon:SaveSettings()
                local status = value and "enabled" or "disabled"
                print("KeyUI: Mouse visibility", status)
                if addonOpen then
                    addon:UpdateInterfaceVisibility()
                end
            end,
        },
        -- toggle to enable or disable PushedTexture functionality
        showPushedTexture = {
            type = "toggle",
            name = "Highlight Buttons",
            desc = "Enable or disable the highlight effect on action buttons",
            order = 3,
            get = function() return KeyUI_Settings.showPushedTexture end,
            set = function(_, value)
                KeyUI_Settings.showPushedTexture = value
                addon:SaveSettings()
                local status = value and "enabled" or "disabled"
                print("KeyUI: Action button highlighting", status)
            end,
        },
        -- Add a button to reset all settings to defaults
        resetSettings = {
            type = "execute",
            name = "Reset Addon Settings",
            desc = "Reset all settings to their default values",
            order = 7,
            confirm = true,  -- Ask for confirmation
            confirmText = "Are you sure you want to reset all settings to default?",
            func = function()
                -- Reset all SavedVariables to their default values
                KeyUI_Settings = {
                    ["showMouse"] = true,
                    ["stayOpenInCombat"] = true,
                    ["showKeyboard"] = true,
                    ["showPushedTexture"] = true,
                }
                MiniMapDB = {
                    ["hide"] = false,
                }
                KeyboardPosition = {}
                MousePosition = {}
                ShowEmptyBinds = nil
                ShowInterfaceBinds = nil
                KeyBindSettings = {}
                KeyBindSettingsMouse = {}
                MouseKeyEditLayouts = {}
                CurrentLayout = {}
                tutorialCompleted = nil

                -- Save the reset settings
                addon:SaveSettings()

                -- Reload the UI to apply the changes
                ReloadUI()
            end,
        },
        preventEscClose = {
            type = "toggle",
            name = "Enable ESC",
            desc = "Enable or disable the addon window closing when pressing ESC",
            order = 6,
            get = function() return KeyUI_Settings.preventEscClose end,
            set = function(_, value)
                KeyUI_Settings.preventEscClose = value
                addon:SaveSettings()
                
                -- Immediately update the ESC closing behavior for all relevant frames
                SetEscCloseEnabled(KeyUIMainFrame, not KeyUI_Settings.preventEscClose)
                SetEscCloseEnabled(KBControlsFrame, not KeyUI_Settings.preventEscClose)
                SetEscCloseEnabled(Mouseholder, not KeyUI_Settings.preventEscClose)
                SetEscCloseEnabled(MouseFrame, not KeyUI_Settings.preventEscClose)
                SetEscCloseEnabled(MouseControls, not KeyUI_Settings.preventEscClose)
                
                local status = value and "enabled" or "disabled"
                print("KeyUI: Closing with ESC " .. status)
            end,
        }        
    },
}

-- Register the options table
AceConfig:RegisterOptionsTable("KeyUI", options)

-- Create the options frame and add it to the Interface Options
local optionsFrame = AceConfigDialog:AddToBlizOptions("KeyUI", "KeyUI")

-- Minimap button setup using LibDataBroker
local miniButton = LDB:NewDataObject("KeyUI", {
    type = "data source",
    text = "KeyUI",
    icon = "Interface\\AddOns\\KeyUI\\Media\\keyboard",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if addonOpen then
                -- Close the addon regardless of the combat state
                addon:HideAll()
                addonOpen = false
            else
                -- Open the addon if stayOpenInCombat is true OR if not in combat
                if not fighting or KeyUI_Settings.stayOpenInCombat then
                    addon:Load()
                    addonOpen = true
                else
                    print("KeyUI: Cannot open while in combat.")
                end
            end
        elseif btn == "RightButton" then
            -- Open the Blizzard settings page
            Settings.OpenToCategory("KeyUI")
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

EventUtil.ContinueOnAddOnLoaded(..., function()
    MiniMapDB = MiniMapDB or { hide = false }
    
    if MiniMapDB.hide then
        LibDBIcon:Hide("KeyUI")
    else
        LibDBIcon:Show("KeyUI")
    end
    
    LibDBIcon:Register("KeyUI", miniButton, MiniMapDB)

    -- Load saved settings
    addon:LoadSettings()
    addon:UpdateInterfaceVisibility()
end)

-- Update the visibility of keyboard and mouse based on settings, only if addon is open
function addon:UpdateInterfaceVisibility()
    if not addonOpen then
        return
    end

    local keyboard = self:GetKeyboard()
    local Controls = self:GetControls()
    local Mouseholder = self:GetMouseholder()
    local MouseFrame = self:GetMouseFrame()
    local MouseControls = self:GetMouseControls()

    if KeyUI_Settings.showKeyboard then
        keyboard:Show()
        Controls:Show()
    else
        keyboard:Hide()
        Controls:Hide()
    end

    if KeyUI_Settings.showMouse then
        Mouseholder:Show()
        MouseFrame:Show()
        MouseControls:Show()
    else
        Mouseholder:Hide()
        MouseFrame:Hide()
        MouseControls:Hide()
    end
end

function addon:Load()
    -- Allow loading if not in combat OR if stayOpenInCombat is true
    if fighting and not KeyUI_Settings.stayOpenInCombat then
        -- Prevent loading if fighting and stayOpenInCombat is false
        return
    else
        addonOpen = true
        self:UpdateInterfaceVisibility()

        local dropdown = self.dropdown or self:CreateDropDown()
        local tooltip = self.tooltip or self:CreateTooltip()

        self.ddChanger = self.ddChanger or self:CreateChangerDD()
        self.ddChangerMouse = self.ddChangerMouse or self:CreateChangerDDMouse()

        local currentActiveBoard = KeyBindSettings.currentboard
        UIDropDownMenu_SetText(self.ddChanger, currentActiveBoard)

        local layoutKey = next(CurrentLayout)
        UIDropDownMenu_SetText(self.ddChangerMouse, layoutKey)
        
        self:LoadSpells()
        self:RefreshKeys()
    end
end

-- Save the current settings to SavedVariables
function addon:SaveSettings()
    KeyUI_Settings = KeyUI_Settings or {}
    KeyUI_Settings.showKeyboard = KeyUI_Settings.showKeyboard
    KeyUI_Settings.showMouse = KeyUI_Settings.showMouse
end

-- Load settings from SavedVariables
function addon:LoadSettings()
    KeyUI_Settings = KeyUI_Settings or {}
    KeyUI_Settings.showKeyboard = KeyUI_Settings.showKeyboard ~= nil and KeyUI_Settings.showKeyboard or false
    KeyUI_Settings.showMouse = KeyUI_Settings.showMouse ~= nil and KeyUI_Settings.showMouse or false
end

-- Hides all UI elements when the addon is closed
function addon:HideAll()
    local keyboard = self:GetKeyboard()
    local Controls = self:GetControls()
    local Mouseholder = self:GetMouseholder()
    local MouseFrame = self:GetMouseFrame()
    local MouseControls = self:GetMouseControls()

    keyboard:Hide()
    Controls:Hide()
    Mouseholder:Hide()
    MouseFrame:Hide()
    MouseControls:Hide()
end

-- Load all available spells and abilities of the player and store them in a table.
function addon:LoadSpells()
    self.spells = {}
    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        local name = skillLineInfo.name
        local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems

        -- Ensure the skill line has a name before proceeding.
        if name then
            self.spells[name] = {}

            for j = offset + 1, offset + numSlots do
                local spellName = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
                local isPassive = C_SpellBook.IsSpellBookItemPassive(j, Enum.SpellBookSpellBank.Player)
                if spellName and not isPassive then
                    table.insert(self.spells[name], spellName)
                end
            end
        end
    end
end

local function OnFrameHide(self)
    if not keyboardFrameVisible and not MouseholderFrameVisible then
        addonOpen = false
    end
end

function addon:GetKeyboard()
    if not keyboardFrame then
        keyboardFrame = self:CreateKeyboard()
        keyboardFrame:SetScript("OnHide", function()
            addon:SaveKeyboard()
            keyboardFrameVisible = false
            OnFrameHide()
        end)
        keyboardFrame:SetScript("OnShow", function()
            keyboardFrameVisible = true
        end)
    end
    return keyboardFrame
end

function addon:GetControls()
    if not ControlsFrame then
        ControlsFrame = self:CreateControls()
    end
    return ControlsFrame
end

function addon:GetMouseholder()
    if not MouseholderFrame then
        MouseholderFrame = self:CreateMouseholder()
        MouseholderFrame:SetScript("OnHide", function()
            addon:SaveMouse()
            MouseholderFrameVisible = false
            OnFrameHide()
        end)
        MouseholderFrame:SetScript("OnShow", function()
            MouseholderFrameVisible = true
        end)
    end
    return MouseholderFrame
end

function addon:GetMouseFrame()
    if not MouseFrame then
        MouseFrame = self:CreateMouseUI()
    end
    return MouseFrame
end

function addon:GetMouseControls()
    if not MouseControlsFrame then
        MouseControlsFrame = self:CreateMouseControls()
    end
    return MouseControlsFrame
end

function addon:CreateTooltip()
    local KBTooltip = CreateFrame("Frame", "KeyUITooltip", UIParent, "GlowBoxTemplate") -- Create the tooltip frame

    KBTooltip:SetWidth(200)
    KBTooltip:SetHeight(25)
    KBTooltip:SetScale(1)
    KBTooltip:SetFrameStrata("TOOLTIP")
    
    KBTooltip.title = KBTooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    KBTooltip.title:SetPoint("TOPLEFT", KBTooltip, "TOPLEFT", 10, -10)
    KBTooltip:SetScript("OnHide", function(self) GameTooltip:Hide() end) -- Hide the GameTooltip when this tooltip hides
    
    addon.tooltip = KBTooltip
    return KBTooltip
end

-- ButtonMouseOver(button) - This function is called when the Mouse cursor hovers over a key binding button. It displays a tooltip description of the spell or ability.
function addon:ButtonMouseOver(button)
    local KBTooltip = self.tooltip
    KBTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 8, -4)  -- Position for the Addon Tooltip
    KBTooltip.title:SetText((button.label:GetText() or "") .. "\n" .. (button.interfaceaction:GetText() or ""))
    KBTooltip.title:SetTextColor(1, 1, 1)
    KBTooltip.title:SetFont("Fonts\\ARIALN.TTF", 16)
    KBTooltip:SetWidth(KBTooltip.title:GetWidth() + 20)
    KBTooltip:SetHeight(KBTooltip.title:GetHeight() + 20)

    if (KBTooltip:GetWidth() < 15) or button.macro:GetText() == "" then
        KBTooltip:Hide()
    else
        KBTooltip:Show()
    end

    -- Show GameTooltip for different types of actions
    if button.slot then
        -- For regular ActionButtons (ACTIONBUTTON1, ACTIONBUTTON2, etc.)
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetAction(button.slot)  -- Use SetAction for ActionButtons
        GameTooltip:Show()
    elseif button.spellid then
        -- For Pet Spells with a spellID (or regular spells)
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetSpellByID(button.spellid)  -- Set tooltip for Pet Spells or regular spells
        GameTooltip:Show()
    elseif button.petActionIndex then
        -- For pet modes (BONUSACTIONBUTTON for Wait, Move To, etc.)
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetPetAction(button.petActionIndex)  -- Show the Pet Action Tooltip
        GameTooltip:Show()
    else
        -- No tooltip for empty buttons
        GameTooltip:Hide()
    end
end

-- CheckModifiers() - Checks the modifier keys (Shift, Ctrl, Alt) and allows the player to toggle them on or off.
function addon:CheckModifiers()
    for v, button in pairs(Keys) do
        if self.modif[button.label:GetText()] then
            button:SetScript("OnEnter", nil)
            button:SetScript("OnLeave", nil)
            button:SetScript("OnMouseDown", nil)
            button:SetScript("OnMouseUp", nil)

            button:SetScript("OnMouseDown", function(self) end)
            button:SetScript("OnEnter", function(self) end)

            button:SetScript("OnLeave", function(self)
                if self.active then

                else

                end
            end)
            button:SetScript("OnMouseUp", function(self)
                if self.active then
                    self.active = false
                    modif[button.label:GetText()] = ""
                    addon:RefreshKeys()
                else
                    self.active = true
                    modif[button.label:GetText()] = button.label:GetText() .. "-"
                    addon:RefreshKeys()
                end
            end)
        end
    end
end

-- SetKey(button) - Determines the texture or text displayed on the button based on the key binding.
function addon:SetKey(button)
    local spell = GetBindingAction(modif.CTRL .. modif.SHIFT .. modif.ALT .. (button.label:GetText() or "")) or ""

    button.icon:Hide()

    -- Define class and bonus bar offset and action bar page
    local classFilename = UnitClassBase("player")
    local bonusBarOffset = GetBonusBarOffset()
    local currentActionBarPage = GetActionBarPage()

    -- Handling empty bindings early
    if ShowEmptyBinds == true then
        local labelText = button.label:GetText()
        if spell == "" and not tContains({"ESC", "CAPS", "LSHIFT", "LCTRL", "LALT", "RALT", "RCTRL", "RSHIFT", "BACKSPACE", "ENTER", "SPACE", "LWIN", "RWIN", "MENU"}, labelText) then
            button:SetBackdropColor(1, 0, 0, 1)
        else
            button:SetBackdropColor(0, 0, 0, 1)
        end
    else
        button:SetBackdropColor(0, 0, 0, 1)
    end

    -- Determine action button slot based on Class and Stance and Action Bar Page (only for Action Button 1-12)
    local function getActionButtonSlot(slot)
        -- Check if the class is Druid or Rogue in Stance and if we are on the first action bar page
        if (classFilename == "ROGUE" or classFilename == "DRUID") and bonusBarOffset ~= 0 and currentActionBarPage == 1 then
            if bonusBarOffset == 1 then
                return slot + 72 -- Maps to 73-84
            elseif bonusBarOffset == 2 then
                return slot -- No change for offset 2
            elseif bonusBarOffset == 3 then
                return slot + 96 -- Maps to 97-108
            elseif bonusBarOffset == 4 then
                return slot + 108 -- Maps to 109-120
            elseif bonusBarOffset == 5 then
                return slot -- No change for offset 5
            end
        end

        -- Handle other action bar pages for all classes
        if currentActionBarPage == 2 then
            return slot + 12 -- Maps to 13-24
        elseif currentActionBarPage == 3 then
            return slot + 24 -- Maps to 25-36
        elseif currentActionBarPage == 4 then
            return slot + 36 -- Maps to 37-48
        elseif currentActionBarPage == 5 then
            return slot + 48 -- Maps to 49-60
        elseif currentActionBarPage == 6 then
            return slot + 60 -- Maps to 61-72
        end

        return slot -- Default 1-12
    end

    -- Standard ActionButton logic
    for i = 1, GetNumBindings() do
        local a = GetBinding(i)
        if spell:find(a) then
            local slot = spell:match("ACTIONBUTTON(%d+)") or spell:match("BT4Button(%d+)")
            local bar, bar2 = spell:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")

            -- Handle MULTIACTIONBAR case
            if bar and bar2 then
                if bar == "0" then slot = tonumber(bar2) end
                if bar == "1" then slot = 60 + tonumber(bar2) end
                if bar == "2" then slot = 48 + tonumber(bar2) end
                if bar == "3" then slot = 24 + tonumber(bar2) end
                if bar == "4" then slot = 36 + tonumber(bar2) end
                if bar == "5" then slot = 144 + tonumber(bar2) end
                if bar == "6" then slot = 156 + tonumber(bar2) end
                if bar == "7" then slot = 168 + tonumber(bar2) end
            end

            -- Apply class/bonus bar offset logic only for ACTIONBUTTON slots
            if slot then
                -- Check if it's not a MULTIACTIONBAR case before applying bonusBarOffset
                if not bar then
                    slot = getActionButtonSlot(slot)
                end

                -- Set the action button texture
                button.icon:SetTexture(GetActionTexture(slot))
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                button.icon:Show()
                button.slot = slot
            end
        end
    end

    if spell:find("^ELVUIBAR%d+BUTTON%d+$") then
        local barIndex, buttonIndex = spell:match("ELVUIBAR(%d+)BUTTON(%d+)")
        local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
        if elvUIButton then
            local actionID = elvUIButton._state_action
            if elvUIButton._state_type == "action" and actionID then
                button.icon:SetTexture(GetActionTexture(actionID))
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                button.icon:Show()
                button.slot = actionID
            end
        end
    end

    -- code for setting icons for other actions (movement, pets, etc.)
    local actionTextures = {
        EXTRAACTIONBUTTON1 = 4200126,
        MOVEFORWARD = 450907,
        MOVEBACKWARD = 450905,
        STRAFELEFT = 450906,
        STRAFERIGHT = 450908
    }

    if actionTextures[spell] then
        button.icon:SetTexture(actionTextures[spell])
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    end

    -- Pet Action Bar logic
    if PetHasActionBar() then
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            for i = 1, 10 do
                local petspellName = "BONUSACTIONBUTTON" .. i
                if spell:match(petspellName) then
                    -- GetPetActionInfo returns multiple values, including texture/token
                    local petName, petTexture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)
                    
                    -- If it's a token, use the token to get the texture
                    if isToken then
                        petTexture = _G[petTexture] or "Interface\\Icons\\" .. petTexture  -- Use WoW's icon folder as fallback
                    end

                    if petTexture then
                        button.icon:SetTexture(petTexture)
                        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        button.icon:Show()

                        -- Check if it's a Pet Spell (spellID is present)
                        if spellID then
                            button.slot = nil  -- No slot for Pet Spells
                            button.spellid = spellID  -- Set spellID for Pet Spells
                            button.petActionIndex = nil  -- Not a pet mode
                        else
                            -- For Pet Modes (e.g., Wait, Move To)
                            button.slot = nil
                            button.spellid = nil
                            button.petActionIndex = i  -- Set petActionIndex for pet modes
                        end
                    else
                        -- Handle empty buttons by clearing the slot, spellID, and petActionIndex
                        button.icon:Hide()
                        button.slot = nil
                        button.spellid = nil
                        button.petActionIndex = nil
                    end
                end
            end
        end
    else
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            button.icon:Hide()
            button.slot = nil
            button.spellid = nil
            button.petActionIndex = nil  -- Clear petActionIndex when no pet action bar
        end
    end

    -- Set macro text
    button.macro:SetText(spell)

    -- Interface action labels
    if button.interfaceaction then
        button.interfaceaction:SetText(KeyMappings[button.macro:GetText()] or button.macro:GetText())
        if ShowInterfaceBinds == true then
            button.interfaceaction:Show()
        else
            button.interfaceaction:Hide()
        end
    end

    -- Label Shortening
    if button.ShortLabel and LabelMapping[button.label:GetText()] then
        button.label:Hide()
        button.ShortLabel:SetText(LabelMapping[button.label:GetText()])
    end    
end

-- RefreshKeys() - Updates the display of key bindings and their textures/texts.
function addon:RefreshKeys()
    --print("RefreshKeys function called")  -- Print statement

    if KeyboardLocked == false or MouseLocked == false then
        return
    end

    if addonOpen == false then
        return
    end

    if keyboardFrameVisible == false and MouseholderFrameVisible == false then
        return
    end

    if MouseEditInput then
        if MouseControls.Input:HasFocus() then
            return
        end
    end

    -- Initialize Keys and KeysMouse if not already
    Keys = Keys or {}
    KeysMouse = KeysMouse or {}

    -- Hide all keys
    for i = 1, #Keys do
        Keys[i]:Hide()
    end

    for j = 1, #KeysMouse do
        KeysMouse[j]:Hide()
    end

    -- Switch the board and create buttons based on the updated layout
    self:SwitchBoard(KeyBindSettings.currentboard)
    if edited == false then
        self:SwitchBoardMouse()
    else
        wipe(KeysMouse)
        edited = false
        self:SwitchBoardMouse()
    end
    self:CheckModifiers()
    addon:RefreshControls()

    -- Set the keys
    for i = 1, #Keys do
        self:SetKey(Keys[i])
    end

    for j = 1, #KeysMouse do
        self:SetKey(KeysMouse[j])
    end
end

-- Define a function to handle key press events
local function HandleKeyPress(key)
    if key == "LSHIFT" or key == "RSHIFT" then
        modif.SHIFT = "SHIFT-"
    elseif key == "LCTRL" or key == "RCTRL" then
        modif.CTRL = "CTRL-"
    elseif key == "LALT" or key == "RALT" then
        modif.ALT = "ALT-"
    end
    addon:RefreshKeys()
end

-- Define a function to handle key release events
local function HandleKeyRelease(key)
    if key == "LSHIFT" or key == "RSHIFT" then
        modif.SHIFT = ""
    elseif key == "LCTRL" or key == "RCTRL" then
        modif.CTRL = ""
    elseif key == "LALT" or key == "RALT" then
        modif.ALT = ""
    end
    addon:RefreshKeys()
end

-- Register for key events
local frame = CreateFrame("Frame")
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:SetScript("OnEvent", function(_, event, key, state)
    if addonOpen then
        if AltCheckbox == false and CtrlCheckbox == false and ShiftCheckbox == false then
            if event == "MODIFIER_STATE_CHANGED" then
                if state == 1 then
                    -- Key press event
                    HandleKeyPress(key)
                else
                    -- Key release event
                    HandleKeyRelease(key)
                end
            end
        end
    end
end)

local function DropDown_Initialize(self, level)
    level = level or 1
    local info = UIDropDownMenu_CreateInfo()
    local value = UIDROPDOWNMENU_MENU_VALUE

    if level == 1 then

        info.text = "Spell"
        info.value = "Spell"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Macro"
        info.value = "Macro"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Interface"
        info.value = "UIBind"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Clear Action Button"
        info.value = 1
        info.hasArrow = false
        info.func = function(self)
            local key = addon.currentKey.macro:GetText()
            local actionSlot = SlotMappings[key]
            if actionSlot then
                PickupAction(actionSlot)
                ClearCursor()
                local mappedName = KeyMappings[key] or "Unknown Action"
                -- Print notification with the mapped name in purple
                print("KeyUI: Cleared |cffa335ee" .. mappedName .. "|r")
                addon:RefreshKeys()
            end
        end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Unbind Key"
        info.value = 1
        info.hasArrow = false
        info.func = function()
            if addon.currentKey.label ~= "" then
                SetBinding(modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or ""))
                addon.currentKey.macro:SetText("")
                addon:RefreshKeys()
                SaveBindings(2)
                -- Print notification of key unbinding
                local keyText = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                print("KeyUI: Unbound key |cffff8000" .. keyText .. "|r")
            end
        end
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        if value == "Spell" then
            for tabName, v in pairs(addon.spells) do
                info.text = tabName
                info.value = 'tab:' .. tabName
                info.hasArrow = true
                info.func = function() end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        if value == "Macro" then
            info.text = "General Macro"
            info.value = "General Macro"
            info.hasArrow = true
            info.func = function() end
            UIDropDownMenu_AddButton(info, level)

            info.text = "Player Macro"
            info.value = "Player Macro"
            info.hasArrow = true
            info.func = function() end
            UIDropDownMenu_AddButton(info, level)
        end

        if value == "UIBind" then
            local categories = {
                "Movement Keys",
                "Action Bar",
                "Action Bar 2",
                "Action Bar 3",
                "Action Bar 4",
                "Action Bar 5",
                "Action Bar 6",
                "Action Bar 7",
                "Action Bar 8",
                "Interface Panel",
                "Chat",
                "Targeting",
                "Target Markers",
                "Vehicle Controls",
                "Camera",
                "Ping System",
                "Miscellaneous",
            }
            for _, category in ipairs(categories) do
                local keybindings = InterfaceMapping[category]
                if keybindings then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = category
                    info.hasArrow = true
                    info.value = category
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end          
        
    elseif level == 3 then
        if value:find("^tab:") then
            local tabName = value:match('^tab:(.+)')
            for k, spellName in pairs(addon.spells[tabName]) do
                info.text = spellName
                info.value = spellName
                info.hasArrow = false
                info.func = function(self)
                    local actionbutton = addon.currentKey.macro:GetText()
                    local actionSlot = SlotMappings[actionbutton]
                    local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                    local command = "Spell " .. spellName
                    if actionSlot then
                        C_Spell.PickupSpell(spellName)
                        PlaceAction(actionSlot)
                        --print(spellName)      -- Spellname
                        --print(key)            -- e.g. ACTIONBUTTON1
                        --print(actionSlot)     -- e.g. 1 (Actionslot)
                        ClearCursor()
                        -- Print notification for new spell binding
                        print("KeyUI: Bound |cffa335ee" .. spellName .. "|r to |cffff8000" .. key .. "|r")
                        addon:RefreshKeys()
                    else
                        SetBinding(key, command)
                        SaveBindings(2)
                        -- Print notification for new spell binding
                        print("KeyUI: Bound |cffa335ee" .. spellName .. "|r to |cffff8000" .. key .. "|r")
                        addon:RefreshKeys()
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif value == "General Macro" then
            for i = 1, 36 do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.currentKey.macro:GetText()
                        local actionSlot = SlotMappings[actionbutton]
                        local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            ClearCursor()
                            addon:RefreshKeys()
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                            addon:RefreshKeys()
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end

        elseif value == "Player Macro" then
            for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.hasArrow = false
                    info.func = function(self)
                        local actionbutton = addon.currentKey.macro:GetText()
                        local actionSlot = SlotMappings[actionbutton]
                        local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        if actionSlot then
                            PickupMacro(title)
                            PlaceAction(actionSlot)
                            ClearCursor()
                            addon:RefreshKeys()
                        else
                            SetBinding(key, command)
                            SaveBindings(2)
                            -- Print notification for new macro binding
                            print("KeyUI: Bound macro |cffa335ee" .. title .. "|r to |cffff8000" .. key .. "|r")
                            addon:RefreshKeys()
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif InterfaceMapping[value] then
            local keybindings = InterfaceMapping[value]
            for index, keybinding in ipairs(keybindings) do
                info.text = keybinding[1]
                info.value = keybinding[2]
                info.hasArrow = false
                info.func = function(self)
                    local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                    SetBinding(key, keybinding[2])
                    SaveBindings(2)
                    -- Print notification for interface binding
                    print("KeyUI: Bound |cffa335ee" .. keybinding[1] .. "|r to |cffff8000" .. key .. "|r")
                    addon:RefreshKeys()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

-- CreateDropDown() - Creates the dropdown menu for selecting key bindings.
function addon:CreateDropDown()
    local DropDown = CreateFrame("Frame", "KBDropDown", self.keyboardFrame, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(DropDown, 60)
    UIDropDownMenu_SetButtonWidth(DropDown, 20)
    DropDown:Hide()
    self.dropdown = DropDown
    UIDropDownMenu_Initialize(DropDown, DropDown_Initialize, "MENU")
    return DropDown
end

-- Function to check battle status
function addon:BattleCheck(event)
    if event == "PLAYER_REGEN_DISABLED" then
        fighting = true
        -- Only close the addon if stayOpenInCombat is false
        if not KeyUI_Settings.stayOpenInCombat and addonOpen then
            KeyUIMainFrame:Hide()
            KBControlsFrame:Hide()
            MouseControls:Hide()
            Mouseholder:Hide()
            MouseFrame:Hide()
            addonOpen = false
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        fighting = false
        -- Optional: Reopen after combat ends
        -- if KeyUI_Settings.stayOpenInCombat and not addonOpen then
        --     addon:Load()
        -- end
    end
end

-- Event frame to handle all relevant events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
eventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

-- Shared event handler function
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if addonOpen then 
        if event == "UPDATE_BONUS_ACTIONBAR" then
            local classFilename = UnitClassBase("player")
            -- Check if the class is Druid or Rogue
            if classFilename == "DRUID" or classFilename == "ROGUE" then
                local bonusBarOffset = GetBonusBarOffset()
                addon:RefreshKeys()
            end
        elseif event == "ACTIONBAR_PAGE_CHANGED" then
            -- Update the current action bar page
            local currentActionBarPage = GetActionBarPage()
            addon:RefreshKeys() -- Optional, reload keys when action bar page changes
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            -- Check the battle status
            addon:BattleCheck(event)
        else
            -- Delay refresh of keys to ensure proper updates
            C_Timer.After(0.01, function()
                addon:RefreshKeys()
            end)
        end
    end
end)

-- SlashCmdList["KeyUI"] - Registers a command to load the addon.
SLASH_KeyUI1 = "/kui"
SLASH_KeyUI2 = "/keyui"
SlashCmdList["KeyUI"] = function() addon:Load() end