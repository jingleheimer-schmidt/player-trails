
--[[
Player Trails control script © 2024 by asher_sky is licensed under Attribution-NonCommercial-ShareAlike 4.0 International
See LICENSE.txt for additional information
--]]

local speeds = {
    veryslow = 0.010,
    slow = 0.020,
    default = 0.040,
    fast = 0.080,
    veryfast = 0.100,
}

local palette = {
    light = { amplitude = 15, center = 240 },      -- light
    pastel = { amplitude = 55, center = 200 },     -- pastel <3
    default = { amplitude = 127.5, center = 127.5 }, -- default (nyan)
    vibrant = { amplitude = 50, center = 100 },    -- muted
    deep = { amplitude = 25, center = 50 },        -- dark
}

local sin = math.sin
local pi_div_3 = math.pi / 3
local pi_0_3 = 0 * pi_div_3
local pi_2_3 = 2 * pi_div_3
local pi_4_3 = 4 * pi_div_3

---@param player_index uint
---@param created_tick uint
---@param game_tick uint
---@param frequency number
---@param amplitude number
---@param center number
---@return Color
local function make_optimized_rainbow(player_index, created_tick, game_tick, frequency, amplitude, center)
    local freakmod = frequency * (game_tick + (player_index * created_tick))
    return {
        r = sin(freakmod + pi_0_3) * amplitude + center,
        g = sin(freakmod + pi_2_3) * amplitude + center,
        b = sin(freakmod + pi_4_3) * amplitude + center,
        a = 255,
    }
end

---@param index integer
local function initialize_settings(index)
    local player_settings = settings.get_player_settings(index)
    if not player_settings then return end
    --[[@type table<integer, trail_segment_data>]]
    storage.trail_data = storage.trail_data or {}
    --[[@type table<integer, table<string, boolean|string|number|Color>>]]
    storage.settings = {}
    storage.settings[index] = {}
    storage.settings[index]["player-trail-glow"] = player_settings["player-trail-glow"].value
    storage.settings[index]["player-trail-color"] = player_settings["player-trail-color"].value
    storage.settings[index]["player-trail-animate"] = player_settings["player-trail-animate"].value
    storage.settings[index]["player-trail-length"] = player_settings["player-trail-length"].value
    storage.settings[index]["player-trail-scale"] = player_settings["player-trail-scale"].value
    storage.settings[index]["player-trail-speed"] = player_settings["player-trail-speed"].value
    storage.settings[index]["player-trail-sync"] = player_settings["player-trail-sync"].value
    storage.settings[index]["player-trail-palette"] = player_settings["player-trail-palette"].value
    storage.settings[index]["player-trail-taper"] = player_settings["player-trail-taper"].value
    storage.settings[index]["player-trail-type"] = player_settings["player-trail-type"].value
end

---@param pos1 MapPosition
---@param pos2 MapPosition
---@return number
local function distance(pos1, pos2)
    local x1, y1, x2, y2 = pos1.x, pos1.y, pos2.x, pos2.y
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

---@param draw_type "sprite"|"light"
---@param player LuaPlayer
---@param position MapPosition
---@param length number
---@param scale number
---@param event_tick uint
---@param player_index uint
---@param frequency number
---@param amplitude number
---@param center number
---@param color Color
local function create_trail_render_object(draw_type, player, position, length, scale, event_tick, player_index, frequency, amplitude, center, color)
    local is_sprite = draw_type == "sprite"
    local is_light = draw_type == "light"
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
        params.intensity = 0.1
        params.scale = scale
        params.render_layer = "light-effect"
    end
    local render_object = is_sprite and rendering.draw_sprite(params) or rendering.draw_light(params)
    storage.trail_data = storage.trail_data or {}
    storage.trail_data[render_object.id] = {
        render_id = render_object.id,
        render_object = render_object,
        sprite = is_sprite,
        light = is_light,
        tick_to_die = event_tick + length,
        scale = scale,
        max_scale = scale,
        tick = event_tick,
        player_index = player_index,
        frequency = frequency,
        amplitude = amplitude,
        center = center,
    }
    render_object.color = color
end

---@param player LuaPlayer
---@param player_settings table
---@param event_tick uint
---@param frequency number
---@param amplitude number
---@param center number
---@return Color
local function get_trail_color(player, player_settings, event_tick, frequency, amplitude, center)
    local rainbow_color = player.color
    if player_settings["player-trail-type"] == "rainbow" then
        local created_tick = player_settings["player-trail-sync"] and player.index or event_tick
        rainbow_color = make_optimized_rainbow(player.index, created_tick, event_tick, frequency, amplitude, center)
    end
    return rainbow_color
end

--- Draw a new sprite and/or light trail segment if the player moved enough.
---@param player LuaPlayer
local function draw_new_trail_segment(player)
    local player_index = player.index
    if not (storage.settings and storage.settings[player_index]) then
        initialize_settings(player_index)
    end
    if player.controller_type ~= defines.controllers.character and not game.simulation then
        return
    end
    local position = player.position
    storage.last_render_positions = storage.last_render_positions or {}
    local last_position = storage.last_render_positions[player_index] or position
    if distance(last_position, position) <= 0.33 then
        return
    end
    storage.last_render_positions[player_index] = position
    local player_settings = storage.settings[player_index]
    local draw_sprite = player_settings["player-trail-color"]
    local draw_light = player_settings["player-trail-glow"]
    if not (draw_sprite or draw_light) then
        return
    end
    local event_tick = game.tick
    local length = tonumber(player_settings["player-trail-length"]) --[[@as integer]]
    local scale = tonumber(player_settings["player-trail-scale"]) --[[@as integer]]
    local frequency = speeds[player_settings["player-trail-speed"]] --[[@as number]]
    local palette_data = palette[player_settings["player-trail-palette"]] --[[@as {amplitude:number, center:number}]]
    local amplitude, center = palette_data.amplitude, palette_data.center

    -- Determine the color (rainbow or static) once, reuse for both sprite and light
    local trail_color = get_trail_color(player, player_settings, event_tick, frequency, amplitude, center)
    if draw_sprite then
        create_trail_render_object("sprite", player, position, length, scale, event_tick, player_index, frequency, amplitude, center, trail_color)
    end
    if draw_light then
        create_trail_render_object("light", player, position, length, scale, event_tick, player_index, frequency, amplitude, center, trail_color)
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
---@field amplitude number
---@field center number

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
    if player_settings["player-trail-animate"] and player_settings["player-trail-type"] == "rainbow" then
        local created_tick = player_settings["player-trail-sync"] and player_index or trail_data.tick
        local rainbow_color = make_optimized_rainbow(player_index, created_tick, current_tick, trail_data.frequency, trail_data.amplitude, trail_data.center)
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

---runs every tick to update the rainbow color animation and taper
---@param event EventData.on_tick
local function on_tick(event)
    for _, player in pairs(game.connected_players) do
        draw_new_trail_segment(player)
    end
    animate_existing_trails()
    if game.simulation then
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

-- script.on_event(defines.events.on_player_changed_position, player_changed_position)

script.on_event(defines.events.on_tick, on_tick)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
