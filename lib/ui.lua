-- ================================================================
-- ui.lua
-- User interface rendering
local ui = {}
local config = require("lib/config")
local player = require("lib/player")

function ui.load()
end

function ui.drawHUD(score, lives)
    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score, font, 10, 10)
    
    -- Draw life icons
    ui.drawLifeIcons(lives)
end

function ui.drawLifeIcons(lives)
    love.graphics.setColor(0.8, 0.9, 1, 0.6)
    local iconSize = 8
    local spacing = 25
    local startX = config.SCREEN_WIDTH - 30
    local y = 15
    
    for i = 1, lives do
        local x = startX - (i - 1) * spacing
        love.graphics.polygon("fill",
            x + iconSize, y,
            x - iconSize, y - iconSize/2,
            x - iconSize/2, y,
            x - iconSize, y + iconSize/2
        )
    end
end

function ui.drawGameOver(score, highScore, distanceTraveled, font)
    player.clearFlashOverlay()

    love.graphics.setColor(1, 0, 0)
    if font then love.graphics.setFont(font) end
    
    local gameOverText = "GAME OVER\nScore: " .. score
    
    if highScore > 0 then
        gameOverText = gameOverText .. "\nHigh Score: " .. highScore
    end
    
    -- Add progress to station
    local progressPercent = math.floor((distanceTraveled / config.STATION_TRIGGER_DISTANCE) * 100)
    progressPercent = math.min(100, progressPercent) -- Cap at 100%
    
    gameOverText = gameOverText .. "\n\nProgress to Station: " .. progressPercent .. "%"
    
    -- Show distance in a more readable format
    local distanceKm = math.floor(distanceTraveled / 100) -- Convert to "kilometers" for display
    local targetKm = math.floor(config.STATION_TRIGGER_DISTANCE / 100)
    gameOverText = gameOverText .. "\nDistance: " .. distanceKm .. "/" .. targetKm .. " km"
    
    -- Encouraging message based on progress
    if progressPercent >= 90 then
        love.graphics.setColor(1, 1, 0)
        gameOverText = gameOverText .. "\n\nSO CLOSE! The station is right there!"
    elseif progressPercent >= 75 then
        love.graphics.setColor(1, 0.8, 0)
        gameOverText = gameOverText .. "\n\nAlmost there! Keep pushing!"
    elseif progressPercent >= 50 then
        love.graphics.setColor(1, 0.6, 0)
        gameOverText = gameOverText .. "\n\nHalfway to the station!"
    elseif progressPercent >= 25 then
        love.graphics.setColor(1, 0.4, 0)
        gameOverText = gameOverText .. "\n\nMaking good progress!"
    else
        love.graphics.setColor(1, 0, 0)
        gameOverText = gameOverText .. "\n\nKeep fighting! The station awaits!"
    end
    
    gameOverText = gameOverText .. "\n\nPress R to restart"
    
    love.graphics.printf(gameOverText, 
                       0, config.SCREEN_HEIGHT/2 - 140, config.SCREEN_WIDTH, "center")
end

function ui.drawStationHUD(score, lives, defeated, needed)
    -- Draw normal HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score, font, 10, 10)
    
    -- Draw life icons
    ui.drawLifeIcons(lives)
    
    -- Draw station progress
    if defeated < needed then
        love.graphics.setColor(1, 1, 0.2)
        love.graphics.print("Hostiles Remaining: " .. (needed - defeated), 10, config.SCREEN_HEIGHT - 40)
    end
end

function ui.drawVictory(score, highScore)
    love.graphics.setColor(0.2, 1, 0.3)

    local victoryText = "MISSION COMPLETE!\nStation Secured!\nFinal Score: " .. score
    
    if score > highScore then
        victoryText = victoryText .. "\n\nNEW HIGH SCORE!"
    elseif highScore > 0 then
        victoryText = victoryText .. "\nHigh Score: " .. highScore
    end
    
    victoryText = victoryText .. "\n\nPress R to play again"
    
    love.graphics.printf(victoryText, 
                       0, config.SCREEN_HEIGHT/2 - 80, config.SCREEN_WIDTH, "center")
end

return ui