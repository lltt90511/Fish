local event = require"logic.event"
local userdata = require"logic.userdata"

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
   if gameData.GameId == 0 then
      local fruitMachine = package.loaded["scene.fruitMachine.main"]
      fruitMachine.initData(gameData)
      -- enterGameFunc(mainScene.widgetID.fruitMachine)
      mainScene.createSubWidget(mainScene.widgetID.fruitMachine)
   elseif gameData.GameId == 1 then
      local fishMachine = package.loaded["scene.fishMachine.main"]
      fishMachine.initData(gameData)
      -- enterGameFunc(mainScene.widgetID.fishMachine)
      mainScene.createSubWidget(mainScene.widgetID.fishMachine)
   elseif gameData.GameId == 3 then
      local moraGame = package.loaded["scene.moraGame"]
      moraGame.initData(gameData)
      enterGameFunc(mainScene.widgetID.moraGame)
   end
end

function onEnterGameFailed(data)
   
end

function onLeaveGameSucceed(gameid)
   print("onLeaveGameSucceed",gameid)
   if gameid > 0 then
      local mainScene = package.loaded["scene.main"]
      mainScene.createSubWidget(nil)
   end
end

function onLeaveGameFailed(data)

end

function onOpenCashOne(id,giftGoldGet,goldGet)
   event.pushEvent("OPEN_CASH_ONE",id,giftGoldGet,goldGet)
end

function onOpenCash(id,currentEndTime,clickEndTime,prizePool)
   event.pushEvent("OPEN_CASH",id,currentEndTime,clickEndTime,prizePool)
end

function onGetGameStatus(gameData)
   event.pushEvent("ON_GET_GAME_STATUS", gameData)
end

function onBetSucceed(data)
   event.pushEvent("ON_BET_SUCCEED", data)
end

function onBetFailed(data)
   event.pushEvent("ON_BET_FAILED", data)
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