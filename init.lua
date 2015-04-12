local sources = {}

-- api --

wield_light = {
  register_source = function(name) sources[name] = true end,
  unregister_source = function(name) sources[name] = nil end,
}

-- functions --

local previous_positions = {}
local helper_name = 'wield_light:helper'

local function turn_off_the_light(player)
  local player_name = player:get_player_name()
  local position = previous_positions[player_name]
  if position then
    if minetest.get_node(position).name == helper_name then
      minetest.remove_node(position)
    end
    previous_positions[player_name] = nil
  end
end

local function turn_on_the_light(player)
  local player_name = player:get_player_name()
  local prev = previous_positions[player_name]
  local position = vector.round(player:getpos())
  position.y = position.y + 1 -- body level

  if not prev or not vector.equals(position, prev) then
    if minetest.get_node(position).name == 'air' then
      minetest.set_node(position, { name = helper_name })
    end
    turn_off_the_light(player) -- turn off for previous position
    previous_positions[player_name] = position
  end
end

-- registration --

minetest.register_node(helper_name, {
  walkable = false,
  pointable = false,
  diggable = false,
  climbable = false,
  sunlight_propagates = true,
  drawtype = 'airlike',
  light_source = 14, -- current LIGHT_MAX from default mod
})

minetest.register_globalstep(function()
  for _, player in ipairs(minetest.get_connected_players()) do
    if sources[player:get_wielded_item():get_name()] then
      turn_on_the_light(player)
    else
      turn_off_the_light(player)
    end
  end
end)

minetest.register_on_dieplayer(turn_off_the_light)
minetest.register_on_leaveplayer(turn_off_the_light)
minetest.register_on_respawnplayer(turn_off_the_light)
minetest.register_on_shutdown(function()
  for _, player in ipairs(minetest.get_connected_players()) do
    turn_off_the_light(player)
  end
end)

wield_light.register_source('default:torch')
wield_light.register_source('fire:basic_flame')
wield_light.register_source('bucket:bucket_lava')
wield_light.register_source('default:lava_source')
