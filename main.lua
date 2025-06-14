-- main.lua
-- Main game loop and coordination
local player = require("lib/player")
local enemies = require("lib/enemies")
local station = require("lib/station")
local asteroids = require("lib/asteroids")
local powerups = require("lib/powerups")
local effects = require("lib/effects")
local sound = require("lib/sound")
local collision = require("lib/collision")
local ui = require("lib/ui")
local config = require("lib/config")
local helpers = require("lib/helpers")

-- Game state object
local gameState = {
    state = "start",
    score = 0,
    highScore = 0,
    lives = 3,
    nextPowerupScore = 300,
    powerupIncrement = 300,
    distanceTraveled = 0,
    dockingTimer = 0,
    dockingSpeed = 100,
    dockingStarted = false,
    
    -- Module references
    player = player,
    enemies = enemies,
    station = station,
    asteroids = asteroids,
    powerups = powerups
}

font = love.graphics.newFont("assets/upheavtt.ttf", 30)

function love.load()
    love.window.setTitle("Space Shooter")
    love.window.setMode(config.SCREEN_WIDTH, config.SCREEN_HEIGHT)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    love.graphics.setFont(font)

    -- Initialize all modules
    player.load()
    enemies.load()
    station.load()
    asteroids.load()
    powerups.load()
    effects.load()
    sound.load()
    ui.load()
    
    sound.playMenuMusic()
end

function love.update(dt)
    effects.updateStars(dt)
    
    if gameState.state == "playing" then
        helpers.updateGameplay(dt, gameState, true) -- Check distance for station trigger
        
    elseif gameState.state == "station_approach" then
        helpers.updateGameplay(dt, gameState, false) -- Don't check distance again
        
        local stationResult = station.update(dt)
        if stationResult == "station_arrived" then
            gameState.state = "station_battle"
            sound.stopGameMusic()
            sound.playStationMusic()
        end
        
    elseif gameState.state == "station_battle" then
        player.update(dt)
        enemies.updateStationBattle(dt)
        
        local stationResult = station.update(dt)
        if stationResult == "docking_ready" and not gameState.dockingStarted then
            gameState.state = "auto_docking"
            gameState.dockingStarted = true
            gameState.dockingTimer = 0
            station.startDocking()
        end
        
        helpers.handleCollisions(gameState, collision.checkstationBattle, false) -- No asteroids
        
    elseif gameState.state == "auto_docking" then
        gameState.dockingTimer = gameState.dockingTimer + dt
        
        local playerData = player.getData()
        local dockTarget = station.getDockingTarget()
        
        local dx = dockTarget.x - playerData.x
        local dy = dockTarget.y - playerData.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance > 5 then
            local moveX = (dx / distance) * gameState.dockingSpeed * dt
            local moveY = (dy / distance) * gameState.dockingSpeed * dt
            
            playerData.x = playerData.x + moveX
            playerData.y = playerData.y + moveY
        else
            gameState.state = "victory"
            if gameState.score > gameState.highScore then
                gameState.highScore = gameState.score
            end
            sound.stopStationMusic()
            sound.play("victory")
        end
        
        station.update(dt)
    end
end

function love.draw()
    -- Background logic
    if gameState.state ~= "station_battle" and gameState.state ~= "auto_docking" then
        effects.drawStars()
    else
        love.graphics.setColor(0.02, 0.02, 0.08)
        love.graphics.rectangle("fill", 0, 0, config.SCREEN_WIDTH, config.SCREEN_HEIGHT)
    end
    
    if gameState.state == "start" then
        love.graphics.setColor(1, 1, 1)
        local loadingScreen = love.graphics.newImage("assets/main-screen.png")
        love.graphics.draw(loadingScreen, 0, 0)
        
    elseif gameState.state == "playing" or gameState.state == "station_approach" then
        asteroids.draw()
        enemies.draw()
        powerups.draw()
        player.draw()
        ui.drawHUD(gameState.score, gameState.lives)
        
    elseif gameState.state == "station_battle" then
        station.draw()
        enemies.draw()
        powerups.draw()
        player.draw()
        ui.drawStationHUD(gameState.score, gameState.lives, station.getProgress())
        
    elseif gameState.state == "auto_docking" then
        station.draw()
        player.draw()
        ui.drawStationHUD(gameState.score, gameState.lives, station.getProgress())
        
        love.graphics.setColor(0.2, 1, 0.3)
        love.graphics.printf("DOCKING IN PROGRESS...", 
                           0, config.SCREEN_HEIGHT/2 + 100, config.SCREEN_WIDTH, "center")
        
    elseif gameState.state == "victory" then
        station.draw()
        player.draw()
        ui.drawVictory(gameState.score, gameState.highScore)
        
    elseif gameState.state == "gameover" then
        ui.drawGameOver(gameState.score, gameState.highScore, font)
    end
end

function love.keypressed(key)
    if key == "return" and gameState.state == "start" then
        gameState.state = "playing"
        sound.stopMenuMusic()
        sound.stopStationMusic()
        sound.playGameMusic()
        
    elseif key == "space" and (gameState.state == "playing" or gameState.state == "station_approach" or gameState.state == "station_battle") then
        player.fireMissile()
        
    elseif key == "r" and (gameState.state == "gameover" or gameState.state == "victory") then
        helpers.resetGame(gameState)
        
    elseif key == "escape" then
        love.event.quit()
    end
end