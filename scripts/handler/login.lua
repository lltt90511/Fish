local userdata = require"logic.userdata"
local http = require"logic.http"
local sqlite = require "sqlite"

payServerUrl = payServerUrl

module("handler.login",package.seeall)
function onLoginSucceed(data)
   printTable(data)
   userdata.UserInfo = data
   userdata.CharIdToImageFile[data.uidx] = {file=userdata.UserInfo.PicUrl,sex=userdata.UserInfo.sex}
   print("@!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
   printTable(userdata.CharIdToImageFile)
   firstToMainScene()
   -- if data.isCreateChar == false then
   --    local loginScene = package.loaded["scene.login"]
   --    --local accName = loginScene.textInput:getText()
   --    if userdata.appInfo.appModel then
   --       call("setInitUserName",1,userdata.appInfo.appModel)
   --    else
   --       call("setInitUserName",1,"")
   --    end
   --    -- call("setInitUserName",1,"")
   --    userdata.UserInfo = {}
   --    userdata.UserInfo.charId = data.charId
   --    userdata.UserInfo.vipExp = data.vipExp
   --    userdata.UserInfo.rmb = data.rmb
   --    userdata.UserInfo.diamonds = data.diamonds
   --    userdata.UserInfo.lastChargeTime = data.lastChargeTime
   --    userdata.UserInfo.lastPhoneCodeTime = data.lastPhoneCodeTime
   --    userdata.UserInfo.phoneNumber = data.phoneNumber
   --    userdata.UserInfo.phoneTmp = data.phoneTmp
   --    userdata.UserInfo.changeUserName = data.changeUserName
   --    userdata.UserInfo.accId = data.accId
   --    setChargeMap(data.chargeMap)
   -- else 
   --    call("getGiftList")
   --    userdata.UserInfo = data.character
   --    userdata.UserInfo.vipExp = data.vipExp
   --    userdata.UserInfo.rmb = data.rmb
   --    userdata.UserInfo.diamonds = data.diamonds
   --    userdata.UserInfo.lastChargeTime = data.lastChargeTime
   --    userdata.UserInfo.lastPhoneCodeTime = data.lastPhoneCodeTime
   --    userdata.UserInfo.phoneNumber = data.phoneNumber
   --    userdata.UserInfo.phoneTmp = data.phoneTmp
   --    userdata.UserInfo.changeUserName = data.changeUserName
   --    userdata.UserInfo.accId = data.accId
   --    setChargeMap(data.chargeMap)
   --    firstToMainScene()
   -- end
end

function setChargeMap(data) 
   userdata.UserInfo.chargeMap = {}
   if data then
      for k, v in pairs(data) do 
         userdata.UserInfo.chargeMap[tonumber(k)] = tonumber(v)
      end
   end
end

function firstToMainScene()
   local daily = false
   -- print (timeToDayStart(getSyncedTime()) , userdata.UserInfo.lastDailyGiftTime/1000 )
   if timeToDayStart(getSyncedTime()) > userdata.UserInfo.lastLq then
      daily = true
   end
   local main = package.loaded['scene.main']
   main.daily = daily
   local sceneManager = package.loaded["logic.sceneManager"]
   if sceneManager.currentScene == sceneManager.SceneType.mainScene then
      local binding = package.loaded["scene.binding"]
      binding.exit()
      sceneManager.Scene[sceneManager.currentScene].initView() 
   end 
   sceneManager.change(sceneManager.SceneType.mainScene)
   luaoc.callStaticMethod("AppController","pushRegister",{account=userdata.UserInfo.uidx,server=payServerUrl.."/ydream/login",environment=""})
   print("payServerUrl url", payServerUrl.."/ydream/login?type=8&appSrc="..appSrc.."&userId="..userdata.UserInfo.uidx)
   http.request(payServerUrl.."/ydream/login?type=8&appSrc="..appSrc.."&userId="..userdata.UserInfo.uidx,nil)
end
function onLoginFailed(data)
   if data and data.msg then
      alert.create(data.msg)
   end
end

function onSetInitNameSucceed(data)
   for k, v in pairs(data) do
      userdata.UserInfo[k] = v
   end
   firstToMainScene()
end

function onSetInitNameFailed(data)

end
