local event = require"logic.event"
local userdata = require"logic.userdata"
local tool = require "logic.tool"

module("handler.fruitMachine",package.seeall)

function onEnterGameSucceed(gameData)
   local mainScene = package.loaded["scene.main"]
   local gameLoading = package.loaded["scene.gameLoading"]
   AudioEngine.stopMusic(true)
   local enterGameFunc = function (mod) 
      if gameLoading.isEnded == false then
         gameLoading.endFunc = function ()
            mainScene.createSubWidget(mod)
         end
      else 
         mainScene.createSubWidget(mod)
      end
   end
   if gameData.gameid == 11 then--大场
      local fishMachine = package.loaded["scene.fishMachine.main"]
      fishMachine.initData(gameData,gameData.gameid)
      -- enterGameFunc(mainScene.widgetID.fruitMachine)
      mainScene.createSubWidget(mainScene.widgetID.fishMachine)
   elseif gameData.gameid == 12 then--小场
      local fishMachine = package.loaded["scene.fishMachine.main"]
      fishMachine.initData(gameData,gameData.gameid)
      -- enterGameFunc(mainScene.widgetID.fishMachine)
      mainScene.createSubWidget(mainScene.widgetID.fishMachine)
   elseif gameData.gameid == 10 then
      -- print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
      local moraGame = package.loaded["scene.moraGame"]
      -- moraGame.initData(gameData)
      -- enterGameFunc(mainScene.widgetID.moraGame)
      mainScene.createSubWidget(mainScene.widgetID.moraGame)
   end
end

function onEnterGameFailed(gameData)
   if gameData and gameData.msg then
      alert.create(gameData.msg)
   end
end

function onLeaveGameSucceed(gameData)
   print("onLeaveGameSucceed",gameData.gameid)
   if gameData.gameid > 0 then
      local mainScene = package.loaded["scene.main"]
      mainScene.createSubWidget(nil)
   end
end

function onLeaveGameFailed(gameData)
   if gameData and gameData.msg then
      alert.create(gameData.msg)
   end
end

function onGetUserListSucceed(gameData)
   -- body
end

function onGetUserListSucceed(gameData) 
   event.pushEvent("ON_GET_USER_LIST_SUCCEED",gameData)
end

function onGetUserListFailed(gameData) 
   event.pushEvent("ON_GET_USER_LIST_FAILED",gameData)
end

function onEnterGameNotice(gameData) 
   event.pushEvent("ON_ENTER_GAME_NOTICE",gameData)
end

function onExitGameNotice(gameData) 
   event.pushEvent("ON_EXIT_GAME_NOTICE",gameData)
end

function onGetGameStatus(gameData)
   event.pushEvent("ON_GET_GAME_STATUS", gameData)
end

function onBetSucceed(gameData)
   userdata.UserInfo.owncash = userdata.UserInfo.owncash - gameData.betMoney
   event.pushEvent("ON_BET_SUCCEED", gameData)
   event.pushEvent("ON_CHANGE_GOLD")
end

function onBetFailed(gameData)
   event.pushEvent("ON_BET_FAILED", gameData)
   -- userdata.UserInfo.gold = userdata.UserInfo.gold + data.gold
   -- userdata.UserInfo.giftGold = userdata.UserInfo.giftGold + data.giftGold
   -- if userdata.isInGame == true then
   --    userdata.isInGame = false  
   -- end
end

--1是vip进入，2是游戏获奖，3是抽奖
function onGameNotice(data)
   -- printTable(data)
   event.pushEvent("SYSTEM_MESSAGE", data)
end

function onBigWin(id,name,exp,gold)
   event.pushEvent("ON_BIG_WIN", id,name,exp,gold)
end

function systemContext(data,type)
   event.pushEvent("SYSTEM_CONTEXT", data,type)
end