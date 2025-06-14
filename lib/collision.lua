-- ================================================================
-- collision.lua
-- Collision detection and management
local collision = {}

local scoreThisFrame = 0

function collision.checkAll(player, enemies, asteroids, powerups)
    scoreThisFrame = 0
    local playerData = player.getData()
    local playerHit = nil
    
    if not player.isInvulnerable() then
        -- Check player vs asteroids
        playerHit = collision.checkPlayerAsteroids(playerData, asteroids)
        
        -- Check player vs enemy bullets
        if not playerHit then
            playerHit = collision.checkPlayerEnemyBullets(playerData, enemies)
        end
        
        -- Check player vs enemy ships
        if not playerHit then
            playerHit = collision.checkPlayerEnemies(playerData, enemies)
        end
    end
    
    -- Check player vs powerups (always allowed)
    local powerupHit = collision.checkPlayerPowerups(playerData, powerups)
    if powerupHit then
        playerHit = powerupHit
    end
    
    -- Check missiles vs targets
    collision.checkMissileTargets(playerData, enemies, asteroids)
    
    return playerHit
end

function collision.checkPlayerAsteroids(playerData, asteroids)
    for j, asteroid in ipairs(asteroids.getAsteroids()) do
        local dx = playerData.x - asteroid.x
        local dy = playerData.y - asteroid.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < asteroid.radius + playerData.size * 0.8 then
            asteroids.breakAsteroid(j)
            return {damage = 1, type = "asteroid"}
        end
    end
    return nil
end

function collision.checkPlayerEnemyBullets(playerData, enemies)
    for i, bullet in ipairs(enemies.getBullets()) do
        local dx = bullet.x - playerData.x
        local dy = bullet.y - playerData.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < playerData.size * 0.8 then
            enemies.removeBullet(i)
            return {damage = 1, type = "bullet"}
        end
    end
    return nil
end

function collision.checkPlayerEnemies(playerData, enemies)
    for i, enemy in ipairs(enemies.getEnemies()) do
        local dx = playerData.x - enemy.x
        local dy = playerData.y - enemy.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < enemy.size + playerData.size * 0.8 then
            enemies.removeEnemy(i)
            return {damage = 1, type = "enemy"}
        end
    end
    return nil
end

function collision.checkPlayerPowerups(playerData, powerups)
    for i, powerup in ipairs(powerups.getPowerups()) do
        local dx = playerData.x - powerup.x
        local dy = playerData.y - powerup.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < powerup.size + playerData.size * 0.8 then
            powerups.removePowerup(i)
            return {damage = -1, type = "powerup"} -- Negative damage = heal
        end
    end
    return nil
end

function collision.checkMissileTargets(playerData, enemies, asteroids)
    for i = #playerData.missiles, 1, -1 do
        local missile = playerData.missiles[i]
        
        -- Check missile vs asteroids
        for j, asteroid in ipairs(asteroids.getAsteroids()) do
            local dx = missile.x - asteroid.x
            local dy = missile.y - asteroid.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < asteroid.radius then
                table.remove(playerData.missiles, i)
                asteroids.breakAsteroid(j)
                scoreThisFrame = scoreThisFrame + 10
                break
            end
        end
        
        -- Check missile vs enemies (if missile still exists)
        if playerData.missiles[i] then
            for j, enemy in ipairs(enemies.getEnemies()) do
                local dx = missile.x - enemy.x
                local dy = missile.y - enemy.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < enemy.size then
                    table.remove(playerData.missiles, i)
                    enemies.removeEnemy(j)
                    scoreThisFrame = scoreThisFrame + 50
                    break
                end
            end
        end
    end
end

function collision.getScoreThisFrame()
    return scoreThisFrame
end


function collision.checkstationBattle(player, enemies, powerups)
    scoreThisFrame = 0
    local playerData = player.getData()
    local playerHit = nil
    
    if not player.isInvulnerable() then
        -- Check player vs enemy bullets
        playerHit = collision.checkPlayerEnemyBullets(playerData, enemies)
        
        -- Check player vs enemy ships
        if not playerHit then
            playerHit = collision.checkPlayerEnemies(playerData, enemies)
        end
    end
    
    -- Check player vs powerups (always allowed)
    local powerupHit = collision.checkPlayerPowerups(playerData, powerups)
    if powerupHit then
        playerHit = powerupHit
    end
    
    -- Check missiles vs enemies (no asteroids in station battle)
    collision.checkMissileEnemies(playerData, enemies)
    
    return playerHit
end

function collision.checkMissileEnemies(playerData, enemies)
    for i = #playerData.missiles, 1, -1 do
        local missile = playerData.missiles[i]
        
        -- Check missile vs enemies
        for j, enemy in ipairs(enemies.getEnemies()) do
            local dx = missile.x - enemy.x
            local dy = missile.y - enemy.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < enemy.size then
                table.remove(playerData.missiles, i)
                enemies.removeEnemy(j)
                scoreThisFrame = scoreThisFrame + 50
                break
            end
        end
    end
end

return collision