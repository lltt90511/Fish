local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local selfInfo = require"scene.selfInfo"
local setting = require "scene.setting"
local countLv = require "logic.countLv"
local rank = require"scene.rank"
local dailyScene = require "scene.loginGift"
local smail = require "scene.mail"
local charge = require "scene.charge"
local activity = require "scene.activity"
local service = require "scene.service"
local about = require "scene.about"
local binding = require "scene.binding"
local vip = require "scene.vip"
local receive = require "scene.receive"
local reward = require "scene.reward"
local tree = require "scene.tree"
local lottery = require "scene.lottery"
local template = require"template.gamedata".data
local backList = require"scene.backList"
local userdata = require"logic.userdata"
local chatHistory = require"scene.chatHistory"
local moraGame = require "scene.moraGame"
local gameLoading = require"scene.gameLoading"
module("scene.main", package.seeall)

this = nil
subWidget = nil
widgetID = {
   main = nil,
   fruitMachine = fruitMachine,
   fishMachine = fishMachine,
   moraGame = moraGame,
   gameLoading = gameLoading,
}
daily = false
local freeGoldTimer = nil
local beginTime = 0
local isFreeGoldAction = false
local isLotterAction = false
-- local isFirstToReward = true
local goldTimer = nil
local timerCnt = 0
min = 0
sec = 0
local lightList = {}
local eventHash = {}
local systemMessageList = {}
local isSystemMessagePlaying = false
local posList = {}

function create()
   this = tool.loadWidget("cash/main_scene",widget)
   widget.top.image.obj:setTouchEnabled(true)
   widget.top.image.obj:registerEventScript(onSelfInfo)
   widget.bottom.huodong.pao.obj:setVisible(false)
   initView()
   initMiddle()
   addLight()
   if UserSetting["fishIndex"] then
      userdata.lastFishSingleIndex = tonumber(UserSetting["fishIndex"])
   end 
   if UserSetting["fruitIndex"] then
      userdata.lastFruitSingleIndex = tonumber(UserSetting["fruitIndex"])
   end 
   if UserSetting["fishType"] then
      userdata.lastFishSingleType = UserSetting["fishType"]
   end 
   if UserSetting["fruitType"] then
      userdata.lastFruitSingleType = UserSetting["fruitType"]
   end 
   if UserSetting["isFirstGame"] then
      userdata.isFirstGame = tonumber(UserSetting["isFirstGame"])
   else
      userdata.isFirstGame = 1
   end
   if UserSetting["fruitHistoryGold"] then
      userdata.userFruitHistoryGold = UserSetting["fruitHistoryGold"]
   end
   if UserSetting["fishHistoryGold"] then
      userdata.userFishHistoryGold = UserSetting["fishHistoryGold"]
   end
   -- getChar(userdata.UserInfo.id or userdata.UserInfo.charId)
   -- local now = os.time()
   -- for k,v in pairs(UserChar) do
   --     local lastTime = 0
   --     local needDelete = false
   --     local cnt = 0
   --     for m,n in pairs(v) do
   --         if n.time/1000 < now - 7*24*3600 then
   --            lastTime = n.time
   --            needDelete = true
   --         end
   --         cnt = cnt + 1
   --     end
   --     if needDelete then
   --        if cnt == #v then
   --           lastTime = v[#v].time
   --        end
   --        deleteChar(k,lastTime)
   --     end
   -- end
   -- getChar(userdata.UserInfo.id or userdata.UserInfo.charId)
   print("main messageList")
   printTable(UserChar)
   userdata.isInGame = false
   activityAni(widget.bottom.shangcheng.pao.obj)
   activityAni(widget.bottom.shezhi.pao.obj)
   activityAni(widget.bottom.setting_panel.btn2.pao.obj)
   event.listen("ON_CHANGE_GOLD",onChangeGold)
   event.listen("ON_CHANGE_VIP",initTop)
   event.listen("ON_CHANGE_NAME",initTop)
   event.listen("ON_BACK",resetBright)
   event.listen("ON_GET_QUEST",setRewardPaoNum)
   event.listen("ON_FINISH_QUEST",setRewardPaoNum)
   event.listen("ON_UPDATE_QUEST",setRewardPaoNum)
   event.listen("ON_UPDATE_MAIL",setMailPaoNum)
   event.listen("ON_GOLD_ACTION",onGoldAction)
   event.listen("HEAD_ICON_CHANGE", onSetDefaultImageSucceed)
   event.listen("SYSTEM_CONTEXT", onSystemContext)
   event.listen("ON_GET_ACTIVITY_EXIST", onGetActivityExist)
   onSetDefaultImageSucceed()

   if platform == "IOS" then
     widget.top_btn_list.kefu.obj:setVisible(false)
     widget.top_btn_list.kefu.obj:setTouchEnabled(false)
   end

   return this
end

function onGetActivityExist(flag)
   if flag then
      widget.bottom.huodong.pao.obj:setVisible(true)
      activityAni(widget.bottom.huodong.pao.obj)
   else
      widget.bottom.huodong.pao.obj:setVisible(false)
   end
end

function onSystemContext(data)
   print("onSystemContext",data)
   table.insert(systemMessageList,data)
   printTable(systemMessageList)
   playSystemMessageEffect()
end

function playSystemMessageEffect()
   print("playSystemMessageEffect",userdata.isInGame)
   if isSystemMessagePlaying == true then
      return
   end
   local func = nil
   func = function()
      if userdata.isInGame == true then
         tool.createEffect(tool.Effect.delay,{time=1.0},widget.obj,function()
            func()
         end)
      else
          if type(systemMessageList) == type({}) and #systemMessageList == 0 then
             isSystemMessagePlaying = false
             return
          end
          isSystemMessagePlaying = true
          local data = table.remove(systemMessageList,1)
          local layout = tool.getRichTextWithColor(data,40) 
          layout:setPosition(ccp(widget.top.text.obj:getSize().width,12))
          widget.top.text.obj:addChild(layout)
          local size = layout:getSize()
      -- tool.createEffect(tool.Effect.delay,{time=4.0},layout,function()   
          tool.createEffect(tool.Effect.move,{time=0.5*(size.width/50),x=-size.width,y=0},layout,
              function()
                 layout:removeFromParent()
                 func()
              end)
      -- end)
      end
   end
   func()
end

function initView()
   initSetting()
   initTips()
   initTop()
   -- initAnnone()
   -- chongzhiAction()
   switchBottomBright("dating")
   scheduleFunc = function()
        setLotteryPaoNum()
        local tmp = template['freeGold'][userdata.UserInfo.freeGoldCnt+1]
        if not tmp or userdata.UserInfo.freeGoldCnt > #template['freeGold'] then
           tmp = template['freeGold'][6]
        end
        local currentTime = getSyncedTime()
        local time = currentTime - userdata.UserInfo.lastFreeGoldTime/1000
        -- print("time",currentTime,userdata.UserInfo.lastFreeGoldTime,tmp.time*60,time)
        if userdata.UserInfo.lastFreeGoldTime == 0 then
           if isFreeGoldAction == false then
              isFreeGoldAction = true
              widget.top.btn_lingqu.Image_10.obj:setVisible(true)
              widget.top.btn_lingqu.time.obj:setVisible(false)
              receiveAction()
           end
        else
           if time > tmp.time*60 then
              if time - tmp.time*60 > 20*60 then
                 userdata.UserInfo.freeGoldCnt = 0
              end
                 -- userdata.UserInfo.lastFreeGoldTime = currentTime*1000
                 -- if isFreeGoldAction == true then
                 --    isFreeGoldAction = false
                 --    widget.top.btn_lingqu.Image_10.obj:setVisible(true)
                 --    widget.top.btn_lingqu.time.obj:setVisible(false)
                 --    widget.top.btn_lingqu.Image_10.obj:setScale(1)
                 -- end
                 if isFreeGoldAction == false then
                    isFreeGoldAction = true
                    widget.top.btn_lingqu.Image_10.obj:setVisible(true)
                    widget.top.btn_lingqu.time.obj:setVisible(false)
                    receiveAction()
                 end
              -- else
              --    if isFreeGoldAction == false then
              --       isFreeGoldAction = true
              --       widget.top.btn_lingqu.Image_10.obj:setVisible(true)
              --       widget.top.btn_lingqu.time.obj:setVisible(false)
              --       receiveAction()
              --    end
              -- end
           else
              if isFreeGoldAction == true then
                 isFreeGoldAction = false
                 widget.top.btn_lingqu.Image_10.obj:setScale(1)
              end
              local nextTime = userdata.UserInfo.lastFreeGoldTime/1000 + tmp.time*60
              -- print("time2",userdata.UserInfo.lastFreeGoldTime,nextTime,currentTime,tmp.time)
              min = math.floor((nextTime-currentTime)/60)
              sec = math.floor((nextTime-currentTime)%60)
              if min < 10 then
                 min = "0" .. min
              end
              if sec < 10 then
                 sec = "0" .. sec
              end
              widget.top.btn_lingqu.Image_10.obj:setVisible(false)
              widget.top.btn_lingqu.time.obj:setVisible(true)
              widget.top.btn_lingqu.time.num.obj:setText(min..":"..sec)
              receive.resetTime(min,sec)
           end
        end 
   end
   if freeGoldTimer then
      unSchedule(freeGoldTimer)
      freeGoldTimer = nil
   end
   -- freeGoldTimer = schedule(scheduleFunc,1)
   -- scheduleFunc()
   setMailPaoNum()
   -- call("getQuestCountList")
   -- call("getPrivateCharList")
   -- call("getActivityExist")
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end


function onSetDefaultImageSucceed()
  print("onSetDefaultImageSucceed!!!!!!!!!!!!!!!!!!")
   tool.getUserImage(eventHash, widget.top.image.obj, userdata.UserInfo.uidx)
   -- tool.loadRemoteImage(eventHash, widget.top.image.obj, userdata.UserInfo.id)
end

function armatureBlend(armature)
    local fff = ccBlendFunc()
    local f =  {GL_SRC_ALPHA, GL_ONE};
    fff.src = f[1]
    fff.dst = f[2]
    armature:setBlendFunc(fff)
end

function addLight()
   for i=1,2 do
       local list = {}
       local layout = Layout:create()
       layout:setSize(CCSize(2000,2000))
       layout:setPosition(ccp(i==1 and 300 or 880,1900))
       widget.obj:addChild(layout,1)
       for j=1,3 do
           local light = CCSprite:create("cash/qietu/main2/guang0"..i..".png")
           light:setAnchorPoint(ccp(0.5,1.0))
           light:setPosition(ccp(0,0))
           light:setRotation(math.random(1,4))
           light:setScale(1.4)
           armatureBlend(light)
           layout:addNode(light)
           blinkAni(light)
       end
       lightAni(layout)
   end
end

-- function blinkAni(obj)
--    tool.createEffect(tool.Effect.fadeOut,{time=math.random(0.6,1.0)},obj,function()
--       tool.createEffect(tool.Effect.fadeIn,{time=math.random(0.8,1.2)},obj,function()
--          blinkAni(obj)
--          end)
--       end)
-- end

function lightAni(obj)
   -- for i,j in pairs(lightList) do
       local time = math.random(0.5,0.8)
       local rotate = math.random(10,30)
       -- for k,v in pairs(j) do
           tool.createEffect(tool.Effect.rotate,{rotate=rotate,time=time},obj,function()
               tool.createEffect(tool.Effect.delay,{time=math.random(0.5,0.7)},obj,function()
                 tool.createEffect(tool.Effect.rotate,{rotate=rotate*-1,time=time},obj,function()
                    lightAni(obj)
                  end)
               end)
           end)
   --     end
   -- end
end

function rotateAni(obj,time,rotate)
   
   tool.createEffect(tool.Effect.rotate,{rotate=rotate,time=time},obj,function()
       tool.createEffect(tool.Effect.delay,{time=math.random(0.5,0.7)},obj,function()
          tool.createEffect(tool.Effect.rotate,{rotate=rotate*-1,time=time},obj,function()
            rotateAni(obj)
          end)
       end)
   end)
end

function blinkAni(obj)
   if not this or not obj then
      return
   end
   tool.createEffect(tool.Effect.fadeIn,{time=math.random(0.6,1.0)},obj,function()
      tool.createEffect(tool.Effect.fadeOut,{time=math.random(0.8,1.2)},obj,function()
         blinkAni(obj)
      end)
   end)
end

function onGetFreeGold()
   if userdata.goldAction == true then
      userdata.goldAction = false
      goldTimer = schedule(function()
         timerCnt = timerCnt + 1
         if timerCnt > 10 then
            unSchedule(goldTimer)
            goldTimer = nil
            timerCnt = 0
            tool.createEffect(tool.Effect.delay,{time=0.5},widget.obj,function()
               if currenScene and currenScene.resetView then
                  currenScene.resetView()
               end
               initTop()
            end)
            return
         end
         local gold = ImageView:create()
         gold:loadTexture("cash/qietu/tymb/goldIcon.png")
         gold:setPosition(ccp(userdata.goldPos.x,userdata.goldPos.y))
         this:addChild(gold,10)
         tool.createEffect(tool.Effect.move,{time=0.5,x=240,y=1790},gold,function()
            tool.createEffect(tool.Effect.fadeOut,{time=0.1},gold,function()
               gold:removeFromParentAndCleanup(true)
            end)
         end)
     end,0.1)
   end
end

function onChangeGold()
   print("onChangeGold mian!!!!!!!!!!!!!!!!!!!!!!!!",userdata.goldAction)
   if userdata.goldAction == false then 
      initTop()
   end
end

function onGoldAction()
   if userdata.goldAction == true then
       userdata.goldAction = false
        if goldTimer then
           unSchedule(goldTimer)
           goldTimer = nil
        end
       goldTimer = schedule(function()
         timerCnt = timerCnt + 1
         if timerCnt > 10 then
            if goldTimer then
               unSchedule(goldTimer)
               goldTimer = nil
            end
            timerCnt = 0
            tool.createEffect(tool.Effect.delay,{time=0.5},widget.obj,function()
               event.pushEvent("ON_GOLD_ACTION_FINISH")
               initTop()
            end)
            return
         end
         local gold = ImageView:create()
         gold:loadTexture("cash/qietu/tymb/goldIcon.png")
         gold:setPosition(ccp(userdata.goldPos.x,userdata.goldPos.y))
         this:addChild(gold,10)
         tool.createEffect(tool.Effect.move,{time=0.5,x=240,y=1790},gold,function()
            tool.createEffect(tool.Effect.fadeOut,{time=0.1},gold,function()
               gold:removeFromParentAndCleanup(true)
            end)
         end)
     end,0.1)
   else
     initTop()
     event.pushEvent("ON_GOLD_ACTION_FINISH")
   end
end

function setMailPaoNum()
  if userdata.giftList then
     local mainNum = 0
     for k,v in pairs(userdata.giftList) do
         if v.read == 0 then
            mainNum = mainNum + 1
         end
     end
     if mainNum > 0 then
        widget.top_btn_list.youjian.pao.obj:setVisible(true)
        if mainNum > 9 then
           widget.top_btn_list.youjian.pao.num.obj:setText("9+")
        else
           widget.top_btn_list.youjian.pao.num.obj:setText(mainNum)
        end
        activityAni(widget.top_btn_list.youjian.pao.obj)
     else
        widget.top_btn_list.youjian.pao.obj:setVisible(false)
     end 
  end
end

function setRewardPaoNum()
   -- -- if isFirstToReward == false then return end
   -- local rewardNum = 0
   -- local isReached = false
   -- for k,v in pairs(template['quest']) do
   --     local tpl = userdata.UserInfo.hashKey[tostring(k)] 
   --     if tpl == nil then
   --        tpl = 0
   --     end
   --     print("tpl",tpl,v.finishCnt)
   --     local isReached = false
   --     if userdata.UserInfo and userdata.UserInfo.reachedQuest then
   --         for m,n in pairs(userdata.UserInfo.reachedQuest) do
   --             if tonumber(n) == v.id then
   --                isReached = true
   --                break
   --             end
   --         end
   --     end
   --     if v then
   --        if tonumber(tpl) >= v.finishCnt then
   --           if isReached == false then
   --               if v.timeType == 0 then
   --                  rewardNum = rewardNum + 1 
   --               elseif v.timeType == 3 then
   --                  if userdata.UserInfo.timeHashKey[tostring(k)] and timeToDayStart(getSyncedTime()) < userdata.UserInfo.timeHashKey[tostring(k)]/1000 then
   --                     rewardNum = rewardNum + 1
   --                  end
   --               end 
   --           end
   --        end
   --     end
   -- end 
   -- -- print("rewardNum",rewardNum)
   -- if rewardNum > 0 then
   --    widget.top_btn_list.jiangli.pao.obj:setVisible(true)
   --    widget.top_btn_list.jiangli.pao.num.obj:setText(rewardNum)
   --    activityAni(widget.top_btn_list.jiangli.pao.obj)
   -- else
   --    widget.top_btn_list.jiangli.pao.obj:setVisible(false)
   -- end
end

function setLotteryPaoNum()
   -- local randomCnt = userdata.UserInfo.randomCnt
   -- local now = getSyncedTime() 
   -- local time_21 = timeToDayStart(now) + 21*3600
   -- local time_13 = timeToDayStart(now) + 13*3600
   -- local time_21_y = time_21 - 24*3600
   -- if now < time_13 then
   --    now = time_21_y
   -- elseif now < time_21 then
   --    now = time_13 
   -- else
   --    now = time_21
   -- end 
   -- if userdata.UserInfo.lastRandomTime/1000 < now then
   --    randomCnt = 0
   -- end
   -- local vipLv = userdata.UserInfo.viplevel --countLv.getVipLv(userdata.UserInfo.vipExp)
   -- randomCnt = 2 + vipLv - randomCnt
   -- if randomCnt > 0 then
   --    widget.top_btn_list.choujiang.pao.obj:setVisible(true)
   --    widget.top_btn_list.choujiang.pao.num.obj:setText(randomCnt)
   --    if isLotterAction == false then
   --       isLotterAction = true
   --       activityAni(widget.top_btn_list.choujiang.pao.obj)
   --    end
   -- else
   --    if isLotterAction == true then
   --       isLotterAction = false
   --    end
   --    widget.top_btn_list.choujiang.pao.obj:setVisible(false)
   -- end
end

function activityAni(obj)
  if not this then return end
  tool.createEffect(tool.Effect.scale,{time=0.3,scale=1.2},obj,function()
      tool.createEffect(tool.Effect.scale,{time=0.12,scale=1.0},obj,function() 
          tool.createEffect(tool.Effect.delay,{time=math.random(1,5),scale=1.0},obj,function() 
              activityAni(obj) 
          end)
      end)
  end)
end

function enter()

end

function onExit(func)
   if not this then return end
   widget.obj:setVisible(false)
   if func then
      func()
   end
end

function exit()
   if this then
    print("main exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~")
      cleanEvent()
      event.unListen("ON_CHANGE_GOLD",onChangeGold)
      event.unListen("ON_CHANGE_VIP",initTop)
      event.unListen("ON_CHANGE_NAME",initTop)
      event.unListen("ON_BACK",resetBright)
      event.unListen("ON_GET_QUEST",setRewardPaoNum)
      event.unListen("ON_FINISH_QUEST",setRewardPaoNum)
      event.unListen("HEAD_ICON_CHANGE", onSetDefaultImageSucceed)
      event.unListen("ON_UPDATE_QUEST",setRewardPaoNum) 
      event.unListen("ON_UPDATE_MAIL",setMailPaoNum)
      event.unListen("ON_GOLD_ACTION",onGoldAction)
      event.unListen("SYSTEM_CONTEXT", onSystemContext)
      event.unListen("ON_GET_ACTIVITY_EXIST", onGetActivityExist)
      if subWidget ~= nil then          
         subWidget.exit()
         subWidget = nil
      end
      if freeGoldTimer then
         unSchedule(freeGoldTimer)
         freeGoldTimer = nil
      end
      for i,v in pairs(middleList) do
        v.obj  = nil
      end
      if textHandler then
         unSchedule(textHandler)
         textHandler = nil
      end
      if goldTimer then
         unSchedule(goldTimer)
         goldTimer = nil
      end
      if scaleListObj then
         scaleListObj.exit()
         scaleListObj = nil
      end
      if fruitMachine then
         fruitMachine.exit()
      end
      if fishMachine then
         fishMachine.exit()
      end
      if currenScene then
         currenScene.exit()
         currenScene = nil
      end
      beginTime = 0
      isFreeGoldAction = false
      isLotterAction = false
      timerCnt = 0
      min = 0
      sec = 0
      lightList = {}
      isSystemMessagePlaying = false
      systemMessageList = {}
      posList = {}
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
   end
end

function receiveAction()
   if isFreeGoldAction == false then return end
   tool.createEffect(tool.Effect.scale,{time = 0.3,scale=1.1},widget.top.btn_lingqu.Image_10.obj,function()
       tool.createEffect(tool.Effect.scale,{time = 0.3,scale=1},widget.top.btn_lingqu.Image_10.obj,function()
          receiveAction()
       end)
   end)
end

function chongzhiAction()
   tool.createEffect(tool.Effect.scale,{time = 0.5,scale=0.8},widget.top.btn_chongzhi.obj,function()
       tool.createEffect(tool.Effect.scale,{time = 0.5,scale=0.7},widget.top.btn_chongzhi.obj,function()
          chongzhiAction()
       end)
   end)
end

function enterTransitionFinish()
   -- call("enterGame", 0)
   if daily then
      daily = false
      dailyScene.create(widget.obj)
   end
end

function exitTransitionStart()
   
end

function createSubWidget(m)
   if subWidget ~= nil then
      subWidget.exit()
   end
   subWidget = m
   if m ~= nil then
      onExit(function()
         m.create(this,package.loaded["scene.main"])
      end)
   else 
      widget.obj:setVisible(true)
      -- call("getActivityExist")
   end
end

function onYoujian(event)
   if event == "releaseUp" and currenScene ~= smail then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = smail
      switchBottomBright(nil)
      smail.create(widget.obj)
   end
end

function onJiangli(event)
   if event == "releaseUp" and currenScene ~= reward then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      -- if isFirstToReward == true then
      --    isFirstToReward = false
      -- end
      currenScene = reward
      switchBottomBright(nil)
      reward.create(widget.obj)
      -- widget.top_btn_list.jiangli.pao.obj:setVisible(false)
   end
end

function onchoujiang(event)
   if event == "releaseUp" and currenScene ~= lottery then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = lottery
      switchBottomBright(nil)
      lottery.create(widget.obj)
      widget.top_btn_list.choujiang.pao.obj:setVisible(false)
   end
end

function onVIP(event)
   if event == "releaseUp" and currenScene ~= vip then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = vip
      switchBottomBright(nil)
      vip.create(widget.obj)
   end
end

function onTree(event)
   if event == "releaseUp" and currenScene ~= tree then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = tree
      switchBottomBright(nil)
      tree.create(widget.obj)
   end
end

function onKefu(event)
   if event == "releaseUp" and currenScene ~= service then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = service
      switchBottomBright(nil)
      service.create(widget.obj)
   end
end

function onMaoxian(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      print("onMaoxian!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@!@!!!!!!!!!!!",settingVis)
      if settingVis then
         switchSetting()
         currenScene = nil
         switchBottomBright("dating")
      end
      call("enterGame", 1)
   end
end

currenScene = nil
function onShuiguo(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if settingVis then
         switchSetting()
         currenScene = nil
      end
      call("enterGame", 0)
   end
end

function onDating(event)
   if event == "releaseUp" and currenScene ~= nil then
      tool.buttonSound("releaseUp","effect_12")
      if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = nil
      switchBottomBright("dating")
   end
end

function onLingqu(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      currenScene = receive
      receive.create(widget.obj)
      receive.resetTime(min,sec)
   end
end

function onShangcheng(event)
   if event == "releaseUp" and currenScene ~= charge then
      tool.buttonSound("releaseUp","effect_12")
      if widget.bottom.shangcheng.pao.obj:isVisible() then
         widget.bottom.shangcheng.pao.obj:setVisible(false)
         widget.bottom.shangcheng.pao.obj:stopAllActions()
      end
     if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = charge
      switchBottomBright("shangcheng")
      charge.create(widget.obj)
   end
end

function onHuodong(event)
   if event == "releaseUp" and currenScene ~= activity  then
      tool.buttonSound("releaseUp","effect_12")
     if currenScene then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = activity
      switchBottomBright("huodong")
      activity.create(widget.obj)
   end
end

function onPaihang(event)
   if event == "releaseUp" and currenScene ~= rank then
      tool.buttonSound("releaseUp","effect_12")
      local goRank = function()
        if currenScene then
          currenScene.exit()
          currenScene = nil
        end
        currenScene = rank
        switchBottomBright("paihang")
        rank.create(widget.obj)
      end
      if platform == "IOS" then
        if UserSetting and UserSetting["rank"] and UserSetting["rank"] == "1" then
          goRank()
        else
          alert.create("进入排行需要上传个人信息至服务器",nil,goRank,nil,"确定","取消")
          saveSetting("rank", "1")
        end
      else
        goRank()
      end
   end
end
shezhiScene = {
  exit = function ()
      settingVis = false
      switchSetting()
       switchBottomBright("dating")
  end
}
function onShezhi(event)
   if event == "releaseUp"  then
        tool.buttonSound("releaseUp","effect_12")
      if currenScene and currenScene ~= shezhiScene then
        currenScene.exit()
        currenScene = nil
      end
      -- if widget.bottom.shezhi.pao.obj:isVisible() then
      --    widget.bottom.shezhi.pao.obj:setVisible(false)
      --    widget.bottom.shezhi.pao.obj:stopAllActions()
      -- end
      settingVis = not settingVis
      switchSetting()
      if settingVis then
        switchBottomBright("shezhi")
        currenScene = shezhiScene
      else
         currenScene = nil
        switchBottomBright("dating")
      end
   end
end
middleList ={
  -- {img = "image/game01.png",call = function ()
  --       tool.buttonSound("releaseUp","effect_12")
  --       if settingVis then
  --          -- switchSetting()
  --          settingVis = false
  --          widget.bottom.setting_panel.obj:setVisible(false)
  --          for i=1,settingMax do
  --              widget.bottom.setting_panel['btn'..i].obj:setTouchEnabled(false)
  --              widget.bottom.setting_panel['btn'..i].pos = tool.getPosition(widget.bottom.setting_panel['btn'..i].obj)
  --          end
  --          currenScene = nil
  --          switchBottomBright("dating")
  --       end
  --       gameLoading.gameTitle = 1
  --       createSubWidget(widgetID.gameLoading)
  --       call("enterGame", 0)
  -- end},
  {img = "image/game02.png",call = function ()
        tool.buttonSound("releaseUp","effect_12")
        if settingVis then
           -- switchSetting()
           settingVis = false
           widget.bottom.setting_panel.obj:setVisible(false)
           for i=1,settingMax do
               widget.bottom.setting_panel['btn'..i].obj:setTouchEnabled(false)
               widget.bottom.setting_panel['btn'..i].pos = tool.getPosition(widget.bottom.setting_panel['btn'..i].obj)
           end
           currenScene = nil
           switchBottomBright("dating")
        end
        -- gameLoading.gameTitle = 2
        -- createSubWidget(widgetID.gameLoading)
        call(6001, 1)
  end},
  -- {img = "image/game03.png",call = function ()
  --       tool.buttonSound("releaseUp","effect_12")
  --       if settingVis then
  --          -- switchSetting()
  --          settingVis = false
  --          widget.bottom.setting_panel.obj:setVisible(false)
  --          for i=1,settingMax do
  --              widget.bottom.setting_panel['btn'..i].obj:setTouchEnabled(false)
  --              widget.bottom.setting_panel['btn'..i].pos = tool.getPosition(widget.bottom.setting_panel['btn'..i].obj)
  --          end
  --          currenScene = nil
  --          switchBottomBright("dating")
  --       end
  --       gameLoading.gameTitle = 3
  --       createSubWidget(widgetID.gameLoading)
  --       call("enterGame", 3)
  -- end},

}

scaleListObj = nil
function initMiddle()
   scaleListObj = scaleList.create(widget.middle.obj,540,widget.middle.center.obj:getPositionY(),0,package.loaded["scene.main"],nil)
   widget.middle.center.obj:setVisible(false)
   widget.middle.page.obj:setVisible(false)
   widget.middle.page.obj:setTouchEnabled(false)

   local diff = 120
   local startX = 540 - (#middleList-1)/2*diff
   for i = 1,#middleList do
      middleList[i].obj = nil
  end
   for i = 1,#middleList do
        local info = middleList[i]
        local obj = widget.middle.center.obj:clone()
        obj = tolua.cast(obj,"ImageView")
        obj:loadTexture(info.img)
        obj:setVisible(true)
        obj:setTouchEnabled(true)
        info.obj = obj
       
        local page = widget.middle.page.obj:clone()
        page:setVisible(true)
       
        widget.middle.obj:addChild(page,30)
        page:setPositionX(startX + diff*(i-1))
        info.page = tolua.cast(page,"Button")

        scaleListObj.pushItem(obj,nil,info.call)
   end
end
function changeSelectedItem()
    for i = 1,#middleList do
      local info = middleList[i]
     -- printTable(info)
       if info.obj  then
        if i ~= scaleListObj.middleIndex  then
            info.obj:setColor(ccc3(128,128,128))
            info.page:setBright(true)
        else
            info.obj:setColor(ccc3(255,255,255))
            info.page:setBright(false)
        end
      end
    end
end
function initTop()
  widget.top.name.obj:setText(userdata.UserInfo.nickName)
  widget.top.gold.gold_num.obj:setStringValue(userdata.UserInfo.owncash)
  -- local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
  widget.top.vip.vip_num.obj:setStringValue(userdata.UserInfo.viplevel)
end
function initTips()
  local mailNum = 0
  local questNum = 11
  local randomNum = 1



  local list = {
    {num = mailNum,obj = widget.top_btn_list.youjian},
    {num = questNum,obj = widget.top_btn_list.jiangli},
    {num = randomNum,obj = widget.top_btn_list.choujiang},
  } 
  for _,v in pairs(list) do
      local num = v.num
      if num <= 0 then
        v.obj.pao.obj:setVisible(false)
      else
        if num > 9 then
           num = "9+"
        end
        v.obj.pao.obj:setVisible(true)
        v.obj.pao.num.obj:setText(num)
      end
  end
end
settingVis = false
settingMax = 5
function initSetting()
    settingVis = false
   local parent =  widget.bottom.setting_panel
   parent.obj:setVisible(false)
   for i=1,settingMax do
      parent['btn'..i].obj:setTouchEnabled(false)
      parent['btn'..i].pos = tool.getPosition(parent['btn'..i].obj)
      posList[i] = tool.getPosition(parent['btn'..i].obj)
    end
end
function  switchSetting( ... )
  local parent =  widget.bottom.setting_panel
  if settingVis then
    parent.obj:setVisible(true)
     for i=1,settingMax do
        local btn = parent['btn'..i]
        tool.setPosition(btn.obj,parent['btn1'].pos)
        tool.createEffect(tool.Effect.move,{time=0.2,x=btn.pos.x,y=btn.pos.y,easeIn=true},btn.obj,function ()
            btn.obj:setTouchEnabled(true)
        end)
     end
  else
     
     parent.obj:setVisible(false)
     for i=1,settingMax do
        parent['btn'..i].obj:setTouchEnabled(false)
        parent['btn'..i].pos = posList[i]--tool.getPosition(parent['btn'..i].obj)
      end
  end
end

local BottomBtnList = {
  "dating","shangcheng","huodong","paihang","shezhi",
}
function switchBottomBright(btnName)
  for _,v in pairs(BottomBtnList) do
      widget.bottom[v].obj:setBright(true)
  end
  if btnName then
     widget.bottom[btnName].obj:setBright(false)
  end
end

function resetBright()
  print("resetBright")
   currenScene = nil
   switchBottomBright("dating")
end

announceId = 1
annoneList = {
  {id=-1,text="很牛逼，啊哈哈哈哈哈哈哈。。。。。",limitTime = -1},
  {id=-1,text="超级。。。",limitTime = -1},
  {id=-1,text="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",limitTime = -1}
}
announceWidth = 0

function rollText(obj, func)
   if not this or not obj then
        return
   end
   local w = obj:getSize().width
   if obj:getPositionX() <= announceWidth and obj:getPositionX() >= -w then
    obj:setPositionX(obj:getPositionX() - 2)
   else
    obj:setPositionX(announceWidth)
     if func then
      func()
     end
   end
end
function getNextAnnone()
  while true do
    announceId = announceId + 1
    if announceId > #annoneList then
      announceId = 1
    end
    if annoneList[announceId] then
      local info = annoneList[announceId] 
      if info.limitTime <0 or info.limitTime > os.time() then
        break
      end
    end
  end
  return annoneList[announceId].text
end
textHandler = nil
function initAnnone()
  announceWidth = widget.top.text.obj:getSize().width
  announceId = 0

  local show  = nil
  show = function ()
    widget.top.text.label.obj:setText(getNextAnnone())
    widget.top.text.label.obj:setPositionX(20)
    if textHandler then
       unSchedule(textHandler)
       textHandler = nil
    end
    textHandler = performWithDelay(function ()
           if not this then 
              if textHandler then
                 unSchedule(textHandler)
                 textHandler = nil
              end
              return 
           end
           textHandler = schedule(function ()
               if not this then 
                  if textHandler then
                     unSchedule(textHandler)
                     textHandler = nil
                  end
                  return 
               end
               rollText(widget.top.text.label.obj, function ()
                      unSchedule(textHandler)
                     show()
               end)
             end,0.01)
      end,1.5)
  end
  show()
end

function pushAnnone(id,text,limitTime)
  table.insert(annoneList, {id=id,text=text,limitTime=limitTime} )
end
function delAnnone(id)
  for _,v in pairs(annoneList) do
      if v.id == id then
        v.limitTime = 0
      end
  end
end
function onSelfInfo(event)
   print("onSetDefaultImageSucceed")
   if event == "releaseUp" and currenScene ~= selfInfo then
      if currenScene  then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = selfInfo
      tool.buttonSound("releaseUp","effect_12")
      -- onShezhi("releaseUp")
      switchBottomBright("dating")
      selfInfo.create(widget.obj)
   end
end
function onSetting(event)
   if event == "releaseUp" and currenScene ~= setting then
      if currenScene  then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = setting
      tool.buttonSound("releaseUp","effect_12")
      -- onShezhi("releaseUp")
      switchBottomBright("dating")
      setting.create(widget.obj)
   end
end
function onBinding(event)
   if event == "releaseUp" and currenScene ~= binding then
      if currenScene  then
        currenScene.exit()
        currenScene = nil
      end
      if widget.bottom.setting_panel.btn2.pao.obj:isVisible() then
         widget.bottom.setting_panel.btn2.pao.obj:setVisible(false)
         widget.bottom.setting_panel.btn2.pao.obj:stopAllActions()
         widget.bottom.shezhi.pao.obj:setVisible(false)
         widget.bottom.shezhi.pao.obj:stopAllActions()
      end
      currenScene = binding
      tool.buttonSound("releaseUp","effect_12")
      -- onShezhi("releaseUp")
      switchBottomBright("dating")
      binding.create(widget.obj)
   end
end
function onAbout(event)
   if event == "releaseUp" and currenScene ~= about then
      if currenScene  then
        currenScene.exit()
        currenScene = nil
      end
      currenScene = about
      tool.buttonSound("releaseUp","effect_12")
      -- onShezhi("releaseUp")
      switchBottomBright("dating")
      about.create(widget.obj)
   end
end
function onChatHistory(event)
   if event == "releaseUp" and currenScene ~= chatHistory then
      if currenScene  then
         currenScene.exit()
         currenScene = nil
      end
      currenScene = chatHistory
      tool.buttonSound("releaseUp","effect_12")
      -- onShezhi("releaseUp")
      switchBottomBright("dating")
      chatHistory.create(widget.obj)
   end
end
widget = {
   _ignore = true,
   bg = {_type = "ImageView"},
   top = {_type = "ImageView",
     vip = {_type = "ImageView",
        vip_num = {_type = "LabelAtlas"},
     },
     name = {_type = "Label"},
     gold = {_type = "ImageView",
        gold_num = {_type = "LabelAtlas"},
     },
     btn_lingqu = {_type = "Button",_func = onLingqu,
        Image_10 = {_type = "ImageView"},
        time = {
           _type = "ImageView",
           num = {_type = "Label"},
        },
     },
     btn_chongzhi = {_type = "Button",_func = onShangcheng},
     text = {_type = "Layout"},
     send = {_type = "Button", text = {_type="Label"},},
     image = {_type = "ImageView"},
   },

 
   top_btn_list = {
      jiangli = {
          _type = "Button",_func = onJiangli,
          pao = {_type = "ImageView",
             num = {_type = "Label"},
          },
      },
      choujiang = {
        _type = "Button",
        _func = onchoujiang,
          pao = {_type = "ImageView",
             num = {_type = "Label"},
          },
      },
      VIP = {_type = "Button",_func = onVIP},
      kefu = {_type = "Button",_func = onKefu},
      youjian = {_type = "Button",
          pao = {_type = "ImageView",
             num = {_type = "Label"},
          },
          _func = onYoujian,
      },
      yaoqianshu = {_type = "Button",_func = onTree},
   },
   middle = {
      center = {_type="ImageView",},
      page = {_type = "Button"},
   },
   bottom = {
       dating = {_type = "Button",_func = onDating},
       shangcheng = {_type = "Button",
          _func = onShangcheng,
          pao = {_type = "ImageView"},
       },
       huodong = {_type = "Button",
          _func = onHuodong,
          pao = {_type = "ImageView"},
       },
       paihang = {_type = "Button",_func = onPaihang},
       shezhi = {_type = "Button",
          _func = onShezhi,
          pao = {_type = "ImageView"},
       },
       setting_panel = {
          btn1 = {_type = "Button",_func =  onAbout},
          btn2 = {_type = "Button",_func =  onBinding,pao = {_type = "ImageView"},},
          btn3 = {_type = "Button",_func =  onSetting},
          btn4 = {_type = "Button",_func =  onSelfInfo},
          btn5 = {_type = "Button",_func =  onChatHistory},
       },
   },
}
