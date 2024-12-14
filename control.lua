
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

--- make a rainbow color
---@param player_index uint
---@param created_tick uint
---@param game_tick uint
---@param player_settings table
---@return Color
local function make_rainbow(player_index, created_tick, game_tick, player_settings)
    -- local player_index = rainbow.player_index
    -- local created_tick = rainbow.tick
    -- local player_settings = settings[index]
    local frequency = speeds[player_settings["player-trail-speed"]]
    if player_settings["player-trail-sync"] == true then
        created_tick = player_index
    end
    -- local modifier = (game_tick)+(player_index*created_tick)
    local palette_key = player_settings["player-trail-palette"]
    local amplitude = palette[palette_key].amplitude
    local center = palette[palette_key].center
    return make_optimized_rainbow(player_index, created_tick, game_tick, frequency, amplitude, center)
end

---@param index integer
local function initialize_settings(index)
    local player_settings = settings.get_player_settings(index)
    if not player_settings then return end
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
    storage.sprites = storage.sprites or {}
    storage.lights = storage.lights or {}
end

---@param pos1 MapPosition
---@param pos2 MapPosition
---@return number
local function distance(pos1, pos2)
    local x1, y1, x2, y2 = pos1.x, pos1.y, pos2.x, pos2.y
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

--- draw a new sprite and light
---@param player LuaPlayer
local function draw_new_trail_segment(player)
    local player_index = player.index
    if not (storage.settings and storage.settings[player_index]) then
        initialize_settings(player.index)
    end
    if (player.controller_type == defines.controllers.character) or game.simulation then
        local position = player.position
        storage.last_render_positions = storage.last_render_positions or {}
        storage.last_render_positions[player_index] = storage.last_render_positions[player_index] or position
        local last_render_position = storage.last_render_positions[player_index]
        if distance(last_render_position, position) > 0.33 then
            local player_settings = storage.settings[player_index]
            local draw_sprite = player_settings["player-trail-color"]
            local draw_light = player_settings["player-trail-glow"]
            local event_tick = game.tick
            if draw_sprite or draw_light then
                local length = tonumber(player_settings["player-trail-length"]) --[[@as integer]]
                local scale = tonumber(player_settings["player-trail-scale"]) --[[@as integer]]
                if draw_sprite then
                    local render_object = rendering.draw_sprite {
                        sprite = "player-trail",
                        target = player.position,
                        surface = player.surface,
                        x_scale = scale,
                        y_scale = scale,
                        render_layer = "radius-visualization",
                        time_to_live = length,
                    }
                    local render_object_id = render_object.id
                    --[[@type table<integer, rainbow_data>]]
                    storage.sprites = storage.sprites or {}
                    storage.sprites[render_object_id] = {
                        render_id = render_object_id,
                        render_object = render_object,
                        sprite = true,
                        light = false,
                        tick_to_die = event_tick + length,
                        scale = scale,
                        max_scale = scale,
                        tick = event_tick,
                        player_index = player_index,
                        frequency = speeds[player_settings["player-trail-speed"]],
                        amplitude = palette[player_settings["player-trail-palette"]].amplitude,
                        center = palette[player_settings["player-trail-palette"]].center,
                    }
                    local rainbow_color = player.color
                    if player_settings["player-trail-type"] == "rainbow" then
                        rainbow_color = make_rainbow(player_index, event_tick, event_tick, player_settings)
                    end
                    render_object.color = rainbow_color
                end
                if draw_light then
                    local render_object = rendering.draw_light {
                        sprite = "player-trail",
                        target = player.position,
                        surface = player.surface,
                        intensity = .1,
                        scale = scale,
                        render_layer = "light-effect",
                        time_to_live = length,
                    }
                    local render_object_id = render_object.id
                    --[[@type table<integer, rainbow_data>]]
                    storage.lights = storage.lights or {}
                    storage.lights[render_object_id] = {
                        render_id = render_object_id,
                        render_object = render_object,
                        sprite = false,
                        light = true,
                        tick_to_die = event_tick + length,
                        scale = scale,
                        max_scale = scale,
                        tick = event_tick,
                        player_index = player_index,
                        frequency = speeds[player_settings["player-trail-speed"]],
                        amplitude = palette[player_settings["player-trail-palette"]].amplitude,
                        center = palette[player_settings["player-trail-palette"]].center,
                    }
                    local rainbow_color = player.color
                    if player_settings["player-trail-type"] == "rainbow" then
                        rainbow_color = make_rainbow(player_index, event_tick, event_tick, player_settings)
                    end
                    render_object.color = rainbow_color
                end
                storage.last_render_positions[player_index] = position
            end
        end
    end
end

---@class rainbow_data
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

---@param trail_data rainbow_data
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
    for id, trail_data in pairs(storage.lights) do
        if trail_data.tick_to_die <= next_tick then
            storage.lights[id] = nil
        else
            animate_existing_trail(trail_data, current_tick)
        end
    end
    for id, trail_data in pairs(storage.sprites) do
        if trail_data.tick_to_die <= next_tick then
            storage.sprites[id] = nil
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
