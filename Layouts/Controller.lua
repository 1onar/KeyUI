local name, addon = ...

addon.default_controller_layouts = {

    ['xbox'] = {

        layout_type = "xbox",

        -- LEFT
        { 'PADLTRIGGER',   -380,  459, 50, 50 },
        { 'PADLSHOULDER',  -380,  401, 50, 50 },
        { 'PADLSTICK',     -380,  345, 50, 50 },
        { 'PADDUP',        -380,  289, 50, 50 },
        { 'PADDLEFT',      -380,  233, 50, 50 },
        { 'PADDDOWN',      -380,  178, 50, 50 },
        { 'PADDRIGHT',     -380,  120, 50, 50 },
        { 'PADBACK',       -380,   63, 50, 50 },

        -- RIGHT
        { 'PADRTRIGGER',    380,  459, 50, 50 },
        { 'PADRSHOULDER',   380,  401, 50, 50 },
        { 'PAD4',           380,  345, 50, 50 },    -- Y
        { 'PAD2',           380,  289, 50, 50 },    -- B
        { 'PAD1',           380,  233, 50, 50 },    -- A
        { 'PAD3',           380,  178, 50, 50 },    -- X
        { 'PADRSTICK',      380,  120, 50, 50 },
        { 'PADFORWARD',     380,   63, 50, 50 },

        -- CENTER
        { 'PADSYSTEM',        0,   10, 50, 50 },
    },

    ['ds4'] = {

        layout_type = "ds4",

        -- LEFT
        { 'PADLSHOULDER',   -380,  416, 50, 50 },
        { 'PADLTRIGGER',  -380,  360, 50, 50 },
        { 'PADDUP',        -380,  304, 50, 50 },
        { 'PADDLEFT',      -380,  249, 50, 50 },
        { 'PADDDOWN',      -380,  194, 50, 50 },
        { 'PADDRIGHT',     -380,  140, 50, 50 },
        { 'PADSOCIAL',     -380,   83, 50, 50 },
        { 'PADLSTICK',     -380,   27, 50, 50 },

        -- RIGHT
        { 'PADRSHOULDER',   380,  416, 50, 50 },
        { 'PADRTRIGGER',    380,  360, 50, 50 },
        { 'PAD4',           380,  304, 50, 50 },    -- Triangle
        { 'PAD2',           380,  249, 50, 50 },    -- Circle
        { 'PAD1',           380,  194, 50, 50 },    -- Cross
        { 'PAD3',           380,  140, 50, 50 },    -- Square
        { 'PADFORWARD',     380,   83, 50, 50 },
        { 'PADRSTICK',      380,   27, 50, 50 },

        -- CENTER
        { 'PADBACK',          0,  450, 50, 50 },
        { 'PADSYSTEM',        0,   20, 50, 50 },
    },

    ['ds5'] = {

        layout_type = "ds5",

        -- LEFT
        { 'PADLSHOULDER',   -380,  416, 50, 50 },
        { 'PADLTRIGGER',  -380,  360, 50, 50 },
        { 'PADDUP',        -380,  304, 50, 50 },
        { 'PADDLEFT',      -380,  249, 50, 50 },
        { 'PADDDOWN',      -380,  194, 50, 50 },
        { 'PADDRIGHT',     -380,  140, 50, 50 },
        { 'PADSOCIAL',     -380,   83, 50, 50 },
        { 'PADLSTICK',     -380,   27, 50, 50 },

        -- RIGHT
        { 'PADRSHOULDER',   380,  416, 50, 50 },
        { 'PADRTRIGGER',    380,  360, 50, 50 },
        { 'PAD4',           380,  304, 50, 50 },    -- Triangle
        { 'PAD2',           380,  249, 50, 50 },    -- Circle
        { 'PAD1',           380,  194, 50, 50 },    -- Cross
        { 'PAD3',           380,  140, 50, 50 },    -- Square
        { 'PADFORWARD',     380,   83, 50, 50 },
        { 'PADRSTICK',      380,   27, 50, 50 },

        -- CENTER
        { 'PADBACK',        -50,  450, 50, 50 },
        { 'PAD6',            50,  450, 50, 50 },
        { 'PADSYSTEM',      -50,   50, 50, 50 },
        { 'PAD5',            50,   50, 50, 50 },
    },

    ['deck'] = {

        layout_type = "deck",

        -- LEFT
        { 'PADLTRIGGER',   -380,  524, 50, 50 },
        { 'PADLSHOULDER',  -380,  468, 50, 50 },
        { 'PADLSTICK',     -380,  412, 50, 50 },
        { 'PADDUP',        -380,  356, 50, 50 },
        { 'PADDLEFT',      -380,  300, 50, 50 },
        { 'PADDDOWN',      -380,  244, 50, 50 },
        { 'PADDRIGHT',     -380,  188, 50, 50 },
        { 'PADBACK',       -380,  132, 50, 50 },
        { 'PADPADDLE1',    -380,   76, 50, 50 },
        { 'PADPADDLE2',    -380,   20, 50, 50 },

        -- RIGHT
        { 'PADRTRIGGER',    380,  524, 50, 50 },
        { 'PADRSHOULDER',   380,  468, 50, 50 },
        { 'PADRSTICK',      380,  412, 50, 50 },    -- A
        { 'PAD1',           380,  356, 50, 50 },    -- B
        { 'PAD2',           380,  300, 50, 50 },    -- X
        { 'PAD3',           380,  244, 50, 50 },    -- Y
        { 'PAD4',           380,  188, 50, 50 },
        { 'PADFORWARD',     380,  132, 50, 50 },
        { 'PADPADDLE3',     380,   76, 50, 50 },
        { 'PADPADDLE4',     380,   20, 50, 50 },

    }
}