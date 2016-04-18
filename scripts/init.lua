package.loaded["config"] = nil
require "config"

print("update version:",scriptsVersion)
require "sqlite"
require "umeng"
setting = require "scene.userSetting"

require"handler.all"
require"AudioEngine"
require"handler.init"
alert = require "scene.alert"
fileManager = require"logic.fileManager"
C_IsUpdating(0)
function main()
   fileManager.clearFile()
   math.randomseed(os.time())

   if platform == "IOS" then
      CCDirector:sharedDirector():setAnimationInterval(1.0 / 60)
   else
      CCDirector:sharedDirector():setAnimationInterval(1.0 / 60)
   end

   AudioEngine.setEffectSuffix(".wav")
   if platform == "Android" then
      AudioEngine.setEffectSuffix(".ogg")
   end
   if platform == "IOS" then
      AudioEngine.setEffectSuffix(".caf")
   end

   local sceneManager = require"logic.sceneManager"
   sceneManager.change(sceneManager.SceneType.startScene)
end

xpcall(main)
