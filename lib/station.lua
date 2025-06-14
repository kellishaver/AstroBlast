-- ================================================================
-- lib/station.lua
-- station battle and space station management
local station = {}
local config = require("lib/config")
local sound = require("lib/sound")
local renderer = require("lib/station-renderer")

local spaceStation = {}
local enemiesDefeated = 0
local totalEnemiesNeeded = 0
local isActive = false
local stationState = "approaching"

function station.load()
    station.reset()
end

function station.reset()
    spaceStation = {
        x = config.SCREEN_WIDTH + 300,
        y = config.SCREEN_HEIGHT / 2,
        targetX = config.SCREEN_WIDTH - 200,
        width = 160,
        height = 120,
        dockingBayLit = false,
        rotationOffset = 0
    }
    enemiesDefeated = 0
    totalEnemiesNeeded = config.STATION_ENEMIES_TO_DEFEAT
    isActive = false
    stationState = "approaching"
end

function station.activate()
    isActive = true
    enemiesDefeated = 0
    totalEnemiesNeeded = config.STATION_ENEMIES_TO_DEFEAT
    spaceStation.dockingBayLit = false
    stationState = "approaching"
    spaceStation.x = config.SCREEN_WIDTH + 300
end

function station.update(dt)
    if not isActive then return nil end
    
    spaceStation.rotationOffset = spaceStation.rotationOffset + dt * 0.5
    
    if stationState == "approaching" then
        spaceStation.x = spaceStation.x - config.SCROLL_SPEED * dt
        
        if spaceStation.x <= spaceStation.targetX then
            spaceStation.x = spaceStation.targetX
            stationState = "arrived"
            return "station_arrived"
        end
        return "approaching"
    end
    
    if stationState == "arrived" and enemiesDefeated >= totalEnemiesNeeded then
        spaceStation.dockingBayLit = true
        stationState = "docking_ready"
        return "docking_ready"
    end
    
    if stationState == "docking" then
        return "docking"
    end
    
    return nil
end

function station.startDocking()
    if stationState == "docking_ready" then
        stationState = "docking"
        return true
    end
    return false
end

function station.isDocking()
    return stationState == "docking"
end

function station.getDockingTarget()
    return {
        x = spaceStation.x - 10,
        y = spaceStation.y
    }
end

function station.checkPlayerDocking(playerData)
    if not isActive or (stationState ~= "docking_ready" and stationState ~= "docking") then
        return false
    end
    
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

function station.enemyDefeated()
    if isActive then
        enemiesDefeated = enemiesDefeated + 1
    end
end

function station.draw()
    if not isActive then return end
    renderer.renderStation(spaceStation, stationState)
end

function station.getProgress()
    if not isActive then return 0, 0 end
    return enemiesDefeated, totalEnemiesNeeded
end

function station.isActive()
    return isActive
end

function station.getState()
    return stationState
end

return station