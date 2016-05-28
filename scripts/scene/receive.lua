local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data
local loginAlert = require "scene.loginAlert"

module("scene.receive", package.seeall)

this = nil
subWidget = nil
parent = nil

local currentTag = 0
local canReceive = false
local richText = nil
local y1 = 0
local y2 = 0
local y3 = 0
local y4 = 0
local numTimer = nil
local nextGoldNum = 0

function create(_parent)
   parent = _parent
   this = tool.loadWidget("cash/receive",widget,_parent,99)
   y1 = widget.alert.title_1.obj:getPositionY()-80
   y2 = widget.alert.gold_1.obj:getPositionY()-80
   y3 = widget.alert.info_1.obj:getPositionY()-80
   y4 = widget.alert.btn_1.obj:getPositionY()-80
   initView()
   event.listen("ON_GET_FREE_GOLD",onGetFreeGold)
   event.listen("ON_CHANGE_VIP",initView)
   event.listen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
   return this
end

function initView()
    local tmp = template['freeGold'][userdata.UserInfo.minNum+1]
    if not tmp or userdata.UserInfo.minNum > #template['freeGold'] then
       tmp = template['freeGold'][6]
    end
    local nextTmp = template['freeGold'][userdata.UserInfo.minNum+2]
    if not nextTmp or userdata.UserInfo.minNum > #template['freeGold'] then
       nextTmp = template['freeGold'][6]
    end
    print("initView",getSyncedTime(),userdata.UserInfo.minlastLq,tmp.time)
    local isShowTime = false
    if getSyncedTime() - userdata.UserInfo.minlastLq < tmp.time*60 then
       isShowTime = true
    end
    widget.alert.btn_1.obj:setTouchEnabled(not isShowTime)
    widget.alert.btn_1.obj:setVisible(not isShowTime)
    widget.alert.title_3.obj:setVisible(isShowTime)
    widget.alert.time.obj:setVisible(isShowTime)
    local goldNum = 0
    nextGoldNum = 0
    local vipGoldNum = 0
    local vipLv = userdata.UserInfo.viplevel
    if vipLv == 0 then
       goldNum = tmp.normal
       nextGoldNum = nextTmp.normal
       vipGoldNum = tmp.vip*2
    else
       goldNum = tmp.vip*(vipLv+1)
       nextGoldNum = nextTmp.vip*(vipLv+1)
       vipGoldNum = tmp.vip*(vipLv+2)
       widget.alert.btn_1.text.obj:setText("VIP领取")
       widget.alert.btn_1.text_shadow.obj:setText("VIP领取")
    end  
    local nextVip = nil
    if nextVip then
       local tmp = template['charge'][nextVip.lv]
       local gold = tmp.goldGet + tmp.giftGet
       if tmp.tips == "" then
          if userdata.UserInfo.lastChargeTime/1000 < timeToDayStart(getSyncedTime()) then
             gold = gold + tmp.goldGet
          end
          gold = gold + tmp.specialAdd
       end
       widget.alert.info_2.obj:setText(tmp.rmb.."元购买"..(gold/10000).."万金币立即升级VIP"..nextVip.lv)
    else
       widget.alert.title_1.obj:setPositionY(y1)
       widget.alert.gold_1.obj:setPositionY(y2)
       widget.alert.info_1.obj:setPositionY(y3)
       widget.alert.btn_1.obj:setPositionY(y4)
       widget.alert.title_3.obj:setPositionY(y1)
       widget.alert.time.obj:setPositionY(y1)
       widget.alert.line.obj:setVisible(false)
       widget.alert.title_2.obj:setVisible(false)
       widget.alert.gold_2.obj:setVisible(false)
       widget.alert.info_2.obj:setVisible(false)
       widget.alert.btn_2.obj:setVisible(false)
    end
    widget.alert.gold_1.label.obj:setText(goldNum)
    widget.alert.gold_2.label.obj:setText(vipGoldNum)
    widget.alert.gold_2.add.obj:setText("*"..math.floor(vipGoldNum/goldNum*100).."%")
    if richText then
       richText:removeFromParentAndCleanup(true)
       richText = nil
    end
	  richText = RichText:create()
   	richText:setAnchorPoint(ccp(0,0.5))
   	richText:setPosition(ccp(-410,0))
	  local text1 = RichElementText:create(1,ccc3(255,255,255),255,"本次领取后"..nextTmp.time.."分钟可领",DEFAULT_FONT,40)
	  richText:pushBackElement(text1)
	  local text2 = RichElementText:create(2,ccc3(255,249,71),255,"免费金币:"..nextGoldNum,DEFAULT_FONT,40)
	  richText:pushBackElement(text2)
	  widget.alert.info_1.obj:addChild(richText)
end

function onGetFreeGold()
   event.pushEvent("ON_GOLD_ACTION")
   widget.alert.btn_1.obj:setTouchEnabled(false)
end

function onGoldActionFinish()
   initView()
   tool.createEffect(tool.Effect.delay,{time=0.8},widget.obj,function()
      exit()
   end)
end

function resetTime(m,s)
   if not this then return end
   widget.alert.time.num.obj:setText(m..":"..s)
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_GET_FREE_GOLD",onGetFreeGold)
      event.unListen("ON_CHANGE_VIP",initView)
      event.unListen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      if goldTimer then
         goldTimer = nil
      end
      richText = nil
      nextGoldNum = 0
      this = nil
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
   end
end

function onBtn1(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      userdata.goldAction = true
      userdata.goldPos = {x = 335,y = 1160}
      call(16001)
      -- umengBonusCoin(nextGoldNum, 1)
   end
end

function onBtn2(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      loginAlert.create(widget.obj)
   end
end

widget = {
  	_ignore = true,
  	alert = {
     	back = {
    		_type = "Button",
    		_func = onBack,
    	},
   		title_1 = {_type = "Label"},
   		gold_1 = {
   			_type = "ImageView",
   			gold = {_type = "ImageView"},
   			label = {_type = "Label"},
   		},
   		info_1 = {_type = "ImageView"},
   		btn_1 = {
   		    _type = "Button",
   		    _func = onBtn1,
   		    text = {_type = "Label"},
          text_shadow = {_type = "Label"},
   		},
   		line = {_type = "ImageView"},
   		title_2 = {_type = "Label"},
   		gold_2 = {
   			_type = "ImageView",
   			gold = {_type = "ImageView"},
   			label = {_type = "Label"},
   			add = {_type = "Label"},
   		},
   		info_2 = {_type = "Label"},
   		btn_2 = {
   		    _type = "Button",
   		    _func = onBtn2,
   		    text = {_type = "Label"},
          text_shadow = {_type = "Label"},
   		},
      title_3 = {_type = "Label"},
      time = {
          _type = "ImageView",
          num = {_type = "Label"},
      },
  	},
} 