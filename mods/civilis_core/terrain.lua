
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
local dark_grey = "civ_white.png^[colorize:#9499a1:"..strength

minetest.register_node(c.."stonegrass", {
	description = "stone with grass",
	tiles = {"civ_grass.png", "civ_grass.png", "civ_stone_with_grass.png", "civ_stone_with_grass.png", "civ_stone_with_grass.png", "civ_stone_with_grass.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stoneblock", {
	description = "stone",
	tiles = {"civ_stone.png"},
	groups = {cracky=2}
})

minetest.register_node(c.."grass", {
	description = "grass",
	tiles = {"civ_grass.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."water", {
	description = "Water",
	tiles = {"civ_water.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,6/16,0.5},
	},
	groups = {cracky=2}
})
--grassy slopes
minetest.register_node(c.."grassyslope1", {
	description = "grassy slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope.obj",
	tiles = {"civ_grass.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."grassyslope2", {
	description = "grassy slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_2.obj",
	tiles = {"civ_grass.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."grassyslope3", {
	description = "grassy slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_3.obj",
	tiles = {"civ_grass.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."grassyslope4", {
	description = "grassy slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_4.obj",
	tiles = {"civ_grass.png"},
	groups = {cracky=2}
})
--stony slopes
minetest.register_node(c.."stonyslope1", {
	description = "stony slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope.obj",
	tiles = {"civ_stone.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stonyslope2", {
	description = "stony slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_2.obj",
	tiles = {"civ_stone.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stonyslope3", {
	description = "stony slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_3.obj",
	tiles = {"civ_stone.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stonyslope4", {
	description = "stony slope",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_slope_4.obj",
	tiles = {"civ_stone.png"},
	groups = {cracky=2}
})
--terain models
minetest.register_node(c.."forest", {
	description = "Forest",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "civ_forest.obj",
	tiles = {dark_green, "civ_wood.png"},
	groups = {cracky=2}
})
minetest.register_node(c.."stonepile", {
	description = "Rock Pile",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "stonepile.obj",
	tiles = {"civ_stone_small.png^[colorize:black:30"},
	groups = {cracky=2}
})
minetest.register_node(c.."crystalpile", {
	description = "Crystal Pile",
	drawtype = "mesh",
	sunlight_propagates = true;
	paramtype = "light";
	mesh = "stonepile.obj",
	tiles = {"civ_stone_small.png^[colorize:blue:30"},
	groups = {cracky=2}
})