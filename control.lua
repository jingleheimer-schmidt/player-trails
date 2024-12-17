
--[[
Player Trails control script © 2024 by asher_sky is licensed under Attribution-NonCommercial-ShareAlike 4.0 International
See LICENSE.txt for additional information
--]]

---@type {string: number}
local speeds = {
    veryslow = 0.010,
    slow = 0.025,
    default = 0.050,
    fast = 0.100,
    veryfast = 0.200,
}

---@type {string: {amplitude: float, center: float}}
local continuous_themes = {
    ["light"] = { amplitude = 15, center = 240 },
    ["pastel"] = { amplitude = 55, center = 200 },
    ["default"] = { amplitude = 127.5, center = 127.5 },
    ["vibrant"] = { amplitude = 50, center = 100 },
    ["deep"] = { amplitude = 25, center = 50 },
}

require("util")

---@type {string: Color[]}
local pride_flag_themes = {
    ["trans"] = {          -- trans pride
        util.color("#5BCEFA"), -- light blue
        util.color("#F5A9B8"), -- light pink
        util.color("#FFFFFF"), -- white
        -- util.color("#F5A9B8"), -- light pink
        -- util.color("#5BCEFA"), -- light blue
        -- util.color("#FFFFFF"), -- white
    },
    ["lesbian"] = {        -- lesbian pride
        util.color("#D52D00"), -- dark orange
        util.color("#EF7627"), -- mid orange
        util.color("#FF9A56"), -- light orange
        util.color("#FFFFFF"), -- white
        util.color("#D162A4"), -- light pink
        util.color("#B55690"), -- mid pink
        util.color("#A30262"), -- dark pink
    },
    ["bi"] = {             -- bi pride
        util.color("#D60270"), -- pink
        util.color("#D60270"), -- pink
        util.color("#9B4F96"), -- purple
        util.color("#0038A8"), -- blue
        util.color("#0038A8"), -- blue
    },
    ["nonbinary"] = {      -- nonbinary pride
        util.color("#FCF434"), -- yellow
        util.color("#FFFFFF"), -- white
        util.color("#9C59D1"), -- purple
        util.color("#000000"), -- black
    },
    ["pan"] = {            -- pan pride
        util.color("#FF218C"), -- pink
        util.color("#FFD800"), -- yellow
        util.color("#21B1FF"), -- blue
    },
    ["ace"] = {            -- ace pride
        util.color("#000000"), -- black
        util.color("#A3A3A3"), -- grey
        util.color("#FFFFFF"), -- white
        util.color("#800080"), -- purple
    },
    ["progress"] = {       -- progress pride
        util.color("#FFFFFF"), -- white
        util.color("#FFAFC8"), -- pink
        util.color("#74D7EE"), -- light blue
        util.color("#613915"), -- brown
        util.color("#000000"), -- black
        util.color("#E40303"), -- red
        util.color("#FF8C00"), -- orange
        util.color("#FFED00"), -- yellow
        util.color("#008026"), -- green
        util.color("#24408E"), -- blue
        util.color("#732982"), -- purple
    },
    ["agender"] = {        -- agender pride
        util.color("#000000"), -- black
        util.color("#BCC4C7"), -- grey
        util.color("#FFFFFF"), -- white
        util.color("#B7F684"), -- green
        -- util.color("#FFFFFF"), -- white
        -- util.color("#BCC4C7"), -- grey
        -- util.color("#000000"), -- black
    },
    ["gay"] = {            -- gay pride
        util.color("#078D70"), -- dark green
        util.color("#26CEAA"), -- medium green
        util.color("#98E8C1"), -- light green
        util.color("#FFFFFF"), -- white
        util.color("#7BADE2"), -- light blue
        util.color("#5049CC"), -- indigo
        util.color("#3D1A78"), -- dark blue
    }
}

---@type {string: Color[]}
local country_flag_themes = {
    ["united nations"] = {                   -- population 7.4 billion, rank 0
        util.color("#019EDB"),               -- blue
        util.color("#019EDB"),               -- blue
        util.color("#019EDB"),               -- blue
        util.color("#FFFFFF"),               -- white
        util.color("#019EDB"),               -- blue
        util.color("#019EDB"),               -- blue
        util.color("#019EDB"),               -- blue
    },
    ["china"] = {                            -- population 1.4 billion, rank 1
        util.color("#EE1C25"),               -- red
        util.color("#FFFF00"),               -- yellow
    },
    ["india"] = {                            -- population 1.3 billion, rank 2
        util.color("#FF9933"),               -- saffron
        util.color("#FFFFFF"),               -- white
        util.color("#138808"),               -- green
    },
    ["united states"] = {                    -- population 335 million, rank 3
        util.color("#B31942"),               -- red
        util.color("#FFFFFF"),               -- white
        util.color("#0A3161"),               -- blue
    },
    ["indonesia"] = {                        -- population 277 million, rank 4
        util.color("#ED1C24"),               -- red
        util.color("#FFFFFF"),               -- white
    },
    ["pakistan"] = {                         -- population 220 million, rank 5
        util.color("#FFFFFF"),               -- white
        util.color("#00401A"),               -- dark green
        util.color("#00401A"),               -- dark green
    },
    ["nigeria"] = {                          -- population 216 million, rank 6
        util.color("#008753"),               -- green
        util.color("#FFFFFF"),               -- white
        util.color("#008753"),               -- green
    },
    ["brazil"] = {                           -- population 203 million, rank 7
        util.color("#009739"),               -- green
        util.color("#FEDD00"),               -- yellow
        util.color("#FFFFFF"),               -- white
        util.color("#012169"),               -- blue
    },
    ["bangladesh"] = {                       -- population 162 million, rank 8
        util.color("#006a4e"),               -- green
        util.color("#f42a41"),               -- red
        util.color("#006A4E"),               -- green
    },
    ["russia"] = {                           -- population 146 million, rank 9
        util.color("#FFFFFF"),               -- white
        util.color("#1C3578"),               -- blue
        util.color("#E4181C"),               -- red
    },
    ["mexico"] = {                           -- population 129 million, rank 10
        util.color("#006341"),               -- dark green
        util.color("#FFFFFF"),               -- white
        util.color("#C8102E"),               -- red
    },
    ["japan"] = {                            -- population 124 million, rank 11
        util.color("#BC002D"),               -- red
        util.color("#FFFFFF"),               -- white
    },
    ["philippines"] = {                      -- population 110 million, rank 12
        util.color("#0038A8"),               -- blue
        util.color("#CE1126"),               -- red
        util.color("#FFFFFF"),               -- white
    },
    ["ethiopia"] = {                         -- population 105 million, rank 13
        util.color("#098930"),               -- yellow
        util.color("#FCDD0C"),               -- yellow
        util.color("#DA131B"),               -- yellow
    },
    ["egypt"] = {                            -- population 102 million, rank 14
        util.color("#CE1126"),               -- red
        util.color("#FFFFFF"),               -- white
        util.color("#000000"),               -- black
    },
    ["vietnam"] = {                          -- population 97 million, rank 15
        util.color("#DA251D"),               -- red
        util.color("#FFFF00"),               -- yellow
    },
    ["democratic republic of the congo"] = { -- population 89 million, rank 16
        util.color("#007FFF"),               -- blue
        util.color("#CE1021"),               -- red
        util.color("#F7D618"),               -- yellow
    },
    ["turkey"] = {                           -- population 84 million, rank 17
        util.color("#E30A17"),               -- red
        util.color("#FFFFFF"),               -- white
    },
    ["iran"] = {                             -- population 84 million, rank 18
        util.color("#239f40"),               -- green
        util.color("#FFFFFF"),               -- white
        util.color("#DA0000"),               -- red
    },
    ["germany"] = {                          -- population 84 million, rank 19
        util.color("#000000"),               -- schwarz
        util.color("#DD0000"),               -- rot
        util.color("#FFCE00"),               -- gold
    },
    ["thailand"] = {                         -- population 68 million, rank 20
        util.color("#A51931"),               -- red
        util.color("#F4F5F8"),               -- white
        util.color("#2D2A4A"),               -- blue
        util.color("#2D2A4A"),               -- blue
        util.color("#F4F5F8"),               -- white
        util.color("#A51931"),               -- red
    },
    ["france"] = {                           -- population 68 million, rank 21
        util.color("#0055A4"),               -- blue
        util.color("#FFFFFF"),               -- white
        util.color("#EF4135"),               -- red
    },
    ["united kingdom"] = {                   -- population 67 million, rank 22
        util.color("#FFFFFF"),               -- white
        util.color("#C8102E"),               -- red
        util.color("#012169"),               -- blue
    },
    ["tanzania"] = {                         -- population 61 million, rank 23
        util.color("#1FB53A"),               -- green
        util.color("#1FB53A"),               -- green
        util.color("#FCD116"),               -- yellow
        util.color("#000000"),               -- black
        util.color("#000000"),               -- black
        util.color("#FCD116"),               -- yellow
        util.color("#01A2DD"),               -- blue
        util.color("#01A2DD"),               -- blue
    },
    ["south africa"] = {                     -- population 60 million, rank 24
        util.color("#000000"),               -- black
        util.color("#FFB612"),               -- gold
        util.color("#007A4D"),               -- green
        util.color("#FFFFFF"),               -- white
        util.color("#DE3831"),               -- red
        util.color("#007A4D"),               -- green
        util.color("#FFFFFF"),               -- white
        util.color("#002395"),               -- blue
    },
    ["italy"] = {                            -- population 58 million, rank 25
        util.color("#008C45"),               -- green
        util.color("#F4F5F0"),               -- white
        util.color("#CD212A"),               -- red
    },
    ["ukraine"] = {                          -- population 41 million, rank 36
        util.color("#0057B7"),               -- blue
        util.color("#FFDD00"),               -- yellow
    },
    ["australia"] = {                        -- population 26 million, rank 53
        util.color("#00008B"),               -- blue
        util.color("#FFFFFF"),               -- white
        util.color("#FF0000"),               -- red
    },
    ["netherlands"] = {                      -- population 17 million, rank 67
        util.color("#AD1D25"),               -- red
        util.color("#FFFFFF"),               -- white
        util.color("#1E4785"),               -- blue
    },
    ["belgium"] = {                          -- population 11 million, rank 82
        util.color("#000000"),               -- black
        util.color("#FDDA24"),               -- yellow
        util.color("#EF3340"),               -- red
    },
    ["cuba"] = {                             -- population 11 million, rank 85
        util.color("#D21034"),               -- red
        util.color("#002590"),               -- blue
        util.color("#FFFFFF"),               -- white
    },
    ["czech republic"] = {                   -- population 10 million, rank 86
        util.color("#11457E"),               -- blue
        util.color("#FFFFFF"),               -- white
        util.color("#D7141A"),               -- red
    },
    ["greece"] = {                           -- population 10 million, rank 89
        util.color("#004C98"),               -- blue
        util.color("#FFFFFF"),               -- white
    },
    ["sweden"] = {                           -- population 10 million, rank 87
        util.color("#006AA7"),               -- blue
        util.color("#FECC02"),               -- yellow
    }
}

---@type {string: Color[]}
local stepwise_themes = {}
for name, colors in pairs(pride_flag_themes) do
    stepwise_themes[name] = colors
end
for name, colors in pairs(country_flag_themes) do
    stepwise_themes[name] = colors
end

local sin = math.sin
local sqrt = math.sqrt
local floor = math.floor
local pi_0 = 0 * math.pi / 3
local pi_2 = 2 * math.pi / 3
local pi_4 = 4 * math.pi / 3

---@param game_tick integer
---@param frequency number
---@param theme_name string
---@param player_index uint
---@return Color
local function get_rainbow_color(game_tick, created_tick, player_index, frequency, theme_name)
    local modifier = frequency * (game_tick + (player_index * created_tick))
    local continuous_theme = continuous_themes[theme_name]
    local stepwise_theme = stepwise_themes[theme_name]
    if continuous_theme then
        local amplitude = continuous_theme.amplitude
        local center = continuous_theme.center
        return {
            r = sin(modifier + pi_4) * amplitude + center,
            g = sin(modifier + pi_2) * amplitude + center,
            b = sin(modifier + pi_0) * amplitude + center,
            a = 255,
        }
    elseif stepwise_theme then
        -- Handle stepwise themes
        local sharpness = 0.8
        local count = #stepwise_theme
        if count == 0 then
            return { 1, 1, 1 } -- Default to white if the theme is empty
        end

        -- Determine the current base and next indices
        local base_index = floor(modifier % count) + 1
        local next_index = (base_index % count) + 1

        -- Time within the current step (0 to 1)
        local step_time = modifier % 1

        -- Adjust interpolation timing based on sharpness
        local t
        if step_time < sharpness then
            t = 0 -- Hold the base color
        else
            t = (step_time - sharpness) / (1 - sharpness) -- Smoothly interpolate at the end
        end

        -- Base and next colors
        local base_color = stepwise_theme[base_index]
        local next_color = stepwise_theme[next_index]

        -- Interpolate only when transitioning
        return {
            r = base_color.r * (1 - t) + next_color.r * t,
            g = base_color.g * (1 - t) + next_color.g * t,
            b = base_color.b * (1 - t) + next_color.b * t,
        }
    else
        return { 1, 1, 1 }
    end
end

---@param index integer
local function initialize_settings(index)
    --[[@type table<integer, trail_segment_data>]]
    storage.trail_data = storage.trail_data or {}
    --[[@type table<integer, table<string, boolean|string|number|Color>>]]
    storage.settings = storage.settings or {}
    local player_settings = settings.get_player_settings(index)
    if not player_settings then return end
    storage.settings[index] = {}
    storage.settings[index]["player-trail-enabled"] = player_settings["player-trail-enabled"].value
    storage.settings[index]["player-trail-glow"] = player_settings["player-trail-glow"].value
    storage.settings[index]["player-trail-color"] = player_settings["player-trail-color"].value
    storage.settings[index]["player-trail-animate"] = player_settings["player-trail-animate"].value
    storage.settings[index]["player-trail-length"] = player_settings["player-trail-length"].value
    storage.settings[index]["player-trail-scale"] = player_settings["player-trail-scale"].value
    storage.settings[index]["player-trail-speed"] = player_settings["player-trail-speed"].value
    storage.settings[index]["player-trail-theme"] = player_settings["player-trail-theme"].value
    storage.settings[index]["player-trail-taper"] = player_settings["player-trail-taper"].value
    storage.settings[index]["player-trail-type"] = player_settings["player-trail-type"].value
end

---@param pos1 MapPosition
---@param pos2 MapPosition
---@return number
local function distance(pos1, pos2)
    local x1, y1, x2, y2 = pos1.x, pos1.y, pos2.x, pos2.y
    return sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

---@param draw_type "sprite"|"light"
---@param player LuaPlayer
---@param position MapPosition
---@param length number
---@param scale number
---@param event_tick uint
---@param player_index uint
---@param frequency number
---@param theme_name string
---@param color Color
local function create_trail_render_object(draw_type, player, position, length, scale, event_tick, player_index, frequency, theme_name, color)
    local is_sprite = draw_type == "sprite"
    local is_light = draw_type == "light"
    scale = is_light and scale * 1.5 or scale
    local params = {
        sprite = "player-trail",
        target = position,
        surface = player.surface,
        time_to_live = length
    }
    if is_sprite then
        params.x_scale = scale
        params.y_scale = scale
        params.render_layer = "radius-visualization"
    elseif is_light then
        params.intensity = 0.2 / scale
        params.scale = scale
        params.render_layer = "light-effect"
    end
    local render_object = is_sprite and rendering.draw_sprite(params) or rendering.draw_light(params)
    local object_id = render_object.id
    storage.trail_data = storage.trail_data or {}
    storage.trail_data[object_id] = {
        render_id = object_id,
        render_object = render_object,
        sprite = is_sprite,
        light = is_light,
        tick_to_die = event_tick + length,
        scale = scale,
        max_scale = scale,
        tick = event_tick,
        player_index = player_index,
        frequency = frequency,
        theme_name = theme_name
    }
    render_object.color = color
end

---@param player LuaPlayer
---@param player_settings table
---@param event_tick uint
---@param created_tick uint
---@param frequency number
---@param theme_name string
---@return Color
local function get_trail_color(player, player_settings, event_tick, created_tick, frequency, theme_name)
    local rainbow_color = player.color
    if player_settings["player-trail-type"] == "rainbow" then
        rainbow_color = get_rainbow_color(event_tick, created_tick, player.index, frequency, theme_name)
    end
    return rainbow_color
end

--- Draw a new sprite and/or light trail segment if the player moved enough.
---@param player LuaPlayer
---@param character LuaEntity
local function draw_new_trail_segment(player, character)
    local player_index = player.index
    if not (storage.settings and storage.settings[player_index]) then
        initialize_settings(player_index)
    end
    if player.controller_type ~= defines.controllers.character and not game.simulation then
        return
    end
    local player_settings = storage.settings[player_index]
    if not player_settings["player-trail-enabled"] then
        return
    end
    local position = character.position
    local character_index = character.unit_number --[[@as integer]]
    storage.last_render_positions = storage.last_render_positions or {}
    storage.last_render_positions[character_index] = storage.last_render_positions[character_index] or position
    local last_position = storage.last_render_positions[character_index]
    if distance(last_position, position) <= 0.29 then
        return
    end
    storage.last_render_positions[character_index] = position
    local draw_sprite = player_settings["player-trail-color"]
    local draw_light = player_settings["player-trail-glow"]
    if not (draw_sprite or draw_light) then
        return
    end
    local event_tick = game.tick
    local length = tonumber(player_settings["player-trail-length"]) --[[@as integer]]
    local scale = tonumber(player_settings["player-trail-scale"]) --[[@as integer]]
    local speed = speeds[player_settings["player-trail-speed"]] --[[@as number]]
    local frequency = speed / 5
    local theme_name = player_settings["player-trail-theme"] --[[@as string]]

    -- Determine the color (rainbow or static) once, reuse for both sprite and light
    local trail_color = get_trail_color(player, player_settings, event_tick, event_tick, frequency, theme_name)
    if draw_sprite then
        create_trail_render_object("sprite", player, position, length, scale, event_tick, player_index, frequency, theme_name, trail_color)
    end
    if draw_light then
        create_trail_render_object("light", player, position, length, scale, event_tick, player_index, frequency, theme_name, trail_color)
    end
end

---@class trail_segment_data
---@field render_id uint
---@field render_object LuaRenderObject
---@field sprite boolean
---@field light boolean
---@field tick_to_die uint
---@field scale uint
---@field max_scale uint
---@field tick uint
---@field player_index uint
---@field frequency number
---@field theme_name string

---@param trail_data trail_segment_data
---@param current_tick uint
local function animate_existing_trail(trail_data, current_tick)
    local render_object = trail_data.render_object
    local player_index = trail_data.player_index
    local player_settings = storage.settings[player_index]
    if player_settings["player-trail-taper"] then
        local scale = trail_data.scale
        scale = scale - scale / trail_data.max_scale / 10
        if trail_data.sprite then
            render_object.x_scale = scale
            render_object.y_scale = scale
        else
            render_object.scale = scale
        end
        trail_data.scale = scale
    end
    if player_settings["player-trail-animate"] and (player_settings["player-trail-type"] == "rainbow") then
        local rainbow_color = get_rainbow_color(current_tick, trail_data.tick, player_index, trail_data.frequency, trail_data.theme_name)
        render_object.color = rainbow_color
    end
end

local function animate_existing_trails()
    local current_tick = game.tick
    if not (current_tick % 3 == 0) then return end
    local next_tick = current_tick + 1
    for id, trail_data in pairs(storage.trail_data) do
        if trail_data.tick_to_die <= next_tick then
            storage.trail_data[id] = nil
        else
            animate_existing_trail(trail_data, current_tick)
        end
    end
end

---@param player LuaPlayer
---@return LuaEntity?
local function get_player_entity(player)
    if player.controller_type == defines.controllers.character then
        return player.character
    elseif player.controller_type == defines.controllers.cutscene then
        return player.cutscene_character
    elseif player.vehicle then
        return player.vehicle
    else
        local characters = player.get_associated_characters()
        if characters and #characters > 0 then
            return characters[1]
        end
    end
end

local function update_simulation_trails()
    if not storage.characters or ((game.tick % 30 == 0) and not next(storage.characters)) then
        storage.characters = {}
        for _, surface in pairs(game.surfaces) do
            for _, character in pairs(surface.find_entities_filtered { type = "character" }) do
                if character and character.valid then
                    local player = character.player or character.associated_player or character.last_user or game.get_player(1)
                    if player and player.valid then
                        storage.characters[character.unit_number] = { player = player, character = character }
                    end
                end
            end
        end
    end
    for id, character_data in pairs(storage.characters) do
        local player = character_data.player
        local character = character_data.character
        if player and player.valid and character and character.valid then
            draw_new_trail_segment(player, character)
        else
            storage.characters[id] = nil
        end
    end
end

---@param event EventData.on_tick
local function on_tick(event)
    for _, player in pairs(game.connected_players) do
        local character = get_player_entity(player)
        if character and character.valid then
            draw_new_trail_segment(player, character)
        end
    end
    animate_existing_trails()
    if game.simulation then
        update_simulation_trails()
    end
end

---@param event EventData.on_runtime_mod_setting_changed
local function on_runtime_mod_setting_changed(event)
    if event.setting:match("^player%-trail%-") then
        initialize_settings(event.player_index)
    end
end

---@param event ConfigurationChangedData
local function on_configuration_changed(event)
    for _, player in pairs(game.players) do
        initialize_settings(player.index)
    end
end

---@param event EventData.on_player_joined_game
local function on_player_joined_game(event)
    initialize_settings(event.player_index)
end

script.on_event(defines.events.on_tick, on_tick)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
