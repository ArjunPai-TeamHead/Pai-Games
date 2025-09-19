-- Mars Survival Game Configuration
-- Central configuration for all game systems

local GameConfig = {}

-- Game Settings
GameConfig.GAME_NAME = "Mars Survival"
GameConfig.VERSION = "1.0.0"

-- Day/Night Cycle Settings
GameConfig.DAY_DURATION = 300 -- 5 minutes in seconds
GameConfig.NIGHT_DURATION = 180 -- 3 minutes in seconds
GameConfig.DAWN_DURATION = 30 -- 30 seconds
GameConfig.DUSK_DURATION = 30 -- 30 seconds

-- Survival Settings
GameConfig.STARTING_OXYGEN = 100
GameConfig.STARTING_ENERGY = 100
GameConfig.STARTING_WARMTH = 100
GameConfig.STARTING_HUNGER = 100

GameConfig.OXYGEN_DECAY_RATE = 2 -- per minute during day
GameConfig.OXYGEN_DECAY_RATE_NIGHT = 4 -- per minute during night
GameConfig.ENERGY_DECAY_RATE = 1.5
GameConfig.WARMTH_DECAY_RATE_DAY = 1
GameConfig.WARMTH_DECAY_RATE_NIGHT = 5
GameConfig.HUNGER_DECAY_RATE = 0.8

-- Mining Settings
GameConfig.MINING_RANGES = {
    IRON = {min = 1, max = 5},
    COPPER = {min = 1, max = 3},
    TITANIUM = {min = 1, max = 2},
    RARE_EARTH = {min = 1, max = 1},
    ICE = {min = 2, max = 8}
}

GameConfig.MINING_EXPERIENCE = {
    IRON = 10,
    COPPER = 15,
    TITANIUM = 25,
    RARE_EARTH = 50,
    ICE = 5
}

-- Resource Values (for trading)
GameConfig.RESOURCE_VALUES = {
    IRON = 10,
    COPPER = 25,
    TITANIUM = 75,
    RARE_EARTH = 200,
    ICE = 5,
    FOOD = 15,
    OXYGEN_TANK = 30
}

-- Progression Settings
GameConfig.LEVEL_EXPERIENCE_BASE = 100
GameConfig.LEVEL_EXPERIENCE_MULTIPLIER = 1.5

GameConfig.SKILLS = {
    MINING = "Mining",
    ENGINEERING = "Engineering",
    SURVIVAL = "Survival",
    COMBAT = "Combat",
    SCIENCE = "Science"
}

-- Job System
GameConfig.JOBS = {
    MINER = {name = "Miner", pay = 50, xp_bonus = {"MINING"}},
    ENGINEER = {name = "Engineer", pay = 75, xp_bonus = {"ENGINEERING"}},
    SCIENTIST = {name = "Scientist", pay = 100, xp_bonus = {"SCIENCE"}},
    SECURITY = {name = "Security", pay = 60, xp_bonus = {"COMBAT"}},
    TRADER = {name = "Trader", pay = 80, xp_bonus = {}}
}

-- Base Building
GameConfig.BUILDING_COSTS = {
    SHELTER_BASIC = {IRON = 20, COPPER = 5},
    SHELTER_ADVANCED = {IRON = 50, COPPER = 15, TITANIUM = 10},
    MINING_DRILL = {IRON = 30, COPPER = 20, TITANIUM = 5},
    DEFENSE_TURRET = {IRON = 40, COPPER = 25, TITANIUM = 15},
    SOLAR_PANEL = {COPPER = 30, RARE_EARTH = 5},
    GREENHOUSE = {IRON = 25, COPPER = 10, ICE = 50}
}

-- Hostile Mobs (Night)
GameConfig.MOBS = {
    DUST_DEVIL = {health = 50, damage = 15, speed = 8},
    MARS_SPIDER = {health = 30, damage = 10, speed = 12},
    SAND_CRAWLER = {health = 80, damage = 25, speed = 6}
}

-- Rocket Building Requirements
GameConfig.ROCKET_COMPONENTS = {
    ENGINE = {TITANIUM = 100, RARE_EARTH = 50, COPPER = 75},
    FUEL_TANK = {IRON = 200, COPPER = 100},
    NAVIGATION = {RARE_EARTH = 75, COPPER = 150},
    LIFE_SUPPORT = {TITANIUM = 50, COPPER = 100, ICE = 500},
    HULL = {IRON = 500, TITANIUM = 200}
}

-- Planet Creation Requirements
GameConfig.PLANET_REQUIREMENTS = {
    TERRAFORM_MODULE = {RARE_EARTH = 1000, TITANIUM = 500},
    ATMOSPHERE_GENERATOR = {RARE_EARTH = 750, COPPER = 300},
    GRAVITY_STABILIZER = {RARE_EARTH = 500, TITANIUM = 300},
    ECOSYSTEM_SEED = {ICE = 2000, RARE_EARTH = 200}
}

return GameConfig