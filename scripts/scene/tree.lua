local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data
local charge = require "scene.charge"

module("scene.tree", package.seeall)

this = nil
subWidget = nil

local splitList = {}
local vipLv = 0
local maxGold = 0

function create(parent)
   this = tool.loadWidget("cash/tree",widget,parent,99)
   initView()
   event.listen("ON_CHANGE_VIP",initView)
   event.listen("ON_GET_TREE",onUpdateTreeGift)
   event.listen("ON_GET_TREE_SUCCESS",onGetTreeGiftSucceed)
   event.listen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
   return this
end

function initView()
	  splitList = {}
	  widget.panel.bg.info.obj:setText("充值就送摇钱树\n初始等级1级\n充值10元升1级\n每小时结1000金币\n每升1级多结100金币\n8小时结满全树")
  	vipLv = math.floor(userdata.UserInfo.vipExp/100)--countLv.getVipLv(userdata.UserInfo.vipExp)
  	print("vipLv:!!!!!!!!!",vipLv)
  	widget.panel.bg.gold.label.obj:setText("LV."..vipLv)
  	if vipLv > 0 then
  	   local tmp = template['vipExp'][vipLv]
  	   if not tmp then
  	   	  tmp = template['vipExp'][#template['vipExp']]
  	   end
  	   splitList = splitWithTrim(tmp.tree,";")
       local lastTime = 0--userdata.UserInfo.lastTreeGiftTime
       if userdata.UserInfo.lastTreeGiftTime > 0 then
  	      lastTime = userdata.UserInfo.lastTreeGiftTime 
       else
          lastTime = getSyncedTime()*1000 
       end
       print("initView",lastTime/1000,getSyncedTime())
  	   if lastTime == nil then
          lastTime = 0
  	   	  -- lastTime = userdata.UserInfo.lastChargeTime
  	   end
       widget.panel.bg.label.obj:setVisible(false)
       widget.panel.bg.goldBar.obj:setVisible(true)
       widget.panel.bg.goldBar_bg.obj:setVisible(true)
       widget.panel.bg.goldNum.obj:setVisible(true)      
       widget.panel.bg.btn.text.obj:setText("领取金币") 
       widget.panel.bg.btn.text_shadow.obj:setText("领取金币") 
       widget.panel.bg.btn.obj:registerEventScript(function(event)
           if event == "releaseUp" then
              -- print("call getGiftTree!!!!!!!!!!!!")
              tool.buttonSound("releaseUp","effect_12")
              userdata.goldAction = true
              userdata.goldPos = {x=375,y=1142}
              call("getGiftTree")
           end
       end)
  	   onUpdateTreeGift(lastTime,0)
	 else
      widget.panel.bg.label.obj:setVisible(true)
      widget.panel.bg.goldBar.obj:setVisible(false)
      widget.panel.bg.goldBar_bg.obj:setVisible(false)
      widget.panel.bg.goldNum.obj:setVisible(false) 
  		widget.panel.bg.label.obj:setText("您还没有摇钱树，充值任意金额立即拥有！")
  		widget.panel.bg.btn.text.obj:setText("马上充值")
      widget.panel.bg.btn.text_shadow.obj:setText("马上充值")
  		widget.panel.bg.btn.obj:registerEventScript(function(event)
	  	 	 if event == "releaseUp" then
          tool.buttonSound("releaseUp","effect_12")
	  	 	 	charge.create(widget.obj)
	  	 	 end
  	  end)
   end
end

function onUpdateTreeGift(time,gold)
   local currentTime = math.floor((getSyncedTime() - time/1000)/3600)
   print("onUpdateTreeGift",getSyncedTime(),time/1000,currentTime)
   local lv = userdata.UserInfo.vipExp/100
   local hourGold = 1000 + lv*100
   maxGold = hourGold*8
   local addGold = gold + currentTime*hourGold
   if addGold > maxGold then
  	  addGold = maxGold
   end
   widget.panel.bg.btn.obj:setTouchEnabled(addGold > 0)
   widget.panel.bg.btn.obj:setBright(addGold > 0)
   widget.panel.bg.goldNum.obj:setText(addGold.."/"..maxGold)
   widget.panel.bg.goldBar.obj:setPercent(addGold/maxGold*100)
   -- if addGold > 0 then
   -- 	  widget.panel.bg.label.obj:setText("您已经有"..addGold.."金币可领取")
     --  widget.panel.bg.btn.text.obj:setText("领取金币") 
     --  widget.panel.bg.btn.text_shadow.obj:setText("领取金币") 
	    -- widget.panel.bg.btn.obj:registerEventScript(function(event)
  	 	--    if event == "releaseUp" then
  	 	--    	  -- print("call getGiftTree!!!!!!!!!!!!")
     --        tool.buttonSound("releaseUp","effect_12")
     --        userdata.goldAction = true
     --        userdata.goldPos = {x=375,y=1142}
  	 	--  	    call("getGiftTree")
  	 	--    end
  	  -- end)
   -- else
   -- 	  widget.panel.bg.label.obj:setText("还没有金币可领取")
   -- 	  widget.panel.bg.btn.obj:setTouchEnabled(false)
   -- 	  widget.panel.bg.btn.obj:setBright(false)
   -- end
end

function onGetTreeGiftSucceed()
   event.pushEvent("ON_GOLD_ACTION")
   widget.panel.bg.goldNum.obj:setText("0/"..maxGold)
   widget.panel.bg.goldBar.obj:setPercent(0)
	 widget.panel.bg.btn.obj:setTouchEnabled(false)
   widget.panel.bg.btn.obj:setBright(false)
end

function onGoldActionFinish()
   tool.createEffect(tool.Effect.delay,{time=0.8},widget.obj,function()
      exit()
   end)
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
   	  event.unListen("ON_CHANGE_VIP",initView)
   	  event.unListen("ON_GET_TREE",onUpdateTreeGift)
   	  event.unListen("ON_GET_TREE_SUCCESS",onGetTreeGiftSucceed)
      event.unListen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      splitList = {}
      this = nil
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
   end
end

widget = {
  	_ignore = true,
  	panel = {
	  	bg = {
	     	back = {
	    		_type = "Button",
	    		_func = onBack,
	    	},
	   		title = {_type = "ImageView"},
	   		tree = {_type = "ImageView"},
	   		info = {_type = "Label"},
	   		gold = {
	   			_type = "ImageView",
	   			label = {_type = "Label"},
	   		},
	   		label = {_type = "Label"},
	   		btn = {
	   		 	_type = "Button",
	   		 	text = {_type = "Label"},
          text_shadow = {_type = "Label"},
	   		},
        goldBar = {_type = "LoadingBar"},
        goldBar_bg = {_type = "ImageView"},
        goldNum = {_type = "Label"},
	  	},
  	},
} 