local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local chat = require"scene.chat.main"
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require "logic.countLv"
local http = require"logic.http"
local exchange = require"scene.exchange"

module("scene.fishMachine.main", package.seeall)

this = nil 
thisParent = nil
parentModule = nil
local data = {}
local autoArr = {50,10,5}
local autoIndex = 1
local singleArr = {"玫瑰","千纸鹤","水晶鞋","兰博基尼"}
-- local singleGoldArr = {100,1000,10000,100000}
local singleGoldArr = {100,1000,10000,100000}
local singleIndex = 1
local fishTimer = nil
local nextTimer = nil
local isPlaying = false
local betOwn = {}
local historyBet = {}
local autoCnt = 0
local winGold = 0
local starNum = 7
local lastOpenId = {inside=0,outside=0}
local classicOutSide = {}
local chatView = nil
local cdEffectPlaying = false
local eventHash = {}
-- local historyUserGold = {}
local isRepeat = false
local isBet = {}
local betEndTime = 0
local finishCircleCnt = 0
local toNextTime = 10
local isDoBet = false
local currentUserPage = 0
local userRankList = {}
local totalUserNum = 0
local isRemuse = false
local resultName = {inside="",outside=""}
local effectId = 0
local gId = 0
local dapuhuoPos = {x=0,y=0}
local shayuPos = {x=0,y=0}
local moguiPos = {x=0,y=0}
local shayuSprite = nil
local moguiSprite = nil

local fishList = {
  [1]={id = 1,name = '大捕获',res = '13',fishType = 0,seqId = 1,multi = 0.0,multiEffect = '8,4,10,2'},
  [2]={id = 8,name = '珊瑚鱼',res = '10',fishType = 0,seqId = 2,multi = 0.0,multiEffect = ''},
  [3]={id = 3,name = '鲨鱼',res = '1',fishType = 0,seqId = 3,multi = 50.0,multiEffect = ''},
  [4]={id = 7,name = '烛光鱼',res = '2',fishType = 0,seqId = 4,multi = 0.0,multiEffect = ''},
  [5]={id = 4,name = '魔鬼鱼',res = '3',fishType = 0,seqId = 5,multi = 20.0,multiEffect = ''},
  [6]={id = 10,name = '水母',res = '4',fishType = 0,seqId = 6,multi = 0.0,multiEffect = ''},
  [7]={id = 2,name = '小捕获',res = '14',fishType = 0,seqId = 7,multi = 0.0,multiEffect = ''},
  [8]={id = 11,name = '蝴蝶鱼',res = '5',fishType = 0,seqId = 8,multi = 0.0,multiEffect = ''},
  [9]={id = 5,name = '灯笼鱼',res = '6',fishType = 0,seqId = 9,multi = 10.0,multiEffect = ''},
  [10]={id = 9,name = '海豚',res = '7',fishType = 0,seqId = 10,multi = 0.0,multiEffect = ''},
  [11]={id = 6,name = '海龟',res = '8',fishType = 0,seqId = 11,multi = 5.0,multiEffect = ''},
  [12]={id = 12,name = '海星',res = '9',fishType = 0,seqId = 12,multi = 0.0,multiEffect = ''},
  [13]={id = 13,name = '对虾',res = '11',fishType = 1,seqId = 1,multi = 1.5,multiEffect = ''},
  [14]={id = 14,name = '螃蟹',res = '12',fishType = 1,seqId = 2,multi = 1.5,multiEffect = ''},
  [15]={id = 13,name = '对虾',res = '11',fishType = 1,seqId = 3,multi = 1.5,multiEffect = ''},
  [16]={id = 14,name = '螃蟹',res = '12',fishType = 1,seqId = 4,multi = 1.5,multiEffect = ''},
  [17]={id = 13,name = '对虾',res = '11',fishType = 1,seqId = 5,multi = 1.5,multiEffect = ''},
  [18]={id = 14,name = '螃蟹',res = '12',fishType = 1,seqId = 6,multi = 1.5,multiEffect = ''},
}
function create(_parent, _parentModule)
   thisParent = _parent
   parentModule = _parentModule 
   this = tool.loadWidget("cash/fish_machine",widget, thisParent)
   commonTop.create(this,package.loaded["scene.fishMachine.main"],gId)
   AudioEngine.playMusic("bgm02.mp3",true)
   -- AudioEngine.preloadEffect("effect_19")
   if userdata.lastFishSingleIndex[gId] and userdata.lastFishSingleIndex[gId] ~= 0 then
        singleIndex = userdata.lastFishSingleIndex[gId]
   end
   if userdata.lastFishSingleType[gId] and userdata.lastFishSingleType[gId] ~= "" then
      local splitList = splitString(userdata.lastFishSingleType[gId],";")
      for k,v in pairs(splitList) do
          local list = splitString(v,",")
          historyBet[tonumber(list[1])] = tonumber(list[2])
      end
   end

   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/shayu.ExportJson")
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/moguiyu.ExportJson")
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/denglongyu.ExportJson")
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/wugui.ExportJson")
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/gold.ExportJson")

   -- if userdata.userFishHistoryGold and userdata.userFishHistoryGold ~= "" then
   --    local splitList = splitString(userdata.userFishHistoryGold,",")
   --    for k,v in pairs(splitList) do
   --        historyUserGold[k] = tonumber(v)
   --    end
   -- end 
   -- printTable(historyBet)
   -- widget.bottom_bg.rank_list.obj:setItemModel(widget.rank_render.obj)
   -- initClassicOutSide()

   lastOpenId = {inside=1,outside=1}
   initView()
   initChatView()
   setHelp(false)
   widget.help.obj:registerEventScript(function(event)
      if event == "releaseUp" then
         setHelp(false)
      end
   end)
   totalCashGold = 0
   currentUserPage = 1
   -- widget.bigAward.obj:setVisible(false)
   -- widget.bigAward.obj:setScale(0)
   -- widget.history_layout.obj:setVisible(false)
   -- widget.history_layout.obj:setTouchEnabled(false)
   -- widget.history_layout.alert.back.obj:setTouchEnabled(false)
   event.listen("ON_GET_GAME_STATUS",onGetGameStatus)
   event.listen("ON_BET_SUCCEED", onBetSucceed)
   event.listen("ON_BET_FAILED", onBetFailed)
   event.listen("ON_REMUSE_FROM_BACKGROUND", onRemuseFormBackground)
   -- if userdata.isFirstGame==1 then
   --    widget.bottom_bg.alert.obj:setVisible(true)
   --    alertFunc(widget.bottom_bg.alert.obj)
   -- else
   --    widget.bottom_bg.alert.obj:setVisible(false)
   -- end
   return this
end

function onRemuseFormBackground()
   if not isRemuse then
      isRemuse = true
   end
   call(8001)
end

function initClassicOutSide()
   classicOutSide = {}
   for k, v in pairs(fishList) do
      if v.fishType == 2 then
         classicOutSide[v.id] = v
      end
   end
end

function initData(gameData,id)
   onUpdateGameData(gameData)
   gId = id
   if data.type == 100 then
      betEndTime = 20 - data.time
   else
      betEndTime = 20
   end
   for k,v in pairs(gameData.bet) do
       singleGoldArr[v.id] = v.gold
   end
end

function onUpdateGameData(gameData)
   data = {}
   for k,v in pairs(gameData) do
       data[k] = v
   end 
   printTable(data)
end

function hiddenAllLight()
   for i=1,12 do
       widget.fish["panel_outside_"..i].light.obj:setVisible(false)
   end
   for i=1,6 do
       widget.fish["panel_inside_"..i].light.obj:setVisible(false)
   end
end

function onGetGameStatus(gameData)
   onUpdateGameData(gameData)
   if data.type == 100 then
      hiddenAllLight()
      changeTouchEnabled(true)
      endNextTimer()
      endFishTimer()
      toNextTime = 10
      if isDoBet then
         isDoBet = false 
      end
      betEndTime = 20 - data.time
      local str = string.format("%02d", betEndTime)
      widget.fish.cd_bg.cd.obj:setText(str) 
      if betEndTime < 5 then
         widget.fish.cd_bg.cd.obj:setColor(ccc3(255,0,0))
      end
      widget.bottom.layout.obj:setTouchEnabled(false)
      widget.bottom.layout.obj:setVisible(false)
      widget.bottom.layout.bg.obj:setVisible(false)
      startFishTimer() 
   elseif data.type == 200 then
      changeTouchEnabled(false)
      widget.fish.cd_bg.cd.obj:setColor(ccc3(204,255,255))
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.bg.obj:setVisible(false)
      widget.bottom.layout.text.obj:setText("开奖中......")
      widget.fish.cd_bg.cd.obj:setText("00")
      if not isPlaying then
         playFishEffect()
      end
   elseif data.type == 201 then
      widget.fish.cd_bg.cd.obj:setText("00")
      widget.fish.cd_bg.cd.obj:setColor(ccc3(204,255,255))
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.bg.obj:setVisible(false)
      -- hiddenAllLight()
      changeTouchEnabled(false)
      endNextTimer()
      nextTimer = schedule(
         function()
            toNextTime = toNextTime - 1
            if toNextTime < 0 then
               toNextTime = 0
            end
            if isDoBet then
               return 
            end
            if isPlaying == false then
               widget.bottom.layout.text.obj:setText("等待开始...还剩"..toNextTime.."秒")
            end
            if toNextTime == 0 then
               toNextTime = 10
               endNextTimer()
            end
         end,1)
      if not isPlaying then
         playFishEffect()
      end
      if data.GameResult and data.GameResult.f and data.GameResult.f[1] and data.GameResult.f[1] == 1 or data.GameResult.f[1] == 3 or data.GameResult.f[1] == 4 then
         setIsBigWin()
      end
   end
end

function onBetSucceed(_data)
   if not isBet[_data.betid].bool then
      isBet[_data.betid].bool = true
   end
   if not isDoBet then
      isDoBet = true
   end
   local equipId = 0
   for i=1,#singleGoldArr do
       if singleGoldArr[i] == _data.betMoney then
          equipId = i
          break
       end
   end
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].img.img.obj:setVisible(true)
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].img.img.obj:loadTexture("cash/qietu/fish/equip_"..equipId..".png")
   onGameUserActionSucceed(_data.betid,_data.betMoney)
end

function onBetFailed(_data)
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].img.obj:setVisible(false)
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].img.img.obj:setVisible(false)
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].img.obj:setTouchEnabled(false)
   if _data.msg == "余额不足,请充值" then
      alert.create(_data.msg,nil,"确定",function()
         commonTop.onRecharge("releaseUp")
      end,"取消",nil)
   else
      alert.create(_data.msg)
   end  
end

function onGetUserListSucceed(_data)
   print("onGetUserListSucceed")
   -- printTable(_data)
   if not _data.users or (_data.users and #_data.users==0) then
      currentUserPage = currentUserPage - 1
      return
   end
   totalUserNum = _data.count
   for k,v in pairs(_data.users) do
       table.insert(userRankList,v)
   end
   print("userRankList!!!!!!!!!!!!!!!!!!!!!!!",#userRankList)
   initRankView(_data.users)
   performWithDelay(function()
                    if not this then return end
                    widget.bottom_bg.rank_list.obj:setBounceEnabled(false)
                   -- widget.bottom_bg.rank_list.obj:scrollToBottom(0.5,true)
                    performWithDelay(function()
                                       if not this then return end  
                                          widget.bottom_bg.rank_list.obj:setBounceEnabled(true)
                                       end,0.6)
                                     end,0.15)
end

function resetShowChatHistory(flag) 
   commonTop.isShowChatHistory = flag
end

function initView()
   for k, v in pairs(fishList) do
      if v.fishType == 0 then
         widget.fish["panel_outside_"..v.seqId].light.obj:setVisible(false)
         widget.fish["panel_outside_"..v.seqId].fish.obj:loadTexture("cash/qietu/fish/fish_"..v.res..".png")
      elseif v.fishType == 1 then      
         widget.fish["panel_inside_"..v.seqId].light.obj:setVisible(false)           
         widget.fish["panel_inside_"..v.seqId].fish.obj:loadTexture("cash/qietu/fish/fish_"..v.res..".png")
      end
   end 
   changeTouchEnabled(false)
   -- local light = CCSprite:create("cash/qietu/effect/guang.png")
   -- light:setPosition(ccp(20,70))
   -- light:setScale(0.3)
   -- armatureBlend(light)
   -- widget.cd_img.obj:addNode(light)
   -- local action = CCRotateBy:create(0t.5,60)
   -- action = CCRepeatForever:create(action)
   -- light:runAction(action)
   widget.bottom.bet_btn_bg["btn_"..singleIndex].obj:setTouchEnabled(false)
   widget.bottom.bet_btn_bg["btn_"..singleIndex].obj:setBright(false)
   widget.bottom.bet_btn_bg["btn_"..singleIndex].text.obj:setColor(ccc3(42,25,6))
   widget.bottom.bet_btn_bg["btn_"..singleIndex].num.obj:setColor(ccc3(42,25,6))
   for i=1,#singleArr do
       if widget.bottom.bet_btn_bg["btn_"..i].obj then
          widget.bottom.bet_btn_bg["btn_"..i].text.obj:setText(singleArr[i])
          widget.bottom.bet_btn_bg["btn_"..i].num.obj:setText(singleGoldArr[i])
          widget.bottom.bet_btn_bg["btn_"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 singleIndex = i
                 userdata.lastFishSingleIndex[gId] = singleIndex
                 saveSetting("fishIndex"..gId,singleIndex)
                 for j=1,#singleArr do
                     if widget.bottom.bet_btn_bg["btn_"..j].obj then
                        -- print("on widget!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",j,singleIndex)
                        if j == singleIndex then
                           widget.bottom.bet_btn_bg["btn_"..j].obj:setTouchEnabled(false)
                           widget.bottom.bet_btn_bg["btn_"..j].obj:setBright(false)
                           widget.bottom.bet_btn_bg["btn_"..j].text.obj:setColor(ccc3(42,25,6))
                           widget.bottom.bet_btn_bg["btn_"..j].num.obj:setColor(ccc3(42,25,6))
                        else
                           widget.bottom.bet_btn_bg["btn_"..j].obj:setTouchEnabled(true)
                           widget.bottom.bet_btn_bg["btn_"..j].obj:setBright(true)
                           widget.bottom.bet_btn_bg["btn_"..j].text.obj:setColor(ccc3(254,177,23))
                           widget.bottom.bet_btn_bg["btn_"..j].num.obj:setColor(ccc3(254,177,23))
                        end
                     end
                 end
              end
          end)
       end
   end
   
   widget.bottom.layout.obj:setVisible(false)
   widget.bottom.layout.obj:setTouchEnabled(false)
   widget.bottom.layout.bg.obj:setVisible(false)

   if data.type == 100 then
      local str = string.format("%02d", betEndTime)
      widget.fish.cd_bg.cd.obj:setText(str)
      if betEndTime < 5 then
         widget.fish.cd_bg.cd.obj:setColor(ccc3(255,0,0))
      end
      startFishTimer()
      changeTouchEnabled(true)    
   elseif data.type == 200 then
      widget.fish.cd_bg.cd.obj:setText("00")
      widget.fish.cd_bg.cd.obj:setColor(ccc3(204,255,255))
      playFishEffect()
      widget.bottom.rebet.obj:setBright(false)
      widget.bottom.rebet.obj:setTouchEnabled(false)
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.text.obj:setText("开奖中......")
   elseif data.type == 201 then
      widget.fish.cd_bg.cd.obj:setText("00")
      widget.fish.cd_bg.cd.obj:setColor(ccc3(204,255,255))
      widget.bottom.rebet.obj:setBright(false)
      widget.bottom.rebet.obj:setTouchEnabled(false)
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.text.obj:setText("开奖中，请稍后...")
      playFishEffect()
      if data.GameResult.f[1] == 1 or data.GameResult.f[1] == 3 or data.GameResult.f[1] == 4 then
         setIsBigWin()
      end
   end
   -- widget.bottom_bg.bet_list.obj:setVisible(true)
   -- widget.bottom_bg.bet_list.obj:setTouchEnabled(false)
   -- widget.bottom_bg.bet_list.obj:setItemModel(widget.bet_render.obj)
   -- widget.bottom_bg.bet_list.obj:removeAllItems()
   local cnt = 0
   local arr = {3,4,5,6,13,14}
   for i = 1,#arr do
      isBet[arr[i]] = {bool=false,id=i}
      local typeTmp = fishList[arr[i]]
      local hasBet = false
      local equipId = 0
      -- if data.type == 100 then
      if data.info and type(data.info) == type({}) then
         for k,v in pairs(data.info) do
             if v.id and v.id == arr[i] then
                hasBet = true         
                for i=1,#singleGoldArr do
                    if singleGoldArr[i] == v.money then
                       equipId = i
                       break
                    end
                end
                break
             end
         end
      end
      widget.bottom.bet_bg["bet_"..i].img.obj:setVisible(hasBet)
      widget.bottom.bet_bg["bet_"..i].img.obj:setTouchEnabled(hasBet)
      widget.bottom.bet_bg["bet_"..i].img.img.obj:setVisible(hasBet)
      if hasBet then
         widget.bottom.bet_bg["bet_"..i].img.img.obj:loadTexture("cash/qietu/fish/equip_"..equipId..".png")
      end
      widget.bottom.bet_bg["bet_"..i].obj:registerEventScript(function(ev,data)
                          if isBet[arr[i]].bool then
                             return
                          end
                          if ev == "releaseUp" then
                             tool.buttonSound("releaseUp","effect_12")
                             bet(arr[i], singleGoldArr[singleIndex])
                          end
      end)
   end
   if data.info and type(data.info) == type({}) then
      for k, v in pairs(data.info) do
          if v.id and v.money then
             onGameUserActionSucceed(v.id,v.money)
          end
      end
   end
   -- refrendeshBetTotal()
end

function armatureBlend(armature)
    local fff = ccBlendFunc()
    local f =  {GL_SRC_ALPHA, GL_ONE};
    fff.src = f[1]
    fff.dst = f[2]
    armature:setBlendFunc(fff)
end

function starAction(obj)
   if not this or not obj then
      return
   end
   tool.createEffect(tool.Effect.fadeIn,{time=math.random(0.4,1.0)},obj,function()
      tool.createEffect(tool.Effect.fadeOut,{time=math.random(0.4,1.0)},obj,function()
         starAction(obj)
      end)
   end)
end

function multiEffect(index, arr, callback)
   if index == #arr then
      callback()
      return
   end
   AudioEngine.playEffect("effect_03")
   local st = tonumber(arr[index])
   local ed = tonumber(arr[index+1])
   local dic = st < ed and 1 or -1
   local func = nil
   local delay = 0
   local totalCnt = math.abs(st-ed)
   func = function()
      st = st + dic
      widget.game_bg.outside["item"..st].effect.obj:setVisible(true)
      widget.game_bg.outside["item"..st].effect.obj:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay},widget.game_bg.outside["item"..st].effect.obj,
                        function()
                           widget.game_bg.outside["item"..st].effect.obj:setOpacity(255)
                           if st == ed then
                              tool.createEffect(tool.Effect.blink,{time=0.3,f=3},widget.game_bg.outside["item"..st].effect.obj,
                                                function()
                                                   AudioEngine.playEffect("effect_04")
                                                   multiEffect(index+1,arr,callback)
                                                end
                              )                              
                              return 
                           end

                           local flag = false
                           for k, v in pairs(arr) do 
                              if st == tonumber(v) and index >= k then
                                 flag = true
                              end
                           end
                           if flag == false then
                              local _st = st
                              tool.createEffect(tool.Effect.fadeOut,{time=0.2},widget.game_bg.outside["item".._st].effect.obj,
                                                function()
                                                   widget.game_bg.outside["item".._st].effect.obj:setVisible(false)
                                                end
                              )
                           end
                           
                           local x = math.abs(st - arr[index])
                           delay = (x-totalCnt/2)*(x-totalCnt/2)/100
                           func()
                        end
      )
   end
   func()
end

function checkMultiFish(id, callback)
   local classicTmp = classicOutSide[id]
   local arr = splitString(classicTmp.multiEffect, ",")
   table.insert(arr,1,id)
   if classicTmp.multiEffect ~= "" then
      multiEffect(1, arr, callback)
   else 
      callback()
   end
end

function playCircle(maxNum, name)
   local st = lastOpenId[name]
   local delay = name == "inside" and 0.2 or 0.2
   -- if widget.fish["panel_"..name.."_"..st] ~= nil then
   --    widget.fish["panel_"..name.."_"..st].light.obj:setVisible(false)
   -- end
   -- st = st >= maxNum and 1 or st + 1
   -- local slowNum = name == "inside" and 2 or 4

   local func = nil
   local cnt = 0
   func = function()
      if data.type == 100 then
         endEffect()
         return
      end
      widget.fish["panel_"..name.."_"..st].light.obj:setVisible(true)
      -- widget.fish["panel_"..name.."_"..st].light.obj:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay}, widget.fish["panel_"..name.."_"..st].light.obj,
      function()
        if name == "outside" then
           AudioEngine.playEffect("effect_19")
        end
        -- widget.fish["panel_"..name.."_"..st].light.obj:setOpacity(255)
        widget.fish["panel_"..name.."_"..st].light.obj:stopAllActions()

       local _st = st
       if data.type == 201 then
          local resultCnt = name == "inside" and data.GameResult.f[2] or data.GameResult.f[1]
          local totalCnt = name == "inside" and maxNum + resultCnt - lastOpenId[name] + 12 or maxNum + resultCnt - lastOpenId[name]
          local _id = name == "inside" and st + 12 or st
          -- print("201!!!!!!!!!!!!!!!!!!!!!",totalCnt,cnt,st,resultCnt,_id)
          delay = 0.4
          if fishList[_id].id == resultCnt then
             -- print("end ",_id,resultCnt,fishList[_id].id,fishList[_id].name)
             resultName[name] = fishList[_id].name
             finishCircleCnt = finishCircleCnt + 1
             lastOpenId[name] = st
             widget.fish["panel_"..name.."_"..st].light.obj:setVisible(true)
             if finishCircleCnt == 2 then
                -- AudioEngine.stopEffect(effectId)
                AudioEngine.stopAllEffects()
                endEffect() 
             end 
             return
          end
       end
       cnt = cnt + 1
       st = st + 1
       if data.type == 200 then
         if cnt > 4 then
            delay = 0.1
         elseif cnt > 8 then
            delay = 0.05
         end
       end
       if st == maxNum + 1 then
          st = 1
       end 
       widget.fish["panel_"..name.."_".._st].light.obj:setVisible(false)
       -- tool.createEffect(tool.Effect.delay,{time = delay-0.1 > 0.1 and delay-0.1 or 0.1},widget.fish["panel_"..name.."_".._st].light.obj,
       --                   function()
       --                      widget.fish["panel_"..name.."_".._st].light.obj:setVisible(false)                                                
       --                   end
       -- )
       func()
    end
      )
   end
   func()
end

function playFishEffect()
   -- printTable(id)
   -- AudioEngine.playEffect("effect_02")
   -- for i = 1, 12 do
   --    if i ~= lastOpenId.outside then
   --       widget.fish["panel_outside_"..i].light.obj:setVisible(false)
   --    end
   -- end
   -- effectId = AudioEngine.playEffect("effect_19",true)
   endFishTimer()
   isPlaying = true
   changeTouchEnabled(false)
   userdata.isInGame = true
   playCircle(6, "inside")
   playCircle(12, "outside")
end

function endEffect()
   userdata.isInGame = false
   -- for i=1,12 do
   --     if data.GameResult.f[1] == fishList[i].id then
   --        lastOpenId.outside = i
   --     end
   -- end
   -- lastOpenId.inside = data.GameResult.f[2] - 12
   -- print("endEffect!!!!!!!!!!!!!!!",lastOpenId.outside,lastOpenId.inside)
   -- widget.fish["panel_outside_"..lastOpenId.outside].light.obj:setVisible(false)
   -- widget.fish["panel_inside_"..lastOpenId.inside].light.obj:setVisible(false)
   if isDoBet then
       performWithDelay(function()
         isPlaying = false
       end,3.0)
   else
       isPlaying = false
   end
   winGold = 0
   finishCircleCnt = 0
   for k,v in pairs(isBet) do
       v.bool = false
       widget.bottom.bet_bg["bet_"..v.id].img.obj:setVisible(false)
       widget.bottom.bet_bg["bet_"..v.id].img.obj:setTouchEnabled(false)
       widget.bottom.bet_bg["bet_"..v.id].img.img.obj:setVisible(false)
   end
   widget.fish.bigWin.obj:removeAllNodes()
   if data.GameResult and data.GameResult.f then
      if data.GameResult.f[1] == 1 then
          showJinbi()   
          local dabuhuo = CCSprite:create("cash/qietu/fish/fish_13.png")
          dabuhuo:setAnchorPoint(ccp(0.5,0))
          dabuhuo:setPosition(ccp(Screen.width/2,230))
          widget.fish.bigWin.obj:addNode(dabuhuo,100)
          local action2_1 = CCRotateTo:create(0.6,15)
          local action2_2 = CCRotateTo:create(0.6,0)
          local action2 = CCSequence:createWithTwoActions(action2_1,action2_2)
          action2 = CCRepeatForever:create(action2)
          dabuhuo:runAction(action2)
          showShayu(1,ccp(400,400),100,-60)
          showMoguiyu(1,ccp(680,500),100,-150)
          showDenglongyu(1,ccp(440,220),100,0)
          showWugui(1,ccp(640,220),100,0)
          performWithDelay(function()
              widget.fish.bigWin.obj:removeAllNodes()
              goBo()
          end,2.0)
       elseif data.GameResult.f[1] == 3 then
          showJinbi()
          showShayu(1.5,ccp(Screen.width/2,692/2),100,-30)
          performWithDelay(function()
              widget.fish.bigWin.obj:removeAllNodes()
              goBo()
          end,2.0)
       elseif data.GameResult.f[1] == 4 then
          showJinbi()
          showMoguiyu(1.5,ccp(Screen.width/2,692/2),100,-150)
          performWithDelay(function()
              widget.fish.bigWin.obj:removeAllNodes()
              goBo()
          end,2.0)
      end
   end
   checkWinResult()
   commonTop.registerEvent()

   betOwn = {}
   
   tool.createEffect(tool.Effect.delay,{time=1},widget.bottom.layout.obj,function()
          isDoBet = false
   end)
   widget.bottom.layout.obj:setTouchEnabled(true)
   widget.bottom.layout.obj:setVisible(true)
end

function setIsBigWin()
   showLight(ccp(545,530))

   local dabuhuo = CCSprite:create("cash/qietu/fish/fish_13.png")
   dabuhuo:setAnchorPoint(ccp(0.5,0))
   dabuhuo:setPosition(ccp(545,445))
   widget.fish.bigWin.obj:addNode(dabuhuo,100)
   local action1 = CCRotateTo:create(0.6,15)
   local action2 = CCRotateTo:create(0.6,0)
   local action3 = CCSequence:createWithTwoActions(action1,action2)
   action3 = CCRepeatForever:create(action3)
   dabuhuo:runAction(action3)

   showLight(ccp(320,250))
   showShayu(1,ccp(260,250),100,0)

   showLight(ccp(760,250))
   showMoguiyu(1,ccp(700,250),100,0)

   local action4 = CCRotateTo:create(0.6,15)
   local action5 = CCRotateTo:create(0.6,0)
   local action6 = CCSequence:createWithTwoActions(action4,action5)
   action6 = CCRepeatForever:create(action6)
   widget.fish.panel_outside_1.fish.obj:runAction(action6)

   widget.fish.panel_outside_3.fish.obj:setVisible(false)
   local armature1 = CCArmature:create("shayu")
   local anim1 = armature1:getAnimation()
   widget.fish.panel_outside_3.obj:addNode(armature1,10)
   armature1:setPosition(ccp(85,50))
   armature1:setScaleX(270/480)
   armature1:setScaleY(203/280)
   anim1:playWithIndex(0)

   widget.fish.panel_outside_5.fish.obj:setVisible(false)
   local armature2 = CCArmature:create("moguiyu")
   local anim2 = armature2:getAnimation()
   widget.fish.panel_outside_5.obj:addNode(armature2,10)
   armature2:setPosition(ccp(75,75))
   armature2:setScaleX(175/320)
   armature2:setScaleY(233/360)
   anim2:playWithIndex(0)

   performWithDelay(function()
      widget.fish.bigWin.obj:removeAllNodes()
      widget.fish.panel_outside_1.fish.obj:stopAllActions()
      widget.fish.panel_outside_1.fish.obj:setRotation(0)
      widget.fish.panel_outside_3.obj:removeAllNodes()
      widget.fish.panel_outside_3.fish.obj:setVisible(true)
      widget.fish.panel_outside_5.obj:removeAllNodes()
      widget.fish.panel_outside_5.fish.obj:setVisible(true)
   end,2.0)
end

function showLight(_p)
   local light = CCSprite:create("cash/qietu/fish/shan.png")
   light:setPosition(_p)
   widget.fish.bigWin.obj:addNode(light,90)
   doLightAni(light)
end

function showJinbi()
   local jinbi = CCArmature:create("gold")
   local anim = jinbi:getAnimation()
   widget.fish.bigWin.obj:addNode(jinbi,90)
   jinbi:setPosition(ccp(Screen.width/2,260))
   anim:playWithIndex(0)
end

function showShayu(_s,_p,_z,_r)
   local armature = CCArmature:create("shayu")
   local anim = armature:getAnimation()
   widget.fish.bigWin.obj:addNode(armature,_z)
   armature:setPosition(_p)
   armature:setScale(_s)
   armature:setRotation(_r)
   anim:playWithIndex(0)
end

function showMoguiyu(_s,_p,_z,_r)
   local armature = CCArmature:create("moguiyu")
   local anim = armature:getAnimation()
   widget.fish.bigWin.obj:addNode(armature,_z)
   armature:setPosition(_p)
   armature:setScale(_s)
   armature:setRotation(_r)
   anim:playWithIndex(0)
end

function showDenglongyu(_s,_p,_z,_r)
   local armature = CCArmature:create("denglongyu")
   local anim = armature:getAnimation()
   widget.fish.bigWin.obj:addNode(armature,_z)
   armature:setPosition(_p)
   armature:setScale(_s)
   armature:setRotation(_r)
   anim:playWithIndex(0)
end

function showWugui(_s,_p,_z,_r)
   local armature = CCArmature:create("wugui")
   local anim = armature:getAnimation()
   widget.fish.bigWin.obj:addNode(armature,_z)
   armature:setPosition(_p)
   armature:setScale(_s)
   armature:setRotation(_r)
   anim:playWithIndex(0)
end

function goBo()
   local bo = ImageView:create()
   bo:loadTexture("cash/qietu/fish/bo.png")
   bo:setAnchorPoint(ccp(0,0))
   bo:setPosition(ccp(-768,0))
   widget.fish.bigWin.obj:addChild(bo,10)
   tool.createEffect(tool.Effect.move,{time=1.0,x=Screen.width+768,y=0,easeOut=true},bo,function()
      bo:setFlipX(true)
      tool.createEffect(tool.Effect.move,{time=1.0,x=-768,y=0,easeOut=true},bo,function()
          bo:removeFromParentAndCleanup(true)
      end)
   end)
end

function doLightAni(obj)
   local action = CCRotateBy:create(1.0,60)
   action = CCRepeatForever:create(action)
   obj:runAction(action)
end

function dabuhuoAni(obj)
  tool.createEffect(tool.Effect.shake,{time=0.5,roate=20},dabuhuo,function()
      dabuhuoAni(obj)
  end)
end

function checkWinResult()
   if data.type == 201 then
      local message = {}
      message.type = 0
      message.cnt = data.GameResult.c
      message.outside = resultName["outside"]
      message.inside = resultName["inside"]
      message.time = os.date("*t",tonumber(os.time()))
      -- chat.addSystemMessage(message)
      chat.setMessage(message,1) 
      chat.setMessage(message,3) 
      local isInResult = false
      if data.GameResult.u and #data.GameResult.u > 0 then
         for k,v in pairs(data.GameResult.u) do
             local resultMsg = {}
             if v.i == userdata.UserInfo.uidx then
                isInResult = true
                if v.m > 0 then
                   widget.bottom.layout.text.obj:setText("恭喜您获得"..getWinStr(v.m/2))
                   widget.bottom.layout.bg.obj:setVisible(true)
                end
             else
             end
             resultMsg.type = 1
             resultMsg.name = v.i == userdata.UserInfo.uidx and "你" or v.e
             resultMsg.id = v.i
             resultMsg.msg = getWinStr(v.m/2)
             chat.setMessage(resultMsg,1) 
             if v.i == userdata.UserInfo.uidx then
                chat.setMessage(resultMsg,3) 
             end         
         end
         -- print("checkWinResult!!!!!!!!!!!!!",isDoBet,isInResult)
      end
      if not isInResult and isDoBet then
         widget.bottom.layout.text.obj:setText("很遗憾您没有中奖！") 
         widget.bottom.layout.bg.obj:setVisible(true)
      end
   end
end

function getWinStr(money)
   local str = ""
   local car = math.floor(money/singleGoldArr[4])
   local shoe = math.floor((money%singleGoldArr[4])/singleGoldArr[3])
   local origami = math.floor(((money%singleGoldArr[4])%singleGoldArr[3])/singleGoldArr[2])
   local flower = math.floor((((money%singleGoldArr[4])%singleGoldArr[3])%singleGoldArr[2])/singleGoldArr[1])
   if car > 0 then
      str = str..car.."辆"..singleArr[4]
   end
   if shoe > 0 then
      str = str..shoe.."双"..singleArr[3]
   end
   if origami > 0 then
      str = str..origami.."只"..singleArr[2]
   end
   if flower > 0 then
      str = str..flower.."朵"..singleArr[1]
   end
   return str
end

function initChatView()
   chatView = chat.create(1,this,package.loaded["scene.fishMachine.main"])
   widget.bottom.obj:addChild(chatView,2)
   chatView:setAnchorPoint(ccp(0,0))
   chatView:setPosition(ccp(0,-1058))
end

function startFishTimer()
   if fishTimer == nil then
      if isRepeat then
         isRepeat = false
      end
      fishTimer = schedule(
         function()
            if data.type == 100 then
               if widget.bottom.layout.obj:isVisible() then
                  widget.bottom.layout.obj:setTouchEnabled(false)
                  widget.bottom.layout.obj:setVisible(false)
               end
               betEndTime = betEndTime - 1
               if betEndTime < 0 then
                  betEndTime = 0
                  call(8001)
                  endFishTimer()
               end
               local str = string.format("%02d", betEndTime)
               widget.fish.cd_bg.cd.obj:setText(str)  
               if betEndTime < 5 then
                  AudioEngine.playEffect("effect_01")
                  widget.fish.cd_bg.cd.obj:setColor(ccc3(255,0,0))
                  tool.createEffect(tool.Effect.blink,{time=0.5,f=1},widget.fish.cd_bg.cd.obj)
               end
               changeTouchEnabled(betEndTime > 0 and true or false)
            else
               endFishTimer()
            end
         end,1)
   end
end

function endFishTimer()
   if fishTimer then
      unSchedule(fishTimer)
      fishTimer = nil
   end
end

function endNextTimer()
   if nextTimer then
      unSchedule(nextTimer)
      nextTimer = nil
   end
end

function changeTouchEnabled(flag)
   if not isRepeat then
      widget.bottom.rebet.obj:setBright(flag)
      widget.bottom.rebet.obj:setTouchEnabled(flag)
   end
   for k, v in pairs(isBet) do
       widget.bottom.bet_bg["bet_"..v.id].obj:setTouchEnabled(flag)
   end
end

function playCdAtlasEffect(cd) 
   if userdata.isInGame == false then
      userdata.isInGame = true
   end
   if cd < 1 then
      cdEffectPlaying = false
      return 
   end
   AudioEngine.playEffect("effect_01")
   cdEffectPlaying = true
   widget.cd_img.obj:loadTexture("cash/qietu/effect/num0"..cd..".png")
   widget.cd_img.obj:setVisible(true)
   widget.cd_img.obj:setScale(2)
   tool.createEffect(tool.Effect.scale,{time=0.3,scale=4},widget.cd_img.obj,
                     function()
                        tool.createEffect(tool.Effect.scale,{time=0.1,scale=2},widget.cd_img.obj,
                                          function()
                                             tool.createEffect(tool.Effect.delay,{time=0.6},widget.cd_img.obj,
                                                               function()
                                                                  widget.cd_img.obj:setVisible(false)
                                                                  playCdAtlasEffect(cd-1)
                                                               end
                                             )
                                          end
                        )
                     end
   )
end

function onRepeatBet(event1) 
   if event1 == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if not isRepeat then
         isRepeat = true 
      end
      local flag = true
      for k, v in pairs(historyBet) do
         if betOwn[k] ~= nil and v < betOwn[k] then
            flag = false
            break
         end
      end
      if flag == true then
         for k, v in pairs(historyBet) do
            local oldBet = betOwn[k] == nil and 0 or betOwn[k]
            if v > oldBet then
               bet(k, v-oldBet)
            end
         end
      end
      widget.bottom.rebet.obj:setBright(false)
      widget.bottom.rebet.obj:setTouchEnabled(false)
   end
end

function bet(id, needGold)
   if userdata.UserInfo.owncash < needGold then
      alert.create("余额不足！")
      return
   end
   widget.bottom.bet_bg["bet_"..isBet[id].id].img.obj:setVisible(true)
   widget.bottom.bet_bg["bet_"..isBet[id].id].img.obj:setTouchEnabled(true)

   -- if userdata.isFirstGame == 1 then
   --    userdata.isFirstGame = 0
   --    saveSetting("isFirstGame",userdata.isFirstGame)
   --    widget.bottom_bg.alert.obj:setVisible(false)
   -- end
   call(9001, id, needGold)
end

function onAutoBet(event1)
   if event1 == "releaseUp" then
      -- printTable(historyBet)
      -- print(#historyBet)
      -- local i=0
      -- for k,v in pairs(historyBet) do
      --     i = i + 1
      -- end
      -- if ,i == 0 then
      --    alert.create("请先选择押注内容！")
      -- else
      --    tool.buttonSound("releaseUp","effect_12")
      --    autoCnt = autoCnt == 0 and autoArr[autoIndex] or 0
      --    if autoCnt > 0 then
      --       autoCnt = autoCnt - 1
      --       onRepeatBet("releaseUp")
      --    end
      --    widget.bottom_bg.auto_layout.label.obj:setText("跟注"..autoCnt.."轮 点击取消")
      --    widget.bottom_bg.auto_layout.obj:setVisible(true)
      --    widget.bottom_bg.auto_layout.obj:setTouchEnabled(true)
      -- end
   end
end

function onEnter()

end

function onExit()

end

function onJilu(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      widget.history_layout.obj:setVisible(true)
      widget.history_layout.obj:setTouchEnabled(true)
      widget.history_layout.alert.back.obj:setTouchEnabled(true)
      refreshHistory()
   end
end

function onAlertBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      widget.history_layout.obj:setVisible(false)
      widget.history_layout.obj:setTouchEnabled(false)
      widget.history_layout.alert.back.obj:setTouchEnabled(false)
   end
end

-- function onExchange(event)
--    if event == "releaseUp" then
--       print("onExchange!!!!!!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",gId)
--       tool.buttonSound("releaseUp","effect_12")
--       call(18001)
--       exchange.create(this,gId)
--    end
-- end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end

function exit()
   if this then
      event.unListen("ON_GET_GAME_STATUS",onGetGameStatus)
      event.unListen("ON_BET_SUCCEED", onBetSucceed)
      event.unListen("ON_BET_FAILED", onBetFailed)
      if chatView then
         chat.exit()
         chatView = nil
      end
      if commonTop then
         commonTop.exit()
      end
      if parentModule and parentModule.initTop then
         parentModule.initTop()
      end
      AudioEngine.stopMusic(true)
      AudioEngine.stopAllEffects()
      AudioEngine.playMusic("bgm01.mp3",true)
      
      cleanEvent()
      this:removeFromParentAndCleanup(true)
      this = nil
      thisParent = nil
      parentModule = nil
      tool.cleanWidgetRef(widget)
      data = nil
      endFishTimer()
      endNextTimer()
      singleIndex = 1
      betOwn = {}
      winGold = 0
      isPlaying = false
      historyBet = {}
      data = {}
      autoCnt = 0
      autoIndex = 1
      lastOpenId = {inside=0,outside=0}
      cdEffectPlaying = false
      isRepeat = false
      isBet = {}
      betEndTime = 0
      finishCircleCnt = 0
      toNextTime = 10
      isDoBet = false
      userRankList = {}
      userRankList = nil
      starNum = 7
      classicOutSide = {}
      -- historyUserGold = {}
      currentUserPage = 0
      totalUserNum = 0
      singleGoldArr = {}
      effectId = 0
      gId = 0
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(7001,gId)
      -- local mainScene = package.loaded["scene.main"]
      -- mainScene.createSubWidget(nil)
   end
end

local maxHistoryNum = 5
-----------------------------------------------

function onUpdateGameStatus(gameData)
   if this == nil then
      return
   end
   data.currentEndTime = currentEndTime / 1000
   data.clickEndTime = clickEndTime / 1000
   data.btnCountTrueInfo = btnCountTrueInfo
   data.btnCountFalseInfo = btnCountFalseInfo
   refreshBetTotal()
end

function onGameUserActionSucceed(id,money)
   if this == nil then
      return
   end
   -- printTable(_data)
   if betOwn[id] == nil then
      betOwn[id] = 0
   end
   betOwn[id] = betOwn[id] + money
   historyBet = cloneTable(betOwn)
   local str = ""
   for k,v in pairs(historyBet) do
       str = str..k..","..v..";"
   end
   saveSetting("fishType"..gId,str)
   userdata.lastFishSingleType[gId] = str
end

function onGameUserActionFailed(_limit)
   if this == nil then
      return
   end
   if _limit == "已达下注上限，请升级VIP赢取更多金币哦！！" then
      alert.create(_limit,nil,function()
          local charge = package.loaded['scene.charge']
          if charge.this then return end
          commonTop.onRecharge("releaseUp")
      end,nil,"确定","取消")
   else
      alert.create(_limit)
   end
end

function alertFunc(obj) 
   if userdata.isFirstGame == 0 then return end
    tool.createEffect(tool.Effect.delay,{time = 0.3},obj,function()
       tool.createEffect(tool.Effect.fadeOut,{time=math.random(0.6,0.8),easeIn = true},obj,function()
          tool.createEffect(tool.Effect.fadeIn,{time=math.random(0.6,0.8),easeIn = true},obj,function()
             alertFunc(obj)
          end)
       end)
    end)
end

function onHelp(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     setHelp(true)
  end
end

function onHelpBack(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     setHelp(false)
  end
end

function setHelp(flag)
   widget.help.obj:setVisible(flag)
   widget.help.obj:setTouchEnabled(flag) 
   widget.help.help_alert.back.obj:setTouchEnabled(flag) 
end

widget = {
   _ignore = true,
   bottom = {
      _type = "ImageView",
      bet_bg = {
        _type = "ImageView",
        bet_1 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "ImageView",
            img = {_type = "ImageView"},
          },
        },
        bet_2 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "Layout",
            img = {_type = "ImageView"},
          },
        },
        bet_3 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "Layout",
            img = {_type = "ImageView"},
          },
        },
        bet_4 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "Layout",
            img = {_type = "ImageView"},
          },
        },
        bet_5 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "Layout",
            img = {_type = "ImageView"},
          },
        },
        bet_6 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          img = {
            _type = "Layout",
            img = {_type = "ImageView"},
          },
        },
      },
      layout = {
        _type = "Layout",
        text = {_type = "Label"},  
        bg = {_type = "ImageView"},
      },
      rebet = {_type = "Button",_func=onRepeatBet},
      bet_btn_bg = {
        _type = "ImageView",
        btn_1 = {
          _type = "Layout",
          text = {_type = "Label"},
          num = {_type = "Label"},
        },
        btn_2 = {
          _type = "Layout",
          text = {_type = "Label"},
          num = {_type = "Label"},
        },
        btn_3 = {
          _type = "Layout",
          text = {_type = "Label"},
          num = {_type = "Label"},
        },
        btn_4 = {
          _type = "Layout",
          text = {_type = "Label"},
          num = {_type = "Label"},
        },
      },
   },
   fish = {
      _type = "ImageView",
      cd_bg = {
        _type = "ImageView",
        cd = {_type = "Label"},
      },
      panel_outside_1 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_2 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_3 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_4 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_5 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_6 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_7 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_8 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_9 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_10 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_11 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_outside_12 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_1 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_2 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_3 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_4 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_5 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      panel_inside_6 = {
        _type = "ImageView",
        light = {_type = "ImageView"},
        fish = {_type = "ImageView"},
      },
      bigWin = {_type = "Layout"},
      help = {_type = "Button",_func = onHelp},
   },
   help = {
      _type = "Layout",
      help_alert = {
          _type = "ImageView",
          back = {_type = "Button",_func = onHelpBack},
          title = {_type = "Label"},
          label_1 = {_type = "Label"},
          label_2 = {_type = "Label"},
          label_3 = {_type = "Label"},
          label_4 = {_type = "Label"},
          label_5 = {_type = "Label"},
          label_6 = {_type = "Label"},
          label_7 = {_type = "Label"},
          label_8 = {_type = "Label"},
          label_9 = {_type = "Label"},
      },
   },
}
                               
                               
                        
