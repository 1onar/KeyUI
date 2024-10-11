-- Define key sizes
local u = 60
local u1_25 = 1.25 * u
local u1_5 = 1.5 * u
local u1_75 = 1.75 * u
local u2 = 2 * u + 2
local u2_25 = 2.25 * u
local u2_75 = 2.75 * u
local u6_25 = 6.25 * u + 8

KeyBindAllBoards = {

-- ISO --

    -- QWERTZ --

        ['QWERTZ_100%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                
            -- 5 row
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
            
            -- 100% -----------------------------------------

                { 'NUMLOCK', Keyboard, 1148, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

                { 'NUMPAD7', Keyboard, 1148, -130, u, u },
                { 'NUMPAD8', Keyboard, 1210, -130, u, u },
                { 'NUMPAD9', Keyboard, 1272, -130, u, u },
                { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
            
                { 'NUMPAD4', Keyboard, 1148, -192, u, u },
                { 'NUMPAD5', Keyboard, 1210, -192, u, u },
                { 'NUMPAD6', Keyboard, 1272, -192, u, u },

                { 'NUMPAD1', Keyboard, 1148, -254, u, u },
                { 'NUMPAD2', Keyboard, 1210, -254, u, u },
                { 'NUMPAD3', Keyboard, 1272, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

                { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
                { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
        },

        ['QWERTZ_96%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'DELETE', Keyboard, 812, -6, u, u },
                { 'INSERT', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 936, -6, u, u },
                { 'END', Keyboard, 998, -6, u, u },
                { 'PAGEUP', Keyboard, 1060, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1122, -6, u, u },
            
                
            -- 2 row
            
                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 936, -68, u, u },
                { 'NUMPADDIV', Keyboard, 998, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1060, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1122, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'NUMPAD7', Keyboard, 936, -130, u, u },
                { 'NUMPAD8', Keyboard, 998, -130, u, u },
                { 'NUMPAD9', Keyboard, 1060, -130, u, u },
                { 'NUMPADADD', Keyboard, 1122, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                { 'NUMPAD4', Keyboard, 936, -192, u, u },
                { 'NUMPAD5', Keyboard, 998, -192, u, u },
                { 'NUMPAD6', Keyboard, 1060, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'NUMPAD1', Keyboard, 936, -254, u, u },
                { 'NUMPAD2', Keyboard, 998, -254, u, u },
                { 'NUMPAD3', Keyboard, 1060, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1122, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
                { 'NUMPAD0', Keyboard, 998, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1060, -316, u, u },
        },

        ['QWERTZ_80%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row

                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },

            -- 4 row

                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
        },

        ['QWERTZ_75%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'PRINTSCREEN', Keyboard, 812, -6, u, u },
                { 'PAUSE', Keyboard, 874, -6, u, u },
                { 'DELETE', Keyboard, 936, -6, u, u },
                
            -- 2 row
            
                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'HOME', Keyboard, 936, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'END', Keyboard, 936, -130, u, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                { 'PAGEUP', Keyboard, 936, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'PAGEDOWN', Keyboard, 936, -254, u, u },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
        },
                
        ['QWERTZ_60%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                { '1', Keyboard, 68, -6, u, u },
                { '2', Keyboard, 130, -6, u, u },
                { '3', Keyboard, 192, -6, u, u },
                { '4', Keyboard, 254, -6, u, u },
                { '5', Keyboard, 316, -6, u, u },
                { '6', Keyboard, 378, -6, u, u },
                { '7', Keyboard, 440, -6, u, u },
                { '8', Keyboard, 502, -6, u, u },
                { '9', Keyboard, 564, -6, u, u },
                { '0', Keyboard, 626, -6, u, u },
                { 'ß', Keyboard, 688, -6, u, u },
                { '´', Keyboard, 750, -6, u, u },
                { 'BACKSPACE', Keyboard, 812, -6, u2, u },
                
            -- 2 row

                { 'TAB', Keyboard, 6, -68, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -68, u, u },
                { 'W', Keyboard, 160, -68, u, u },
                { 'E', Keyboard, 222, -68, u, u },
                { 'R', Keyboard, 284, -68, u, u },
                { 'T', Keyboard, 346, -68, u, u },
                { 'Z', Keyboard, 408, -68, u, u },
                { 'U', Keyboard, 470, -68, u, u },
                { 'I', Keyboard, 532, -68, u, u },
                { 'O', Keyboard, 594, -68, u, u },
                { 'P', Keyboard, 656, -68, u, u },
                { 'ü', Keyboard, 718, -68, u, u },
                { '+', Keyboard, 780, -68, u, u },
                { 'ENTER', Keyboard, 859, -68, u1_25, u2 },

            -- 3 row

                { 'CAPS', Keyboard, 6, -130, u1_75 + 2, u },
                { 'A', Keyboard, 115, -130, u, u },
                { 'S', Keyboard, 177, -130, u, u },
                { 'D', Keyboard, 239, -130, u, u },
                { 'F', Keyboard, 301, -130, u, u },
                { 'G', Keyboard, 363, -130, u, u },
                { 'H', Keyboard, 425, -130, u, u },
                { 'J', Keyboard, 487, -130, u, u },
                { 'K', Keyboard, 549, -130, u, u },
                { 'L', Keyboard, 611, -130, u, u },
                { 'ö', Keyboard, 673, -130, u, u },
                { "ä", Keyboard, 735, -130, u, u },
                { '#', Keyboard, 797, -130, u, u },
                
            -- 4 row

                { 'LSHIFT', Keyboard, 6, -192, u1_25 + 2, u },
                { '<', Keyboard, 85, -192, u, u },
                { 'Y', Keyboard, 147, -192, u, u },
                { 'X', Keyboard, 209, -192, u, u },
                { 'C', Keyboard, 271, -192, u, u },
                { 'V', Keyboard, 333, -192, u, u },
                { 'B', Keyboard, 395, -192, u, u },
                { 'N', Keyboard, 457, -192, u, u },
                { 'M', Keyboard, 519, -192, u, u },
                { ',', Keyboard, 581, -192, u, u },
                { '.', Keyboard, 643, -192, u, u },
                { '-', Keyboard, 705, -192, u, u },
                { 'RSHIFT', Keyboard, 767, -192, u2_75 + 2, u },

            -- 5 row

                { 'LCTRL', Keyboard, 6, -254, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -254, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -254, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -254, u6_25, u },
                { 'RALT', Keyboard, 626, -254, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -254, u1_25, u },
                { 'MENU', Keyboard, 782, -254, u1_25, u },
                { 'RCTRL', Keyboard, 859, -254, u1_25, u },
        },

        ['QWERTZ_1800'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 956, -6, u, u },
                { 'END', Keyboard, 1018, -6, u, u },
                { 'PAGEUP', Keyboard, 1080, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1142, -6, u, u },
            
                
            -- 2 row
            
                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 956, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1018, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1080, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1142, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'NUMPAD7', Keyboard, 956, -130, u, u },
                { 'NUMPAD8', Keyboard, 1018, -130, u, u },
                { 'NUMPAD9', Keyboard, 1080, -130, u, u },
                { 'NUMPADADD', Keyboard, 1142, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                { 'NUMPAD4', Keyboard, 956, -192, u, u },
                { 'NUMPAD5', Keyboard, 1018, -192, u, u },
                { 'NUMPAD6', Keyboard, 1080, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 884, -264, u, u },
                { 'NUMPAD1', Keyboard, 956, -254, u, u },
                { 'NUMPAD2', Keyboard, 1018, -254, u, u },
                { 'NUMPAD3', Keyboard, 1080, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1142, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 822, -326, u, u },
                { 'DOWN', Keyboard, 884, -326, u, u },
                { 'RIGHT', Keyboard, 946, -326, u, u },
                { 'NUMPAD0', Keyboard, 1018, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1080, -316, u, u },
        },
    
        ['QWERTZ_HALF'] = {
            
            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                
            -- 2 row

                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, 245, u },
        },

        ['QWERTZ_PRIMARY'] = {
        
            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '^', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { 'ß', Keyboard, 688, -68, u, u },
                { '´', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Z', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { 'ü', Keyboard, 718, -130, u, u },
                { '+', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'ö', Keyboard, 673, -192, u, u },
                { "ä", Keyboard, 735, -192, u, u },
                { '#', Keyboard, 797, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'Y', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '-', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
        },

    --

    -- AZERTY --

        ['AZERTY_100%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
            
            -- 100% -----------------------------------------

                { 'NUMLOCK', Keyboard, 1148, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

                { 'NUMPAD7', Keyboard, 1148, -130, u, u },
                { 'NUMPAD8', Keyboard, 1210, -130, u, u },
                { 'NUMPAD9', Keyboard, 1272, -130, u, u },
                { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
            
                { 'NUMPAD4', Keyboard, 1148, -192, u, u },
                { 'NUMPAD5', Keyboard, 1210, -192, u, u },
                { 'NUMPAD6', Keyboard, 1272, -192, u, u },

                { 'NUMPAD1', Keyboard, 1148, -254, u, u },
                { 'NUMPAD2', Keyboard, 1210, -254, u, u },
                { 'NUMPAD3', Keyboard, 1272, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

                { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
                { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
        },

        ['AZERTY_96%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'DELETE', Keyboard, 812, -6, u, u },
                { 'INSERT', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 936, -6, u, u },
                { 'END', Keyboard, 998, -6, u, u },
                { 'PAGEUP', Keyboard, 1060, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1122, -6, u, u },
            
                
            -- 2 row
            
                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 936, -68, u, u },
                { 'NUMPADDIV', Keyboard, 998, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1060, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1122, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'NUMPAD7', Keyboard, 936, -130, u, u },
                { 'NUMPAD8', Keyboard, 998, -130, u, u },
                { 'NUMPAD9', Keyboard, 1060, -130, u, u },
                { 'NUMPADADD', Keyboard, 1122, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                { 'NUMPAD4', Keyboard, 936, -192, u, u },
                { 'NUMPAD5', Keyboard, 998, -192, u, u },
                { 'NUMPAD6', Keyboard, 1060, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'NUMPAD1', Keyboard, 936, -254, u, u },
                { 'NUMPAD2', Keyboard, 998, -254, u, u },
                { 'NUMPAD3', Keyboard, 1060, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1122, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
                { 'NUMPAD0', Keyboard, 998, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1060, -316, u, u },
        },

        ['AZERTY_80%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row

                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },

            -- 4 row

                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
        },

        ['AZERTY_75%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'PRINTSCREEN', Keyboard, 812, -6, u, u },
                { 'PAUSE', Keyboard, 874, -6, u, u },
                { 'DELETE', Keyboard, 936, -6, u, u },
                
            -- 2 row
            
                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'HOME', Keyboard, 936, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'END', Keyboard, 936, -130, u, u },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                { 'PAGEUP', Keyboard, 936, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'PAGEDOWN', Keyboard, 936, -254, u, u },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
        },

        ['AZERTY_60%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                { '&', Keyboard, 68, -6, u, u },
                { 'é', Keyboard, 130, -6, u, u },
                { '"', Keyboard, 192, -6, u, u },
                { "'", Keyboard, 254, -6, u, u },
                { '(', Keyboard, 316, -6, u, u },
                { '-', Keyboard, 378, -6, u, u },
                { 'è', Keyboard, 440, -6, u, u },
                { '_', Keyboard, 502, -6, u, u },
                { 'ç', Keyboard, 564, -6, u, u },
                { 'à', Keyboard, 626, -6, u, u },
                { ')', Keyboard, 688, -6, u, u },
                { '=', Keyboard, 750, -6, u, u },
                { 'BACKSPACE', Keyboard, 812, -6, u2, u },
                
            -- 2 row

                { 'TAB', Keyboard, 6, -68, u1_5 + 1, u },
                { 'A', Keyboard, 98, -68, u, u },
                { 'Z', Keyboard, 160, -68, u, u },
                { 'E', Keyboard, 222, -68, u, u },
                { 'R', Keyboard, 284, -68, u, u },
                { 'T', Keyboard, 346, -68, u, u },
                { 'Y', Keyboard, 408, -68, u, u },
                { 'U', Keyboard, 470, -68, u, u },
                { 'I', Keyboard, 532, -68, u, u },
                { 'O', Keyboard, 594, -68, u, u },
                { 'P', Keyboard, 656, -68, u, u },
                { '^', Keyboard, 718, -68, u, u },
                { '$', Keyboard, 780, -68, u, u },
                { 'ENTER', Keyboard, 859, -68, u1_25, u2 },

            -- 3 row

                { 'CAPSLOCK', Keyboard, 6, -130, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -130, u, u },
                { 'S', Keyboard, 177, -130, u, u },
                { 'D', Keyboard, 239, -130, u, u },
                { 'F', Keyboard, 301, -130, u, u },
                { 'G', Keyboard, 363, -130, u, u },
                { 'H', Keyboard, 425, -130, u, u },
                { 'J', Keyboard, 487, -130, u, u },
                { 'K', Keyboard, 549, -130, u, u },
                { 'L', Keyboard, 611, -130, u, u },
                { 'M', Keyboard, 673, -130, u, u },
                { 'ù', Keyboard, 735, -130, u, u },
                { '*', Keyboard, 797, -130, u, u },
                
            -- 4 row

                { 'LSHIFT', Keyboard, 6, -192, u1_25 + 2, u },
                { '<', Keyboard, 85, -192, u, u },
                { 'W', Keyboard, 147, -192, u, u },
                { 'X', Keyboard, 209, -192, u, u },
                { 'C', Keyboard, 271, -192, u, u },
                { 'V', Keyboard, 333, -192, u, u },
                { 'B', Keyboard, 395, -192, u, u },
                { 'N', Keyboard, 457, -192, u, u },
                { ',', Keyboard, 519, -192, u, u },
                { ';', Keyboard, 581, -192, u, u },
                { ':', Keyboard, 643, -192, u, u },
                { '!', Keyboard, 705, -192, u, u },
                { 'RSHIFT', Keyboard, 767, -192, u2_75 + 2, u },

            -- 5 row

                { 'LCTRL', Keyboard, 6, -254, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -254, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -254, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -254, u6_25, u },
                { 'RALT', Keyboard, 626, -254, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -254, u1_25, u },
                { 'MENU', Keyboard, 782, -254, u1_25, u },
                { 'RCTRL', Keyboard, 859, -254, u1_25, u },
        },

        ['AZERTY_1800'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 956, -6, u, u },
                { 'END', Keyboard, 1018, -6, u, u },
                { 'PAGEUP', Keyboard, 1080, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1142, -6, u, u },
            
                
            -- 2 row
            
                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 956, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1018, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1080, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1142, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
                { 'NUMPAD7', Keyboard, 956, -130, u, u },
                { 'NUMPAD8', Keyboard, 1018, -130, u, u },
                { 'NUMPAD9', Keyboard, 1080, -130, u, u },
                { 'NUMPADADD', Keyboard, 1142, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                { 'NUMPAD4', Keyboard, 956, -192, u, u },
                { 'NUMPAD5', Keyboard, 1018, -192, u, u },
                { 'NUMPAD6', Keyboard, 1080, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 884, -264, u, u },
                { 'NUMPAD1', Keyboard, 956, -254, u, u },
                { 'NUMPAD2', Keyboard, 1018, -254, u, u },
                { 'NUMPAD3', Keyboard, 1080, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1142, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 822, -326, u, u },
                { 'DOWN', Keyboard, 884, -326, u, u },
                { 'RIGHT', Keyboard, 946, -326, u, u },
                { 'NUMPAD0', Keyboard, 1018, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1080, -316, u, u },
        },

        ['AZERTY_HALF'] = {
            
            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                
            -- 2 row

                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, 245, u },
        },

        ['AZERTY_PRIMARY'] = {
        
            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '²', Keyboard, 6, -68, u, u },
                { '&', Keyboard, 68, -68, u, u },
                { 'é', Keyboard, 130, -68, u, u },
                { '"', Keyboard, 192, -68, u, u },
                { "'", Keyboard, 254, -68, u, u },
                { '(', Keyboard, 316, -68, u, u },
                { '-', Keyboard, 378, -68, u, u },
                { 'è', Keyboard, 440, -68, u, u },
                { '_', Keyboard, 502, -68, u, u },
                { 'ç', Keyboard, 564, -68, u, u },
                { 'à', Keyboard, 626, -68, u, u },
                { ')', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'A', Keyboard, 98, -130, u, u },
                { 'Z', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '^', Keyboard, 718, -130, u, u },
                { '$', Keyboard, 780, -130, u, u },
                { 'ENTER', Keyboard, 859, -130, u1_25, u2 },
            
            -- 4 row
            
                { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
                { 'Q', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { 'M', Keyboard, 673, -192, u, u },
                { 'ù', Keyboard, 735, -192, u, u },
                { '*', Keyboard, 797, -192, u, u },
                
            -- 5 row

                { 'LSHIFT', Keyboard, 6, -254, u1_25 + 2, u },
                { '<', Keyboard, 85, -254, u, u },
                { 'W', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { ',', Keyboard, 519, -254, u, u },
                { ';', Keyboard, 581, -254, u, u },
                { ':', Keyboard, 643, -254, u, u },
                { '!', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
        },

    --

--

-- ANSI --

    -- QWERTY --

        ['QWERTY_100%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                
            -- 5 row
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
            
            -- 100% -----------------------------------------

                { 'NUMLOCK', Keyboard, 1148, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

                { 'NUMPAD7', Keyboard, 1148, -130, u, u },
                { 'NUMPAD8', Keyboard, 1210, -130, u, u },
                { 'NUMPAD9', Keyboard, 1272, -130, u, u },
                { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
            
                { 'NUMPAD4', Keyboard, 1148, -192, u, u },
                { 'NUMPAD5', Keyboard, 1210, -192, u, u },
                { 'NUMPAD6', Keyboard, 1272, -192, u, u },

                { 'NUMPAD1', Keyboard, 1148, -254, u, u },
                { 'NUMPAD2', Keyboard, 1210, -254, u, u },
                { 'NUMPAD3', Keyboard, 1272, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

                { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
                { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
        },
        ['QWERTY_96%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'DELETE', Keyboard, 812, -6, u, u },
                { 'INSERT', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 936, -6, u, u },
                { 'END', Keyboard, 998, -6, u, u },
                { 'PAGEUP', Keyboard, 1060, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1122, -6, u, u },
            
                
            -- 2 row
            
                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 936, -68, u, u },
                { 'NUMPADDIV', Keyboard, 998, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1060, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1122, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
                { 'NUMPAD7', Keyboard, 936, -130, u, u },
                { 'NUMPAD8', Keyboard, 998, -130, u, u },
                { 'NUMPAD9', Keyboard, 1060, -130, u, u },
                { 'NUMPADADD', Keyboard, 1122, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                { 'NUMPAD4', Keyboard, 936, -192, u, u },
                { 'NUMPAD5', Keyboard, 998, -192, u, u },
                { 'NUMPAD6', Keyboard, 1060, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'NUMPAD1', Keyboard, 936, -254, u, u },
                { 'NUMPAD2', Keyboard, 998, -254, u, u },
                { 'NUMPAD3', Keyboard, 1060, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1122, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
                { 'NUMPAD0', Keyboard, 998, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1060, -316, u, u },
        },
        ['QWERTY_80%'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                
            -- 2 row

                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                
            -- 5 row
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
                
            -- 80% ------------------------------------------

                { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
                { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
                { 'PAUSE', Keyboard, 1073, -6, u, u },

                { 'INSERT', Keyboard, 949, -68, u, u },
                { 'HOME', Keyboard, 1011, -68, u, u },
                { 'PAGEUP', Keyboard, 1073, -68, u, u },

                { 'DELETE', Keyboard, 949, -130, u, u },
                { 'END', Keyboard, 1011, -130, u, u },
                { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
                
                { 'LEFT', Keyboard, 949, -316, u, u },
                { 'DOWN', Keyboard, 1011, -316, u, u },
                { 'UP', Keyboard, 1011, -254, u, u },
                { 'RIGHT', Keyboard, 1073, -316, u, u },
        },
        ['QWERTY_75%'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                { 'F1', Keyboard, 68, -6, u, u },
                { 'F2', Keyboard, 130, -6, u, u },
                { 'F3', Keyboard, 192, -6, u, u },
                { 'F4', Keyboard, 254, -6, u, u },
                { 'F5', Keyboard, 316, -6, u, u },
                { 'F6', Keyboard, 378, -6, u, u },
                { 'F7', Keyboard, 440, -6, u, u },
                { 'F8', Keyboard, 502, -6, u, u },
                { 'F9', Keyboard, 564, -6, u, u },
                { 'F10', Keyboard, 626, -6, u, u },
                { 'F11', Keyboard, 688, -6, u, u },
                { 'F12', Keyboard, 750, -6, u, u },
                { 'PRINTSCREEN', Keyboard, 812, -6, u, u },
                { 'PAUSE', Keyboard, 874, -6, u, u },
                { 'DELETE', Keyboard, 936, -6, u, u },
                
            -- 2 row
            
                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'HOME', Keyboard, 936, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
                { 'END', Keyboard, 936, -130, u, u },
            
            -- 4 row
        
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                { 'PAGEUP', Keyboard, 936, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 874, -254, u, u },
                { 'PAGEDOWN', Keyboard, 936, -254, u, u },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 812, -316, u, u },
                { 'DOWN', Keyboard, 874, -316, u, u },
                { 'RIGHT', Keyboard, 936, -316, u, u },
        },
        ['QWERTY_60%'] = {

            -- 1 row
        
                { 'ESC', Keyboard, 6, -6, u, u },
                { '1', Keyboard, 68, -6, u, u },
                { '2', Keyboard, 130, -6, u, u },
                { '3', Keyboard, 192, -6, u, u },
                { '4', Keyboard, 254, -6, u, u },
                { '5', Keyboard, 316, -6, u, u },
                { '6', Keyboard, 378, -6, u, u },
                { '7', Keyboard, 440, -6, u, u },
                { '8', Keyboard, 502, -6, u, u },
                { '9', Keyboard, 564, -6, u, u },
                { '0', Keyboard, 626, -6, u, u },
                { '-', Keyboard, 688, -6, u, u },
                { '=', Keyboard, 750, -6, u, u },
                { 'BACKSPACE', Keyboard, 812, -6, u2, u },
                
            -- 2 row
        
                { 'TAB', Keyboard, 6, -68, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -68, u, u },
                { 'W', Keyboard, 160, -68, u, u },
                { 'E', Keyboard, 222, -68, u, u },
                { 'R', Keyboard, 284, -68, u, u },
                { 'T', Keyboard, 346, -68, u, u },
                { 'Y', Keyboard, 408, -68, u, u },
                { 'U', Keyboard, 470, -68, u, u },
                { 'I', Keyboard, 532, -68, u, u },
                { 'O', Keyboard, 594, -68, u, u },
                { 'P', Keyboard, 656, -68, u, u },
                { '[', Keyboard, 718, -68, u, u },
                { ']', Keyboard, 780, -68, u, u },
                { '\\', Keyboard, 842, -68, u1_5 + 2, u },
        
            -- 3 row
        
                { 'CAPS', Keyboard, 6, -130, u1_75 + 2, u },
                { 'A', Keyboard, 115, -130, u, u },
                { 'S', Keyboard, 177, -130, u, u },
                { 'D', Keyboard, 239, -130, u, u },
                { 'F', Keyboard, 301, -130, u, u },
                { 'G', Keyboard, 363, -130, u, u },
                { 'H', Keyboard, 425, -130, u, u },
                { 'J', Keyboard, 487, -130, u, u },
                { 'K', Keyboard, 549, -130, u, u },
                { 'L', Keyboard, 611, -130, u, u },
                { ';', Keyboard, 673, -130, u, u },
                { ",", Keyboard, 735, -130, u, u },
                { 'ENTER', Keyboard, 797, -130, u2_25 + 2, u },
                
            -- 4 row
        
                { 'LSHIFT', Keyboard, 6, -192, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -192, u, u },
                { 'X', Keyboard, 209, -192, u, u },
                { 'C', Keyboard, 271, -192, u, u },
                { 'V', Keyboard, 333, -192, u, u },
                { 'B', Keyboard, 395, -192, u, u },
                { 'N', Keyboard, 457, -192, u, u },
                { 'M', Keyboard, 519, -192, u, u },
                { ',', Keyboard, 581, -192, u, u },
                { '.', Keyboard, 643, -192, u, u },
                { '/', Keyboard, 705, -192, u, u },
                { 'RSHIFT', Keyboard, 767, -192, u2_75 + 2, u },
        
            -- 5 row
        
                { 'LCTRL', Keyboard, 6, -254, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -254, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -254, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -254, u6_25, u },
                { 'RALT', Keyboard, 626, -254, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -254, u1_25, u },
                { 'MENU', Keyboard, 782, -254, u1_25, u },
                { 'RCTRL', Keyboard, 859, -254, u1_25, u },
        },
        ['QWERTY_1800'] = {

            -- 1 row
            
                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
                { 'HOME', Keyboard, 956, -6, u, u },
                { 'END', Keyboard, 1018, -6, u, u },
                { 'PAGEUP', Keyboard, 1080, -6, u, u },
                { 'PAGEDOWN', Keyboard, 1142, -6, u, u },
            
                
            -- 2 row
            
                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                { 'NUMLOCK', Keyboard, 956, -68, u, u },
                { 'NUMPADDIV', Keyboard, 1018, -68, u, u },
                { 'NUMPADMULT', Keyboard, 1080, -68, u, u },
                { 'NUMPADSUB', Keyboard, 1142, -68, u, u },
            
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
                { 'NUMPAD7', Keyboard, 956, -130, u, u },
                { 'NUMPAD8', Keyboard, 1018, -130, u, u },
                { 'NUMPAD9', Keyboard, 1080, -130, u, u },
                { 'NUMPADADD', Keyboard, 1142, -130, u, u2 },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                { 'NUMPAD4', Keyboard, 956, -192, u, u },
                { 'NUMPAD5', Keyboard, 1018, -192, u, u },
                { 'NUMPAD6', Keyboard, 1080, -192, u, u },
                
            -- 5 row
            
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, 105, u },
                { 'UP', Keyboard, 884, -264, u, u },
                { 'NUMPAD1', Keyboard, 956, -254, u, u },
                { 'NUMPAD2', Keyboard, 1018, -254, u, u },
                { 'NUMPAD3', Keyboard, 1080, -254, u, u },
                { 'NUMPADENTER', Keyboard, 1142, -254, u, u2 },
            
            -- 6 row
            
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u, u },
                { 'MENU', Keyboard, 688, -316, u, u },
                { 'RCTRL', Keyboard, 750, -316, u, u },
                { 'LEFT', Keyboard, 822, -326, u, u },
                { 'DOWN', Keyboard, 884, -326, u, u },
                { 'RIGHT', Keyboard, 946, -326, u, u },
                { 'NUMPAD0', Keyboard, 1018, -316, u, u },
                { 'NUMPADDOT', Keyboard, 1080, -316, u, u },
        },        
        ['QWERTY_HALF'] = {
            
            -- 1 row
        
                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                
            -- 2 row
        
                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                
            -- 5 row
        
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
        
            -- 6 row
        
                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, 245, u },
        },
        ['QWERTY_PRIMARY'] = {

            -- 1 row

                { 'ESC', Keyboard, 6, -6, u, u },
                -- 1u gap
                { 'F1', Keyboard, 130, -6, u, u },
                { 'F2', Keyboard, 192, -6, u, u },
                { 'F3', Keyboard, 254, -6, u, u },
                { 'F4', Keyboard, 316, -6, u, u },
                -- 0,5u gap
                { 'F5', Keyboard, 409, -6, u, u },
                { 'F6', Keyboard, 471, -6, u, u },
                { 'F7', Keyboard, 533, -6, u, u },
                { 'F8', Keyboard, 595, -6, u, u },
                -- 0,5u gap
                { 'F9', Keyboard, 688, -6, u, u },
                { 'F10', Keyboard, 750, -6, u, u },
                { 'F11', Keyboard, 812, -6, u, u },
                { 'F12', Keyboard, 874, -6, u, u },
            
            -- 2 row

                { '`', Keyboard, 6, -68, u, u },
                { '1', Keyboard, 68, -68, u, u },
                { '2', Keyboard, 130, -68, u, u },
                { '3', Keyboard, 192, -68, u, u },
                { '4', Keyboard, 254, -68, u, u },
                { '5', Keyboard, 316, -68, u, u },
                { '6', Keyboard, 378, -68, u, u },
                { '7', Keyboard, 440, -68, u, u },
                { '8', Keyboard, 502, -68, u, u },
                { '9', Keyboard, 564, -68, u, u },
                { '0', Keyboard, 626, -68, u, u },
                { '-', Keyboard, 688, -68, u, u },
                { '=', Keyboard, 750, -68, u, u },
                { 'BACKSPACE', Keyboard, 812, -68, u2, u },
                
            -- 3 row
            
                { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
                { 'Q', Keyboard, 98, -130, u, u },
                { 'W', Keyboard, 160, -130, u, u },
                { 'E', Keyboard, 222, -130, u, u },
                { 'R', Keyboard, 284, -130, u, u },
                { 'T', Keyboard, 346, -130, u, u },
                { 'Y', Keyboard, 408, -130, u, u },
                { 'U', Keyboard, 470, -130, u, u },
                { 'I', Keyboard, 532, -130, u, u },
                { 'O', Keyboard, 594, -130, u, u },
                { 'P', Keyboard, 656, -130, u, u },
                { '[', Keyboard, 718, -130, u, u },
                { ']', Keyboard, 780, -130, u, u },
                { '\\', Keyboard, 842, -130, u1_5 + 2, u },
            
            -- 4 row
            
                { 'CAPS', Keyboard, 6, -192, u1_75 + 2, u },
                { 'A', Keyboard, 115, -192, u, u },
                { 'S', Keyboard, 177, -192, u, u },
                { 'D', Keyboard, 239, -192, u, u },
                { 'F', Keyboard, 301, -192, u, u },
                { 'G', Keyboard, 363, -192, u, u },
                { 'H', Keyboard, 425, -192, u, u },
                { 'J', Keyboard, 487, -192, u, u },
                { 'K', Keyboard, 549, -192, u, u },
                { 'L', Keyboard, 611, -192, u, u },
                { ';', Keyboard, 673, -192, u, u },
                { ",", Keyboard, 735, -192, u, u },
                { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
                
            -- 5 row
                { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
                { 'Z', Keyboard, 147, -254, u, u },
                { 'X', Keyboard, 209, -254, u, u },
                { 'C', Keyboard, 271, -254, u, u },
                { 'V', Keyboard, 333, -254, u, u },
                { 'B', Keyboard, 395, -254, u, u },
                { 'N', Keyboard, 457, -254, u, u },
                { 'M', Keyboard, 519, -254, u, u },
                { ',', Keyboard, 581, -254, u, u },
                { '.', Keyboard, 643, -254, u, u },
                { '/', Keyboard, 705, -254, u, u },
                { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

            -- 6 row

                { 'LCTRL', Keyboard, 6, -316, u1_25 + 2, u },
                { 'LWIN', Keyboard, 85, -316, u1_25 + 1, u },
                { 'LALT', Keyboard, 163, -316, u1_25 + 1, u },
                { 'SPACE', Keyboard, 241, -316, u6_25, u },
                { 'RALT', Keyboard, 626, -316, u1_25 + 2, u },
                { 'RWIN', Keyboard, 705, -316, u1_25, u },
                { 'MENU', Keyboard, 782, -316, u1_25, u },
                { 'RCTRL', Keyboard, 859, -316, u1_25, u },
        },
        
    --

--

-- DVORAK --

    ['DVORAK_100%'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '1', Keyboard, 68, -68, u, u },
            { '2', Keyboard, 130, -68, u, u },
            { '3', Keyboard, 192, -68, u, u },
            { '4', Keyboard, 254, -68, u, u },
            { '5', Keyboard, 316, -68, u, u },
            { '6', Keyboard, 378, -68, u, u },
            { '7', Keyboard, 440, -68, u, u },
            { '8', Keyboard, 502, -68, u, u },
            { '9', Keyboard, 564, -68, u, u },
            { '0', Keyboard, 626, -68, u, u },
            { '[', Keyboard, 688, -68, u, u },
            { ']', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { '`', Keyboard, 98, -130, u, u },
            { ',', Keyboard, 160, -130, u, u },
            { '.', Keyboard, 222, -130, u, u },
            { 'P', Keyboard, 284, -130, u, u },
            { 'Y', Keyboard, 346, -130, u, u },
            { 'F', Keyboard, 408, -130, u, u },
            { 'G', Keyboard, 470, -130, u, u },
            { 'C', Keyboard, 532, -130, u, u },
            { 'R', Keyboard, 594, -130, u, u },
            { 'L', Keyboard, 656, -130, u, u },
            { '/', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { 'A', Keyboard, 115, -192, u, u },
            { 'O', Keyboard, 177, -192, u, u },
            { 'E', Keyboard, 239, -192, u, u },
            { 'U', Keyboard, 301, -192, u, u },
            { 'I', Keyboard, 363, -192, u, u },
            { 'D', Keyboard, 425, -192, u, u },
            { 'H', Keyboard, 487, -192, u, u },
            { 'T', Keyboard, 549, -192, u, u },
            { 'N', Keyboard, 611, -192, u, u },
            { 'S', Keyboard, 673, -192, u, u },
            { '-', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { ';', Keyboard, 147, -254, u, u },
            { 'Q', Keyboard, 209, -254, u, u },
            { 'J', Keyboard, 271, -254, u, u },
            { 'K', Keyboard, 333, -254, u, u },
            { 'X', Keyboard, 395, -254, u, u },
            { 'B', Keyboard, 457, -254, u, u },
            { 'M', Keyboard, 519, -254, u, u },
            { 'W', Keyboard, 581, -254, u, u },
            { 'V', Keyboard, 643, -254, u, u },
            { 'Z', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },

        -- 80% ------------------------------------------

            { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
            { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
            { 'PAUSE', Keyboard, 1073, -6, u, u },

            { 'INSERT', Keyboard, 949, -68, u, u },
            { 'HOME', Keyboard, 1011, -68, u, u },
            { 'PAGEUP', Keyboard, 1073, -68, u, u },

            { 'DELETE', Keyboard, 949, -130, u, u },
            { 'END', Keyboard, 1011, -130, u, u },
            { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
            
            { 'LEFT', Keyboard, 949, -316, u, u },
            { 'DOWN', Keyboard, 1011, -316, u, u },
            { 'UP', Keyboard, 1011, -254, u, u },
            { 'RIGHT', Keyboard, 1073, -316, u, u },
    
        -- 100% -----------------------------------------

            { 'NUMLOCK', Keyboard, 1148, -68, u, u },
            { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
            { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
            { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

            { 'NUMPAD7', Keyboard, 1148, -130, u, u },
            { 'NUMPAD8', Keyboard, 1210, -130, u, u },
            { 'NUMPAD9', Keyboard, 1272, -130, u, u },
            { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
        
            { 'NUMPAD4', Keyboard, 1148, -192, u, u },
            { 'NUMPAD5', Keyboard, 1210, -192, u, u },
            { 'NUMPAD6', Keyboard, 1272, -192, u, u },

            { 'NUMPAD1', Keyboard, 1148, -254, u, u },
            { 'NUMPAD2', Keyboard, 1210, -254, u, u },
            { 'NUMPAD3', Keyboard, 1272, -254, u, u },
            { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

            { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
            { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
    },

    ['DVORAK_PRIMARY'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '1', Keyboard, 68, -68, u, u },
            { '2', Keyboard, 130, -68, u, u },
            { '3', Keyboard, 192, -68, u, u },
            { '4', Keyboard, 254, -68, u, u },
            { '5', Keyboard, 316, -68, u, u },
            { '6', Keyboard, 378, -68, u, u },
            { '7', Keyboard, 440, -68, u, u },
            { '8', Keyboard, 502, -68, u, u },
            { '9', Keyboard, 564, -68, u, u },
            { '0', Keyboard, 626, -68, u, u },
            { '[', Keyboard, 688, -68, u, u },
            { ']', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { '`', Keyboard, 98, -130, u, u },
            { ',', Keyboard, 160, -130, u, u },
            { '.', Keyboard, 222, -130, u, u },
            { 'P', Keyboard, 284, -130, u, u },
            { 'Y', Keyboard, 346, -130, u, u },
            { 'F', Keyboard, 408, -130, u, u },
            { 'G', Keyboard, 470, -130, u, u },
            { 'C', Keyboard, 532, -130, u, u },
            { 'R', Keyboard, 594, -130, u, u },
            { 'L', Keyboard, 656, -130, u, u },
            { '/', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { 'A', Keyboard, 115, -192, u, u },
            { 'O', Keyboard, 177, -192, u, u },
            { 'E', Keyboard, 239, -192, u, u },
            { 'U', Keyboard, 301, -192, u, u },
            { 'I', Keyboard, 363, -192, u, u },
            { 'D', Keyboard, 425, -192, u, u },
            { 'H', Keyboard, 487, -192, u, u },
            { 'T', Keyboard, 549, -192, u, u },
            { 'N', Keyboard, 611, -192, u, u },
            { 'S', Keyboard, 673, -192, u, u },
            { '-', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { ';', Keyboard, 147, -254, u, u },
            { 'Q', Keyboard, 209, -254, u, u },
            { 'J', Keyboard, 271, -254, u, u },
            { 'K', Keyboard, 333, -254, u, u },
            { 'X', Keyboard, 395, -254, u, u },
            { 'B', Keyboard, 457, -254, u, u },
            { 'M', Keyboard, 519, -254, u, u },
            { 'W', Keyboard, 581, -254, u, u },
            { 'V', Keyboard, 643, -254, u, u },
            { 'Z', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },
    },

    ['DVORAK_RIGHT_100%'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '1', Keyboard, 68, -68, u, u },
            { '2', Keyboard, 130, -68, u, u },
            { '3', Keyboard, 192, -68, u, u },
            { '4', Keyboard, 254, -68, u, u },
            { 'J', Keyboard, 316, -68, u, u },
            { 'L', Keyboard, 378, -68, u, u },
            { 'M', Keyboard, 440, -68, u, u },
            { 'F', Keyboard, 502, -68, u, u },
            { 'P', Keyboard, 564, -68, u, u },
            { '/', Keyboard, 626, -68, u, u },
            { '[', Keyboard, 688, -68, u, u },
            { ']', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { '5', Keyboard, 98, -130, u, u },
            { '6', Keyboard, 160, -130, u, u },
            { 'Q', Keyboard, 222, -130, u, u },
            { '.', Keyboard, 284, -130, u, u },
            { 'O', Keyboard, 346, -130, u, u },
            { 'R', Keyboard, 408, -130, u, u },
            { 'S', Keyboard, 470, -130, u, u },
            { 'U', Keyboard, 532, -130, u, u },
            { 'Y', Keyboard, 594, -130, u, u },
            { 'B', Keyboard, 656, -130, u, u },
            { ';', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { '&', Keyboard, 115, -192, u, u },
            { '*', Keyboard, 177, -192, u, u },
            { 'Z', Keyboard, 239, -192, u, u },
            { 'A', Keyboard, 301, -192, u, u },
            { 'E', Keyboard, 363, -192, u, u },
            { 'H', Keyboard, 425, -192, u, u },
            { 'T', Keyboard, 487, -192, u, u },
            { 'D', Keyboard, 549, -192, u, u },
            { 'C', Keyboard, 611, -192, u, u },
            { 'K', Keyboard, 673, -192, u, u },
            { '-', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { '9', Keyboard, 147, -254, u, u },
            { '0', Keyboard, 209, -254, u, u },
            { 'X', Keyboard, 271, -254, u, u },
            { ',', Keyboard, 333, -254, u, u },
            { 'I', Keyboard, 395, -254, u, u },
            { 'N', Keyboard, 457, -254, u, u },
            { 'W', Keyboard, 519, -254, u, u },
            { 'V', Keyboard, 581, -254, u, u },
            { 'G', Keyboard, 643, -254, u, u },
            { ',', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },

        -- 80% ------------------------------------------

            { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
            { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
            { 'PAUSE', Keyboard, 1073, -6, u, u },

            { 'INSERT', Keyboard, 949, -68, u, u },
            { 'HOME', Keyboard, 1011, -68, u, u },
            { 'PAGEUP', Keyboard, 1073, -68, u, u },

            { 'DELETE', Keyboard, 949, -130, u, u },
            { 'END', Keyboard, 1011, -130, u, u },
            { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
            
            { 'LEFT', Keyboard, 949, -316, u, u },
            { 'DOWN', Keyboard, 1011, -316, u, u },
            { 'UP', Keyboard, 1011, -254, u, u },
            { 'RIGHT', Keyboard, 1073, -316, u, u },
    
        -- 100% -----------------------------------------

            { 'NUMLOCK', Keyboard, 1148, -68, u, u },
            { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
            { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
            { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

            { 'NUMPAD7', Keyboard, 1148, -130, u, u },
            { 'NUMPAD8', Keyboard, 1210, -130, u, u },
            { 'NUMPAD9', Keyboard, 1272, -130, u, u },
            { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
        
            { 'NUMPAD4', Keyboard, 1148, -192, u, u },
            { 'NUMPAD5', Keyboard, 1210, -192, u, u },
            { 'NUMPAD6', Keyboard, 1272, -192, u, u },

            { 'NUMPAD1', Keyboard, 1148, -254, u, u },
            { 'NUMPAD2', Keyboard, 1210, -254, u, u },
            { 'NUMPAD3', Keyboard, 1272, -254, u, u },
            { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

            { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
            { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
    },

    ['DVORAK_RIGHT_PRIMARY'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '1', Keyboard, 68, -68, u, u },
            { '2', Keyboard, 130, -68, u, u },
            { '3', Keyboard, 192, -68, u, u },
            { '4', Keyboard, 254, -68, u, u },
            { 'J', Keyboard, 316, -68, u, u },
            { 'L', Keyboard, 378, -68, u, u },
            { 'M', Keyboard, 440, -68, u, u },
            { 'F', Keyboard, 502, -68, u, u },
            { 'P', Keyboard, 564, -68, u, u },
            { '/', Keyboard, 626, -68, u, u },
            { '[', Keyboard, 688, -68, u, u },
            { ']', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { '5', Keyboard, 98, -130, u, u },
            { '6', Keyboard, 160, -130, u, u },
            { 'Q', Keyboard, 222, -130, u, u },
            { '.', Keyboard, 284, -130, u, u },
            { 'O', Keyboard, 346, -130, u, u },
            { 'R', Keyboard, 408, -130, u, u },
            { 'S', Keyboard, 470, -130, u, u },
            { 'U', Keyboard, 532, -130, u, u },
            { 'Y', Keyboard, 594, -130, u, u },
            { 'B', Keyboard, 656, -130, u, u },
            { ';', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { '&', Keyboard, 115, -192, u, u },
            { '*', Keyboard, 177, -192, u, u },
            { 'Z', Keyboard, 239, -192, u, u },
            { 'A', Keyboard, 301, -192, u, u },
            { 'E', Keyboard, 363, -192, u, u },
            { 'H', Keyboard, 425, -192, u, u },
            { 'T', Keyboard, 487, -192, u, u },
            { 'D', Keyboard, 549, -192, u, u },
            { 'C', Keyboard, 611, -192, u, u },
            { 'K', Keyboard, 673, -192, u, u },
            { '-', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { '9', Keyboard, 147, -254, u, u },
            { '0', Keyboard, 209, -254, u, u },
            { 'X', Keyboard, 271, -254, u, u },
            { ',', Keyboard, 333, -254, u, u },
            { 'I', Keyboard, 395, -254, u, u },
            { 'N', Keyboard, 457, -254, u, u },
            { 'W', Keyboard, 519, -254, u, u },
            { 'V', Keyboard, 581, -254, u, u },
            { 'G', Keyboard, 643, -254, u, u },
            { ',', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },
    },

    ['DVORAK_LEFT_100%'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '[', Keyboard, 68, -68, u, u },
            { ']', Keyboard, 130, -68, u, u },
            { '/', Keyboard, 192, -68, u, u },
            { 'P', Keyboard, 254, -68, u, u },
            { 'F', Keyboard, 316, -68, u, u },
            { 'M', Keyboard, 378, -68, u, u },
            { 'L', Keyboard, 440, -68, u, u },
            { 'J', Keyboard, 502, -68, u, u },
            { '4', Keyboard, 564, -68, u, u },
            { '3', Keyboard, 626, -68, u, u },
            { '2', Keyboard, 688, -68, u, u },
            { '1', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { ';', Keyboard, 98, -130, u, u },
            { 'Q', Keyboard, 160, -130, u, u },
            { 'B', Keyboard, 222, -130, u, u },
            { 'Y', Keyboard, 284, -130, u, u },
            { 'U', Keyboard, 346, -130, u, u },
            { 'R', Keyboard, 408, -130, u, u },
            { 'S', Keyboard, 470, -130, u, u },
            { 'O', Keyboard, 532, -130, u, u },
            { '.', Keyboard, 594, -130, u, u },
            { '6', Keyboard, 656, -130, u, u },
            { '5', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { '-', Keyboard, 115, -192, u, u },
            { 'K', Keyboard, 177, -192, u, u },
            { 'C', Keyboard, 239, -192, u, u },
            { 'D', Keyboard, 301, -192, u, u },
            { 'T', Keyboard, 363, -192, u, u },
            { 'H', Keyboard, 425, -192, u, u },
            { 'E', Keyboard, 487, -192, u, u },
            { 'A', Keyboard, 549, -192, u, u },
            { 'Z', Keyboard, 611, -192, u, u },
            { '8', Keyboard, 673, -192, u, u },
            { '9', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { ',', Keyboard, 147, -254, u, u },
            { 'X', Keyboard, 209, -254, u, u },
            { 'G', Keyboard, 271, -254, u, u },
            { 'V', Keyboard, 333, -254, u, u },
            { 'W', Keyboard, 395, -254, u, u },
            { 'N', Keyboard, 457, -254, u, u },
            { 'I', Keyboard, 519, -254, u, u },
            { ',', Keyboard, 581, -254, u, u },
            { '0', Keyboard, 643, -254, u, u },
            { '9', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },

        -- 80% ------------------------------------------

            { 'PRINTSCREEN', Keyboard, 949, -6, u, u },
            { 'SCROLLLOCK', Keyboard, 1011, -6, u, u },
            { 'PAUSE', Keyboard, 1073, -6, u, u },

            { 'INSERT', Keyboard, 949, -68, u, u },
            { 'HOME', Keyboard, 1011, -68, u, u },
            { 'PAGEUP', Keyboard, 1073, -68, u, u },

            { 'DELETE', Keyboard, 949, -130, u, u },
            { 'END', Keyboard, 1011, -130, u, u },
            { 'PAGEDOWN', Keyboard, 1073, -130, u, u },
            
            { 'LEFT', Keyboard, 949, -316, u, u },
            { 'DOWN', Keyboard, 1011, -316, u, u },
            { 'UP', Keyboard, 1011, -254, u, u },
            { 'RIGHT', Keyboard, 1073, -316, u, u },
    
        -- 100% -----------------------------------------

            { 'NUMLOCK', Keyboard, 1148, -68, u, u },
            { 'NUMPADDIV', Keyboard, 1210, -68, u, u },
            { 'NUMPADMULT', Keyboard, 1272, -68, u, u },
            { 'NUMPADSUB', Keyboard, 1334, -68, u, u },

            { 'NUMPAD7', Keyboard, 1148, -130, u, u },
            { 'NUMPAD8', Keyboard, 1210, -130, u, u },
            { 'NUMPAD9', Keyboard, 1272, -130, u, u },
            { 'NUMPADADD', Keyboard, 1334, -130, u, u2 },
        
            { 'NUMPAD4', Keyboard, 1148, -192, u, u },
            { 'NUMPAD5', Keyboard, 1210, -192, u, u },
            { 'NUMPAD6', Keyboard, 1272, -192, u, u },

            { 'NUMPAD1', Keyboard, 1148, -254, u, u },
            { 'NUMPAD2', Keyboard, 1210, -254, u, u },
            { 'NUMPAD3', Keyboard, 1272, -254, u, u },
            { 'NUMPADENTER', Keyboard, 1334, -254, u, u2 },

            { 'NUMPAD0', Keyboard, 1148, -316, u2, u },
            { 'NUMPADDOT', Keyboard, 1272, -316, u, u },
    },

    ['DVORAK_LEFT_PRIMARY'] = {

        -- 1 row

            { 'ESC', Keyboard, 6, -6, u, u },
            -- 1u gap
            { 'F1', Keyboard, 130, -6, u, u },
            { 'F2', Keyboard, 192, -6, u, u },
            { 'F3', Keyboard, 254, -6, u, u },
            { 'F4', Keyboard, 316, -6, u, u },
            -- 0,5u gap
            { 'F5', Keyboard, 409, -6, u, u },
            { 'F6', Keyboard, 471, -6, u, u },
            { 'F7', Keyboard, 533, -6, u, u },
            { 'F8', Keyboard, 595, -6, u, u },
            -- 0,5u gap
            { 'F9', Keyboard, 688, -6, u, u },
            { 'F10', Keyboard, 750, -6, u, u },
            { 'F11', Keyboard, 812, -6, u, u },
            { 'F12', Keyboard, 874, -6, u, u },
            
        -- 2 row

            { '`', Keyboard, 6, -68, u, u },
            { '[', Keyboard, 68, -68, u, u },
            { ']', Keyboard, 130, -68, u, u },
            { '/', Keyboard, 192, -68, u, u },
            { 'P', Keyboard, 254, -68, u, u },
            { 'F', Keyboard, 316, -68, u, u },
            { 'M', Keyboard, 378, -68, u, u },
            { 'L', Keyboard, 440, -68, u, u },
            { 'J', Keyboard, 502, -68, u, u },
            { '4', Keyboard, 564, -68, u, u },
            { '3', Keyboard, 626, -68, u, u },
            { '2', Keyboard, 688, -68, u, u },
            { '1', Keyboard, 750, -68, u, u },
            { 'BACKSPACE', Keyboard, 812, -68, u2, u },
            
        -- 3 row
        
            { 'TAB', Keyboard, 6, -130, u1_5 + 1, u },
            { ';', Keyboard, 98, -130, u, u },
            { 'Q', Keyboard, 160, -130, u, u },
            { 'B', Keyboard, 222, -130, u, u },
            { 'Y', Keyboard, 284, -130, u, u },
            { 'U', Keyboard, 346, -130, u, u },
            { 'R', Keyboard, 408, -130, u, u },
            { 'S', Keyboard, 470, -130, u, u },
            { 'O', Keyboard, 532, -130, u, u },
            { '.', Keyboard, 594, -130, u, u },
            { '6', Keyboard, 656, -130, u, u },
            { '5', Keyboard, 718, -130, u, u },
            { '=', Keyboard, 780, -130, u, u },
            { '\\', Keyboard, 842, -130, u1_5 + 2, u },
        
        -- 4 row
        
            { 'CAPSLOCK', Keyboard, 6, -192, u1_75 + 2, u },
            { '-', Keyboard, 115, -192, u, u },
            { 'K', Keyboard, 177, -192, u, u },
            { 'C', Keyboard, 239, -192, u, u },
            { 'D', Keyboard, 301, -192, u, u },
            { 'T', Keyboard, 363, -192, u, u },
            { 'H', Keyboard, 425, -192, u, u },
            { 'E', Keyboard, 487, -192, u, u },
            { 'A', Keyboard, 549, -192, u, u },
            { 'Z', Keyboard, 611, -192, u, u },
            { '8', Keyboard, 673, -192, u, u },
            { '9', Keyboard, 735, -192, u, u },
            { 'ENTER', Keyboard, 797, -192, u2_25 + 2, u },
            
        -- 5 row

            { 'LSHIFT', Keyboard, 6, -254, u2_25 + 4, u },
            { ',', Keyboard, 147, -254, u, u },
            { 'X', Keyboard, 209, -254, u, u },
            { 'G', Keyboard, 271, -254, u, u },
            { 'V', Keyboard, 333, -254, u, u },
            { 'W', Keyboard, 395, -254, u, u },
            { 'N', Keyboard, 457, -254, u, u },
            { 'I', Keyboard, 519, -254, u, u },
            { ',', Keyboard, 581, -254, u, u },
            { '0', Keyboard, 643, -254, u, u },
            { '9', Keyboard, 705, -254, u, u },
            { 'RSHIFT', Keyboard, 767, -254, u2_75 + 2, u },

        -- 6 row

            { 'LCTRL', Keyboard, 6, -316, u1_5 + 1, u },
            { 'LWIN', Keyboard, 99, -316, u, u },
            { 'LALT', Keyboard, 161, -316, u1_5 + 1, u },
            { 'SPACE', Keyboard, 254, -316, 368, u },
            { 'RALT', Keyboard, 624, -316, u1_5 + 2, u },
            { 'RWIN', Keyboard, 718, -316, u, u },
            { 'MENU', Keyboard, 780, -316, u, u },
            { 'RCTRL', Keyboard, 842, -316, u1_5 + 2, u },   
    },

--

-- RAZER --

    ['Tartarus_v1'] = { 

        { 'TAB', Keyboard, 6, -16, u, u },   
        { 'Q', Keyboard, 68, -6, u, u },
        { 'W', Keyboard, 130, -6, u, u },
        { 'E', Keyboard, 192, -6, u, u },
        { 'R', Keyboard, 254, -6, u, u },
            
        { 'CAPS', Keyboard, 6, -78, u, u },
        { 'A', Keyboard, 68, -68, u, u },
        { 'S', Keyboard, 130, -68, u, u },
        { 'D', Keyboard, 192, -68, u, u },
        { 'F', Keyboard, 254, -68, u, u },
            
        { 'LSHIFT', Keyboard, 6, -140, u, u },
        { 'Z', Keyboard, 68, -130, u, u },
        { 'X', Keyboard, 130, -130, u, u },
        { 'C', Keyboard, 192, -130, u, u },
        { 'V', Keyboard, 254, -130, u, u },
    },

    ['Tartarus_v2'] = { 

        { '1', Keyboard, 6, -16, u, u },   
        { '2', Keyboard, 68, -6, u, u },
        { '3', Keyboard, 130, -6, u, u },
        { '4', Keyboard, 192, -6, u, u },
        { '5', Keyboard, 254, -6, u, u },
                        
        { 'TAB', Keyboard, 6, -78, u, u },
        { 'Q', Keyboard, 68, -68, u, u },
        { 'W', Keyboard, 130, -68, u, u },
        { 'E', Keyboard, 192, -68, u, u },
        { 'R', Keyboard, 254, -68, u, u },
                        
        { 'CAPS', Keyboard, 6, -140, u, u },
        { 'A', Keyboard, 68, -130, u, u },
        { 'S', Keyboard, 130, -130, u, u },
        { 'D', Keyboard, 192, -130, u, u },
        { 'F', Keyboard, 254, -130, u, u },
            
        { 'LSHIFT', Keyboard, 6, -202, u, u },
        { 'Z', Keyboard, 68, -192, u, u },
        { 'X', Keyboard, 130, -192, u, u },
        { 'C', Keyboard, 192, -192, u, u },
    },
        
--

-- AZERON --

    ['Cyborg'] = { 

        { 'I', Keyboard, 130, -6, u, u },
        { 'M', Keyboard, 192, -6, u, u },
        { 'UP', Keyboard, 316, -6, u, u },
                        
        { 'Z', Keyboard, 6, -68, u, u },
        { 'X', Keyboard, 68, -68, u, u },
        { 'C', Keyboard, 130, -68, u, u },
        { 'V', Keyboard, 192, -68, u, u },
        { 'LEFT', Keyboard, 254, -68, u, u },
        { 'T', Keyboard, 316, -68, u, u },
        { 'RIGHT', Keyboard, 378, -68, u, u },
                        
        { 'Q', Keyboard, 6, -130, u, u },
        { 'G', Keyboard, 68, -130, u, u },
        { 'R', Keyboard, 130, -130, u, u },
        { 'E', Keyboard, 192, -130, u, u },
        { 'DOWN', Keyboard, 316, -130, u, u },

        { '1', Keyboard, 6, -192, u, u },
        { '2', Keyboard, 68, -192, u, u },
        { '3', Keyboard, 130, -192, u, u },
        { '4', Keyboard, 192, -192, u, u },
        { 'F', Keyboard, 254, -192, u, u },

        { 'A', Keyboard, 6, -254, u, u },
        { 'ALT', Keyboard, 68, -254, u, u },
        { 'SHIFT', Keyboard, 130, -254, u, u },
        { 'CTRL', Keyboard, 192, -254, u, u },

        { '=', Keyboard, 316, -316, u, u },
        { 'ESC', Keyboard, 378, -316, u, u },
    },

    ['Cyborg_II'] = { 

        { 'UP', Keyboard, 378, -6, u, u },

        { 'Z', Keyboard, 68, -68, u, u },        
        { 'X', Keyboard, 130, -68, u, u },
        { 'C', Keyboard, 192, -68, u, u },
        { 'V', Keyboard, 254, -68, u, u },
        { 'LEFT', Keyboard, 316, -68, u, u },
        { 'T', Keyboard, 378, -68, u, u },
        { 'RIGHT', Keyboard, 440, -68, u, u },

        { 'Q', Keyboard, 68, -130, u, u },
        { 'G', Keyboard, 130, -130, u, u },
        { 'R', Keyboard, 192, -130, u, u },
        { 'E', Keyboard, 254, -130, u, u },
        { 'DOWN', Keyboard, 378, -130, u, u },

        { '0', Keyboard, 6, -192, u, u },
        { '1', Keyboard, 68, -192, u, u },
        { '2', Keyboard, 130, -192, u, u },
        { '3', Keyboard, 192, -192, u, u },
        { '4', Keyboard, 254, -192, u, u },
        { 'F', Keyboard, 316, -192, u, u },
        { 'Z', Keyboard, 502, -192, u, u },

        --{ 'W', Keyboard, 470, -192, u, u },
        --{ 'A', Keyboard, 440, -222, u, u },
        --{ 'S', Keyboard, 470, -254, u, u },
        --{ 'D', Keyboard, 502, -222, u, u },

        { 'A', Keyboard, 68, -254, u, u },
        { 'ALT', Keyboard, 130, -254, u, u },
        { 'SHIFT', Keyboard, 192, -254, u, u },
        { 'CTRL', Keyboard, 254, -254, u, u },
        { 'ESC', Keyboard, 502, -254, u, u },
        
        { 'P', Keyboard, 68, -316, u, u },
        { 'L', Keyboard, 130, -316, u, u },
        { 'I', Keyboard, 192, -316, u, u },
        { 'M', Keyboard, 254, -316, u, u },
        { '=', Keyboard, 378, -316, u, u },
    },

--

}