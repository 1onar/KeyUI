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

-- Initialize SavedVariables for KeyUI settings
KeyUI_Settings = KeyUI_Settings or {
    showKeyboard = true,  -- Default to true if not set
    showMouse = true,      -- Default to true if not set
}

-- Initialize modif table to avoid nil errors
local modif = modif or {}
modif.CTRL = modif.CTRL or ""
modif.SHIFT = modif.SHIFT or ""
modif.ALT = modif.ALT or ""
addon.modif = modif

-- Define the options table for AceConfig
local options = {
    type = "group",
    name = "KeyUI",
    args = {
        minimap = {
            type = "toggle",
            name = "Minimap Button",
            desc = "Show or hide the minimap button",
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
        showKeyboard = {
            type = "toggle",
            name = "Show Keyboard",
            desc = "Show or hide the keyboard interface",
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
                addon:HideAll()
                addonOpen = false
            else
                if not fighting then
                    addon:Load()
                    addonOpen = true
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
    if fighting then
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
        self:LoadDropDown()
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

-- LoadDropDown() - This function initializes the dropdown menu for key bindings.
function addon:LoadDropDown()
    self.menu = {}
end

-- Load all available spells and abilities of the player and store them in a table.
function addon:LoadSpells()
    self.spells = {}
    for i = 1, GetNumSpellTabs() do
        local name, texture, offset, numSpells = GetSpellTabInfo(i)
        self.spells[name] = {}

        if not name then
            --break
        end

        for j = offset + 1, (offset + numSpells) do
            local spellName = GetSpellBookItemName(j, BOOKTYPE_SPELL)
            if spellName and not (IsPassiveSpell(j, BOOKTYPE_SPELL)) then
                tinsert(self.spells[name], spellName)
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
    KBTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 8, -4)
    KBTooltip.title:SetText((button.label:GetText() or "") .. "\n" .. (button.interfaceaction:GetText() or ""))
    KBTooltip.title:SetTextColor(1, 1, 1)
    KBTooltip.title:SetFont("Fonts\\ARIALN.TTF", 16)
        if button.slot then
            GameTooltip:SetOwner(button, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
            GameTooltip:SetAction(button.slot)
            GameTooltip:Show()
        elseif button.spellid then
            GameTooltip:SetOwner(button, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
            GameTooltip:SetSpellByID(button.spellid)
            GameTooltip:Show()
        end

    KBTooltip:SetWidth(KBTooltip.title:GetWidth() + 20)
    KBTooltip:SetHeight(KBTooltip.title:GetHeight() + 20)
    

    if (KBTooltip:GetWidth() < 15) or button.macro:GetText() == "" then
        KBTooltip:Hide()
    else
        KBTooltip:Show()
    end
end

-- Create a new button on the given parent frame or default to the main keyboard frame.
function addon:NewButton(parent)
    if not parent then
        parent = self.keyboardFrame
    end

    -- Create a frame that acts as a button with a tooltip border.
    local button = CreateFrame("FRAME", nil, parent, "TooltipBorderedFrameTemplate")
    button:SetMovable(true)
    button:EnableMouse(true)
    button:SetBackdropColor(0, 0, 0, 1)

    -- Create a label to display the full name of the action.
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.label:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    button.label:SetTextColor(1, 1, 1, 0.9)
    button.label:SetHeight(50)
    button.label:SetWidth(100)
    button.label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -4, -6)
    button.label:SetJustifyH("RIGHT")
    button.label:SetJustifyV("TOP")

    -- Create a shorter label, possibly for abbreviations or shorter texts.
    button.ShortLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.ShortLabel:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    button.ShortLabel:SetTextColor(1, 1, 1, 0.9)
    button.ShortLabel:SetHeight(50)
    button.ShortLabel:SetWidth(100)
    button.ShortLabel:SetPoint("TOPRIGHT", button, "TOPRIGHT", -4, -6)
    button.ShortLabel:SetJustifyH("RIGHT")
    button.ShortLabel:SetJustifyV("TOP")

    -- Hidden font string to store the macro text.
    button.macro = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.macro:SetText("")
    button.macro:Hide()

    -- Font string to display the interface action text.
    button.interfaceaction = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    button.interfaceaction:SetTextColor(1, 1, 1)
    button.interfaceaction:SetHeight(64)
    button.interfaceaction:SetWidth(64)
    button.interfaceaction:SetPoint("CENTER", button, "CENTER", 0, -6)
    button.interfaceaction:SetText("")

    -- Icon texture for the button.
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(60, 60)
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)

    -- Define the mouse hover behavior to show tooltips.
    button:SetScript("OnEnter", function()
        self:ButtonMouseOver(button)
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        KeyUITooltip:Hide()
    end)

    -- Define behavior for mouse down actions (left-click).
    button:SetScript("OnMouseDown", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            addon.currentKey = self
            local key = addon.currentKey.macro:GetText()

            -- Check if 'key' is non-nil and non-empty before proceeding.
            if key and key ~= "" then
                local actionSlot = SlotMappings[key]
                if actionSlot then
                    PickupAction(actionSlot)
                    addon:RefreshKeys()
                elseif button.stateaction then
                    local pickupstateaction = loadstring("return " .. button.stateaction)()
                    PickupAction(pickupstateaction)
                    addon:RefreshKeys()
                elseif string.match(key, "^ELVUIBAR%d+BUTTON%d+$") then
                    -- Handle ElvUI Buttons
                    local barIndex, buttonIndex = string.match(key, "^ELVUIBAR(%d+)BUTTON(%d+)$")
                    local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
                    if elvUIButton and elvUIButton._state_action then
                        PickupAction(elvUIButton._state_action)
                        addon:RefreshKeys()
                    end
                end
            else
                -- Handle the case where the key is nil or empty
                --print("No valid macro text found for the button.")
            end
        end
    end)

    -- Define behavior for mouse up actions (left-click and right-click).
    button:SetScript("OnMouseUp", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            local infoType, info1, info2 = GetCursorInfo()

            -- Debug output to check values (optional)
            --print("infoType:", infoType)
            --print("info1 (expected spellbook slot):", info1)
            --print("info2 (expected spellbook type):", info2)

            if infoType == "spell" then
                local slotIndex = tonumber(info1)

                -- Determine the correct spell book type based on info2.
                local spellBookType
                if info2 == "spell" then
                    spellBookType = Enum.SpellBookSpellBank.Player  -- Default to player spells.
                elseif info2 == "pet" then
                    spellBookType = Enum.SpellBookSpellBank.Pet     -- For pet spells.
                else
                    --print("Unknown spell book type:", info2)
                    return
                end

                -- Ensure slotIndex is valid before using it.
                if slotIndex then
                    local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, spellBookType)

                    -- Check if spellBookItemInfo is valid before accessing its properties.
                    if spellBookItemInfo then
                        local spellname = spellBookItemInfo.name
                        addon.currentKey = self
                        local key = addon.currentKey.macro:GetText()
                        if key and key ~= "" then
                            local actionSlot = SlotMappings[key]
                            if actionSlot then
                                PlaceAction(actionSlot)
                                ClearCursor()
                                addon:RefreshKeys()
                            elseif string.match(key, "^ELVUIBAR%d+BUTTON%d+$") then
                                -- Handle ElvUI Buttons.
                                local barIndex, buttonIndex = string.match(key, "^ELVUIBAR(%d+)BUTTON(%d+)$")
                                local elvUIButton = _G["ElvUI_Bar" .. barIndex .. "Button" .. buttonIndex]
                                if elvUIButton and elvUIButton._state_action then
                                    PlaceAction(elvUIButton._state_action)
                                    ClearCursor()
                                    addon:RefreshKeys()
                                end
                            end
                        else
                            -- Handle the case where the key is nil or empty
                            --print("No valid macro text found for the button.")
                        end
                    else
                        --print("spellBookItemInfo is nil")
                    end
                else
                    --print("Invalid slotIndex:", slotIndex)
                end
            end
        elseif Mousebutton == "RightButton" then
            addon.currentKey = self
            ToggleDropDownMenu(1, nil, KBDropDown, self, 30, 20)
        end
    end)

    local glowBox = CreateFrame("Frame", nil, button, "GlowBoxTemplate")
    glowBox:SetSize(68, 68)
    glowBox:SetPoint("CENTER", button, "CENTER", 0, 0)
    glowBox:Hide()
    glowBox:SetFrameLevel(button:GetFrameLevel())

    button.glowBox = glowBox

    return button
end

-- SwitchBoard(board) - This function switches the key binding board to display different key bindings.
function addon:SwitchBoard(board)
    if KeyBindAllBoards[board] and addonOpen == true and addon.keyboardFrame then
        board = KeyBindAllBoards[board]
        
        addon.keyboardFrame:SetWidth(100)
        addon.keyboardFrame:SetHeight(100)

        local cx, cy = addon.keyboardFrame:GetCenter()
        local left, right, top, bottom = cx, cx, cy, cy

        for i = 1, #board do
            local Key = Keys[i] or self:NewButton()

            if board[i][5] then
                Key:SetWidth(board[i][5])
                Key:SetHeight(board[i][6])
            else
                Key:SetWidth(70)
                Key:SetHeight(70)
            end

            if not Keys[i] then
                Keys[i] = Key
            end

            Key:SetPoint("TOPLEFT", self.keyboardFrame, "TOPLEFT", board[i][3], board[i][4])
            Key.label:SetText(board[i][1])
            local tempframe = Key
            tempframe:Show()

            local l, r, t, b = Key:GetLeft(), Key:GetRight(), Key:GetTop(), Key:GetBottom()

            if l < left then
                left = l
            end
            if r > right then
                right = r
            end
            if t > top then
                top = t
            end
            if b < bottom then
                bottom = b
            end
        end

        self.keyboardFrame:SetWidth(right - left + 15)
        self.keyboardFrame:SetHeight(top - bottom + 14)
        KBControlsFrame:SetWidth(self.keyboardFrame:GetWidth())

    end
end

function addon:SwitchBoardMouse()
    if addonOpen == true and addon.MouseFrame then
        if CurrentLayout then
            
            -- Calculate the center of the Mouse frame once
            local cx, cy = addon.MouseFrame:GetCenter()
            local left, right, top, bottom = cx, cx, cy, cy

            for _, layoutData in pairs(CurrentLayout) do
                for i = 1, #layoutData do
                    local MouseKey = KeysMouse[i] or self:NewButtonMouse()
                    local currentLayout = layoutData[i]

                    if currentLayout[5] then
                        MouseKey:SetWidth(currentLayout[5])
                        MouseKey:SetHeight(currentLayout[6])
                    else
                        MouseKey:SetWidth(85)
                        MouseKey:SetHeight(85)
                    end

                    if not KeysMouse[i] then
                        KeysMouse[i] = MouseKey
                    end

                    MouseKey:SetPoint("TOPRIGHT", self.MouseFrame, "TOPRIGHT", currentLayout[3], currentLayout[4])
                    MouseKey.label:SetText(currentLayout[1])
                    local tempframe = MouseKey
                    tempframe:Show()
                end
            end

            -- After all buttons are added, set the size of the Mouse frame
            for i = 1, #KeysMouse do
                local l, r, t, b = KeysMouse[i]:GetLeft(), KeysMouse[i]:GetRight(), KeysMouse[i]:GetTop(), KeysMouse[i]:GetBottom()

                if l < left then
                    left = l
                end
                if r > right then
                    right = r
                end
                if t > top then
                    top = t
                end
                if b < bottom then
                    bottom = b
                end
            end
        end
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

    -- Standard ActionButton logic
    for i = 1, GetNumBindings() do
        local a = GetBinding(i)
        if spell:find(a) then
            local slot = spell:match("ACTIONBUTTON(%d+)") or spell:match("BT4Button(%d+)")
            local bar, bar2 = spell:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
            if bar and bar2 then
                if bar == "0" then slot = bar2 end
                if bar == "1" then slot = 60 + bar2 end
                if bar == "2" then slot = 48 + bar2 end
                if bar == "3" then slot = 24 + bar2 end
                if bar == "4" then slot = 36 + bar2 end
                if bar == "5" then slot = 144 + bar2 end
                if bar == "6" then slot = 156 + bar2 end
                if bar == "7" then slot = 168 + bar2 end
            end
            if slot then
                button.icon:SetTexture(GetActionTexture(slot))
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                button.icon:Show()
                button.slot = slot
            end
        end
    end

    -- Custom logic for ElvUI buttons
    for barIndex = 1, 15 do
        for buttonIndex = 1, 12 do
            local elvUIButtonName = "ELVUIBAR" .. barIndex .. "BUTTON" .. buttonIndex
            if spell == elvUIButtonName then
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
        end
    end

    -- code for setting icons for other actions (movement, pets, etc.)
    if spell == "EXTRAACTIONBUTTON1" then
        button.icon:SetTexture(4200126)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    elseif spell == "MOVEFORWARD" then
        button.icon:SetTexture(450907)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    elseif spell == "MOVEBACKWARD" then
        button.icon:SetTexture(450905)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()    
    elseif spell == "STRAFELEFT" then
        button.icon:SetTexture(450906)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    elseif spell == "STRAFERIGHT" then
        button.icon:SetTexture(450908)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.icon:Show()
    end

    if PetHasActionBar() == true then
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            for i = 1, 10 do
                local petspellName = "BONUSACTIONBUTTON" .. i
                if spell:match(petspellName) then
                    local pet = GetPetActionInfo(i)
                    if pet then
                        local petTexture = GetSpellTexture(pet)
                        if petTexture then
                            button.icon:SetTexture(petTexture)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = petTexture
                        end
                        if pet == "PET_ACTION_ATTACK" then
                            button.icon:SetTexture(132152)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 132152
                        elseif pet == "PET_MODE_DEFENSIVEASSIST" then
                            button.icon:SetTexture(132110)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 132110
                        elseif pet == "PET_MODE_PASSIVE" then
                            button.icon:SetTexture(132311)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 132311
                        elseif pet == "PET_MODE_ASSIST" then
                            button.icon:SetTexture(524348)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 524348
                        elseif pet == "PET_ACTION_FOLLOW" then
                            button.icon:SetTexture(132328)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 132328
                        elseif pet == "PET_ACTION_MOVE_TO" then
                            button.icon:SetTexture(457329)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 457329
                        elseif pet == "PET_ACTION_WAIT" then
                            button.icon:SetTexture(136106)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 136106
                        elseif pet == "PET_MODE_DEFENSIVE" then
                            button.icon:SetTexture(132110)
                            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                            button.icon:Show()
                            button.slot = 132110
                        end
                    else
                        button.icon:Hide()
                        button.slot = nil
                    end
                end
            end
        end
    else
        if spell:match("^BONUSACTIONBUTTON%d+$") then
            button.icon:Hide()
            button.slot = nil
        end
    end
    
    -- handling empty bindings
    if ShowEmptyBinds == true then
        local labelText = button.label:GetText()
        if spell == "" and not tContains({"ESC", "CAPS", "LSHIFT", "LCTRL", "LALT", "RALT", "RCTRL", "RSHIFT", "BACKSPACE", "ENTER", "SPACE"}, labelText) then
            button:SetBackdropColor(1, 1, 1, 1)
            if button.glowBox then
                button.glowBox:Show()
            end
        else
            button:SetBackdropColor(0, 0, 0, 1)
            if button.glowBox then
                button.glowBox:Hide()
            end
        end
    else
        button:SetBackdropColor(0, 0, 0, 1)  -- Reset to the default color if a binding is set
        if button.glowBox then
            button.glowBox:Hide()
        end
    end

	button.macro:SetText(spell) -- Macro = Blizzard Interface Command (e.g. STRAFE etc.) ////// Spell = Key (e.g. 1, 2, 3, ..., Q, W, E, R, T, Z,..)

    -- additional logic for interface bindings if needed
    if button.interfaceaction then
        if ShowInterfaceBinds == true then
            button.interfaceaction:Show()
        else
            button.interfaceaction:Hide()
        end
    end

    -- Get the current text from "button.macro"
    local currentText = button.macro:GetText()
    -- Look up the corresponding text in the "KeyMappings" table
    local newText = KeyMappings[currentText] or currentText
    -- Check if newText is nil (not found in KeyMappings)
    if newText == nil then
        newText = currentText  -- Use the original text if not found
    end
    -- Set the new text in "button.interfaceaction"
    button.interfaceaction:SetText(newText)

    if LabelMapping[button.label:GetText()] then
        button.label:Hide()
        button.ShortLabel:SetText(LabelMapping[button.label:GetText()])
    end
end

-- RefreshKeys() - Updates the display of key bindings and their textures/texts.
function addon:RefreshKeys()
    if not locked then
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
                        addon:RefreshKeys()
                    else
                        SetBinding(key, command)
                        SaveBindings(2)
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

function addon:CreateChangerDD() 
    local KBChangeBoardDD = CreateFrame("Frame", "KBChangeBoardDD", KBControlsFrame, "UIDropDownMenuTemplate")

    KBChangeBoardDD:SetPoint("BOTTOM", KBControlsFrame, "BOTTOM", 0, 14)
    UIDropDownMenu_SetWidth(KBChangeBoardDD, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDD, 120)
    KBChangeBoardDD:Hide()

    local boardCategories = {
        QWERTZ = {"QWERTZ_PRIMARY", "QWERTZ_60%", "QWERTZ_80%", "QWERTZ_100%"},
        QWERTY = {"QWERTY_PRIMARY", "QWERTY_60%", "QWERTY_80%", "QWERTY_100%"},
        AZERTY = {"AZERTY_PRIMARY", "AZERTY_60%", "AZERTY_80%", "AZERTY_100%"},
        DVORAK = {"DVORAK_PRIMARY", "DVORAK_60%", "DVORAK_80%", "DVORAK_100%"},
        Razer = {"Razer_Tartarus", "Razer_Tartarus2"},
        Azeron = {"Azeron"}
    }

    local categoryOrder = {"QWERTZ", "QWERTY", "AZERTY", "DVORAK", "Razer", "Azeron"}

    local function ChangeBoardDD_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
        local value = UIDROPDOWNMENU_MENU_VALUE
    
        if level == 1 then
            for _, category in ipairs(categoryOrder) do 
                info.text = category
                info.value = category
                info.hasArrow = true
                info.notCheckable = true
                info.menuList = category
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 then
            local layouts = boardCategories[value]
            if layouts then
                for _, name in ipairs(layouts) do
                    info.text = name
                    info.value = name
                    info.func = function()
                        KeyBindSettings.currentboard = name
                        addon:RefreshKeys()
                        UIDropDownMenu_SetText(KBChangeBoardDD, name)
                        if maximizeFlag == true then
                            KBControlsFrame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
                        else
                            return
                        end
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end

    UIDropDownMenu_Initialize(KBChangeBoardDD, ChangeBoardDD_Initialize)
    self.ddChanger = KBChangeBoardDD
    return KBChangeBoardDD
end

function addon:CreateChangerDDMouse()
    local KBChangeBoardDDMouse = CreateFrame("Frame", "KBChangeBoardDDMouse", MouseControls, "UIDropDownMenuTemplate")

    KBChangeBoardDDMouse:SetPoint("TOP", MouseControls, "TOP", -20, -10)
    UIDropDownMenu_SetWidth(KBChangeBoardDDMouse, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDDMouse, 120)
    KBChangeBoardDDMouse:Hide()

    local boardOrder = {"Layout_4x3", 'Layout_2+4x3', "Layout_3x3", "Layout_3x2", "Layout_1+2x2", "Layout_2x2", "Layout_2x1", "Layout_Circle"}

    local function ChangeBoardDDMouse_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
        local value = UIDROPDOWNMENU_MENU_VALUE

        for _, name in ipairs(boardOrder) do
            local Mousebuttons = KeyBindAllBoardsMouse[name]
            info.text = name
            info.value = name
            info.colorCode = "|cFFFFFFFF" -- white
            info.func = function()
                KeyBindSettingsMouse.currentboard = name
                wipe(CurrentLayout)
                CurrentLayout = {[name] = KeyBindAllBoardsMouse[name]}
                addon:RefreshKeys()
                UIDropDownMenu_SetText(self, name)
                MouseControls.Input:SetText("")
                MouseControls.Input:ClearFocus()
            end
            UIDropDownMenu_AddButton(info, level)
        end

        if type(MouseKeyEditLayouts) == "table" then
            for name, layout in pairs(MouseKeyEditLayouts) do
                info.text = name
                info.value = name
                info.colorCode = "|cFF31BD22" -- green
                info.func = function()
                    wipe(CurrentLayout)
                    CurrentLayout[name] = layout
                    addon:RefreshKeys()
                    UIDropDownMenu_SetText(self, name)
                    MouseControls.Input:SetText("")
                    MouseControls.Input:ClearFocus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        else
            return
        end
        --info.text = "New Layout"
        --info.value = "New Layout"
        --info.colorCode = "|cFFFFFF00" -- Yellow
        --info.func = function()
        --    Mouse.Input:SetText("New Layout")
        --    for _, k in pairs(KeysMouse) do
        --        k:Hide()
        --    end
        --    UIDropDownMenu_SetText(self, "New Layout")
        --end
        --UIDropDownMenu_AddButton(info, level)
    end
    UIDropDownMenu_Initialize(KBChangeBoardDDMouse, ChangeBoardDDMouse_Initialize)
    self.ddChangerMouse = KBChangeBoardDDMouse
    return KBChangeBoardDDMouse
end

-- BattleCheck(event) - Checks whether the player is in combat or not and adjusts the display accordingly.
function addon:BattleCheck(event)
    if event == "PLAYER_REGEN_DISABLED" then
        fighting = true
        --print("fighting true")
        if addonOpen then
            KeyUIMainFrame:Hide()
            KBControlsFrame:Hide()
            MouseControls:Hide()
            Mouseholder:Hide()
            MouseFrame:Hide()
            addonOpen = false
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        fighting = false
        --print("fighting false")
    end
end

local function OnEvent(self, event, ...)
    C_Timer.After(0.01, function()
        addon:RefreshKeys()
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ACTIONBAR_SHOWGRID")
f:RegisterEvent("ACTIONBAR_HIDEGRID")
f:RegisterEvent("UNIT_PET")
f:SetScript("OnEvent", OnEvent)

-- SpecCheck - Monitors changes in the player's talents.
local SpecCheck = CreateFrame("Frame", "BackdropTemplate")
SpecCheck:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecCheck:SetScript("OnEvent", function(self, spec) end)

-- EventCheck - Monitors various in-game events such as entering and leaving combat mode.
local EventCheck = CreateFrame("Frame")
EventCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
EventCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
EventCheck:SetScript("OnEvent", function(self, event) addon:BattleCheck(event) end)

-- SlashCmdList["KeyUI"] - Registers a command to load the addon.
SLASH_KeyUI1 = "/kui"
SLASH_KeyUI2 = "/keyui"
SlashCmdList["KeyUI"] = function() addon:Load() end