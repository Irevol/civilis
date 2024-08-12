function civ.is_around(pos, targetname, radius)
    local found = 0
    local radius = radius or 1
    for x = -radius, radius do
        for z = -radius, radius do
            local check_pos = {
                x = pos.x + x,
                y = pos.y,
                z = pos.z + z
            }
            if minetest.get_node(pos).name == targetname then
                found = found + 1 
            end
        end
    end
    return found
end

function civ.get_surrounding_structs(pos, radius)
    local radius = radius or 1
    local structs = {}
    for x = -radius, radius do
        for z = -radius, radius do
            local check_pos = {
                x = pos.x + x,
                y = pos.y,
                z = pos.z + z
            }
            if civ.is_structure(check_pos) then
                   table.insert(structs, minetest.get_node(check_pos).name)
            end
        end
    end
    return structs
end

function civ.get_resource_rate(resource)
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    local net_rate = 0
    for _, link in pairs(minetest.deserialize(basemeta:get_string("links"))) do
        for item, rate in link.consumes do
            if item == resource then
                net_rate = net_rate - rate
                break
            end
        end
        for item, rate in link.produces do
            if item == resource then
                net_rate = net_rate + rate
                break
            end
        end
    end
    return net_rate
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
            civ.update_node({
                x = pos.x + x,
                y = pos.y + y,
                z = pos.z + z
            })
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

function civ.register_link(consumed, produced)
    local active = active or true
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    basemeta:set_string(minetest.serialize(table.insert(minetest.deserialize(basemeta:get_string("links")), {consumes=def.consumes or {}, produces=def.produces})))
end

function civ.unregister_link(consumed, produced)
    local links = minetest.deserialize(basemeta:get_string("links"))
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    for i, link in minetest.deserialize(basemeta:get_string("links")) do
        if link[1] == consumed and link[2] == produced then
            table.remove(links, i)
        end
    end
    basemeta:set_string(minetest.serialize(links))
end

local function get_actual_production(count, dependant_produces, produces)
    for item, rate in dependant_produces do
        produces[item] = rate*count + (produces[item] or 0)
    end
    return produces
end

function civ.register_structure(def)

    local desc = civ.highlight(def.description) .. "\n"
    def.consumes = def.consumes or {}
    def.produces = def.produces or {}

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
    --consumes
    if def.consumes then
        desc = desc .. "\nConsumes:"
        for item, rate in pairs(def.consumes) do
            desc = desc .. "\n\t" .. rate .. " " .. minetest.registered_items[item].description .. " per second"
        end
    end
    --produces
    if def.produces then
        desc = desc .. "\nProduces:"
        for item, rate in pairs(def.produces) do
            desc = desc .. "\n\t" .. rate .. " " .. minetest.registered_items[item].description .. " per second"
        end 
    end
    --extra
    if def.extra_description then
        desc = desc .. "\n"+extra_description
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
                    if node == "water" then
                        if civ.is_around_water(pointed_thing.above) < num then
                            minetest.chat_send_all("You can't place that here...")
                            return                           
                        end
                    else
                        if civ.is_around(pointed_thing.above, node) < num then
                            minetest.chat_send_all("You can't place that here...")
                            return
                        end
                    end
                end
            end
            -- then go
            minetest.item_place_node(itemstack, placer, pointed_thing)
            if def.dependant_produces then
                local count = def.dependant_count(pos)
                civ.register_link(def.consumes, get_actual_production(count, def.dependant_produces, def.produces))
                meta:set_int("last_struct_count", count)
            else
                civ.register_link(def.consumes or {}, def.produces)
            end     
        end,
        on_dig = function(pos, node, digger)
            if def.dependant_produces then
                civ.unregister_link(def.consumes, get_actual_production(meta:get_int("last_struct_count"), def.dependant_produces, def.produces))
            else
                civ.unregister_link(def.consumes, def.produces)
            end
            minetest.dig_node(pos, digger)
        end,
        _update = function(pos)
            if def.dependant_produces then
                local meta = minetest.get_meta(pos)
                local count = def.dependant_count(pos)
                civ.register_link(def.consumes, get_actual_production(count, def.dependant_produces, def.produces))
                civ.unregister_link(def.consumes, get_actual_production(meta:get_int("last_struct_count"), def.dependant_produces, def.produces))
                meta:set_int("last_struct_count", count)
            end
        end
    })
end

function civ.get_fall_chance(pos)
    local structs = civ.get_surrounding_structs(pos, 2)
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string("basepos")))
    local chance = basemeta:get_int("fall_chance")
    for struct in structs do 
        if struct == c.."anchor" then
            chance = chance - 1
        end
        if chance < 0 then
            chance = 0
        end
    end
    return chance
end

function civ.execute_event()
    for x = -12, 12 do
        for z = -12, 12 do
            local pos = {x=pos.x+x,y=pos.y,z=pos.z+z}
            local node = minetest.get_node(pos)
            local chance = civ.get_fall_chance()
            if civ.is_around(pos, "air") and (node.name == c.."stoneblock" or node.name == c.."stonegrass") then
                if math.random(0, chance) == 1 then
                    for y=-3, 3 do
                         minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z}, {name == "air"})
                    end
                end
             end
        end
    end
end