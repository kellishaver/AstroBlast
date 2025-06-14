-- ================================================================
-- ui.lua
-- User interface rendering
local ui = {}
local config = require("lib/config")

function ui.load()
end

function ui.drawHUD(score, lives)
    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score, font, 10, 10)
    -- love.graphics.print(score, 10, 10, 0, 2, 2)
    
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

function ui.drawGameOver(score, highScore, font)
    local font     = love.graphics.newFont("assets/upheavtt.ttf", 30)
    love.graphics.setColor(1, 0, 0)
    if font then love.graphics.setFont(font) end
    
    local gameOverText = "GAME OVER\nScore: " .. score
    
    if highScore > 0 then
        gameOverText = gameOverText .. "\nHigh Score: " .. highScore
    end
    
    gameOverText = gameOverText .. "\nPress R to restart"
    
    love.graphics.printf(gameOverText, 
                       0, config.SCREEN_HEIGHT/2 - 40, config.SCREEN_WIDTH, "center")
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