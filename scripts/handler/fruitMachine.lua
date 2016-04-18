local event = require"logic.event"
local userdata = require"logic.userdata"

module("handler.fruitMachine",package.seeall)

function onEnterGameSucceed(gameId, ...)
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
   if gameId == 0 then
      local fruitMachine = package.loaded["scene.fruitMachine.main"]
      fruitMachine.initData(...)
      enterGameFunc(mainScene.widgetID.fruitMachine)
   elseif gameId == 1 then
      local fishMachine = package.loaded["scene.fishMachine.main"]
      fishMachine.initData(...)
      enterGameFunc(mainScene.widgetID.fishMachine)
   elseif gameId == 3 then
      local moraGame = package.loaded["scene.moraGame"]
      moraGame.initData(...)
      enterGameFunc(mainScene.widgetID.moraGame)
   end
end

function onEnterGameFailed(data)
   
end

function onLeaveGameSucceed(gameId,flag)
   if not flag then
      alert.create("对方已退出房间！",nil,function()
         local mainScene = package.loaded["scene.main"]
         mainScene.createSubWidget(nil)
      end,function()
         local mainScene = package.loaded["scene.main"]
         mainScene.createSubWidget(nil)
      end)
   else
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

function onUpdateGameStatus(now, currentEndTime, clickEndTime, btnCountTrueInfo ,btnCountFalseInfo)
   event.pushEvent("UPDATE_GAME_STATUS", currentEndTime, clickEndTime, btnCountTrueInfo, btnCountFalseInfo)
end

function onGameUserActionSucceed(data)
   event.pushEvent("GAME_USER_ACTION_SUCCEED", data)
end

function onGameUserActionFailed(limit,data)
   event.pushEvent("GAME_USER_ACTION_FAILED", limit)
   userdata.UserInfo.gold = userdata.UserInfo.gold + data.gold
   userdata.UserInfo.giftGold = userdata.UserInfo.giftGold + data.giftGold
   if userdata.isInGame == true then
      userdata.isInGame = false  
   end
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