local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local chat = require"scene.chat.main"
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require"logic.countLv"
local http = require"logic.http"

module("scene.fruitMachine.main", package.seeall)

this = nil
thisParent = nil
parentModule = nil
local data = {}
local historyList = {}
local historyAlertList = {}
local betList = {}
local slotList = {}
local fruitTimer = nil
local autoArr = {50,10,5}
local autoIndex = 1
local singleArr = {200,500,1000,5000,10000,50000,100000}
local singleIndex = 1
local betOwn = {}
local winGold = 0
local lastOpenId = 0
local isPlaying = false
local historyBet = {}
local autoCnt = 0
local chatView = nil
local lightDelay = 1
local cdEffectPlaying = false
local starNum = 7
local resultLight = nil
local bigList = {}
local isBig = false
local eventHash = {}
local longPressHandler = nil
local totalCashGold = 0
local lastUserGold = 0
local historyUserGold = {}
local isRepeat = false

function create(_parent,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   this = tool.loadWidget("cash/fruit_machine",widget, thisParent)
   commonTop.create(this,package.loaded["scene.fruitMachine.main"])
   AudioEngine.playMusic("bgm02.mp3",true)
   if userdata.lastFruitSingleIndex and userdata.lastFruitSingleIndex ~= 0 then
      singleIndex = userdata.lastFruitSingleIndex
   end
   if userdata.lastFruitSingleType ~= "" then
      local splitList = splitString(userdata.lastFruitSingleType,";")
      for k,v in pairs(splitList) do
          local list = splitString(v,",")
          historyBet[tonumber(list[1])] = tonumber(list[2])
      end
   end
   if userdata.userFruitHistoryGold and userdata.userFruitHistoryGold ~= "" then
      local splitList = splitString(userdata.userFruitHistoryGold,",")
      for k,v in pairs(splitList) do
          historyUserGold[k] = tonumber(v)
      end
   end
   initView()
   initResult()
   totalCashGold = 0
   lastUserGold = userdata.UserInfo.giftGold + userdata.UserInfo.gold
   bigList.id = 0
   bigList.name = ""
   bigList.exp = 0
   bigList.gold = 0
   widget.bigAward.obj:setVisible(false)
   widget.bigAward.obj:setScale(0)
   widget.historyAlert_layout.obj:setVisible(false)
   widget.historyAlert_layout.obj:setTouchEnabled(false)
   widget.historyAlert_layout.alert.back.obj:setTouchEnabled(false)
   event.listen("OPEN_CASH_ONE",onOpenCashOne)
   event.listen("OPEN_CASH",onOpenCash)
   event.listen("UPDATE_GAME_STATUS",onUpdateGameStatus)
   event.listen("GAME_USER_ACTION_SUCCEED", onGameUserActionSucceed)
   event.listen("GAME_USER_ACTION_FAILED", onGameUserActionFailed)
   event.listen("ON_CHANGE_GOLD", onChangeGold)
   event.listen("ON_BIG_WIN", onBigWin)
   -- setCashGold(0)
   if userdata.isFirstGame==1 then
      widget.bottom_bg.alert.obj:setVisible(true)
      alertFunc(widget.bottom_bg.alert.obj)
   else
      widget.bottom_bg.alert.obj:setVisible(false)
   end
   local historyBtn = Button:create() 
   historyBtn:loadTextures("cash/qietu/tymb/historyBtn.png","cash/qietu/tymb/historyBtn.png","cash/qietu/tymb/historyBtn.png",0)
   historyBtn:setPosition(ccp(5 * 108 + 58,51))
   historyBtn:registerEventScript(showHistory)
   historyBtn:setScale(0.9)
   widget.layout.history_layout.obj:addChild(historyBtn)
   onChangeGold()
   return this
end

function initData(btnCountTrueInfo,btnCountFalseInfo,currentEndTime,clickEndTime,messageList,countDownTime,gameIntervalTime,history,lastBigTime,userAction,prizePool)
   -- setCashGold(0)
   data = {}
   data.btnCountTrueInfo = btnCountTrueInfo
   data.btnCountFalseInfo = btnCountFalseInfo
   data.currentEndTime = currentEndTime / 1000
   data.clickEndTime = clickEndTime / 1000
   data.messageList = messageList
   data.countDownTime = countDownTime / 1000
   data.gameIntervalTime = gameIntervalTime / 1000
   data.history = history
   data.userAction = userAction
   data.prizePool = prizePool
   -- printTable(data)
end

function resetShowChatHistory(flag) 
   commonTop.isShowChatHistory = flag
end

function initView() 
   local fx, fy = 0, 7
   local dic = {{1,0},{0,-1},{-1,0},{0,1}}
   local k = 1
   for i = 1, #template["classic"] do     
      local classicTmp = template["classic"][i]
      if classicTmp.gameId == 1 then
         local x, y = fx + dic[k][1], fy + dic[k][2]
         fx, fy = x, y
         if (dic[k][1] == 1 and fx >= 7) or (dic[k][1] == -1 and fx <= 1) or 
         (dic[k][2] == 1 and fy >= 7) or (dic[k][2] == -1 and fy <= 1) then
            k = k + 1
         end        
         
         local typeTmp = template["classicType"][classicTmp.type]
         local slot = {obj = tolua.cast(widget.slot_render.obj:clone(),"ImageView")}
         slot.select_img = tool.findChild(slot.obj, "select_img", "ImageView")
         slot.img = tool.findChild(slot.obj, "img", "ImageView")
         slot.num_atlas = tool.findChild(slot.obj, "num_atlas", "LabelAtlas")
         slot.select_img:setVisible(false)
         slot.img:loadTexture("fruitMachine/shuiguo"..typeTmp.res..".png")
         if classicTmp.showMulti ~= "" then
            slot.img:setScale(0.7)
            local pos = tool.getPosition(slot.img)
            tool.setPosition(slot.img,pos,{x=0,y=20})
            slot.num_atlas:setStringValue(classicTmp.multi)
         else 
            slot.num_atlas:setVisible(false)
         end
         
         local posX = (x - 1) * 132 + 68
         local posY = (y - 1) * 132 + 68
         widget.layout.obj:addChild(slot.obj)
         slot.obj:setPosition(ccp(posX,posY))
         
         table.insert(slotList, slot)
      end
   end
   
   refreshHistory()
   
   initChatView()
   initCostView()
   widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
   widget.bottom_bg.auto_layout.obj:setVisible(false)
   widget.bottom_bg.auto_layout.obj:registerEventScript(function(event)
                                                           if event == "releaseUp" then
                                                              tool.buttonSound("releaseUp","effect_12")
                                                              autoCnt = 0
                                                              widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
                                                              widget.bottom_bg.auto_layout.obj:setVisible(false)
                                                              if isPlaying == false and cdEffectPlaying == false then
                                                                 widget.bottom_bg.auto_btn.obj:setTouchEnabled(true)
                                                                 widget.bottom_bg.auto_btn.obj:setBright(true)
                                                              end
                                                           end
                                                        end)

   widget.cd_img.obj:setVisible(false)
   local light = CCSprite:create("cash/qietu/effect/guang.png")
   light:setPosition(ccp(20,70))
   light:setScale(0.3)
   armatureBlend(light)
   widget.cd_img.obj:addNode(light)
   local action = CCRotateBy:create(0.5,60)
   action = CCRepeatForever:create(action)
   light:runAction(action)

   widget.num_layout.win_atlas.obj:setStringValue(0)
   startFruitTimer()

   widget.bottom_bg.single_cost.obj:setText("单注"..singleArr[singleIndex])
   -- widget.bottom_bg.auto_cnt.obj:setText("跟注0轮")

   widget.bottom_bg.list.obj:setVisible(true)
   widget.bottom_bg.list.obj:setTouchEnabled(false)
   widget.bottom_bg.list.obj:setItemModel(widget.bet_render.obj)
   widget.bottom_bg.list.obj:removeAllItems()
   local cnt = 0
   for i = 8, 1, -1 do
      local typeTmp = template["classicType"][i]
      
      widget.bottom_bg.list.obj:pushBackDefaultItem()
      local v = {obj = tolua.cast(widget.bottom_bg.list.obj:getItem(cnt),"Layout"), index = i}
      v.btn_tmp1 = tool.findChild(v.obj, "btn_tmp1", "Button")
      v.btn_tmp2 = tool.findChild(v.obj, "btn_tmp2", "Button")
      v.img = tool.findChild(v.obj, "img", "ImageView")
      v.num_atlas = tool.findChild(v.obj, "num_atlas", "LabelAtlas")
      v.my_num = tool.findChild(v.obj, "my_num", "Label")
      v.total_num = tool.findChild(v.obj, "total_num", "Label")
      
      v.btn_tmp1:setVisible(false)
      v.btn_tmp1:setTouchEnabled(false)
      v.btn_tmp2:setVisible(false)
      v.btn_tmp2:setTouchEnabled(false)
      if i % 2 == 0 then
         v.btn_tmp1:setVisible(true)
         v.btn_tmp1:setTouchEnabled(true)
      else 
         v.btn_tmp2:setVisible(true)
         v.btn_tmp2:setTouchEnabled(true)
      end
      local info = {cnt = i,index = singleIndex}
      local func = function(ev,data)
          local longPressFunc = function (info1,event1,data1)
             local time = 0
             if longPressHandler then
                unSchedule(longPressHandler)
                longPressHandler = nil
             end
             longPressHandler = schedule(function()
                time = time + 1
                if time%2 == 0 then
                   bet(info1.cnt, singleArr[info1.index])
                end
             end,1)
          end
          if ev == "releaseUp" then
             if longPressHandler then
                unSchedule(longPressHandler)
                longPressHandler = nil
             end
          end
          if tool.longPress(ev,data,info,longPressFunc) then
             return 
          end
         if ev == "releaseUp" then
            tool.buttonSound("releaseUp","effect_12")
            bet(i, singleArr[singleIndex])
         end
      end
      v.btn_tmp1:registerEventScript(func)
      v.btn_tmp2:registerEventScript(func)
      v.img:loadTexture("fruitMachine/shuiguo"..typeTmp.res..".png")
      v.num_atlas:setStringValue(typeTmp.multi)
      v.my_num:setText("0")
      v.total_num:setText("0")
      
      cnt = cnt + 1

      table.insert(betList, v)
   end
   
   for k, v in pairs(data.userAction) do
      onGameUserActionSucceed(v)
   end
   refreshBetTotal()

   playLightEffect()
end

function onBigWin(id,name,exp,gold)
   print("onBigWin",id,name,exp,gold)
   bigList.id = tonumber(id)
   bigList.name = name
   bigList.exp = exp
   bigList.gold = gold
   if isBig == false then
      isBig = true
   end
end

function showBigAward()
   if bigList.id == 0 then return end
   widget.bigAward.obj:setVisible(true)
   print("showBigAward",bigList.id)
   tool.loadRemoteImage(eventHash, widget.bigAward.head.obj, bigList.id)
   widget.bigAward.name.obj:setText(bigList.name)
   local vipLv = countLv.getVipLv(bigList.exp)
   widget.bigAward.vipNum.obj:setStringValue(vipLv)
   widget.bigAward.gold.obj:setText(math.floor(bigList.gold/10000).."万金币")
   tool.createEffect(tool.Effect.scale,{time=0.3,scale=1.2},widget.bigAward.obj,function()
      tool.createEffect(tool.Effect.scale,{time=0.2,scale=1.0},widget.bigAward.obj,function()
         tool.createEffect(tool.Effect.delay,{time=1.0},widget.bigAward.obj,function()
             tool.createEffect(tool.Effect.scale,{time=0.2,scale=0},widget.bigAward.obj,function()
                widget.bigAward.obj:setVisible(false)
                isBig = false
             end)
         end)
      end)
   end)
end

function initCostView()
   widget.bottom_bg.list_layout.bg.obj:setPosition(ccp(0,-250))
   local pushOrPullfunc = function()
      local posY = widget.bottom_bg.list_layout.bg.obj:getPositionY()
      if posY == -250 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.bottom_bg.list_layout.bg.obj)
      elseif posY == 0 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=-250,easeIn=true},widget.bottom_bg.list_layout.bg.obj)
      end
   end
   for i = 1, 3 do 
      widget.bottom_bg.list_layout.bg["label"..i].obj:setTouchEnabled(true)
      widget.bottom_bg.list_layout.bg["label"..i].obj:registerEventScript(function(event)
          if event == "releaseUp" then
             tool.buttonSound("releaseUp","effect_12")
             autoIndex = i
             widget.bottom_bg.autoCnt_layout.auto_cnt.obj:setText("跟注"..autoArr[autoIndex].."轮")
             pushOrPullfunc()
          end
       end
      )
   end
   widget.bottom_bg.autoCnt_layout.obj:setTouchEnabled(true)
   widget.bottom_bg.autoCnt_layout.obj:registerEventScript(
      function(event)
         if event == "releaseUp" then
            tool.buttonSound("releaseUp","effect_12")
            pushOrPullfunc()
         end
      end
   )
   
   local now = getSyncedTime()
   local time = math.floor(data.clickEndTime - now)
   changeTouchEnabled(time > 0 and true or false)
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

function doResultAni()
   AudioEngine.playEffect("effect_05")
   local classicTmp = template["classic"][lastOpenId]
   if not classicTmp then
      classicTmp = template["classic"][1]
   end
   local typeTmp = template["classicType"][classicTmp.type]
   if not typeTmp then
      typeTmp = template["classicType"][1]
   end
   widget.result.icon.obj:loadTexture("fruitMachine/shuiguo"..typeTmp.res.."d.png")
   widget.result.obj:setVisible(true)
   widget.result.number.obj:setStringValue(classicTmp.multi)
   if classicTmp.multi < 10 then
      widget.result.cheng.obj:setPositionX(305)
      widget.result.number.obj:setPositionX(305)
   elseif classicTmp.multi < 100 then
      widget.result.cheng.obj:setPositionX(290)
      widget.result.number.obj:setPositionX(280)
   else
      widget.result.cheng.obj:setPositionX(255)
      widget.result.number.obj:setPositionX(245)
   end
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
      tool.createEffect(tool.Effect.scale,{time=0.1,scale=1.0},widget.result.icon.obj,function()
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
                     if isBig == true then
                        showBigAward()
                     end
                     startFruitTimer()
                  end)
               end)
            end)
         end)
      end)    
   end)
end

function initChatView()
   chatView = chat.create(data.messageList,660,555,0,package.loaded["scene.fruitMachine.main"])
   widget.layout.obj:addChild(chatView,2)
   chatView:setAnchorPoint(ccp(0,0))
   chatView:setPosition(ccp(136,238))
end

function startFruitTimer()
   if fruitTimer == nil then
      if isRepeat then
         isRepeat = false
      end
      fruitTimer = schedule(
         function()
            local now = getSyncedTime()
            local time = math.floor(data.clickEndTime - now)
            time = time > 0 and time or 0
            local str = string.format("%02d", time)
            widget.num_layout.time_atlas.obj:setStringValue(str)
            changeTouchEnabled(time > 0 and true or false)
              
            local cd = math.floor(data.currentEndTime - now)
            cd = cd > 0 and cd or 0
            if cd <= data.countDownTime and cd > 0 and cdEffectPlaying == false then
               if userdata.isInGame == false then
                  userdata.isInGame = true
               end
               playCdAtlasEffect(cd)
            end
         end,1
      )
   end
   setPrizePoll(data.prizePool)
   --http.request(payServerUrl.."/ydream/login?type=501",onGetPrizepool)
end

function onGetPrizepool(header,body)
   print("onGetPrizepool",body)
   local tab = cjson.decode(body)
   printTable(tab)
   print("money:!!!!!!!!!!!!!!!!!!!!!!!!",tab.money/10000)
   widget.bottom_bg.num.obj:setStringValue(tab.money/10000)
end

function setPrizePoll(num)
   if not this or num == nil then
      return 
   end
   local panel = widget.bottom_bg.panel_jiangjin
   local panelSize = panel.obj:getSize()
   if num >= 100000 then
      panel.num.obj:setStringValue(math.floor(num/10000+0.5))
      panel.wenzi_2.obj:setVisible(true)
      panel.obj:setSize(CCSize(panel.wenzi_1.obj:getSize().width+panel.num.obj:getSize().width+panel.wenzi_2.obj:getSize().width,panelSize.height))
   else
      panel.num.obj:setStringValue(num)
      panel.wenzi_2.obj:setVisible(false)
      panel.obj:setSize(CCSize(panel.wenzi_1.obj:getSize().width+panel.num.obj:getSize().width,panelSize.height))
   end
   panel.obj:setPositionX(-panel.obj:getSize().width/2)
end

function setCashGold(num)
   print("setCashGold",num)
   if not this or num == nil then
      return 
   end
   local panel = widget.bottom_bg.panel_zonger
   local panelSize = panel.obj:getSize()
   if num >= 100000 then
      panel.num.obj:setStringValue(math.floor(num/10000+0.5))
      panel.wenzi_2.obj:setVisible(true)
      panel.obj:setSize(CCSize(panel.wenzi_1.obj:getSize().width+panel.num.obj:getSize().width+panel.wenzi_2.obj:getSize().width,panelSize.height))
   else
      panel.num.obj:setStringValue(num)
      panel.wenzi_2.obj:setVisible(false)
      panel.obj:setSize(CCSize(panel.wenzi_1.obj:getSize().width+panel.num.obj:getSize().width,panelSize.height))
   end
   panel.obj:setPositionX(-panel.obj:getSize().width/2)
end

function endFruitTimer()
   if fruitTimer then
      unSchedule(fruitTimer)
      fruitTimer = nil
   end
end

function changeTouchEnabled(flag)
   if not isRepeat then
      widget.bottom_bg.repeat_btn.obj:setBright(flag)
      widget.bottom_bg.repeat_btn.obj:setTouchEnabled(flag)
   end
   if autoCnt > 0 then
      widget.bottom_bg.auto_btn.obj:setBright(false)
      widget.bottom_bg.auto_btn.obj:setTouchEnabled(false)
   else
      widget.bottom_bg.auto_btn.obj:setBright(flag)
      widget.bottom_bg.auto_btn.obj:setTouchEnabled(flag)
   end
   widget.bottom_bg.change_btn.obj:setBright(flag)
   widget.bottom_bg.change_btn.obj:setTouchEnabled(flag)
   widget.bottom_bg.autoCnt_layout.obj:setTouchEnabled(flag)
   
   if flag == false then
      local posY = widget.bottom_bg.list_layout.bg.obj:getPositionY()
      if posY == 0 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=-250,easeIn=true},widget.bottom_bg.list_layout.bg.obj)
      end
   end
   
   for k, v in pairs(betList) do
      if v.index % 2 == 0 then
         v.btn_tmp1:setBright(flag)
         v.btn_tmp1:setTouchEnabled(flag)
      else 
         v.btn_tmp2:setBright(flag)
         v.btn_tmp2:setTouchEnabled(flag)
      end
   end
   if flag == false then
      if longPressHandler then
         unSchedule(longPressHandler)
         longPressHandler = nil
      end
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
   -- if cd == 1 then
   --    widget.cd_img.light.obj:setPositionX(10)
   -- else
   --    widget.cd_img.light.obj:setPositionX(30)
   -- end
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
      slotList[st].select_img:setVisible(true)
      slotList[st].select_img:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay},slotList[st].select_img,
                        function()
                           slotList[st].select_img:setOpacity(255)
                           if st == ed then
                              tool.createEffect(tool.Effect.blink,{time=0.3,f=3},slotList[st].select_img,
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
                              tool.createEffect(tool.Effect.fadeOut,{time=0.2},slotList[_st].select_img,
                                                function()
                                                   slotList[_st].select_img:setVisible(false)
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

function checkMultiFruit(id, callback)
   local classicTmp = template["classic"][id]
   local arr = splitString(classicTmp.multiEffect, ",")
   table.insert(arr,1,id)
   if classicTmp.multiEffect ~= "" then
      multiEffect(1, arr, callback)
   else 
      callback()
   end
end

function playFruitEffect(id)  
   endFruitTimer()
   isPlaying = true
   AudioEngine.playEffect("effect_02")
   local st = lastOpenId 
   local delay = 0
   if slotList[st] ~= nil then
      slotList[st].select_img:setVisible(false)
   end
   st = st >= 24 and 1 or st + 1
   local totalCnt = 24*3 - lastOpenId + id
   local totalDelay = 0
   local c1,c2 = totalCnt*totalCnt/4, totalCnt*totalCnt*3/4
   for i = 1, totalCnt-1 do
      if i < 5 or i > totalCnt - 5 then
         totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c1
      else 
         totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c2
      end
   end
   local per = 4/totalDelay

   local func = nil
   local cnt = 0
   func = function()
      slotList[st].select_img:setVisible(true)
      slotList[st].select_img:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay},slotList[st].select_img,
                        function()
                           --AudioEngine.playEffect("effect_12")
                           slotList[st].select_img:setOpacity(255)

                           if st == id and cnt == totalCnt - 1 then
                              tool.createEffect(tool.Effect.blink,{time=0.5,f=3},slotList[st].select_img,
                                                function()
                                                   local numFunc = function()
                                                      if winGold > 0 then
                                                         local gold = userdata.UserInfo.gold+userdata.UserInfo.giftGold
                                                         tool.numEffectWithObj(widget.num_layout.total_atlas.obj,gold-winGold,gold,2,0)
                                                         tool.numEffectWithObj(widget.num_layout.win_atlas.obj,winGold,0,2,0,
                                                                               function()
                                                                                  endEffect(id)
                                                                               end
                                                         )                                                      
                                                      else 
                                                         endEffect(id)
                                                      end
                                                   end
                                                   checkMultiFruit(id, numFunc)
                                                end
                              )
                              return
                           end

                           local _st = st                                                     
                           st = st + 1
                           if st == 25 then
                              st = 1
                           end
                           cnt = cnt + 1
                           local x = cnt
                           if x < 5 or x > totalCnt - 5 then
                              delay = (x-totalCnt/2)*(x-totalCnt/2)/c1*per
                           else 
                              delay = (x-totalCnt/2)*(x-totalCnt/2)/c2*per
                           end
                           lightDelay = delay
                           tool.createEffect(tool.Effect.fadeOut,{time=delay-0.1 > 0.1 and delay-0.1 or 0.1},slotList[_st].select_img,
                                             function()
                                                slotList[_st].select_img:setVisible(false)
                                                
                                             end
                           )
                           
                           func()
                        end
      )
   end
   func()
end

function endEffect(id)
   userdata.isInGame = false
   lastOpenId = id
   isPlaying = false
   winGold = 0
   lightDelay = 1

   doResultAni()
   -- startFruitTimer()

   event.listen("ON_CHANGE_GOLD", onChangeGold)
   commonTop.registerEvent()
   onChangeGold()
   
   data.history[6] = nil
   table.insert(data.history,1,id)
   refreshHistory()
   
   betOwn = {}
   refreshBetOwn()
   
   if autoCnt > 0 then
      autoCnt = autoCnt - 1
      onRepeatBet("releaseUp")
   else
      widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
      widget.bottom_bg.auto_layout.obj:setVisible(false)
   end
   widget.bottom_bg.auto_layout.label.obj:setText("跟注"..autoCnt.."轮 点击取消")
end

function playLightEffect()
   local func = nil
   func = function(obj,dir)
      tool.createEffect(tool.Effect.delay, {time = lightDelay}, obj, 
                        function()
                           local y = obj:getPositionY()
                           local fy = y+dir*49
                           obj:setPositionY(fy)
                           if fy >= 364 or fy <= -514 then
                              dir = -dir
                           end
                           func(obj,dir)
                        end
      )
   end
   func(widget.left_light.layout.obj,1)
   func(widget.right_light.layout.obj,1)
end

function showHistory(event)
    if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      widget.historyAlert_layout.obj:setVisible(true)
      widget.historyAlert_layout.obj:setTouchEnabled(true)
      widget.historyAlert_layout.alert.back.obj:setTouchEnabled(true)
      refreshHistoryAlert()
   end
end

function onAlertBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      widget.historyAlert_layout.obj:setVisible(false)
      widget.historyAlert_layout.obj:setTouchEnabled(false)
      widget.historyAlert_layout.alert.back.obj:setTouchEnabled(false)
   end
end

function refreshHistory()
   for k, v in pairs(historyList) do
      if v.obj then
         v.obj:removeFromParentAndCleanup(true)
      end
   end
   historyList = {}
   local historyLayoutSize = widget.layout.history_layout.obj:getSize()
   if data.history and type(data.history) == type({}) then
      for i = 1,#data.history do
         if i > 5 then break end
         local classicTmp = template["classic"][data.history[i]]
         local typeTmp = template["classicType"][classicTmp.type]

         local v = {obj = tolua.cast(widget.history_render.obj:clone(), "ImageView")}
         local img = tool.findChild(v.obj, "img", "ImageView")
         local num_atlas = tool.findChild(v.obj, "num_atlas", "LabelAtlas") 
         local new = tool.findChild(v.obj, "new", "ImageView")
         img:loadTexture("fruitMachine/shuiguo"..typeTmp.res..".png")
         img:setScale(0.8)
         if classicTmp.showMulti ~= "" then
            num_atlas:setStringValue(classicTmp.multi)
         else 
            num_atlas:setVisible(false)
         end
         new:setVisible(i == 1)
         local posX = (i - 1) * 108 + 58
         local posY = 51
         widget.layout.history_layout.obj:addChild(v.obj)
         v.obj:setPosition(ccp(posX,posY))
         
         table.insert(historyList, v)
      end
   end
end

function refreshHistoryAlert()
   for k, v in pairs(historyAlertList) do
      if v.obj then
         v.obj:removeFromParentAndCleanup(true)
      end
   end
   historyAlertList = {}
   local historyLayoutSize = widget.layout.history_layout.obj:getSize()
   if data.history and type(data.history) == type({}) then
      for i = 1,#data.history do
         if i > 5 then break end
         local classicTmp = template["classic"][data.history[i]]
         local typeTmp = template["classicType"][classicTmp.type]

         local v = {obj = tolua.cast(widget.history_render.obj:clone(), "ImageView")}
         local img = tool.findChild(v.obj, "img", "ImageView")
         local num_atlas = tool.findChild(v.obj, "num_atlas", "LabelAtlas") 
         local new = tool.findChild(v.obj, "new", "ImageView")
         img:loadTexture("fruitMachine/shuiguo"..typeTmp.res..".png")
         img:setScale(0.8)
         if classicTmp.showMulti ~= "" then
            num_atlas:setStringValue(classicTmp.multi)
         else 
            num_atlas:setVisible(false)
         end
         new:setVisible(i == 1)
         local posX = (i - 1) * 165 - 280
         local posY = 80
         widget.historyAlert_layout.alert.obj:addChild(v.obj)
         v.obj:setPosition(ccp(posX,posY))
         
         table.insert(historyAlertList, v)
      end
   end
   if #historyUserGold > 0 then
      widget.historyAlert_layout.alert.listView.obj:removeAllItems()
      local titleLabel = Label:create()
      titleLabel:setFontSize(40)
      titleLabel:setText("个人中奖纪录：")
      widget.historyAlert_layout.alert.listView.obj:pushBackCustomItem(titleLabel)
      local cnt = 1
      for i=1,#historyUserGold do
          local label = Label:create()
          label:setFontSize(40)
          label:setText(cnt.."."..historyUserGold[i].."  ")
          widget.historyAlert_layout.alert.listView.obj:pushBackCustomItem(label)
          cnt = cnt + 1
      end
   end
end

function numToStr(num)
   local str = ""
   local finalNum = 0
   if num >= 100000000000000000000 then
      finalNum = math.floor(num/100000000000000000000+0.5)
      str = finalNum.."万亿亿"
   elseif num >= 10000000000000000000 then
      finalNum = math.floor(num/10000000000000000000+0.5)
      str = finalNum.."千亿亿"
   elseif num >= 1000000000000000000 then
      finalNum = math.floor(num/1000000000000000000+0.5)
      str = finalNum.."百亿亿"
   elseif num >= 10000000000000000 then
      finalNum = math.floor(num/10000000000000000+0.5)
      str = finalNum.."亿亿"
   elseif num >= 1000000000000000 then
      finalNum = math.floor(num/1000000000000000+0.5)
      str = finalNum.."千万亿"
   elseif num >= 1000000000000 then
      finalNum = math.floor(num/1000000000000+0.5)
      str = finalNum.."万亿"
   elseif num >= 100000000 then
      finalNum = math.floor(num/100000000*10+0.5)/10
      str = finalNum.."亿"
   elseif num >= 10000 then
      if num >= 10000000 then
         finalNum = math.floor(num/10000+0.5)
      else
         finalNum = math.floor(num/10000*10+0.5)/10
      end
      str = finalNum.."万"
   else 
      str = num..""
   end
   return str
end

function refreshBetTotal()
   if isPlaying == true then 
      return
   end
   local totalNum = 0
   for k, v in pairs(betList) do
      local trueNum = data.btnCountTrueInfo[v.index]
      local falseNum = data.btnCountFalseInfo[v.index]
      local num = 0
      if trueNum == nil then
         trueNum = data.btnCountTrueInfo[v.index..""]
      end
      if falseNum == nil then
         falseNum = data.btnCountFalseInfo[v.index..""]
      end
      num = trueNum
      if not userdata.UserInfo.isGM then
         num = num + falseNum
      end
      totalNum = totalNum + num
      v.total_num:setText(numToStr(num))
   end
   setCashGold(totalNum)
end

function refreshBetOwn()
   for k, v in pairs(betList) do
      if betOwn[v.index] ~= nil then
         v.my_num:setText(numToStr(betOwn[v.index]))
      else 
         v.my_num:setText("0")
      end
   end
end

function onChangeGold()
   local gold = userdata.UserInfo.gold+userdata.UserInfo.giftGold
   widget.num_layout.total_atlas.obj:setStringValue(gold)
end

function onEnter()
   
end

function onExit()

end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end

function exit()
   if this then
      event.unListen("OPEN_CASH_ONE",onOpenCashOne)
      event.unListen("OPEN_CASH",onOpenCash)
      event.unListen("UPDATE_GAME_STATUS",onUpdateGameStatus)
      event.unListen("GAME_USER_ACTION_SUCCEED", onGameUserActionSucceed)
      event.unListen("GAME_USER_ACTION_FAILED", onGameUserActionFailed)
      event.unListen("ON_CHANGE_GOLD", onChangeGold)
      event.unListen("ON_BIG_WIN", onBigWin)
      AudioEngine.stopMusic(true)
      AudioEngine.stopAllEffects()
      AudioEngine.playMusic("bgm01.mp3",true)
      if chatView then
         chat.exit()
         chatView = nil
      end
      if commonTop then
         commonTop.exit()
      end
      if longPressHandler then
         unSchedule(longPressHandler)
         longPressHandler = nil
      end
      if parentModule and parentModule.initTop then
         parentModule.initTop()
      end
      cleanEvent()
      this:removeFromParentAndCleanup(true)
      this = nil
      thisParent = nil
      parentModule = nil
      tool.cleanWidgetRef(widget)
      data = nil
      historyList = {}
      historyAlertList = {}
      betList = {}
      slotList = {}
      endFruitTimer()
      singleIndex = 1
      autoIndex = 1
      betOwn = {}
      winGold = 0
      lastOpenId = 0
      isPlaying = false
      historyBet = {}
      data = {}
      autoCnt = 0
      lightDelay = 1
      cdEffectPlaying = false
      isRepeat = false
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call("leaveGame")
      -- local mainScene = package.loaded["scene.main"]
      -- mainScene.createSubWidget(nil)
   end
end

function onChangeSingleCost(event1)
   if event1 == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      singleIndex = singleIndex + 1
      singleIndex = singleIndex > #singleArr and 1 or singleIndex
      print("onChangeSingleCost0",userdata.UserInfo.vipExp)
      local vipLv = 0
      local maxSingleGold = 50000
      if countLv.getVipLv(userdata.UserInfo.vipExp) then
         vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
      end
      if template['vipExp'][vipLv] then
         maxSingleGold = template['vipExp'][vipLv].betLimit * 10000
      end
      print("onChangeSingleCost2",maxSingleGold,vipLv)
      if singleArr[singleIndex] > maxSingleGold then
         singleIndex = 1
      end
      widget.bottom_bg.single_cost.obj:setText("单注"..singleArr[singleIndex])
      userdata.lastFruitSingleIndex = singleIndex
      saveSetting("fruitIndex",singleIndex)
   end
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
      widget.bottom_bg.repeat_btn.obj:setBright(false)
      widget.bottom_bg.repeat_btn.obj:setTouchEnabled(false)
   end
end

function bet(id, needGold)
   if userdata.UserInfo.giftGold + userdata.UserInfo.gold < needGold then
      alert.create("余额不足！")
      return
   end
   local _needGiftGold = userdata.UserInfo.giftGold < needGold and userdata.UserInfo.giftGold or needGold 
   local _needGold = needGold - _needGiftGold
   totalCashGold = totalCashGold + _needGold + _needGiftGold

   userdata.UserInfo.gold = userdata.UserInfo.gold - _needGold
   userdata.UserInfo.giftGold = userdata.UserInfo.giftGold - _needGiftGold
   
   if userdata.isFirstGame == 1 then
      userdata.isFirstGame = 0
      saveSetting("isFirstGame",userdata.isFirstGame)
      widget.bottom_bg.alert.obj:setVisible(false)
   end
   print("gold!!!!!!!!!!!!!!!!!!",_needGold,_needGiftGold,_needGold+_needGiftGold)
   call("userAction", id, _needGold, _needGiftGold)
end

function onAutoBet(event1)
   if event1 == "releaseUp" then
      -- printTable(historyBet)
      local i=0
      for k,v in pairs(historyBet) do
          i = i + 1
      end
      if i == 0 then
         alert.create("请先选择押注内容！")
      else
         tool.buttonSound("releaseUp","effect_12")
         autoCnt = autoCnt == 0 and autoArr[autoIndex] or 0
         if autoCnt > 0 then
            autoCnt = autoCnt - 1
            onRepeatBet("releaseUp")
         end
         widget.bottom_bg.auto_layout.label.obj:setText("跟注"..autoCnt.."轮 点击取消")
         widget.bottom_bg.auto_layout.obj:setVisible(true)
         widget.bottom_bg.auto_layout.obj:setTouchEnabled(true)
         widget.bottom_bg.auto_btn.obj:setTouchEnabled(false)
         widget.bottom_bg.auto_btn.obj:setBright(false)
      end
   end
end

local maxHistoryNum = 5
function onOpenCash(id, currentEndTime,clickEndTime,prizePool)
   if this == nil then
      return
   end
   if userdata.isInGame == false then
      userdata.isInGame = true
   end
   data.currentEndTime = currentEndTime / 1000
   data.clickEndTime = clickEndTime / 1000
   data.prizePool = prizePool

   if totalCashGold > 0 then
      local cashGold = userdata.UserInfo.giftGold + userdata.UserInfo.gold - lastUserGold
      if #historyUserGold == maxHistoryNum then
         historyUserGold[maxHistoryNum] = nil
      end 
      table.insert(historyUserGold,1,cashGold)
      local historyStr = ""
      for i=1,#historyUserGold do
          historyStr = historyStr..tostring(historyUserGold[i])..","
      end
      saveSetting("fruitHistoryGold",historyStr)
   end
   lastUserGold = userdata.UserInfo.giftGold + userdata.UserInfo.gold
   totalCashGold = 0
   playFruitEffect(id)
end

function onOpenCashOne(id,giftGoldGet,goldGet)
   if this == nil then
      return
   end
   winGold = giftGoldGet + goldGet
   event.unListen("ON_CHANGE_GOLD", onChangeGold)
   commonTop.unRegisterEvent()
end

function onUpdateGameStatus(currentEndTime, clickEndTime, btnCountTrueInfo, btnCountFalseInfo)
   if this == nil then
      return
   end
   data.currentEndTime = currentEndTime / 1000
   data.clickEndTime = clickEndTime / 1000
   data.btnCountTrueInfo = btnCountTrueInfo
   data.btnCountFalseInfo = btnCountFalseInfo
   refreshBetTotal()
end

function onGameUserActionSucceed(_data)
   if this == nil then
      return
   end
   -- printTable(_data)
   if betOwn[_data.btnId] == nil then
      betOwn[_data.btnId] = 0
   end
   betOwn[_data.btnId] = betOwn[_data.btnId] + _data.gold + _data.giftGold
   historyBet = cloneTable(betOwn)
   -- print("onGameUserActionSucceed")
   -- printTable(historyBet)
   local str = ""
   for k,v in pairs(historyBet) do
       str = str..k..","..v..";"
   end
   saveSetting("fruitType",str)
   userdata.lastFruitSingleType = str
   refreshBetOwn()
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
   bottom_bg = {
      _type = "ImageView",
      change_btn = {_type = "Button", _func = onChangeSingleCost},
      repeat_btn = {_type = "Button", _func = onRepeatBet},
      auto_btn = {_type = "Button", _func = onAutoBet},
      single_cost = {_type = "Label"},
      autoCnt_layout = {
         _type = "Layout",
         auto_cnt = {_type = "Label"},
         triangle = {_type = "ImageView"},
      },
      auto_layout = {
         _type = "Layout",
         label = {_type = "Label"}
      },
      list = {_type = "ListView"},    
      list_layout = {
         _type = "Layout",
          bg = {_type = "ImageView",
                       label1 = {_type = "Label"},
                       label2 = {_type = "Label"},
                       label3 = {_type = "Label"},
          },
      },
      alert = {_type = "ImageView",
          image = {_type = "ImageView"},
      },
      panel_jiangjin = {
          _type = "Layout",
          wenzi_1 = {_type = "ImageView"},
          num = {_type = "LabelAtlas"},
          wenzi_2 = {_type = "ImageView"},
      },
      panel_zonger = {
          _type = "Layout",
          wenzi_1 = {_type = "ImageView"},
          num = {_type = "LabelAtlas"},
          wenzi_2 = {_type = "ImageView"},
      },
   },
   layout = {
      _type = "Layout",
      history_layout = {_type = "Layout"},
   },
   num_layout = {
      _type = "Layout",
      time_atlas = {_type = "LabelAtlas"},
      win_atlas = {_type = "LabelAtlas"},
      total_atlas = {_type = "LabelAtlas"},
   },
   cd_atlas = {_type = "LabelAtlas"},
   bet_render = {
      _type = "Layout",
      btn_tmp1 = {_type = "Button"},
      btn_tmp2 = {_type = "Button"},
      img = {_type = "ImageView"},
      num_atlas = {_type = "LabelAtlas"},
      my_num = {_type = "Label"},
      total_num = {_type = "Label"},
   },
   slot_render = {
      _type = "ImageView",
      select_img = {_type = "ImageView"},
      img = {_type = "ImageView"},
      num_atlas = {_type = "LabelAtlas"},
   },
   history_render = {
      _type = "ImageView",
      img = {_type = "ImageView"},
      num_atlas = {_type = "LabelAtlas"},
      new = {_type = "ImageView"},
   },
   left_light = {_type = "ImageView", layout = {_type = "Layout"}},
   right_light = {_type = "ImageView", layout = {_type = "Layout"}},
   cd_img = {_type = "ImageView"},
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
   bigAward = {
      _type = "ImageView",
      text_1 = {_type = "ImageView"},
      head = {
         _type = "ImageView",
         top = {_type = "ImageView"},
      },   
      vip = {_type = "ImageView"},
      vipNum = {_type = "LabelAtlas"},
      name = {_type = "Label"},
      text_2 = {_type = "ImageView"},
      gold = {_type = "Label"},
   },
   historyAlert_layout = {_type = "Layout",
                     alert = {_type = "ImageView", 
                              back = {_type = "Button",_func = onAlertBack},
                              listView = {_type = "ListView"},
                     }, 
   },
}
