local name, addon = ...

addon.action_mapping = {

    ["Movement Keys"] = {
        { "Move and Steer",         "MOVEANDSTEER" },
        { "Move Forward",           "MOVEFORWARD" },
        { "Move Backward",          "MOVEBACKWARD" },
        { "Turn Left",              "TURNLEFT" },
        { "Turn Right",             "TURNRIGHT" },
        { "Strafe Left",            "STRAFELEFT" },
        { "Strafe Right",           "STRAFERIGHT" },
        { "Jump",                   "JUMP" },
        { "Sit/Move Down",          "SITORSTAND" },
        { "Sheath/Unsheath Weapon", "TOGGLESHEATH" },
        { "Toggle Autorun",         "TOGGLEAUTORUN" },
        { "Start Autorun",          "STARTAUTORUN" },
        { "Stop Autorun",           "STOPAUTORUN" },
        { "Pitch Up",               "PITCHUP" },
        { "Pitch Down",             "PITCHDOWN" },
        { "Toggle Run/Walk",        "TOGGLERUN" },
        { "Follow Target",          "FOLLOWTARGET" },
    },

    ["Action Bar"] = {
        { "Action Button 1",          "ACTIONBUTTON1" },
        { "Action Button 2",          "ACTIONBUTTON2" },
        { "Action Button 3",          "ACTIONBUTTON3" },
        { "Action Button 4",          "ACTIONBUTTON4" },
        { "Action Button 5",          "ACTIONBUTTON5" },
        { "Action Button 6",          "ACTIONBUTTON6" },
        { "Action Button 7",          "ACTIONBUTTON7" },
        { "Action Button 8",          "ACTIONBUTTON8" },
        { "Action Button 9",          "ACTIONBUTTON9" },
        { "Action Button 10",         "ACTIONBUTTON10" },
        { "Action Button 11",         "ACTIONBUTTON11" },
        { "Action Button 12",         "ACTIONBUTTON12" },
        { "Extra Action Button 1",    "EXTRAACTIONBUTTON1" },
        { "Pet Action Button 1",      "BONUSACTIONBUTTON1" },
        { "Pet Action Button 2",      "BONUSACTIONBUTTON2" },
        { "Pet Action Button 3",      "BONUSACTIONBUTTON3" },
        { "Pet Action Button 4",      "BONUSACTIONBUTTON4" },
        { "Pet Action Button 5",      "BONUSACTIONBUTTON5" },
        { "Pet Action Button 6",      "BONUSACTIONBUTTON6" },
        { "Pet Action Button 7",      "BONUSACTIONBUTTON7" },
        { "Pet Action Button 8",      "BONUSACTIONBUTTON8" },
        { "Pet Action Button 9",      "BONUSACTIONBUTTON9" },
        { "Pet Action Button 10",     "BONUSACTIONBUTTON10" },
        { "Action Page 1",            "ACTIONPAGE1" },
        { "Action Page 2",            "ACTIONPAGE2" },
        { "Action Page 3",            "ACTIONPAGE3" },
        { "Action Page 4",            "ACTIONPAGE4" },
        { "Action Page 5",            "ACTIONPAGE5" },
        { "Action Page 6",            "ACTIONPAGE6" },
        { "Previous Action Bar",      "PREVIOUSACTIONPAGE" },
        { "Next Action Bar",          "NEXTACTIONPAGE" },
        { "Toggle Action Bar Lock",   "TOGGLEACTIONBARLOCK" },
        { "Toggle Self Cast",         "TOGGLEAUTOSELFCAST" },
        { "Special Action Button 1",  "SHAPESHIFTBUTTON1" },
        { "Special Action Button 2",  "SHAPESHIFTBUTTON2" },
        { "Special Action Button 3",  "SHAPESHIFTBUTTON3" },
        { "Special Action Button 4",  "SHAPESHIFTBUTTON4" },
        { "Special Action Button 5",  "SHAPESHIFTBUTTON5" },
        { "Special Action Button 6",  "SHAPESHIFTBUTTON6" },
        { "Special Action Button 7",  "SHAPESHIFTBUTTON7" },
        { "Special Action Button 8",  "SHAPESHIFTBUTTON8" },
        { "Special Action Button 9",  "SHAPESHIFTBUTTON9" },
        { "Special Action Button 10", "SHAPESHIFTBUTTON10" },
    },

    ["Action Bar 2"] = {
        { "Action Bar 2 Button 1",  "MULTIACTIONBAR1BUTTON1" },
        { "Action Bar 2 Button 2",  "MULTIACTIONBAR1BUTTON2" },
        { "Action Bar 2 Button 3",  "MULTIACTIONBAR1BUTTON3" },
        { "Action Bar 2 Button 4",  "MULTIACTIONBAR1BUTTON4" },
        { "Action Bar 2 Button 5",  "MULTIACTIONBAR1BUTTON5" },
        { "Action Bar 2 Button 6",  "MULTIACTIONBAR1BUTTON6" },
        { "Action Bar 2 Button 7",  "MULTIACTIONBAR1BUTTON7" },
        { "Action Bar 2 Button 8",  "MULTIACTIONBAR1BUTTON8" },
        { "Action Bar 2 Button 9",  "MULTIACTIONBAR1BUTTON9" },
        { "Action Bar 2 Button 10", "MULTIACTIONBAR1BUTTON10" },
        { "Action Bar 2 Button 11", "MULTIACTIONBAR1BUTTON11" },
        { "Action Bar 2 Button 12", "MULTIACTIONBAR1BUTTON12" },
    },

    ["Action Bar 3"] = {
        { "Action Bar 3 Button 1",  "MULTIACTIONBAR2BUTTON1" },
        { "Action Bar 3 Button 2",  "MULTIACTIONBAR2BUTTON2" },
        { "Action Bar 3 Button 3",  "MULTIACTIONBAR2BUTTON3" },
        { "Action Bar 3 Button 4",  "MULTIACTIONBAR2BUTTON4" },
        { "Action Bar 3 Button 5",  "MULTIACTIONBAR2BUTTON5" },
        { "Action Bar 3 Button 6",  "MULTIACTIONBAR2BUTTON6" },
        { "Action Bar 3 Button 7",  "MULTIACTIONBAR2BUTTON7" },
        { "Action Bar 3 Button 8",  "MULTIACTIONBAR2BUTTON8" },
        { "Action Bar 3 Button 9",  "MULTIACTIONBAR2BUTTON9" },
        { "Action Bar 3 Button 10", "MULTIACTIONBAR2BUTTON10" },
        { "Action Bar 3 Button 11", "MULTIACTIONBAR2BUTTON11" },
        { "Action Bar 3 Button 12", "MULTIACTIONBAR2BUTTON12" },
    },

    ["Action Bar 4"] = {
        { "Action Bar 4 Button 1",  "MULTIACTIONBAR3BUTTON1" },
        { "Action Bar 4 Button 2",  "MULTIACTIONBAR3BUTTON2" },
        { "Action Bar 4 Button 3",  "MULTIACTIONBAR3BUTTON3" },
        { "Action Bar 4 Button 4",  "MULTIACTIONBAR3BUTTON4" },
        { "Action Bar 4 Button 5",  "MULTIACTIONBAR3BUTTON5" },
        { "Action Bar 4 Button 6",  "MULTIACTIONBAR3BUTTON6" },
        { "Action Bar 4 Button 7",  "MULTIACTIONBAR3BUTTON7" },
        { "Action Bar 4 Button 8",  "MULTIACTIONBAR3BUTTON8" },
        { "Action Bar 4 Button 9",  "MULTIACTIONBAR3BUTTON9" },
        { "Action Bar 4 Button 10", "MULTIACTIONBAR3BUTTON10" },
        { "Action Bar 4 Button 11", "MULTIACTIONBAR3BUTTON11" },
        { "Action Bar 4 Button 12", "MULTIACTIONBAR3BUTTON12" },
    },

    ["Action Bar 5"] = {
        { "Action Bar 5 Button 1",  "MULTIACTIONBAR4BUTTON1" },
        { "Action Bar 5 Button 2",  "MULTIACTIONBAR4BUTTON2" },
        { "Action Bar 5 Button 3",  "MULTIACTIONBAR4BUTTON3" },
        { "Action Bar 5 Button 4",  "MULTIACTIONBAR4BUTTON4" },
        { "Action Bar 5 Button 5",  "MULTIACTIONBAR4BUTTON5" },
        { "Action Bar 5 Button 6",  "MULTIACTIONBAR4BUTTON6" },
        { "Action Bar 5 Button 7",  "MULTIACTIONBAR4BUTTON7" },
        { "Action Bar 5 Button 8",  "MULTIACTIONBAR4BUTTON8" },
        { "Action Bar 5 Button 9",  "MULTIACTIONBAR4BUTTON9" },
        { "Action Bar 5 Button 10", "MULTIACTIONBAR4BUTTON10" },
        { "Action Bar 5 Button 11", "MULTIACTIONBAR4BUTTON11" },
        { "Action Bar 5 Button 12", "MULTIACTIONBAR4BUTTON12" },
    },

    ["Action Bar 6"] = {
        { "Action Bar 6 Button 1",  "MULTIACTIONBAR5BUTTON1" },
        { "Action Bar 6 Button 2",  "MULTIACTIONBAR5BUTTON2" },
        { "Action Bar 6 Button 3",  "MULTIACTIONBAR5BUTTON3" },
        { "Action Bar 6 Button 4",  "MULTIACTIONBAR5BUTTON4" },
        { "Action Bar 6 Button 5",  "MULTIACTIONBAR5BUTTON5" },
        { "Action Bar 6 Button 6",  "MULTIACTIONBAR5BUTTON6" },
        { "Action Bar 6 Button 7",  "MULTIACTIONBAR5BUTTON7" },
        { "Action Bar 6 Button 8",  "MULTIACTIONBAR5BUTTON8" },
        { "Action Bar 6 Button 9",  "MULTIACTIONBAR5BUTTON9" },
        { "Action Bar 6 Button 10", "MULTIACTIONBAR5BUTTON10" },
        { "Action Bar 6 Button 11", "MULTIACTIONBAR5BUTTON11" },
        { "Action Bar 6 Button 12", "MULTIACTIONBAR5BUTTON12" },
    },

    ["Action Bar 7"] = {
        { "Action Bar 7 Button 1",  "MULTIACTIONBAR6BUTTON1" },
        { "Action Bar 7 Button 2",  "MULTIACTIONBAR6BUTTON2" },
        { "Action Bar 7 Button 3",  "MULTIACTIONBAR6BUTTON3" },
        { "Action Bar 7 Button 4",  "MULTIACTIONBAR6BUTTON4" },
        { "Action Bar 7 Button 5",  "MULTIACTIONBAR6BUTTON5" },
        { "Action Bar 7 Button 6",  "MULTIACTIONBAR6BUTTON6" },
        { "Action Bar 7 Button 7",  "MULTIACTIONBAR6BUTTON7" },
        { "Action Bar 7 Button 8",  "MULTIACTIONBAR6BUTTON8" },
        { "Action Bar 7 Button 9",  "MULTIACTIONBAR6BUTTON9" },
        { "Action Bar 7 Button 10", "MULTIACTIONBAR6BUTTON10" },
        { "Action Bar 7 Button 11", "MULTIACTIONBAR6BUTTON11" },
        { "Action Bar 7 Button 12", "MULTIACTIONBAR6BUTTON12" },
    },

    ["Action Bar 8"] = {
        { "Action Bar 8 Button 1",  "MULTIACTIONBAR7BUTTON1" },
        { "Action Bar 8 Button 2",  "MULTIACTIONBAR7BUTTON2" },
        { "Action Bar 8 Button 3",  "MULTIACTIONBAR7BUTTON3" },
        { "Action Bar 8 Button 4",  "MULTIACTIONBAR7BUTTON4" },
        { "Action Bar 8 Button 5",  "MULTIACTIONBAR7BUTTON5" },
        { "Action Bar 8 Button 6",  "MULTIACTIONBAR7BUTTON6" },
        { "Action Bar 8 Button 7",  "MULTIACTIONBAR7BUTTON7" },
        { "Action Bar 8 Button 8",  "MULTIACTIONBAR7BUTTON8" },
        { "Action Bar 8 Button 9",  "MULTIACTIONBAR7BUTTON9" },
        { "Action Bar 8 Button 10", "MULTIACTIONBAR7BUTTON10" },
        { "Action Bar 8 Button 11", "MULTIACTIONBAR7BUTTON11" },
        { "Action Bar 8 Button 12", "MULTIACTIONBAR7BUTTON12" },
    },

    ["Interface Panel"] = {
        { "Toggle Game Menu",             "TOGGLEGAMEMENU" },
        { "Toggle Backpack",              "TOGGLEBACKPACK" },
        { "Toggle Reagent Bag",           "TOGGLEREAGENTBAG1" },
        { "Toggle Bag 1",                 "TOGGLEBAG1" },
        { "Toggle Bag 2",                 "TOGGLEBAG2" },
        { "Toggle Bag 3",                 "TOGGLEBAG3" },
        { "Toggle Bag 4",                 "TOGGLEBAG4" },
        { "Open All Bags",                "OPENALLBAGS" },
        { "Toggle Character Pane",        "TOGGLECHARACTER0" },
        { "Toggle Reputation Pane",       "TOGGLECHARACTER2" },
        { "Toggle Currency Frame",        "TOGGLECURRENCY" },
        { "Toggle Spellbook",             "TOGGLESPELLBOOK" },
        { "Toggle Profession Book",       "TOGGLEPROFESSIONBOOK" },
        { "Toggle Pet Book",              "TOGGLEPETBOOK" },
        { "Toggle Talent Pane",           "TOGGLETALENTS" },
        { "Toggle Achievement Frame",     "TOGGLEACHIEVEMENT" },
        { "Toggle Statistics Frame",      "TOGGLESTATISTICS" },
        { "Toggle Quest Log",             "TOGGLEQUESTLOG" },
        { "Toggle World Map Pane",        "TOGGLEWORLDMAP" },
        { "Toggle World Map Size",        "TOGGLEWORLDMAPSIZE" },
        { "Toggle Minimap",               "TOGGLEMINIMAP" },
        { "Toggle Zone Map",              "TOGGLEBATTLEFIELDMINIMAP" },
        { "Toggle Score Screen",          "TOGGLEWORLDSTATESCORES" },
        { "Toggle Guild Pane",            "TOGGLEGUILDTAB" },
        { "Toggle Social Pane",           "TOGGLESOCIAL" },
        { "Toggle Friends Pane",          "TOGGLEFRIENDSTAB" },
        { "Toggle Quick Join",            "TOGGLEQUICKJOINTAB" },
        { "Toggle Who Pane",              "TOGGLEWHOTAB" },
        { "Toggle Chat Pane",             "TOGGLECHATTAB" },
        { "Toggle Raid Pane",             "TOGGLERAIDTAB" },
        { "Toggle Text To Speech Config", "TOGGLETEXTTOSPEECH" },
        { "Toggle Group Finder",          "TOGGLEGROUPFINDER" },
        { "Toggle Dungeons & Raids",      "TOGGLEDUNGEONSANDRAIDS" },
        { "Toggle PVP Pane",              "TOGGLECHARACTER4" },
        { "Toggle Collections",           "TOGGLECOLLECTIONS" },
        { "Toggle Mount Journal",         "TOGGLECOLLECTIONSMOUNTJOURNAL" },
        { "Toggle Pet Journal",           "TOGGLECOLLECTIONSPETJOURNAL" },
        { "Toggle Toy Box",               "TOGGLECOLLECTIONSTOYBOX" },
        { "Toggle Heirlooms Pane",        "TOGGLECOLLECTIONSHEIRLOOM" },
        { "Toggle Appearances",           "TOGGLECOLLECTIONSWARDROBE" },
        { "Toggle Adventure Guide",       "TOGGLEENCOUNTERJOURNAL" },
        { "Toggle Garrison Report",       "TOGGLEGARRISONLANDINGPAGE" },
    },

    ["Chat"] = {
        { "Open Chat",                      "OPENCHAT" },
        { "Open Chat Slash",                "OPENCHATSLASH" },
        { "Chat Page Up",                   "CHATPAGEUP" },
        { "Chat Page Down",                 "CHATPAGEDOWN" },
        { "Chat Bottom",                    "CHATBOTTOM" },
        { "Chat Reply",                     "REPLY" },
        { "Re-Whisper",                     "REPLY2" },
        { "Combat Log Page Up",             "COMBATLOGPAGEUP" },
        { "Combat Log Page Down",           "COMBATLOGPAGEDOWN" },
        { "Combat Log Bottom",              "COMBATLOGBOTTOM" },
        { "Toggle Combat Log",              "TOGGLECOMBATLOG" },
        { "Voice Chat: Toggle Mute Self",   "TOGGLE_VOICE_SELF_MUTE" },
        { "Voice Chat: Toggle Deafen Self", "TOGGLE_VOICE_SELF_DEAFEN" },
        { "Stop Text To Speech Playback",   "TEXT_TO_SPEECH_STOP" },
    },

    ["Targeting"] = {
        { "Target Nearest Enemy",            "TARGETNEARESTENEMY" },
        { "Target Previous Enemy",           "TARGETPREVIOUSENEMY" },
        { "Target Scan Enemy (Hold)",        "TARGETSCANENEMY" },
        { "Target Nearest Friend",           "TARGETNEARESTFRIEND" },
        { "Target Previous Friend",          "TARGETPREVIOUSFRIEND" },
        { "Target Nearest Enemy Player",     "TARGETNEARESTENEMYPLAYER" },
        { "Target Previous Enemy Player",    "TARGETPREVIOUSENEMYPLAYER" },
        { "Target Nearest Friendly Player",  "TARGETNEARESTFRIENDPLAYER" },
        { "Target Previous Friendly Player", "TARGETPREVIOUSFRIENDPLAYER" },
        { "Target Self",                     "TARGETSELF" },
        { "Target Party Member 1",           "TARGETPARTYMEMBER1" },
        { "Target Party Member 2",           "TARGETPARTYMEMBER2" },
        { "Target Party Member 3",           "TARGETPARTYMEMBER3" },
        { "Target Party Member 4",           "TARGETPARTYMEMBER4" },
        { "Target Pet",                      "TARGETPET" },
        { "Target Party Pet 1",              "TARGETPARTYPET1" },
        { "Target Party Pet 2",              "TARGETPARTYPET2" },
        { "Target Party Pet 3",              "TARGETPARTYPET3" },
        { "Target Party Pet 4",              "TARGETPARTYPET4" },
        { "Target Last Hostile",             "TARGETLASTHOSTILE" },
        { "Target Last Target",              "TARGETLASTTARGET" },
        { "Target Arena Enemy 1",            "TARGETARENA1" },
        { "Target Arena Enemy 2",            "TARGETARENA2" },
        { "Target Arena Enemy 3",            "TARGETARENA3" },
        { "Target Arena Enemy 4",            "TARGETARENA4" },
        { "Target Arena Enemy 5",            "TARGETARENA5" },
        { "Focus Arena Enemy 1",             "FOCUSARENA1" },
        { "Focus Arena Enemy 2",             "FOCUSARENA2" },
        { "Focus Arena Enemy 3",             "FOCUSARENA3" },
        { "Focus Arena Enemy 4",             "FOCUSARENA4" },
        { "Focus Arena Enemy 5",             "FOCUSARENA5" },
        { "Show Enemy Nameplates",           "NAMEPLATES" },
        { "Show Friendly Nameplates",        "FRIENDNAMEPLATES" },
        { "Show All Nameplates",             "ALLNAMEPLATES" },
        { "Interact With Mouseover",         "INTERACTMOUSEOVER" },
        { "Interact With Target",            "INTERACTTARGET" },
        { "Assist Target",                   "ASSISTTARGET" },
        { "Attack Target",                   "ATTACKTARGET" },
        { "Start Attack",                    "STARTATTACK" },
        { "Pet Attack",                      "PETATTACK" },
        { "Focus Target",                    "FOCUSTARGET" },
        { "Target Focus",                    "TARGETFOCUS" },
        { "Target Mouseover",                "TARGETMOUSEOVER" },
        { "Target Current Talker",           "TARGETTALKER" },
    },

    ["Target Markers"] = {
        { "Assign Star to Target",     "RAIDTARGET1" },
        { "Assign Circle to Target",   "RAIDTARGET2" },
        { "Assign Diamond to Target",  "RAIDTARGET3" },
        { "Assign Triangle to Target", "RAIDTARGET4" },
        { "Assign Moon to Target",     "RAIDTARGET5" },
        { "Assign Square to Target",   "RAIDTARGET6" },
        { "Assign Cross to Target",    "RAIDTARGET7" },
        { "Clear Target Marker Icon",  "RAIDTARGETNONE" },
    },

    ["Vehicle Controls"] = {
        { "Exit Vehicle",  "VEHICLEEXIT" },
        { "Previous Seat", "VEHICLEPREVSEAT" },
        { "Next Seat",     "VEHICLENEXTSEAT" },
        { "Aim Up",        "VEHICLEAIMUP" },
        { "Aim Down",      "VEHICLEAIMDOWN" },
        { "Aim Increment", "VEHICLEAIMINCREMENT" },
        { "Aim Decrement", "VEHICLEAIMDECREMENT" },
    },

    ["Camera"] = {
        { "Next View",     "NEXTVIEW" },
        { "Previous View", "PREVVIEW" },
        { "Zoom In",       "CAMERAZOOMIN" },
        { "Zoom Out",      "CAMERAZOOMOUT" },
        { "Set View 1",    "SETVIEW1" },
        { "Set View 2",    "SETVIEW2" },
        { "Set View 3",    "SETVIEW3" },
        { "Set View 4",    "SETVIEW4" },
        { "Set View 5",    "SETVIEW5" },
        { "Save View 1",   "SAVEVIEW1" },
        { "Save View 2",   "SAVEVIEW2" },
        { "Save View 3",   "SAVEVIEW3" },
        { "Save View 4",   "SAVEVIEW4" },
        { "Save View 5",   "SAVEVIEW5" },
        { "Reset View 1",  "RESETVIEW1" },
        { "Reset View 2",  "RESETVIEW2" },
        { "Reset View 3",  "RESETVIEW3" },
        { "Reset View 4",  "RESETVIEW4" },
        { "Reset View 5",  "RESETVIEW5" },
        { "Flip Camera",   "FLIPCAMERAYAW" },
        { "Center Camera", "CENTERCAMERA" },
    },

    ["Ping System"] = {
        { "Ping",      "TOGGLEPINGLISTENER" },
        { "Attack",    "PINGATTACK" },
        { "Warning",   "PINGWARNING" },
        { "On My Way", "PINGONMYWAY" },
        { "Assist",    "PINGASSIST" },
    },

    ["Miscellaneous"] = {
        { "Stop Casting",             "STOPCASTING" },
        { "Stop Attacking",           "STOPATTACK" },
        { "Dismount",                 "DISMOUNT" },
        { "Minimap Zoom In",          "MINIMAPZOOMIN" },
        { "Minimap Zoom Out",         "MINIMAPZOOMOUT" },
        { "Toggle Music",             "TOGGLEMUSIC" },
        { "Toggle Sound",             "TOGGLESOUND" },
        { "Master Volume Up",         "MASTERVOLUMEUP" },
        { "Master Volume Down",       "MASTERVOLUMEDOWN" },
        { "Toggle User Interface",    "TOGGLEUI" },
        { "Toggle Framerate Display", "TOGGLEFPS" },
        { "Screen Shot",              "SCREENSHOT" },
        { "Item Comparison Cycling",  "ITEMCOMPARISONCYCLING" },
        { "Toggle Graphics Settings", "TOGGLEGRAPHICSSETTINGS" },
        { "Toggle Self Highlight",    "TOGGLESELFHIGHLIGHT" },
        { "Toggle Windowed Mode",     "TOGGLEWINDOWED" },
    },
}

-- shortening too long keys
addon.shortcut_labels = {
    ["CAPSLOCK"] = "CAPS",
    ["PRINTSCREEN"] = "PRINT",
    ["SCROLLLOCK"] = "SCROLL",
    ["INSERT"] = "INS",
    ["PAGEUP"] = "PG UP",
    ["DELETE"] = "DEL",
    ["PAGEDOWN"] = "PG DN",
    ["NUMPAD0"] = "NUM0",
    ["NUMPAD1"] = "NUM1",
    ["NUMPAD2"] = "NUM2",
    ["NUMPAD3"] = "NUM3",
    ["NUMPAD4"] = "NUM4",
    ["NUMPAD5"] = "NUM5",
    ["NUMPAD6"] = "NUM6",
    ["NUMPAD7"] = "NUM7",
    ["NUMPAD8"] = "NUM8",
    ["NUMPAD9"] = "NUM9",
    ["NUMLOCK"] = "NUMLK",
    ["NUMPADDIV"] = "/",
    ["NUMPADMULT"] = "*",
    ["NUMPADSUB"] = "-",
    ["NUMPADADD"] = "+",
    ["NUMPADENTER"] = "ENTER",
    ["NUMPADDOT"] = ".",
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
