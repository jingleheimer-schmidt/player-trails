
local rainbowColorSetting = {
    type = "bool-setting",
    name = "player-trail-color",
    setting_type = "runtime-per-user",
    order = "a",
    default_value = true
}

local rainbowGlowSetting = {
    type = "bool-setting",
    name = "player-trail-glow",
    setting_type = "runtime-per-user",
    order = "b",
    default_value = true
}

local rainbowAnimateSetting = {
    type = "bool-setting",
    name = "player-trail-animate",
    setting_type = "runtime-per-user",
    order = "c",
    default_value = true
}

local rainbowTaperSetting = {
    type = "bool-setting",
    name = "player-trail-taper",
    setting_type = "runtime-per-user",
    order = "d",
    default_value = true
}

local rainbowSyncSetting = {
    type = "bool-setting",
    name = "player-trail-sync",
    setting_type = "runtime-per-user",
    order = "e",
    default_value = false
}

local rainbowScaleSetting = {
    type = "string-setting",
    name = "player-trail-scale",
    setting_type = "runtime-per-user",
    order = "f",
    default_value = "5",
    allowed_values = {
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "8",
        "11",
        "20",
    }
}

local rainbowLengthSetting = {
    type = "string-setting",
    name = "player-trail-length",
    setting_type = "runtime-per-user",
    order = "g",
    default_value = "120",
    allowed_values = {
        "15",
        "30",
        "60",
        "90",
        "120",
        "180",
        "210",
        "300",
        "600"
    }
}

local rainbowColorTypeSetting = {
    type = "string-setting",
    name = "player-trail-type",
    setting_type = "runtime-per-user",
    order = "h",
    default_value = "rainbow",
    allowed_values = {
        "player",
        "rainbow"
    }
}

local rainbowPaletteSetting = {
    type = "string-setting",
    name = "player-trail-palette",
    setting_type = "runtime-per-user",
    order = "i",
    default_value = "default",
    allowed_values = {
        "light",
        "pastel",
        "default",
        "vibrant",
        "deep"
    }
}

local rainbowSpeedSetting = {
    type = "string-setting",
    name = "player-trail-speed",
    setting_type = "runtime-per-user",
    order = "j",
    default_value = "default",
    allowed_values = {
        "veryslow",
        "slow",
        "default",
        "fast",
        "veryfast"
    }
}

-- local rainbowTrailsBalance = {
--   type = "string-setting",
--   name = "player-trail-balance",
--   setting_type = "runtime-global",
--   order = "k",
--   default_value = "super-pretty",
--   allowed_values = {
--     -- "super-performance",
--     "performance",
--     "balanced",
--     "pretty",
--     "super-pretty"
--   }
-- }

data:extend({
    rainbowColorSetting,
    rainbowGlowSetting,
    rainbowAnimateSetting,
    rainbowTaperSetting,
    rainbowSyncSetting,
    rainbowScaleSetting,
    rainbowLengthSetting,
    rainbowColorTypeSetting,
    rainbowPaletteSetting,
    rainbowSpeedSetting,
    -- rainbowTrailsBalance
})
