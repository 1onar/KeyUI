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

    -- Create arrow frame (Retail uses template, Anniversary builds manually)
    local arrow
    if pcall(function() CreateFrame("Frame", nil, UIParent, "Tutorial_PointerDown") end) then
        -- Retail: Use built-in template
        arrow = CreateFrame("Frame", nil, tutorial_frame, "Tutorial_PointerDown")
        arrow:SetPoint("TOP", tutorial_frame, "CENTER", 0, 0)
        if arrow.Anim then
            arrow.Anim:Play()
        end
    else
        -- Anniversary: Build arrow manually with extracted textures
        arrow = CreateFrame("Frame", nil, tutorial_frame)
        arrow:SetSize(64, 64)
        arrow:SetPoint("TOP", tutorial_frame, "CENTER", 0, 23)
        arrow:SetAlpha(0)

        -- Background layer: Arrow texture
        local arrowTex = arrow:CreateTexture(nil, "BACKGROUND")
        arrowTex:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\newplayerexperienceparts")
        arrowTex:SetTexCoord(0.735352, 0.766602, 0.254883, 0.317383)  -- NPE_ArrowDown
        arrowTex:SetAllPoints()

        -- Overlay layer: Glow texture
        local glowTex = arrow:CreateTexture(nil, "OVERLAY")
        glowTex:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\newplayerexperienceparts")
        glowTex:SetTexCoord(0.767578, 0.798828, 0.254883, 0.317383)  -- NPE_ArrowDownGlow
        glowTex:SetAlpha(0.75)
        glowTex:SetBlendMode("ADD")
        glowTex:SetAllPoints()

        -- Animation: Move down + fade in/out
        local ag = arrow:CreateAnimationGroup()
        arrow.Anim = ag

        local translation = ag:CreateAnimation("Translation")
        translation:SetOffset(0, -50)
        translation:SetDuration(1)
        translation:SetOrder(1)
        translation:SetSmoothing("OUT")

        local alphaIn = ag:CreateAnimation("Alpha")
        alphaIn:SetFromAlpha(0)
        alphaIn:SetToAlpha(1)
        alphaIn:SetDuration(0.1)
        alphaIn:SetOrder(1)

        local alphaOut = ag:CreateAnimation("Alpha")
        alphaOut:SetFromAlpha(1)
        alphaOut:SetToAlpha(0)
        alphaOut:SetDuration(0.9)
        alphaOut:SetStartDelay(0.1)
        alphaOut:SetOrder(1)
        alphaOut:SetSmoothing("IN")

        ag:SetScript("OnFinished", function(self)
            self:Play()
        end)

        ag:Play()
    end

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

                -- Create arrow frame (Retail uses template, Anniversary builds manually)
                local arrow2
                if pcall(function() CreateFrame("Frame", nil, UIParent, "Tutorial_PointerLeft") end) then
                    -- Retail: Use built-in template
                    arrow2 = CreateFrame("Frame", nil, tutorial_frame2, "Tutorial_PointerLeft")
                    arrow2:ClearAllPoints()
                    arrow2:SetPoint("LEFT", frame2_setpoint, "RIGHT", 30, 0)
                    arrow2:SetFrameStrata("TOOLTIP")
                    if arrow2.Anim then
                        arrow2.Anim:Play()
                    end
                else
                    -- Anniversary: Build arrow manually with extracted textures
                    arrow2 = CreateFrame("Frame", nil, tutorial_frame2)
                    arrow2:SetSize(64, 64)
                    arrow2:SetPoint("LEFT", frame2_setpoint, "RIGHT", 30, 0)
                    arrow2:SetAlpha(0)

                    -- Background layer: Arrow texture
                    local arrowTex2 = arrow2:CreateTexture(nil, "BACKGROUND")
                    arrowTex2:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\newplayerexperienceparts")
                    arrowTex2:SetTexCoord(0.799805, 0.831055, 0.254883, 0.317383)  -- NPE_ArrowLeft
                    arrowTex2:SetAllPoints()

                    -- Overlay layer: Glow texture
                    local glowTex2 = arrow2:CreateTexture(nil, "OVERLAY")
                    glowTex2:SetTexture("Interface\\AddOns\\KeyUI\\Media\\Atlas\\newplayerexperienceparts")
                    glowTex2:SetTexCoord(0.832031, 0.863281, 0.254883, 0.317383)  -- NPE_ArrowLeftGlow
                    glowTex2:SetAlpha(0.75)
                    glowTex2:SetBlendMode("ADD")
                    glowTex2:SetAllPoints()

                    -- Animation: Move left + fade in/out
                    local ag2 = arrow2:CreateAnimationGroup()
                    arrow2.Anim = ag2

                    local translation2 = ag2:CreateAnimation("Translation")
                    translation2:SetOffset(-50, 0)
                    translation2:SetDuration(1)
                    translation2:SetOrder(1)
                    translation2:SetSmoothing("OUT")

                    local alphaIn2 = ag2:CreateAnimation("Alpha")
                    alphaIn2:SetFromAlpha(0)
                    alphaIn2:SetToAlpha(1)
                    alphaIn2:SetDuration(0.1)
                    alphaIn2:SetOrder(1)

                    local alphaOut2 = ag2:CreateAnimation("Alpha")
                    alphaOut2:SetFromAlpha(1)
                    alphaOut2:SetToAlpha(0)
                    alphaOut2:SetDuration(0.9)
                    alphaOut2:SetStartDelay(0.1)
                    alphaOut2:SetOrder(1)
                    alphaOut2:SetSmoothing("IN")

                    ag2:SetScript("OnFinished", function(self)
                        self:Play()
                    end)

                    ag2:Play()
                end

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