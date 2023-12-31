local name, addon = ...

MousePosition = {}

locked = true
edited = false

function addon:SaveMouse()
    MousePosition.x, MousePosition.y = Mouseholder:GetCenter()
    MousePosition.scale = Mouseholder:GetScale()
end

function addon:CreateMouseholder()
    local Mouseholder = CreateFrame("Frame", "Mouseholder", UIParent)
    tinsert(UISpecialFrames, "Mouseholder")
    
    Mouseholder:SetWidth(260)
    Mouseholder:SetHeight(400)
    Mouseholder:Hide()

    -- Load the saved position if it exists
    if MousePosition.x and MousePosition.y then
        Mouseholder:SetPoint("CENTER", UIParent, "BOTTOMLEFT", MousePosition.x, MousePosition.y)
        Mouseholder:SetScale(MousePosition.scale)
    else
        Mouseholder:SetPoint("CENTER", UIParent, "CENTER", 580, 30)
        Mouseholder:SetScale(1)
    end

    Mouseholder:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    Mouseholder:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    Mouseholder:SetMovable(true)

    Mouseholder.Texture = Mouseholder:CreateTexture()
    Mouseholder.Texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Mouse.tga")
    Mouseholder.Texture:SetPoint("Center", Mouseholder, "Center", 0, 0)
    Mouseholder.Texture:SetSize(370, 370)

    return Mouseholder
end

function addon:CreateMouseUI()
    local MouseFrame = CreateFrame("Frame", "MouseFrame", Mouseholder)
    tinsert(UISpecialFrames, "MouseFrame")

    MouseFrame:SetWidth(50)
    MouseFrame:SetHeight(50)
    MouseFrame:SetPoint("RIGHT", Mouseholder, "LEFT", 5, -25)
    MouseFrame:SetScale(1)
    MouseFrame:Hide()

    addon.MouseFrame = MouseFrame

    return MouseFrame
end

function addon:CreateMouseControls()
    local MouseControls = CreateFrame("Frame", "MouseControls", Mouseholder, "TooltipBorderedFrameTemplate")
    tinsert(UISpecialFrames, "MouseControls")

    MouseControls:SetBackdropColor(0,0,0,1);
    MouseControls:SetPoint("BOTTOMRIGHT", Mouseholder, "TOPRIGHT", 0, -10)
    MouseControls:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    MouseControls:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    local function OnMaximizeMouse()
        maximizeFlag = true

        MouseControls:SetWidth((Mouseholder:GetWidth()+100))
        MouseControls:SetHeight(190)

        --Size start
            MouseControls.EditBox = CreateFrame("EditBox", "KUI_EditBox2", MouseControls, "InputBoxTemplate")
            MouseControls.EditBox:SetSize(60, 12)
            MouseControls.EditBox:SetPoint("BOTTOM", MouseControls, "BOTTOM", 0, 26)
            MouseControls.EditBox:SetMaxLetters(4)
            MouseControls.EditBox:SetAutoFocus(false)
            MouseControls.EditBox:SetText(string.format("%.2f", Mouseholder:GetScale()))
            MouseControls.EditBox:SetJustifyH("CENTER")
            
            MouseControls.EditBox:SetScript("OnEnterPressed", function(self)
                local value = tonumber(self:GetText())
                if value then
                    if value < 0.5 then
                        value = 0.5
                    elseif value > 1.5 then
                        value = 1.5
                    end
                    Mouseholder:SetScale(value)
                    self:SetText(string.format("%.2f", value))
                end
                self:ClearFocus()
            end)

            MouseControls.LeftButton = CreateFrame("Button", "MouseControlLeftButton", MouseControls)
            MouseControls.LeftButton:SetSize(34, 34)
            MouseControls.LeftButton:SetPoint("CENTER", MouseControls.EditBox, "CENTER", -58, 0)
            MouseControls.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
            MouseControls.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
            MouseControls.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            
            MouseControls.RightButton = CreateFrame("Button", "MouseControlRightButton", MouseControls)
            MouseControls.RightButton:SetSize(34, 34)
            MouseControls.RightButton:SetPoint("CENTER", MouseControls.EditBox, "CENTER", 54, 0)
            MouseControls.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            MouseControls.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
            MouseControls.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            
            MouseControls.LeftButton:SetScript("OnClick", function()
                local currentValue = Mouseholder:GetScale()
                local step = 0.05
                local newValue = currentValue - step
                if newValue < 0.5 then
                    newValue = 0.5
                end
                Mouseholder:SetScale(newValue)
                MouseControls.EditBox:SetText(string.format("%.2f", newValue))
            end)
            
            MouseControls.RightButton:SetScript("OnClick", function()
                local currentValue = Mouseholder:GetScale()
                local step = 0.05
                local newValue = currentValue + step
                if newValue > 1.5 then
                    newValue = 1.5
                end
                Mouseholder:SetScale(newValue)
                MouseControls.EditBox:SetText(string.format("%.2f", newValue))
            end)        
        --Size end

        --Text start
            MouseControls.Layout = MouseControls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            MouseControls.Layout:SetText("Layout")
            MouseControls.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
            MouseControls.Layout:SetPoint("RIGHT", KBChangeBoardDDMouse, "LEFT", 0, 2)
            MouseControls.Layout:SetTextColor(1, 1, 1)

            MouseControls.Name = MouseControls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            MouseControls.Name:SetText("Name")
            MouseControls.Name:SetFont("Fonts\\FRIZQT__.TTF", 14)
            MouseControls.Name:SetPoint("TOPLEFT", MouseControls.Layout, "TOPLEFT", 0, -44)
            MouseControls.Name:SetTextColor(1, 1, 1)

            MouseControls.Size = MouseControls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            MouseControls.Size:SetText("Size")
            MouseControls.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
            MouseControls.Size:SetPoint("TOPLEFT", MouseControls.Name, "TOPLEFT", 0, -90)
            MouseControls.Size:SetTextColor(1, 1, 1)
        --Text end

        --Edit start
            MouseControls.Input  = CreateFrame("EditBox", "MouseEditInput", MouseControls, "InputBoxInstructionsTemplate")
            MouseControls.Input:SetSize(130, 30)
            MouseControls.Input:SetPoint("TOP", MouseControls, "TOP", -16, -54)
            MouseControls.Input:SetAutoFocus(false)
            
            MouseControls.Save = CreateFrame("Button", nil, MouseControls, "UIPanelButtonTemplate")
            MouseControls.Save:SetSize(104, 26)
            MouseControls.Save:SetPoint("CENTER", MouseControls, "CENTER", 0, -16)
            MouseControls.Save:SetScript("OnClick", function() addon:SaveLayout() end)
            local SaveText = MouseControls.Save:CreateFontString(nil, "OVERLAY")
            SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            SaveText:SetPoint("CENTER", 0, 1)
            SaveText:SetText("Save")

            MouseControls.Save:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Save the current layout.")
                GameTooltip:Show()
            end)
            
            MouseControls.Save:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            MouseControls.Delete = CreateFrame("Button", nil, MouseControls, "UIPanelButtonTemplate")
            MouseControls.Delete:SetSize(104, 26)
            MouseControls.Delete:SetPoint("LEFT", MouseControls.Save, "RIGHT", 5, 0)

            MouseControls.Delete:SetScript("OnClick", function(self)                                        --select a default layout
                -- Get the text from the KBChangeBoardDDMouse dropdown menu.
                local selectedLayout = UIDropDownMenu_GetText(KBChangeBoardDDMouse)
                -- Remove the selected layout from the MouseKeyEditLayouts table.
                MouseKeyEditLayouts[selectedLayout] = nil
                -- Clear the text in the Mouse.Input field.
                MouseControls.Input:SetText("")
                -- Print a message indicating which layout was deleted.
                print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")

                --CurrentLayout = {KeyBindAllBoardsMouse.Layout_4x3}
                wipe(CurrentLayout)
                UIDropDownMenu_SetText(KBChangeBoardDDMouse, "")
                addon:RefreshKeys()
            end)
            local DeleteText = MouseControls.Delete:CreateFontString(nil, "OVERLAY")
            DeleteText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            DeleteText:SetPoint("CENTER", 0, 1)
            DeleteText:SetText("Delete")

            MouseControls.Delete:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Delete the current layout if it's a self-made layout.")
                GameTooltip:Show()
            end)
            
            MouseControls.Delete:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            MouseControls.Lock = CreateFrame("Button", nil, MouseControls, "UIPanelButtonTemplate")
            MouseControls.Lock:SetSize(104, 26)
            MouseControls.Lock:SetPoint("RIGHT", MouseControls.Save, "LEFT", -5, 0)

            local LockText = MouseControls.Lock:CreateFontString(nil, "OVERLAY")
            LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)  -- Set your preferred font and size
            LockText:SetPoint("CENTER", 0, 1)
            if locked == false then
                LockText:SetText("Lock")
            else
                LockText:SetText("Unlock")
            end

            local function ToggleLock()
                if locked then
                    locked = false
                    edited = true
                    LockText:SetText("Lock")
                    if MouseControls.glowBoxLock then
                        MouseControls.glowBoxLock:Show()
                    end
                else
                    locked = true
                    LockText:SetText("Unlock")
                    if MouseControls.glowBoxLock then
                        MouseControls.glowBoxLock:Hide()
                    end  
                end
            end

            MouseControls.Lock:SetScript("OnClick", function(self) ToggleLock() end)

            MouseControls.Lock:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Toggle Editor Mode")
                GameTooltip:AddLine("- Drag the keys with left mouse")
                GameTooltip:AddLine("- Delete keys with Shift + left-click mouse")
                GameTooltip:AddLine("- Assign new keybindings by pushing keys")
                GameTooltip:Show()
            end)
            
            MouseControls.Lock:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            MouseControls.glowBoxLock = CreateFrame("Frame", nil, MouseControls, "GlowBorderTemplate")
            MouseControls.glowBoxLock:SetSize(106, 28)
            MouseControls.glowBoxLock:SetPoint("CENTER", MouseControls.Lock, "CENTER", 0, 0)
            MouseControls.glowBoxLock:Hide()
            MouseControls.glowBoxLock:SetFrameLevel(MouseControls.Lock:GetFrameLevel()+1)
        --Edit end

        --Mouse.New = CreateFrame("Button", nil, MouseControls, "UIPanelButtonTemplate")
        --Mouse.New:SetSize(100,30)
        --Mouse.New:SetPoint("TOPRIGHT", Mouse.Lock, "TOPLEFT", -20, 0)
        --Mouse.New:SetText("New Key")
        --Mouse.New:SetScript("OnClick", addon.NewButtonMouse)
	
        MouseControls.EditBox:Show()
        MouseControls.LeftButton:Show()
        MouseControls.RightButton:Show()
        MouseControls.Input:Show()
        MouseControls.Save:Show()
        MouseControls.Delete:Show()
        MouseControls.Lock:Show()

        if locked == false then
            if MouseControls.glowBoxLock then
                MouseControls.glowBoxLock:Show()
            end
        end
        
        if KBChangeBoardDDMouse then
            KBChangeBoardDDMouse:Show()
        end
        
    end

    local function OnMinimizeMouse()
        maximizeFlag = false
        
        MouseControls:SetWidth(50)
        MouseControls:SetHeight(26)

        if MouseControls.EditBox then
            MouseControls.EditBox:Hide()
            MouseControls.LeftButton:Hide()
            MouseControls.RightButton:Hide()
            MouseControls.Input:Hide()
            MouseControls.Save:Hide()
            MouseControls.Delete:Hide()
            MouseControls.Lock:Hide()
            MouseControls.Size:Hide()
            MouseControls.Layout:Hide()
            MouseControls.Name:Hide()

            if MouseControls.glowBoxLock then
                MouseControls.glowBoxLock:Hide()
            end

            if KBChangeBoardDDMouse then
                KBChangeBoardDDMouse:Hide()
            end
        end
    end    

    MouseControls.Close = CreateFrame("Button", "$parentClose", MouseControls, "UIPanelCloseButton")
    MouseControls.Close:SetSize(42, 42)
    MouseControls.Close:SetPoint("TOPRIGHT", 8, 8)
    MouseControls.Close:SetScript("OnClick", function(s) MouseControls:Hide() Mouseholder:Hide() end)

    MouseControls.MinMax = CreateFrame("Frame", "#parentMinMax", MouseControls, "MaximizeMinimizeButtonFrameTemplate")
    MouseControls.MinMax:SetSize(42, 42)
    MouseControls.MinMax:SetPoint("RIGHT", MouseControls.Close, "LEFT", 18, 0)
    MouseControls.MinMax:SetOnMaximizedCallback(OnMaximizeMouse)
    MouseControls.MinMax:SetOnMinimizedCallback(OnMinimizeMouse)

    MouseControls.MinMax:Maximize() -- Set the MinMax button & control frame size to Minimize
    MouseControls.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize

    return MouseControls
end

local function GetCursorScaledPosition()
	local scale, x, y = UIParent:GetScale(), GetCursorPosition()
	return x / scale, y / scale
end

local function DragOrSize(self, Mousebutton)
    local x, y = GetCursorScaledPosition()
    if locked then
        return -- Do nothing if not locked is selected
    end
    self:StartMoving()
    self.isMoving = true  -- Add a flag to indicate the frame is being moved
    if IsShiftKeyDown() then
        KeysMouse[self] = nil
        self:Hide()
    end
end

local function Release(self, Mousebutton)
    if Mousebutton == "LeftButton" then
        self:StopMovingOrSizing()
        self.isMoving = false  -- Reset the flag when the movement is stopped
    end
end

local function KeyDown(self, key)
    if not locked and not self.isMoving then
        if key == "RightButton" then
            return
        elseif key == "MiddleButton" then
            self.label:SetText("Button3")
        else
            -- For all other keys, set the label to the key itself
            self.label:SetText(key)
        end
    end
end

local function OnMouseWheel(self, delta)
    if not locked and not self.isMoving then
        if delta > 0 then
            -- Mouse wheel scrolled up
            self.label:SetText("MouseWheelUp")
        elseif delta < 0 then
            -- Mouse wheel scrolled down
            self.label:SetText("MouseWheelDown")
        end
    end
end

function addon:SaveLayout()
    local msg = MouseControls.Input:GetText()
    if locked == true then
        if msg ~= "" then
            MouseControls.Input:SetText("")
            MouseControls.Input:ClearFocus()
            print("KeyUI: Saved the new layout '" .. msg .. "'.")
            MouseKeyEditLayouts[msg] = {}
            for _, Mousebutton in ipairs(KeysMouse) do
                if Mousebutton:IsVisible() then
                    MouseKeyEditLayouts[msg][#MouseKeyEditLayouts[msg] + 1] = {
                        Mousebutton.label:GetText(),
                        "Mouse",
                        floor(Mousebutton:GetLeft() - MouseFrame:GetLeft() + 0.5),
                        floor(Mousebutton:GetTop() - MouseFrame:GetTop() + 0.5),
                        floor(Mousebutton:GetWidth() + 0.5),
                        floor(Mousebutton:GetHeight() + 0.5)
                    }
                end
            end
            wipe(CurrentLayout)
            CurrentLayout[msg] = MouseKeyEditLayouts[msg]
            addon:RefreshKeys()
            UIDropDownMenu_SetText(self.ddChangerMouse, msg)
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
    end
end

function addon:NewButtonMouse()
    local Mousebutton = CreateFrame("FRAME", nil, Mouseholder, "TooltipBorderedFrameTemplate")
    Mousebutton:SetMovable(true)
    Mousebutton:EnableMouse(true)
	Mousebutton:EnableKeyboard(true)
    Mousebutton:SetBackdropColor(0, 0, 0, 1)

    Mousebutton.label = Mousebutton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Mousebutton.label:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    Mousebutton.label:SetTextColor(1, 1, 1, 0.9)
    Mousebutton.label:SetHeight(50)
    Mousebutton.label:SetWidth(54)
    Mousebutton.label:SetPoint("CENTER", Mousebutton, "CENTER", 0, 6)
    Mousebutton.label:SetJustifyH("CENTER")
    Mousebutton.label:SetJustifyV("BOTTOM")
    
    --button.macro = Blizzard ID Commands
    Mousebutton.macro = Mousebutton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Mousebutton.macro:SetText("")
    Mousebutton.macro:Hide()

    --button.interfaceaction = Blizzard ID changed to readable Text
    Mousebutton.interfaceaction = Mousebutton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Mousebutton.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE")
    Mousebutton.interfaceaction:SetTextColor(1, 1, 1)
    Mousebutton.interfaceaction:SetHeight(20)
    Mousebutton.interfaceaction:SetWidth(44)
    Mousebutton.interfaceaction:SetPoint("TOP", Mousebutton, "TOP", 0, -6)
    Mousebutton.interfaceaction:SetText("")

    Mousebutton.icon = Mousebutton:CreateTexture(nil, "ARTWORK")
    Mousebutton.icon:SetSize(40, 40)
    Mousebutton.icon:SetPoint("TOPLEFT", Mousebutton, "TOPLEFT", 5, -5)

    Mousebutton:SetScript("OnEnter", function(self)
        addon:ButtonMouseOver(Mousebutton)
        self:EnableKeyboard(true)
        self:EnableMouseWheel(true)
        self:SetScript("OnKeyDown", KeyDown)
        self:SetScript("OnMouseWheel", OnMouseWheel)
    end)
    Mousebutton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        KeyUITooltip:Hide()
        self:EnableKeyboard(false)
        self:SetScript("OnKeyDown", nil)
    end)

    Mousebutton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if locked == false then
                DragOrSize(self, button)
            else
                addon.currentKey = self
                local key = addon.currentKey.macro:GetText()
                local actionSlot = SlotMappings[key]
                if actionSlot then
                    PickupAction(actionSlot)
                    addon:RefreshKeys()
                end
            end
        else
            KeyDown(self, button)
        end
    end)

    Mousebutton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if locked == false then  
                Release(self, button)
            else
                infoType, info1, info2 = GetCursorInfo()
                if infoType == "spell" then
                    local spellname = GetSpellBookItemName(info1, info2)
                    addon.currentKey = self
                    local key = addon.currentKey.macro:GetText()
                    local actionSlot = SlotMappings[key]
                    if actionSlot then
                        PlaceAction(actionSlot)
                        ClearCursor()
                        addon:RefreshKeys()
                    end
                end
            end
        elseif button == "RightButton" then
            addon.currentKey = self
            ToggleDropDownMenu(1, nil, KBDropDown, self, 30, 20)
        end
    end)

    local glowBox = CreateFrame("Frame", nil, Mousebutton, "GlowBoxTemplate")
    glowBox:SetSize(48, 48)
    glowBox:SetPoint("CENTER", Mousebutton, "CENTER", 0, 0)
    glowBox:Show()
    glowBox:SetFrameLevel(Mousebutton:GetFrameLevel())

    Mousebutton.glowBox = glowBox

	KeysMouse[Mousebutton] = Mousebutton
	
	return Mousebutton	
end