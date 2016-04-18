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
module("scene.rank", package.seeall)

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

local eventHash = {}

function create(parent,rankList)
   this = tool.loadWidget("cash/Rank",widget,parent,99)
   currentRank = rankList
   local diffY = widget.panel.bg.topTip.obj:getSize().height
   topPos.topTip = tool.getPosition(widget.panel.bg.topPos.obj)
   topPos.normal = {x = topPos.topTip.x,y = topPos.topTip.y+diffY}
   backPos.topTip = tool.getPosition(widget.panel.bg.back.obj)
   backPos.normal = {x = backPos.topTip.x,y = backPos.topTip.y+diffY}  
   scrollListHeight.topTip = widget.panel.bg.listView.obj:getSize().height
   scrollListHeight.normal = widget.panel.bg.listView.obj:getSize().height + diffY
   if currentRank == nil then
   		currentRank = rank.charge
   		RankList = currentRank.tabList[currentRank.currentTab]
   end
   widget.panel.bg.listView.obj:setTouchEnabled(true)
   scroll = scrollList.create(widget.panel.bg.listView.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,150,540,true,"club",nil,package.loaded["scene.rank"],0,300,0)
   scroll.setIsOutDisplayEnabled(true)
   
   initScene()
   return this
end
function onCharge(event)
  if event == "releaseUp" and currentRank ~= rank.charge then
      tool.buttonSound("releaseUp","effect_12")
  	print ("switch to charge")
     cleanScene()
     currentRank = rank.charge
     RankList = currentRank.tabList[currentRank.currentTab]
     initScene()
  end
 end
function onVip(event)
  if event == "releaseUp" and currentRank ~= rank.vip then
      tool.buttonSound("releaseUp","effect_12")
  	print ("switch to vip")
  	 cleanScene()
     currentRank = rank.vip
     RankList = currentRank.tabList[currentRank.currentTab]
     initScene()
  end
end
TabList = {}
function cleanScene()
	 cleanRank()
	for i,v in pairs(currentRank.tabObjList) do
		v:removeFromParentAndCleanup(true)
	end

	currentRank.tabObjList = {}
end
function initScene()
	-- init 

	widget.panel.bg.tab.obj:setVisible(false)
	widget.panel.bg.topPos.obj:setVisible(false)
	widget.panel.bg.tab.obj:setTouchEnabled(false)
	local x = widget.panel.bg.tab.obj:getPositionX()
	local diffX = widget.panel.bg.tab.obj:getSize().width*0.9
	currentRank.tabObjList = {}
	for i=1,#currentRank.tabList do
		local info = currentRank.tabList[i]
		local tab = widget.panel.bg.tab.obj:clone()
		local text = tool.findChild(tab,"text","Label")
		text:setText(info.name)
		widget.panel.bg.obj:addChild(tab)
		tab:setPositionX(widget.panel.bg.tab.obj:getPositionX()+(i-1)*diffX)
		currentRank.tabObjList[i] = tab
		tab:setTouchEnabled(true)
		tab:setVisible(true)
		tab:setBright(true)
		tab:registerEventScript(function (event)
			if event == "releaseUp" then
      		   tool.buttonSound("releaseUp","effect_12")
				cleanRank()
				currentRank.currentTab = i
				RankList = currentRank.tabList[currentRank.currentTab]
				onSwitchRankList()
			end
		end)
	end
	onSwitchRankList()
end
function cleanRank()
	for i=1,#currentRank.tabList do
		currentRank.tabObjList[i]:setBright(true)
	end
	if RankList.topObj then
		RankList.topObj:removeFromParentAndCleanup(true)
		RankList.topObj = nil
	end
	RankList.endCall = nil
	scroll.clear()
end
function onSwitchRankList()
	currentRank.tabObjList[currentRank.currentTab]:setBright(false)
	local topPosition = topPos.normal
	local backPosition = backPos.normal
	local sHeight = scrollListHeight.normal
	if RankList.topTip then
		widget.panel.bg.topTip.obj:setVisible(true)
		widget.panel.bg.topTip.text.obj:setText(RankList.topTip)
		topPosition = topPos.topTip
		backPosition = backPos.topTip
		sHeight = scrollListHeight.topTip
	else
		widget.panel.bg.topTip.obj:setVisible(false)
	end
	widget.panel.bg.back.obj:setPosition(ccp(backPosition.x,backPosition.y))
	widget.panel.bg.bottomTip.text.obj:setText(RankList.bottomTip)
	local top = RankList.top.obj:clone()
	widget.panel.bg.obj:addChild(top)
	top:setPosition(ccp(topPosition.x,topPosition.y))
	widget.panel.bg.listView.obj:setSize(CCSize(widget.panel.bg.listView.obj:getSize().width,sHeight))
	RankList.topObj = top
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
		if v.charId then
		   v.charId = v.charId 
	    end
		scroll.pushItem(rank.render(rank,v))

	end
	--scroll.updateItemsVisible(scroll.obj,"onScroll")
end

function vipRender(rank,info)
    printTable(info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(vip,obj)
	widgetList.name.obj:setText(v.charName)
	widgetList.id.obj:setText("ID:"..(v.charId + 8000000))
	local lv = countLv.getVipLv(v.score)
	widgetList.vipLv.obj:setStringValue(lv)
	widgetList.img.obj:loadTexture("cash/qietu/main2/default.jpg")
    tool.loadRemoteImage(eventHash, widgetList.img.obj, v.charId)
	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	return obj

end
function goldRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(gold,obj)
	widgetList.name.obj:setText(v.charName)
	widgetList.id.obj:setText("ID:"..(v.charId + 8000000))
	widgetList.gold.obj:setText(v.score)
	widgetList.img.obj:loadTexture("cash/qietu/main2/default.jpg")
    tool.loadRemoteImage(eventHash, widgetList.img.obj, v.charId)
	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	return obj

end

function winGoldRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(winGold,obj)
	widgetList.name.obj:setText(v.charName)
	widgetList.id.obj:setText("ID:"..(v.charId + 8000000))
	widgetList.gold.obj:setText(v.score)
	widgetList.img.obj:loadTexture("cash/qietu/main2/default.jpg")
    tool.loadRemoteImage(eventHash, widgetList.img.obj, v.charId)
	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	return obj
end

function chargeRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(charge,obj)
	widgetList.name.obj:setText(v.charName)
	widgetList.id.obj:setText("ID:"..(v.charId + 8000000))
	widgetList.gift.obj:setText(v.gold)
	widgetList.charge_num.obj:setText(v.score)
	widgetList.img.obj:loadTexture("cash/qietu/main2/default.jpg")
    tool.loadRemoteImage(eventHash, widgetList.img.obj, v.charId)
	local t = template['chargeGift'][v.rank]
	if t == nil then
		widgetList.gift.obj:setText("无")
	else
		local num = v.score * t.multi / 10000
		mun = math.floor(num)
		widgetList.gift.obj:setText(num.."万")
	end
	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	return obj
end

function chargeYesRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(charge_yes,obj)
	widgetList.name.obj:setText(v.charName)
	widgetList.id.obj:setText("ID:"..(v.charId + 8000000))
	widgetList.gift.obj:setText(v.gold)
	widgetList.charge_num.obj:setText(v.score)
	widgetList.img.obj:loadTexture("cash/qietu/main2/default.jpg")
	print("chargeYesRender",v.charId,userdata.UserInfo.charId)
    widgetList.get.obj:setVisible(v.charId == userdata.UserInfo.id)
    widgetList.get.obj:setTouchEnabled(v.charId == userdata.UserInfo.id)
    tool.loadRemoteImage(eventHash, widgetList.img.obj, v.charId)
	local t = template['chargeGift'][v.rank]
	if t == nil then
		widgetList.gift.obj:setText("无")
	else
		local num = v.score * t.multi / 10000
		mun = math.floor(num)
		widgetList.gift.obj:setText(num.."万")
	end
	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	return obj
end

function chargeGiftRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(chargeGift,obj)

	if v.rank <=3 then
		widgetList.rank.text.obj:setVisible(false)
		widgetList.rank.obj:loadTexture("image/cup"..v.rank..".png")
		widgetList.rank.obj:setScale(1.5)
	else
		widgetList.rank.text.obj:setText(v.rank)
	end
	obj:setTouchEnabled(false)
	local count=  info.multi / 10000
	widgetList.gift.obj:setText(count.."万*充值金额")
	return obj
end

function callServer(rank,endCall,funcName,...)
	
	call(funcName,...)
	rank.list = {	}
	rank.endCall = endCall
	if endCall then
		endCall()
	end
end

function onGetRankList(rankId,data)
	local xxrankList = {
		rankInfo.gold,
		rankInfo.vip,
		rankInfo.charge,
		rankInfo.charge_yes,
		nil,
		rankInfo.winGold,
	}
	local rank = xxrankList[rankId]
	if rank == nil then
		return 
	end
	for i,v in pairs(data) do
		if type(v) ~= "userdata" then
			v.rank = i
			table.insert(rank.list,v)
		end
	end
	rank.lastCacheTime = getSyncedTime()
	if this and rank.endCall then
		rank.endCall()
	end
end
function getChargeRank(rank,endCall)
	local list = template['chargeGift']
	rank.list = {}
	for i=1,#list do
		table.insert(rank.list,list[i])
	end
	if endCall then
		endCall()
	end
end
function onYesGet(event)
	if event == "releaseUp" then
    	call("getVipReward")
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
     cleanEvent()
     event.pushEvent("ON_BACK")
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
charge = {
	_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	img = {_type="ImageView"},
	name = {_type="Label"},
	id = {_type="Label"},
	charge_num ={_type="Label"},
	gift = {_type="Label"},
}
charge_yes = {
	_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	img = {_type="ImageView"},
	name = {_type="Label"},
	id = {_type="Label"},
	charge_num ={_type="Label"},
	gift = {_type="Label"},
	get = {_type = "Button",
	   _func = onYesGet,
	   text = {_type = "Label"},
	   text_shadow = {_type = "Label"},
	},
}
vip = {
_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	img = {_type="ImageView"},
	name = {_type="Label"},
	id = {_type="Label"},
	vipLv = {_type="LabelAtlas"},
}
chargeGift = {
_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	gift = {_type="Label"},
}
gold = {
_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	img = {_type="ImageView"},
	name = {_type="Label"},
	id = {_type="Label"},
	gold = {_type="Label"},
}
winGold = {
_ignore = true,
	rank = {_type= "ImageView",text = {_type="Label"}},
	img = {_type="ImageView"},
	name = {_type="Label"},
	id = {_type="Label"},
	gold = {_type="Label"},
}
widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	charge =  {_type="Button",_func=onCharge},
       	vip =  {_type="Button",_func=onVip},
   		tab = {
   			_type="Button",_func=onTab,
   			text  = {_type="Label"}
   		},
   		topTip = {
   			text  = {_type="Label"}
   		},
   		bottomTip = {
   			text  = {_type="Label"}
   		},
   		listView ={_type = "ScrollView"},
   		topPos = {},
  },
  },
  scroll_bg = {
  	scroll_bar = {},
  },
  charge = {
	top = {},
	tmp = {},
  },
  charge_yes = {
	top = {},
	tmp = {},
  },
  vip = {
	top = {},
	tmp = {},
  },
  chargeGift = {
	top = {},
	tmp = {},
  },

  gold = {
	top = {},
	tmp = {},
  },
  winGold = {
	top = {Label_40 = {_type = "Label", _stroke = true}},
	tmp = {},
  },
  charge = {
	top = {},
	tmp = {},
  },
}

cacheStrategy={
	rank = {cacheTime = 5*60,},
	localData = {cacheTime = -1},
}

rankInfo = {
	vip = {name="VIP榜",top = widget.vip.top,tmp=widget.vip.tmp,cacheStrategy = cacheStrategy.rank, itemHeight= 207,interface =callServer,parms = {"getRankList",2},render = vipRender,topTip=nil,bottomTip ="VIP榜每5分钟更新一次",},
	gold = {name="财富榜",top = widget.gold.top,tmp=widget.gold.tmp,cacheStrategy = cacheStrategy.rank,itemHeight= 207,interface =callServer,parms = {"getRankList",1},render = goldRender,topTip=nil,bottomTip ="财富榜每5分钟更新一次",},
	winGold = {name="豪胜榜",top = widget.winGold.top,tmp=widget.winGold.tmp,cacheStrategy = cacheStrategy.rank,itemHeight= 207,interface =callServer,parms = {"getRankList",6},render = winGoldRender,topTip=nil,bottomTip ="豪胜榜每5分钟更新一次",},
	charge = {name="充值榜",top = widget.charge.top,tmp=widget.charge.tmp,cacheStrategy = cacheStrategy.rank, itemHeight= 207,interface =callServer,parms = {"getRankList",3},render = chargeRender,topTip="登顶财富榜，X10万倍金币豪送；上榜充值榜均有奖！",bottomTip ="充值每5分钟更新一次，预计明天奖励金币可能因为名次变化而增减，实际奖励以每晚24点最终名次为准",},
	charge_yes = {name="昨日充值榜",top = widget.charge_yes.top,tmp=widget.charge_yes.tmp,cacheStrategy = cacheStrategy.rank, itemHeight= 207,interface =callServer,parms = {"getRankList",4},render = chargeYesRender,topTip=nil,bottomTip ="昨日充值榜每天24点更新",},
	charge_gift = {name="充值奖励榜",top = widget.chargeGift.top,tmp=widget.chargeGift.tmp,cacheStrategy = cacheStrategy.localData, itemHeight= 207,interface =getChargeRank,parms={},render = chargeGiftRender,topTip=nil,bottomTip ="规则：充值奖励榜在上榜后第二天发放，上榜玩家请进入昨日充值榜，找到自己的名次领取奖励",},

}

rank = {
	charge = {
		tabList = {
			rankInfo.charge,rankInfo.charge_yes,rankInfo.charge_gift
		},
		currentTab = 1,
	},
	vip = {
		tabList = {
			rankInfo.vip,rankInfo.winGold,rankInfo.gold,
		},
		currentTab = 1,
	},
}
