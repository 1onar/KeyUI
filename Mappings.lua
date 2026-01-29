local name, addon = ...

-- NOTE: addon.binding_mapping was removed — interface bindings are now
-- dynamically enumerated via GetNumBindings() / GetBinding() in Core.lua

-- List of  buttons that should not be modified
addon.no_modifier_keys = {
    ["ESCAPE"] = true,
    ["ESC"] = true,
    ["LSHIFT"] = true,
    ["LCTRL"] = true,
    ["LALT"] = true,
    ["RALT"] = true,
    ["RCTRL"] = true,
    ["RSHIFT"] = true,
    ["LWIN"] = true,
    ["RWIN"] = true,
    ["LMETA"] = true,
    ["RMETA"] = true,
    ["MENU"] = true,
    ["N/A"] = true,
    ["Custom"] = true,
}

-- List of buttons that should not be highlighted when empty
addon.no_highlight = {
    ["ESCAPE"] = true,
    ["CAPS"] = true,
    ["CAPSLOCK"] = true,
    ["LSHIFT"] = true,
    ["LCTRL"] = true,
    ["LALT"] = true,
    ["RALT"] = true,
    ["RCTRL"] = true,
    ["RSHIFT"] = true,
    ["BACKSPACE"] = true,
    ["ENTER"] = true,
    ["NUMPADENTER"] = true,
    ["LWIN"] = true,
    ["RWIN"] = true,
    ["MENU"] = true,
    ["LMETA"] = true,
    ["RMETA"] = true,
    ["N/A"] = true,
    ["Custom"] = true,
}

addon.short_keys = {
    ["CAPSLOCK"] = "Caps",
    ["PRINTSCREEN"] = "Prt Scrn",
    ["SCROLLLOCK"] = "Scr Lk",
    ["INSERT"] = "Ins",
    ["PAGEUP"] = "Pg Up",
    ["PAGEDOWN"] = "Pg Dn",
    ["NUMPAD0"] = "Num0",
    ["NUMPAD1"] = "Num1",
    ["NUMPAD2"] = "Num2",
    ["NUMPAD3"] = "Num3",
    ["NUMPAD4"] = "Num4",
    ["NUMPAD5"] = "Num5",
    ["NUMPAD6"] = "Num6",
    ["NUMPAD7"] = "Num7",
    ["NUMPAD8"] = "Num8",
    ["NUMPAD9"] = "Num9",
    ["NUMLOCK"] = "Num Lk",
    ["NUMPADDIVIDE"] = "/",
    ["NUMPADMULTIPLY"] = "*",
    ["NUMPADMINUS"] = "-",
    ["NUMPADPLUS"] = "+",
    ["NUMPADDECIMAL"] = ".",
    ["ESCAPE"] = "ESC",
    ["LSHIFT"] = "SHIFT",
    ["LCTRL"] = "CTRL",
    ["LALT"] = "ALT",
    ["RSHIFT"] = "SHIFT",
    ["RCTRL"] = "CTRL",
    ["RALT"] = "ALT",
    ["LWIN"] = "WIN",
    ["RWIN"] = "WIN",
    ["LMETA"] = "META",
    ["RMETA"] = "META",
    ["TAB"] = "Tab",
}

addon.action_slot_mapping = {
    --Action Bar 1
    ACTIONBUTTON1 = "1",
    ACTIONBUTTON2 = "2",
    ACTIONBUTTON3 = "3",
    ACTIONBUTTON4 = "4",
    ACTIONBUTTON5 = "5",
    ACTIONBUTTON6 = "6",
    ACTIONBUTTON7 = "7",
    ACTIONBUTTON8 = "8",
    ACTIONBUTTON9 = "9",
    ACTIONBUTTON10 = "10",
    ACTIONBUTTON11 = "11",
    ACTIONBUTTON12 = "12",

    --Action Bar 2
    MULTIACTIONBAR1BUTTON1 = "61",
    MULTIACTIONBAR1BUTTON2 = "62",
    MULTIACTIONBAR1BUTTON3 = "63",
    MULTIACTIONBAR1BUTTON4 = "64",
    MULTIACTIONBAR1BUTTON5 = "65",
    MULTIACTIONBAR1BUTTON6 = "66",
    MULTIACTIONBAR1BUTTON7 = "67",
    MULTIACTIONBAR1BUTTON8 = "68",
    MULTIACTIONBAR1BUTTON9 = "69",
    MULTIACTIONBAR1BUTTON10 = "70",
    MULTIACTIONBAR1BUTTON11 = "71",
    MULTIACTIONBAR1BUTTON12 = "72",

    --Action Bar 3
    MULTIACTIONBAR2BUTTON1 = "49",
    MULTIACTIONBAR2BUTTON2 = "50",
    MULTIACTIONBAR2BUTTON3 = "51",
    MULTIACTIONBAR2BUTTON4 = "52",
    MULTIACTIONBAR2BUTTON5 = "53",
    MULTIACTIONBAR2BUTTON6 = "54",
    MULTIACTIONBAR2BUTTON7 = "55",
    MULTIACTIONBAR2BUTTON8 = "56",
    MULTIACTIONBAR2BUTTON9 = "57",
    MULTIACTIONBAR2BUTTON10 = "58",
    MULTIACTIONBAR2BUTTON11 = "59",
    MULTIACTIONBAR2BUTTON12 = "60",

    --Action Bar 4
    MULTIACTIONBAR3BUTTON1 = "25",
    MULTIACTIONBAR3BUTTON2 = "26",
    MULTIACTIONBAR3BUTTON3 = "27",
    MULTIACTIONBAR3BUTTON4 = "28",
    MULTIACTIONBAR3BUTTON5 = "29",
    MULTIACTIONBAR3BUTTON6 = "30",
    MULTIACTIONBAR3BUTTON7 = "31",
    MULTIACTIONBAR3BUTTON8 = "32",
    MULTIACTIONBAR3BUTTON9 = "33",
    MULTIACTIONBAR3BUTTON10 = "34",
    MULTIACTIONBAR3BUTTON11 = "35",
    MULTIACTIONBAR3BUTTON12 = "36",

    --Action Bar 5
    MULTIACTIONBAR4BUTTON1 = "37",
    MULTIACTIONBAR4BUTTON2 = "38",
    MULTIACTIONBAR4BUTTON3 = "39",
    MULTIACTIONBAR4BUTTON4 = "40",
    MULTIACTIONBAR4BUTTON5 = "41",
    MULTIACTIONBAR4BUTTON6 = "42",
    MULTIACTIONBAR4BUTTON7 = "43",
    MULTIACTIONBAR4BUTTON8 = "44",
    MULTIACTIONBAR4BUTTON9 = "45",
    MULTIACTIONBAR4BUTTON10 = "46",
    MULTIACTIONBAR4BUTTON11 = "47",
    MULTIACTIONBAR4BUTTON12 = "48",

    --Action Bar 6
    MULTIACTIONBAR5BUTTON1 = "145",
    MULTIACTIONBAR5BUTTON2 = "146",
    MULTIACTIONBAR5BUTTON3 = "147",
    MULTIACTIONBAR5BUTTON4 = "148",
    MULTIACTIONBAR5BUTTON5 = "149",
    MULTIACTIONBAR5BUTTON6 = "150",
    MULTIACTIONBAR5BUTTON7 = "151",
    MULTIACTIONBAR5BUTTON8 = "152",
    MULTIACTIONBAR5BUTTON9 = "153",
    MULTIACTIONBAR5BUTTON10 = "154",
    MULTIACTIONBAR5BUTTON11 = "155",
    MULTIACTIONBAR5BUTTON12 = "156",

    --Action Bar 7
    MULTIACTIONBAR6BUTTON1 = "157",
    MULTIACTIONBAR6BUTTON2 = "158",
    MULTIACTIONBAR6BUTTON3 = "159",
    MULTIACTIONBAR6BUTTON4 = "160",
    MULTIACTIONBAR6BUTTON5 = "161",
    MULTIACTIONBAR6BUTTON6 = "162",
    MULTIACTIONBAR6BUTTON7 = "163",
    MULTIACTIONBAR6BUTTON8 = "164",
    MULTIACTIONBAR6BUTTON9 = "165",
    MULTIACTIONBAR6BUTTON10 = "166",
    MULTIACTIONBAR6BUTTON11 = "167",
    MULTIACTIONBAR6BUTTON12 = "168",

    --Action Bar 8
    MULTIACTIONBAR7BUTTON1 = "169",
    MULTIACTIONBAR7BUTTON2 = "170",
    MULTIACTIONBAR7BUTTON3 = "171",
    MULTIACTIONBAR7BUTTON4 = "172",
    MULTIACTIONBAR7BUTTON5 = "173",
    MULTIACTIONBAR7BUTTON6 = "174",
    MULTIACTIONBAR7BUTTON7 = "175",
    MULTIACTIONBAR7BUTTON8 = "176",
    MULTIACTIONBAR7BUTTON9 = "177",
    MULTIACTIONBAR7BUTTON10 = "178",
    MULTIACTIONBAR7BUTTON11 = "179",
    MULTIACTIONBAR7BUTTON12 = "180",
}

addon.button_texture_mapping = {
    -- Action Bar 1 Page 1
    ["1"] = ActionButton1,
    ["2"] = ActionButton2,
    ["3"] = ActionButton3,
    ["4"] = ActionButton4,
    ["5"] = ActionButton5,
    ["6"] = ActionButton6,
    ["7"] = ActionButton7,
    ["8"] = ActionButton8,
    ["9"] = ActionButton9,
    ["10"] = ActionButton10,
    ["11"] = ActionButton11,
    ["12"] = ActionButton12,

    -- Action Bar 1 Page 2
    ["13"] = ActionButton1,
    ["14"] = ActionButton2,
    ["15"] = ActionButton3,
    ["16"] = ActionButton4,
    ["17"] = ActionButton5,
    ["18"] = ActionButton6,
    ["19"] = ActionButton7,
    ["20"] = ActionButton8,
    ["21"] = ActionButton9,
    ["22"] = ActionButton10,
    ["23"] = ActionButton11,
    ["24"] = ActionButton12,

    -- Bonus Bar 1
    ["73"] = ActionButton1,
    ["74"] = ActionButton2,
    ["75"] = ActionButton3,
    ["76"] = ActionButton4,
    ["77"] = ActionButton5,
    ["78"] = ActionButton6,
    ["79"] = ActionButton7,
    ["80"] = ActionButton8,
    ["81"] = ActionButton9,
    ["82"] = ActionButton10,
    ["83"] = ActionButton11,
    ["84"] = ActionButton12,

    -- Bonus Bar 3
    ["97"] = ActionButton1,
    ["98"] = ActionButton2,
    ["99"] = ActionButton3,
    ["100"] = ActionButton4,
    ["101"] = ActionButton5,
    ["102"] = ActionButton6,
    ["103"] = ActionButton7,
    ["104"] = ActionButton8,
    ["105"] = ActionButton9,
    ["106"] = ActionButton10,
    ["107"] = ActionButton11,
    ["108"] = ActionButton12,

    -- Bonus Bar 4
    ["109"] = ActionButton1,
    ["110"] = ActionButton2,
    ["111"] = ActionButton3,
    ["112"] = ActionButton4,
    ["113"] = ActionButton5,
    ["114"] = ActionButton6,
    ["115"] = ActionButton7,
    ["116"] = ActionButton8,
    ["117"] = ActionButton9,
    ["118"] = ActionButton10,
    ["119"] = ActionButton11,
    ["120"] = ActionButton12,

    -- Action Bar 2
    ["61"] = MultiBarBottomLeftButton1,
    ["62"] = MultiBarBottomLeftButton2,
    ["63"] = MultiBarBottomLeftButton3,
    ["64"] = MultiBarBottomLeftButton4,
    ["65"] = MultiBarBottomLeftButton5,
    ["66"] = MultiBarBottomLeftButton6,
    ["67"] = MultiBarBottomLeftButton7,
    ["68"] = MultiBarBottomLeftButton8,
    ["69"] = MultiBarBottomLeftButton9,
    ["70"] = MultiBarBottomLeftButton10,
    ["71"] = MultiBarBottomLeftButton11,
    ["72"] = MultiBarBottomLeftButton12,

    -- Action Bar 3
    ["49"] = MultiBarBottomRightButton1,
    ["50"] = MultiBarBottomRightButton2,
    ["51"] = MultiBarBottomRightButton3,
    ["52"] = MultiBarBottomRightButton4,
    ["53"] = MultiBarBottomRightButton5,
    ["54"] = MultiBarBottomRightButton6,
    ["55"] = MultiBarBottomRightButton7,
    ["56"] = MultiBarBottomRightButton8,
    ["57"] = MultiBarBottomRightButton9,
    ["58"] = MultiBarBottomRightButton10,
    ["59"] = MultiBarBottomRightButton11,
    ["60"] = MultiBarBottomRightButton12,

    -- Action Bar 4
    ["25"] = MultiBarRightButton1,
    ["26"] = MultiBarRightButton2,
    ["27"] = MultiBarRightButton3,
    ["28"] = MultiBarRightButton4,
    ["29"] = MultiBarRightButton5,
    ["30"] = MultiBarRightButton6,
    ["31"] = MultiBarRightButton7,
    ["32"] = MultiBarRightButton8,
    ["33"] = MultiBarRightButton9,
    ["34"] = MultiBarRightButton10,
    ["35"] = MultiBarRightButton11,
    ["36"] = MultiBarRightButton12,

    -- Action Bar 5
    ["37"] = MultiBarLeftButton1,
    ["38"] = MultiBarLeftButton2,
    ["39"] = MultiBarLeftButton3,
    ["40"] = MultiBarLeftButton4,
    ["41"] = MultiBarLeftButton5,
    ["42"] = MultiBarLeftButton6,
    ["43"] = MultiBarLeftButton7,
    ["44"] = MultiBarLeftButton8,
    ["45"] = MultiBarLeftButton9,
    ["46"] = MultiBarLeftButton10,
    ["47"] = MultiBarLeftButton11,
    ["48"] = MultiBarLeftButton12,

    -- Action Bar 6
    ["145"] = MultiBar5Button1,
    ["146"] = MultiBar5Button2,
    ["147"] = MultiBar5Button3,
    ["148"] = MultiBar5Button4,
    ["149"] = MultiBar5Button5,
    ["150"] = MultiBar5Button6,
    ["151"] = MultiBar5Button7,
    ["152"] = MultiBar5Button8,
    ["153"] = MultiBar5Button9,
    ["154"] = MultiBar5Button10,
    ["155"] = MultiBar5Button11,
    ["156"] = MultiBar5Button12,

    -- Action Bar 7
    ["157"] = MultiBar6Button1,
    ["158"] = MultiBar6Button2,
    ["159"] = MultiBar6Button3,
    ["160"] = MultiBar6Button4,
    ["161"] = MultiBar6Button5,
    ["162"] = MultiBar6Button6,
    ["163"] = MultiBar6Button7,
    ["164"] = MultiBar6Button8,
    ["165"] = MultiBar6Button9,
    ["166"] = MultiBar6Button10,
    ["167"] = MultiBar6Button11,
    ["168"] = MultiBar6Button12,

    -- Action Bar 8
    ["169"] = MultiBar7Button1,
    ["170"] = MultiBar7Button2,
    ["171"] = MultiBar7Button3,
    ["172"] = MultiBar7Button4,
    ["173"] = MultiBar7Button5,
    ["174"] = MultiBar7Button6,
    ["175"] = MultiBar7Button7,
    ["176"] = MultiBar7Button8,
    ["177"] = MultiBar7Button9,
    ["178"] = MultiBar7Button10,
    ["179"] = MultiBar7Button11,
    ["180"] = MultiBar7Button12,

    -- Dragonriding
    ["121"] = ActionButton1,
    ["122"] = ActionButton2,
    ["123"] = ActionButton3,
    ["124"] = ActionButton4,
    ["125"] = ActionButton5,
    ["126"] = ActionButton6,
    ["127"] = ActionButton7,
    ["128"] = ActionButton8,
    ["129"] = ActionButton9,
    ["130"] = ActionButton10,
    ["131"] = ActionButton11,
    ["132"] = ActionButton12,
}

-- List of gamepad buttons
addon.gamepad_buttons = {
    ["PADDUP"] = true,
    ["PADDRIGHT"] = true,
    ["PADDDOWN"] = true,
    ["PADDLEFT"] = true,
    ["PAD1"] = true,
    ["PAD2"] = true,
    ["PAD3"] = true,
    ["PAD4"] = true,
    ["PAD5"] = true,
    ["PAD6"] = true,
    ["PADLSHOULDER"] = true,
    ["PADLTRIGGER"] = true,
    ["PADRSHOULDER"] = true,
    ["PADRTRIGGER"] = true,
    ["PADLSTICK"] = true,
    ["PADRSTICK"] = true,
    ["PADLSTICKUP"] = true,
    ["PADLSTICKRIGHT"] = true,
    ["PADLSTICKDOWN"] = true,
    ["PADLSTICKLEFT"] = true,
    ["PADRSTICKUP"] = true,
    ["PADRSTICKRIGHT"] = true,
    ["PADRSTICKDOWN"] = true,
    ["PADRSTICKLEFT"] = true,
    ["PADPADDLE1"] = true,
    ["PADPADDLE2"] = true,
    ["PADPADDLE3"] = true,
    ["PADPADDLE4"] = true,
    ["PADFORWARD"] = true,
    ["PADBACK"] = true,
    ["PADSYSTEM"] = true,
    ["PADSOCIAL"] = true,
}

-- Playstation Button Icons
addon.playstation_buttons = {
    -- D-Pad buttons
    ["PADDUP"]        = "Gamepad_Shp_Up_64",        -- D-Pad Up
    ["PADDRIGHT"]     = "Gamepad_Shp_Right_64",     -- D-Pad Right
    ["PADDDOWN"]      = "Gamepad_Shp_Down_64",      -- D-Pad Down
    ["PADDLEFT"]      = "Gamepad_Shp_Left_64",      -- D-Pad Left

    -- Face buttons
    ["PAD1"]          = "Gamepad_Shp_Cross_64",     -- Cross button
    ["PAD2"]          = "Gamepad_Shp_Circle_64",    -- Circle button
    ["PAD3"]          = "Gamepad_Shp_Square_64",    -- Square button
    ["PAD4"]          = "Gamepad_Shp_Triangle_64",  -- Triangle button

    -- Additional buttons
    ["PAD5"]          = "Gamepad_Shp_MicMute_64",   -- Mic Mute button
    ["PAD6"]          = "Gamepad_Shp_TouchpadR_64", -- Right side of the touchpad

    -- Shoulder and trigger buttons
    ["PADLSHOULDER"]  = "Gamepad_Shp_LShoulder_64", -- L1 (Left shoulder)
    ["PADLTRIGGER"]   = "Gamepad_Shp_LTrigger_64",  -- L2 (Left trigger)
    ["PADRSHOULDER"]  = "Gamepad_Shp_RShoulder_64", -- R1 (Right shoulder)
    ["PADRTRIGGER"]   = "Gamepad_Shp_RTrigger_64",  -- R2 (Right trigger)

    -- Stick buttons
    ["PADLSTICK"]     = "Gamepad_Shp_LStickIn_64",  -- Left stick (press)
    ["PADRSTICK"]     = "Gamepad_Shp_RStickIn_64",  -- Right stick (press)

    -- System and menu buttons
    ["PADBACK"]       = "Gamepad_Shp_TouchpadL_64", -- Left side of the touchpad
    ["PADFORWARD"]    = "Gamepad_Shp_Menu_64",      -- Menu button
    ["PADSYSTEM"]     = "Gamepad_Shp_System_64",    -- PlayStation button (system button)
    ["PADSOCIAL"]     = "Gamepad_Shp_Share_64",     -- Share button
}

-- Xbox Button Icons
addon.xbox_buttons = {
    -- D-Pad buttons
    ["PADDUP"]        = "Gamepad_Ltr_Up_64",        -- D-Pad Up
    ["PADDRIGHT"]     = "Gamepad_Ltr_Right_64",     -- D-Pad Right
    ["PADDDOWN"]      = "Gamepad_Ltr_Down_64",      -- D-Pad Down
    ["PADDLEFT"]      = "Gamepad_Ltr_Left_64",      -- D-Pad Left

    -- Face buttons
    ["PAD1"]          = "Gamepad_Ltr_A_64",         -- A button
    ["PAD2"]          = "Gamepad_Ltr_B_64",         -- B button
    ["PAD3"]          = "Gamepad_Ltr_X_64",         -- X button
    ["PAD4"]          = "Gamepad_Ltr_Y_64",         -- Y button

    -- Shoulder and trigger buttons
    ["PADLSHOULDER"]  = "Gamepad_Ltr_LShoulder_64", -- Left Shoulder (LB)
    ["PADLTRIGGER"]   = "Gamepad_Ltr_LTrigger_64",  -- Left Trigger (LT)
    ["PADRSHOULDER"]  = "Gamepad_Ltr_RShoulder_64", -- Right Shoulder (RB)
    ["PADRTRIGGER"]   = "Gamepad_Ltr_RTrigger_64",  -- Right Trigger (RT)

    -- Stick buttons
    ["PADLSTICK"]     = "Gamepad_Gen_LStickIn_64",  -- Left stick (press)
    ["PADRSTICK"]     = "Gamepad_Gen_RStickIn_64",  -- Right stick (press)

    -- System and menu buttons
    ["PADBACK"]       = "Gamepad_Ltr_View_64",      -- View button (Back)
    ["PADFORWARD"]    = "Gamepad_Ltr_Menu_64",      -- Menu button (Start)
    ["PADSYSTEM"]     = "Gamepad_Ltr_System_64",    -- Xbox button (System button)
}

-- Steam Deck Button Icons
addon.deck_buttons = {
    -- D-Pad buttons
    ["PADDUP"]        = "Gamepad_Ltr_Up_64",        -- D-Pad Up
    ["PADDRIGHT"]     = "Gamepad_Ltr_Right_64",     -- D-Pad Right
    ["PADDDOWN"]      = "Gamepad_Ltr_Down_64",      -- D-Pad Down
    ["PADDLEFT"]      = "Gamepad_Ltr_Left_64",      -- D-Pad Left

    -- Face buttons
    ["PAD1"]          = "Gamepad_Ltr_A_64",         -- A button
    ["PAD2"]          = "Gamepad_Ltr_B_64",         -- B button
    ["PAD3"]          = "Gamepad_Ltr_X_64",         -- X button
    ["PAD4"]          = "Gamepad_Ltr_Y_64",         -- Y button

    -- Shoulder and trigger buttons
    ["PADLSHOULDER"]  = "Gamepad_Ltr_LShoulder_64", -- Left Shoulder button (L1)
    ["PADLTRIGGER"]   = "Gamepad_Ltr_LTrigger_64",  -- Left Trigger button (L2)
    ["PADRSHOULDER"]  = "Gamepad_Ltr_RShoulder_64", -- Right Shoulder button (R1)
    ["PADRTRIGGER"]   = "Gamepad_Ltr_RTrigger_64",  -- Right Trigger button (R2)

    -- Stick buttons
    ["PADLSTICK"]     = "Gamepad_Gen_LStickIn_64",  -- Left Stick (press)
    ["PADRSTICK"]     = "Gamepad_Gen_RStickIn_64",  -- Right Stick (press)

    -- System and menu buttons
    ["PADBACK"]       = "Gamepad_Ltr_View_64",      -- View button
    ["PADFORWARD"]    = "Gamepad_Ltr_Menu_64",      -- Menu button

    -- Rear paddle buttons
    ["PADPADDLE1"]    = "Gamepad_Gen_Paddle1_64",   -- Rear Paddle 1 (L4)
    ["PADPADDLE2"]    = "Gamepad_Gen_Paddle2_64",   -- Rear Paddle 2 (L5)
    ["PADPADDLE3"]    = "Gamepad_Gen_Paddle3_64",   -- Rear Paddle 3 (R4)
    ["PADPADDLE4"]    = "Gamepad_Gen_Paddle4_64",   -- Rear Paddle 4 (R5)
}