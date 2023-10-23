local name, addon = ...

--SavedVariables--------------
MiniMapDB = {}
ShowEmptyBinds = {}
ShowInterfaceBinds = {}
KeyBindSettings = {}
KeyBindSettingsMouse = {}
MouseKeyEditLayouts = {}
CurrentLayout = {}
------------------------------

KeysMouse = {}
local addonOpen = false
local fighting = false
local keyboardFrameVisible = false
local MouseholderFrameVisible = false
local Keys = {}

local KeyIcon = LibStub("LibDataBroker-1.1"):NewDataObject("KeyUI", {
    type = "data source",
    text = "KeyUI",
    icon = "Interface\\AddOns\\KeyUI\\Media\\keyboard",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if addonOpen then
                keyboardFrame:Hide()
                KBControlsFrame:Hide()
                Mouseholder:Hide()
                MouseControls:Hide()
                addonOpen = false
            else
                if fighting == false then
                    addon:Load()
                    addonOpen = true
                end
            end
        end
    end,
    
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine("KeyUI")
        -- tooltip:AddLine("BLA BLA BLA", 1, 1, 1)    
    end,
})
local icon = LibStub("LibDBIcon-1.0")
icon:Register("KeyUI", KeyIcon, MiniMapDB)

-- Define the modif table
local modif = {}
modif.CTRL = ""
modif.SHIFT = ""
modif.ALT = ""
addon.modif = modif

function addon:Load()
    local keyboard = self:GetKeyboard()
    local Controls = self:GetControls()
    local Mouseholder = self:GetMouseholder()
    local MouseFrame = self:GetMouseFrame()
    local MouseControls = self:GetMouseControls()

    if fighting then
        return
    else
        addonOpen = true

        keyboard:Show()
        Controls:Show()
        Mouseholder:Show()
        MouseFrame:Show()
        MouseControls:Show()

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

-- LoadDropDown() - This function initializes the dropdown menu for key bindings.
function addon:LoadDropDown()
    self.menu = {}
end

-- LoadSpells() - Here, all available spells and abilities of the player are loaded and stored in a table.
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
        --print("addonOpen = false")
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
        end

    KBTooltip:SetWidth(KBTooltip.title:GetWidth() + 20)
    KBTooltip:SetHeight(KBTooltip.title:GetHeight() + 20)
    

    if (KBTooltip:GetWidth() < 15) or button.macro:GetText() == "" then
        KBTooltip:Hide()
    else
        KBTooltip:Show()
    end
end

function addon:NewButton(parent)
    if not parent then
        parent = self.keyboardFrame
    end
    local button = CreateFrame("FRAME", nil, parent, "TooltipBorderedFrameTemplate")
    button:SetMovable(true)
    button:EnableMouse(true)
    button:SetBackdropColor(0, 0, 0, 1)

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.label:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
    button.label:SetTextColor(1, 1, 1, 0.9)
    button.label:SetHeight(50)
    button.label:SetWidth(100)
    button.label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -4, -6)
    button.label:SetJustifyH("RIGHT")
    button.label:SetJustifyV("TOP")

    --button.macro = Blizzard ID Commands
    button.macro = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.macro:SetText("")
    button.macro:Hide()

    --button.interfaceaction = Blizzard ID changed to readable Text
    button.interfaceaction = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    button.interfaceaction:SetTextColor(1, 1, 1)
    button.interfaceaction:SetHeight(64)
    button.interfaceaction:SetWidth(64)
    button.interfaceaction:SetPoint("CENTER", button, "CENTER", 0, -6)
    button.interfaceaction:SetText("")

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(60, 60)
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)

    button:SetScript("OnEnter", function()
        self:ButtonMouseOver(button)
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        KeyUITooltip:Hide()
    end)
    button:SetScript("OnMouseDown", function()
    end)
    button:SetScript("OnMouseUp", function(self, Mousebutton)
        if Mousebutton == "LeftButton" then
            infoType, info1, info2 = GetCursorInfo()

            if infoType == "spell" then
                local spellname = GetSpellBookItemName(info1, info2)
                addon.currentKey = self
                SetBindingSpell(modif.CTRL..modif.SHIFT..modif.ALT..(addon.currentKey.label:GetText() or ""), spellname)
                ClearCursor()
                SaveBindings(2)
                addon:RefreshKeys()
            end
        elseif Mousebutton == "RightButton" then
            addon.currentKey = self
            ToggleDropDownMenu(1, nil, KBDropDown, self, 30, 20)
        end
    end)
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
    local found = false
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
            elseif slot then
                button.icon:SetTexture(GetActionTexture(slot))
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                button.icon:Show()
                button.slot = slot
            end
        end
    end
    
    if ShowEmptyBinds == true then
        local labelText = button.label:GetText()
        if spell == "" and labelText ~= "ESC" and labelText ~= "CAPS" and labelText ~= "LSHIFT" and labelText ~= "LCTRL" and labelText ~= "LALT" and labelText ~= "RALT" and labelText ~= "RCTRL" and labelText ~= "RSHIFT" and labelText ~= "BACKSPACE" and labelText ~= "ENTER" and labelText ~= "SPACE" then

            button:SetBackdropColor(1, 0, 0, 1)  -- Highlight in red if no binding and not one of the specified keys
        else
            button:SetBackdropColor(0, 0, 0, 1)
        end
    else
        button:SetBackdropColor(0, 0, 0, 1)  -- Reset to the default color if a binding is set
    end    

	button.macro:SetText(spell) -- Macro = Blizzard Interface Command (e.g. STRAFE etc.) ////// Spell = Key (e.g. 1, 2, 3, ..., Q, W, E, R, T, Z,..)

    if button.interfaceaction then
        if ShowInterfaceBinds == true then
        -- Check if there's no icon before setting the text
            button.interfaceaction:Show()
        else
            button.interfaceaction:Hide()
        end
    end
    -- Get the current text from "button.macro"
    local currentText = button.macro:GetText()
    -- Look up the corresponding text in the "KeyMappings" table
    local newText = KeyMappings[currentText]
    -- Check if newText is nil (not found in KeyMappings)
    if newText == nil then
        newText = currentText  -- Use the original text if not found
    end
    -- Set the new text in "button.interfaceaction"
    button.interfaceaction:SetText(newText)
end

-- RefreshKeys() - Updates the display of key bindings and their textures/texts.
function addon:RefreshKeys()
    if not locked then
    --if not locked or UIDropDownMenu_GetText(self.ddChangerMouse) == "New Layout" then
        return -- Do nothing if not locked or if "New Layout" is selected
    end

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
        --print("Keys edited = false")
        self:SwitchBoardMouse()
    end
    self:CheckModifiers()
    addon:RefreshControls()

    for i = 1, #Keys do
        self:SetKey(Keys[i])
    end

    for j = 1, #KeysMouse do
        self:SetKey(KeysMouse[j])
    end
    --print("Keys refreshed")
end

-- Define a function to handle key press events
local function HandleKeyPress(key)
    if addonOpen then
        if AltCheckbox == false and CtrlCheckbox == false and ShiftCheckbox == false then
            if key == "LSHIFT" or key == "RSHIFT" then
                modif.SHIFT = "SHIFT-"
            elseif key == "LCTRL" or key == "RCTRL" then
                modif.CTRL = "CTRL-"
            elseif key == "LALT" or key == "RALT" then
                modif.ALT = "ALT-"
            end
            addon:RefreshKeys()  -- Refresh the displayed keys with the updated modifiers
        end
    end
end

-- Define a function to handle key release events
local function HandleKeyRelease(key)
    if addonOpen then
        if AltCheckbox == false and CtrlCheckbox == false and ShiftCheckbox == false then
            if key == "LSHIFT" or key == "RSHIFT" then
                modif.SHIFT = ""
            elseif key == "LCTRL" or key == "RCTRL" then
                modif.CTRL = ""
            elseif key == "LALT" or key == "RALT" then
                modif.ALT = ""
            end
            addon:RefreshKeys()  -- Refresh the displayed keys with the updated modifiers
        end
    end
end

-- Register for key events
local frame = CreateFrame("Frame")
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:SetScript("OnEvent", function(_, event, key, state)
    if event == "MODIFIER_STATE_CHANGED" then
        if state == 1 then
            -- Key press event
            HandleKeyPress(key)
        else
            -- Key release event
            HandleKeyRelease(key)
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
                    local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                    local command = "Spell " .. spellName
                    SetBinding(key, command)
                    SaveBindings(2)
                    addon:RefreshKeys()
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
                        local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        SetBinding(key, command)
                        SaveBindings(2)
                        addon:RefreshKeys()
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
                        local key = modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or "")
                        local command = "Macro " .. title
                        SetBinding(key, command)
                        SaveBindings(2)
                        addon:RefreshKeys()
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

local function KeyHandler(self, key)
    if modif[key] then
        for v, button in pairs(Keys) do
            if modif[button.label:GetText()] then
                if button.active then
                    button.active = false
                    modif[button.label:GetText()] = ""
                    addon:RefreshKeys()
                else
                    button.active = true
                    modif[button.label:GetText()] = button.label:GetText() .. "-"
                    addon:RefreshKeys()
                end
            end
        end
    end
end

function addon:CreateChangerDD() 
    local KBChangeBoardDD = CreateFrame("Frame", "KBChangeBoardDD", KBControlsFrame, "UIDropDownMenuTemplate")

    KBChangeBoardDD:SetPoint("BOTTOM", KBControlsFrame, "BOTTOM", 0, 14)
    UIDropDownMenu_SetWidth(KBChangeBoardDD, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDD, 120)
    KBChangeBoardDD:Hide()

    local boardOrder = {"QWERTZ_SLIM", "QWERTZ_TKL", "QWERTZ_FULL", "QWERTY_SLIM", "QWERTY_TKL", "QWERTY_FULL", "AZERTY_SLIM", "AZERTY_TKL", "AZERTY_FULL", "Razer_Tartarus", "Razer_Tartarus2", "Azeron"}

    local function ChangeBoardDD_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
        local value = UIDROPDOWNMENU_MENU_VALUE
    
        for _, name in ipairs(boardOrder) do 
            local buttons = KeyBindAllBoards[name]
            info.text = name
            info.value = name
            info.func = function()
                KeyBindSettings.currentboard = name
                addon:RefreshKeys()
                UIDropDownMenu_SetText(self, name)
                if maximizeFlag == true then
                    KBControlsFrame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
                else
                    return
                end
            end
            UIDropDownMenu_AddButton(info, level)
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

local function editmodecb(ownerID, ...)
    fighting=false
    --print("fighting false")
end

local function editmodecb2(ownerID, ...)
    fighting=true
    --print("fighting true")
    if addonOpen then
        KeyUIMainFrame:Hide()
        KBControlsFrame:Hide()
        MouseControls:Hide()
        Mouseholder:Hide()
        MouseFrame:Hide()
        addonOpen = false
    end
end

local function OnEvent(self, event, ...)
	addon:RefreshKeys()
end

local f = CreateFrame("Frame")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:SetScript("OnEvent", OnEvent)

-- SpecCheck - Monitors changes in the player's talents.
local SpecCheck = CreateFrame("Frame", "BackdropTemplate")
SpecCheck:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecCheck:SetScript("OnEvent", function(self, spec) end)

-- EventCheck - Monitors various in-game events such as entering and leaving combat mode.
local EventCheck = CreateFrame("Frame", "BackdropTemplate")
EventCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
EventCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
EventRegistry:RegisterCallback("EditMode.Exit",editmodecb)
EventRegistry:RegisterCallback("EditMode.Enter",editmodecb2)
EventCheck:SetScript("OnEvent", function(self, event) addon:BattleCheck(event) end)

-- SlashCmdList["KeyBind"] - Registers a command to load the addon.
SLASH_KeyBind1 = "/kui"
SLASH_KeyBind2 = "/keyui"
SlashCmdList["KeyBind"] = function() addon:Load() end