local previous_positions = {}

local helper_name = 'flaming_torch:torch'
local default_name = 'default:torch'
local replacer_name = 'air'

-- functions --

local function turn_off_the_light(player)
    local position = previous_positions[player:get_player_name()]
    if position then
        node = minetest.get_node_or_nil(position)
        if node.name == helper_name then
            minetest.set_node(position, { name = replacer_name })
        end
        previous_positions[player:get_player_name()] = nil
    end
end

local function turn_on_the_light(player)
    if player:get_wielded_item():get_name() == default_name then
        local position = vector.round(player:getpos())
        position.y = position.y + 1 -- torch is on head level
        local prev = previous_positions[player:get_player_name()]
        if not prev or (prev and not vector.equals(position, prev)) then
            node = minetest.get_node_or_nil(position)
            if node.name == replacer_name then
                minetest.set_node(position, { name = helper_name })
            end
            turn_off_the_light(player)
            previous_positions[player:get_player_name()] = position
        end
    else
        turn_off_the_light(player)
    end
end

-- nodes registration --

minetest.register_node(helper_name, {
    walkable = false,
    pointable = false,
    diggable = false,
    climbable = false,
    sunlight_propagates = true,
    drawtype = 'airlike',
    light_source = minetest.registered_nodes[default_name].light_source,
})

-- events registration --

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        turn_on_the_light(player)
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
