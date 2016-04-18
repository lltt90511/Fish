local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local countLv = require"logic.countLv"
local scrollList = require"widget.scrollList"
local template = require"template.gamedata".data

module("scene.mail", package.seeall)

this = nil
subWidget = nil
currentRank = nil
RankList = nil
topPos = {
	normal = {x=0,y=0},
	topTip = {x=0,y=0},
}
backPos = {
	normal = {x=0,y=0},
	topTip = {x=0,y=0},
}
scrollListHeight = {
	normal = 0,
	topTip = 0,
}
scroll = nil
function create(parent,rankList)
   this = tool.loadWidget("cash/mail",widget,parent,99)
   currentRank = rankList
   if currentRank == nil then
   		RankList = rankInfo.mail
   end
   widget.panel.bg.listView.obj:setTouchEnabled(true)
   scroll = scrollList.create(widget.panel.bg.listView.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,942,470,true,"club",nil,package.loaded["scene.mail"],0,300,0)
   scroll.setIsOutDisplayEnabled(true)
   
   initScene()
   event.listen("ON_UPDATE_MAIL",onSwitchRankList)
   return this
end

function cleanScene()
	cleanRank()
end
function initScene()
	-- init 

	widget.panel.bg.title.obj:setVisible(false)
	local pos = tool.getPosition(widget.panel.bg.title.obj)
	local top = RankList.top.obj:clone()
	widget.panel.bg.obj:addChild(top)
	tool.setPosition(top,pos)
	onSwitchRankList()
end
function cleanRank()
	if RankList.topObj then
		RankList.topObj:removeFromParentAndCleanup(true)
		RankList.topObj = nil
	end
	RankList.endCall = nil
	scroll.clear()
end
function onSwitchRankList()
	local listView = widget.panel.bg.listView.obj
	scroll.clear()
	scroll.setPageEnabled(false)
	scroll.setItemHeight(RankList.itemHeight)
	if RankList.lastCacheTime == nil or 
		RankList.cacheStrategy.cacheTime <=0 or
		RankList.lastCacheTime + RankList.cacheStrategy.cacheTime < getSyncedTime() then
		RankList.interface(RankList,renderRank,unpack(RankList.parms))
	else
		renderRank()
	end
	local t
end
function renderRank()
	local rank = RankList
	for _,v in pairs(rank.list) do
		if type(v) ~= "userdata" then
			scroll.pushItem(rank.render(rank,v))
		end
	end
	--scroll.updateItemsVisible(scroll.obj,"onScroll")
end

function mailRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(mail,obj)
	widgetList.info.obj:setText(v.massage)
	widgetList.title.obj:setText("系统邮件")
	local tRec = os.date("*t",tonumber(v.createTime)/1000-timeDiff)
	widgetList.time.obj:setText(tRec.year.."-"..tRec.month.."-"..tRec.day.." "..tRec.hour..":"..tRec.min..":"..tRec.sec)
	obj:setTouchEnabled(false)
	if v.type == 0 then
		widgetList.btn.text.obj:setText("删除")
		widgetList.btn.text_shadow.obj:setText("删除")
	elseif v.type == 2 then
		if v.read == 0 then
		   widgetList.btn.text.obj:setText("领取")
		   widgetList.btn.text_shadow.obj:setText("领取")
		elseif v.read == 1 then
		   widgetList.btn.obj:setBright(false)
		   widgetList.btn.obj:setTouchEnabled(false)
		   widgetList.btn.text.obj:setText("已领取")
		   widgetList.btn.text_shadow.obj:setText("已领取")
		end
	end

	widgetList.btn.obj:registerEventScript(function (event)
		if event == "releaseUp" then
      		tool.buttonSound("releaseUp","effect_12")
			call("openGiftPack",v.id)
			-- scroll.removeItem(obj)
			widgetList.btn.text.obj:setText("已领取")
			widgetList.btn.text_shadow.obj:setText("已领取")
		end
	end)
	return obj
end



function getMail(rank,endCall)
	local list = template['chargeGift']
	rank.list = {}
	if userdata.giftList then
		rank.list = userdata.giftList
		table.sort(rank.list,function(a,b)
			if a.read == b.read then
			   return a.createTime > b.createTime
			else
			   if a.read == 0 then
			   	  return true
			   elseif b.read == 0 then
			   	  return false
			   end
			end
		end)
	end
	if endCall then
		endCall()
	end
end
function exit()
  if this then

      event.pushEvent("ON_BACK")
      event.unListen("ON_UPDATE_MAIL",onSwitchRankList)
	  cleanScene()
	  scroll.clear()
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end
function onBack(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
     exit()
  end
end
mail = {
	_ignore = true,
	btn = {_type= "Button",text = {_type="Label"},text_shadow = {_type="Label"}},
	info = {_type="Label"},
	title = {_type="Label"},
	time = {_type="Label"},
}

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	title =  {_type="ImageView",},
   		listView ={_type = "ScrollView"},
  	},
  },
  scroll_bg = {
  	scroll_bar = {},
  },

  mial_btn = {
	top = {},
	tmp = {},
  },
}

cacheStrategy={
	rank = {cacheTime = 5*60,},
	localData = {cacheTime = -1},
}

rankInfo = {
	mail = {name="VIP榜",top = widget.mial_btn.top,tmp=widget.mial_btn.tmp,cacheStrategy = cacheStrategy.localData, itemHeight= 207,interface =getMail,parms = {},render = mailRender,},
	--gold = {name="财富榜",top = widget.gold.top,tmp=widget.gold.tmp,cacheStrategy = cacheStrategy.localData,itemHeight= 207,interface =callServer,parms = {},render = goldRender,topTip=nil,bottomTip ="财富榜每5分钟更新一次",},
}