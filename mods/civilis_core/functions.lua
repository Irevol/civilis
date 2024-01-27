function civ.is_around(pos, targetname)
	local found = false
	pos.x = pos.x-1
	if minetest.get_node(pos).name == targetname then found = true end
	pos.x = pos.x+2
	if minetest.get_node(pos).name == targetname then found = true end
	pos.x = pos.x-1
	pos.z=pos.z-1
	if minetest.get_node(pos).name == targetname then found = true end
	pos.z=pos.z+2
	if minetest.get_node(pos).name == targetname then found = true end
	pos.z=pos.z-1
	return found
end

function civ.change_resource_rate(resource, amount)
	local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
	basemeta:set_float( resource.."rate", basemeta:get_float(resource.."rate")+amount )
	minetest.chat_send_all("hmm")
end

function civ.highlight(text)
	return minetest.colorize("yellow",text)
end

function civ.is_around_water(pos)
	return (is_around({x=pos.x,y=pos.y-1,z=pos.z}, c.."water") or civ.is_around(pos, c.."well"))
end

function civ.is_around_cliff(pos)
	return (civ.is_around(pos, c.."stonegrass") or civ.is_around(pos, c.."stoneblock"))
end

function civ.update_node(pos)
	if minetest.registered_nodes[minetest.get_node(pos).name]._update ~= nil then 
		minetest.registered_nodes[minetest.get_node(pos).name]._update(pos)
	end
end

--update nodes in 2 block radius on place
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	for x in ipairs({-2,-1,0,1,2}) do 
		for z in ipairs({-2,-1,0,1,2}) do
			civ.update_node({x=pos.x+x,y=pos.y,z=pos.z+z})
		end
	end
	return true
end)

function civ.is_structure(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "structure") ~= 0
end

civ.recipes = {}
function civ.register_recipe(name, output, input, crafttime, researchcost, researchreq)
	table.insert(civ.recipes, {name, output, input, crafttime, researchcost, researchreq})
end

civ.materials = {}
function civ.register_material(name, description, image)
	minetest.register_craftitem(name, {
		description = description,
		inventory_image = image,
		stack_max = 100000,
	})
	table.insert(civ.materials,name)
end

function civ.execute_event()
	-- for x = -10, 10, 1 do 
		-- for z = -10, 10, 1 do 
			-- local pos = {x=pos.x+x,y=pos.y,z=pos.z+z}
			-- local node = minetest.get_node(pos)
			-- if not civ.is_structure(pos) then 
				-- if node.name == c.."stoneblock" or node.name == c.."stonegrass" then
					-- minetest.set_node(pos, {name == "air"})
					
		-- end
	-- end
end
