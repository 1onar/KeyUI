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

    -- Show Keyboard Setting
    local showKeyboardSetting = Settings.RegisterAddOnSetting(
        category,
        "KEYUI_SHOW_KEYBOARD",
        "show_keyboard",
        keyui_settings,
        Settings.VarType.Boolean,
        "Show Keyboard",
        Settings.Default.False
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
        Settings.Default.False
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

    -- Font Header + Settings
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Font"))

    -- Font Face Dropdown
    local function GetFontFace()
        return keyui_settings.font_face
    end

    local function SetFontFace(value)
        keyui_settings.font_face = value
        addon:RefreshAllFonts()
    end

    local function GetFontFaceOptions()
        local container = Settings.CreateControlTextContainer()
        for _, fontName in ipairs(addon.FONT_OPTIONS_ORDER) do
            container:Add(fontName, fontName)
        end
        return container:GetData()
    end

    local fontFaceSetting = Settings.RegisterProxySetting(
        category,
        "KEYUI_FONT_FACE",
        Settings.VarType.String,
        "Font",
        "Expressway",
        GetFontFace,
        SetFontFace
    )
    Settings.CreateDropdown(category, fontFaceSetting, GetFontFaceOptions, "Select the font used throughout KeyUI")

    -- Font Base Size Slider
    local function GetFontSize()
        return keyui_settings.font_base_size
    end

    local function SetFontSize(value)
        keyui_settings.font_base_size = value
        addon:RefreshAllFonts()
    end

    local fontSizeSetting = Settings.RegisterProxySetting(
        category,
        "KEYUI_FONT_SIZE",
        Settings.VarType.Number,
        "Font Size",
        16,
        GetFontSize,
        SetFontSize
    )

    local fontSizeOptions = Settings.CreateSliderOptions(10, 24, 1)
    fontSizeOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    Settings.CreateSlider(category, fontSizeSetting, fontSizeOptions, "Adjust the base font size for all KeyUI text")

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
