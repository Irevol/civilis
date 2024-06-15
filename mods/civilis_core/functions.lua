function civ.is_around(pos, targetname)
    local found = 0
    pos.x = pos.x - 1
    if minetest.get_node(pos).name == targetname then
        found = found + 1
    end
    pos.x = pos.x + 2
    if minetest.get_node(pos).name == targetname then
        found = found + 1
    end
    pos.x = pos.x - 1
    pos.z = pos.z - 1
    if minetest.get_node(pos).name == targetname then
        found = found + 1
    end
    pos.z = pos.z + 2
    if minetest.get_node(pos).name == targetname then
        found = found + 1
    end
    pos.z = pos.z - 1
    return found
end

function civ.get_surrounding_structs(pos, radius)
    local structs = {}
    for x = -radius, radius do
        for z = -radius, radius do
            for y = -1, 1 do
                local check_pos = {
                    x = pos.x + x,
                    y = pos.y + y,
                    z = pos.z + z
                }
                if civ.is_structure(check_pos) then
                    table.insert(structs, minetest.get_node(check_pos).name)
                end
            end
        end
    end
    return structs
end

function civ.change_resource_rate(resource, amount)
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    basemeta:set_float(resource .. "rate", basemeta:get_float(resource .. "rate") + amount)
    minetest.chat_send_all("hmm")
end

function civ.get_resource_rate(resource)
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    return basemeta:get_float(resource .. "rate")
end

function civ.highlight(text)
    return minetest.colorize("yellow", text)
end

function civ.is_around_water(pos)
    return civ.is_around({ x = pos.x, y = pos.y - 1, z = pos.z}, c .. "water") + civ.is_around(pos, c .. "well")
end

function civ.is_around_cliff(pos)
    return (civ.is_around(pos, c .. "stonegrass") + civ.is_around(pos, c .. "stoneblock"))
end

function civ.update_node(pos)
    if minetest.registered_nodes[minetest.get_node(pos).name]._update ~= nil then
        minetest.registered_nodes[minetest.get_node(pos).name]._update(pos)
    end
end

-- update nodes in 3 block radius on place
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    for x = -3, 3 do
        for z = -3, 3 do
            for y = -1, 1 do
                civ.update_node({
                    x = pos.x + x,
                    y = pos.y + y,
                    z = pos.z + z
                })
            end
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
        stack_max = 1000000
    })
    table.insert(civ.materials, name)
end

function civ.change_happiness(amount)
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    basemeta:set_float("happiness", basemeta:get_float("happiness") + amount)
end

function civ.get_happiness()
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    return basemeta:get_float("happiness")
end

function civ.register_structure(def)
    local desc = civ.highlight(def.description) .. "\n"
    if def.location_requirements then
        desc = desc .. "\nMust be placed next to:"
        for node, num in pairs(def.location_requirements) do
            -- get first line
            short_description = ""
            for token in string.gmatch(minetest.registered_items[node].description, "[^\n]+") do
                short_description = token
                break
            end
            desc = desc .. "\n\t" .. num .. "  " .. civ.highlight(short_description)
        end
    end
    if def.consumption_requirements then
        desc = desc .. "\nConsumes:"
        for item, rate in pairs(def.consumption_requirements) do
            desc = desc .. "\n\t" .. rate .. " " .. minetest.registered_items[item].description .. " per second"
        end
    end
    desc = desc .. "\nProduces:"
    for item, rate in pairs(def.produces) do
        desc = desc .. "\n\t" .. rate .. " " .. minetest.registered_items[item].description .. " per second"
    end
    minetest.register_node(def.name, {
        description = desc,
        mesh = def.mesh,
        tiles = def.tiles,
        drawtype = "mesh",
        sunlight_propagates = true,
        walkable = false,
        paramtype = "light",
        groups = {
            cracky = 2,
            structure = 1
        },
        on_place = function(itemstack, placer, pointed_thing)
            -- check requirements
            if def.location_requirements then
                for node, num in pairs(def.location_requirements) do
                    if civ.is_around(pointed_thing.above, node) < num then
                        minetest.chat_send_all("You can't place that here...")
                        return
                    end
                end
            end
            if def.consumption_requirements then
                for item, rate in pairs(def.consumption_requirements) do
                    if civ.get_resource_rate(item) < rate then
                        minetest.chat_send_all("You are not producing enough " .. minetest.registered_items[item].description .. " to build this...")
                        return
                    end
                end
            end
            -- then go
            for item, rate in pairs(def.produces) do
                civ.change_resource_rate(item, rate)
            end
            if def.consumption_requirements then
                for item, rate in pairs(def.consumption_requirements) do
                    civ.change_resource_rate(item, -rate)
                end
            end
            minetest.set_node(pointed_thing.above, {
                name = def.name
            })
        end,
        on_dig = function(pos, node, digger)
            for item, rate in pairs(def.produces) do
                civ.change_resource_rate(item, -rate)
            end
            if def.consumption_requirements then
                for item, rate in pairs(def.consumption_requirements) do
                    civ.change_resource_rate(item, rate)
                end
            end
            minetest.set_node(pos, {
                name = "air"
            })
        end
    })
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
