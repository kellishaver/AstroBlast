-- ================================================================
-- asteroids.lua
-- Asteroid management
local asteroids = {}
local config = require("lib/config")
local sound = require("lib/sound")

local asteroidList = {}
local spawnTimer = 0

function asteroids.load()
    asteroids.reset()
end

function asteroids.reset()
    asteroidList = {}
    spawnTimer = 0
end

function asteroids.update(dt, score)
    -- Progressive spawn rate
    local baseSpawnRate = config.ASTEROID_SPAWN_RATE
    local spawnRateReduction = math.floor(score / 1000) * 0.2
    local currentSpawnRate = math.max(0.8, baseSpawnRate - spawnRateReduction)
    
    spawnTimer = spawnTimer + dt
    if spawnTimer >= currentSpawnRate then
        asteroids.spawn("large")
        spawnTimer = 0
    end
    
    for i = #asteroidList, 1, -1 do
        local asteroid = asteroidList[i]
        asteroid.x = asteroid.x - asteroid.speed * dt
        asteroid.rotation = asteroid.rotation + asteroid.rotationSpeed * dt
        
        if asteroid.x < -asteroid.radius * 2 then
            table.remove(asteroidList, i)
        end
    end
end

function asteroids.spawn(size, x, y)
    size = size or "large"
    x = x or config.SCREEN_WIDTH + 50
    y = y or math.random(50, config.SCREEN_HEIGHT - 50)
    
    local sizeData = config.ASTEROID_SIZES[size]
    local asteroid = {
        x = x,
        y = y,
        size = size,
        radius = sizeData.radius,
        speed = math.random(config.ASTEROID_SPEED_MIN, config.ASTEROID_SPEED_MAX),
        rotation = 0,
        rotationSpeed = math.random(-2, 2),
        points = {}
    }
    
    for i = 1, sizeData.points do
        local angle = (i - 1) * (2 * math.pi / sizeData.points)
        local radiusVariation = math.random(70, 130) / 100
        local pointRadius = sizeData.radius * radiusVariation
        table.insert(asteroid.points, {
            x = math.cos(angle) * pointRadius,
            y = math.sin(angle) * pointRadius
        })
    end
    
    table.insert(asteroidList, asteroid)
end

function asteroids.draw()
    love.graphics.setColor(0.6, 0.6, 0.6)
    for _, asteroid in ipairs(asteroidList) do
        local drawPoints = {}
        for _, point in ipairs(asteroid.points) do
            local rotatedX = point.x * math.cos(asteroid.rotation) - point.y * math.sin(asteroid.rotation)
            local rotatedY = point.x * math.sin(asteroid.rotation) + point.y * math.cos(asteroid.rotation)
            table.insert(drawPoints, asteroid.x + rotatedX)
            table.insert(drawPoints, asteroid.y + rotatedY)
        end
        
        love.graphics.polygon("fill", drawPoints)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.polygon("line", drawPoints)
        love.graphics.setColor(0.6, 0.6, 0.6)
    end
end

function asteroids.getAsteroids()
    return asteroidList
end

function asteroids.removeAsteroid(index)
    table.remove(asteroidList, index)
end

function asteroids.breakAsteroid(index)
    local asteroid = asteroidList[index]
    sound.play("asteroidHit")
    
    if asteroid.size == "large" then
        local numPieces = math.random(2, 3)
        for k = 1, numPieces do
            local angle = (k - 1) * (2 * math.pi / numPieces) + math.random(-0.5, 0.5)
            local offsetX = math.cos(angle) * math.random(15, 25)
            local offsetY = math.sin(angle) * math.random(15, 25)
            asteroids.spawn("medium", asteroid.x + offsetX, asteroid.y + offsetY)
        end
    elseif asteroid.size == "medium" then
        local numPieces = math.random(1, 2)
        for k = 1, numPieces do
            local angle = (k - 1) * math.pi + math.random(-0.5, 0.5)
            local offsetX = math.cos(angle) * math.random(10, 15)
            local offsetY = math.sin(angle) * math.random(10, 15)
            asteroids.spawn("small", asteroid.x + offsetX, asteroid.y + offsetY)
        end
    end
    
    asteroids.removeAsteroid(index)
end

return asteroids