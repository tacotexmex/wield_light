local sources = {}

-- api --

wield_light = {
  register_source = function(name) sources[name] = true end,
  unregister_source = function(name) sources[name] = nil end,
}

-- registration --

local positions = {}
local HELPER_NAME = 'wield_light:helper'

minetest.register_node(HELPER_NAME, {
  walkable = false,
  pointable = false,
  diggable = false,
  climbable = false,
  sunlight_propagates = true,
  drawtype = 'airlike',
  light_source = 14, -- current LIGHT_MAX from default mod
  on_construct = function(pos)
    minetest.get_node_timer(pos):start(0.1)
  end,
  on_timer = function(pos)
    if positions[minetest.hash_node_position(pos)] then
      return true
    end
    minetest.remove_node(pos)
  end,
})

minetest.register_globalstep(function()
  local new_positions = {}
  for _, player in pairs(minetest.get_connected_players()) do
    if sources[player:get_wielded_item():get_name()] then
      local pos = vector.round(player:getpos())
      pos.y = pos.y + 1 -- body level
      local target_node = minetest.get_node(pos).name
      if target_node == 'air' and target_node ~= HELPER_NAME then
        minetest.set_node(pos, { name = HELPER_NAME })
      end
      new_positions[minetest.hash_node_position(pos)] = true
    end
  end
  positions = new_positions
end)

wield_light.register_source('default:torch')
wield_light.register_source('fire:basic_flame')
wield_light.register_source('bucket:bucket_lava')
wield_light.register_source('default:lava_source')
