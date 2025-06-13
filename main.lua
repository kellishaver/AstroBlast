-- main.lua
-- Main game loop and coordination
local player = require("lib/player")
local enemies = require("lib/enemies")
local boss = require("lib/boss")
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
local distanceTraveled = 0

function love.load()
    love.window.setTitle("Space Shooter")
    love.window.setMode(config.SCREEN_WIDTH, config.SCREEN_HEIGHT)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Initialize all modules
    player.load()
    enemies.load()
    boss.load()
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
        
        -- Track distance traveled
        distanceTraveled = distanceTraveled + config.SCROLL_SPEED * dt
        
        -- Check for boss trigger
        if distanceTraveled >= config.BOSS_TRIGGER_DISTANCE then
            gameState = "boss_approach"
            boss.activate()
            -- Keep normal music playing during approach
        end
        
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
        
    elseif gameState == "boss_approach" then
        -- Station is approaching - keep normal gameplay but with station visible
        player.update(dt)
        enemies.update(dt, score)
        asteroids.update(dt, score) -- Keep asteroids during approach
        powerups.update(dt)
        
        local bossResult = boss.update(dt)
        if bossResult == "station_arrived" then
            gameState = "boss_battle"
            sound.stopGameMusic() -- Now stop music and could add boss music
        end
        
        -- Handle collisions normally during approach
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
        
    elseif gameState == "boss_battle" then
        player.update(dt)
        enemies.updateBossBattle(dt)
        
        local bossResult = boss.update(dt)
        if bossResult == "auto_dock" then
            -- Auto-dock when all enemies are defeated
            gameState = "victory"
            sound.play("playerLife") -- Or add a victory sound
        end
        
        -- Handle collisions (no asteroids in boss battle)
        local playerHit = collision.checkBossBattle(player, enemies, powerups)
        if playerHit then
            lives = lives - playerHit.damage
            if lives <= 0 then
                gameState = "gameover"
                if score > highScore then
                    highScore = score
                end
                sound.play("gameOver")
            end
        end
        
        score = score + collision.getScoreThisFrame()
    end
end

function love.draw()
    -- Only draw stars in normal play, not boss battle
    if gameState ~= "boss_battle" then
        effects.drawStars()
    else
        -- Different background for boss battle - darker space
        love.graphics.setColor(0.02, 0.02, 0.08)
        love.graphics.rectangle("fill", 0, 0, config.SCREEN_WIDTH, config.SCREEN_HEIGHT)
    end
    
    if gameState == "start" then
        love.graphics.setColor(1, 1, 1)
        local loadingScreen = love.graphics.newImage("assets/main-screen.png")
        love.graphics.draw(loadingScreen, 0, 0)
        
    elseif gameState == "playing" or gameState == "boss_approach" then
        asteroids.draw()
        enemies.draw()
        powerups.draw()
        player.draw()
        ui.drawHUD(score, lives)
        
    elseif gameState == "boss_battle" then
        boss.draw()
        enemies.draw()
        powerups.draw()
        player.draw()
        ui.drawBossHUD(score, lives, boss.getProgress())
        
    elseif gameState == "victory" then
        boss.draw()
        player.draw()
        ui.drawVictory(score, highScore)
        
    elseif gameState == "gameover" then
        ui.drawGameOver(score, highScore, fontt)
    end
end

function love.keypressed(key)
    if key == "return" and gameState == "start" then
        gameState = "playing"
        sound.stopMenuMusic()
        sound.playGameMusic()
    elseif key == "space" and (gameState == "playing" or gameState == "boss_approach" or gameState == "boss_battle") then
        player.fireMissile()
    elseif key == "r" and (gameState == "gameover" or gameState == "victory") then
        -- Restart logic
        gameState = "playing"
        score = 0
        lives = 3
        distanceTraveled = 0  -- Reset distance
        nextPowerupScore = 300
        powerupIncrement = 300
        player.reset()
        enemies.reset()
        asteroids.reset()
        powerups.reset()
        boss.reset()  -- Reset boss
        sound.stopMenuMusic()
        sound.playGameMusic()
    elseif key == "escape" then
        love.event.quit()
    end
end