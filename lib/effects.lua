-- ================================================================
-- effects.lua
-- Visual effects and animations
local effects = {}
local config = require("lib/config")

local stars = {}

function effects.load()
    effects.generateStars()
end

function effects.generateStars()
    stars = {}
    for i = 1, config.STAR_COUNT do
        table.insert(stars, {
            x = math.random(0, config.SCREEN_WIDTH),
            y = math.random(0, config.SCREEN_HEIGHT),
            speed = math.random(config.STAR_SPEED_MIN, config.STAR_SPEED_MAX),
            brightness = math.random(30, 100) / 100,
            size = math.random(1, 3)
        })
    end
end

function effects.updateStars(dt)
    for _, star in ipairs(stars) do
        star.x = star.x - star.speed * dt
        if star.x < 0 then
            star.x = config.SCREEN_WIDTH + math.random(0, 50)
            star.y = math.random(0, config.SCREEN_HEIGHT)
            star.speed = math.random(config.STAR_SPEED_MIN, config.STAR_SPEED_MAX)
            star.brightness = math.random(30, 100) / 100
        end
    end
end

function effects.drawStars()
    for _, star in ipairs(stars) do
        love.graphics.setColor(star.brightness, star.brightness, star.brightness)
        if star.size == 1 then
            love.graphics.points(star.x, star.y)
        else
            love.graphics.circle("fill", star.x, star.y, star.size * 0.5)
        end
    end
end

return effects