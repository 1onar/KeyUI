local name, addon = ...

function addon:create_selection_frame()
    -- Create the main selection frame
    local selection_frame = CreateFrame("Frame", "keyui_selection_frame", UIParent, "BackdropTemplate")
    addon.selection_frame = selection_frame

    tinsert(UISpecialFrames, "keyui_selection_frame")

    -- Position and size of the main frame
    selection_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    -- Adjust height and width for 256x512 images and margins
    local border = 5    -- border size
    local margin = 8
    local child_frame_width = 250
    local child_frame_height = 500
    local total_width = border * 2 + margin * 2 + child_frame_width * 3
    selection_frame:SetSize(total_width, child_frame_height + border * 2)

    -- Backdrop settings for the main frame
    local backdropInfo = {
        bgFile = "Interface\\AddOns\\KeyUI\\Media\\Background\\darkgrey_bg",
        tile = true,
        tileSize = 8,
    }
    selection_frame:SetBackdrop(backdropInfo)
    selection_frame:SetBackdropColor(0.08, 0.08, 0.08, 1)


    -- Create a secondary frame at the bottom for instructions and buttons
    local top_frame = CreateFrame("Frame", nil, selection_frame, "BackdropTemplate")
    top_frame:SetSize(total_width, 50)  -- Height for the controls section
    top_frame:SetPoint("BOTTOM", selection_frame, "TOP", 0, 0)  -- Adjust positioning as needed

    local control_backdropInfo = {
        bgFile = "Interface\\AddOns\\KeyUI\\Media\\Background\\bottomblack_bg",
        tile = false,
    }
    top_frame:SetBackdrop(control_backdropInfo)
    top_frame:SetBackdropColor(0.1, 0.1, 0.1, 1)

    -- Create instructions text
    local instructions_text = top_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions_text:SetPoint("CENTER", top_frame, "CENTER", 0, 0)
    instructions_text:SetText("Select One or More Devices to Visualize")
    instructions_text:SetFont(addon:GetFont(), addon:GetFontSize(1.75))
    addon:RegisterFontString(instructions_text, 1.75)
    instructions_text:SetTextColor(1, 1, 1, 1)

    -- Create a secondary frame at the bottom for instructions and buttons
    local bottom_frame = CreateFrame("Frame", nil, selection_frame, "BackdropTemplate")

    local button_width = selection_frame:GetWidth() / 2 - 30  -- 1/2 of the width
    local one_quarter_offset = selection_frame:GetWidth() / 4  -- 1/4 of the width
    local three_quarter_offset = selection_frame:GetWidth() * 3 / 4  -- 3/4 of the width    

    bottom_frame:SetSize(total_width, 60)  -- Height for the controls section
    bottom_frame:SetPoint("TOPLEFT", selection_frame, "BOTTOMLEFT", 0, 0)  -- Adjust positioning as needed

    local control_backdropInfo = {
        bgFile = "Interface\\AddOns\\KeyUI\\Media\\Background\\topblack_bg",
        tile = false,
    }
    bottom_frame:SetBackdrop(control_backdropInfo)
    bottom_frame:SetBackdropColor(0.1, 0.1, 0.1, 1)

    -- Load Button
    local load_button = addon:CreateStyledButton(selection_frame, {
        width = button_width,
        height = 30,
        label = "Load",
        textureHeight = 46,
    })
    load_button:SetPoint("CENTER", bottom_frame, "LEFT", one_quarter_offset, 0)
    if keyui_settings.show_keyboard == false and keyui_settings.show_mouse == false and keyui_settings.show_controller == false then
        load_button:Disable()
    end

    -- Cancel Button
    local cancel_button = addon:CreateStyledButton(selection_frame, {
        width = button_width,
        height = 30,
        label = "Cancel",
        textureHeight = 46,
    })
    cancel_button:SetPoint("CENTER", bottom_frame, "LEFT", three_quarter_offset, 0)

    load_button:SetScript("OnShow", function()
        if keyui_settings.show_keyboard == false and keyui_settings.show_mouse == false and keyui_settings.show_controller == false then
            load_button:Disable()
        end
    end)

    -- Scripts for button functionality
    load_button:SetScript("OnClick", function()
        addon.selection_frame:Hide()
        addon:load()
    end)

    cancel_button:SetScript("OnClick", function()
        addon:hide_all_frames()
        keyui_settings.show_keyboard = false
        keyui_settings.show_mouse = false
        keyui_settings.show_controller = false
    end)

    -- Helper function to create a child frame with hover effects and a label
    local function create_child_frame(parent, texture_path, frame_width, frame_height, x_offset, settings_key, label_text)
        -- Create the child frame
        local selection_backdrop_frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        selection_backdrop_frame:SetSize(frame_width - 4, frame_height)

        -- Set the position of the frame to the center of its x_offset, but keep the child centered
        selection_backdrop_frame:SetPoint("CENTER", parent, "CENTER", x_offset, 0)

        -- Add the texture to the child frame
        local texture = selection_backdrop_frame:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(texture_path)
        texture:SetAllPoints(selection_backdrop_frame)

        -- Border frame to be toggled with selected texture from Editmode
        local border_frame = addon:CreateGlowFrame(selection_backdrop_frame, {
            point = { "CENTER", selection_backdrop_frame, "CENTER" },
            width = frame_width,
            height = frame_height,
        })

        -- Add a label text to the frame
        local label = selection_backdrop_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetText(label_text)
        label:SetFont(addon:GetFont(), addon:GetFontSize(1.375), "OUTLINE")
        addon:RegisterFontString(label, 1.375, false, "OUTLINE")
        label:SetTextColor(1, 1, 1, 1)
        label:SetPoint("TOPLEFT", selection_backdrop_frame, "TOPLEFT", 20, -20)

        -- Initialize visibility based on keyui_settings
        if keyui_settings[settings_key] then
            border_frame:Show()
        else
            border_frame:Hide()
        end

        -- Handle the click event to toggle visibility and update keyui_settings
        selection_backdrop_frame:SetScript("OnMouseDown", function(self)
            if keyui_settings[settings_key] then
                border_frame:Hide()
                keyui_settings[settings_key] = false
                if load_button and keyui_settings.show_keyboard == false and keyui_settings.show_mouse == false and keyui_settings.show_controller == false then
                    load_button:Disable()
                end
            else
                border_frame:Show()
                keyui_settings[settings_key] = true
                if load_button then
                    load_button:Enable()
                end
            end
        end)

        -- Set scale effect on hover without moving
        selection_backdrop_frame:SetScript("OnEnter", function(self)
            self:SetWidth(frame_width + 4) -- Slightly increase width on hover
            self:SetHeight(frame_height + 8) -- Slightly increase height on hover
            border_frame:SetWidth(frame_width) -- Slightly increase width on hover
            border_frame:SetHeight(frame_height + 6) -- Slightly increase height on hover
        end)

        selection_backdrop_frame:SetScript("OnLeave", function(self)
            self:SetWidth(frame_width)  -- Reset width
            self:SetHeight(frame_height) -- Reset height
            border_frame:SetWidth(frame_width - 4)  -- Reset width
            border_frame:SetHeight(frame_height) -- Reset height
        end)

        selection_backdrop_frame:SetScript("OnShow", function()
            if keyui_settings[settings_key] then
                border_frame:Show()
            else
                border_frame:Hide()
            end
        end)

        -- Set the frame level of the child frame to be higher than the selection frame but lower than the border frame
        selection_backdrop_frame:SetFrameLevel(parent:GetFrameLevel() + 1)

        return selection_backdrop_frame
    end

    -- Create and position the child frames
    local keyboard_frame = create_child_frame(
        selection_frame,
        "Interface\\AddOns\\KeyUI\\Media\\Frame\\selection_keyboard.tga",
        child_frame_width,
        child_frame_height,
        -((total_width / 2) - (child_frame_width / 2)) + border,
        "show_keyboard", -- Settings key
        "Keyboard"       -- Label text
    )

    local mouse_frame = create_child_frame(
        selection_frame,
        "Interface\\AddOns\\KeyUI\\Media\\Frame\\selection_mouse.tga",
        child_frame_width,
        child_frame_height,
        -((total_width / 2) - (child_frame_width / 2)) + border + margin + child_frame_width,
        "show_mouse", -- Settings key
        "Mouse"       -- Label text
    )

    local controller_frame = create_child_frame(
        selection_frame,
        "Interface\\AddOns\\KeyUI\\Media\\Frame\\selection_controller.tga",
        child_frame_width,
        child_frame_height,
        -((total_width / 2) - (child_frame_width / 2)) + border + margin * 2 + child_frame_width * 2,
        "show_controller", -- Settings key
        "Controller"      -- Label text
    )

    return selection_frame
end
