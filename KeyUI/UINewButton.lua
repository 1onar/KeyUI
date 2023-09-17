local name, addon = ...

function addon:NewButton(parent) -- creates new buttons to add the the keyboard
	if not parent then parent = self.keyboardFrame end
	

	local button = CreateFrame("FRAME", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	button:SetMovable(true)
	button:EnableMouse(true)
	button:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                                            tile = true, tileSize = 16, edgeSize = 16,
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	button:SetBackdropColor(0,0,0,0.8);

	button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.label:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	button.label:SetTextColor(1,1,1,0.7)
	button.label:SetHeight(50)
	button.label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -8,  -4)
	button.label:SetJustifyH("RIGHT")
	button.label:SetJustifyV("TOP")

	button.macro = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.macro:SetText("")

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetSize(60, 60)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)

	button:SetScript("OnEnter", function() self:ButtonMouseOver(button) end)
	button:SetScript("OnLeave", function() end)
	button:SetScript("OnMouseDown",function() end)
	button:SetScript("OnMouseUp",function(self, mousebutton)
	
	if mousebutton == "LeftButton" then
	infoType, info1, info2 = GetCursorInfo()

	if infoType == "spell" then
	local spellname = GetSpellBookItemName(info1, info2)
	addon.currentKey = self
	--	print(modif.CTRL..modif.SHIFT..modif.ALT..(SelectedFrame.label:GetText() or ""), spellname)
															SetBindingSpell(modif.CTRL..modif.SHIFT..modif.ALT..(addon.currentKey.label:GetText() or ""), spellname)
															ClearCursor()
															SaveBindings(2)
															addon:RefreshKeys()
	end
	
	elseif mousebutton == "RightButton" then
	addon.currentKey = self
														ToggleDropDownMenu(1, nil, KBDropDown, self, 30, 20)

	end
end)
return button
end
