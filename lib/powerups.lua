-- ================================================================
-- powerups.lua
-- Powerup management
local powerups = {}
local config = require("lib/config")
local sound = require("lib/sound")

local powerupList = {}

function powerups.load()
    powerups.reset()
end

function powerups.reset()
    powerupList = {}
end

function powerups.update(dt)
    for i = #powerupList, 1, -1 do
        local powerup = powerupList[i]
        powerup.x = powerup.x - powerup.speed * dt
        
        if powerup.x < -powerup.size * 2 then
            table.remove(powerupList, i)
        end
    end
end

function powerups.spawn()
    local powerup = {
        x = config.SCREEN_WIDTH + 30,
        y = math.random(50, config.SCREEN_HEIGHT - 50),
        size = config.POWERUP_SIZE,
        speed = config.POWERUP_SPEED
    }
    table.insert(powerupList, powerup)
end

function powerups.draw()
    love.graphics.setColor(0.2, 1, 0.3)
    for _, powerup in ipairs(powerupList) do
        love.graphics.polygon("fill",
            powerup.x - powerup.size, powerup.y,
            powerup.x + powerup.size, powerup.y - powerup.size/2,
            powerup.x + powerup.size/2, powerup.y,
            powerup.x + powerup.size, powerup.y + powerup.size/2
        )
        
        love.graphics.setColor(0.1, 0.8, 0.2)
        love.graphics.polygon("line",
            powerup.x - powerup.size, powerup.y,
            powerup.x + powerup.size, powerup.y - powerup.size/2,
            powerup.x + powerup.size/2, powerup.y,
            powerup.x + powerup.size, powerup.y + powerup.size/2
        )
        love.graphics.setColor(0.2, 1, 0.3)
    end
end

function powerups.getPowerups()
    return powerupList
end

function powerups.removePowerup(index)
    table.remove(powerupList, index)
    sound.play("playerLife")
end

return powerups