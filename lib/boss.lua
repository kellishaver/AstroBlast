-- ================================================================
-- lib/boss.lua
-- Boss battle and space station management
local boss = {}
local config = require("lib/config")
local sound = require("lib/sound")

local spaceStation = {}
local enemiesDefeated = 0
local totalEnemiesNeeded = 0
local isActive = false
local stationState = "approaching" -- approaching, arrived, docking_ready

function boss.load()
    boss.reset()
end

function boss.reset()
    spaceStation = {
        x = config.SCREEN_WIDTH + 300, -- Start off-screen to the right
        y = config.SCREEN_HEIGHT / 2,
        targetX = config.SCREEN_WIDTH - 200, -- Final position
        width = 160,
        height = 120,
        dockingBayLit = false,
        rotationOffset = 0 -- For rotating elements
    }
    enemiesDefeated = 0
    totalEnemiesNeeded = config.BOSS_ENEMIES_TO_DEFEAT
    isActive = false
    stationState = "approaching"
end

function boss.activate()
    isActive = true
    enemiesDefeated = 0
    totalEnemiesNeeded = config.BOSS_ENEMIES_TO_DEFEAT
    spaceStation.dockingBayLit = false
    stationState = "approaching"
    -- Station starts off-screen and will scroll in
    spaceStation.x = config.SCREEN_WIDTH + 300
end

function boss.update(dt)
    if not isActive then return nil end
    
    -- Update station rotation animation
    spaceStation.rotationOffset = spaceStation.rotationOffset + dt * 0.5
    
    -- Handle station approach
    if stationState == "approaching" then
        -- Move station in at scroll speed
        spaceStation.x = spaceStation.x - config.SCROLL_SPEED * dt
        
        -- Check if station has reached its target position
        if spaceStation.x <= spaceStation.targetX then
            spaceStation.x = spaceStation.targetX
            stationState = "arrived"
            return "station_arrived" -- Signal to stop scrolling
        end
        return "approaching"
    end
    
    -- Check victory condition only after station has arrived
    if stationState == "arrived" and enemiesDefeated >= totalEnemiesNeeded then
        spaceStation.dockingBayLit = true
        stationState = "docking_ready"
        return "auto_dock" -- Auto-dock when enemies are cleared
    end
    
    return nil
end

function boss.enemyDefeated()
    if isActive then
        enemiesDefeated = enemiesDefeated + 1
    end
end

function boss.draw()
    if not isActive then return end
    
    local station = spaceStation
    local centerX = station.x + station.width/2
    local centerY = station.y
    
    -- Main station hull (lower section)
    love.graphics.setColor(0.6, 0.65, 0.7)
    love.graphics.rectangle("fill", station.x, station.y - 20, 
                          station.width, 80)
    
    -- Connecting neck
    love.graphics.setColor(0.55, 0.6, 0.65)
    local neckWidth = 30
    local neckHeight = 25
    love.graphics.rectangle("fill", centerX - neckWidth/2, station.y - 45, 
                          neckWidth, neckHeight)
    
    -- Oval command module (top section)
    love.graphics.setColor(0.7, 0.75, 0.8)
    local ovalWidth = 70
    local ovalHeight = 40
    local ovalCenterY = station.y - 60
    
    -- Draw oval using multiple circles (simple approximation)
    for i = 0, ovalWidth, 4 do
        local x = centerX - ovalWidth/2 + i
        local distFromCenter = math.abs(i - ovalWidth/2) / (ovalWidth/2)
        local height = ovalHeight * math.sqrt(1 - distFromCenter * distFromCenter)
        love.graphics.rectangle("fill", x, ovalCenterY - height/2, 4, height)
    end
    
    -- Station core (central cylinder in main hull)
    love.graphics.setColor(0.7, 0.75, 0.8)
    love.graphics.rectangle("fill", station.x + 30, station.y - 15, 100, 60)
    
    -- Rotating outer ring
    local ringRadius = 45
    local ringThickness = 8
    love.graphics.setColor(0.5, 0.55, 0.6)
    
    -- Draw ring segments to simulate rotation
    local numSegments = 16
    for i = 0, numSegments - 1 do
        local angle = (i / numSegments) * 2 * math.pi + station.rotationOffset
        local x1 = centerX + math.cos(angle) * (ringRadius - ringThickness/2)
        local y1 = centerY + math.sin(angle) * (ringRadius - ringThickness/2)
        local x2 = centerX + math.cos(angle) * (ringRadius + ringThickness/2)
        local y2 = centerY + math.sin(angle) * (ringRadius + ringThickness/2)
        
        -- Only draw every other segment for broken ring effect
        if i % 2 == 0 then
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- Command module details
    love.graphics.setColor(0.5, 0.55, 0.6)
    -- Command module bands
    love.graphics.rectangle("fill", centerX - ovalWidth/2, ovalCenterY - 2, ovalWidth, 1)
    love.graphics.rectangle("fill", centerX - ovalWidth/2, ovalCenterY + 2, ovalWidth, 1)
    
    -- Bridge windows on command module
    love.graphics.setColor(0.8, 0.9, 1, 0.8)
    love.graphics.rectangle("fill", centerX - 20, ovalCenterY - 8, 40, 6)
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", centerX - 18, ovalCenterY - 6, 12, 2)
    love.graphics.rectangle("fill", centerX - 2, ovalCenterY - 6, 12, 2)
    love.graphics.rectangle("fill", centerX + 14, ovalCenterY - 6, 12, 2)
    
    -- Docking bays (multiple)
    local dockBays = {
        {x = station.x - 15, y = station.y - 20, w = 20, h = 12},
        {x = station.x - 15, y = station.y, w = 20, h = 12},
        {x = station.x - 15, y = station.y + 20, w = 20, h = 12}
    }
    
    for _, bay in ipairs(dockBays) do
        if station.dockingBayLit then
            love.graphics.setColor(0.2, 1, 0.3) -- Green when ready
        else
            love.graphics.setColor(0.4, 0.4, 0.5) -- Dark when not ready
        end
        love.graphics.rectangle("fill", bay.x, bay.y, bay.w, bay.h)
        
        -- Bay entrance
        love.graphics.setColor(0.1, 0.1, 0.15)
        love.graphics.rectangle("fill", bay.x, bay.y + 2, bay.w, bay.h - 4)
    end
    
    -- Communication arrays and antennas
    love.graphics.setColor(0.6, 0.6, 0.7)
    -- Main antenna on command module
    love.graphics.rectangle("fill", centerX - 2, ovalCenterY - 25, 4, 15)
    love.graphics.circle("fill", centerX, ovalCenterY - 30, 3)
    
    -- Side antennas on main hull
    love.graphics.rectangle("fill", station.x + 20, station.y - 40, 2, 15)
    love.graphics.rectangle("fill", station.x + station.width - 20, station.y - 40, 2, 15)
    
    -- Solar panels
    love.graphics.setColor(0.2, 0.2, 0.4)
    love.graphics.rectangle("fill", station.x - 10, station.y - 30, 8, 40)
    love.graphics.rectangle("fill", station.x - 10, station.y + 10, 8, 40)
    love.graphics.rectangle("fill", station.x + station.width + 2, station.y - 30, 8, 40)
    love.graphics.rectangle("fill", station.x + station.width + 2, station.y + 10, 8, 40)
    
    -- Panel grid lines
    love.graphics.setColor(0.3, 0.3, 0.5)
    for i = 1, 6 do
        local y = station.y - 30 + (i * 6)
        love.graphics.line(station.x - 10, y, station.x - 2, y)
        love.graphics.line(station.x + station.width + 2, y, station.x + station.width + 10, y)
    end
    
    -- Windows/viewports on main hull
    love.graphics.setColor(0.8, 0.9, 1, 0.6)
    love.graphics.circle("fill", station.x + 40, station.y - 5, 4)
    love.graphics.circle("fill", station.x + 60, station.y + 15, 3)
    love.graphics.circle("fill", station.x + 90, station.y + 5, 3)
    love.graphics.rectangle("fill", station.x + 110, station.y - 3, 15, 6)
    
    -- Blinking lights (navigation and warning)
    local time = love.timer.getTime()
    if math.floor(time * 2) % 2 == 0 then
        -- Red warning lights
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.circle("fill", station.x + 10, station.y - 35, 2)
        love.graphics.circle("fill", station.x + station.width - 10, station.y - 35, 2)
        love.graphics.circle("fill", station.x + 10, station.y + 35, 2)
        love.graphics.circle("fill", station.x + station.width - 10, station.y + 35, 2)
        
        -- Command module warning lights
        love.graphics.circle("fill", centerX - 25, ovalCenterY, 1.5)
        love.graphics.circle("fill", centerX + 25, ovalCenterY, 1.5)
    end
    
    if math.floor(time * 3) % 2 == 0 then
        -- Blue navigation lights
        love.graphics.setColor(0.2, 0.4, 1)
        love.graphics.circle("fill", centerX - 20, station.y - 25, 1.5)
        love.graphics.circle("fill", centerX + 20, station.y - 25, 1.5)
        love.graphics.circle("fill", centerX, station.y + 30, 1.5)
        
        -- Command module nav lights
        love.graphics.circle("fill", centerX, ovalCenterY - 15, 1.5)
    end
    
    -- Engine/thruster glow (subtle)
    if stationState == "approaching" then
        love.graphics.setColor(0.2, 0.6, 1, 0.3)
        love.graphics.circle("fill", station.x + station.width + 5, centerY - 10, 3)
        love.graphics.circle("fill", station.x + station.width + 5, centerY + 10, 3)
    end
    
    -- Status indicators
    love.graphics.setColor(0.9, 0.9, 0.9)
    if station.dockingBayLit then
        love.graphics.setColor(0.2, 1, 0.3)
        love.graphics.circle("fill", station.x + 15, station.y - 25, 2)
        love.graphics.circle("fill", station.x + 15, station.y + 25, 2)
    else
        love.graphics.setColor(1, 0.6, 0.2)
        love.graphics.circle("fill", station.x + 15, station.y - 25, 2)
        love.graphics.circle("fill", station.x + 15, station.y + 25, 2)
    end
end

function boss.checkPlayerDocking(playerData)
    if not isActive or stationState ~= "docking_ready" then
        return false
    end
    
    -- Make docking bays slightly larger and more forgiving
    local dockBays = {
        {x = spaceStation.x - 20, y = spaceStation.y - 25, w = 30, h = 18},
        {x = spaceStation.x - 20, y = spaceStation.y - 5, w = 30, h = 18},
        {x = spaceStation.x - 20, y = spaceStation.y + 15, w = 30, h = 18}
    }
    
    for _, bay in ipairs(dockBays) do
        if playerData.x + playerData.size > bay.x and 
           playerData.x - playerData.size < bay.x + bay.w and
           playerData.y + playerData.size > bay.y and 
           playerData.y - playerData.size < bay.y + bay.h then
            return true
        end
    end
    
    return false
end

function boss.getProgress()
    if not isActive then return 0, 0 end
    return enemiesDefeated, totalEnemiesNeeded
end

function boss.isActive()
    return isActive
end

function boss.getState()
    return stationState
end

return boss