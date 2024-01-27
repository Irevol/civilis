
c = "civilis_core:"
data = minetest.get_mod_storage()
civ = {}

local path = minetest.get_modpath("civilis_core")
dofile(path.."/functions.lua")
dofile(path.."/menu.lua")
dofile(path.."/materials.lua")
dofile(path.."/terrain.lua")
dofile(path.."/crafting.lua")
dofile(path.."/structures.lua") --should be split into multiple documents (if not mods)

minetest.register_lbm({
    label = "start timer",
    name = c.."start_timer",
    nodenames = {c.."base"},
    run_at_every_load = true,
    action = function(pos, node)
		minetest.get_node_timer(pos):start(1)
	end,
})

data:get_int("event_period")

--
--temporary
--
minetest.register_node(c.."grasst", {
	description = "grasst",
	tiles = {"civ_grass_small.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stonet", {
	description = "stonet",
	tiles = {"civ_stone_small.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."wood", {
	description = "wood",
	tiles = {"civ_wood.png"},
	groups = {cracky=2}
})


local strength = "230"
local black = "civ_white.png^[colorize:#000000:"..strength
local blue = "civ_white.png^[colorize:#2b72de:"..strength
local cyan = "civ_white.png^[colorize:#7aa3e6:"..strength
local dark_green = "civ_white.png^[colorize:#315721:"..strength
local green = "civ_white.png^[colorize:#64ae49:"..strength
local orange = "civ_white.png^[colorize:#ffa319:"..strength
local pink = "civ_white.png^[colorize:#ffe7cf:"..strength
local red = "civ_white.png^[colorize:#ff840170:"..strength
local yellow = "civ_white.png^[colorize:#ffd21c:"..strength
local brown = "civ_white.png^[colorize:#4a240d:"..strength
local grey = "civ_white.png^[colorize:#9499a1:"..strength
local dark_grey = "civ_white.png^[colorize:#424242:"..strength
local all_colours = {
	{"black",    black},
	{"blue",      blue},
	{"cyan",      cyan},
	{"dark_green", dark_green},
	{"green",  green},
	{"orange",     orange},
	{"pink",    pink},
	{"red",  red},
	{"yellow",     yellow},
	{"brown",     brown},
	{"grey",     grey},
	{"dark_grey", dark_grey},
}
for _, col in ipairs(all_colours) do

	minetest.register_node(c..col[1], {
		description = col[1].." block",
		tiles = {col[2]},
		groups = {cracky=2}
	})
	
end


