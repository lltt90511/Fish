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
local hasOtherGuess = false
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
   -- onFingerGameInviteAgreeSucceed()
   widget.bg.yazhu.obj:setVisible(false)
   widget.bg.yazhu.obj:setTouchEnabled(false)
   -- if tonumber(data.ownerId) == userdata.UserInfo.id or tonumber(data.ownerId) == userdata.UserInfo.charId then
   --    local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
   --    if vipLv >= 6 then
   --       widget.bg.yaoqing.obj:setVisible(true)
   --       widget.bg.yaoqing.obj:setTouchEnabled(true)
   --    end 
   --    betAlert.create(this)
   -- else
   --    widget.bg.yaoqing.obj:setVisible(false)
   --    widget.bg.yaoqing.obj:setTouchEnabled(false)
   --    setMineTouchEnabled(true)
   -- end
         widget.bg.yaoqing.obj:setVisible(true)
         widget.bg.yaoqing.obj:setTouchEnabled(true)
   -- if inviterId and inviterId > 0 then
   --    call("fingerGameInvite",tostring(inviterId)) 
   -- end
   -- local ps = CCParticleSystemQuad:create("ani/jinbi1.plist")
   -- ps:setPosition(ccp(Screen.width/2,Screen.height/2))
   -- this:addNode(ps)
   event.listen("ON_FINGER_GAME_BET_SUCCEED",onFingerGameBetSucceed)
   event.listen("ON_FINGER_GAME_GUESS_SUCCEED",onFingerGameGuessSucceed)
   event.listen("ON_FINGER_GAME_GUESS_FAILED",onFingerGameGuessFailed)
   event.listen("ON_FINGER_GAME_ENDTIME",onFingerGameEndTime)
   event.listen("ON_FINGER_GAME_RESULT",onFingerGameResult)
   event.listen("ON_FINGER_GAME_INVITE_AGREE_SUCCEED",onFingerGameInviteAgreeSucceed)
   event.listen("ON_BET_ALERT_BACK",onBetAlertBack)
   event.listen("ON_FINGER_GAME_LEAVE",onFingerGameLeave)
   return this
end

function initData(_data)
   -- printTable(fingerInfo)
   data = {}
   for k,v in pairs(_data) do
       data[k] = v
   end
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
            if cnt > 20 then
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

function onFingerGameBetSucceed(_data)
   print("onFingerGameBetSucceed!!!!!!!!!!!!!!!!!!!!!!!!!!")
   if betAlert.this then
      betAlert.exit()
   end
   local flag = false
   local gold = 0
   if _data.fromidx == userdata.UserInfo.uidx then
      if userdata.UserInfo.owncash < _data.mfrom then
         flag = true
      end
      gold = _data.mto
      userdata.UserInfo.owncash = _data.mfrom
   elseif _data.toidx == userdata.UserInfo.uidx then
      if userdata.UserInfo.owncash < _data.mto then
         flag = true
      end
      gold = _data.mfrom
      userdata.UserInfo.owncash = _data.mto
   end
   onFlyGold(flag,gold)
end

function onFingerGameGuessSucceed(_data)
   if widget.bg.countDown.obj:isVisible() then
      widget.bg.countDown.obj:setVisible(false)
   end
   -- if countDownTime > 3 then
   --    setMineTouchEnabled(true)
   -- end
   if not hasOtherGuess then
      onFingerGameEndTime()
   end
   setMineTouchEnabled(false)
   widget.bg.mine_shitou.btn.obj:setBright(tonumber(_data.msg)~=0)
   widget.bg.mine_jiandao.btn.obj:setBright(tonumber(_data.msg)~=1)
   widget.bg.mine_bu.btn.obj:setBright(tonumber(_data.msg)~=2)
end

function onFingerGameGuessFailed()
   if hasGuess then
      hasGuess = false
   end
   setMineTouchEnabled(true)
end

function onFingerGameEndTime()
   widget.bg.countDown.image.num.obj:setStringValue(countDownTime)
   if countDownTime > 0 then
      widget.bg.countDown.obj:setVisible(true)
   end
   widget.bg.other.image.obj:loadTexture("cash/qietu/mora/wenhao.png")
   if not isCountDown then
      isCountDown = true
      beginCountDown()
   end
   if not hasOtherGuess then
      hasOtherGuess = true
   end
end

function onFingerGameLeave()
   initView()
   widget.bg.yaoqing.obj:setVisible(true)
   widget.bg.yaoqing.obj:setTouchEnabled(true)
   widget.bg.yazhu.obj:setVisible(false)
   widget.bg.yazhu.obj:setTouchEnabled(false)
end

function onFingerGameResult(_data)
   -- data = {}
   -- -- printTable(fingerInfo)
   -- for k,v in pairs(fingerInfo) do
   --     data[k] = v
   -- end
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
   local isS1 = false
   if userdata.UserInfo.uidx == tonumber(_data.s1) then
      otherGuess = tonumber(_data.s2Res)
      mineGuess = tonumber(_data.s1Res)
      otherId = tonumber(_data.s2)
      isS1 = true
   elseif userdata.UserInfo.uidx == tonumber(_data.s2) then
      otherGuess = tonumber(_data.s1Res)
      mineGuess = tonumber(_data.s2Res)
      otherId = tonumber(_data.s1)
   end
   if mineGuess == otherGuess then
      winOrLost = 1
   else
      if mineGuess == 2 and otherGuess == 0 then
         winOrLost = 2
      elseif mineGuess == 0 and otherGuess == 2 then
         winOrLost = 0
      else
         if mineGuess < otherGuess then
            winOrLost = 2
         else
            winOrLost = 0
         end
      end
   end
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
      -- if winOrLost ~= 1 then
      --    tool.createEffect(tool.Effect.fadeIn,{time = 0.5,easeIn = true},widget.bg.jieguo_layout.obj,function()
      --       tool.createEffect(tool.Effect.delay,{time = 1.0},widget.bg.jieguo_layout.obj,function()
      --          tool.createEffect(tool.Effect.fadeOut,{time = 0.5,easeIn = true},widget.bg.jieguo_layout.obj)
      --       end)
      --    end)
      -- end
      tool.createEffect(tool.Effect.scale,{time = 0.2,scale = 1.2},widget.bg.result.obj,function()
         tool.createEffect(tool.Effect.scale,{time = 0.15,scale = 1.0},widget.bg.result.obj,function()
            tool.createEffect(tool.Effect.scale,{time = 0.1,scale = 1.05},widget.bg.result.obj,function()
               tool.createEffect(tool.Effect.scale,{time = 0.05,scale = 1.0},widget.bg.result.obj,function()
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
                              hasOtherGuess = false
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
   if not data.user then return end
   local id = data.user._uidx
   local name = data.user._nickName
   local gold = data.gold
   -- printTable(data)
   widget.bg.yazhu.obj:setVisible(true)
   widget.bg.yazhu.obj:setTouchEnabled(true)
   widget.bg.yaoqing.obj:setVisible(false)
   widget.bg.yaoqing.obj:setTouchEnabled(false)
   if id and id > 0 then
      widget.bg.head.obj:setVisible(true)
      userdata.CharIdToImageFile[data.user._uidx] = {file=data.user._picUrl,sex=data.user._sex}
      tool.getUserImage(eventHash, widget.bg.head.icon.obj, id)
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
   showOrHideAlert(1,false)
end

function onBetAlertBack()
   -- if not widget.bg.yazhu.obj:isVisible() then
   --    widget.bg.yazhu.obj:setVisible(true)
   --    widget.bg.yazhu.obj:setTouchEnabled(true)
   -- end
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
      event.unListen("ON_FINGER_GAME_GUESS_SUCCEED",onFingerGameGuessSucceed)
      event.unListen("ON_FINGER_GAME_GUESS_FAILED",onFingerGameGuessFailed)
      event.unListen("ON_FINGER_GAME_ENDTIME",onFingerGameEndTime)
      event.unListen("ON_FINGER_GAME_RESULT",onFingerGameResult)
      event.unListen("ON_FINGER_GAME_INVITE_AGREE_SUCCEED",onFingerGameInviteAgreeSucceed)
      event.unListen("ON_BET_ALERT_BACK",onBetAlertBack)
      event.unListen("ON_FINGER_GAME_LEAVE",onFingerGameLeave)
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
      hasOtherGuess = false
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
      -- if data.gold == 0 then
      --    alert.create("请先押注!",nil,function()
      --        betAlert.create(this,package.loaded["scene.moraGame"])
      --    end,nil,"去押注","再等等")
      -- else
      --    local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
      --    if vipLv < 6 then
      --       alert.create("VIP6才能邀请玩家！")
      --    else
      --       showOrHideAlert(1,true)
      --    end
      -- end
      showOrHideAlert(1,true)
   end
end

function onBet(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      betAlert.create(this,package.loaded["scene.moraGame"])
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
   AudioEngine.playEffect(soundArr[guessType+1])
   userdata.goldAction = true
   if guessType == 0 then
      minePosX = 210
   elseif guessType == 1 then
      minePosX = 540
   elseif guessType == 2 then
      minePosX = 870
   end
   call(35001,guessType)
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(7001,10)
      -- local mainScene = package.loaded["scene.main"]
      -- mainScene.createSubWidget(nil)
   end
end

function onAlertQueding(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      local str = textInput:getText()
      if str == "" then
         alert.create("请输入邀请人的ID")
      else
         if not tonumber(str) then
            alert.create("请输入邀请人的ID")
         else
            call(30001,math.floor(tonumber(str)))
            textInput:setText("")
         end
         -- if tonumber(str) and tonumber(str) > 8000000 then
         --    str = tostring(tonumber(str)-8000000)
         -- end
         -- call("fingerGameInvite",str)
         -- showOrHideAlert(1,false)
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

widget = {
   _ignore = true,
   bg = {
      _type = "ImageView",
      head = {
         _type = "ImageView",
         icon = {_type = "ImageView"},
      },
      yaoqing = {_type = "Button",_func = onInviter},
      yazhu = {
         _type = "Button",
         _func = onBet,
         text = {_type = "Label"},
      },
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
      countDown = {
         image = {
            _type = "ImageView",
            num = {_type = "LabelAtlas"},   
         },
      },
      name = {_type = "Label"},
      gold = {_type = "LabelAtlas"},
      gold_ico = {_type = "ImageView"},
      alert_layout = {
         _type = "Layout",
         alert = {
            _type = "ImageView",
            label = {_type = "Label"},
            input = {_type = "ImageView"},
            queding = {_type = "Button",_func = onAlertQueding},
            back = {_type = "Button",_func = onAlertBack},
         },
      },
   },
}