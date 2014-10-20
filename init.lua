local previous_positions = {}

local helper_name = 'flaming_torch:torch'

-- functions --

local function turn_off_the_light(player)
    local position = previous_positions[player:get_player_name()]
    if position then
        node = minetest.get_node_or_nil(position)
        if node.name == helper_name then
            minetest.set_node(position, { name = 'air' })
        end
        previous_positions[player:get_player_name()] = nil
    end
end

local function turn_on_the_light(player)
    if player:get_wielded_item():get_name() == core.registered_aliases['torch'] then
        local position = vector.round(player:getpos())
        position.y = position.y + 1 -- torch is on head level
        local prev = previous_positions[player:get_player_name()]
        if not prev or (prev and not vector.equals(position, prev)) then
            node = minetest.get_node_or_nil(position)
            if node.name == 'air' then
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
    light_source = 14, -- current LIGHT_MAX from default mod
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
