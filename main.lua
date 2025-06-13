-- main.lua
-- Main game loop and coordination
local player = require("lib/player")
local enemies = require("lib/enemies")
local asteroids = require("lib/asteroids")
local powerups = require("lib/powerups")
local effects = require("lib/effects")
local sound = require("lib/sound")
local collision = require("lib/collision")
local ui = require("lib/ui")
local config = require("lib/config")

local gameState = "start"
local score = 0
local highScore = 0
local lives = 3
local nextPowerupScore = 300
local powerupIncrement = 300

function love.load()
    love.window.setTitle("Space Shooter")
    love.window.setMode(config.SCREEN_WIDTH, config.SCREEN_HEIGHT)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Initialize all modules
    player.load()
    enemies.load()
    asteroids.load()
    powerups.load()
    effects.load()
    sound.load()
    ui.load()
    
    sound.playMenuMusic()
end

function love.update(dt)
    effects.updateStars(dt)
    
    if gameState == "playing" then
        player.update(dt)
        enemies.update(dt, score)
        asteroids.update(dt, score)
        powerups.update(dt)
        
        -- Check powerup spawn
        if score >= nextPowerupScore then
            powerups.spawn()
            sound.play("playerLife")
            powerupIncrement = powerupIncrement + 100
            nextPowerupScore = nextPowerupScore + powerupIncrement
        end
        
        -- Handle collisions
        local playerHit = collision.checkAll(player, enemies, asteroids, powerups)
        if playerHit then
            lives = lives - playerHit.damage
            if playerHit.type == "powerup" then
                lives = lives + 1
            end
            
            if lives <= 0 then
                gameState = "gameover"

                if score > highScore then
                    highScore = score
                end
                sound.stopGameMusic()
                sound.play("gameOver")
            end
        end
        
        score = score + collision.getScoreThisFrame()
    end
end

function love.draw()
    effects.drawStars()
    
    if gameState == "start" then
        love.graphics.setColor(1, 1, 1)
        local loadingScreen = love.graphics.newImage("assets/main-screen.png")
        love.graphics.draw(loadingScreen, 0, 0)
    elseif gameState == "playing" then
        asteroids.draw()
        enemies.draw()
        powerups.draw()
        player.draw()
        ui.drawHUD(score, lives)
    elseif gameState == "gameover" then
        ui.drawGameOver(score, highScore, fontt)  -- Pass both scores
    end
end

function love.keypressed(key)
    if key == "return" and gameState == "start" then
        gameState = "playing"
        sound.stopMenuMusic()
        sound.playGameMusic()
    elseif key == "space" and gameState == "playing" then
        player.fireMissile()
    elseif key == "r" and gameState == "gameover" then
        -- Restart logic
        gameState = "playing"
        score = 0
        lives = 3
        nextPowerupScore = 300
        powerupIncrement = 300
        player.reset()
        enemies.reset()
        asteroids.reset()
        powerups.reset()
        sound.stopMenuMusic()
        sound.playGameMusic()
    elseif key == "escape" then
        love.event.quit()
    end
end