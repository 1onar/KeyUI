local name, addon = ...

-- ============================================================================
-- ActionButton.lua – Shared factory functions for KeyUI secure action buttons
-- ============================================================================
-- All three surfaces (Keyboard, Mouse, Controller) share the same button
-- sub-element factories and update logic defined here.
-- ============================================================================

local LBG  -- LibButtonGlow-1.0, resolved lazily after embeds are loaded
local function GetLBG()
    if not LBG then
        LBG = LibStub and LibStub("LibButtonGlow-1.0", true)
    end
    return LBG
end

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
function addon.CreateEquippedBorder(button)
    local tex = button:CreateTexture(nil, "OVERLAY", nil, 1)
    tex:SetAllPoints(button.icon)
    tex:SetColorTexture(0, 0.8, 0, 0.35)
    tex:Hide()
    return tex
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

    local locStart, locDuration
    if C_ActionBar and C_ActionBar.GetActionLossOfControlCooldown then
        local info = C_ActionBar.GetActionLossOfControlCooldown(button.active_slot)
        if info then
            locStart    = info.startTime
            locDuration = info.duration
        end
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
-- Proc-glow (spell activation overlay) via LibButtonGlow-1.0
-- Taint-safe alternative to ActionButton_ShowOverlayGlow.
-- ---------------------------------------------------------------------------

function addon:ShowButtonProcGlow(button)
    local lbg = GetLBG()
    if lbg then
        lbg:ShowOverlayGlow(button)
    end
end

function addon:HideButtonProcGlow(button)
    local lbg = GetLBG()
    if lbg then
        lbg:HideOverlayGlow(button)
    end
end

-- Called when SPELL_ACTIVATION_OVERLAY_GLOW_SHOW fires with a spellID.
function addon:HandleProcGlowShow(spellID)
    if not keyui_settings.show_actionbar_mode or not keyui_settings.show_proc_glow then return end
    local function check(list)
        for _, b in ipairs(list) do
            if b.active_slot and HasAction and HasAction(b.active_slot) then
                local atype, aid = GetActionInfo(b.active_slot)
                if atype == "spell" and aid == spellID then
                    addon:ShowButtonProcGlow(b)
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
                local atype, aid = GetActionInfo(b.active_slot)
                if atype == "spell" and aid == spellID then
                    addon:HideButtonProcGlow(b)
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
