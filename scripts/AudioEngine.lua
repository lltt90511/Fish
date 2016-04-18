--Encapsulate SimpleAudioEngine to AudioEngine,Play music and sound effects. 
local M = {}
local sharedEngine = SimpleAudioEngine:sharedEngine()
M.music = true
M.effect = true
M.effectSuffix = ".wav"
M.playingMusic = nil
M.playingMusicLoop = true
M.pause = false
local print  = print
function M.switch(music,effect)
    if music == false then
        M.pause = true
        M.pauseMusic(true)
    else
        if M.pause  then
            sharedEngine:resumeBackgroundMusic()
        elseif M.music == false and  M.playingMusic then
            sharedEngine:playBackgroundMusic( M.playingMusic, M.playingMusicLoop)
        end
    end
    if effect == false then
        M.stopAllEffects()
    end
    M.effect = effect
    M.music = music
end
function M.playMusic(filename, isLoop)
	if UserSetting and UserSetting["musicOpen"] and tonumber(UserSetting["musicOpen"]) == 0 then
		return
	end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    M.playingMusic = filename
    M.playingMusicLoop = loopValue
    M.pause = false
    if M.music then
        sharedEngine:playBackgroundMusic(filename, loopValue)
    end
end
function M.switchMusic(flag)
     M.switch(flag,M.effect)
end
function M.switchEffect(flag)
     M.switch(M.music,flag)
end
function M.getSwitch()
    return M.music,M.effect
end
function M.setEffectSuffix(suf)
    M.effectSuffix  = suf
end
function M.stopAllEffects()
    sharedEngine:stopAllEffects()
end

function M.getMusicVolume()
    return sharedEngine:getBackgroundMusicVolume()
end

function M.isMusicPlaying()
    return sharedEngine:isBackgroundMusicPlaying()
end

function M.getEffectsVolume()
    return sharedEngine:getEffectsVolume()
end

function M.setMusicVolume(volume)
    sharedEngine:setBackgroundMusicVolume(volume)
end

function M.stopEffect(handle)
    sharedEngine:stopEffect(handle)
end

function M.stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    M.playingMusic = nil
    sharedEngine:stopBackgroundMusic(releaseDataValue)
end


function M.getPlayingMusic()
    return M.playingMusic
end
function M.pauseAllEffects()
    sharedEngine:pauseAllEffects()
end

function M.preloadMusic(filename)
    sharedEngine:preloadBackgroundMusic(filename)
end

function M.resumeMusic()
    if M.music then
        sharedEngine:resumeBackgroundMusic()
    end
end

function M.playEffect(filename, isLoop)
    --print ("xxxx",filename..M.effectSuffix)
    if UserSetting and UserSetting["effectOpen"] and tonumber(UserSetting["effectOpen"]) == 0 then
        return
    end
    if M.effect ~= true then
        return 
    end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    return sharedEngine:playEffect(filename..M.effectSuffix, loopValue)
end

function M.rewindMusic()
    sharedEngine:rewindBackgroundMusic()
end

function M.willPlayMusic()
    return sharedEngine:willPlayBackgroundMusic()
end

function M.unloadEffect(filename)
    sharedEngine:unloadEffect(filename..M.effectSuffix)
end

function M.preloadEffect(filename)
    sharedEngine:preloadEffect(filename..M.effectSuffix)
end

function M.setEffectsVolume(volume)
    sharedEngine:setEffectsVolume(volume)
end

function M.pauseEffect(handle)
    sharedEngine:pauseEffect(handle)
end

function M.resumeAllEffects(handle)
    sharedEngine:resumeAllEffects()
end

function M.pauseMusic()
    sharedEngine:pauseBackgroundMusic()
end

function M.resumeEffect(handle)
    sharedEngine:resumeEffect(handle)
end

local modename = "AudioEngine"
local proxy = {}
local mt    = {
    __index = M,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy,mt)
_G[modename] = proxy
package.loaded[modename] = proxy