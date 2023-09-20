local name, addon = ...

local LibStub = LibStub
local icon = LibStub("LibDBIcon-1.0")
icon:Register("KeyUI", {
    icon = "Interface\\\AddOns\\KeyUI\\Media\\keyboard", -- Pfade zum Icon
    OnClick = function(self, button)
        if button == "LeftButton" then
            if firstClick then
                addon.keyboardFrame:Hide()
                addon.controlsFrame:Hide()
            else
                addon:Load()
            end
            firstClick = not firstClick
        end
    end,
     OnTooltipShow = function(tooltip)
        -- Hier kannst du eine Tooltip-Beschreibung für dein Minimap-Icon hinzufügen
        tooltip:SetText("KeyUI")
        -- tooltip:AddLine("Klick, um Aktion auszuführen", 1, 1, 1)
     end,
})

KeyBindSettings = {}

local fighting = false -- Indicates whether the player is in combat or not
local Keys = {} -- Stores the key buttons once they are created

local DefaultBoard = KeyBindAllBoards.QWERTZ

local modif = {} -- Table that stores the modifiers
modif.CTRL = ""
modif.SHIFT = ""
modif.ALT = ""

addon.modif = modif

function addon:Load()
    if fighting then
        return
    end
    local keyboard = self.keyboardFrame or self:CreateKeyboard()
    local controls = self.controlsFrame or self:CreateControls()
    local dropdown = self.dropdown or self:CreateDropDown()
    local tooltip = self.tooltip or self:CreateTooltip()
    self.ddChanger = self.ddChanger or self:CreateChangerDD()
    controls:Show()
    keyboard:Show()
    self:LoadSpells()
    self:LoadDropDown()
    self:RefreshKeys()
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

function addon:GetKeyboard()
    return self.keyboardFrame
end

-- ButtonMouseOver(button) - This function is called when the mouse cursor hovers over a key binding button. It displays a tooltip description of the spell or ability.
function addon:ButtonMouseOver(button)
    local KBTooltip = self.tooltip
    KBTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 10, 0)
    KBTooltip.title:SetText((button.label:GetText() or "") .. ":\n" .. (button.macro:GetText() or ""))
    if button.slot then
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
        GameTooltip:SetAction(button.slot)
        GameTooltip:Show()
    end
    KBTooltip:SetWidth(KBTooltip.title:GetWidth() + 10)
    KBTooltip:SetHeight(KBTooltip.title:GetHeight() + 10)

    if (KBTooltip:GetWidth() < 15) or button.macro:GetText() == "" then
        KBTooltip:Hide()
    else
        KBTooltip:Show()
    end
end

-- SwitchBoard(board) - This function switches the key binding board to display different key bindings.
function addon:SwitchBoard(board)
    if KeyBindAllBoards[board] then
        board = KeyBindAllBoards[board]

        local cx, cy = self.keyboardFrame:GetCenter()
        local left, right, top, bottom = cx, cx, cy, cy

        for i = 1, #board do
            local Key = Keys[i] or self:NewButton()

            if board[i][5] then
                Key:SetWidth(board[i][5])
                Key:SetHeight(board[i][6])
            else
                Key:SetWidth(85)
                Key:SetHeight(85)
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
        self.keyboardFrame:SetHeight(top - bottom + 10)
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
    -- print("spell:"..spell)
    if spell:find("^SPELL") then
        button.icon:Show()
        spell = spell:match("SPELL%s(.*)")
        button.icon:SetTexture(GetSpellTexture(spell))
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.type = "spell"
    elseif spell:find("^MACRO") then
        button.icon:Show()
        spell = spell:match("MACRO%s(.*)")
        button.icon:SetTexture(select(2, GetMacroInfo(spell)))
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.type = "macro"
    -- elseif spell:find("^ITEM") then
    --    button.icon:Show()
    --    spell = spell:match("ITEM%s(.*)")
    --    button.icon:SetTexture(select(10, GetItemInfo(spell)))
    --    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --    button.type = "item"
    else
        button.icon:Hide()
        local found = false
        for i = 1, GetNumBindings() do
            local a = GetBinding(i)
            if spell:find(a) then
                -- print("binding:"..i)
                --	print("a:"..a)
                local slot = spell:match("ACTIONBUTTON(%d+)") or spell:match("BT4Button(%d+)") 
		        local bar,bar2 = spell:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
                --	bindingAction = GetBindingByKey(modif.CTRL .. modif.SHIFT .. modif.ALT .. (button.label:GetText() or ""))
                --	if slot then print("slot:"..slot) end
                --	if bar then print("bar:"..bar) end
                --	if bar2 then print("bar2:"..bar2) end

	            if bar and bar2 then
	              if bar=="0" then slot=bar2 end
	              if bar=="1" then slot=60+bar2 end
	              if bar=="2" then slot=48+bar2 end
	              if bar=="3" then slot=24+bar2 end
	              if bar=="4" then slot=36+bar2 end
	              if bar=="5" then slot=144+bar2 end
	              if bar=="6" then slot=156+bar2 end
	              if bar=="7" then slot=168+bar2 end
                    --	if slot then print("slot:"..slot) end
	            end
	            if spell=="EXTRAACTIONBUTTON1" then
		        button.icon:SetTexture(4200126)
                    	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    	button.icon:Show()
	            else

                    if slot then
                    --		if slot then print("slot:"..slot) end
                        button.icon:SetTexture(GetActionTexture(slot))
                        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        button.icon:Show()
                        button.slot = slot
                    end
                end
                spell = GetBindingText(spell, "BINDING_NAME_") or spell
                button.type = "interface"
                found = true
            end
        end
        if not found then
            button.type = "none"
        end
    end
    button.macro:SetText(spell)
end

-- RefreshKeys() - Updates the display of key bindings and their textures/texts.
function addon:RefreshKeys()
    for i = 1, #Keys do
        Keys[i]:Hide()
    end

    self:SwitchBoard(KeyBindSettings.currentboard or DefaultBoard)
    self:CheckModifiers()

    for i = 1, #Keys do
        self:SetKey(Keys[i])
    end
end

-- Dropdown stuffs:

local function DropDown_Initialize(self, level)
    level = level or 1
    local info = UIDropDownMenu_CreateInfo()
    local value = UIDROPDOWNMENU_MENU_VALUE

    if level == 1 then
        info.text = "Unbind Key"
        info.value = 1
        info.tooltipTitle = "Unbind"
        info.tooltipText = "Removes all bindings from the selected key"
        info.func = function()
            if addon.currentKey.label ~= "" then
                SetBinding(modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or ""))
                addon.currentKey.macro:SetText("")
                addon:RefreshKeys()
                SaveBindings(2)
            end
        end
        UIDropDownMenu_AddButton(info, level)

        info.text = "General Macro"
        info.value = "General Macro"
        info.tooltipTitle = "Macro"
        info.tooltipText = "Bind the selected key to a general macro"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Player Macro"
        info.value = "Player Macro"
        info.tooltipTitle = "Macro"
        info.tooltipText = "Bind the selected key to a player-specific macro"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Spell"
        info.value = "Spell"
        info.tooltipTitle = "Spell"
        info.tooltipText = "Bind the selected key to a spell"
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        if value == "Spell" then
            for tabName, v in pairs(addon.spells) do
                info.text = tabName
                info.value = 'tab:' .. tabName
                info.tooltipTitle = tabName
                info.hasArrow = true
                info.func = function() end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        if value == "General Macro" then
            for i = 1, 36 do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.tooltipTitle = title
                    info.tooltipText = body
                    info.hasArrow = false
                    info.func = function(self)
                        SetBindingMacro(modif.CTRL .. modif.SHIFT .. modif.ALT .. (
                        addon.currentKey.label:GetText() or ""), title)
                        SaveBindings(2)
                        addon:RefreshKeys()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end

        if value == "Player Macro" then
            for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
                local title, iconTexture, body = GetMacroInfo(i)
                if title then
                    info.text = title
                    info.value = title
                    info.tooltipTitle = title
                    info.tooltipText = body
                    info.hasArrow = false
                    info.func = function(self)
                        SetBindingMacro(modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or ""), title)
                        SaveBindings(2)
                        addon:RefreshKeys()
                    end
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
                    SetBindingSpell(modif.CTRL .. modif.SHIFT .. modif.ALT .. (addon.currentKey.label:GetText() or ""), spellName)
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
    local DropDown = CreateFrame("Frame", "KBDropDown", self.keyboardFrame, "UIDropDownMenuTemplate", BackdropTemplateMixin and "BackdropTemplate")
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
    local Controls = self.controlsFrame
    local KBChangeBoardDDD = CreateFrame("Frame", "KBChangeBoardDD", Controls, "UIDropDownMenuTemplate", BackdropTemplateMixin and "BackdropTemplate")
    KBChangeBoardDD:SetPoint("TOPLEFT", -3, -10)
    UIDropDownMenu_SetWidth(KBChangeBoardDDD, 80)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDDD, 100)

    local function ChangeBoardDD_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
        local value = UIDROPDOWNMENU_MENU_VALUE

        info.colorCode = "|cFF31BD22"
        for name, buttons in pairs(KeyBindAllBoards) do
            info.text = name
            info.value = name
            info.func = function()
                KeyBindSettings.currentboard = name
                addon:RefreshKeys()
                UIDropDownMenu_SetText(self, name)
            end
            UIDropDownMenu_AddButton(info, level)
        end

        info.colorCode = "|cFFFFFFFF"
        if KBEditLayouts then
            for name in pairs(KBEditLayouts) do
                info.text = name
                info.value = name
                info.func = function()
                    KeyBindSettings.currentboard = name
                    addon:RefreshKeys()
                    UIDropDownMenu_SetText(self, name)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
    UIDropDownMenu_Initialize(KBChangeBoardDDD, ChangeBoardDD_Initialize)
    self.ddChanger = KBChangeBoardDDD
    return KBChangeBoardDDD
end

-- CreateChangerDD() - Creates a dropdown menu for switching between different key binding boards.
local KeyCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
KeyCheck:EnableKeyboard(true)

-- BattleCheck(event) - Checks whether the player is in combat or not and adjusts the display accordingly.
function addon:BattleCheck(event)
    if event == "PLAYER_REGEN_DISABLED" then
        fighting = true
        if self.keyboardFrame then
            self.keyboardFrame:Hide()
            self.controlsFrame:Hide()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        fighting = false
    end
end

local function editmodecb(ownerID, ...)
    fighting=false
    -- print("fightfalse")
end

local function editmodecb2(ownerID, ...)
    fighting=true
    -- print("fighttrue")
end


-- SpecCheck - Monitors changes in the player's talents.
local SpecCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
SpecCheck:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecCheck:SetScript("OnEvent", function(self, spec) end)

-- EventCheck - Monitors various in-game events such as entering and leaving combat mode.
local EventCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
EventCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
EventCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
EventRegistry:RegisterCallback("EditMode.Enter",editmodecb2)
EventRegistry:RegisterCallback("EditMode.Exit",editmodecb)
EventCheck:SetScript("OnEvent", function(self, event) addon:BattleCheck(event) end)

-- SlashCmdList["KeyBind"] - Registers a command to load the addon.
SLASH_KeyBind1 = "/kui"
SLASH_KeyBind2 = "/keyui"
SlashCmdList["KeyBind"] = function() addon:Load() end