-- ================================================================
-- config.lua
-- Game configuration and constants
local config = {}

config.SCREEN_WIDTH = 800
config.SCREEN_HEIGHT = 600

-- Player settings
config.PLAYER_SPEED = 300
config.PLAYER_SIZE = 15
config.PLAYER_LIVES = 4

-- Missile settings
config.MISSILE_SPEED = 500
config.MAX_MISSILES = 5
config.MISSILE_WIDTH = 8
config.MISSILE_HEIGHT = 3

-- Enemy settings
config.ENEMY_SPEED = 180
config.ENEMY_SIZE = 18
config.ENEMY_BULLET_SPEED = 300
config.ENEMY_SPAWN_RATE = 4.0
config.ENEMY_FIRE_RATE = 2.0
config.MAX_ENEMY_BULLETS_PER_SHIP = 3

-- Asteroid settings
config.ASTEROID_SPEED_MIN = 80
config.ASTEROID_SPEED_MAX = 150
config.ASTEROID_SPAWN_RATE = 1.5
config.ASTEROID_SIZES = {
    small = {radius = 12, points = 6},
    medium = {radius = 20, points = 8},
    large = {radius = 32, points = 10}
}

-- Powerup settings
config.POWERUP_SPEED = 100
config.POWERUP_SIZE = 12

-- Game settings
config.INVULNERABILITY_TIME = 2.0
config.STAR_COUNT = 200
config.STAR_SPEED_MIN = 50
config.STAR_SPEED_MAX = 200
config.SCROLL_SPEED = 220

-- Battle for station settings
config.STATION_TRIGGER_DISTANCE = 20000
config.STATION_ENEMIES_TO_DEFEAT = 20
config.STATION_ENEMY_SPAWN_RATE = 1.0

return config