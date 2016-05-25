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
local totalCashGold = 0
local lastUserGold = 0
local historyUserGold = {}
local max_list_y = -350
local isRepeat = false
local isBet = {}
local betEndTime = 0
local finishCircleCnt = 0
local toNextTime = 10
local isDoBet = false
local currentUserPage = 0
local userRankList = {}
local totalUserNum = 0
local resultName = {inside="",outside=""}
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
   this = tool.loadWidget("cash/fish_machine1",widget, thisParent)
   commonTop.create(this,package.loaded["scene.fishMachine.main"])
   AudioEngine.playMusic("bgm02.mp3",true)
   if userdata.lastFishSingleIndex and userdata.lastFishSingleIndex ~= 0 then
      singleIndex = userdata.lastFishSingleIndex
   end
   -- print("create!!!!",userdata.lastFishSingleType)
   if userdata.lastFishSingleType and userdata.lastFishSingleType ~= "" then
      local splitList = splitString(userdata.lastFishSingleType,";")
      for k,v in pairs(splitList) do
          local list = splitString(v,",")
          historyBet[tonumber(list[1])] = tonumber(list[2])
      end
   end
   if userdata.userFishHistoryGold and userdata.userFishHistoryGold ~= "" then
      local splitList = splitString(userdata.userFishHistoryGold,",")
      for k,v in pairs(splitList) do
          historyUserGold[k] = tonumber(v)
      end
   end 
   -- printTable(historyBet)
   -- widget.bottom_bg.rank_list.obj:setItemModel(widget.rank_render.obj)
   -- initClassicOutSide()
   lastOpenId = {inside=1,outside=1}
   initView()
   initResult()
   initChatView()
   totalCashGold = 0
   lastUserGold = 0--userdata.UserInfo.giftGold + userdata.UserInfo.gold
   currentUserPage = 1
   -- widget.bigAward.obj:setVisible(false)
   -- widget.bigAward.obj:setScale(0)
   -- widget.history_layout.obj:setVisible(false)
   -- widget.history_layout.obj:setTouchEnabled(false)
   -- widget.history_layout.alert.back.obj:setTouchEnabled(false)
   event.listen("ON_GET_GAME_STATUS",onGetGameStatus)
   event.listen("ON_BET_SUCCEED", onBetSucceed)
   event.listen("ON_BET_FAILED", onBetFailed)
   -- if userdata.isFirstGame==1 then
   --    widget.bottom_bg.alert.obj:setVisible(true)
   --    alertFunc(widget.bottom_bg.alert.obj)
   -- else
   --    widget.bottom_bg.alert.obj:setVisible(false)
   -- end
   return this
end

function initClassicOutSide()
   classicOutSide = {}
   for k, v in pairs(fishList) do
      if v.fishType == 2 then
         classicOutSide[v.id] = v
      end
   end
end

function initData(gameData)
   onUpdateGameData(gameData)
   if data.type == 100 then
      betEndTime = 20 - data.time
   else
      betEndTime = 20
   end
end

function onUpdateGameData(gameData)
   data = {}
   for k,v in pairs(gameData) do
       data[k] = v
   end 
   printTable(data)
end

function onGetGameStatus(gameData)
   onUpdateGameData(gameData)
   if data.type == 100 then
      changeTouchEnabled(true)
      endNextTimer()
      toNextTime = 10
      if isDoBet then
         isDoBet = false 
      end
      betEndTime = 20 - data.time
      local str = string.format("%02d", betEndTime)
      widget.fish.cd_bg.cd.obj:setText(str) 
      widget.bottom.layout.obj:setTouchEnabled(false)
      widget.bottom.layout.obj:setVisible(false)
   elseif data.type == 200 then
      widget.fish.cd_bg.cd.obj:setColor(ccc3(204,255,255))
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.text.obj:setText("开奖中......")
      widget.fish.cd_bg.cd.obj:setText("00")
      playFishEffect()
   elseif data.type == 201 then
      endNextTimer()
      nextTimer = schedule(
         function()
            toNextTime = toNextTime - 1
            if isDoBet then
               return 
            end
            if isPlaying == false then
               widget.bottom.layout.text.obj:setText("等待开始...还剩"..toNextTime.."秒")
            end
            if toNextTime == 0 then
               toNextTime = 10
               widget.bottom.layout.obj:setTouchEnabled(false)
               widget.bottom.layout.obj:setVisible(false)
               endNextTimer()
            end
         end,1)
   end
end

function onBetSucceed(_data)
   if not isBet[_data.betid].bool then
      isBet[_data.betid].bool = true
   end
   if not isDoBet then
      isDoBet = true
   end
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].layout.obj:setVisible(true)
   widget.bottom.bet_bg["bet_"..isBet[_data.betid].id].layout.obj:setTouchEnabled(true)
   onGameUserActionSucceed(_data.betid,_data.betMoney)
end

function onBetFailed(_data)
   alert.create(_data.msg)  
end

function onGetUserListSucceed(_data)
   print("onGetUserListSucceed")
   printTable(_data)
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
         widget.fish["panel_outside_"..v.seqId].fish.obj:loadTexture("cash/qietu/fish1/fish_"..v.res..".png")
      elseif v.fishType == 1 then      
         widget.fish["panel_inside_"..v.seqId].light.obj:setVisible(false)           
         widget.fish["panel_inside_"..v.seqId].fish.obj:loadTexture("cash/qietu/fish1/fish_"..v.res..".png")
      end
   end 
   changeTouchEnabled(false)
   widget.bottom.layout.obj:setVisible(false)
   widget.bottom.layout.obj:setTouchEnabled(false)
   -- local light = CCSprite:create("cash/qietu/effect/guang.png")
   -- light:setPosition(ccp(20,70))
   -- light:setScale(0.3)
   -- armatureBlend(light)
   -- widget.cd_img.obj:addNode(light)
   -- local action = CCRotateBy:create(0.5,60)
   -- action = CCRepeatForever:create(action)
   -- light:runAction(action)
   widget.bottom["btn_"..singleIndex].obj:setTouchEnabled(false)
   widget.bottom["btn_"..singleIndex].obj:setBackGroundColor(ccc3(255,0,0))
   for i=1,#singleArr do
       if widget.bottom["btn_"..i].obj then
          widget.bottom["btn_"..i].text.obj:setText(singleArr[i])
          widget.bottom["btn_"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 singleIndex = i
                 userdata.lastFishSingleIndex = singleIndex
                 saveSetting("fishIndex",singleIndex)
                 for j=1,#singleArr do
                     if widget.bottom["btn_"..j].obj then
                        print("on widget!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",j,singleIndex)
                        if j == singleIndex then
                           widget.bottom["btn_"..j].obj:setTouchEnabled(false)
                           widget.bottom["btn_"..j].obj:setBackGroundColor(ccc3(255,0,0))
                        else
                           widget.bottom["btn_"..j].obj:setTouchEnabled(true)
                           widget.bottom["btn_"..j].obj:setBackGroundColor(ccc3(0,0,0))
                        end
                     end
                 end
              end
          end)
       end
   end

   initCostView()
   
   startFishTimer()
   if data.type == 100 then
      local str = string.format("%02d", betEndTime)
      widget.fish.cd_bg.cd.obj:setText(str)
      changeTouchEnabled(true) 
   elseif data.type == 200 then
      widget.fish.cd_bg.cd.obj:setText("00")
      playFishEffect()
      widget.bottom.rebet.obj:setBright(false)
      widget.bottom.rebet.obj:setTouchEnabled(false)
   elseif data.type == 201 then
      widget.fish.cd_bg.cd.obj:setText("00")
      widget.bottom.rebet.obj:setBright(false)
      widget.bottom.rebet.obj:setTouchEnabled(false)
      widget.bottom.layout.obj:setTouchEnabled(true)
      widget.bottom.layout.obj:setVisible(true)
      widget.bottom.layout.text.obj:setText("开奖中，请稍后...")
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
      if data.type == 100 then
         for k,v in pairs(data.info) do
             if v.id == arr[i] then
                hasBet = true
                break
             end
         end
      end
      widget.bottom.bet_bg["bet_"..i].layout.obj:setVisible(hasBet)
      widget.bottom.bet_bg["bet_"..i].layout.obj:setTouchEnabled(hasBet)
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
          onGameUserActionSucceed(v.id,v.money)
      end
   end
   -- refrendeshBetTotal()
end

function initCostView()
   widget.bottom.bet_gold.obj:setTouchEnabled(false)
   widget.bottom.bet_layout.obj:setTouchEnabled(false)
   widget.bottom.bet_gold.num.obj:setText(singleArr[singleIndex])
   widget.bottom.bet_layout.bg.obj:setPosition(ccp(0,max_list_y))
   local pushOrPullfunc = function()
      local posY = widget.bottom.bet_layout.bg.obj:getPositionY()
      if posY == max_list_y then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.bottom.bet_layout.bg.obj)
      elseif posY == 0 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.bottom.bet_layout.bg.obj)
      end
   end       -- widget.bottom.bet_gold.obj:registerEventScript(function(event)
   --        if event == "releaseUp" then
   --           tool.buttonSound("releaseUp","effect_12")
   --           pushOrPullfunc()
   --        end
   -- end)
   -- for i = 1, 4 do 
   --    widget.bottom.bet_layout.bg["label_"..i].obj:setTouchEnabled(true)
   --    widget.bottom.bet_layout.bg["label_"..i].obj:registerEventScript(function(event)
   --        if event == "releaseUp" then
   --           tool.buttonSound("releaseUp","effect_12")
   --           singleIndex = i
   --           userdata.lastFishSingleIndex = singleIndex
   --           saveSetting("fishIndex",singleIndex)
   --           widget.bottom.bet_gold.num.obj:setText(singleArr[singleIndex])
   --           pushOrPullfunc()
   --        end
   --     end)
   -- end

   changeTouchEnabled(true)
end

function initResult()
   widget.result.obj:setVisible(false)
   widget.result.star_l.obj:setScale(0)  
   widget.result.star_r.obj:setScale(0) 
   widget.result.number.obj:setScale(0)
   widget.result.cheng.obj:setScale(0)
   widget.result.icon.obj:setScale(0)   
   resultLight = CCSprite:create("cash/qietu/effect/guang.png")
   resultLight:setPosition(ccp(300,300))
   resultLight:setScale(2.0)
   armatureBlend(resultLight)
   widget.result.obj:addNode(resultLight)
   resultLight:setVisible(false)
   for i=1,starNum do 
       local star = tool.findChild(widget.result.obj,"star_"..i,"ImageView")
       if star then
          starAction(star)
       end
   end
end

function doResultAni(id)
   local fishTmp = nil
   for k,v in pairs(fishList) do
       if v.id == id then
          fishTmp = v
       end
   end
   if not fishTmp then
      return
   end
   AudioEngine.playEffect("effect_05")
   widget.result.number.obj:setStringValue(fishTmp.multi)
   if fishTmp.multi < 10 then
      widget.result.cheng.obj:setPositionX(305)
      widget.result.number.obj:setPositionX(305)
   elseif fishTmp.multi < 100 then
      widget.result.cheng.obj:setPositionX(290)
      widget.result.number.obj:setPositionX(280)
   else
      widget.result.cheng.obj:setPositionX(255)
      widget.result.number.obj:setPositionX(245)
   end
   widget.result.icon.obj:loadTexture("cash/qietu/fish1/fish_"..fishTmp.res..".png")
   widget.result.obj:setVisible(true)
   tool.createEnterEffect(widget.result.obj,{x=0,y=-1000,easeOut=true},0.3,function()
      for i=1,starNum do 
          local star = tool.findChild(widget.result.obj,"star_"..i,"ImageView")
          if star then
             star:setVisible(true)
          end
      end  
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=1.5},widget.result.star_l.obj) 
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=1.5},widget.result.star_r.obj) 
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=2.0},widget.result.number.obj) 
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=1.3},widget.result.cheng.obj) 
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=2.0},widget.result.icon.obj,function()
         resultLight:setVisible(true)
         local action = CCRotateBy:create(0.5,60)
         action = CCRepeatForever:create(action)
         resultLight:runAction(action)
         tool.createEffect(tool.Effect.delay,{time=2},widget.result.icon.obj,function()
            tool.createEffect(tool.Effect.scale,{time=0.1,scale=0},widget.result.star_l.obj) 
            tool.createEffect(tool.Effect.scale,{time=0.1,scale=0},widget.result.star_r.obj) 
            tool.createEffect(tool.Effect.scale,{time=0.1,scale=0},widget.result.number.obj) 
            tool.createEffect(tool.Effect.scale,{time=0.1,scale=0},widget.result.cheng.obj) 
            tool.createEffect(tool.Effect.scale,{time=0.1,scale=0},widget.result.icon.obj,function()
               tool.createEffect(tool.Effect.delay,{time=0.2},widget.result.icon.obj,function() 
                  for i=1,starNum do 
                      local star = tool.findChild(widget.result.obj,"star_"..i,"ImageView")
                      if star then
                         star:setVisible(false)
                      end
                  end               
                  resultLight:stopAllActions()
                  resultLight:setVisible(false)
                  tool.createEffect(tool.Effect.fadeOut,{time=0.15},widget.result.obj)
                  tool.createExitEffect(widget.result.obj,{x=0,y=-300,easeOut=true},0.15,true,function()
                     widget.result.obj:setVisible(false)
                     widget.result.obj:setOpacity(255)
                     -- if isBig == true then
                     --    showBigAward()
                     -- end
                     startFishTimer()
                  end)
               end)
            end)
         end)
      end)    
   end)
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
      widget.fish["panel_"..name.."_"..st].light.obj:setVisible(true)
      -- widget.fish["panel_"..name.."_"..st].light.obj:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay}, widget.fish["panel_"..name.."_"..st].light.obj,
                        function()
                           -- widget.fish["panel_"..name.."_"..st].light.obj:setOpacity(255)
                           widget.fish["panel_"..name.."_"..st].light.obj:stopAllActions()

                           local _st = st
                           if data.type == 201 then
                              local resultCnt = name == "inside" and data.GameResult.f[2] or data.GameResult.f[1]
                              local totalCnt = name == "inside" and maxNum + resultCnt - lastOpenId[name] + 12 or maxNum + resultCnt - lastOpenId[name]
                              local _id = name == "inside" and st + 12 or st
                              print("201!!!!!!!!!!!!!!!!!!!!!",totalCnt,cnt,st,resultCnt,_id)
                              delay = 0.4
                              if fishList[_id].id == resultCnt then
                                 print("end ",_id,resultCnt,fishList[_id].id,fishList[_id].name)
                                 resultName[name] = fishList[_id].name
                                 finishCircleCnt = finishCircleCnt + 1
                                 if finishCircleCnt == 2 then
                                    endEffect() 
                                 end 
                                 return
                              end
                              cnt = cnt + 1
                           end
                           st = st + 1
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
   AudioEngine.playEffect("effect_02")
   -- for i = 1, 12 do
   --    if i ~= lastOpenId.outside then
   --       widget.fish["panel_outside_"..i].light.obj:setVisible(false)
   --    end
   -- end
   endFishTimer()
   isPlaying = true
   changeTouchEnabled(false)

   playCircle(6, "inside")
   playCircle(12, "outside")
end

function endEffect()
   userdata.isInGame = false
   for i=1,12 do
       if data.GameResult.f[1] == fishList[i].id then
          lastOpenId.outside = i
       end
   end
   lastOpenId.inside = data.GameResult.f[2] - 12
   widget.fish["panel_outside_"..lastOpenId.outside].light.obj:setVisible(false)
   widget.fish["panel_inside_"..lastOpenId.inside].light.obj:setVisible(false)
   isPlaying = false
   winGold = 0
   finishCircleCnt = 0
   for k,v in pairs(isBet) do
       v.bool = false
       widget.bottom.bet_bg["bet_"..v.id].layout.obj:setVisible(false)
       widget.bottom.bet_bg["bet_"..v.id].layout.obj:setTouchEnabled(false)
   end
   for i=1,#singleArr do
       if widget.bottom["btn_"..i].obj then
          widget.bottom["btn_"..i].obj:setTouchEnabled(true)
          widget.bottom["btn_"..i].obj:setColor(ccc3(0,0,0))
       end
   end
   checkWinResult()
   if fishList[lastOpenId.outside].id >= 1 and fishList[lastOpenId.outside].id <= 6 then
      doResultAni(fishList[lastOpenId.outside].id)
   else
      startFishTimer() 
   end 
   commonTop.registerEvent()

   betOwn = {}
   
   widget.bottom.layout.obj:setTouchEnabled(true)
   widget.bottom.layout.obj:setVisible(true)
end

function checkWinResult()
   if data.type == 201 then
      local message = {}
      message.type = 0
      message.cnt = data.GameResult.c
      message.outside = resultName["outside"]
      message.inside = resultName["inside"]
      chat.addSystemMessage(message)
      chat.setMessage(message,1) 
      chat.setMessage(message,3) 
      if data.GameResult.u and #data.GameResult.u > 0 then
         local isInResult = false
         for k,v in pairs(data.GameResult.u) do
             local resultMsg = {}
             if v.i == userdata.UserInfo.uidx then
                isInResult = true
                if v.m > 0 then
                   widget.bottom.layout.text.obj:setText("恭喜您中奖了")
                end
             else
             end
             resultMsg.type = 1
             resultMsg.name = v.i == userdata.UserInfo.uidx and "你" or v.e
             resultMsg.time = os.date("*t",tonumber(os.time()))
             resultMsg.id = v.i
             resultMsg.msg = getWinStr(v.m)
             chat.setMessage(resultMsg,1) 
             chat.setMessage(resultMsg,3)           
         end
         if not isInResult and isDoBet then
            widget.bottom.layout.text.obj:setText("很遗憾您没有中奖！") 
         end
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
   chatView:setPosition(ccp(0,-970))
end

function startFishTimer()
   if fishTimer == nil then
      if isRepeat then
         isRepeat = false
      end
      fishTimer = schedule(
         function()
            if data.type == 100 then
               betEndTime = betEndTime - 1
               local str = string.format("%02d", betEndTime)
               widget.fish.cd_bg.cd.obj:setText(str)  
               if betEndTime < 5 then
                  widget.fish.cd_bg.cd.obj:setColor(ccc3(255,0,0))
                  tool.createEffect(tool.Effect.blink,{time=0.5,f=1},widget.fish.cd_bg.cd.obj)
               end
               changeTouchEnabled(betEndTime > 0 and true or false)
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
   -- widget.bottom.bet_gold.obj:setBright(flag)
   -- widget.bottom.bet_gold.obj:setTouchEnabled(flag)
   if not isRepeat then
      widget.bottom.rebet.obj:setBright(flag)
      widget.bottom.rebet.obj:setTouchEnabled(flag)
   end
   -- if flag == false then
   --    local posY = widget.bottom.bet_layout.bg.obj:getPositionY()
   --    if posY == 0 then
   --       widget.bottom.bet_layout.obj:setTouchEnabled(false)
   --       tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeOut=true},widget.bottom.bet_layout.bg.obj)
   --    end
   -- end
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
   -- if not isBet[id] then
   --    isBet[id] = true
   -- end
   -- -- local _needGiftGold = userdata.UserInfo.giftGold < needGold and userdata.UserInfo.giftGold or needGold 
   -- -- local _needGold = needGold - _needGiftGold
   -- -- totalCashGold = totalCashGold + _needGold + _needGiftGold

   -- -- userdata.UserInfo.gold = userdata.UserInfo.gold - _needGold
   -- -- userdata.UserInfo.giftGold = userdata.UserInfo.giftGold - _needGiftGold

   -- userdata.UserInfo.owncash = userdata,UserInfo.owncash - needGold

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

function onExchange(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(18001)
      exchange.create(this)
   end
end

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
      totalCashGold = 0
      lastUserGold = 0
      historyUserGold = {}
      max_list_y = -350
      isDoBet = false
      currentUserPage = 0
      totalUserNum = 0
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(7001,1)
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
   saveSetting("fishType",str)
   userdata.lastFishSingleType = str
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
          layout = {_type = "Layout"},
        },
        bet_2 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          layout = {_type = "Layout"},
        },
        bet_3 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          layout = {_type = "Layout"},
        },
        bet_4 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          layout = {_type = "Layout"},
        },
        bet_5 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          layout = {_type = "Layout"},
        },
        bet_6 = {
          _type = "ImageView",
          image = {_type = "ImageView"},
          num = {_type = "Label"},
          layout = {_type = "Layout"},
        },
      },
      layout = {
        _type = "Layout",
        text = {_type = "Label"},  
      },
      bet_gold = {
        _type = "Button",_func=onPoint,
        num = {_type = "Label"},
        point = {_type = "ImageView"},
      },
      rebet = {_type = "Button",_func=onRepeatBet},
      bet_layout = {
        _type = "Layout",
        bg = {
          _type = "Layout",
          label_1 = {_type = "Label",line={_type = "ImageView"}},
          label_2 = {_type = "Label",line={_type = "ImageView"}},
          label_3 = {_type = "Label",line={_type = "ImageView"}},
          label_4 = {_type = "Label"},
        },
      },
      btn_1 = {
        _type = "Layout",
        text = {_type = "Label"},
      },
      btn_2 = {
        _type = "Layout",
        text = {_type = "Label"},
      },
      btn_3 = {
        _type = "Layout",
        text = {_type = "Label"},
      },
      btn_4 = {
        _type = "Layout",
        text = {_type = "Label"},
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
      exchange = {
        _type = "Button",
        _func = onExchange,
        text = {_type = "Label"},
        text_shadow = {_type = "Label"},
      },
   },
   result = {
      _type = "Layout",
      star_l = {_type = "ImageView"},
      star_r = {_type = "ImageView"},
      pai = {_type = "ImageView"},
      icon = {_type = "ImageView"},
      star_1 = {_type = "ImageView"},
      star_2 = {_type = "ImageView"},
      star_3 = {_type = "ImageView"},
      star_4 = {_type = "ImageView"},
      star_5 = {_type = "ImageView"},
      star_6 = {_type = "ImageView"},
      star_7 = {_type = "ImageView"},
      number = {_type = "LabelAtlas"},
      cheng = {_type = "ImageView"},
   },
}
                               
                               
                        
