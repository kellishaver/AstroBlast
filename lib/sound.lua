-- ================================================================
-- sound.lua
-- Audio management
local sound = {}

local sounds = {}

function sound.load()
    sounds.menuLoop       = love.audio.newSource("assets/menu-loop.mp3", "stream")
    sounds.gameLoop       = love.audio.newSource("assets/game-loop.mp3", "stream")
    sounds.stationLoop    = love.audio.newSource("assets/station-loop.mp3", "stream")  -- ADD THIS
    sounds.playerMissile  = love.audio.newSource("assets/player-missile.mp3", "static")
    sounds.enemyMissile   = love.audio.newSource("assets/enemy-missile.mp3", "static")
    sounds.asteroidHit    = love.audio.newSource("assets/asteroid-hit.mp3", "static")
    sounds.enemyDestroyed = love.audio.newSource("assets/enemy-destroyed.mp3", "static")
    sounds.playerHit      = love.audio.newSource("assets/player-hit.mp3", "static")
    sounds.playerLife     = love.audio.newSource("assets/player-life.mp3", "static")
    sounds.gameOver       = love.audio.newSource("assets/game-over.mp3", "static")
    sounds.victory        = love.audio.newSource("assets/victory.mp3", "static")    -- AND THIS
    
    sounds.menuLoop:setLooping(true)
    sounds.gameLoop:setLooping(true)
    sounds.stationLoop:setLooping(true)  -- AND THIS
end

function sound.play(soundName)
    if sounds[soundName] then
        love.audio.play(sounds[soundName])
    end
end

function sound.playMenuMusic()
    love.audio.play(sounds.menuLoop)
end

function sound.playGameMusic()
    love.audio.play(sounds.gameLoop)
end

function sound.playStationMusic()
    love.audio.play(sounds.stationLoop)
end

function sound.stopMenuMusic()
    love.audio.stop(sounds.menuLoop)
end

function sound.stopGameMusic()
    love.audio.stop(sounds.gameLoop)
end

function sound.stopStationMusic()
    love.audio.stop(sounds.stationLoop)
end

return sound