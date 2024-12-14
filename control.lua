
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
    if not index then return end
    if not global.settings then
        global.settings = {}
    end
    local player_settings = settings.get_player_settings(index)
    global.settings[index] = {}
    global.settings[index]["player-trail-glow"] = player_settings["player-trail-glow"].value
    global.settings[index]["player-trail-color"] = player_settings["player-trail-color"].value
    global.settings[index]["player-trail-animate"] = player_settings["player-trail-animate"].value
    global.settings[index]["player-trail-length"] = player_settings["player-trail-length"].value
    global.settings[index]["player-trail-scale"] = player_settings["player-trail-scale"].value
    global.settings[index]["player-trail-speed"] = player_settings["player-trail-speed"].value
    global.settings[index]["player-trail-sync"] = player_settings["player-trail-sync"].value
    global.settings[index]["player-trail-palette"] = player_settings["player-trail-palette"].value
    global.settings[index]["player-trail-taper"] = player_settings["player-trail-taper"].value
    global.settings[index]["player-trail-type"] = player_settings["player-trail-type"].value
    if not global.sprites then
        global.sprites = {}
    end
    if not global.lights then
        global.lights = {}
    end
end

-- ---called whenever a player changes position, draws a new sprite and light
-- ---@param event EventData.on_player_changed_position
-- local function player_changed_position(event)
--   local player_index = event.player_index
--   if not (global.settings and global.settings[player_index]) then
--     initialize_settings(player_index)
--   end
--   local player_settings = global.settings[player_index]
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
--     if not global.sprites then
--       global.sprites = {}
--     end
--     local sprite_data = {
--       sprite = sprite,
--       tick_to_die = event_tick + length,
--       size = (scale + length) * 4,
--       tick = event_tick,
--       player_index = player_index,
--     }
--     global.sprites[sprite] = sprite_data
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
--     if not global.lights then
--       global.lights = {}
--     end
--     local light_data = {
--       light = light,
--       tick_to_die = event_tick + length,
--       size = (scale + length) * 4,
--       tick = event_tick,
--       player_index = player_index,
--     }
--     global.lights[light] = light_data
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
    if not (global.settings and global.settings[player_index]) then
        initialize_settings(player.index)
    end
    if player.controller_type == defines.controllers.character then
        global.last_render_positions = global.last_render_positions or {}
        local position = player.position
        global.last_render_positions[player_index] = global.last_render_positions[player_index] or position
        local last_render_position = global.last_render_positions[player_index]
        if distance(last_render_position, position) > 0.33 then
            local player_settings = global.settings[player_index]
            local sprite = player_settings["player-trail-color"]
            local light = player_settings["player-trail-glow"]
            local event_tick = game.tick
            if sprite or light then
                local length = tonumber(player_settings["player-trail-length"])
                local scale = tonumber(player_settings["player-trail-scale"])
                if sprite then
                    sprite = rendering.draw_sprite {
                        sprite = "player-trail",
                        target = player.position,
                        surface = player.surface,
                        x_scale = scale,
                        y_scale = scale,
                        render_layer = "radius-visualization",
                        time_to_live = length,
                    }
                    global.sprites = global.sprites or {} ---@type table<integer, rainbow_data>
                    global.sprites[sprite] = {
                        render_id = sprite,
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
                    rendering.set_color(sprite, rainbow_color)
                end
                if light then
                    light = rendering.draw_light {
                        sprite = "player-trail",
                        target = player.position,
                        surface = player.surface,
                        intensity = .1,
                        scale = scale,
                        render_layer = "light-effect",
                        time_to_live = length,
                    }
                    global.lights = global.lights or {} ---@type table<integer, rainbow_data>
                    global.lights[light] = {
                        render_id = light,
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
                    rendering.set_color(light, rainbow_color)
                end
                global.last_render_positions[player_index] = position
            end
        end
    end
end

---@class rainbow_data
---@field render_id uint
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

local function animate_existing_trail_segments()
    local render_ids = rendering.get_all_ids("player-trails")
    if not render_ids then return end
    local settings = global.settings
    local game_tick = game.tick
    for _, id in pairs(render_ids) do
        local rainbow = global.sprites[id] or global.lights[id] or nil
        if rainbow then
            if rainbow.tick_to_die <= game_tick + 1 then
                global.sprites[id] = nil
                global.lights[id] = nil
            elseif game_tick % 3 == 0 then
                local player_index = rainbow.player_index
                local player_settings = settings[rainbow.player_index]
                local sprite = rainbow.sprite
                local light = rainbow.light
                local rainbow_color = make_optimized_rainbow(player_index, rainbow.tick, game_tick, rainbow.frequency,
                    rainbow.amplitude, rainbow.center)
                local scale = rainbow.scale
                local max_scale = rainbow.max_scale
                local animated_trail = player_settings["player-trail-animate"]
                local rainbow_trail = player_settings["player-trail-type"] == "rainbow"
                local tapered_trail = player_settings["player-trail-taper"]
                if sprite then
                    if tapered_trail then
                        -- local scale = rendering.get_x_scale(sprite)
                        scale = scale - scale / max_scale / 10
                        rendering.set_x_scale(id, scale)
                        rendering.set_y_scale(id, scale)
                        global.sprites[id].scale = scale
                    end
                    if animated_trail and rainbow_trail then
                        rendering.set_color(id, rainbow_color)
                    end
                elseif light then
                    if tapered_trail then
                        -- local scale = rendering.get_scale(light)
                        scale = scale - scale / max_scale / 10
                        rendering.set_scale(id, scale)
                        global.lights[id].scale = scale
                    end
                    if animated_trail and rainbow_trail then
                        rendering.set_color(id, rainbow_color)
                    end
                end
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
    animate_existing_trail_segments()
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting:match("^player%-trail%-") then
        initialize_settings(event.player_index)
    end
end)

script.on_configuration_changed(function(event)
    for each, player in pairs(game.players) do
        initialize_settings(player.index)
    end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    initialize_settings(event.player_index)
end)

-- script.on_event(defines.events.on_player_changed_position, player_changed_position)

script.on_event(defines.events.on_tick, on_tick)
