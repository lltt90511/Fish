local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local chat = require"scene.chat.main"
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require "logic.countLv"
local http = require"logic.http"

module("scene.fishMachine.main", package.seeall)

this = nil 
thisParent = nil
parentModule = nil
local data = {}
local autoArr = {50,10,5}
local autoIndex = 1
local singleArr = {100000,50000,10000,5000,1000}
local singleIndex = 5
local fishTimer = nil
local nextTimer = nil
local betList = {}
local isPlaying = false
local betOwn = {}
local historyBet = {}
local autoCnt = 0
local winGold = 0
local lastOpenId = {inside=0,outside=0}
local classicOutSide = {}
local chatView = nil
local cdEffectPlaying = false
local starNum = 7
local resultLight = nil
local historyList = {}
local eventHash = {}
local bigList = {}
local isBig = false
local longPressHandler = nil
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
local resetUserTimer = nil
local userRankList = {}
local totalUserNum = 0

local fishList = {
  [1]={id = 1,name = '大捕获',res = '0',fishType = 0,seqId = 12,multi = 0.0,multiEffect = '8,4,10,2'},
  [2]={id = 2,name = '小捕获',res = '0',fishType = 1,seqId = 6,multi = 0.0,multiEffect = ''},
  [3]={id = 3,name = '鲨鱼',res = '05',fishType = 2,seqId = 2,multi = 50.0,multiEffect = ''},
  [4]={id = 4,name = '魔鬼鱼',res = '02',fishType = 2,seqId = 4,multi = 20.0,multiEffect = ''},
  [5]={id = 5,name = '灯笼鱼',res = '013',fishType = 2,seqId = 8,multi = 10.0,multiEffect = ''},
  [6]={id = 6,name = '海龟',res = '07',fishType = 2,seqId = 10,multi = 5.0,multiEffect = ''},
  [7]={id = 7,name = '烛光鱼',res = '011',fishType = 2,seqId = 3,multi = 0.0,multiEffect = ''},
  [8]={id = 8,name = '珊瑚鱼',res = '01',fishType = 2,seqId = 1,multi = 0.0,multiEffect = ''},
  [9]={id = 9,name = '海豚',res = '04',fishType = 2,seqId = 9,multi = 0.0,multiEffect = ''},
  [10]={id = 10,name = '水母',res = '08',fishType = 2,seqId = 5,multi = 0.0,multiEffect = ''},
  [11]={id = 11,name = '蝴蝶鱼',res = '015',fishType = 2,seqId = 7,multi = 0.0,multiEffect = ''},
  [12]={id = 12,name = '海星',res = '03',fishType = 2,seqId = 11,multi = 0.0,multiEffect = ''},
  [13]={id = 13,name = '对虾',res = '012',fishType = 3,seqId = 1,multi = 1.5,multiEffect = ''},
  [14]={id = 14,name = '螃蟹',res = '010',fishType = 3,seqId = 2,multi = 1.5,multiEffect = ''},
  [15]={id = 15,name = '对虾',res = '012',fishType = 3,seqId = 3,multi = 1.5,multiEffect = ''},
  [16]={id = 16,name = '螃蟹',res = '010',fishType = 3,seqId = 4,multi = 1.5,multiEffect = ''},
  [17]={id = 17,name = '对虾',res = '012',fishType = 3,seqId = 5,multi = 1.5,multiEffect = ''},
  [18]={id = 18,name = '螃蟹',res = '010',fishType = 3,seqId = 6,multi = 1.5,multiEffect = ''},
}
function create(_parent, _parentModule)
   thisParent = _parent
   parentModule = _parentModule 
   this = tool.loadWidget("cash/fish_machine",widget, thisParent)
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
   initClassicOutSide()
   initView()
   initResult()
   initChatView()
   totalCashGold = 0
   lastUserGold = 0--userdata.UserInfo.giftGold + userdata.UserInfo.gold
   bigList.id = 0
   bigList.name = ""
   bigList.exp = 0
   bigList.gold = 0
   currentUserPage = 1
   widget.bigAward.obj:setVisible(false)
   widget.bigAward.obj:setScale(0)
   widget.history_layout.obj:setVisible(false)
   widget.history_layout.obj:setTouchEnabled(false)
   widget.history_layout.alert.back.obj:setTouchEnabled(false)
   event.listen("ON_GET_GAME_STATUS",onGetGameStatus)
   event.listen("ON_BET_SUCCEED", onBetSucceed)
   event.listen("ON_BET_FAILED", onBetFailed)
   event.listen("ON_ENTER_GAME_NOTICE", onEnterGameNotice)
   event.listen("ON_EXIT_GAME_NOTICE", onExitGameNotice)
   event.listen("ON_GET_USER_LIST_SUCCEED", onGetUserListSucceed)
   event.listen("ON_GET_USER_LIST_FAILED", onGetUserListFailed)
   -- setCashGold(0)
   -- if userdata.isFirstGame==1 then
   --    widget.bottom_bg.alert.obj:setVisible(true)
   --    alertFunc(widget.bottom_bg.alert.obj)
   -- else
   --    widget.bottom_bg.alert.obj:setVisible(false)
   -- end
   widget.bottom_bg.rank_list.obj:registerEventScript(function(event)
     -- print("event!!!!!!!!!",event)
     if event == "SCROLL_BOTTOM" then
        print("SCROLL_BOTTOM!!!!!!!!!!!!!!!!!!")
        currentUserPage = currentUserPage + 1
        call(6101,currentUserPage)
     end
   end)
   widget.bottom_bg.alert.obj:setVisible(false)
   call(6101,currentUserPage)
   return this
end

function initRankView(_list)
   for k,v in pairs(_list) do   
       addRankItem(v)
   end
end

function addRankItem(item,index)       
   local obj = widget.rank_render.obj:clone()
   obj:setTouchEnabled(true)
   obj:registerEventScript(function(event)
      if event == "releaseUp" then
          
      end 
   end)
   local rank_img = tool.findChild(obj,"rank_img","ImageView")
   rank_img:setScale(0.8)
   -- tool.loadRemoteImage(eventHash, rank_img, userdata.UserInfo.uidx)
   -- local vipLv = countLv.getVipLv(v.score)
   -- if vipLv == 0 then
   --    vipLv = 1
   -- end
   local name = tool.findChild(obj,"name","Label")
   name:setText(item._nickName)
   local bonus = tool.findChild(obj,"bonus","Label")
   bonus:setText("VIP"..item._vip)
   local rank_atlas = tool.findChild(obj,"rank_atlas","LabelAtlas")
   rank_atlas:setVisible(false)
   if index and type(index) == type(0) then
      widget.bottom_bg.rank_list.obj:insertCustomItem(obj,index)
   else
      widget.bottom_bg.rank_list.obj:pushBackCustomItem(obj)
   end
end

function removeRankItem(index)
   widget.bottom_bg.rank_list.obj:removeItem(index)
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
      endNextTimer()
      toNextTime = 10
      if isDoBet then
         isDoBet = false 
      end
      betEndTime = 20 - data.time
      widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
      widget.bottom_bg.auto_layout.obj:setVisible(false)
   elseif data.type == 200 then
      -- widget.bottom_bg.auto_layout.obj:setTouchEnabled(true)
      -- widget.bottom_bg.auto_layout.obj:setVisible(true)
      -- widget.bottom_bg.auto_layout.label.obj:setText("开奖中......")
      widget.bottom_bg.time_atlas.obj:setStringValue("00")
      playFishEffect()
   elseif data.type == 201 then
      endNextTimer()
      nextTimer = schedule(
         function()
            toNextTime = toNextTime - 1
            if isDoBet then
               return 
            end
            widget.bottom_bg.auto_layout.label.obj:setText("等待开始...还剩"..toNextTime.."秒")
            if toNextTime == 0 then
               toNextTime = 10
               widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
               widget.bottom_bg.auto_layout.obj:setVisible(false)
               endNextTimer()
            end
         end,1)
   end
end

function onBetSucceed(_data)
   if not isBet[_data.betid] then
      isBet[_data.betid] = true
   end
   if not isDoBet then
      isDoBet = true
   end
   onGameUserActionSucceed(_data.betid,_data.betMoney)
end

function onBetFailed(_data)
   alert.create(_data.msg)  
end

function onEnterGameNotice(_data)
   print("onEnterGameNotice")
   printTable(_data)
   if _data.user._uidx == userdata.UserInfo.uidx then
      return
   end
   table.insert(userRankList,_data.index,_data.user)
   addRankItem(_data.user,_data.index)
end

function onExitGameNotice(_data)
   print("onExitGameNotice")
   printTable(_data)
   printTable(userRankList)
   local index = 0
   for k,v in pairs(userRankList) do
       printTable(v)
       if tonumber(v._uidx) == tonumber(_data.user._uidx) then
          break
       end
       print("!!!!!!!!!!!!!!!!!!!",v._uidx,_data.user._uidx,index)
       index = index + 1
   end
   print("index!!!!!!!!!!!!!!!!!!!!!!!!",index,#userRankList)
   if index < #userRankList then
      table.remove(userRankList,index)
      removeRankItem(index)
   end   
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

function onGetUserListFailed(_data)
   
end

function resetShowChatHistory(flag) 
   commonTop.isShowChatHistory = flag
end

function initView()
   for k, v in pairs(fishList) do
      if v.fishType == 0 then
         widget.game_bg.outside["item12"].effect.obj:setVisible(false)
         widget.game_bg.outside["item12"].img.obj:setScale(1.3)
         widget.game_bg.outside["item12"].img.obj:loadTexture("cash/qietu/tymb/dapuhuo.png")
      elseif v.fishType == 1 then
         widget.game_bg.outside["item6"].effect.obj:setVisible(false)
         widget.game_bg.outside["item6"].img.obj:setScale(1.3)
         widget.game_bg.outside["item6"].img.obj:loadTexture("cash/qietu/tymb/xiaopuhuo.png")
      elseif v.fishType == 2 then
         widget.game_bg.outside["item"..v.seqId].effect.obj:setVisible(false)
         widget.game_bg.outside["item"..v.seqId].img.obj:loadTexture("fish/fish"..v.res..".png")
      elseif v.fishType == 3 then      
         widget.game_bg.inside["item"..v.seqId].effect.obj:setVisible(false)           
         widget.game_bg.inside["item"..v.seqId].img.obj:loadTexture("fish/fish"..v.res..".png")
      end
   end 
   widget.cd_img.obj:setVisible(false)
   -- local light = CCSprite:create("cash/qietu/effect/guang.png")
   -- light:setPosition(ccp(20,70))
   -- light:setScale(0.3)
   -- armatureBlend(light)
   -- widget.cd_img.obj:addNode(light)
   -- local action = CCRotateBy:create(0.5,60)
   -- action = CCRepeatForever:create(action)
   -- light:runAction(action)

   widget.bottom_bg.win_atlas.obj:setStringValue(0)
   widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
   widget.bottom_bg.auto_layout.obj:setVisible(false)
   -- widget.bottom_bg.auto_layout.obj:registerEventScript(function(event)
   --                                                         if event == "releaseUp" then
   --                                                            tool.buttonSound("releaseUp","effect_12")
   --                                                            autoCnt = 0
   --                                                            widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
   --                                                            widget.bottom_bg.auto_layout.obj:setVisible(false)
   --                                                         end
   --                                                      end
   -- )

   initCostView()
   
   startFishTimer()
   if data.type == 200 then
      playFishEffect()
   elseif data.type == 201 then
      widget.bottom_bg.auto_layout.obj:setTouchEnabled(true)
      widget.bottom_bg.auto_layout.obj:setVisible(true)
      widget.bottom_bg.auto_layout.label.obj:setText("开奖中，请稍后...")
   end
   widget.bottom_bg.bet_list.obj:setVisible(true)
   widget.bottom_bg.bet_list.obj:setTouchEnabled(false)
   widget.bottom_bg.bet_list.obj:setItemModel(widget.bet_render.obj)
   widget.bottom_bg.bet_list.obj:removeAllItems()
   local cnt = 0
   local arr = {3,4,5,6,13,14}
   for i = 1,#arr do
      isBet[arr[i]] = false
      local typeTmp = fishList[arr[i]]
      
      widget.bottom_bg.bet_list.obj:pushBackDefaultItem()
      local v = {obj = tolua.cast(widget.bottom_bg.bet_list.obj:getItem(cnt),"Layout"), index = arr[i]}
      v.img = tool.findChild(v.obj, "img", "ImageView")
      v.img:setScale(0.8)
      v.num = tool.findChild(v.obj, "num", "Label")
      v.my_num = tool.findChild(v.obj, "my_num", "Label")
      v.total_num = tool.findChild(v.obj, "total_num", "Label")
      local info = {cnt = arr[i],index = singleIndex}
      v.obj:setTouchEnabled(true)
      v.obj:registerEventScript(function(ev,data)
                          if isBet[arr[i]] then
                             return
                          end
                          if ev == "releaseUp" then
                             tool.buttonSound("releaseUp","effect_12")
                             bet(arr[i], singleArr[singleIndex])
                          end
      end)
      if i == 1 then
         v.img:setScale(0.45)
      elseif i == 2 then
         v.img:setScale(0.5)
      end
      v.img:loadTexture("fish/fish"..typeTmp.res..".png")
      v.num:setText("x"..typeTmp.multi)
      v.my_num:setText("0")
      v.total_num:setText("0")
      
      cnt = cnt + 1
      table.insert(betList,v)
   end
   if data.info and type(data.info) == type({}) then
      for k, v in pairs(data.info) do
          onGameUserActionSucceed(v.id,v.money)
      end
   end
   refreshBetTotal()
end

function initCostView()
   widget.bottom_bg.auto_list_layout.obj:setTouchEnabled(false)
   widget.bottom_bg.cost_layout.single_cost.obj:setText("单注："..singleArr[singleIndex])
   widget.bottom_bg.list_layout.bg.obj:setPosition(ccp(0,max_list_y))
   local pushOrPullfunc = function()
      local posY = widget.bottom_bg.list_layout.bg.obj:getPositionY()
      if posY == max_list_y then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.bottom_bg.list_layout.bg.obj)
      elseif posY == 0 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.bottom_bg.list_layout.bg.obj)
      end
   end    
   -- local maxListNum = 5
   -- local vipLv = 0
   local maxSingleGold = 5000000
   -- if countLv.getVipLv(userdata.UserInfo.vipExp) then
   --    vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
   -- end
   -- if template['vipExp'][vipLv] then
   --    maxSingleGold = template['vipExp'][vipLv].betLimit * 10000
   -- end
   for i = 1, 5 do 
       if singleArr[i] <= maxSingleGold then
          widget.bottom_bg.list_layout.bg["label"..i].obj:setTouchEnabled(true)
          widget.bottom_bg.list_layout.bg["label"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 tool.buttonSound("releaseUp","effect_12")
                 singleIndex = i
                 userdata.lastFishSingleIndex = singleIndex
                 saveSetting("fishIndex",singleIndex)
                 widget.bottom_bg.cost_layout.single_cost.obj:setText("单注："..singleArr[singleIndex])
                 pushOrPullfunc()
              end
           end)
       else
          -- widget.bottom_bg.list_layout.bg["label"..i].obj:setColor(ccc3(255,255,255))
          -- widget.bottom_bg.list_layout.bg["label"..i].obj:setTouchEnabled(true)
          -- widget.bottom_bg.list_layout.bg["label"..i].obj:registerEventScript(function(event)
          --     if event == "releaseUp" then
          --        tool.buttonSound("releaseUp","effect_12")
          --        pushOrPullfunc()
          --        alert.create("VIP等级不够，不能下注此金额，请升级您的VIP等级！！",nil,function()
          --             commonTop.onRecharge("releaseUp")
          --         end,nil,"确定","取消")
          --     end
          --  end)
       end
   end
   widget.bottom_bg.cost_layout.obj:setTouchEnabled(true)
   widget.bottom_bg.cost_layout.obj:registerEventScript(
      function(event)
         if event == "releaseUp" then
            tool.buttonSound("releaseUp","effect_12")
            pushOrPullfunc()
         end
      end
   )
   widget.bottom_bg.auto_list_layout.list_view.obj:setPosition(ccp(0,max_list_y))
   local autoFunc = function()
      local posY = widget.bottom_bg.auto_list_layout.list_view.obj:getPositionY()
      if posY == max_list_y then
         -- widget.bottom_bg.auto_list_layout.obj:setTouchEnabled(true)
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.bottom_bg.auto_list_layout.list_view.obj)
      elseif posY == 0 then
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.bottom_bg.auto_list_layout.list_view.obj)
      end
   end
   for i = 1, 3 do 
      widget.bottom_bg.auto_list_layout.list_view["img_"..i].obj:setTouchEnabled(true)
      widget.bottom_bg.auto_list_layout.list_view["img_"..i].obj:registerEventScript(function(event)
          if event == "releaseUp" then
             tool.buttonSound("releaseUp","effect_12")
             autoIndex = i
             onAutoBet(event)
             autoFunc()
          end
       end
      )
   end
   widget.bottom_bg.auto_btn.obj:setTouchEnabled(true)
   widget.bottom_bg.auto_btn.obj:registerEventScript(
      function(event)
      -- print("event",event)
         if event == "releaseUp" then
            -- tool.buttonSound("releaseUp","effect_12")
            -- autoFunc()
            -- call(11001,20038626,0,"is a message!")
         end
      end
   )
   -- local now = getSyncedTime()
   -- local time = math.floor(data.clickEndTime - now)
   -- if data.type == 100 and data.time > 3 then
   --    changeTouchEnabled(true)
   -- else
   --    changeTouchEnabled(false)
   -- end
   changeTouchEnabled(true)
end

function onBigWin(id,name,exp,gold)
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
   tool.loadRemoteImage(eventHash, widget.bigAward.head.obj, bigList.id)
   widget.bigAward.name.obj:setText(bigList.name)
   -- local vipLv = countLv.getVipLv(bigList.exp)
   widget.bigAward.vipNum.obj:setStringValue(0)
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

function refreshHistory()
   for k, v in pairs(historyList) do
      if v and v.obj then
         v.obj:removeFromParentAndCleanup(true)
      end
   end
   historyList = {}
   -- printTable(data,history)
   local historyLayoutSize = widget.history_layout.obj:getSize()
   if data.history and type(data.history) == type({}) then
      for i = 1,#data.history do
         local typeTmp_in = nil
         local typeTmp_out = nil
         for k,v in pairs(template["classic"]) do
             if v.gameId == 2 and v.seqId == data.history[i]["in"] then
                typeTmp_in = template["classicType"][v.type]
             elseif v.gameId == 3 and v.seqId == data.history[i]["out"] then
                typeTmp_out = template["classicType"][v.type]
             end
         end

         -- for k,v in pairs(fishList) do
         --     if v.fishType == 1 and v.id == data.history[i]["in"] then
         --        typeTmp_in = fishList[v.id]
         --     elseif v.fishType == 2 and v.id == data.history[i]["out"] then
         --        typeTmp_out = fishList[v.id]
         --     end
         -- end

         local v = {obj = tolua.cast(widget.tmp.obj:clone(), "ImageView")}
         local img_in = tool.findChild(v.obj, "img_in", "ImageView")
         local img_out = tool.findChild(v.obj, "img_out", "ImageView")
         local new = tool.findChild(v.obj,"new","ImageView")

         img_in:loadTexture("fish/fish"..typeTmp_in.res.."_h.png")
         img_out:loadTexture("fish/fish"..typeTmp_out.res.."_h.png")
         new:setVisible(i == 1)

         local posX = (i - 1) * 158 - 363
         local posY = 100
         widget.history_layout.alert.obj:addChild(v.obj)
         v.obj:setPosition(ccp(posX,posY))
         
         table.insert(historyList, v)
      end
   end
   if #historyUserGold > 0 then
      widget.history_layout.alert.listView.obj:removeAllItems()
      local titleLabel = Label:create()
      titleLabel:setFontSize(40)
      titleLabel:setText("个人中奖纪录：")
      widget.history_layout.alert.listView.obj:pushBackCustomItem(titleLabel)
      local cnt = 1
      for i=1,#historyUserGold do
          local label = Label:create()
          label:setFontSize(40)
          label:setText(cnt.."."..historyUserGold[i].."  ")
          widget.history_layout.alert.listView.obj:pushBackCustomItem(label)
          cnt = cnt + 1
      end
   end
   if not data.lastBigTime or (data.lastBigTime and data.lastBigTime == 0) then
      widget.history_layout.alert.time.obj:setText("还未开出鲨鱼")
   else
     local time = getSyncedTime() - data.lastBigTime/1000
     -- print("refreshHistory",time,getSyncedTime(),data.lastBigTime)
     if math.floor(time/(3600*24)) > 0 then
        widget.history_layout.alert.time.obj:setText(math.floor(time/3600/24).."天前开出鲨鱼")
     elseif math.floor(time/3600) > 0 then
        widget.history_layout.alert.time.obj:setText(math.floor(time/3600).."小时前开出鲨鱼")
     elseif math.floor(time/60) > 0 then
        widget.history_layout.alert.time.obj:setText(math.floor(time/60).."分钟前开出鲨鱼")
     else
        widget.history_layout.alert.time.obj:setText(math.floor(time).."秒前开出鲨鱼")
     end
   end
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

function doResultAni(id) 
   AudioEngine.playEffect("effect_05")
   local classicTmp = nil
   for k,v in pairs(template["classic"]) do
       if v.gameId == 3 and v.seqId == id then
          classicTmp = v
       end
   end
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
   local typeTmp = template["classicType"][classicTmp.type]
   if not typeTmp then
      typeTmp = template["classicType"][11]
   end
   widget.result.icon.obj:loadTexture("fish/fish"..typeTmp.res.."d.png")
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
                     startFishTimer()
                  end)
               end)
            end)
         end)
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
   -- local id = name == "inside" and _id["in"] or _id["out"]
   local st = lastOpenId[name]
   local delay = name == "inside" and 0.1 or 0.2
   if widget.game_bg[name]["item"..st] ~= nil then
      widget.game_bg[name]["item"..st].effect.obj:setVisible(false)
   end
   st = st >= maxNum and 1 or st + 1
   -- local totalCnt = maxNum*8 -lastOpenId[name] + id
   local slowNum = name == "inside" and 2 or 4
   -- local totalDelay = 10
   -- local c1,c2 = totalCnt*totalCnt/4, totalCnt*totalCnt*3/4
   -- for i = 1, totalCnt-1 do
   --    if i < slowNum or i > totalCnt - slowNum then
   --       totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c1
   --    else 
   --       totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c2
   --    end
   -- end
   -- local per = name == "inside" and 4/totalDelay or 4/totalDelay

   local func = nil
   func = function()
      widget.game_bg[name]["item"..st].effect.obj:setVisible(true)
      widget.game_bg[name]["item"..st].effect.obj:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay}, widget.game_bg[name]["item"..st].effect.obj,
                        function()
                           widget.game_bg[name]["item"..st].effect.obj:setOpacity(255)
                           widget.game_bg[name]["item"..st].effect.obj:stopAllActions()

                           local _st = st
                           if data.type == 201 then
                              local resultCnt = name == "inside" and data.GameResult.f[2]-12 or data.GameResult.f[1]
                              delay = 0.4
                              if st == resultCnt then
                                 finishCircleCnt = finishCircleCnt + 1
                                 if finishCircleCnt == 2 then
                                    endEffect() 
                                 end 
                                 return
                              end
                           end
                           st = st + 1
                           if st == maxNum + 1 then
                              st = 1
                           end 
                           tool.createEffect(tool.Effect.delay,{time = delay-0.1 > 0.1 and delay-0.1 or 0.1},widget.game_bg[name]["item".._st].effect.obj,
                                             function()
                                                widget.game_bg[name]["item".._st].effect.obj:setVisible(false)                                                
                                             end
                           )
                           func()
                        end
      )
   end
   func()
end

function playFishEffect()
   -- printTable(id)
   AudioEngine.playEffect("effect_02")
   for i = 1, 12 do
      if i ~= lastOpenId.outside then
         widget.game_bg.outside["item"..i].effect.obj:setVisible(false)
      end
   end
   endFishTimer()
   isPlaying = true
   
   playCircle(6, "inside")
   playCircle(12, "outside")
end

function endEffect()
   userdata.isInGame = false
   lastOpenId.outside = data.GameResult.f[1]
   lastOpenId.inside = data.GameResult.f[2]
   isPlaying = false
   winGold = 0
   finishCircleCnt = 0
   for k,v in pairs(isBet) do
       v = false
   end
   checkWinResult()
   changeTouchEnabled(true)
   if lastOpenId.outside == 2 or lastOpenId.outside == 4 or lastOpenId.outside == 8 or lastOpenId.outside == 10 or lastOpenId.outside == 6 or lastOpenId.outside == 12 then
      doResultAni(lastOpenId.outside)
   end
   startFishTimer()  
   commonTop.registerEvent()

   -- data.history[6] = nil
   -- table.insert(data.history,1,id)
   -- refreshHistory()

   betOwn = {}
   refreshBetOwn()
   
   -- if autoCnt > 0 then
   --    autoCnt = autoCnt - 1
   --    onRepeatBet("releaseUp")
   -- else
   --    widget.bottom_bg.auto_layout.obj:setTouchEnabled(false)
   --    widget.bottom_bg.auto_layout.obj:setVisible(false)
   -- end
   widget.bottom_bg.auto_layout.obj:setTouchEnabled(true)
   widget.bottom_bg.auto_layout.obj:setVisible(true)
end

function checkWinResult()
   if data.type == 201 then
      local message = {}
      message.type = 0
      message.cnt = data.GameResult.c
      message.outside = fishList[data.GameResult.f[1]].name
      message.inside = fishList[data.GameResult.f[2]].name
      chat.addMessage(message)
      if data.GameResult.u and #data.GameResult.u > 0 then
         local isInResult = false
         for k,v in pairs(data.GameResult.u) do
             if v.i == userdata.UserInfo.uidx then
                isInResult = true
                if v.m > 0 then
                   widget.bottom_bg.auto_layout.label.obj:setText("恭喜您赢得了"..v.m.."金币！")
                end
             else
             end
             message.type = 1
             message.name = v.e
             message.money = v.m
             chat.addMessage(message)         
         end
         if not isInResult and isDoBet then
            widget.bottom_bg.auto_layout.label.obj:setText("很遗憾您没有中奖！") 
         end
      end
   end
end

function initChatView()
   chatView = chat.create(620,470,1,package.loaded["scene.fishMachine.main"])
   widget.bottom_bg.obj:addChild(chatView,2)
   chatView:setAnchorPoint(ccp(0,0))
   chatView:setPosition(ccp(-515,-465))
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
   -- if isPlaying == true then 
   --    return
   -- end
   -- local totalNum = 0
   -- for k, v in pairs(betList) do
   --    local trueNum = data.btnCountTrueInfo[v.index]
   --    local falseNum = data.btnCountFalseInfo[v.index]
   --    local num = 0
   --    if trueNum == nil then
   --       trueNum = data.btnCountTrueInfo[v.index..""]
   --    end
   --    if falseNum == nil then
   --       falseNum = data.btnCountFalseInfo[v.index..""]
   --    end
   --    num = trueNum
   --    if not userdata.UserInfo.isGM then
   --       num = num + falseNum
   --    end
   --    totalNum = totalNum + num
   --    v.total_num:setText(numToStr(num))
   -- end
   -- setCashGold(totalNum)
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

function startFishTimer()
   if fishTimer == nil then
      if isRepeat then
         isRepeat = false
      end
      fishTimer = schedule(
         function()
            if data.type == 100 then
               -- if betEndTime > 3 then
               --    local str = string.format("%02d", betEndTime)
               --    widget.bottom_bg.time_atlas.obj:setStringValue(str)
               -- else
               --    playCdAtlasEffect(betEndTime)
               -- end
               betEndTime = betEndTime - 1
               local str = string.format("%02d", betEndTime)
               widget.bottom_bg.time_atlas.obj:setStringValue(str)  
               changeTouchEnabled(betEndTime > 0 and true or false)
            end
            -- local now = getSyncedTime()
            -- local time = math.floor(data.clickEndTime - now)
            -- time = time > 0 and time or 0
            -- local str = string.format("%02d", time)
            -- widget.bottom_bg.time_atlas.obj:setStringValue(str)
            -- changeTouchEnabled(time > 0 and true or false)
            
            -- local cd = math.floor(data.currentEndTime - now)
            -- cd = cd > 0 and cd or 0
            -- if cd <= data.countDownTime and cd > 0 and cdEffectPlaying == false then
            --    playCdAtlasEffect(cd)
            -- end
         end,1
      )
   end
   -- setPrizePoll(data.prizePool)
   -- call("getRankList",5)
end

function onGetPrizepool(header,body)
   -- print("onGetPrizepool",body)
   local tab = cjson.decode(body)
   -- printTable(tab)
   -- print("money:!!!!!!!!!!!!!!!!!!!!!!!!",tab.money/10000)
   widget.game_bg.num.obj:setStringValue(tab.money/10000)
end

function setPrizePoll(num)
   if not this or num == nil then
      return 
   end
   local panel = widget.game_bg.panel_jiangjin
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
   local panel = widget.game_bg.panel_zonger
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
      widget.bottom_bg.repeat_btn.obj:setBright(flag)
      widget.bottom_bg.repeat_btn.obj:setTouchEnabled(flag)
   end
   widget.bottom_bg.auto_btn.obj:setBright(flag)
   widget.bottom_bg.auto_btn.obj:setTouchEnabled(flag)
   widget.bottom_bg.cost_layout.obj:setTouchEnabled(flag)
   if flag == false then
      local posY = widget.bottom_bg.list_layout.bg.obj:getPositionY()
      if posY == 0 then
         widget.bottom_bg.list_layout.obj:setTouchEnabled(false)
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeOut=true},widget.bottom_bg.list_layout.bg.obj)
      end
      posY = widget.bottom_bg.auto_list_layout.list_view.obj:getPositionY()
      if posY == 0 then
         -- widget.bottom_bg.auto_list_layout.obj:setTouchEnabled(false)
         tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.bottom_bg.auto_list_layout.list_view.obj)
      end
   end
   for k, v in pairs(betList) do
       v.obj:setTouchEnabled(flag)
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
      widget.bottom_bg.repeat_btn.obj:setBright(false)
      widget.bottom_bg.repeat_btn.obj:setTouchEnabled(false)
   end
end

function bet(id, needGold)
   -- if userdata.UserInfo.owncash < needGold then
   --    alert.create("余额不足！")
   --    return
   -- end
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
      event.unListen("ON_ENTER_GAME_NOTICE", onEnterGameNotice)
      event.unListen("ON_EXIT_GAME_NOTICE", onExitGameNotice)
      event.unListen("ON_GET_USER_LIST_SUCCEED", onGetUserListSucceed)
      event.unListen("ON_GET_USER_LIST_FAILED", onGetUserListFailed)
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
      betList = {}
      endFishTimer()
      singleIndex = 3
      betOwn = {}
      winGold = 0
      isPlaying = false
      historyBet = {}
      historyList = {}
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
   -- cd_atlas = {_type = "LabelAtlas"},
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
   game_bg = {_type = "ImageView",
              outside = {_type = "ImageView",
                         item1={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item2={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item3={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item4={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item5={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item6={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item7={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item8={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item9={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item10={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item11={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                         item12={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
              },
              inside = {_type = "ImageView",
                        item1={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                        item2={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                        item3={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                        item4={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                        item5={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
                        item6={_type="Layout",pao1={_type="ImageView"},pao2={_type="ImageView"},img={_type="ImageView"},effect={_type="ImageView"}},
              },
              jilu = {_type = "Button",_func = onJilu},
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
   bottom_bg = {_type = "ImageView",
                time_atlas = {_type = "LabelAtlas"},
                win_atlas = {_type = "LabelAtlas"},
                repeat_btn = {_type = "Button", _func = onRepeatBet},
                auto_btn = {_type = "Button"},
                cost_layout = {_type = "Layout",
                               single_cost = {_type = "Label"},
                               triangle = {_type = "ImageView"},
                },
                list_layout = {_type = "Layout",
                               -- list_view = {_type = "ListView",
                               --              label1 = {_type = "Label"},
                               --              label2 = {_type = "Label"},
                               --              label3 = {_type = "Label"},
                               -- },
                               bg = {_type = "ImageView",
                                      label1 = {_type = "Label"},
                                      label2 = {_type = "Label"},
                                      label3 = {_type = "Label"},
                                      label4 = {_type = "Label"},
                                      label5 = {_type = "Label"},
                                      line_1 = {_type = "ImageView"},
                                      line_2 = {_type = "ImageView"},
                               },
                },
                rank_list = {_type = "ListView"},
                bet_list = {_type = "ListView"},
                auto_layout = {_type = "Layout", label = {_type = "Label"}},
                auto_list_layout = {_type = "Layout",
                               list_view = {_type = "ListView",
                                            img_1 = {_type = "ImageView",label = {_type = "Label"},},
                                            img_2 = {_type = "ImageView",label = {_type = "Label"},},
                                            img_3 = {_type = "ImageView",label = {_type = "Label"},},
                               },
                },
                alert = {_type = "ImageView",
                    image = {_type = "ImageView"},
                },
   },
   rank_render = {_type = "Layout",
                  rank_img = {_type = "ImageView"},
                  name = {_type = "Label"},
                  bonus = {_type = "Label"},
                  rank_atlas = {_type = "LabelAtlas"},
   },
   bet_render = {_type = "Layout",
                 my_num = {_type = "Label"},
                 total_num = {_type = "Label"},
                 img = {_type = "ImageView"},
                 num = {_type = "Label"},
   },
   history_layout = {_type = "Layout",
                     alert = {_type = "ImageView", 
                              back = {_type = "Button",_func = onAlertBack},
                              time = {_type = "Label"},
                              listView = {_type = "ListView"},
                     }, 
   },
   tmp = {_type = "ImageView",
          img_in = {_type = "ImageView"},
          img_out = {_type = "ImageView"},
          new = {_type = "ImageView"},
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
}
                               
                               
                        
