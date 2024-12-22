local name, addon = ...

-- Function to create a glowing tutorial highlight around the selected button
function addon:create_tutorial_frame1()

    local frame
    local frame1_setpoint

    -- Get the correct reference button based on the active control tab
    if addon.keyboard_frame and addon.keyboard_frame.controls_button:IsVisible() then
        frame = addon.keyboard_frame
        frame1_setpoint = addon.keyboard_frame.controls_button
    elseif addon.mouse_image and addon.mouse_image.controls_button:IsVisible() then
        frame = addon.mouse_image
        frame1_setpoint = addon.mouse_image.controls_button
    elseif addon.controller_frame and addon.controller_frame.controls_button:IsVisible() then
        frame = addon.controller_frame
        frame1_setpoint = addon.controller_frame.controls_button
    end

    -- Create the main glowing frame
    local tutorial_frame = CreateFrame("Frame", nil, frame, "GlowBoxTemplate")
    tutorial_frame:SetPoint("BOTTOM", frame1_setpoint, "CENTER", 0, 70)
    tutorial_frame:SetSize(200, 50)
    tutorial_frame:SetFrameStrata("TOOLTIP")

    local frametext = tutorial_frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frametext:SetPoint("CENTER", tutorial_frame, "CENTER")
    frametext:SetText("Click here to begin!")

    -- Create an arrow frame and position it relative to the main frame
    local arrow = CreateFrame("Frame", nil, tutorial_frame, "Tutorial_PointerDown")
    arrow:SetPoint("TOP", tutorial_frame, "CENTER", 0, 0)

    -- Start the arrow animation
    arrow.Anim:Play()

    -- Hook click event to hide tutorial when the button is clicked
    frame1_setpoint:HookScript("OnClick", function()

        if tutorial_frame then
            tutorial_frame:Hide()

            if addon.controls_frame and addon.tutorial_frame2_created ~= true then

                local frame2_setpoint

                -- Get the correct reference button based on the active control tab
                if addon.keyboard_selector and addon.keyboard_selector:IsVisible() then
                    frame2_setpoint = addon.keyboard_selector
                elseif addon.mouse_selector and addon.mouse_selector:IsVisible() then
                    frame2_setpoint = addon.mouse_selector
                elseif addon.controller_selector and addon.controller_selector:IsVisible() then
                    frame2_setpoint = addon.controller_selector
                end

                -- Create the main glowing frame
                local tutorial_frame2 = CreateFrame("Frame", nil, addon.controls_frame, "GlowBoxTemplate")
                tutorial_frame2:SetPoint("LEFT", frame2_setpoint, "RIGHT", 70, 0)
                tutorial_frame2:SetSize(200, 50)
                tutorial_frame2:SetFrameStrata("TOOLTIP")

                local frametext2 = tutorial_frame2:CreateFontString(nil, "ARTWORK", "GameFontWhite")
                frametext2:SetPoint("CENTER", tutorial_frame2, "CENTER")
                frametext2:SetText("Click to select a layout")

                -- Create an arrow frame and position it relative to the main frame
                local arrow2 = CreateFrame("Frame", nil, tutorial_frame2, "Tutorial_PointerLeft")

                -- Remove any existing point, then set a new one
                arrow2:ClearAllPoints()
                arrow2:SetPoint("LEFT", frame2_setpoint, "RIGHT", 30, 0)

                arrow2:SetFrameStrata("TOOLTIP")

                -- Start the arrow animation
                arrow2.Anim:Play()

                -- Hook click event to hide tutorial when the button is clicked
                frame2_setpoint:HookScript("OnClick", function()
                    if tutorial_frame2 then
                        tutorial_frame2:Hide()
                        keyui_settings.tutorial_completed = true
                    end
                end)

                addon.tutorial_frame2_created = true
            end
        end
    end)

    addon.tutorial_frame1_created = true
end