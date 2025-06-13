-- ================================================================
-- player.lua
-- Player ship management
local player = {}
local config = require("lib/config")
local sound = require("lib/sound")

local playerData = {
    x = 100,
    y = config.SCREEN_HEIGHT / 2,
    size = config.PLAYER_SIZE,
    vx = 0,
    vy = 0,
    missiles = {},
    invulnerabilityTimer = 0
}

function player.load()
    player.reset()
end

function player.reset()
    playerData.x = 100
    playerData.y = config.SCREEN_HEIGHT / 2
    playerData.vx = 0
    playerData.vy = 0
    playerData.missiles = {}
    playerData.invulnerabilityTimer = 0
end

function player.update(dt)
    -- Handle input
    playerData.vx = 0
    playerData.vy = 0
    
    if love.keyboard.isDown("left", "a") then
        playerData.vx = -config.PLAYER_SPEED
    end
    if love.keyboard.isDown("right", "d") then
        playerData.vx = config.PLAYER_SPEED
    end
    if love.keyboard.isDown("up", "w") then
        playerData.vy = -config.PLAYER_SPEED
    end
    if love.keyboard.isDown("down", "s") then
        playerData.vy = config.PLAYER_SPEED
    end
    
    -- Update position
    playerData.x = playerData.x + playerData.vx * dt
    playerData.y = playerData.y + playerData.vy * dt
    
    -- Keep on screen
    playerData.x = math.max(playerData.size, math.min(config.SCREEN_WIDTH - playerData.size, playerData.x))
    playerData.y = math.max(playerData.size, math.min(config.SCREEN_HEIGHT - playerData.size, playerData.y))
    
    -- Update invulnerability
    if playerData.invulnerabilityTimer > 0 then
        playerData.invulnerabilityTimer = playerData.invulnerabilityTimer - dt
    end
    
    -- Update missiles
    for i = #playerData.missiles, 1, -1 do
        local missile = playerData.missiles[i]
        missile.x = missile.x + config.MISSILE_SPEED * dt
        if missile.x > config.SCREEN_WIDTH then
            table.remove(playerData.missiles, i)
        end
    end
end

function player.fireMissile()
    if #playerData.missiles < config.MAX_MISSILES then
        table.insert(playerData.missiles, {
            x = playerData.x + playerData.size,
            y = playerData.y,
            width = config.MISSILE_WIDTH,
            height = config.MISSILE_HEIGHT
        })
        sound.play("playerMissile")
    end
end

function player.draw()
    -- Draw missiles
    love.graphics.setColor(1, 1, 0.2)
    for _, missile in ipairs(playerData.missiles) do
        love.graphics.rectangle("fill", missile.x, missile.y - missile.height/2, 
                              missile.width, missile.height)
    end
    
    -- Draw player (with flashing during invulnerability)
    if playerData.invulnerabilityTimer <= 0 or math.floor(playerData.invulnerabilityTimer * 10) % 2 == 0 then
        love.graphics.setColor(0.8, 0.9, 1)
        love.graphics.polygon("fill",
            playerData.x + playerData.size, playerData.y,
            playerData.x - playerData.size, playerData.y - playerData.size/2,
            playerData.x - playerData.size/2, playerData.y,
            playerData.x - playerData.size, playerData.y + playerData.size/2
        )
    end
end

function player.getData()
    return playerData
end

function player.takeDamage()
    playerData.invulnerabilityTimer = config.INVULNERABILITY_TIME
    sound.play("playerHit")
end

function player.isInvulnerable()
    return playerData.invulnerabilityTimer > 0
end

return player