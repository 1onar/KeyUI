local name, addon = ...

addon.default_controller_layouts = {

    ['xbox'] = {

        layout_type = "xbox",

        -- LEFT
        { 'PADLTRIGGER',    -380,  220, 50, 50 },
        { 'PADLSHOULDER',   -380,  162, 50, 50 },
        { 'PADLSTICK',      -380,  106, 50, 50 },
        { 'PADDUP',         -380,   50, 50, 50 },
        { 'PADDLEFT',       -380,   -6, 50, 50 },
        { 'PADDDOWN',       -380,  -62, 50, 50 },
        { 'PADDRIGHT',      -380, -118, 50, 50 },
        { 'PADBACK',        -380, -176, 50, 50 },

        -- RIGHT
        { 'PADRTRIGGER',    380,  220, 50, 50 },
        { 'PADRSHOULDER',   380,  162, 50, 50 },
        { 'PAD4',           380,  106, 50, 50 },    -- Y
        { 'PAD2',           380,   50, 50, 50 },    -- B
        { 'PAD1',           380,   -6, 50, 50 },    -- A
        { 'PAD3',           380,  -62, 50, 50 },    -- X
        { 'PADRSTICK',      380, -118, 50, 50 },
        { 'PADFORWARD',     380, -176, 50, 50 },

        -- CENTER
        { 'PADSYSTEM',      0,  -234, 50, 50 },
    }
}