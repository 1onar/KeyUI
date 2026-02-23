local name, addon = ...

-- ============================================================================
-- ActionButton.lua – Shared factory functions for KeyUI secure action buttons
-- ============================================================================
-- All three surfaces (Keyboard, Mouse, Controller) share the same button
-- sub-element factories and update logic defined here.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Sub-element factories
-- ---------------------------------------------------------------------------

-- Main cooldown swipe (already existed in Core.lua; kept here for reference).
-- Core.lua still owns addon.CreateCooldownFrame.

-- Charge-recharge cooldown: thin edge ring, no swipe, no countdown numbers.
-- Shown only when currentCharges < maxCharges.
function addon.CreateChargeCooldownFrame(button)
    local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cd:ClearAllPoints()
    cd:SetAllPoints(button.icon)
    cd:SetFrameLevel(button:GetFrameLevel() + 2)
    cd:SetDrawSwipe(false)
    cd:SetDrawEdge(true)
    cd:SetDrawBling(false)
    cd:SetHideCountdownNumbers(true)
    cd:Hide()
    return cd
end

-- Loss-of-Control cooldown: red swipe for stun/fear/silence.
-- Shown on top of the normal cooldown when LoC duration > main cooldown.
function addon.CreateLoCCooldownFrame(button)
    local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cd:ClearAllPoints()
    cd:SetAllPoints(button.icon)
    cd:SetFrameLevel(button:GetFrameLevel() + 3)
    cd:SetSwipeColor(0.17, 0, 0, 0.8)
    cd:SetDrawEdge(true)
    cd:SetDrawBling(false)
    cd:SetHideCountdownNumbers(true)
    cd:Hide()
    return cd
end

-- Flash texture: semi-transparent red overlay that blinks during auto-attack.
function addon.CreateFlashTexture(button)
    local tex = button:CreateTexture(nil, "ARTWORK", nil, 1)
    tex:SetAllPoints(button.icon)
    tex:SetColorTexture(1, 0.1, 0.1, 0.4)
    tex:Hide()
    return tex
end

-- Equipped-item border: thin green overlay when an item on this slot is worn.
-- Implemented as a child Frame (FrameLevel+4) so it renders above the cooldown
-- child frames (+1, +2, +3) which otherwise obscure a plain texture on the parent.
function addon.CreateEquippedBorder(button)
    local f = CreateFrame("Frame", nil, button)
    -- Extend 5 px outward beyond the icon on each side; the atlas border texture has
    -- transparent padding before the visible border line so we need extra room.
    f:SetPoint("TOPLEFT",     button.icon, "TOPLEFT",     -5,  5)
    f:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT",  5, -5)
    f:SetFrameLevel(button:GetFrameLevel() + 4)
    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    addon:SetTexture(tex, "UI-HUD-ActionBar-IconFrame-Border",
        "Interface\\AddOns\\KeyUI\\Media\\Atlas\\CombatAssistantSingleButton",
        {0.707031, 0.886719, 0.462891, 0.506836})
    tex:SetVertexColor(0, 1.0, 0, 0.5)
    f:Hide()
    return f
end

-- ---------------------------------------------------------------------------
-- Slot attribute helper
-- ---------------------------------------------------------------------------

-- Call this every time button.active_slot changes (outside combat).
-- Sets the SecureActionButtonTemplate attributes so clicking executes the action.
function addon:SetButtonActionSlot(button, slot)
    button.active_slot = slot
    if not InCombatLockdown() then
        if slot and slot > 0 then
            button:SetAttribute("type", "action")
            button:SetAttribute("action", slot)
        else
            button:SetAttribute("type", nil)
            button:SetAttribute("action", nil)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Charge-cooldown update
-- ---------------------------------------------------------------------------

function addon:UpdateButtonChargeCooldown(button)
    local cd = button.charge_cooldown
    if not cd then return end

    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_charge_cooldown then
        cd:Hide()
        return
    end

    if not button.icon:IsShown() or not button.active_slot then
        cd:Hide()
        return
    end

    if InCombatLockdown() then return end

    local charges, maxCharges, chargeStart, chargeDuration, chargeModRate
    if C_ActionBar and C_ActionBar.GetActionCharges then
        local info = C_ActionBar.GetActionCharges(button.active_slot)
        if info then
            charges      = info.currentCharges
            maxCharges   = info.maxCharges
            chargeStart  = info.cooldownStartTime
            chargeDuration = info.cooldownDuration
            chargeModRate  = info.chargeModRate
        end
    elseif GetActionCharges then
        charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(button.active_slot)
    end

    if maxCharges and maxCharges > 1 and charges and charges < maxCharges
        and chargeStart and chargeStart > 0 and chargeDuration and chargeDuration > 0 then
        cd:SetCooldown(chargeStart, chargeDuration, chargeModRate or 1.0)
        cd:Show()
    else
        cd:Hide()
    end
end

-- ---------------------------------------------------------------------------
-- Loss-of-Control cooldown update
-- ---------------------------------------------------------------------------

function addon:UpdateButtonLoCCooldown(button)
    local cd = button.loc_cooldown
    if not cd then return end

    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_loc_cooldown then
        cd:Hide()
        return
    end

    if not button.icon:IsShown() or not button.active_slot then
        cd:Hide()
        return
    end

    if InCombatLockdown() then return end

    local locStart, locDuration
    if C_ActionBar and C_ActionBar.GetActionLossOfControlCooldown then
        locStart, locDuration = C_ActionBar.GetActionLossOfControlCooldown(button.active_slot)
    elseif GetActionLossOfControlCooldown then
        locStart, locDuration = GetActionLossOfControlCooldown(button.active_slot)
    end

    if locStart and locStart > 0 and locDuration and locDuration > 0 then
        cd:SetCooldown(locStart, locDuration)
        cd:Show()
    else
        cd:Hide()
    end
end

-- ---------------------------------------------------------------------------
-- Batch refresh helpers for charge & LoC cooldowns
-- ---------------------------------------------------------------------------

function addon:refresh_charge_cooldowns()
    if not keyui_settings.show_actionbar_mode then return end
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonChargeCooldown(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonChargeCooldown(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonChargeCooldown(b) end
end

function addon:refresh_loc_cooldowns()
    if not keyui_settings.show_actionbar_mode then return end
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonLoCCooldown(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonLoCCooldown(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonLoCCooldown(b) end
end

-- ---------------------------------------------------------------------------
-- Auto-attack / auto-shot flash
-- ---------------------------------------------------------------------------

local FLASH_CYCLE = 0.4   -- seconds per on/off half-cycle

-- Start or stop flashing on a single button.
function addon:UpdateButtonFlash(button)
    if not button.flash_texture then return end

    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_attack_flash then
        button.flash_texture:Hide()
        button.flashing = false
        return
    end

    if not button.icon:IsShown() or not button.active_slot then
        button.flash_texture:Hide()
        button.flashing = false
        return
    end

    local shouldFlash = false
    if IsAttackAction and IsAttackAction(button.active_slot) and IsCurrentAction and IsCurrentAction(button.active_slot) then
        shouldFlash = true
    elseif IsAutoRepeatAction and IsAutoRepeatAction(button.active_slot) then
        shouldFlash = true
    end

    button.flashing = shouldFlash
    if not shouldFlash then
        button.flash_texture:Hide()
    end
end

function addon:refresh_flash()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonFlash(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonFlash(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonFlash(b) end
end

-- OnUpdate ticker that toggles the flash texture at FLASH_CYCLE intervals.
do
    local flashTime = 0
    local flashOn   = false
    local flashFrame = CreateFrame("Frame")
    flashFrame:SetScript("OnUpdate", function(_, elapsed)
        if not addon.open then return end

        flashTime = flashTime + elapsed
        if flashTime < FLASH_CYCLE then return end
        flashTime = 0
        flashOn = not flashOn

        local function tick(list)
            for _, b in ipairs(list) do
                if b.flashing and b.flash_texture then
                    if flashOn then
                        b.flash_texture:Show()
                    else
                        b.flash_texture:Hide()
                    end
                end
            end
        end
        tick(addon.keys_keyboard)
        tick(addon.keys_mouse)
        tick(addon.keys_controller)
    end)
end

-- ---------------------------------------------------------------------------
-- Equipped-item border update
-- ---------------------------------------------------------------------------

function addon:UpdateButtonEquipped(button)
    local tex = button.equipped_border
    if not tex then return end

    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_equipped_border then
        tex:Hide()
        return
    end

    if not button.icon:IsShown() or not button.active_slot then
        tex:Hide()
        return
    end

    local equipped = false
    if C_ActionBar and C_ActionBar.IsEquippedAction then
        equipped = C_ActionBar.IsEquippedAction(button.active_slot)
    elseif IsEquippedAction then
        equipped = IsEquippedAction(button.active_slot)
    end

    if equipped then tex:Show() else tex:Hide() end
end

function addon:refresh_equipped()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonEquipped(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonEquipped(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonEquipped(b) end
end

-- ---------------------------------------------------------------------------
-- Proc-glow via Blizzard's ActionButtonSpellAlertTemplate (1:1 implementation).
-- Mirrors ActionButtonSpellAlertManager behaviour including the "downgrade" to
-- ProcAltGlow when One Button Assist is active and the spell is in the rotation.
-- ---------------------------------------------------------------------------

-- Returns true when assisted combat is active AND spellID is part of the rotation.
-- Mirrors AssistedCombatManager:ShouldDowngradeSpellAlertForButton for KeyUI buttons
-- (Blizzard skips non-.bar.isNormalBar buttons, so we implement this ourselves).
local function KeyUI_ShouldDowngradeAlert(spellID)
    if not C_ActionBar or not C_ActionBar.HasAssistedCombatActionButtons then return false end
    if not C_ActionBar.HasAssistedCombatActionButtons() then return false end
    if not C_AssistedCombat or not C_AssistedCombat.GetRotationSpells then return false end
    for _, sid in ipairs(C_AssistedCombat.GetRotationSpells()) do
        if sid == spellID then return true end
    end
    return false
end

-- Show proc glow on button. useAltGlow=true → ProcAltGlow (dezenter Rahmen),
-- useAltGlow=false → volle Burst-Animation (OneButton-Atlas für Assist-Buttons).
function addon:ShowButtonProcGlow(button, useAltGlow)
    -- ActionButtonSpellAlertTemplate exists in Retail, Cata Classic, and Anniversary.
    -- Classic Era (isVanilla) does not have it; fall back to LibButtonGlow if available.
    if addon.VERSION.isRetail or addon.VERSION.isCata or addon.VERSION.isAnniversary then
        if useAltGlow then
            -- Subtle golden ring (downgrade): use a dedicated KeyUI frame so we can size
            -- it to the icon exactly, without fighting useAtlasSize=true template internals.
            if not button.KeyUI_ProcAltGlow then
                local iw, ih = button.icon:GetSize()
                local g = CreateFrame("Frame", nil, button)
                g:SetFrameLevel(button:GetFrameLevel() + 5)
                g:SetPoint("CENTER", button.icon, "CENTER", 0, 0)
                g:SetSize(iw * 1.1, ih * 1.1)
                local tex = g:CreateTexture(nil, "OVERLAY")
                tex:SetAllPoints()
                if addon.VERSION.USE_ATLAS then
                    tex:SetAtlas("UI-HUD-RotationHelper-ProcAltGlow")
                else
                    tex:SetColorTexture(1, 0.82, 0, 0.6)  -- golden fallback
                end
                button.KeyUI_ProcAltGlow = g
            end
            -- Hide full-burst if it was previously showing
            if button.SpellActivationAlert then button.SpellActivationAlert:Hide() end
            button.KeyUI_ProcAltGlow:Show()
            return
        end
        -- Full burst animation (useAltGlow=false)
        if not button.SpellActivationAlert then
            -- Anchor to icon CENTER (not button CENTER) so the +4 Y offset on keyboard
            -- icons is respected; size from icon (not button) so it scales correctly.
            local iw, ih = button.icon:GetSize()
            local f = CreateFrame("Frame", nil, button, "ActionButtonSpellAlertTemplate")
            f:SetSize(iw * 1.4, ih * 1.4)
            f:SetPoint("CENTER", button.icon, "CENTER", 0, 0)
            button.SpellActivationAlert = f
        end
        -- Hide alt glow if it was previously showing
        if button.KeyUI_ProcAltGlow then button.KeyUI_ProcAltGlow:Hide() end
        local alert = button.SpellActivationAlert
        -- Use OneButton atlas for assist buttons, standard flipbook for normal spell buttons
        local isAssist = C_ActionBar and C_ActionBar.IsAssistedCombatAction and
                         C_ActionBar.IsAssistedCombatAction(button.active_slot)
        if isAssist then
            alert.ProcStartFlipbook:SetAtlas("OneButton_ProcStart_Flipbook")
            alert.ProcLoopFlipbook:SetAtlas("OneButton_ProcLoop_Flipbook")
        else
            alert.ProcStartFlipbook:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")
            alert.ProcLoopFlipbook:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
        end
        alert.ProcAltGlow:Hide()
        alert.ProcStartFlipbook:SetAlpha(1)
        alert:Show()
        alert.ProcStartAnim:Play()
        return
    end
    -- Classic Era: native overlay glow (ActionButton_ShowOverlayGlow exists in 1.15.x)
    ActionButton_ShowOverlayGlow(button)
end

function addon:HideButtonProcGlow(button)
    if addon.VERSION.isRetail or addon.VERSION.isCata or addon.VERSION.isAnniversary then
        if button.KeyUI_ProcAltGlow then button.KeyUI_ProcAltGlow:Hide() end
        if button.SpellActivationAlert then
            local alert = button.SpellActivationAlert
            alert.ProcStartAnim:Stop()
            alert.ProcAltGlow:Hide()
            alert:Hide()   -- OnHide Mixin stops ProcLoop
        end
        return
    end
    -- Classic Era: native overlay glow
    ActionButton_HideOverlayGlow(button)
end

-- Called when SPELL_ACTIVATION_OVERLAY_GLOW_SHOW fires with a spellID.
function addon:HandleProcGlowShow(spellID)
    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_proc_glow then return end
    local downgrade = KeyUI_ShouldDowngradeAlert(spellID)
    local function check(list)
        for _, b in ipairs(list) do
            if b.active_slot and HasAction and HasAction(b.active_slot) then
                -- Identify assist buttons first; they need a different trigger condition.
                local isAssist = C_ActionBar and C_ActionBar.IsAssistedCombatAction and
                                 C_ActionBar.IsAssistedCombatAction(b.active_slot)
                if isAssist then
                    -- downgrade=true means: assist is active AND spellID is in the rotation.
                    -- The assist button IS showing that rotation spell → show full burst on it.
                    -- (GetActionInfo on assist slots returns nil, so we can't match by spellID.)
                    if downgrade then
                        addon:ShowButtonProcGlow(b, false)  -- assist: always full burst
                    end
                else
                    local atype, aid = GetActionInfo(b.active_slot)
                    if atype == "spell" and aid == spellID then
                        addon:ShowButtonProcGlow(b, downgrade)
                    end
                end
            end
        end
    end
    check(addon.keys_keyboard)
    check(addon.keys_mouse)
    check(addon.keys_controller)
end

-- Called when SPELL_ACTIVATION_OVERLAY_GLOW_HIDE fires with a spellID.
function addon:HandleProcGlowHide(spellID)
    local function check(list)
        for _, b in ipairs(list) do
            if b.active_slot then
                local isAssist = C_ActionBar and C_ActionBar.IsAssistedCombatAction and
                                 C_ActionBar.IsAssistedCombatAction(b.active_slot)
                if isAssist then
                    -- Mirror the show-logic: hide when downgrade=true (assist active + rotation spell)
                    local downgrade = KeyUI_ShouldDowngradeAlert(spellID)
                    if downgrade then
                        addon:HideButtonProcGlow(b)
                    end
                else
                    local atype, aid = GetActionInfo(b.active_slot)
                    if atype == "spell" and aid == spellID then
                        addon:HideButtonProcGlow(b)
                    end
                end
            end
        end
    end
    check(addon.keys_keyboard)
    check(addon.keys_mouse)
    check(addon.keys_controller)
end

-- ---------------------------------------------------------------------------
-- Pet auto-cast overlay
-- ---------------------------------------------------------------------------

function addon:UpdateButtonPetAutoCast(button)
    local overlay = button.autocast_overlay
    if not overlay then return end

    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_pet_autocast then
        overlay:Hide()
        return
    end

    if not button.icon:IsShown() or not button.active_slot then
        overlay:Hide()
        return
    end

    local allowed, enabled = false, false
    if C_ActionBar and C_ActionBar.GetActionAutocast then
        allowed, enabled = C_ActionBar.GetActionAutocast(button.active_slot)
    elseif GetActionAutocast then
        allowed, enabled = GetActionAutocast(button.active_slot)
    end

    if allowed then
        overlay:Show()
        -- Animate the rotating dots: Blizzard's AutoCastOverlayTemplate handles
        -- the animation internally when shown/hidden via Show()/Hide().
        if enabled then
            if AutoCastShine_AutoCastStart then
                AutoCastShine_AutoCastStart(overlay)
            end
            -- Retail/Anniversary: AutoCastOverlayTemplate animates automatically via Mixin
        else
            if AutoCastShine_AutoCastStop then
                AutoCastShine_AutoCastStop(overlay)
            end
        end
    else
        overlay:Hide()
    end
end

function addon:refresh_pet_autocast()
    for _, b in ipairs(addon.keys_keyboard)    do addon:UpdateButtonPetAutoCast(b) end
    for _, b in ipairs(addon.keys_mouse)       do addon:UpdateButtonPetAutoCast(b) end
    for _, b in ipairs(addon.keys_controller)  do addon:UpdateButtonPetAutoCast(b) end
end

-- Pet auto-cast toggle on right-click (when in locked mode with an active slot).
function addon:ToggleButtonPetAutoCast(button)
    if not button.active_slot then return end
    if C_ActionBar and C_ActionBar.ToggleAutoCastPetAction then
        C_ActionBar.ToggleAutoCastPetAction(button.active_slot)
    elseif ToggleAutoCastPetAction then
        ToggleAutoCastPetAction(button.active_slot)
    end
end
