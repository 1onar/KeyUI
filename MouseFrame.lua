local name, addon = ...

-- Save the position and scale of the mouse holder
function addon:SaveMouse()
    local x, y = Mouseholder:GetCenter()
    keyui_settings.mouse_position.x = x
    keyui_settings.mouse_position.y = y
    keyui_settings.mouse_position.scale = Mouseholder:GetScale()
end

function addon:CreateMouseholder()
    local Mouseholder = CreateFrame("Frame", "Mouseholder", UIParent)

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "Mouseholder")
    end

    Mouseholder:SetWidth(260)
    Mouseholder:SetHeight(400)
    Mouseholder:Hide()

    -- Load the saved position if it exists
    if keyui_settings.mouse_position.x and keyui_settings.mouse_position.y then
        Mouseholder:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            keyui_settings.mouse_position.x,
            keyui_settings.mouse_position.y
        )
        Mouseholder:SetScale(keyui_settings.mouse_position.scale)
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

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "MouseFrame")
    end

    MouseFrame:SetWidth(50)
    MouseFrame:SetHeight(50)
    MouseFrame:SetPoint("RIGHT", Mouseholder, "LEFT", 5, -25)
    MouseFrame:SetScale(1)
    MouseFrame:Hide()

    addon.MouseFrame = MouseFrame

    if keyui_settings.show_keyboard == false then
        addon:RefreshKeys()
    end

    return MouseFrame
end

function addon:CreateMouseControls()
    local MouseControls = CreateFrame("Frame", "MouseControls", Mouseholder, "TooltipBorderedFrameTemplate")

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "MouseControls")
    end

    MouseControls:SetBackdropColor(0, 0, 0, 1);
    MouseControls:SetPoint("BOTTOMRIGHT", Mouseholder, "TOPRIGHT", 0, -10)
    MouseControls:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    MouseControls:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    local function OnMaximizeMouse()
        addon.mouse_maximize_flag = true

        MouseControls:SetWidth((Mouseholder:GetWidth() + 100))
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
        MouseControls.Input = CreateFrame("EditBox", "MouseEditInput", MouseControls, "InputBoxInstructionsTemplate")
        MouseControls.Input:SetSize(130, 30)
        MouseControls.Input:SetPoint("TOP", MouseControls, "TOP", -16, -54)
        MouseControls.Input:SetAutoFocus(false)

        MouseControls.Save = CreateFrame("Button", nil, MouseControls, "UIPanelButtonTemplate")
        MouseControls.Save:SetSize(104, 26)
        MouseControls.Save:SetPoint("CENTER", MouseControls, "CENTER", 0, -16)
        MouseControls.Save:SetScript("OnClick", function() addon:MouseSaveLayout() end)
        local SaveText = MouseControls.Save:CreateFontString(nil, "OVERLAY")
        SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12)     -- Set your preferred font and size
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

        MouseControls.Delete:SetScript("OnClick", function(self)
            -- Check if KBChangeBoardDDMouse is not nil
            if not KBChangeBoardDDMouse then
                print("Error: KBChangeBoardDDMouse is nil.")
                return     -- Exit the function early if KBChangeBoardDDMouse is nil
            end

            -- Get the text from the KBChangeBoardDDMouse dropdown menu.
            local selectedLayout = UIDropDownMenu_GetText(KBChangeBoardDDMouse)

            -- Ensure selectedLayout is not nil before proceeding
            if selectedLayout then
                -- Remove the selected layout from the MouseKeyEditLayouts table.
                layout_edited_mouse[selectedLayout] = nil

                -- Clear the text in the Mouse.Input field.
                MouseControls.Input:SetText("")

                -- Print a message indicating which layout was deleted.
                print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")

                wipe(layout_current_mouse)
                UIDropDownMenu_SetText(KBChangeBoardDDMouse, "")
                addon:RefreshKeys()
            else
                print("KeyUI: Error - No layout selected to delete.")
            end
        end)

        local DeleteText = MouseControls.Delete:CreateFontString(nil, "OVERLAY")
        DeleteText:SetFont("Fonts\\FRIZQT__.TTF", 12)     -- Set your preferred font and size
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
        LockText:SetFont("Fonts\\FRIZQT__.TTF", 12)     -- Set your preferred font and size
        LockText:SetPoint("CENTER", 0, 1)
        if addon.mouse_locked == false then
            LockText:SetText("Lock")
        else
            LockText:SetText("Unlock")
        end

        local function ToggleLock()
            if addon.mouse_locked then
                addon.mouse_locked = false
                addon.keys_mouse_edited = true
                LockText:SetText("Lock")
                if MouseControls.glowBoxLock then
                    MouseControls.glowBoxLock:Show()
                end
            else
                addon.mouse_locked = true
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
        MouseControls.glowBoxLock:SetFrameLevel(MouseControls.Lock:GetFrameLevel() + 1)
        --Edit end

        if KBChangeBoardDDMouse then
            KBChangeBoardDDMouse:Show()
        end

        MouseControls.EditBox:Show()
        MouseControls.LeftButton:Show()
        MouseControls.RightButton:Show()

        MouseControls.Input:Show()
        MouseControls.Save:Show()
        MouseControls.Delete:Show()
        MouseControls.Lock:Show()

        if addon.mouse_locked == false then
            if MouseControls.glowBoxLock then
                MouseControls.glowBoxLock:Show()
            end
        end
    end

    local function OnMinimizeMouse()
        addon.mouse_maximize_flag = false

        MouseControls:SetWidth(50)
        MouseControls:SetHeight(26)

        if MouseControls.EditBox then
            if KBChangeBoardDDMouse then
                KBChangeBoardDDMouse:Hide()
            end
            MouseControls.EditBox:Hide()
            MouseControls.LeftButton:Hide()
            MouseControls.RightButton:Hide()
            MouseControls.Size:Hide()

            MouseControls.Input:Hide()
            MouseControls.Save:Hide()
            MouseControls.Delete:Hide()
            MouseControls.Lock:Hide()

            MouseControls.Layout:Hide()
            MouseControls.Name:Hide()

            if MouseControls.glowBoxLock then
                MouseControls.glowBoxLock:Hide()
            end
        end
    end

    MouseControls.Close = CreateFrame("Button", "$parentClose", MouseControls, "UIPanelCloseButton")
    MouseControls.Close:SetSize(26, 26)
    MouseControls.Close:SetPoint("TOPRIGHT", 0, 0)
    MouseControls.Close:SetScript("OnClick", function(s)
        MouseControls:Hide()
        Mouseholder:Hide()
    end)

    MouseControls.MinMax = CreateFrame("Frame", "#parentMinMax", MouseControls, "MaximizeMinimizeButtonFrameTemplate")
    MouseControls.MinMax:SetSize(26, 26)
    MouseControls.MinMax:SetPoint("RIGHT", MouseControls.Close, "LEFT", 2, 0)
    MouseControls.MinMax:SetOnMaximizedCallback(OnMaximizeMouse)
    MouseControls.MinMax:SetOnMinimizedCallback(OnMinimizeMouse)

    MouseControls.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
    --MouseControls.MinMax:SetMaximizedLook() -- Set the MinMax button & control frame size to Minimize

    return MouseControls
end

local function GetCursorScaledPosition()
    local scale, x, y = UIParent:GetScale(), GetCursorPosition()
    return x / scale, y / scale
end

local function DragOrSize(self, Mousebutton)
    local x, y = GetCursorScaledPosition()
    if addon.mouse_locked then
        return -- Do nothing if not MouseLocked is selected
    end
    self:StartMoving()
    self.isMoving = true -- Add a flag to indicate the frame is being moved
    if IsShiftKeyDown() then
        addon.keys_mouse[self] = nil
        self:Hide()
    end
end

local function Release(self, Mousebutton)
    if Mousebutton == "LeftButton" then
        self:StopMovingOrSizing()
        self.isMoving = false -- Reset the flag when the movement is stopped
    end
end

local function KeyDown(self, key)
    if not addon.mouse_locked and not self.isMoving then
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
    if not addon.mouse_locked and not self.isMoving then
        if delta > 0 then
            -- Mouse wheel scrolled up
            self.label:SetText("MouseWheelUp")
        elseif delta < 0 then
            -- Mouse wheel scrolled down
            self.label:SetText("MouseWheelDown")
        end
    end
end

function addon:MouseSaveLayout()
    local msg = MouseControls.Input:GetText()
    if addon.mouse_locked == true then
        if msg ~= "" then
            MouseControls.Input:SetText("")
            MouseControls.Input:ClearFocus()
            print("KeyUI: Saved the new layout '" .. msg .. "'.")
            layout_edited_mouse[msg] = {}
            for _, Mousebutton in ipairs(addon.keys_mouse) do
                if Mousebutton:IsVisible() then
                    layout_edited_mouse[msg][#layout_edited_mouse[msg] + 1] = {
                        Mousebutton.label:GetText(),
                        "Mouse",
                        floor(Mousebutton:GetLeft() - MouseFrame:GetLeft() + 0.5),
                        floor(Mousebutton:GetTop() - MouseFrame:GetTop() + 0.5),
                        floor(Mousebutton:GetWidth() + 0.5),
                        floor(Mousebutton:GetHeight() + 0.5)
                    }
                end
            end
            wipe(layout_current_mouse)
            layout_current_mouse[msg] = layout_edited_mouse[msg]
            addon:RefreshKeys()
            UIDropDownMenu_SetText(self.ddChangerMouse, msg)
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
    end
end

function addon:SwitchBoardMouse()
    if addon.open == true and addon.MouseFrame then
        if layout_current_mouse then
            -- Calculate the center of the Mouse frame once
            local cx, cy = addon.MouseFrame:GetCenter()
            local left, right, top, bottom = cx, cx, cy, cy

            for _, layoutData in pairs(layout_current_mouse) do
                for i = 1, #layoutData do
                    local MouseKey = addon.keys_mouse[i] or self:NewButtonMouse()
                    local CurrentLayoutMouse = layoutData[i]

                    if CurrentLayoutMouse[5] then
                        MouseKey:SetWidth(CurrentLayoutMouse[5])
                        MouseKey:SetHeight(CurrentLayoutMouse[6])
                    else
                        MouseKey:SetWidth(85)
                        MouseKey:SetHeight(85)
                    end

                    if not addon.keys_mouse[i] then
                        addon.keys_mouse[i] = MouseKey
                    end

                    MouseKey:SetPoint("TOPRIGHT", self.MouseFrame, "TOPRIGHT", CurrentLayoutMouse[3],
                        CurrentLayoutMouse[4])
                    MouseKey.label:SetText(CurrentLayoutMouse[1])
                    local tempframe = MouseKey
                    tempframe:Show()
                end
            end

            -- After all buttons are added, set the size of the Mouse frame
            for i = 1, #addon.keys_mouse do
                local l, r, t, b = addon.keys_mouse[i]:GetLeft(), addon.keys_mouse[i]:GetRight(),
                    addon.keys_mouse[i]:GetTop(), addon.keys_mouse[i]:GetBottom()

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

    Mousebutton:SetScript("OnEnter", function()
        addon:ButtonMouseOver(Mousebutton)
        Mousebutton:EnableKeyboard(true)
        Mousebutton:EnableMouseWheel(true)
        Mousebutton:SetScript("OnKeyDown", KeyDown)
        Mousebutton:SetScript("OnMouseWheel", OnMouseWheel)

        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()

        -- Only show the PushedTexture if the setting is enabled
        if keyui_settings.show_pushed_texture then
            -- Check if currentActionBarPage is valid and map it to adjustedSlot
            if currentActionBarPage and Mousebutton.slot then
                -- Calculate the adjustedSlot based on currentActionBarPage
                local adjustedSlot = Mousebutton.slot
                if currentActionBarPage == 3 and Mousebutton.slot >= 25 and Mousebutton.slot <= 36 then
                    adjustedSlot = Mousebutton.slot - 24 -- Map to ActionButton1-12
                elseif currentActionBarPage == 4 and Mousebutton.slot >= 37 and Mousebutton.slot <= 48 then
                    adjustedSlot = Mousebutton.slot - 36 -- Map to ActionButton1-12
                elseif currentActionBarPage == 5 and Mousebutton.slot >= 49 and Mousebutton.slot <= 60 then
                    adjustedSlot = Mousebutton.slot - 48 -- Map to ActionButton1-12
                elseif currentActionBarPage == 6 and Mousebutton.slot >= 61 and Mousebutton.slot <= 72 then
                    adjustedSlot = Mousebutton.slot - 60 -- Map to ActionButton1-12
                end

                -- Look up the correct button in TextureMappings using the adjustedSlot
                local mappedButton = TextureMappings[tostring(adjustedSlot)]
                if mappedButton then
                    local normalTexture = mappedButton:GetNormalTexture()
                    if normalTexture and normalTexture:IsVisible() then
                        local pushedTexture = mappedButton:GetPushedTexture()
                        if pushedTexture then
                            pushedTexture:Show() -- Show the pushed texture
                            --print("Showing PushedTexture for button in slot", Mousebutton.slot)
                        end
                    end
                end
            end
        end
    end)

    Mousebutton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        KeyUITooltip:Hide()
        Mousebutton:EnableKeyboard(false)
        Mousebutton:EnableMouseWheel(false)
        Mousebutton:SetScript("OnKeyDown", nil)

        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()

        if keyui_settings.show_pushed_texture then
            -- Check if currentActionBarPage is valid and map it to adjustedSlot
            if currentActionBarPage and Mousebutton.slot then
                -- Calculate the adjustedSlot based on currentActionBarPage
                local adjustedSlot = Mousebutton.slot
                if currentActionBarPage == 3 and Mousebutton.slot >= 25 and Mousebutton.slot <= 36 then
                    adjustedSlot = Mousebutton.slot - 24 -- Map to ActionButton1-12
                elseif currentActionBarPage == 4 and Mousebutton.slot >= 37 and Mousebutton.slot <= 48 then
                    adjustedSlot = Mousebutton.slot - 36 -- Map to ActionButton1-12
                elseif currentActionBarPage == 5 and Mousebutton.slot >= 49 and Mousebutton.slot <= 60 then
                    adjustedSlot = Mousebutton.slot - 48 -- Map to ActionButton1-12
                elseif currentActionBarPage == 6 and Mousebutton.slot >= 61 and Mousebutton.slot <= 72 then
                    adjustedSlot = Mousebutton.slot - 60 -- Map to ActionButton1-12
                end

                -- Look up the correct button in TextureMappings using the adjustedSlot
                local mappedButton = TextureMappings[tostring(adjustedSlot)]
                if mappedButton then
                    local pushedTexture = mappedButton:GetPushedTexture()
                    if pushedTexture then
                        pushedTexture:Hide() -- Hide the pushed texture
                        --print("Hiding PushedTexture for button in slot", Mousebutton.slot)
                    end
                end
            end
        end
    end)

    Mousebutton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if addon.mouse_locked == false then
                DragOrSize(self, button)
            else
                addon.currentKey = self
                local key = addon.currentKey.macro:GetText()

                -- Define class and bonus bar offset and action bar page
                local classFilename = UnitClassBase("player")
                local bonusBarOffset = GetBonusBarOffset()
                local currentActionBarPage = GetActionBarPage()

                local actionSlot = SlotMappings[key]

                if actionSlot then
                    -- Adjust action slot based on current action bar page
                    local adjustedSlot = tonumber(actionSlot)

                    -- Handle bonus bar offsets for ROGUE and DRUID
                    if (classFilename == "ROGUE" or classFilename == "DRUID") and bonusBarOffset ~= 0 and currentActionBarPage == 1 then
                        if bonusBarOffset == 1 then
                            adjustedSlot = adjustedSlot + 72  -- Maps to 73-84
                        elseif bonusBarOffset == 2 then
                            adjustedSlot = adjustedSlot       -- No change for offset 2
                        elseif bonusBarOffset == 3 then
                            adjustedSlot = adjustedSlot + 96  -- Maps to 97-108
                        elseif bonusBarOffset == 4 then
                            adjustedSlot = adjustedSlot + 108 -- Maps to 109-120
                        elseif bonusBarOffset == 5 then
                            adjustedSlot = adjustedSlot       -- No change for offset 5
                        end
                    end

                    -- Adjust based on current action bar page
                    if currentActionBarPage == 2 then
                        adjustedSlot = adjustedSlot + 12 -- For ActionBarPage 2, adjust slots by +12 (13-24)
                    elseif currentActionBarPage == 3 then
                        adjustedSlot = adjustedSlot + 24 -- For ActionBarPage 3, adjust slots by +24 (25-36)
                    elseif currentActionBarPage == 4 then
                        adjustedSlot = adjustedSlot + 36 -- For ActionBarPage 4, adjust slots by +36 (37-48)
                    elseif currentActionBarPage == 5 then
                        adjustedSlot = adjustedSlot + 48 -- For ActionBarPage 5, adjust slots by +48 (49-60)
                    elseif currentActionBarPage == 6 then
                        adjustedSlot = adjustedSlot + 60 -- For ActionBarPage 6, adjust slots by +60 (61-72)
                    end

                    -- Check if Dragonriding
                    if bonusBarOffset == 5 and currentActionBarPage == 1 then
                        adjustedSlot = adjustedSlot + 120 -- Maps to 121-132
                    end

                    -- Ensure adjustedSlot is valid before picking up
                    if adjustedSlot >= 1 and adjustedSlot <= 132 then -- Adjust the upper limit as necessary
                        PickupAction(adjustedSlot)
                        addon:RefreshKeys()
                    else
                        -- Optionally handle cases where the adjusted slot is out of range
                        PickupAction(actionSlot)
                        addon:RefreshKeys()
                    end
                end
            end
        else
            KeyDown(self, button)
        end
    end)

    Mousebutton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if addon.mouse_locked == false then
                Release(self, button)
            else
                infoType, info1, info2 = GetCursorInfo()
                if infoType == "spell" then
                    local spellname = C_SpellBook.GetSpellBookItemName(info1, Enum.SpellBookSpellBank.Player)
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

    addon.keys_mouse[Mousebutton] = Mousebutton

    return Mousebutton
end

function addon:CreateChangerDDMouse()
    local KBChangeBoardDDMouse = CreateFrame("Frame", "KBChangeBoardDDMouse", MouseControls, "UIDropDownMenuTemplate")

    KBChangeBoardDDMouse:SetPoint("TOP", MouseControls, "TOP", -20, -10)
    UIDropDownMenu_SetWidth(KBChangeBoardDDMouse, 120)
    UIDropDownMenu_SetButtonWidth(KBChangeBoardDDMouse, 120)
    KBChangeBoardDDMouse:Hide()

    local boardOrder = { "Layout_4x3", 'Layout_2+4x3', "Layout_3x3", "Layout_3x2", "Layout_1+2x2", "Layout_2x2",
        "Layout_2x1", "Layout_Circle" }

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
                key_bind_settings_mouse.currentboard = name
                wipe(layout_current_mouse)
                layout_current_mouse = { [name] = KeyBindAllBoardsMouse[name] }
                addon:RefreshKeys()
                UIDropDownMenu_SetText(self, name)
                MouseControls.Input:SetText("")
                MouseControls.Input:ClearFocus()
            end
            UIDropDownMenu_AddButton(info, level)
        end

        if type(layout_edited_mouse) == "table" then
            for name, layout in pairs(layout_edited_mouse) do
                info.text = name
                info.value = name
                info.colorCode = "|cffff8000"
                info.func = function()
                    wipe(layout_current_mouse)
                    layout_current_mouse[name] = layout
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
