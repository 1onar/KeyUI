local _, addon = ...

-- Register Settings category
local category, layout = Settings.RegisterVerticalLayoutCategory("KeyUI")
addon.settingsCategory = category

local function InitializeSettingsPanel()
    -- Minimap Button Setting
    local function GetMinimapValue()
        return not keyui_settings.minimap.hide
    end

    local function SetMinimapValue(value)
        keyui_settings.minimap.hide = not value
        local LibDBIcon = LibStub("LibDBIcon-1.0")
        if value then
            LibDBIcon:Show("KeyUI")
            print("KeyUI: Minimap button enabled")
        else
            LibDBIcon:Hide("KeyUI")
            print("KeyUI: Minimap button disabled")
        end
    end

    local minimapSetting = Settings.RegisterProxySetting(
        category,
        "KEYUI_MINIMAP_BUTTON",
        Settings.VarType.Boolean,
        "Minimap Button",
        Settings.Default.True,
        GetMinimapValue,
        SetMinimapValue
    )
    Settings.CreateCheckbox(category, minimapSetting, "Show or hide the minimap button")

    -- Stay Open In Combat Setting
    local stayOpenSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_STAY_OPEN_COMBAT",
        "stay_open_in_combat",
        keyui_settings,
        Settings.VarType.Boolean,
        "Stay Open In Combat",
        Settings.Default.False
    )
    Settings.CreateCheckbox(category, stayOpenSetting, "Allow KeyUI to stay open during combat")

    -- Show Keyboard Setting
    local showKeyboardSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_SHOW_KEYBOARD",
        "show_keyboard",
        keyui_settings,
        Settings.VarType.Boolean,
        "Show Keyboard",
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, showKeyboardSetting, "Show or hide the keyboard frame")

    -- Show Mouse Setting
    local showMouseSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_SHOW_MOUSE",
        "show_mouse",
        keyui_settings,
        Settings.VarType.Boolean,
        "Show Mouse",
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, showMouseSetting, "Show or hide the mouse frame")

    -- Show Controller Setting
    local showControllerSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_SHOW_CONTROLLER",
        "show_controller",
        keyui_settings,
        Settings.VarType.Boolean,
        "Show Controller",
        Settings.Default.False
    )
    Settings.CreateCheckbox(category, showControllerSetting, "Show or hide the controller frame")

    -- Keyboard Background Setting
    local keyboardBgSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_KEYBOARD_BACKGROUND",
        "show_keyboard_background",
        keyui_settings,
        Settings.VarType.Boolean,
        "Keyboard Background",
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, keyboardBgSetting, "Show or hide the background and border of the keyboard frame")

    -- Mouse Graphic Setting
    local mouseGraphicSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_MOUSE_GRAPHIC",
        "show_mouse_graphic",
        keyui_settings,
        Settings.VarType.Boolean,
        "Mouse Graphic",
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, mouseGraphicSetting, "Show or hide the graphical representation of the mouse")

    -- Controller Background Setting
    local controllerBgSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_CONTROLLER_BACKGROUND",
        "show_controller_background",
        keyui_settings,
        Settings.VarType.Boolean,
        "Controller Background",
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, controllerBgSetting, "Show or hide the background and border of the controller frame")

    -- Enable ESC Setting (with special handler)
    local function GetEscValue()
        return keyui_settings.close_on_esc
    end

    local function SetEscValue(value)
        keyui_settings.close_on_esc = value

        -- Update ESC behavior for all frames
        local function set_esc_close_enabled(frame, enabled)
            if not frame then return end
            local frame_name = frame:GetName()
            if not frame_name then return end

            for i = #UISpecialFrames, 1, -1 do
                if UISpecialFrames[i] == frame_name then
                    table.remove(UISpecialFrames, i)
                end
            end

            if enabled then
                tinsert(UISpecialFrames, frame_name)
            end
        end

        set_esc_close_enabled(addon.keyboard_frame, value)
        set_esc_close_enabled(addon.controls_frame, value)
        set_esc_close_enabled(addon.mouse_image, value)
        set_esc_close_enabled(addon.mouse_frame, value)
        set_esc_close_enabled(addon.mouse_control_frame, value)

        local status = value and "enabled" or "disabled"
        print("KeyUI: Closing with ESC " .. status)
    end

    local escSetting = Settings.RegisterProxySetting(
        category,
        "KEYUI_ENABLE_ESC",
        Settings.VarType.Boolean,
        "Enable ESC",
        Settings.Default.False,
        GetEscValue,
        SetEscValue
    )
    Settings.CreateCheckbox(category, escSetting, "Enable or disable the addon window closing when pressing ESC")

    -- Profiles Header + Buttons
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Profiles"))

    -- Export Profile Button
    local exportButton = CreateSettingsButtonInitializer(
        "Export Profile",
        "Export Profile",
        function()
            addon:ShowProfileExportPopup()
        end,
        "Copy your current KeyUI configuration as a sharable string",
        true
    )
    layout:AddInitializer(exportButton)

    -- Import Profile Button
    local importButton = CreateSettingsButtonInitializer(
        "Import Profile",
        "Import Profile",
        function()
            addon:ShowProfileImportPopup()
        end,
        "Paste a profile string to apply someone else's configuration",
        true
    )
    layout:AddInitializer(importButton)

    -- Reset Settings Button (with confirmation dialog)
    local resetButton = CreateSettingsButtonInitializer(
        "Full Reset",
        "Full Reset",
        function()
            StaticPopupDialogs["KEYUI_CONFIRM_RESET"] = {
                text = "Are you sure you want to reset ALL KeyUI data (settings, layouts, positions, keybinds) to default?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    addon:ResetAddonSettings()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("KEYUI_CONFIRM_RESET")
        end,
        "Completely resets all KeyUI data: settings, custom layouts, frame positions, and keybind configurations",
        true
    )
    layout:AddInitializer(resetButton)

    -- Register category
    Settings.RegisterAddOnCategory(category)
end

addon.InitializeSettingsPanel = InitializeSettingsPanel
