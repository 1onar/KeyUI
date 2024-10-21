local name, addon = ...

-- Save the position and scale of the mouse holder
function addon:SaveMousePosition()
    local x, y = addon.mouse_image:GetCenter()
    keyui_settings.mouse_position.x = x
    keyui_settings.mouse_position.y = y
    keyui_settings.mouse_position.scale = addon.mouse_image:GetScale()
end

function addon:CreateMouseImage()
    local mouse_image = CreateFrame("Frame", "keyui_mouse_image", UIParent)
    addon.mouse_image = mouse_image

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_mouse_image")
    end

    mouse_image:SetWidth(260)
    mouse_image:SetHeight(400)
    mouse_image:Hide()

    -- Load the saved position if it exists
    if keyui_settings.mouse_position.x and keyui_settings.mouse_position.y then
        mouse_image:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            keyui_settings.mouse_position.x,
            keyui_settings.mouse_position.y
        )
        mouse_image:SetScale(keyui_settings.mouse_position.scale)
    else
        mouse_image:SetPoint("CENTER", UIParent, "CENTER", 580, 30)
        mouse_image:SetScale(1)
    end

    mouse_image:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    mouse_image:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    mouse_image:SetMovable(true)

    mouse_image.Texture = mouse_image:CreateTexture()
    mouse_image.Texture:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Mouse.tga")
    mouse_image.Texture:SetPoint("Center", mouse_image, "Center", 0, 0)
    mouse_image.Texture:SetSize(370, 370)

    return mouse_image
end

function addon:CreateMouseFrame()
    local mouse_frame = CreateFrame("Frame", "keyui_mouse_frame", addon.mouse_image)
    addon.mouse_frame = mouse_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_mouse_frame")
    end

    mouse_frame:SetWidth(50)
    mouse_frame:SetHeight(50)
    mouse_frame:SetPoint("RIGHT", addon.mouse_image, "LEFT", 5, -25)
    mouse_frame:SetScale(1)
    mouse_frame:Hide()

    if keyui_settings.show_keyboard == false then   -- i still dont know why i have to trigger a extra refreshkeys when keyboard is hidden
        addon:RefreshKeys()
    end

    return mouse_frame
end

function addon:CreateMouseControl()
    local mouse_control_frame = CreateFrame("Frame", "keyui_mouse_control_frame", addon.mouse_image,
    "TooltipBorderedFrameTemplate")
    addon.mouse_control_frame = mouse_control_frame

    -- Manage ESC key behavior based on the setting
    if keyui_settings.prevent_esc_close ~= false then
        tinsert(UISpecialFrames, "keyui_mouse_control_frame")
    end

    mouse_control_frame:SetBackdropColor(0, 0, 0, 1);
    mouse_control_frame:SetPoint("BOTTOMRIGHT", addon.mouse_image, "TOPRIGHT", 0, -10)
    mouse_control_frame:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    mouse_control_frame:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    local function OnMaximizeMouse()
        addon.mouse_maximize_flag = true

        mouse_control_frame:SetWidth((addon.mouse_image:GetWidth() + 100))
        mouse_control_frame:SetHeight(190)

        --Size start
        mouse_control_frame.EditBox = CreateFrame("EditBox", nil, mouse_control_frame, "InputBoxTemplate")
        mouse_control_frame.EditBox:SetSize(60, 12)
        mouse_control_frame.EditBox:SetPoint("BOTTOM", mouse_control_frame, "BOTTOM", 0, 26)
        mouse_control_frame.EditBox:SetMaxLetters(4)
        mouse_control_frame.EditBox:SetAutoFocus(false)
        mouse_control_frame.EditBox:SetText(string.format("%.2f", addon.mouse_image:GetScale()))
        mouse_control_frame.EditBox:SetJustifyH("CENTER")

        mouse_control_frame.EditBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if value then
                if value < 0.5 then
                    value = 0.5
                elseif value > 1.5 then
                    value = 1.5
                end
                addon.mouse_image:SetScale(value)
                self:SetText(string.format("%.2f", value))
            end
            self:ClearFocus()
        end)

        mouse_control_frame.LeftButton = CreateFrame("Button", nil, mouse_control_frame)
        mouse_control_frame.LeftButton:SetSize(34, 34)
        mouse_control_frame.LeftButton:SetPoint("CENTER", mouse_control_frame.EditBox, "CENTER", -58, 0)
        mouse_control_frame.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        mouse_control_frame.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        mouse_control_frame.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        mouse_control_frame.RightButton = CreateFrame("Button", nil, mouse_control_frame)
        mouse_control_frame.RightButton:SetSize(34, 34)
        mouse_control_frame.RightButton:SetPoint("CENTER", mouse_control_frame.EditBox, "CENTER", 54, 0)
        mouse_control_frame.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        mouse_control_frame.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        mouse_control_frame.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        mouse_control_frame.LeftButton:SetScript("OnClick", function()
            local currentValue = addon.mouse_image:GetScale()
            local step = 0.05
            local newValue = currentValue - step
            if newValue < 0.5 then
                newValue = 0.5
            end
            addon.mouse_image:SetScale(newValue)
            mouse_control_frame.EditBox:SetText(string.format("%.2f", newValue))
        end)

        mouse_control_frame.RightButton:SetScript("OnClick", function()
            local currentValue = addon.mouse_image:GetScale()
            local step = 0.05
            local newValue = currentValue + step
            if newValue > 1.5 then
                newValue = 1.5
            end
            addon.mouse_image:SetScale(newValue)
            mouse_control_frame.EditBox:SetText(string.format("%.2f", newValue))
        end)
        --Size end

        --Text start
        mouse_control_frame.Layout = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mouse_control_frame.Layout:SetText("Layout")
        mouse_control_frame.Layout:SetFont("Fonts\\FRIZQT__.TTF", 14)
        mouse_control_frame.Layout:SetPoint("RIGHT", addon.mouse_selector, "LEFT", 0, 2)
        mouse_control_frame.Layout:SetTextColor(1, 1, 1)

        mouse_control_frame.Name = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mouse_control_frame.Name:SetText("Name")
        mouse_control_frame.Name:SetFont("Fonts\\FRIZQT__.TTF", 14)
        mouse_control_frame.Name:SetPoint("TOPLEFT", mouse_control_frame.Layout, "TOPLEFT", 0, -44)
        mouse_control_frame.Name:SetTextColor(1, 1, 1)

        mouse_control_frame.Size = mouse_control_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mouse_control_frame.Size:SetText("Size")
        mouse_control_frame.Size:SetFont("Fonts\\FRIZQT__.TTF", 14)
        mouse_control_frame.Size:SetPoint("TOPLEFT", mouse_control_frame.Name, "TOPLEFT", 0, -90)
        mouse_control_frame.Size:SetTextColor(1, 1, 1)
        --Text end

        --Edit start
        mouse_control_frame.Input = CreateFrame("EditBox", nil, mouse_control_frame, "InputBoxInstructionsTemplate")
        mouse_control_frame.Input:SetSize(130, 30)
        mouse_control_frame.Input:SetPoint("TOP", mouse_control_frame, "TOP", -16, -54)
        mouse_control_frame.Input:SetAutoFocus(false)

        mouse_control_frame.Save = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
        mouse_control_frame.Save:SetSize(104, 26)
        mouse_control_frame.Save:SetPoint("CENTER", mouse_control_frame, "CENTER", 0, -16)
        mouse_control_frame.Save:SetScript("OnClick", function() addon:SaveMouseLayout() end)
        local SaveText = mouse_control_frame.Save:CreateFontString(nil, "OVERLAY")
        SaveText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
        SaveText:SetPoint("CENTER", 0, 1)
        SaveText:SetText("Save")

        mouse_control_frame.Save:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Save the current layout.")
            GameTooltip:Show()
        end)

        mouse_control_frame.Save:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        mouse_control_frame.Delete = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
        mouse_control_frame.Delete:SetSize(104, 26)
        mouse_control_frame.Delete:SetPoint("LEFT", mouse_control_frame.Save, "RIGHT", 5, 0)

        mouse_control_frame.Delete:SetScript("OnClick", function(self)
            -- Check if MouseLayoutSelecter is not nil
            if not addon.mouse_selector then
                print("Error: MouseLayoutSelecter is nil.")
                return -- Exit the function early if MouseLayoutSelecter is nil
            end

            -- Get the text from the MouseLayoutSelecter dropdown menu.
            local selectedLayout = UIDropDownMenu_GetText(addon.mouse_selector)

            -- Ensure selectedLayout is not nil before proceeding
            if selectedLayout then
                -- Remove the selected layout from the MouseKeyEditLayouts table.
                keyui_settings.layout_edited_mouse[selectedLayout] = nil

                -- Clear the text in the Mouse.Input field.
                mouse_control_frame.Input:SetText("")

                -- Print a message indicating which layout was deleted.
                print("KeyUI: Deleted the layout '" .. selectedLayout .. "'.")

                wipe(keyui_settings.layout_current_mouse)
                UIDropDownMenu_SetText(addon.mouse_selector, "")
                addon:RefreshKeys()
            else
                print("KeyUI: Error - No layout selected to delete.")
            end
        end)

        local DeleteText = mouse_control_frame.Delete:CreateFontString(nil, "OVERLAY")
        DeleteText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
        DeleteText:SetPoint("CENTER", 0, 1)
        DeleteText:SetText("Delete")

        mouse_control_frame.Delete:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Delete the current layout if it's a self-made layout.")
            GameTooltip:Show()
        end)

        mouse_control_frame.Delete:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        mouse_control_frame.Lock = CreateFrame("Button", nil, mouse_control_frame, "UIPanelButtonTemplate")
        mouse_control_frame.Lock:SetSize(104, 26)
        mouse_control_frame.Lock:SetPoint("RIGHT", mouse_control_frame.Save, "LEFT", -5, 0)

        local LockText = mouse_control_frame.Lock:CreateFontString(nil, "OVERLAY")
        LockText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set your preferred font and size
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
                if mouse_control_frame.glowBoxLock then
                    mouse_control_frame.glowBoxLock:Show()
                end
            else
                addon.mouse_locked = true
                LockText:SetText("Unlock")
                if mouse_control_frame.glowBoxLock then
                    mouse_control_frame.glowBoxLock:Hide()
                end
            end
        end

        mouse_control_frame.Lock:SetScript("OnClick", function(self) ToggleLock() end)

        mouse_control_frame.Lock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Toggle Editor Mode")
            GameTooltip:AddLine("- Drag the keys with left mouse")
            GameTooltip:AddLine("- Delete keys with Shift + left-click mouse")
            GameTooltip:AddLine("- Assign new keybindings by pushing keys")
            GameTooltip:Show()
        end)

        mouse_control_frame.Lock:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        mouse_control_frame.glowBoxLock = CreateFrame("Frame", nil, mouse_control_frame, "GlowBorderTemplate")
        mouse_control_frame.glowBoxLock:SetSize(106, 28)
        mouse_control_frame.glowBoxLock:SetPoint("CENTER", mouse_control_frame.Lock, "CENTER", 0, 0)
        mouse_control_frame.glowBoxLock:Hide()
        mouse_control_frame.glowBoxLock:SetFrameLevel(mouse_control_frame.Lock:GetFrameLevel() + 1)
        --Edit end

        if addon.mouse_selector then
            addon.mouse_selector:Show()
            addon.mouse_selector:SetPoint("TOP", addon.mouse_control_frame, "TOP", -20, -10)
        end

        mouse_control_frame.EditBox:Show()
        mouse_control_frame.LeftButton:Show()
        mouse_control_frame.RightButton:Show()

        mouse_control_frame.Input:Show()
        mouse_control_frame.Save:Show()
        mouse_control_frame.Delete:Show()
        mouse_control_frame.Lock:Show()

        if addon.mouse_locked == false then
            if mouse_control_frame.glowBoxLock then
                mouse_control_frame.glowBoxLock:Show()
            end
        end
    end

    local function OnMinimizeMouse()
        addon.mouse_maximize_flag = false

        mouse_control_frame:SetWidth(50)
        mouse_control_frame:SetHeight(26)

        if mouse_control_frame.EditBox then
            if addon.mouse_selector then
                addon.mouse_selector:Hide()
            end
            mouse_control_frame.EditBox:Hide()
            mouse_control_frame.LeftButton:Hide()
            mouse_control_frame.RightButton:Hide()
            mouse_control_frame.Size:Hide()

            mouse_control_frame.Input:Hide()
            mouse_control_frame.Save:Hide()
            mouse_control_frame.Delete:Hide()
            mouse_control_frame.Lock:Hide()

            mouse_control_frame.Layout:Hide()
            mouse_control_frame.Name:Hide()

            if mouse_control_frame.glowBoxLock then
                mouse_control_frame.glowBoxLock:Hide()
            end
        end
    end

    mouse_control_frame.Close = CreateFrame("Button", nil, mouse_control_frame, "UIPanelCloseButton")
    mouse_control_frame.Close:SetSize(26, 26)
    mouse_control_frame.Close:SetPoint("TOPRIGHT", 0, 0)
    mouse_control_frame.Close:SetScript("OnClick", function(s)
        mouse_control_frame:Hide()
        addon.mouse_image:Hide()
    end)

    mouse_control_frame.MinMax = CreateFrame("Frame", nil, mouse_control_frame, "MaximizeMinimizeButtonFrameTemplate")
    mouse_control_frame.MinMax:SetSize(26, 26)
    mouse_control_frame.MinMax:SetPoint("RIGHT", mouse_control_frame.Close, "LEFT", 2, 0)
    mouse_control_frame.MinMax:SetOnMaximizedCallback(OnMaximizeMouse)
    mouse_control_frame.MinMax:SetOnMinimizedCallback(OnMinimizeMouse)

    mouse_control_frame.MinMax:Minimize() -- Set the MinMax button & control frame size to Minimize
    --MouseControls.MinMax:SetMaximizedLook() -- Set the MinMax button & control frame size to Minimize

    return mouse_control_frame
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

function addon:SaveMouseLayout()
    local msg = addon.mouse_control_frame.Input:GetText()

    if addon.mouse_locked == true then
        if msg ~= "" then
            -- Clear the input field and focus
            addon.mouse_control_frame.Input:SetText("")
            addon.mouse_control_frame.Input:ClearFocus()

            print("KeyUI: Saved the new layout '" .. msg .. "'.")

            -- Initialize a new table for the saved layout
            keyui_settings.layout_edited_mouse[msg] = {}

            -- Iterate through all mouse buttons to save their data
            for _, Mousebutton in ipairs(addon.keys_mouse) do
                if Mousebutton:IsVisible() then
                    -- Save button properties: label, position, width, and height
                    keyui_settings.layout_edited_mouse[msg][#keyui_settings.layout_edited_mouse[msg] + 1] = {
                        Mousebutton.label:GetText(),                               -- Button name
                        floor(Mousebutton:GetLeft() - addon.mouse_frame:GetLeft() + 0.5), -- X position
                        floor(Mousebutton:GetTop() - addon.mouse_frame:GetTop() + 0.5),   -- Y position
                        floor(Mousebutton:GetWidth() + 0.5),                       -- Width
                        floor(Mousebutton:GetHeight() + 0.5)                       -- Height
                    }
                end
            end

            -- Clear the current layout and assign the new one
            wipe(keyui_settings.layout_current_mouse)
            keyui_settings.layout_current_mouse[msg] = keyui_settings.layout_edited_mouse[msg]

            -- Refresh the keys and update the dropdown menu
            addon:RefreshKeys()
            UIDropDownMenu_SetText(addon.mouse_selector, msg)
        else
            print("KeyUI: Please enter a name for the layout before saving.")
        end
    else
        print("KeyUI: Please lock the binds to save.")
    end
end

-- This function switches the key binding board to display different mouse key bindings.
function addon:UpdateMouseLayout()
    -- Clear existing Keys to avoid leftover data from previous layouts
    for i = 1, #addon.keys_mouse do
        addon.keys_mouse[i]:Hide()
        addon.keys_mouse[i] = nil
    end
    addon.keys_mouse = {}

    if addon.open == true and addon.mouse_frame then

        -- Check if the layout is empty
        local layoutNotEmpty = false
        for _, layoutData in pairs(keyui_settings.layout_current_mouse) do
            if #layoutData > 0 then
                layoutNotEmpty = true
                break
            end
        end

        -- Only proceed if there is a valid layout
        if layoutNotEmpty then
            local cx, cy = addon.mouse_frame:GetCenter()
            local left, right, top, bottom = cx, cx, cy, cy

            for _, layoutData in pairs(keyui_settings.layout_current_mouse) do
                for i = 1, #layoutData do
                    local MouseKey = addon.keys_mouse[i] or addon:CreateMouseButtons()
                    local keyData = layoutData[i]

                    if keyData[4] then
                        MouseKey:SetWidth(keyData[4])
                        MouseKey:SetHeight(keyData[5])
                    else
                        MouseKey:SetWidth(50)
                        MouseKey:SetHeight(50)
                    end

                    if not addon.keys_mouse[i] then
                        addon.keys_mouse[i] = MouseKey
                    end

                    MouseKey:SetPoint("TOPRIGHT", addon.mouse_frame, "TOPRIGHT", keyData[2], keyData[3])
                    MouseKey.label:SetText(keyData[1])
                    MouseKey:Show()

                    -- Track the extreme positions for frame resizing
                    local l, r, t, b = MouseKey:GetLeft(), MouseKey:GetRight(), MouseKey:GetTop(), MouseKey:GetBottom()

                    if l < left then left = l end
                    if r > right then right = r end
                    if t > top then top = t end
                    if b < bottom then bottom = b end
                end
            end
        end
    end
end

-- Create a new button to the main mouse image frame.
function addon:CreateMouseButtons()

    local mouse_button = CreateFrame("FRAME", nil, addon.mouse_image, "TooltipBorderedFrameTemplate")
    mouse_button:SetMovable(true)
    mouse_button:EnableMouse(true)
    mouse_button:EnableKeyboard(true)
    mouse_button:SetBackdropColor(0, 0, 0, 1)

    mouse_button.label = mouse_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mouse_button.label:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    mouse_button.label:SetTextColor(1, 1, 1, 0.9)
    mouse_button.label:SetHeight(50)
    mouse_button.label:SetWidth(54)
    mouse_button.label:SetPoint("CENTER", mouse_button, "CENTER", 0, 6)
    mouse_button.label:SetJustifyH("CENTER")
    mouse_button.label:SetJustifyV("BOTTOM")

    --button.macro = Blizzard ID Commands
    mouse_button.macro = mouse_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mouse_button.macro:SetText("")
    mouse_button.macro:Hide()

    --button.interfaceaction = Blizzard ID changed to readable Text
    mouse_button.interfaceaction = mouse_button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mouse_button.interfaceaction:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE")
    mouse_button.interfaceaction:SetTextColor(1, 1, 1)
    mouse_button.interfaceaction:SetHeight(20)
    mouse_button.interfaceaction:SetWidth(44)
    mouse_button.interfaceaction:SetPoint("TOP", mouse_button, "TOP", 0, -6)
    mouse_button.interfaceaction:SetText("")

    mouse_button.icon = mouse_button:CreateTexture(nil, "ARTWORK")
    mouse_button.icon:SetSize(40, 40)
    mouse_button.icon:SetPoint("TOPLEFT", mouse_button, "TOPLEFT", 5, -5)

    mouse_button:SetScript("OnEnter", function()
        addon:ButtonMouseOver(mouse_button)
        mouse_button:EnableKeyboard(true)
        mouse_button:EnableMouseWheel(true)

        if not addon.mouse_locked and not self.isMoving then -- insure modifier work when locked and hovering a key
            mouse_button:SetScript("OnKeyDown", function(_, key)
                addon:HandleKeyDown(mouse_button, key)
            end)
        end
        
        mouse_button:SetScript("OnMouseWheel", function(_, delta)
            addon:HandleMouseWheel(mouse_button, delta)
        end)

        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()

        -- Only show the PushedTexture if the setting is enabled
        if keyui_settings.show_pushed_texture then
            -- Check if currentActionBarPage is valid and map it to adjustedSlot
            if currentActionBarPage and mouse_button.slot then
                -- Calculate the adjustedSlot based on currentActionBarPage
                local adjustedSlot = mouse_button.slot
                if currentActionBarPage == 3 and mouse_button.slot >= 25 and mouse_button.slot <= 36 then
                    adjustedSlot = mouse_button.slot - 24 -- Map to ActionButton1-12
                elseif currentActionBarPage == 4 and mouse_button.slot >= 37 and mouse_button.slot <= 48 then
                    adjustedSlot = mouse_button.slot - 36 -- Map to ActionButton1-12
                elseif currentActionBarPage == 5 and mouse_button.slot >= 49 and mouse_button.slot <= 60 then
                    adjustedSlot = mouse_button.slot - 48 -- Map to ActionButton1-12
                elseif currentActionBarPage == 6 and mouse_button.slot >= 61 and mouse_button.slot <= 72 then
                    adjustedSlot = mouse_button.slot - 60 -- Map to ActionButton1-12
                end

                -- Look up the correct button in TextureMappings using the adjustedSlot
                local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
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

    mouse_button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        addon.tooltip:Hide()
        mouse_button:EnableKeyboard(false)
        mouse_button:EnableMouseWheel(false)
        if not addon.mouse_locked and not self.isMoving then -- insure modifier work when locked and hovering a key
            mouse_button:SetScript("OnKeyDown", nil)
        end

        -- Get the current action bar page
        local currentActionBarPage = GetActionBarPage()

        if keyui_settings.show_pushed_texture then
            -- Check if currentActionBarPage is valid and map it to adjustedSlot
            if currentActionBarPage and mouse_button.slot then
                -- Calculate the adjustedSlot based on currentActionBarPage
                local adjustedSlot = mouse_button.slot
                if currentActionBarPage == 3 and mouse_button.slot >= 25 and mouse_button.slot <= 36 then
                    adjustedSlot = mouse_button.slot - 24 -- Map to ActionButton1-12
                elseif currentActionBarPage == 4 and mouse_button.slot >= 37 and mouse_button.slot <= 48 then
                    adjustedSlot = mouse_button.slot - 36 -- Map to ActionButton1-12
                elseif currentActionBarPage == 5 and mouse_button.slot >= 49 and mouse_button.slot <= 60 then
                    adjustedSlot = mouse_button.slot - 48 -- Map to ActionButton1-12
                elseif currentActionBarPage == 6 and mouse_button.slot >= 61 and mouse_button.slot <= 72 then
                    adjustedSlot = mouse_button.slot - 60 -- Map to ActionButton1-12
                end

                -- Look up the correct button in TextureMappings using the adjustedSlot
                local mappedButton = addon.button_texture_mapping[tostring(adjustedSlot)]
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

    mouse_button:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if addon.mouse_locked == false then
                DragOrSize(self, button)
            else
                addon.currentKey = self
                local key = addon.currentKey.macro:GetText()

                local actionSlot = addon.action_slot_mapping[key]

                if actionSlot then
                    -- Adjust action slot based on current action bar page
                    local adjustedSlot = tonumber(actionSlot)

                    -- Handle bonus bar offsets for ROGUE and DRUID
                    if (addon.class_name == "ROGUE" or addon.class_name == "DRUID") and addon.bonusbar_offset ~= 0 and addon.current_actionbar_page == 1 then
                        if addon.bonusbar_offset == 1 then
                            adjustedSlot = adjustedSlot + 72  -- Maps to 73-84
                        elseif addon.bonusbar_offset == 2 then
                            adjustedSlot = adjustedSlot       -- No change for offset 2
                        elseif addon.bonusbar_offset == 3 then
                            adjustedSlot = adjustedSlot + 96  -- Maps to 97-108
                        elseif addon.bonusbar_offset == 4 then
                            adjustedSlot = adjustedSlot + 108 -- Maps to 109-120
                        end
                    end

                    -- Adjust based on current action bar page
                    if addon.current_actionbar_page == 2 then
                        adjustedSlot = adjustedSlot + 12 -- For ActionBarPage 2, adjust slots by +12 (13-24)
                    elseif addon.current_actionbar_page == 3 then
                        adjustedSlot = adjustedSlot + 24 -- For ActionBarPage 3, adjust slots by +24 (25-36)
                    elseif addon.current_actionbar_page == 4 then
                        adjustedSlot = adjustedSlot + 36 -- For ActionBarPage 4, adjust slots by +36 (37-48)
                    elseif addon.current_actionbar_page == 5 then
                        adjustedSlot = adjustedSlot + 48 -- For ActionBarPage 5, adjust slots by +48 (49-60)
                    elseif addon.current_actionbar_page == 6 then
                        adjustedSlot = adjustedSlot + 60 -- For ActionBarPage 6, adjust slots by +60 (61-72)
                    end

                    -- Check if Dragonriding
                    if addon.bonusbar_offset == 5 and addon.current_actionbar_page == 1 then
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
            addon:HandleKeyDown(self, button) -- Use the shared handler directly
        end
    end)

    mouse_button:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if addon.mouse_locked == false then
                Release(self, button)
            else
                infoType, info1, info2 = GetCursorInfo()
                if infoType == "spell" then
                    local spellname = C_SpellBook.GetSpellBookItemName(info1, Enum.SpellBookSpellBank.Player)
                    addon.currentKey = self
                    local key = addon.currentKey.macro:GetText()
                    local actionSlot = addon.action_slot_mapping[key]
                    if actionSlot then
                        PlaceAction(actionSlot)
                        ClearCursor()
                        addon:RefreshKeys()
                    end
                end
            end
        elseif button == "RightButton" then
            addon.currentKey = self
            ToggleDropDownMenu(1, nil, addon.dropdown, self, 30, 20)
        end
    end)

    addon.keys_mouse[mouse_button] = mouse_button

    return mouse_button
end

function addon:MouseLayoutSelecter()
    local MouseLayoutSelecter = CreateFrame("Frame", nil, addon.mouse_control_frame, "UIDropDownMenuTemplate")
    addon.mouse_selector = MouseLayoutSelecter

    UIDropDownMenu_SetWidth(MouseLayoutSelecter, 120)
    UIDropDownMenu_SetButtonWidth(MouseLayoutSelecter, 120)
    MouseLayoutSelecter:Hide()

    local boardOrder = { "Layout_4x3", 'Layout_2+4x3', "Layout_3x3", "Layout_3x2", "Layout_1+2x2", "Layout_2x2",
        "Layout_2x1", "Layout_Circle" }

    local function MouseLayoutSelecter_Initialize(self, level)
        level = level or 1
        local info = UIDropDownMenu_CreateInfo()
        local value = UIDROPDOWNMENU_MENU_VALUE

        for _, name in ipairs(boardOrder) do
            local Mousebuttons = addon.default_mouse_layouts[name]
            info.text = name
            info.value = name
            info.colorCode = "|cFFFFFFFF" -- white
            info.func = function()
                keyui_settings.key_bind_settings_mouse.currentboard = name
                wipe(keyui_settings.layout_current_mouse)
                keyui_settings.layout_current_mouse = { [name] = addon.default_mouse_layouts[name] }
                addon:RefreshKeys()
                UIDropDownMenu_SetText(self, name)
                addon.mouse_control_frame.Input:SetText("")
                addon.mouse_control_frame.Input:ClearFocus()
            end
            UIDropDownMenu_AddButton(info, level)
        end

        if type(keyui_settings.layout_edited_mouse) == "table" then
            for name, layout in pairs(keyui_settings.layout_edited_mouse) do
                info.text = name
                info.value = name
                info.colorCode = "|cffff8000"
                info.func = function()
                    wipe(keyui_settings.layout_current_mouse)
                    keyui_settings.layout_current_mouse[name] = layout
                    addon:RefreshKeys()
                    UIDropDownMenu_SetText(self, name)
                    addon.mouse_control_frame.Input:SetText("")
                    addon.mouse_control_frame.Input:ClearFocus()
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

    UIDropDownMenu_Initialize(MouseLayoutSelecter, MouseLayoutSelecter_Initialize)

    return MouseLayoutSelecter
end
