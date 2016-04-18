local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data

module("scene.charge_alert", package.seeall)

this = nil
subWidget = nil

function create(parent,id)
   this = tool.loadWidget("cash/charge_alert",widget,parent,15)
   initView(id)
   userdata.goldAction = true
   userdata.goldPos = {x = 760,y = 816}
   event.pushEvent("ON_GOLD_ACTION")
   return this
end

function initView(id)
   local tpl = template['charge'][id]
   if tpl then
   	  local gold = tpl.goldGet + tpl.giftGet + tpl.specialAdd
   	  widget.bg.gold_1.label.obj:setText("+"..(tpl.goldGet/10000).."万")
   	  widget.bg.gold_2.label.obj:setText("+"..(tpl.giftGet/10000).."万")
   	  if userdata.UserInfo.lastChargeTime/1000 < timeToDayStart(getSyncedTime()) then 
   	  	 widget.bg.gold_3.label.obj:setText("+"..(tpl.goldGet/10000).."万")
   	  	 gold = gold + tpl.goldGet
   	  else
         local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
         widget.bg.title_3.obj:setText("VIP加成")
         if vipLv > 0 then
            widget.bg.gold_3.label.obj:setText("+"..(tpl.goldGet*vipLv*0.1/10000).."万")
            gold = gold + tpl.goldGet*vipLv*0.1
         else
            widget.bg.gold_3.label.obj:setText("+0")
         end
   	  end
   	  widget.bg.gold_4.label.obj:setText("+"..(tpl.specialAdd/10000).."万")
   	  widget.bg.gold_bottom.label2.obj:setText(gold)
   end
end

function onBack(event)
   if event == "releaseUp" then
   	  exit()
   end	
end

function exit()
  if this then
	   this:removeFromParentAndCleanup(true)
	   tool.cleanWidgetRef(widget)
	   this = nil
  end
end

widget = {
	_ignore = true,
    bg = {
        back = {_type="Button",_func=onBack},
       	title_1 =  {_type="Label"},
   		gold_1 ={
   			_type = "ImageView",
   			label = {_type = "Label"},
   		},
       	title_2 =  {_type="Label"},
   		gold_2 ={
   			_type = "ImageView",
   			label = {_type = "Label"},
   		},
       	title_3 =  {_type="Label"},
   		gold_3 ={
   			_type = "ImageView",
   			label = {_type = "Label"},
   		},
       	title_4 =  {_type="Label"},
   		gold_4 ={
   			_type = "ImageView",
   			label = {_type = "Label"},
   		},
   		gold_bottom ={
   			_type = "ImageView",
   			label1 = {_type = "Label"},
   			label2 = {_type = "Label"},
   			gold = {_type = "ImageView"},
   		},
   		top = {_type = "ImageView"},
  	},
}