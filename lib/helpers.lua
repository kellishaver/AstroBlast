-- ================================================================
-- lib/helpers.lua
-- Game helper functions
local helpers = {}
local collision = require("lib/collision")
local sound = require("lib/sound")
local config = require("lib/config")

-- Pass game state table by reference so functions can modify it
function helpers.handleCollisions(gameState, collisionCheckFunc, includeAsteroids)
    local playerHit
    if includeAsteroids then
        playerHit = collisionCheckFunc(gameState.player, gameState.enemies, gameState.asteroids, gameState.powerups)
    else
        playerHit = collisionCheckFunc(gameState.player, gameState.enemies, gameState.powerups)
    end
    
    if playerHit then
        if playerHit.type == "powerup" then
            gameState.lives = gameState.lives + 1
            sound.play("playerLife")
        else
            gameState.lives = gameState.lives - playerHit.damage
            gameState.player.takeDamage()
        end
        
        if gameState.lives <= 0 then
            gameState.state = "gameover"
            if gameState.score > gameState.highScore then
                gameState.highScore = gameState.score
            end
            sound.stopGameMusic()
            sound.stopStationMusic()
            sound.play("gameOver")
        end
    end
    
    gameState.score = gameState.score + collision.getScoreThisFrame()
end

function helpers.checkPowerupSpawn(gameState)
    if gameState.score >= gameState.nextPowerupScore then
        gameState.powerups.spawn()
        gameState.powerupIncrement = gameState.powerupIncrement + 100
        gameState.nextPowerupScore = gameState.nextPowerupScore + gameState.powerupIncrement
    end
end

function helpers.updateGameplay(dt, gameState, checkDistance)
    gameState.player.update(dt)
    gameState.enemies.update(dt, gameState.score)
    gameState.asteroids.update(dt, gameState.score)
    gameState.powerups.update(dt)
    
    if checkDistance then
        gameState.distanceTraveled = gameState.distanceTraveled + config.SCROLL_SPEED * dt
        if gameState.distanceTraveled >= config.STATION_TRIGGER_DISTANCE then
            gameState.state = "station_approach"
            gameState.station.activate()
        end
    end
    
    helpers.checkPowerupSpawn(gameState)
    helpers.handleCollisions(gameState, collision.checkAll, true) -- Include asteroids
end

function helpers.resetGame(gameState)
    gameState.state = "playing"
    gameState.score = 0
    gameState.lives = 3
    gameState.distanceTraveled = 0
    gameState.nextPowerupScore = 300
    gameState.powerupIncrement = 300
    gameState.dockingTimer = 0
    gameState.dockingStarted = false
    
    gameState.player.reset()
    gameState.enemies.reset()
    gameState.asteroids.reset()
    gameState.powerups.reset()
    gameState.station.reset()
    
    sound.stopMenuMusic()
    sound.stopStationMusic()
    sound.playGameMusic()
end

return helpers