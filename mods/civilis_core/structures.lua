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
-- Wood
civ.register_structure({
    name = c .. "woodhouse",
    description = "Lumber Storehouse",
    mesh = "civ_woodhouse.obj",
    tiles = {"civ_wood.png", black, grey, pink, brown},
    produces = {
        [c .. "lumber"] = 0.2
    },
    location_requirements = {
        [c .. "forest"] = 1,
        [c .. "road"] = 1
    },
})
civ.register_structure({
    name = c .. "woodhouse2",
    description = "Large Lumber Storehouse",
    mesh = "civ_woodhouse2.obj",
    tiles = {black, grey, pink, brown, "civ_wood.png"},
    produces = {
        [c .. "lumber"] = 0.4
    },
    location_requirements = {
        [c .. "forest"] = 1,
        [c .. "road"] = 1
    },
})
civ.register_structure({
    name = c .. "woodhouse3",
    description = "Automated Storehouse",
    mesh = "civ_woodhouse3.obj",
    tiles = {black, grey, pink, brown, dark_grey, "civ_wood.png"},
    produces = {
        [c .. "lumber"] = 0.6
    },
    location_requirements = {
        [c .. "forest"] = 1,
        [c .. "power_line"] = 1
    },
    consumption_requirements = {
        [c .. "power"] = 0.1
    }
})

-- Mine
civ.register_structure({
    name = c .. "mine",
    description = "Mine",
    mesh = "civ_mine.obj",
    tiles = {grey, black},
    produces = {
        [c .. "stone"] = 0.2
    },
    location_requirements = {
        [c .. "stonepile"] = 1,
        [c .. "road"] = 1
    },
})
civ.register_structure({
    name = c .. "mine2",
    description = "Large Mine",
    mesh = "civ_mine2.obj",
    tiles = {grey, "civ_stone_small.png", black},
    produces = {
        [c .. "stone"] = 0.3
    },
    location_requirements = {
        [c .. "stonepile"] = 1,
        [c .. "road"] = 1
    },
})
civ.register_structure({
    name = c .. "mine3",
    description = "Industrial Mine",
    mesh = "civ_mine3.obj",
    tiles = {grey, black, yellow},
    produces = {
        [c .. "stone"] = 0.5
    },
    location_requirements = {
        [c .. "stonepile"] = 1,
        [c .. "power_line"] = 1
    },
})

-- Metal
civ.register_structure({
    name = c .. "refinery",
    description = "Refinery",
    mesh = "civ_refinery.obj",
    tiles = {grey, black, yellow},
    produces = {
        [c .. "metal"] = 0.1
    },
    location_requirements = {
        [c .. "road"] = 2
    },
    consumption_requirements = {
        [c .. "stone"] = 0.5,
        [c .. "coal"] = 0.2
    }
})

-- Machine Parts
civ.register_structure({
    name = c .. "workshop",
    description = "Workshop",
    mesh = "civ_refinery.obj",
    tiles = {grey, black, yellow},
    produces = {
        [c .. "metal"] = 0.1
    },
    location_requirements = {
        [c .. "road"] = 2,
        [c .. "road"] = 2
    },
    consumption_requirements = {
        [c .. "metal"] = 0.2,
        [c .. "coal"] = 0.1
    }
})

-- Coal
civ.register_structure({
    name = c .. "coal_mine",
    description = "Coal Mine",
    mesh = "civ_mine.obj",
    tiles = {grey, black},
    produces = {
        [c .. "coal"] = 0.1
    },
    location_requirements = {
        [c .. "road"] = 2,
        [c .. "stonepile"] = 1
    },
    consumption_requirements = nil
})

-- Crystals
civ.register_structure({
    name = c .. "crystal_mine",
    description = "Crystal Mine",
    mesh = "civ_mine.obj",
    tiles = {grey, black},
    produces = {
        [c .. "crystal"] = 0.05
    },
    location_requirements = {
        [c .. "road"] = 2,
        [c .. "stonepile"] = 1
    },
    consumption_requirements = nil
})
civ.register_structure({
    name = c .. "crystal_house",
    description = "Crystal Storehouse",
    mesh = "civ_crystal_house.obj",
    tiles = {grey, black},
    produces = {
        [c .. "crystal"] = 0.05
    },
    location_requirements = {
        [c .. "road"] = 2,
        [c .. "forest"] = 1
    },
    consumption_requirements = nil
})
civ.register_structure({
    name = c .. "crystal_house",
    description = "Crystal Storehouse",
    mesh = "civ_crystal_house.obj",
    tiles = {grey, black},
    produces = {
        [c .. "crystal"] = 0.05
    },
    location_requirements = {
        [c .. "road"] = 2,
        [c .. "forest"] = 1
    },
    consumption_requirements = nil
})

-- Farm
civ.register_structure({
    name = c .. "farm",
    description = "Farm",
    mesh = "civ_farm.obj",
    tiles = {"civ_wood.png", brown, pink, grey},
    produces = {
        [c .. "grain"] = 0.2
    },
    location_requirements = {
        [c .. "road"] = 1,
        [c .. "water"] = 2
    },
    consumption_requirements = nil
})
civ.register_structure({
    name = c .. "farm2",
    description = "Industrial Farm",
    mesh = "civ_farm2.obj",
    tiles = {"civ_wood.png", brown, pink, grey},
    produces = {
        [c .. "grain"] = 0.5
    },
    location_requirements = {
        [c .. "road"] = 1,
        [c .. "water"] = 2,
        [c .. "power_line"] = 1
    },
    consumption_requirements = {
        [c .. "power"] = 0.3
    }
})

-- Power Plant
civ.register_structure({
    name = c .. "power_plant",
    description = "Coal Power Plant",
    mesh = "civ_power_plant.obj",
    tiles = {grey, brown, black, dark_grey, yellow},
    produces = {
        [c .. "power"] = 0.5
    },
    location_requirements = {
        [c .. "road"] = 1,
        [c .. "water"] = 1
    },
    consumption_requirements = {
        [c .. "coal"] = 0.3
    }
})
civ.register_structure({
    name = c .. "power_plant_crystal",
    description = "Crystal Power Plant",
    mesh = "civ_power_plant_crystal.obj",
    tiles = {"civ_wood.png", brown, pink, grey},
    produces = {
        [c .. "power"] = 0.75
    },
    location_requirements = {
        [c .. "road"] = 1,
    },
    consumption_requirements = {
        [c .. "crystal"] = 0.1
    }
})
