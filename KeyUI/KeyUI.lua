local name, addon = ...

KeyBindSettings = {}

local fighting = false -- if the player is in combat or not
local Keys = {} --stores the key buttons once they are created

local DefaultBoard = KeyBindAllBoards.qwertz

local modif = {} --table that stores the modifiers
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

function addon:LoadDropDown()
	self.menu = {}

end

function addon:LoadSpells()
	self.spells = {}
	for i = 1, GetNumSpellTabs() do
		local name, texture, offset, numSpells = GetSpellTabInfo(i);
		self.spells[name] = {}

		if not name then
			--break
		end

		for j = offset+1, (offset+numSpells) do
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


function addon:ButtonMouseOver(button) --change the tooltip and highlight
	local KBTooltip = self.tooltip
	KBTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 10, 0)
	KBTooltip.title:SetText((button.label:GetText() or "")..":\n"..(button.macro:GetText() or ""))
	if button.slot then
		--KBTooltip:SetAction(button.slot)
		GameTooltip:SetOwner(button, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT")
		GameTooltip:SetAction(button.slot)

		GameTooltip:Show()
	end
	KBTooltip:SetWidth(KBTooltip.title:GetWidth()+10)
	KBTooltip:SetHeight(KBTooltip.title:GetHeight()+10)

	if (KBTooltip:GetWidth() < 15) or button.macro:GetText() == "" then
		KBTooltip:Hide()
	else
		KBTooltip:Show()
	end

end





function addon:SwitchBoard(board)
	if KeyBindAllBoards[board] or KBEditLayouts[board] then
		board = KeyBindAllBoards[board] or KBEditLayouts[board]

		local cx, cy = self.keyboardFrame:GetCenter()
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

		self.keyboardFrame:SetWidth(right-left + 15)
		self.keyboardFrame:SetWidth(right-left + 15)
		self.keyboardFrame:SetHeight(top-bottom+ 10)
		self.keyboardFrame:SetHeight(top-bottom+ 10)

	end

end

function addon:CheckModifiers()
	for v, button in pairs(Keys) do --change the events for shift/ctrl/alt
		if self.modif[button.label:GetText()] then

			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button:SetScript("OnMouseDown", nil)
			button:SetScript("OnMouseUp", nil)

			button:SetScript("OnMouseDown", function(self)  end)
			button:SetScript("OnEnter", function(self)  end)


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
											modif[button.label:GetText()] = button.label:GetText().."-"
											addon:RefreshKeys()

										end
								end)
		end
	end
end

function addon:SetKey(button) -- set the texture/text for the key
	local spell = GetBindingAction(modif.CTRL..modif.SHIFT..modif.ALT..(button.label:GetText() or "")) or ""

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
	elseif spell:find("^ITEM") then
		button.icon:Show()
		spell = spell:match("ITEM%s(.*)")
		button.icon:SetTexture(select(10, GetItemInfo(spell)))
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.type = "item"
	else
		button.icon:Hide()
		local found = false
		for i = 1, GetNumBindings() do
		local a = GetBinding(i)
			if spell:find(a) then

				local slot = spell:match("ACTIONBUTTON(%d+)") or spell:match("BT4Button(%d+)")

				if slot then
					button.icon:SetTexture(GetActionTexture(slot))
					button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
					button.icon:Show()
					button.slot = slot
					--tooltip
				end
				spell = GetBindingText(spell, "BINDING_NAME_") or spell
				button.type = "interface"

				found = true

				--break -- ?
			end
		end
		if not found then
			button.type = "none"
		end
	end
	button.macro:SetText(spell)
end


function addon:RefreshKeys() --refresh all the highlights and text for the buttons

	for i = 1, #Keys do
		Keys[i]:Hide()
	end

	self:SwitchBoard(KeyBindSettings.currentboard or DefaultBoard)
	self:CheckModifiers()


	for i = 1, #Keys do
		self:SetKey(Keys[i])
	end
end



--dropdown stuffs:

local function DropDown_Initialize(self, level) -- the menu items, needs a cleanup
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
									SetBinding(modif.CTRL..modif.SHIFT..modif.ALT..(addon.currentKey.label:GetText() or ""))
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


	elseif level ==2 then
		if value == "Spell" then
			for tabName, v in pairs(addon.spells) do
				info.text = tabName
				info.value = 'tab:'..tabName
				info.tooltipTitle = tabName
				info.hasArrow = true
				info.func = function() end
				UIDropDownMenu_AddButton(info, level)
			end
		end

		if value == "General Macro" then
			for i = 1,36 do
			local title, iconTexture, body = GetMacroInfo(i)
				if title then
				info.text = title
				info.value = title
				info.tooltipTitle = title
				info.tooltipText = body
				info.hasArrow = false
				info.func = function(self) SetBindingMacro(modif.CTRL..modif.SHIFT..modif.ALT..(
					addon.currentKey.label:GetText() or ""), title) SaveBindings(2) addon:RefreshKeys() end
				UIDropDownMenu_AddButton(info, level)
				end

			end
		end

		if value == "Player Macro" then
			for i =  MAX_ACCOUNT_MACROS+1, MAX_ACCOUNT_MACROS+MAX_CHARACTER_MACROS do
			local title, iconTexture, body = GetMacroInfo(i)
				if title then
				info.text = title
				info.value = title
				info.tooltipTitle = title
				info.tooltipText = body
				info.hasArrow = false
				info.func = function(self) SetBindingMacro(modif.CTRL..modif.SHIFT..modif.ALT..(addon.currentKey.label:GetText() or ""), title) SaveBindings(2) addon:RefreshKeys() end
				UIDropDownMenu_AddButton(info, level)
				end
			end
		end

	elseif level == 3 then
		if value:find("^tab:") then
			local tabName = value:match('^tab:(.+)')
			for k,spellName in pairs(addon.spells[tabName]) do
				info.text = spellName
				info.value = spellName
				info.hasArrow = false
				info.func = function(self) SetBindingSpell(modif.CTRL..modif.SHIFT..modif.ALT..(addon.currentKey.label:GetText() or ""), spellName) SaveBindings(2) addon:RefreshKeys() end
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

function addon:CreateDropDown()
	local DropDown = CreateFrame("Frame", "KBDropDown", self.keyboardFrame, "UIDropDownMenuTemplate", BackdropTemplateMixin and "BackdropTemplate")
	UIDropDownMenu_SetWidth(DropDown, 60)
	UIDropDownMenu_SetButtonWidth(DropDown, 20)
	DropDown:Hide()
	self.dropdown = DropDown
	UIDropDownMenu_Initialize(DropDown, DropDown_Initialize, "MENU")
	return DropDown
end

--IsPassiveSpell(spellID, "bookType")


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
					modif[button.label:GetText()] = button.label:GetText().."-"
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
	UIDropDownMenu_SetWidth(KBChangeBoardDD, 150)
	UIDropDownMenu_SetButtonWidth(KBChangeBoardDD, 100)



	local function ChangeBoardDD_Initialize(self, level) -- the menu items, needs a cleanup
			level = level or 1
		local info = UIDropDownMenu_CreateInfo()
		local value = UIDROPDOWNMENU_MENU_VALUE

		info.colorCode = "|cFF31BD22"
		for name, buttons in pairs(KeyBindAllBoards) do
			info.text = name
			info.value = name
			info.func = function() KeyBindSettings.currentboard = name addon:RefreshKeys() UIDropDownMenu_SetText(self, name) end
			UIDropDownMenu_AddButton(info, level)
		end


		info.colorCode = "|cFFFFFFFF"
		if KBEditLayouts then
			for name in pairs(KBEditLayouts) do
				info.text = name

				--set color
				info.value = name
				info.func = function() KeyBindSettings.currentboard = name addon:RefreshKeys() UIDropDownMenu_SetText(self, name) end
				UIDropDownMenu_AddButton(info,level)
			end
		end
	end


	UIDropDownMenu_Initialize(KBChangeBoardDD, ChangeBoardDD_Initialize)
	self.ddChanger = KBChangeBoardDD
	return KBChangeBoardDD
end
local KeyCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
KeyCheck:EnableKeyboard(true)
KeyCheck:EnableKeyboard(true)
--KeyCheck:SetScript("OnKeyDown", KeyHandler)

function addon:BattleCheck(event)
	if event == "PLAYER_REGEN_DISABLED" then
		fighting = true
		if self.keyboardFrame then
			self.keyboardFrame:Hide()
			self.controlsFrame:Hide()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		fighting = false
	elseif event == "PLAYER_TARGET_CHANGED" then
		--addon:RefreshKeys()
	end
end

local SpecCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
SpecCheck:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecCheck:SetScript("OnEvent", function(self, spec) end)

local EventCheck = CreateFrame("Frame", BackdropTemplateMixin and "BackdropTemplate")
EventCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
EventCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
EventCheck:RegisterEvent("PLAYER_TARGET_CHANGED")
EventCheck:SetScript("OnEvent", function(self,event) addon:BattleCheck(event) end)


SLASH_KeyBind1 = "/kui";
SLASH_KeyBind2 = "/keyui";
SlashCmdList["KeyBind"] = function() addon:Load() end