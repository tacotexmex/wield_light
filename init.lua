local sounds = {}
local previous_positions = {}

local helper_name = 'flaming_torch:torch'

-- functions --

local function turn_off_the_light(player, keep_sound)
    local player_name = player:get_player_name()
    local position = previous_positions[player_name]
    if position then
        if minetest.get_node(position).name == helper_name then
            minetest.remove_node(position)
        end
        previous_positions[player_name] = nil
    end
    if not keep_sound and sounds[player_name] then
        minetest.sound_stop(sounds[player_name])
        sounds[player_name] = nil
    end
end

local function turn_on_the_light(player)
    local position = vector.round(player:getpos())
    position.y = position.y + 1 -- torch is on head level
    local prev = previous_positions[player:get_player_name()]
    if not prev or not vector.equals(position, prev) then
        keep_sound = false
        if minetest.get_node(position).name == 'air' then
            keep_sound = true
            minetest.set_node(position, { name = helper_name })
            if not sounds[player:get_player_name()] then
                sounds[player:get_player_name()] = minetest.sound_play('torch', { object = player, loop = true })
            end
        end
        turn_off_the_light(player, keep_sound)
        previous_positions[player:get_player_name()] = position
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

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_wielded_item():get_name() == core.registered_aliases['torch'] then
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
