local strength = "230"
local black = "civ_white.png^[colorize:#000000:" .. strength
local blue = "civ_white.png^[colorize:#2b72de:" .. strength
local cyan = "civ_white.png^[colorize:#7aa3e6:" .. strength
local dark_green = "civ_white.png^[colorize:#315721:" .. strength
local green = "civ_white.png^[colorize:#64ae49:" .. strength
local orange = "civ_white.png^[colorize:#ffa319:" .. strength
local pink = "civ_white.png^[colorize:#ffe7cf:" .. strength
local red = "civ_white.png^[colorize:#ff840170:" .. strength
local yellow = "civ_white.png^[colorize:#ffd21c:" .. strength
local brown = "civ_white.png^[colorize:#4a240d:" .. strength
local grey = "civ_white.png^[colorize:#9499a1:" .. strength
local dark_grey = "civ_white.png^[colorize:#424242:" .. strength

local error_msg = "You can't place that here..."

-- Base

-- local function has_index(tab, ind)
--     for index, _ in ipairs(tab) do
--         if index == ind then
--             return true
--         end
--     end
--     return false
-- end

minetest.register_node(c .. "base", {
    description = civ.highlight("Base"),
	drawtype = "mesh", 
    sunlight_propagates = true, 
    paramtype = "light",
    mesh = "civ_flag.obj",
    tiles = {blue, black, brown, grey},
    groups = {
        cracky = 2,
        structure = 1
    },
    on_construct = function(pos)
        data:set_string("basepos", minetest.serialize(pos))
        minetest.get_node_timer(pos):start(1)
        local meta = minetest.get_meta(pos)
        for _, material in ipairs(civ.materials) do
            meta:set_float(material .. "rate", 0)
            meta:set_float(material .. "excess", 0)
		end
		meta:set_string("links", minetest.serialize({}))
		meta:set_float("happiness", 1)
        -- future multiplayer functionality, perhaps?
        meta:set_string("player", "singleplayer")
    end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = minetest.get_player_by_name(meta:get_string("player")):get_inventory()
		local links = minetest.deserialize(meta:get_string("links"))
		local happiness = meta:get_float("happiness")

        for _, link in ipairs(links) do
			--check if resources are avaliable
			local resources_avaliable = true
			for item, rate in link.consumes do
				if not inv:contains_item("main", item) then
					resources_avaliable = false
					break
				end
			end 
			--if they are, do stuff
            if resources_avaliable then
				for item, rate in link.consumes do 
					meta:set_float(item.."excess", meta:get_float(item.."excess")-rate*happiness)
				end
				for item, rate in link.produces do 
					meta:set_float(item.."excess", meta:get_float(item.."excess")+rate*happiness)
				end
			end
        end

		for _, material in ipairs(civ.materials) do
            local excess = meta:get_float(material .. "excess")
            while excess >= 1 do
                excess = excess - 1
                inv:add_item("main", material)
            end
			while excess <= -1 do
				excess = excess + 1
				inv:remove_item("main", material)
			end
            meta:set_float(material .. "excess", excess)
        end

        return true
    end
    -- on_rightclick = function(pos, node, puncher, pointed_thing)
    -- local meta = minetest.get_meta(pos)
    -- end,
})

--Road
minetest.register_node(c .. "road", {
	description = civ.highlight("Road") .. 
	"\n\n\t Must be placed next to another " .. civ.highlight("Road") .. "," .. civ.highlight("Stair") .. ", or your " .. civ.highlight("Base") .. 
	"\n\t Can not be placed next to cliffs",
	inventory_image = "road_straight.png",
	wield_image = "road_straight.png",
	drawtype = "raillike",
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	tiles = { "road_straight.png", "road_curve.png", "road_t.png", "road_cross.png" },
	selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, -1 / 2 + 1 / 16, 1 / 2 },
	},
	groups = { snappy = 3 },
	connects_to = {
		c .. "stair1",
		c .. "stair2",
		c .. "stair3",
		c .. "stair4",
	},
	on_place = function(itemstack, placer, pointed_thing)
		if (civ.is_around(pointed_thing.above, c .. "road") or civ.is_around({ x = pointed_thing.above.x, y = pointed_thing.above.y - 1, z = pointed_thing.above.z }, c .. "stair1") or civ.is_around({ x = pointed_thing.above.x, y = pointed_thing.above.y - 1, z = pointed_thing.above.z }, c .. "stair2") or civ.is_around({ x = pointed_thing.above.x, y = pointed_thing.above.y - 1, z = pointed_thing.above.z }, c .. "stair3") or civ.is_around({ x = pointed_thing.above.x, y = pointed_thing.above.y - 1, z = pointed_thing.above.z }, c .. "stair4") or civ.is_around(pointed_thing.above, c .. "base")) and not civ.is_around_cliff(pointed_thing.above) then
			minetest.set_node(pointed_thing.above, { name = c .. "road" })
		else
			minetest.chat_send_all(error_msg)
		end
	end,
})

--Stairs
minetest.register_node(c .. "stair1", {
	description = "stony slope",
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	mesh = "stair.obj",
	tiles = { grey },
	groups = { cracky = 2 },
	on_place = function(itemstack, placer, pointed_thing)
		local nodename = "air"
		local pos = pointed_thing.above
		--orient stair
		local targetnames = { c .. "stoneblock", c .. "stonegrass" }
		for _, targetname in ipairs(targetnames) do
			pos.x = pos.x - 1
			if minetest.get_node(pos).name == targetname then
				nodename = c .. "stair1"
			end
			pos.x = pos.x + 2
			if minetest.get_node(pos).name == targetname then
				nodename = c .. "stair2"
			end
			pos.x = pos.x - 1
			pos.z = pos.z - 1
			if minetest.get_node(pos).name == targetname then
				nodename = c .. "stair3"
			end
			pos.z = pos.z + 2
			if minetest.get_node(pos).name == targetname then
				nodename = c .. "stair4"
			end
			pos.z = pos.z - 1
		end
		if civ.is_around(pointed_thing.above, c .. "road") and nodename ~= "air" then
			minetest.set_node(pointed_thing.above, { name = nodename })
		else
			minetest.chat_send_all(error_msg)
		end
	end,
})
minetest.register_node(c .. "stair2", {
	description = "stony slope",
 
	mesh = "stair1.obj",
	tiles = { grey },
	groups = { cracky = 2 },
	drops = { c .. "stair1" },
})
minetest.register_node(c .. "stair3", {
	description = "stony slope",
 
	mesh = "stair2.obj",
	tiles = { grey },
	groups = { cracky = 2 },
	drops = { c .. "stair1" },
})
minetest.register_node(c .. "stair4", {
	description = "stony slope",
 
	mesh = "stair3.obj",
	tiles = { grey },
	groups = { cracky = 2 },
	drops = { c .. "stair1" },
})

--Power Line
minetest.register_node(c .. "power_line", {
	description = civ.highlight("Power Line") .. 
	"\n\n\t Must be placed next to another " .. civ.highlight("Power Line") .. " or a " .. civ.highlight("Power Plant") .. 
	"\n\t Can not be placed next to cliffs",
	inventory_image = "road_straight.png",
	wield_image = "power_straight.png",
	drawtype = "raillike",
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	tiles = { "power_straight.png", "power_curve.png", "power_t.png", "power_cross.png" },
	selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, -1 / 2 + 1 / 16, 1 / 2 },
	},
	groups = { snappy = 3 },
	on_place = function(itemstack, placer, pointed_thing)
		if (civ.is_around(pointed_thing.above, c .. "power_plant") or civ.is_around(pointed_thing.above, c .. "power_line")) and not civ.is_around_cliff(pointed_thing.above) then
			minetest.set_node(pointed_thing.above, { name = c .. "power_line" })
		else
			minetest.chat_send_all(error_msg)
		end
	end,
})

--People
minetest.register_node(c .. "tent", {
	description = civ.highlight("Tent") .. 
	"\n\n\t Must be placed next to a " .. civ.highlight("Water") .. 
	"\n\t Gives 5 People",
	mesh = "woodhouse.obj",
	tiles = { "civ_wood.png", black, grey, pink, brown },
	groups = { cracky = 2, structure = 1, home = 1 },
	drawtype = "mesh", 
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around_water(pos) then
			minetest.set_node(pointed_thing.above, { name = c .. "house" })
			placer:get_inventory():add_item(c.."people 5")
		else
			minetest.chat_send_all(error_msg)
		end
	end,
	on_dig = function(pos, node, digger)
		inv = placer:get_inventory()
		if inv:contains_item("main", c .. "people 5") then
			inv:remove_item("main", c .. "people 5")
			minetest.dig_node(pos, digger)
		else
			minetest.chat_send_all("You need at least 5 people to remove this structure")
			return false
		end
	end
})
minetest.register_node(c .. "house", {
	description = civ.highlight("House") .. 
	"\n\n\t Must be placed next to a " .. civ.highlight("Road") .. 
	"\n\t Gives 10 People",
	mesh = "civ_house.obj",
	tiles = { "civ_wood.png", black, grey, pink, brown },
	groups = { cracky = 2, structure = 1, home = 1 },
	drawtype = "mesh", 
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around(pointed_thing.above, c .. "road") then
			minetest.set_node(pointed_thing.above, { name = c .. "house" })
			placer:get_inventory():add_item(c.."people 10")
		else
			minetest.chat_send_all(error_msg)
		end
	end,
	on_dig = function(pos, node, digger)
		inv = placer:get_inventory()
		if inv:contains_item("main", c .. "people 10") then
			inv:remove_item("main", c .. "people 10")
			minetest.dig_node(pos, digger)
		else
			minetest.chat_send_all("You need at least 10 people to remove this structure")
			return false
		end
	end,
})
minetest.register_node(c .. "apartment", {
	description = civ.highlight("Apartment") .. 
	"\n\n\t Must be placed next to a " .. civ.highlight("Power Line") .. 
	"\n\t Gives 20 People",
	mesh = "civ_apartment.obj",
	tiles = { "civ_wood.png", black, grey, pink, brown },
	groups = { cracky = 2, structure = 1, home = 1 },
	drawtype = "mesh", 
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around(pointed_thing.above, c .. "power_line") then
			minetest.set_node(pointed_thing.above, { name = c .. "apartment" })
			placer:get_inventory():add_item(c.."people 20")
		else
			minetest.chat_send_all(error_msg)
		end
	end,
	on_dig = function(pos, node, digger)
		on_dig = function(pos, node, digger)
			inv = placer:get_inventory()
			if inv:contains_item("main", c .. "people 20") then
				inv:remove_item("main", c .. "people 20")
				minetest.dig_node(pos, digger)
			else
				minetest.chat_send_all("You need at least 20 people to remove this structure")
				return false
			end
		end
	end
})

--Happiness
minetest.register_node(c .. "flowers", {
	description = civ.highlight("Flowers") .. 
	"\n\n\t Must be placed next to " .. civ.highlight("Water") .. 
	"\n\t Adds 2% happiness",
	drawtype = "mesh",
	mesh = "civ_flowers.obj",
	tiles = { pink, blue, yellow, orange, yellow, brown, "civ_grass_small.png" },
	groups = { cracky = 2, structure = 1 }, 
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around_water(pointed_thing.above) then
			minetest.set_node(pointed_thing.above, { name = c .. "flowers" })
			civ.change_happiness(0.02)
		else
			minetest.chat_send_all(error_msg)
		end
	end,
	on_dig = function(pos, node, digger)
		civ.change_happiness(-0.02)
		minetest.set_node(pos, { name = "air" })
	end,
})
minetest.register_node(c .. "flowers", {
	description = civ.highlight("Flowers") .. 
	"\n\n\t Must be placed next to " .. civ.highlight("Water") .. 
	"\n\t Adds 2% happiness",
	drawtype = "mesh",
	mesh = "civ_flowers.obj",
	tiles = { pink, blue, yellow, orange, yellow, brown, "civ_grass_small.png" },
	groups = { cracky = 2, structure = 1 }, 
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around_water(pointed_thing.above) then
			minetest.set_node(pointed_thing.above, { name = c .. "flowers" })
			civ.change_happiness(0.02)
		else
			minetest.chat_send_all(error_msg)
		end
	end,
	on_dig = function(pos, node, digger)
		civ.change_happiness(-0.02)
		minetest.set_node(pos, { name = "air" })
	end,
})

--Other
minetest.register_node(c .. "well", {
	description = civ.highlight("Well") .. "\n\n\t No placement requirements. \n\t Acts as water",
	mesh = "civ_well.obj",
	tiles = { cyan, grey, "civ_wood.png" },
	groups = { cracky = 2, structure = 1 },
	drawtype = "mesh", 
    sunlight_propagates = true, 
    paramtype = "light"
})

minetest.register_node(c .. "market", {
	description = civ.highlight("Market") ..
	"\n\n\t Must be placed next to a " .. civ.highlight("Road") .. 
	"\n\t Enables the placement of some buildings",
	mesh = "civ_market.obj",
	tiles = { cyan, grey, "civ_wood.png" },
	groups = { cracky = 2, structure = 1 },
	drawtype = "mesh",
    sunlight_propagates = true, 
    paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if civ.is_around(pointed_thing.above, c .. "road") then
			minetest.set_node(pointed_thing.above, { name = c .. "market" })
		else
			minetest.chat_send_all(error_msg)
		end
	end,
})