
--[[
Player Trails control script © 2022 by asher_sky is licensed under Attribution-NonCommercial-ShareAlike 4.0 International. See LICENSE.txt for additional information
--]]

local speeds = {
  veryslow = 0.010,
  slow = 0.025,
  default = 0.050,
  fast = 0.100,
  veryfast = 0.200,
}

local palette = {
  light = {amplitude = 15, center = 240},           -- light
  pastel = {amplitude = 55, center = 200},          -- pastel <3
  default = {amplitude = 127.5, center = 127.5},    -- default (nyan)
  vibrant = {amplitude = 50, center = 100},         -- muted
  deep = {amplitude = 25, center = 50},             -- dark
}

local sin = math.sin
local pi_div_3 = math.pi / 3

local function make_rainbow(rainbow, game_tick, player_settings)
  local index = rainbow.player_index
  local created_tick = rainbow.tick
  -- local player_settings = settings[index]
  local frequency = speeds[player_settings["player-trail-speed"]]
  if player_settings["player-trail-sync"] == true then
    created_tick = index
  end
  local modifier = (game_tick)+(index*created_tick)
  local palette_key = player_settings["player-trail-palette"]
  local amplitude = palette[palette_key].amplitude
  local center = palette[palette_key].center
  return {
    r = sin(frequency*(modifier)+(0*pi_div_3))*amplitude+center,
    g = sin(frequency*(modifier)+(2*pi_div_3))*amplitude+center,
    b = sin(frequency*(modifier)+(4*pi_div_3))*amplitude+center,
    a = 255,
  }
end

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
end

---called whenever a player changes position, draws a new sprite and light
---@param event EventData.on_player_changed_position
local function player_changed_position(event)
  local player_index = event.player_index
  if not (global.settings and global.settings[player_index]) then
    initialize_settings(player_index)
  end
  local player_settings = global.settings[player_index]
  local sprite = player_settings["player-trail-color"]
  local light = player_settings["player-trail-glow"]
  local player = {}
  if sprite or light then
    player = game.get_player(player_index)
    if not (player.controller_type == defines.controllers.character) then
      return
    end
  else
    return
  end
  local event_tick = event.tick
  local length = tonumber(player_settings["player-trail-length"])
  local scale = tonumber(player_settings["player-trail-scale"])
  if sprite then
    sprite = rendering.draw_sprite{
      sprite = "player-trail",
      target = player.position,
      surface = player.surface,
      x_scale = scale,
      y_scale = scale,
      render_layer = "radius-visualization",
      time_to_live = length,
    }
    if not global.sprites then
      global.sprites = {}
    end
    local sprite_data = {
      sprite = sprite,
      tick_to_die = event_tick + length,
      size = (scale + length) * 4,
      tick = event_tick,
      player_index = player_index,
    }
    global.sprites[sprite] = sprite_data
    local rainbow_color = player.color
    if player_settings["player-trail-type"] == "rainbow" then
      rainbow_color = make_rainbow(sprite_data, event_tick, player_settings)
    end
    rendering.set_color(sprite, rainbow_color)
  end
  if light then
    light = rendering.draw_light{
      sprite = "player-trail",
      target = player.position,
      surface = player.surface,
      intensity = .175,
      scale = scale * 2,
      render_layer = "light-effect",
      time_to_live = length,
    }
    if not global.lights then
      global.lights = {}
    end
    local light_data = {
      light = light,
      tick_to_die = event_tick + length,
      size = (scale + length) * 4,
      tick = event_tick,
      player_index = player_index,
    }
    global.lights[light] = light_data
    local rainbow_color = player.color
    if player_settings["player-trail-type"] == "rainbow" then
      rainbow_color = make_rainbow(light_data, event_tick, player_settings)
    end
    rendering.set_color(light, rainbow_color)
  end
end

---runs every tick to update the rainbow color animation and taper
---@param event EventData.on_tick
local function on_tick(event)
  local render_ids = rendering.get_all_ids("player-trails")
  if not render_ids then
    return
  end
  local settings = global.settings
  local game_tick = event.tick
  for _, id in pairs(render_ids) do
    local rainbow = global.sprites[id] or global.lights[id]
    if rainbow then
      if rainbow.tick_to_die <= game_tick then
          global.sprites[id] = nil
          global.lights[id] = nil
      else
        local player_settings = settings[rainbow.player_index]
        local sprite = rainbow.sprite
        local light = rainbow.light
        local rainbow_color = make_rainbow(rainbow, game_tick, player_settings)
        local size = rainbow.size
        local animated_trail = player_settings["player-trail-animate"]
        local rainbow_trail = player_settings["player-trail-type"] == "rainbow"
        local tapered_trail = player_settings["player-trail-taper"]
        if sprite then
          if tapered_trail then
            local scale = rendering.get_x_scale(sprite)
            scale = scale - scale / size
            rendering.set_x_scale(sprite, scale)
            rendering.set_y_scale(sprite, scale)
          end
          if animated_trail and rainbow_trail then
            rendering.set_color(sprite, rainbow_color)
          end
        elseif light then
          if tapered_trail then
            local scale = rendering.get_scale(light)
            scale = scale - scale / size
            rendering.set_scale(light, scale)
          end
          if animated_trail and rainbow_trail then
            rendering.set_color(light, rainbow_color)
          end
        end
      end
    end
  end
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

script.on_event(defines.events.on_player_changed_position, player_changed_position)

script.on_event(defines.events.on_tick, on_tick)
