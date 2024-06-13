data:set_int("event_period", 100)

local function get_menu_formspec()
	return "size[10,10]" .. "label[0.5,0.5;Choose a map...]" .. "button_exit[0.5,1.5;5,1;map1;Map 1]" .. "button_exit[0.5,2.5;5,1;map2,Map 2]"
end

minetest.register_on_newplayer(function(ObjectRef)
	--minetest.set_player_privs(ObjectRef:get_player_name(),  {interact = true, fly = true})
	minetest.show_formspec(ObjectRef:get_player_name(), c .. "startmenu", get_menu_formspec())
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == c .. "start_menu" then
		for map, pressed in fields do
			if pressed ~= nil then
				minetest.place_schematic({x=0,y=0,z=0}, map..".mts")
			end
		end
		player:set_pos({x=0,y=30,z=0})
	end
end)
