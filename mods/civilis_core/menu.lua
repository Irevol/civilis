
data:set_int("event_period", 100)

function get_menu_formspec()
	return "size[10,10]"
	.."label[0.5,0.5;Choose a map...]"
	.."button_exit[0.5,1.5;5,1;map1;Map 1]"
end
minetest.register_on_joinplayer(function(ObjectRef, last_login)
	minetest.show_formspec(ObjectRef:get_player_name(), c.."startmenu", get_menu_formspec())
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == c.."start_menu" then
		if fields.map1 then
			minetest.place_schematic({x=0,y=0,z-0}, "map1.mts")
		end
	end
end)
