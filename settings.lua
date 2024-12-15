
---@type data.ModBoolSettingPrototype
local sprite = {
    type = "bool-setting",
    name = "player-trail-color",
    setting_type = "runtime-per-user",
    order = "a",
    default_value = true,
    hidden = true,
    forced_value = true
}

---@type data.ModBoolSettingPrototype
local light = {
    type = "bool-setting",
    name = "player-trail-glow",
    setting_type = "runtime-per-user",
    order = "b",
    default_value = true,
    hidden = true,
    forced_value = true
}

---@type data.ModBoolSettingPrototype
local animate = {
    type = "bool-setting",
    name = "player-trail-animate",
    setting_type = "runtime-per-user",
    order = "c",
    default_value = true
}

---@type data.ModBoolSettingPrototype
local taper = {
    type = "bool-setting",
    name = "player-trail-taper",
    setting_type = "runtime-per-user",
    order = "d",
    default_value = true
}

---@type data.ModStringSettingPrototype
local scale = {
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

---@type data.ModStringSettingPrototype
local length = {
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

---@type data.ModStringSettingPrototype
local color_type = {
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

---@type data.ModStringSettingPrototype
local theme = {
    type = "string-setting",
    name = "player-trail-theme",
    setting_type = "runtime-per-user",
    order = "i",
    default_value = "default",
    allowed_values = {
        -- original continuous themes
        "light",
        "pastel",
        "default",
        "vibrant",
        "deep",
        -- stepwise pride flag themes
        "lesbian",
        "gay",
        "bi",
        "trans",
        "pan",
        "ace",
        "nonbinary",
        "agender",
        "progress",
        -- stepwise country flag themes
        "united nations",
        "china",
        "india",
        "united states",
        "indonesia",
        "pakistan",
        "nigeria",
        "brazil",
        "bangladesh",
        "russia",
        "mexico",
        "japan",
        "philippines",
        "ethiopia",
        "egypt",
        "vietnam",
        "democratic republic of the congo",
        "turkey",
        "iran",
        "germany",
        "thailand",
        "france",
        "united kingdom",
        "tanzania",
        "south africa",
        "italy",
        "ukraine",
        "australia",
        "netherlands",
        "belgium",
        "cuba",
        "czech republic",
        "greece",
        "sweden",
    }
}

---@type data.ModStringSettingPrototype
local speed = {
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

---@type data.ModBoolSettingPrototype
local enabled = {
    type = "bool-setting",
    name = "player-trail-enabled",
    setting_type = "runtime-per-user",
    order = "a",
    default_value = true
}

data:extend({
    sprite,
    light,
    animate,
    taper,
    scale,
    length,
    color_type,
    theme,
    speed,
    enabled
})
