local function get_selection_formspec()
    local formspec = ''
    for i, recipe in ipairs(civ.recipes) do
        -- dont show unresearched recipes
        if data:get_string(recipe[2]) ~= '' then
            local y_offset = (i - 1) * 1.1
            formspec = table.concat({formspec, 'item_image[0.5,' .. y_offset .. ';1,1;' .. recipe[2] .. ']', 'button[1.5,' .. y_offset .. ';5,1;' .. recipe[2] .. ';Craft ' .. recipe[1] .. ']'})
        end
    end
    return formspec
end

local function get_crafting_formspec(recipe)
    local formspec = 'size[10,10]' .. 'label[0.5,0.5;Materials Required to Craft:]'
    for i, requirement in ipairs(recipe[3]) do
        local stack = ItemStack(requirement)
        local y_offset = (i + 1) * 1
        formspec = table.concat({formspec, 'item_image[0.5,' .. y_offset .. ';1,1;' .. stack:get_name() .. ']', 'label[1.5,' .. y_offset .. ';x' .. stack:get_count() .. ']'})
    end
    return formspec .. 'button[1,9;4,1;' .. recipe[2] .. ';Craft]' .. 'button_exit[5,9;4,1;exit;Exit]'
end

local function get_materials_formspec()
    local basemeta = minetest.get_meta(minetest.deserialize(data:get_string('basepos')))
    local formspec = ''
    for i, material in ipairs(civ.materials) do
        if (basemeta:get_float(material .. 'rate') ~= 0) and (basemeta:get_float(material .. 'rate') ~= '') then
            local y_offset = (i - 1) * 1.1
            formspec = formspec .. 'item_image[1,' .. y_offset .. ';1,1;' .. material .. ']' .. 'label[2,' .. y_offset + 0.2 .. ';produced per a second: ' .. basemeta:get_float(material .. 'rate') .. ']'
        end
    end
    return formspec
end

local function get_research_formspec()
    local formspec = ''
    for i, recipe in ipairs(civ.recipes) do
        -- if unresearched
        if data:get_string(recipe[2]) == '' then
            local flag = true
			--if all requirements are researched
            for _, req in ipairs(recipe[6]) do
                if data:get_string(req) == '' then
                    flag = false
                end
            end
            if flag then
                local y_offset = (i - 1) * 1.1
                formspec = formspec .. 'item_image[0.5,' .. y_offset .. ';1,1;' .. recipe[2] .. ']' .. 'button_exit[1.5,' .. y_offset .. ';5,1;' .. recipe[2] .. '_research;Unlock ' .. recipe[1] .. ' (costs ' .. recipe[5] .. ' research)]'
            end
        end
    end
    return formspec
end

minetest.register_node(c .. 'timer', {
    description = 'timer',
    drawtype = 'airlike',
    pointable = false,
    -- on_construct = function(pos)
    -- local meta = minetest.get_meta(pos)
    -- meta:set_float("crafttime", 0)
    -- end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local totaltime = meta:get_float('totaltime')
        local crafttime = meta:get_float('crafttime')
        meta:set_float('crafttime', meta:get_float('crafttime') + 0.2)
        local formspec = 'size[9,5]' .. 'image[0.5,0.5;8,1;(progress_bar_background.png^[lowpart:' .. (crafttime / totaltime) * 100 .. ':civ_progress_bar.png)^[transformR270 ]'
        if crafttime < totaltime then
            minetest.show_formspec(meta:get_string('player'), c .. 'timer', formspec)
            return true
        else
            minetest.show_formspec(meta:get_string('player'), c .. 'timer', '')
            minetest.set_node(pos, {
                name = 'air'
            })
            return false
        end
    end
})

sfinv.register_page(c .. 'resources', {
    title = 'Resource Rates',
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, 'box[0.05,0.05;8,4.9;grey]' .. get_materials_formspec(), true)
    end
})

sfinv.register_page(c .. 'structcraft', {
    title = 'Crafting',
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, 'box[0.05,0.05;8,4.9;grey]' .. 'scrollbaroptions[min=0;max=300;largestep=100,smallstep=10]' .. 'scrollbar[0,0;0.5,5;vertical;scrollbar;0]' .. 'scroll_container[0.2,0.4;11,5.7;scrollbar;vertical]' .. get_selection_formspec() .. 'scroll_container_end[]', true)
    end
})

sfinv.register_page(c .. 'research', {
    title = 'Research',
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, 'box[0.05,0.05;8,4.9;grey]' .. 'scrollbaroptions[min=0;max=300;largestep=100,smallstep=10]' .. 'scrollbar[0,0;0.5,5;vertical;scrollbar;0]' .. 'scroll_container[0.2,0.4;11,5.7;scrollbar;vertical]' .. get_research_formspec() .. 'scroll_container_end[]', true)
    end
})

minetest.register_on_player_receive_fields( -- what a mess...
function(player, formname, fields)
    for field, _ in pairs(fields) do
        for _, recipe in ipairs(civ.recipes) do
			--crafting
            if recipe[2] == field then
				--2nd form
                if formname == c .. 'craft' then
                    local inv = minetest.get_inventory({
                        type = 'player',
                        name = player:get_player_name()
                    })
                    -- check if you have materials
                    for _, requirement in ipairs(recipe[3]) do
                        if not inv:contains_item('main', requirement) then
                            minetest.chat_send_all('You don\'t have the nessicary materials!')
                            return
                        end
                    end
                    -- then take them
                    for _, requirement in ipairs(recipe[3]) do
                        inv:remove_item('main', requirement)
                    end
                    -- then take some time
                    local timerpos = player:get_pos()
                    -- theoretically nothing should be where the player's head is
                    timerpos.y = timerpos.y + 1
                    minetest.set_node(timerpos, {
                        name = c .. 'timer'
                    })
                    local meta = minetest.get_meta(timerpos)
                    meta:set_float('totaltime', recipe[4])
                    meta:set_string('player', player:get_player_name())
                    minetest.get_node_timer(timerpos):start(0.1)

                    minetest.after(recipe[4], function(output)
                        inv:add_item('main', output)
                    end, recipe[2])
				-- first "selection" form
                else
                    minetest.show_formspec(player:get_player_name(), c .. 'craft', get_crafting_formspec(recipe))
                end
			--research
            elseif recipe[2] .. '_research' == field then
                local inv = minetest.get_inventory({
                    type = 'player',
                    name = player:get_player_name()
                })
                if inv:contains_item('main', c .. 'research ' .. recipe[5]) then
                    data:set_string(recipe[2], 'researched')
                    inv:remove_item('main', c .. 'research ' .. recipe[5])
                else
                    minetest.chat_send_all('You don\'t have enough research!')
                end
            end
        end
    end
end)

-----------------------------------------------------------------
-- Register Recipes --

civ.register_recipe('Mine', c .. 'mine', {c .. 'lumber 10'}, 3, 5, {})
civ.register_recipe('Lumber Storehouse', c .. 'woodhouse', {c .. 'stone 10'}, 10, 5, {})
civ.register_recipe('Well', c .. 'well', {c .. 'lumber 10'}, 10, 5, {})
civ.register_recipe('Farm', c .. 'farm', {c .. 'lumber 10'}, 10, 5, {})
