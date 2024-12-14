
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

-- ---called whenever a player changes position, draws a new sprite and light
-- ---@param event EventData.on_player_changed_position
-- local function player_changed_position(event)
--   local player_index = event.player_index
--   if not (storage.settings and storage.settings[player_index]) then
--     initialize_settings(player_index)
--   end
--   local player_settings = storage.settings[player_index]
--   local sprite = player_settings["player-trail-color"]
--   local light = player_settings["player-trail-glow"]
--   local player = {}
--   if sprite or light then
--     player = game.get_player(player_index)
--     if not (player.controller_type == defines.controllers.character) then
--       return
--     end
--   else
--     return
--   end
--   local event_tick = event.tick
--   local length = tonumber(player_settings["player-trail-length"])
--   local scale = tonumber(player_settings["player-trail-scale"])
--   if sprite then
--     sprite = rendering.draw_sprite{
--       sprite = "player-trail",
--       target = player.position,
--       surface = player.surface,
--       x_scale = scale,
--       y_scale = scale,
--       render_layer = "radius-visualization",
--       time_to_live = length,
--     }
--     if not storage.sprites then
--       storage.sprites = {}
--     end
--     local sprite_data = {
--       sprite = sprite,
--       tick_to_die = event_tick + length,
--       size = (scale + length) * 4,
--       tick = event_tick,
--       player_index = player_index,
--     }
--     storage.sprites[sprite] = sprite_data
--     local rainbow_color = player.color
--     if player_settings["player-trail-type"] == "rainbow" then
--       rainbow_color = make_rainbow(sprite_data, event_tick, player_settings)
--     end
--     rendering.set_color(sprite, rainbow_color)
--   end
--   if light then
--     light = rendering.draw_light{
--       sprite = "player-trail",
--       target = player.position,
--       surface = player.surface,
--       intensity = .175,
--       scale = scale * 2,
--       render_layer = "light-effect",
--       time_to_live = length,
--     }
--     if not storage.lights then
--       storage.lights = {}
--     end
--     local light_data = {
--       light = light,
--       tick_to_die = event_tick + length,
--       size = (scale + length) * 4,
--       tick = event_tick,
--       player_index = player_index,
--     }
--     storage.lights[light] = light_data
--     local rainbow_color = player.color
--     if player_settings["player-trail-type"] == "rainbow" then
--       rainbow_color = make_rainbow(light_data, event_tick, player_settings)
--     end
--     rendering.set_color(light, rainbow_color)
--   end
-- end

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

local function animate_existing_sprites()
    local current_tick = game.tick
    for id, sprite_data in pairs(storage.sprites) do
        if sprite_data.tick_to_die <= current_tick + 1 then
            storage.sprites[id] = nil
        elseif (current_tick % 3 == 0) and sprite_data.sprite then
            local render_object = sprite_data.render_object
            local player_index = sprite_data.player_index
            local player_settings = storage.settings[player_index]
            local created_tick = player_settings["player-trail-sync"] and player_index or sprite_data.tick
            local rainbow_color = make_optimized_rainbow(player_index, created_tick, current_tick, sprite_data.frequency, sprite_data.amplitude, sprite_data.center)
            local scale = sprite_data.scale
            local max_scale = sprite_data.max_scale
            local animated_trail = player_settings["player-trail-animate"]
            local rainbow_trail = player_settings["player-trail-type"] == "rainbow"
            local tapered_trail = player_settings["player-trail-taper"]
            if tapered_trail then
                scale = scale - scale / max_scale / 10
                render_object.x_scale = scale
                render_object.y_scale = scale
                sprite_data.scale = scale
            end
            if animated_trail and rainbow_trail then
                render_object.color = rainbow_color
            end
        end
    end
end

local function animate_existing_lights()
    local current_tick = game.tick
    for id, light_data in pairs(storage.lights) do
        if light_data.tick_to_die <= current_tick + 1 then
            storage.lights[id] = nil
        elseif (current_tick % 3 == 0) and light_data.light then
            local render_object = light_data.render_object
            local player_index = light_data.player_index
            local player_settings = storage.settings[player_index]
            local created_tick = player_settings["player-trail-sync"] and player_index or light_data.tick
            local rainbow_color = make_optimized_rainbow(player_index, created_tick, current_tick, light_data.frequency, light_data.amplitude, light_data.center)
            local scale = light_data.scale
            local max_scale = light_data.max_scale
            local animated_trail = player_settings["player-trail-animate"]
            local rainbow_trail = player_settings["player-trail-type"] == "rainbow"
            local tapered_trail = player_settings["player-trail-taper"]
            if tapered_trail then
                scale = scale - scale / max_scale / 10
                render_object.scale = scale
                light_data.scale = scale
            end
            if animated_trail and rainbow_trail then
                render_object.color = rainbow_color
            end
        end
    end
end

---runs every tick to update the rainbow color animation and taper
---@param event EventData.on_tick
local function on_tick(event)
    for _, player in pairs(game.connected_players) do
        draw_new_trail_segment(player)
    end
    animate_existing_sprites()
    animate_existing_lights()
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
