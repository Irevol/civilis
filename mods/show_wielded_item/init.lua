-- Based on 4itemnames mod by 4aiman
local wield = {}
local wieldindex = {}
local huds = {}
local dtimes = {}
local dlimit = 6 -- HUD element will be hidden after this many seconds

local function set_hud(player)
    if not player:is_player() then
        return
    end
    local player_name = player:get_player_name()
    local off = {
        x = 0,
    	y = -180
    }
	huds[player_name] = player:hud_add({
        hud_elem_type = "text",
        position = {
            x = 0.5,
            y = 1
        },
        offset = off,
        alignment = {
            x = 0,
            y = 0
        },
        number = 0xFFFFFF,
        text = "",
        z_index = 100
    })
end

minetest.register_on_joinplayer(function(player)
    set_hud(player)

    local name = player:get_player_name()
    wield[name] = player:get_wielded_item():get_name()
    wieldindex[name] = player:get_wield_index()
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    wield[name] = nil
    wieldindex[name] = nil
end)

minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local wstack = player:get_wielded_item()
        local wname = wstack:get_name()
        local windex = player:get_wield_index()

        if dtimes[player_name] and dtimes[player_name] < dlimit then
            dtimes[player_name] = dtimes[player_name] + dtime
            if dtimes[player_name] > dlimit and huds[player_name] then
                player:hud_change(huds[player_name], 'text', "")
            end
        end

        -- Update HUD when wielded item or wielded index changed
        if wname ~= wield[player_name] or windex ~= wieldindex[player_name] then
            wieldindex[player_name] = windex
            wield[player_name] = wname
            dtimes[player_name] = 0
            if huds[player_name] then
                local def = minetest.registered_items[wname]
                local desc = def.description
                player:hud_change(huds[player_name], 'text', desc)
            end
        end
    end
end)

