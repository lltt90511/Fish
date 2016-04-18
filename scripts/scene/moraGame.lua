local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require"logic.countLv"
local http = require"logic.http"
local betAlert = require"scene.betAlert"

module("scene.moraGame", package.seeall)

this = nil
thisParent = nil
parentModule = nil
inviterId = nil
local eventHash = {}
local data = {}
local countDownTime = 10
local winOrLost = 0 --0失败，1平局，2胜利
local textInput = nil
local picArr = {"shitou_1.png","jiandao_1.png","bu_1.png"}
local soundArr = {"effect_16","effect_18","effect_17"}
local timerCnt = 0
local goldTimer = nil
local otherPosX = 540
local otherPosY = 1220
local minePosX = 0
local minePosY = 610
local mineSelect = nil
local countDownTimer = nil
local isCountDown = false
local hasGuess = false
isYazhu = false
local needChangeGold = 0

function create(_parent,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   this = tool.loadWidget("cash/moraGame",widget,thisParent)
   commonTop.create(this,package.loaded["scene.moraGame"])
   AudioEngine.playMusic("bgm03.mp3",true)
   AudioEngine.playEffect("effect_15") 
   initView()
   initEditBox()
   showOrHideAlert(1,false)
   showOrHideAlert(2,false)
   showOrHideAlert(3,false)
   if data.gold then
      setYazhuGold(data.gold)
   else
      setYazhuGold(0)
   end
   onFingerGameInviteAgreeSucceed()
   widget.bg.yazhu.obj:setVisible(false)
   widget.bg.yazhu.obj:setTouchEnabled(false)
   if tonumber(data.ownerId) == userdata.UserInfo.id or tonumber(data.ownerId) == userdata.UserInfo.charId then
      local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
      if vipLv >= 6 then
         widget.bg.yaoqing.obj:setVisible(true)
         widget.bg.yaoqing.obj:setTouchEnabled(true)
      end 
      betAlert.create(this)
   else
      widget.bg.yaoqing.obj:setVisible(false)
      widget.bg.yaoqing.obj:setTouchEnabled(false)
      setMineTouchEnabled(true)
   end
   if inviterId and inviterId > 0 then
      call("fingerGameInvite",tostring(inviterId)) 
   end
   -- local ps = CCParticleSystemQuad:create("ani/jinbi1.plist")
   -- ps:setPosition(ccp(Screen.width/2,Screen.height/2))
   -- this:addNode(ps)
   widget.bg.jieguo_layout.obj:setOpacity(0)
   event.listen("ON_FINGER_GAME_BET_SUCCEED",onFingerGameBetSucceed)
   event.listen("ON_FINGER_GAME_BET_CHANGE",onFingerGameBetChange)
   event.listen("ON_FINGER_GAME_GUESS_SUCCEED",onFingerGameGuessSucceed)
   event.listen("ON_FINGER_GAME_GUESS_FAILED",onFingerGameGuessFailed)
   event.listen("ON_FINGER_GAME_ENDTIME",onFingerGameEndTime)
   event.listen("ON_FINGER_GAME_RESULT",onFingerGameResult)
   event.listen("ON_FINGER_GAME_INVITE_AGREE_SUCCEED",onFingerGameInviteAgreeSucceed)
   event.listen("ON_BET_ALERT_BACK",onBetAlertBack)
   return this
end

function initData(fingerInfo)
   -- printTable(fingerInfo)
   data = {}
   for k,v in pairs(fingerInfo) do
       data[k] = v
   end
   printTable(data)
end

function initView()
   widget.bg.head.obj:setVisible(false)
   widget.bg.result.obj:setOpacity(0)
   widget.bg.countDown.obj:setVisible(false)
   widget.bg.name.obj:setVisible(false)
   widget.bg.gold_ico.obj:setVisible(false)
   widget.bg.gold.obj:setVisible(false)
end

function initEditBox()
   local inputSize = widget.bg.alert_layout.alert.input.obj:getSize()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   widget.bg.alert_layout.alert.input.obj:addNode(textInput)
   textInput:setPosition(ccp(0,0))
   textInput:setAnchorPoint(ccp(0,0))
   textInput:setFontColor(ccc3(255,255,255))
   textInput:setFontSize(40)
   textInput:setFontName(DEFAULT_FONT)
   -- textInput:setInputMode(3)
   textInput:setReturnType(1)
   textInput:setMaxLength(20)
   textInput:setPlaceHolder("输入文字")
   textInput:setText("")
   textInput:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      print(textInput:getText())
      print(strEventName)
      local str = textInput:getText()
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         local i = 1
         local cnt = 1
         local tb = {}
         while i <= #str  do
            c = str:sub(i,i)
            ord = c:byte()
            if ord > 128 then
               table.insert(tb,str:sub(i,i+2))
               i = i+3
               cnt = cnt + 1
            else
               table.insert(tb,c)
               i = i+1
               cnt = cnt + 1
            end
            if cnt > 21 then
               alert.create("文字太长，超过输入限制")
               textInput:setText("")
               return
            end
         end
         textInput:setText(table.concat(tb))
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.bg.alert_layout.alert.input.obj:setTouchEnabled(true)
   widget.bg.alert_layout.alert.input.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput:attachWithIME()
                                                   textInput:setPosition(ccp(0,0))
                                                end
   end)
end

function onFlyGold(flag,gold,func)
   local beginX = 0
   local beginY = 0
   local endX = 0
   local endY = 0
   if flag then
      beginX = 300
      beginY = 1530
      endX = 240
      endY = 1790
   else
      beginX = 240
      beginY = 1790
      endX = 300
      endY = 1530
   end
   if userdata.goldAction then 
      AudioEngine.playEffect("effect_07")     
      userdata.goldAction = false
      if goldTimer then
         unSchedule(goldTimer)
         goldTimer = nil
      end
      goldTimer = schedule(function()
         timerCnt = timerCnt + 1
         if timerCnt > 10 then
            unSchedule(goldTimer)
            goldTimer = nil
            timerCnt = 0
            tool.createEffect(tool.Effect.delay,{time=0.5},widget.obj,function()
               if commonTop.onChangeGold then
                  commonTop.onChangeGold()
               end
               local mainScene = package.loaded["scene.main"]
               if mainScene.this and mainScene.initTop then
                  mainScene.initTop()
               end
               widget.bg.gold.obj:setStringValue(gold)
               if func then
                  func()
               end
            end)
            return
         end
         local gold = ImageView:create()
         gold:loadTexture("cash/qietu/tymb/goldIcon.png")
         gold:setPosition(ccp(beginX,beginY))
         thisParent:addChild(gold,100)
         tool.createEffect(tool.Effect.move,{time=0.5,x=endX,y=endY},gold,function()
            tool.createEffect(tool.Effect.fadeOut,{time=0.1},gold,function()
               gold:removeFromParentAndCleanup(true)
            end)
         end)
     end,0.1)
   end
end

function onFingerGameBetSucceed(gold)
   -- print("-----------------==")
   -- printTable(data)
   if (userdata.UserInfo.id == tonumber(data.ownerId) or userdata.UserInfo.charId == tonumber(data.ownerId)) and tonumber(data.targetId) ~= -1 then
      showOrHideAlert(2,true)
   end
   setYazhuGold(gold)
   if betAlert.this then
      betAlert.exit()
   end
end

function onFingerGameBetChange(gold)
   if gold > 0 then
      if userdata.UserInfo.id == tonumber(data.ownerId) or userdata.UserInfo.charId == tonumber(data.ownerId) then
         if gold ~= data.gold then
            setYazhuGold(gold)
            alert.create("对方拒绝您修改的押注金额!押注金额已被重置")
         end
         showOrHideAlert(2,false)
      else
         alert.create("对方修改了押注金额!当前押注金额"..gold.."!是否同意？",nil,function()
            setYazhuGold(gold)
            call("fingerGameBet",data.gold)
         end,function()
            if data.gold == 0 then
               needChangeGold = gold
               AudioEngine.playEffect("effect_06")
               showOrHideAlert(3,true)
               -- tool.createEffect(tool.Effect.delay,{time = 0.5},widget.obj,function()
               --    alert.create("如果此时拒绝将直接离开游戏，是否拒绝？",nil,function()
               --       setYazhuGold(gold)
               --       call("fingerGameBet",data.gold)
               --    end,function()
               --       call("leaveGame")
               --    end,"继续游戏","直接拒绝")
               -- end)
            else
               call("fingerGameBet",data.gold)
            end
         end,"同意","拒绝")
      end
   else
      if isYazhu then
         isYazhu = false
      end
      setYazhuGold(gold)
      if userdata.UserInfo.id == tonumber(data.targetId) or userdata.UserInfo.charId == tonumber(data.targetId) then 
         alert.create("押注金比数超出玩家金币数，已重设")
      end
   end
end 

function setYazhuGold(gold)
   data.gold = gold
   widget.bg.yazhu_layout.yazhu_num.obj:setStringValue(gold)
   local panel = widget.bg.yazhu_layout
   local panelSize = panel.obj:getSize()
   panel.obj:setSize(CCSize(panel.yazhu.obj:getSize().width+panel.yazhu_num.obj:getSize().width+panel.jinbi.obj:getSize().width,panelSize.height))
   panel.obj:setPositionX(Screen.width/2-panel.obj:getSize().width/2)
end

function onFingerGameGuessSucceed(type)
   if widget.bg.countDown.obj:isVisible() then
      widget.bg.countDown.obj:setVisible(false)
   end
   if countDownTime > 3 then
      setMineTouchEnabled(true)
   end
   widget.bg.mine_shitou.btn.obj:setBright(type~=0)
   widget.bg.mine_jiandao.btn.obj:setBright(type~=1)
   widget.bg.mine_bu.btn.obj:setBright(type~=2)
end

function onFingerGameGuessFailed()
   if hasGuess then
      hasGuess = false
   end
   if isYazhu then
      isYazhu = false
   end
   setMineTouchEnabled(true)
end

function onFingerGameEndTime(endTime)
   data.endTime = endTime
   widget.bg.countDown.image.num.obj:setStringValue(countDownTime)
   if countDownTime > 0 then
      widget.bg.countDown.obj:setVisible(true)
   end
   widget.bg.other.image.obj:loadTexture("cash/qietu/mora/wenhao.png")
   if not isCountDown then
      isCountDown = true
      beginCountDown()
   end
   if not isYazhu then
      isYazhu = true
   end
end

function onFingerGameResult(fingerInfo)
   data = {}
   -- printTable(fingerInfo)
   for k,v in pairs(fingerInfo) do
       data[k] = v
   end
   -- printTable(data)
   setMineTouchEnabled(false)
   if countDownTimer then
      unSchedule(countDownTimer)
      countDownTimer = nil
   end
   if widget.bg.countDown.obj:isVisible() then
      widget.bg.countDown.obj:setVisible(false)
   end
   widget.bg.countDown.image.num.obj:setStringValue(countDownTime)
   local gold = 0
   local otherId = 0
   local otherGuess = -1
   local mineGuess = -1
   if userdata.UserInfo.id == tonumber(data.targetId) or userdata.UserInfo.charId == tonumber(data.targetId) then
      otherGuess = tonumber(data.ownerGuess)
      mineGuess = tonumber(data.targetGuess)
      gold = data.ownerGold
      otherId = tonumber(data.ownerId)
   elseif userdata.UserInfo.id == tonumber(data.ownerId) or userdata.UserInfo.charId == tonumber(data.ownerId) then
      otherGuess = tonumber(data.targetGuess)
      mineGuess = tonumber(data.ownerGuess)
      gold = data.targetGold
      otherId = tonumber(data.targetId)
   end
   if tonumber(data.ownerGuess) == tonumber(data.targetGuess) then
      winOrLost = 1
   else
      if userdata.UserInfo.id == tonumber(data.targetId) or userdata.UserInfo.charId == tonumber(data.targetId) then
         if tonumber(data.ownerGuess) == 2 and tonumber(data.targetGuess) == 0 then
            winOrLost = 0
         elseif (tonumber(data.ownerGuess) == 0 and tonumber(data.targetGuess) == 2) or tonumber(data.ownerGuess) > tonumber(data.targetGuess) then
            winOrLost = 2
         else
            winOrLost = 0
         end
      elseif userdata.UserInfo.id == tonumber(data.ownerId) or userdata.UserInfo.charId == tonumber(data.ownerId) then
         if tonumber(data.ownerGuess) == 0 and tonumber(data.targetGuess) == 2 then
            winOrLost = 0
         elseif (tonumber(data.ownerGuess) == 2 and tonumber(data.targetGuess) == 0) or tonumber(data.ownerGuess) < tonumber(data.targetGuess) then
            winOrLost = 2
         else
            winOrLost = 0
         end
      end
   end
   local panel = widget.bg.jieguo_layout
   local panelSize = panel.obj:getSize()
   if winOrLost == 0 then
      panel.label.obj:setText("您输掉了")
   elseif winOrLost == 2 then
      panel.label.obj:setText("您赢得了")
   end
   panel.num.obj:setStringValue(data.gold)
   panel.obj:setSize(CCSize(panel.label.obj:getSize().width+panel.num.obj:getSize().width+panel.image.obj:getSize().width,panelSize.height))
   panel.obj:setPositionX(Screen.width/2-panel.obj:getSize().width/2)
   if otherId == -1 then
      widget.bg.other.image.obj:loadTexture("cash/qietu/mora/wenhao.png")
   end
   if winOrLost == 0 then
      widget.bg.result.obj:loadTexture("cash/qietu/mora/shibai.png")
   elseif winOrLost == 1 then
      widget.bg.result.obj:loadTexture("cash/qietu/mora/pingju.png")
   elseif winOrLost == 2 then
      widget.bg.result.obj:loadTexture("cash/qietu/mora/shengli.png")
   end
   AudioEngine.playEffect("effect_14")
   local action1 = CCFlipX3D:create(0.2)
   local action2 = action1:reverse()
   local action3 = CCSequence:createWithTwoActions(action1,action2)
   widget.bg.other.obj:runAction(action3)
   if mineGuess == 0 then
      mineSelect = widget.bg.mine_shitou.obj
      minePosX = 210
   elseif mineGuess == 1 then
      mineSelect = widget.bg.mine_jiandao.obj
      minePosX = 540
   elseif mineGuess == 2 then
      mineSelect = widget.bg.mine_bu.obj
      minePosX = 870
   end
   local func = function()
      widget.bg.result.obj:setOpacity(255)
      widget.bg.result.obj:setScale(0)
      if winOrLost == 0 then
         AudioEngine.playEffect("effect_10")
      elseif winOrLost == 1 then
         AudioEngine.playEffect("effect_11")
      elseif winOrLost == 2 then
         AudioEngine.playEffect("effect_09")
      end     
      if winOrLost ~= 1 then
         tool.createEffect(tool.Effect.fadeIn,{time = 0.5,easeIn = true},widget.bg.jieguo_layout.obj,function()
            tool.createEffect(tool.Effect.delay,{time = 1.0},widget.bg.jieguo_layout.obj,function()
               tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},widget.bg.jieguo_layout.obj)
            end)
         end)
      end
      tool.createEffect(tool.Effect.scale,{time = 0.2,scale = 1.2},widget.bg.result.obj,function()
         tool.createEffect(tool.Effect.scale,{time = 0.15,scale = 1.0},widget.bg.result.obj,function()
            tool.createEffect(tool.Effect.scale,{time = 0.1,scale = 1.05},widget.bg.result.obj,function()
               tool.createEffect(tool.Effect.scale,{time = 0.05,scale = 1.0},widget.bg.result.obj,function()
                  if otherId > 0 then
                     if winOrLost ~= 1 then
                        onFlyGold(winOrLost==2,gold)
                     end
                  else
                     userdata.goldAction = false
                     if commonTop.onChangeGold then
                        commonTop.onChangeGold()
                     end
                     local mainScene = package.loaded["scene.main"]
                     if mainScene.this and mainScene.initTop then
                        mainScene.initTop()
                     end
                  end
                  tool.createEffect(tool.Effect.delay,{time = 1.0},widget.bg.result.obj,function()
                     tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},widget.bg.result.obj)  
                     tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},widget.bg.other.image.obj,function()
                           widget.bg.other.image.obj:loadTexture("cash/qietu/mora/di_2.png")
                     end)
                     tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},widget.bg.other.obj,function()
                        widget.bg.other.obj:setPosition(ccp(otherPosX,otherPosY))
                        tool.createEffect(tool.Effect.delay,{time = 0.1},widget.bg.other.obj,function()
                           tool.createEffect(tool.Effect.fadeIn,{time = 0.5,easeIn = true},widget.bg.other.obj)
                           tool.createEffect(tool.Effect.fadeIn,{time = 0.5,easeIn = true},widget.bg.other.image.obj)
                        end)
                     end)
                     tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},mineSelect,function()
                        setMineBright(true)
                        mineSelect:setPosition(ccp(minePosX,minePosY))
                        tool.createEffect(tool.Effect.delay,{time = 0.1},mineSelect,function()
                           tool.createEffect(tool.Effect.fadeIn,{time = 0.5,easeIn = true},mineSelect,function()
                              countDownTime = 10
                              isCountDown = false
                              hasGuess = false
                              isYazhu = false
                              data.ownerGuess = -1
                              data.targetGuess = -1
                              setMineTouchEnabled(true)
                           end)
                        end)
                     end)         
                  end) 
               end)
            end)
         end)
      end)
   end
   tool.createEffect(tool.Effect.delay,{time = 0.5},widget.bg.result.obj,function()
      if otherGuess >= 0 then
         widget.bg.other.image.obj:loadTexture("cash/qietu/mora/"..picArr[otherGuess+1])
      end
      widget.bg.other.obj:setScale(1.5)
      local shadowBg = ImageView:create()
      shadowBg:loadTexture("cash/qietu/mora/di.png")
      shadowBg:setOpacity(80)
      shadowBg:setPosition(ccp(widget.bg.other.obj:getPositionX(),widget.bg.other.obj:getPositionY()))
      widget.bg.obj:addChild(shadowBg)
      local shadow = ImageView:create()
      shadow:loadTexture("cash/qietu/mora/"..picArr[otherGuess+1])
      shadow:setPosition(ccp(0,0))
      shadow:setOpacity(50)
      shadowBg:addChild(shadow)
      tool.createEffect(tool.Effect.delay,{time = 0.2},widget.bg.result.obj,function()
         tool.createEffect(tool.Effect.delay,{time = 0.12},shadowBg,function()
            tool.createEffect(tool.Effect.scale,{time = 0.1,scale = 1.5},shadowBg,function()
               shadow:removeFromParentAndCleanup(true)
               shadowBg:removeFromParentAndCleanup(true)
            end)
         end)
         tool.createEffect(tool.Effect.scale,{time = 0.2,scale = 1},widget.bg.other.obj,function()
            AudioEngine.playEffect(soundArr[otherGuess+1]) 
            AudioEngine.playEffect("effect_13")
            if winOrLost ~= 1 then
               AudioEngine.playEffect("effect_08")
            end
            tool.createEffect(tool.Effect.delay,{time = 0.3},widget.bg.other.obj,function()
               if winOrLost == 1 then
                  func()
               else   
                  if winOrLost == 0 then
                     tool.createEffect(tool.Effect.move,{time = 0.2,x = minePosX,y = minePosY,easeIn = true},widget.bg.other.obj)
                     tool.createEffect(tool.Effect.delay,{time = 0.09},mineSelect,function()
                        tool.createEffect(tool.Effect.move,{time = 0.2,x = minePosX*2-otherPosX,y = -200,easeIn = true},mineSelect,function()
                           tool.createEffect(tool.Effect.delay,{time = 0.1},mineSelect,func)
                        end)
                     end)
                  elseif winOrLost == 2 then
                     tool.createEffect(tool.Effect.move,{time = 0.2,x = otherPosX,y = otherPosY,easeIn = true},mineSelect)
                     tool.createEffect(tool.Effect.delay,{time = 0.06},widget.bg.other.obj,function() 
                        tool.createEffect(tool.Effect.move,{time = 0.2,x = otherPosX*2-minePosX,y = Screen.height+200,easeIn = true},widget.bg.other.obj,function()
                           tool.createEffect(tool.Effect.delay,{time = 0.1},mineSelect,func)
                        end)
                     end)
                  end
               end
            end)
         end)
      end)
   end)
end

function onFingerGameInviteAgreeSucceed()
   local id = 0
   local name = nil
   local gold = nil
   -- printTable(data)
   widget.bg.yaoqing.obj:setVisible(false)
   widget.bg.yaoqing.obj:setTouchEnabled(false)
   if tonumber(data.ownerId) == userdata.UserInfo.id or tonumber(data.ownerId) == userdata.UserInfo.charId then
      id = tonumber(data.targetId)
      name = data.targetCharName
      gold = data.targetGold
   elseif tonumber(data.targetId) == userdata.UserInfo.id or tonumber(data.targetId) == userdata.UserInfo.charId then
      id = tonumber(data.ownerId) 
      name = data.ownerCharName
      gold = data.ownerGold
   end
   if id and id > 0 then
      widget.bg.head.obj:setVisible(true)
      tool.loadRemoteImage(eventHash, widget.bg.head.icon.obj, id)
      if name then
         widget.bg.name.obj:setVisible(true)
         widget.bg.name.obj:setText(name)
      end
      if gold then
         widget.bg.gold_ico.obj:setVisible(true)
         widget.bg.gold.obj:setVisible(true)
         widget.bg.gold.obj:setStringValue(gold)
      end
   end
end

function onBetAlertBack()
   if not widget.bg.yazhu.obj:isVisible() then
      widget.bg.yazhu.obj:setVisible(true)
      widget.bg.yazhu.obj:setTouchEnabled(true)
   end
end

function beginCountDown()
   if countDownTimer then
      unSchedule(countDownTimer)
      countDownTimer = nil
   end
   countDownTimer = schedule(function()
      countDownTime = countDownTime - 1
      if countDownTime <= 3 then
         print("hasGuess!!!!!!!!!!!!!!!!!",hasGuess)
         setMineTouchEnabled(not hasGuess)
         AudioEngine.playEffect("effect_01")   
      end
      widget.bg.countDown.image.num.obj:setStringValue(countDownTime)
      if countDownTime == 0 then
         unSchedule(countDownTimer)
         countDownTimer = nil
         widget.bg.countDown.obj:setVisible(false)
         if not hasGuess then
            randomGuess()
         end
      end
   end,1.0)
end

function randomGuess()
   local random = math.random(0,2)
   onGuess(random)
end

function showOrHideAlert(type,flag)
   widget.bg.alert_layout.obj:setVisible(flag)
   widget.bg.alert_layout.obj:setTouchEnabled(flag)
   if type == 1 then
      widget.bg.alert_layout.alert.obj:setVisible(flag)
      widget.bg.alert_layout.alert.input.obj:setTouchEnabled(flag)
      widget.bg.alert_layout.alert.queding.obj:setTouchEnabled(flag)
      widget.bg.alert_layout.alert.back.obj:setTouchEnabled(flag)
   elseif type == 2 then
      widget.bg.alert_layout.waitChange.obj:setVisible(flag)
   elseif type == 3 then
      widget.bg.alert_layout.refuse.obj:setVisible(flag)
      widget.bg.alert_layout.refuse.jixu.obj:setTouchEnabled(flag)
      widget.bg.alert_layout.refuse.likai.obj:setTouchEnabled(flag)
   end
end

function setMineTouchEnabled(flag)
   widget.bg.mine_shitou.btn.obj:setTouchEnabled(flag)
   widget.bg.mine_jiandao.btn.obj:setTouchEnabled(flag)
   widget.bg.mine_bu.btn.obj:setTouchEnabled(flag)
end

function setMineBright(flag)
   widget.bg.mine_shitou.btn.obj:setBright(flag)
   widget.bg.mine_jiandao.btn.obj:setBright(flag)
   widget.bg.mine_bu.btn.obj:setBright(flag)
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end

function exit()
   if this then
      event.unListen("ON_FINGER_GAME_BET_SUCCEED",onFingerGameBetSucceed)
      event.unListen("ON_FINGER_GAME_BET_CHANGE",onFingerGameBetChange)
      event.unListen("ON_FINGER_GAME_GUESS_SUCCEED",onFingerGameGuessSucceed)
      event.unListen("ON_FINGER_GAME_GUESS_FAILED",onFingerGameGuessFailed)
      event.unListen("ON_FINGER_GAME_ENDTIME",onFingerGameEndTime)
      event.unListen("ON_FINGER_GAME_RESULT",onFingerGameResult)
      event.unListen("ON_FINGER_GAME_INVITE_AGREE_SUCCEED",onFingerGameInviteAgreeSucceed)
      event.unListen("ON_BET_ALERT_BACK",onBetAlertBack)
      cleanEvent()
      data = {}
      inviterId = nil
      countDownTime = 10
      winOrLost = 0 --0失败，1平局，2胜利
      textInput = nil
      timerCnt = 0
      otherPosX = 540
      otherPosY = 1220
      minePosX = 0
      minePosY = 610
      mineSelect = nil
      isCountDown = false
      hasGuess = false
      isYazhu = false
      needChangeGold = 0
      if goldTimer then
         unSchedule(goldTimer)
         goldTimer = nil
      end
      if countDownTimer then
         unSchedule(countDownTimer)
         countDownTimer = nil
      end
      if commonTop then
         commonTop.exit()
      end
      AudioEngine.stopMusic(true)
      AudioEngine.stopAllEffects()
      AudioEngine.playMusic("bgm01.mp3",true)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      parentModule = nil
      thisParent = nil
      this = nil
   end
end

function onInviter(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if data.gold == 0 then
         alert.create("请先押注!",nil,function()
             betAlert.create(this,package.loaded["scene.moraGame"])
         end,nil,"去押注","再等等")
      else
         local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
         if vipLv < 6 then
            alert.create("VIP6才能邀请玩家！")
         else
            showOrHideAlert(1,true)
         end
      end
   end
end

function onBet(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if isYazhu then
         alert.create("已押注，请勿修改押注金额！")
      else
         betAlert.create(this,package.loaded["scene.moraGame"])
      end
   end
end

function onShitou(event)
   if event == "releaseUp" then
      onGuess(0)
   end
end

function onJiandao(event)
   if event == "releaseUp" then
      onGuess(1)
   end
end

function onBu(event)
   if event == "releaseUp" then
      onGuess(2)
   end
end

function onGuess(guessType)
   setMineTouchEnabled(false)
   if not hasGuess then
      hasGuess = true
   end
   if not isYazhu then
      isYazhu = true
   end
   AudioEngine.playEffect(soundArr[guessType+1])
   userdata.goldAction = true
   if guessType == 0 then
      minePosX = 210
   elseif guessType == 1 then
      minePosX = 540
   elseif guessType == 2 then
      minePosX = 870
   end
   call("fingerGameGuess",guessType)
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call("leaveGame")
      -- local mainScene = package.loaded["scene.main"]
      -- mainScene.createSubWidget(nil)
   end
end

function onAlertQueding(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      local str = textInput:getText()
      if str == "" then
         alert.create("请输入邀请人的ID或用户名")
      else
         if tonumber(str) and tonumber(str) > 8000000 then
            str = tostring(tonumber(str)-8000000)
         end
         call("fingerGameInvite",str)
         showOrHideAlert(1,false)
         textInput:setText("")
      end
   end
end

function onAlertBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      showOrHideAlert(1,false)
      textInput:setText("")
   end
end

function onJixu(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      setYazhuGold(needChangeGold)
      call("fingerGameBet",data.gold)
      showOrHideAlert(3,false)
      needChangeGold = 0
   end
end

function onLikai(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call("leaveGame")
   end
end

widget = {
   _ignore = true,
   bg = {
      _type = "ImageView",
      head = {
         _type = "ImageView",
         icon = {_type = "ImageView"},
      },
      yaoqing = {_type = "Button",_func = onInviter},
      yazhu = {_type = "Button",_func = onBet},
      other = {
         _type = "ImageView",
         image = {_type = "ImageView"},
      },
      result = {_type = "ImageView"},
      mine_shitou = {
         _type = "ImageView",
         btn = {_type = "Button",_func = onShitou},
      },
      mine_jiandao = {
         _type = "ImageView",
         btn = {_type = "Button",_func = onJiandao},
      },
      mine_bu = {
         _type = "ImageView",
         btn = {_type = "Button",_func = onBu},
      },
      yazhu_layout = {
         _type = "Layout",
         yazhu = {_type = "ImageView"},
         yazhu_num = {_type = "LabelAtlas"},
         jinbi = {_type = "ImageView"},
      },
      countDown = {
         image = {
            _type = "ImageView",
            num = {_type = "LabelAtlas"},   
         },
      },
      name = {_type = "Label"},
      gold = {_type = "LabelAtlas"},
      gold_ico = {_type = "ImageView"},
      jieguo_layout = {
         _type = "Layout",
         label = {_type = "Label"},
         num = {_type = "LabelAtlas"},
         image = {_type = "ImageView"},
      },
      alert_layout = {
         _type = "Layout",
         alert = {
            _type = "ImageView",
            label = {_type = "Label"},
            input = {_type = "ImageView"},
            queding = {_type = "Button",_func = onAlertQueding},
            back = {_type = "Button",_func = onAlertBack},
         },
         waitChange = {
            _type = "ImageView",
            label = {_type = "Label"},
         },
         refuse = {
            _type = "ImageView",
            label = {_type = "Label"},
            jixu = {
               _type = "Button",
               _func = onJixu,
               text = {_type = "Label"},
               shadow = {_type = "Label"},
            },
            likai = {
               _type = "Button",
               _func = onLikai,
               text = {_type = "Label"},
               shadow = {_type = "Label"},
            },
         },
      },
   },
}