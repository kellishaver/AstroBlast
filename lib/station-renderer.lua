-- ================================================================
-- lib/station-renderer.lua
-- Station drawing and rendering components
local renderer = {}

function renderer.drawMainHull(stationData)
    -- Main station hull (lower section)
    love.graphics.setColor(0.6, 0.65, 0.7)
    love.graphics.rectangle("fill", stationData.x, stationData.y - 20, 
                          stationData.width, 80)
    
    -- Station core (central cylinder in main hull)
    love.graphics.setColor(0.7, 0.75, 0.8)
    love.graphics.rectangle("fill", stationData.x + 30, stationData.y - 15, 100, 60)
end

function renderer.drawCommandModule(stationData, centerX, centerY)
    -- Connecting neck
    love.graphics.setColor(0.55, 0.6, 0.65)
    local neckWidth = 30
    local neckHeight = 25
    love.graphics.rectangle("fill", centerX - neckWidth/2, stationData.y - 45, 
                          neckWidth, neckHeight)
    
    -- Oval command module (top section)
    love.graphics.setColor(0.7, 0.75, 0.8)
    local ovalWidth = 70
    local ovalHeight = 40
    local ovalCenterY = stationData.y - 60
    
    -- Draw oval using multiple circles (simple approximation)
    for i = 0, ovalWidth, 4 do
        local x = centerX - ovalWidth/2 + i
        local distFromCenter = math.abs(i - ovalWidth/2) / (ovalWidth/2)
        local height = ovalHeight * math.sqrt(1 - distFromCenter * distFromCenter)
        love.graphics.rectangle("fill", x, ovalCenterY - height/2, 4, height)
    end
    
    -- Command module details
    love.graphics.setColor(0.5, 0.55, 0.6)
    love.graphics.rectangle("fill", centerX - ovalWidth/2, ovalCenterY - 2, ovalWidth, 1)
    love.graphics.rectangle("fill", centerX - ovalWidth/2, ovalCenterY + 2, ovalWidth, 1)
    
    -- Bridge windows on command module
    love.graphics.setColor(0.8, 0.9, 1, 0.8)
    love.graphics.rectangle("fill", centerX - 20, ovalCenterY - 8, 40, 6)
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", centerX - 18, ovalCenterY - 6, 12, 2)
    love.graphics.rectangle("fill", centerX - 2, ovalCenterY - 6, 12, 2)
    love.graphics.rectangle("fill", centerX + 14, ovalCenterY - 6, 12, 2)
end

function renderer.drawRotatingRing(stationData, centerX, centerY)
    local ringRadius = 45
    local ringThickness = 8
    love.graphics.setColor(0.5, 0.55, 0.6)
    
    -- Draw ring segments to simulate rotation
    local numSegments = 16
    for i = 0, numSegments - 1 do
        local angle = (i / numSegments) * 2 * math.pi + stationData.rotationOffset
        local x1 = centerX + math.cos(angle) * (ringRadius - ringThickness/2)
        local y1 = centerY + math.sin(angle) * (ringRadius - ringThickness/2)
        local x2 = centerX + math.cos(angle) * (ringRadius + ringThickness/2)
        local y2 = centerY + math.sin(angle) * (ringRadius + ringThickness/2)
        
        -- Only draw every other segment for broken ring effect
        if i % 2 == 0 then
            love.graphics.line(x1, y1, x2, y2)
        end
    end
end

function renderer.drawDockingBays(stationData)
    local dockBays = {
        {x = stationData.x - 15, y = stationData.y - 20, w = 20, h = 12},
        {x = stationData.x - 15, y = stationData.y, w = 20, h = 12},
        {x = stationData.x - 15, y = stationData.y + 20, w = 20, h = 12}
    }
    
    for _, bay in ipairs(dockBays) do
        if stationData.dockingBayLit then
            love.graphics.setColor(0.2, 1, 0.3) -- Green when ready
        else
            love.graphics.setColor(0.4, 0.4, 0.5) -- Dark when not ready
        end
        love.graphics.rectangle("fill", bay.x, bay.y, bay.w, bay.h)
        
        -- Bay entrance
        love.graphics.setColor(0.1, 0.1, 0.15)
        love.graphics.rectangle("fill", bay.x, bay.y + 2, bay.w, bay.h - 4)
    end
end

function renderer.drawAntennas(stationData, centerX, centerY)
    love.graphics.setColor(0.6, 0.6, 0.7)
    local ovalCenterY = stationData.y - 60
    
    -- Main antenna on command module
    love.graphics.rectangle("fill", centerX - 2, ovalCenterY - 25, 4, 15)
    love.graphics.circle("fill", centerX, ovalCenterY - 30, 3)
    
    -- Side antennas on main hull
    love.graphics.rectangle("fill", stationData.x + 20, stationData.y - 40, 2, 15)
    love.graphics.rectangle("fill", stationData.x + stationData.width - 20, stationData.y - 40, 2, 15)
end

function renderer.drawSolarPanels(stationData)
    love.graphics.setColor(0.2, 0.2, 0.4)
    love.graphics.rectangle("fill", stationData.x - 10, stationData.y - 30, 8, 40)
    love.graphics.rectangle("fill", stationData.x - 10, stationData.y + 10, 8, 40)
    love.graphics.rectangle("fill", stationData.x + stationData.width + 2, stationData.y - 30, 8, 40)
    love.graphics.rectangle("fill", stationData.x + stationData.width + 2, stationData.y + 10, 8, 40)
    
    -- Panel grid lines
    love.graphics.setColor(0.3, 0.3, 0.5)
    for i = 1, 6 do
        local y = stationData.y - 30 + (i * 6)
        love.graphics.line(stationData.x - 10, y, stationData.x - 2, y)
        love.graphics.line(stationData.x + stationData.width + 2, y, stationData.x + stationData.width + 10, y)
    end
end

function renderer.drawWindows(stationData)
    love.graphics.setColor(0.8, 0.9, 1, 0.6)
    love.graphics.circle("fill", stationData.x + 40, stationData.y - 5, 4)
    love.graphics.circle("fill", stationData.x + 60, stationData.y + 15, 3)
    love.graphics.circle("fill", stationData.x + 90, stationData.y + 5, 3)
    love.graphics.rectangle("fill", stationData.x + 110, stationData.y - 3, 15, 6)
end

function renderer.drawLights(stationData, centerX, centerY)
    local time = love.timer.getTime()
    local ovalCenterY = stationData.y - 60
    
    -- Blinking warning lights (red)
    if math.floor(time * 2) % 2 == 0 then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.circle("fill", stationData.x + 10, stationData.y - 35, 2)
        love.graphics.circle("fill", stationData.x + stationData.width - 10, stationData.y - 35, 2)
        love.graphics.circle("fill", stationData.x + 10, stationData.y + 35, 2)
        love.graphics.circle("fill", stationData.x + stationData.width - 10, stationData.y + 35, 2)
        
        -- Command module warning lights
        love.graphics.circle("fill", centerX - 25, ovalCenterY, 1.5)
        love.graphics.circle("fill", centerX + 25, ovalCenterY, 1.5)
    end
    
    -- Blinking navigation lights (blue)
    if math.floor(time * 3) % 2 == 0 then
        love.graphics.setColor(0.2, 0.4, 1)
        love.graphics.circle("fill", centerX - 20, stationData.y - 25, 1.5)
        love.graphics.circle("fill", centerX + 20, stationData.y - 25, 1.5)
        love.graphics.circle("fill", centerX, stationData.y + 30, 1.5)
        
        -- Command module nav lights
        love.graphics.circle("fill", centerX, ovalCenterY - 15, 1.5)
    end
end

function renderer.drawEngineGlow(stationData, centerY, stationState)
    if stationState == "approaching" then
        love.graphics.setColor(0.2, 0.6, 1, 0.3)
        love.graphics.circle("fill", stationData.x + stationData.width + 5, centerY - 10, 3)
        love.graphics.circle("fill", stationData.x + stationData.width + 5, centerY + 10, 3)
    end
end

function renderer.drawStatusIndicators(stationData)
    love.graphics.setColor(0.9, 0.9, 0.9)
    if stationData.dockingBayLit then
        love.graphics.setColor(0.2, 1, 0.3)
        love.graphics.circle("fill", stationData.x + 15, stationData.y - 25, 2)
        love.graphics.circle("fill", stationData.x + 15, stationData.y + 25, 2)
    else
        love.graphics.setColor(1, 0.6, 0.2)
        love.graphics.circle("fill", stationData.x + 15, stationData.y - 25, 2)
        love.graphics.circle("fill", stationData.x + 15, stationData.y + 25, 2)
    end
end

-- Main render function that coordinates all components
function renderer.renderStation(stationData, stationState)
    local centerX = stationData.x + stationData.width/2
    local centerY = stationData.y
    
    renderer.drawMainHull(stationData)
    renderer.drawCommandModule(stationData, centerX, centerY)
    renderer.drawRotatingRing(stationData, centerX, centerY)
    renderer.drawDockingBays(stationData)
    renderer.drawAntennas(stationData, centerX, centerY)
    renderer.drawSolarPanels(stationData)
    renderer.drawWindows(stationData)
    renderer.drawLights(stationData, centerX, centerY)
    renderer.drawEngineGlow(stationData, centerY, stationState)
    renderer.drawStatusIndicators(stationData)
end

return renderer