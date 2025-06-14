-- ================================================================
-- enemies.lua
-- Enemy ship management
local enemies = {}
local config = require("lib/config")
local sound = require("lib/sound")

local enemyList = {}
local enemyBullets = {}
local spawnTimer = 0

function enemies.load()
    enemies.reset()
end

function enemies.reset()
    enemyList = {}
    enemyBullets = {}
    spawnTimer = 0
end

function enemies.update(dt, score)
    -- Progressive spawn rate
    local baseSpawnRate = config.ENEMY_SPAWN_RATE
    local spawnRateReduction = math.floor(score / 400) * 0.5
    local currentSpawnRate = math.max(1.5, baseSpawnRate - spawnRateReduction)
    
    spawnTimer = spawnTimer + dt
    if spawnTimer >= currentSpawnRate then
        enemies.spawn()
        spawnTimer = 0
    end
    
    -- Update enemies
    for i = #enemyList, 1, -1 do
        local enemy = enemyList[i]
        enemy.x = enemy.x - enemy.speed * dt
        enemy.fireTimer = enemy.fireTimer - dt
        
        -- Handle rotation logic
        if math.abs(enemy.rotation - enemy.targetRotation) > 0.1 then
            local rotDiff = enemy.targetRotation - enemy.rotation
            if rotDiff > math.pi then rotDiff = rotDiff - 2 * math.pi end
            if rotDiff < -math.pi then rotDiff = rotDiff + 2 * math.pi end
            
            local rotStep = enemy.rotationSpeed * dt
            if math.abs(rotDiff) < rotStep then
                enemy.rotation = enemy.targetRotation
            else
                enemy.rotation = enemy.rotation + (rotDiff > 0 and rotStep or -rotStep)
            end
        end
        
        -- Fire at player
        if enemy.fireTimer <= 0 and enemy.bulletCount < config.MAX_ENEMY_BULLETS_PER_SHIP then
            local player = require("lib/player").getData()
            local dx = player.x - enemy.x
            local dy = player.y - enemy.y
            enemy.targetRotation = math.atan2(dy, dx)
            
            enemies.fireAtPlayer(enemy, player, score)
            enemy.returnTimer = 0.5
        end
        
        -- Return to normal orientation
        if enemy.returnTimer then
            enemy.returnTimer = enemy.returnTimer - dt
            if enemy.returnTimer <= 0 then
                enemy.targetRotation = 0
                enemy.returnTimer = nil
            end
        end
        
        if enemy.x < -enemy.size * 2 then
            table.remove(enemyList, i)
        end
    end
    
    -- Update bullets
    for i = #enemyBullets, 1, -1 do
        local bullet = enemyBullets[i]
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        
        if bullet.x < 0 or bullet.x > config.SCREEN_WIDTH or 
           bullet.y < 0 or bullet.y > config.SCREEN_HEIGHT then
            if bullet.owner then
                bullet.owner.bulletCount = bullet.owner.bulletCount - 1
            end
            table.remove(enemyBullets, i)
        end
    end
end

function enemies.spawn()
    local enemy = {
        x = config.SCREEN_WIDTH + 30,
        y = math.random(50, config.SCREEN_HEIGHT - 50),
        size = config.ENEMY_SIZE,
        speed = config.ENEMY_SPEED,
        fireTimer = math.random(1, 3),
        bulletCount = 0,
        rotation = 0,
        targetRotation = 0,
        rotationSpeed = 8
    }
    table.insert(enemyList, enemy)
end

function enemies.fireAtPlayer(enemy, player, score)
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    local dirX = dx / distance
    local dirY = dy / distance
    
    local bullet = {
        x = enemy.x,
        y = enemy.y,
        vx = dirX * config.ENEMY_BULLET_SPEED,
        vy = dirY * config.ENEMY_BULLET_SPEED,
        owner = enemy
    }
    
    table.insert(enemyBullets, bullet)
    enemy.bulletCount = enemy.bulletCount + 1
    
    -- Progressive fire rate
    local baseFire = config.ENEMY_FIRE_RATE
    local fireRateReduction = math.floor(score / 600) * 0.3
    local currentFireRate = math.max(0.8, baseFire - fireRateReduction)
    enemy.fireTimer = currentFireRate
    
    sound.play("enemyMissile")
end

function enemies.draw()
    -- Draw enemies
    love.graphics.setColor(1, 0.6, 0.2)
    for _, enemy in ipairs(enemyList) do
        local cos_r = math.cos(enemy.rotation)
        local sin_r = math.sin(enemy.rotation)
        
        local points = {
            {-enemy.size, 0},
            {enemy.size, -enemy.size/2},
            {enemy.size/2, 0},
            {enemy.size, enemy.size/2}
        }
        
        local rotatedPoints = {}
        for _, point in ipairs(points) do
            local x = point[1] * cos_r - point[2] * sin_r + enemy.x
            local y = point[1] * sin_r + point[2] * cos_r + enemy.y
            table.insert(rotatedPoints, x)
            table.insert(rotatedPoints, y)
        end
        
        love.graphics.polygon("fill", rotatedPoints)
    end
    
    -- Draw bullets
    love.graphics.setColor(0, 1, 1)
    for _, bullet in ipairs(enemyBullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, 3)
    end
end

function enemies.getEnemies()
    return enemyList
end

function enemies.getBullets()
    return enemyBullets
end

function enemies.removeEnemy(index)
    table.remove(enemyList, index)
    sound.play("enemyDestroyed")
end

function enemies.removeBullet(index)
    local bullet = enemyBullets[index]
    if bullet.owner then
        bullet.owner.bulletCount = bullet.owner.bulletCount - 1
    end
    table.remove(enemyBullets, index)
end

function enemies.updatestationBattle(dt)
    -- Different enemy spawning logic for station battle
    local baseSpawnRate = config.STATION_ENEMY_SPAWN_RATE
    
    spawnTimer = spawnTimer + dt
    if spawnTimer >= baseSpawnRate then
        -- Only spawn if we haven't defeated enough enemies yet
        local defeated, needed = require("lib/station").getProgress()
        if defeated < needed then
            enemies.spawn()
            spawnTimer = 0
        end
    end
    
    -- Update existing enemies (same as normal)
    for i = #enemyList, 1, -1 do
        local enemy = enemyList[i]
        enemy.x = enemy.x - enemy.speed * dt
        enemy.fireTimer = enemy.fireTimer - dt
        
        -- Handle rotation logic (same as normal)
        if math.abs(enemy.rotation - enemy.targetRotation) > 0.1 then
            local rotDiff = enemy.targetRotation - enemy.rotation
            if rotDiff > math.pi then rotDiff = rotDiff - 2 * math.pi end
            if rotDiff < -math.pi then rotDiff = rotDiff + 2 * math.pi end
            
            local rotStep = enemy.rotationSpeed * dt
            if math.abs(rotDiff) < rotStep then
                enemy.rotation = enemy.targetRotation
            else
                enemy.rotation = enemy.rotation + (rotDiff > 0 and rotStep or -rotStep)
            end
        end
        
        -- Fire at player
        if enemy.fireTimer <= 0 and enemy.bulletCount < config.MAX_ENEMY_BULLETS_PER_SHIP then
            local player = require("lib/player").getData()
            local dx = player.x - enemy.x
            local dy = player.y - enemy.y
            enemy.targetRotation = math.atan2(dy, dx)
            
            enemies.fireAtPlayer(enemy, player, 0) -- No score-based difficulty in station battle
            enemy.returnTimer = 0.5
        end
        
        -- Return to normal orientation
        if enemy.returnTimer then
            enemy.returnTimer = enemy.returnTimer - dt
            if enemy.returnTimer <= 0 then
                enemy.targetRotation = 0
                enemy.returnTimer = nil
            end
        end
        
        if enemy.x < -enemy.size * 2 then
            table.remove(enemyList, i)
        end
    end
    
    -- Update bullets (same as normal)
    for i = #enemyBullets, 1, -1 do
        local bullet = enemyBullets[i]
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        
        if bullet.x < 0 or bullet.x > config.SCREEN_WIDTH or 
           bullet.y < 0 or bullet.y > config.SCREEN_HEIGHT then
            if bullet.owner then
                bullet.owner.bulletCount = bullet.owner.bulletCount - 1
            end
            table.remove(enemyBullets, i)
        end
    end
end

-- Override the removeEnemy function to notify station of defeat
local originalRemoveEnemy = enemies.removeEnemy
function enemies.removeEnemy(index)
    originalRemoveEnemy(index)
    -- Notify station system of enemy defeat
    require("lib/station").enemyDefeated()
end
return enemies