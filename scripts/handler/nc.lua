local alert = require "scene.alert"
local userdata = require"logic.userdata"
module("handler.nc", package.seeall)

reconnectAlert = function ()
   local nc = package.loaded['logic.nc']
   alert.create("连接服务器失败，请检查网络连接", nil, 
      function()
         nc.connect()
         local sceneManager = require"logic.sceneManager"
         sceneManager.change(sceneManager.SceneType.startScene)
         if true then return end
         if platform == "Windows" then
           local sceneManager = require"logic.sceneManager"
           sceneManager.change(sceneManager.SceneType.starScene)
         else
            if UserSetting.uuid ~= nil and UserSetting.uuid ~= "" then
               print("login uuid", UserSetting.uuid)
               nc.connect()
               call(1001, "2", UserSetting.uuid)
            else
               if userdata.deviceId then
                  print("login deviceId", userdata.deviceId)
                  nc.connect()
                  call(1001, "1", userdata.deviceId)
               end
           end
           -- if getPlatform() == "sgj" or getPlatform() == "ipay_chongqin" then
           --   if UserSetting.uuid ~= nil and UserSetting.uuid ~= "" then
           --     print("login uuid", UserSetting.uuid)
           --     nc.connect()
           --     call("login", 0, UserSetting.uuid)
           --   else
           --     if userdata.deviceId then
           --       print("login deviceId", userdata.deviceId)
           --       nc.connect()
           --       call("login", 0, userdata.deviceId)
           --     end
           --   end
           -- elseif getPlatform() == "xmw" then
           --   nc.disConnect()
           --   saveSetting("uuid","")
           --   sdkLogin()
           -- end
         end
      end, nil, "重试", "取消")
end

function onConnect(ret)
   print("onConnect", ret)
   local nc = package.loaded['logic.nc']
   if ret == -1 then
      reconnectAlert()
      return
   end
   nc.startTimeHandler()
   nc.connected = true
end

function onClose()
   local nc = package.loaded['logic.nc']
   nc.stopTimer()
   nc.connected = false
   reconnectAlert()
end
