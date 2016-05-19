local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
local template = require"template.gamedata".data
local charge_alert = require"scene.charge_alert"

payServerUrl = payServerUrl

module("scene.charge", package.seeall)

this = nil
subWidget = nil
currentRank = nil
RankList = nil
buyItem = nil
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
function create(parent,rankList,isInGame)
   this = tool.loadWidget("cash/charge",widget,parent,15)
   RankList = rankList
   if RankList == nil then
   		RankList = rankInfo.alipay
   end
   widget.panel.bg.listView.obj:setTouchEnabled(true)
   if isInGame ~= nil and isInGame then
   	  local panelSize = widget.panel.obj:getSize()
   	  local bgSize = widget.panel.bg.obj:getSize()
   	  local listSize = widget.panel.bg.listView.obj:getSize()
   	  local sizeAdd = Screen.height-168-bgSize.height
      widget.panel.obj:setSize(CCSize(panelSize.width,Screen.height-168)) 
      widget.panel.obj:setPositionY(0)
      widget.panel.bg.obj:setSize(CCSize(bgSize.width,Screen.height-168)) 
      widget.panel.bg.obj:setPositionY(panelSize.height)
      widget.panel.bg.listView.obj:setSize(CCSize(listSize.width,listSize.height+sizeAdd))
      widget.panel.bg.listView.obj:setPositionY(-bgSize.height)
   end
   scroll = scrollList.create(widget.panel.bg.listView.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,942,540,true,"club",nil,package.loaded["scene.charge"],0,300,0)
   scroll.setIsOutDisplayEnabled(true)
   onSwitchRankList()
   event.listen("CHARGE_SUCCESS", onChargeSuccess)
   return this
end

function onChargeSuccess(id,time)
    charge_alert.create(widget.obj,id)
    userdata.UserInfo.lastChargeTime = time
	cleanRank()
	onSwitchRankList()
end

function cleanScene()
	cleanRank()
end
tabList = {}
function initScene()
	-- init 
	widget.panel.bg.tab.obj:setVisible(false)
	widget.panel.bg.tab.obj:setTouchEnabled(false)
		local x = widget.panel.bg.tab.obj:getPositionX()
	local diffX = widget.panel.bg.tab.obj:getSize().width*0.9
	tabList = {}
	local i = 0
	for _,v in pairs(rankInfo) do
		i = i + 1
		local info = v
		local id = i
		local tab = widget.panel.bg.tab.obj:clone()
		local text = tool.findChild(tab,"text","Label")
		text:setText(info.name)
		widget.panel.bg.obj:addChild(tab)
		tab:setPositionX(widget.panel.bg.tab.obj:getPositionX()+(i-1)*diffX)
		tabList[i] = tab
		tab:setTouchEnabled(true)
		tab:setVisible(true)
		tab:setBright(true)
		tab:registerEventScript(function (event)
			if event == "releaseUp" then
      			tool.buttonSound("releaseUp","effect_12")
				cleanRank()
				RankList = info
				onSwitchRankList()
				tabList[id]:setBright(false)
			end
		end)
	end
	onSwitchRankList()
	tabList[1]:setBright(false)
end
function cleanRank()
	for i=1,#tabList do
		tabList[i]:setBright(true)
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
end
function renderRank()
	local rank = RankList
	for _,v in pairs(rank.list) do
		scroll.pushItem(rank.render(rank,v))
	end
	--scroll.updateItemsVisible(scroll.obj,"onScroll")
end

function chargeRender(rank,info)
	local v = info
	local obj = rank.tmp.obj:clone()
	local widgetList = tool.loadWidgetForClone(charge,obj)
	widgetList.tip.obj:setText(v.tip)
	widgetList.bottom.gift.obj:setText(v.gift)
	widgetList.all.text.obj:setText("合计:"..((v.all )/ 10000).."万")
	widgetList.buy.text.obj:setText(v.rmb.."元购买")
	widgetList.buy.text_shadow.obj:setText(v.rmb.."元购买")
	obj:setTouchEnabled(false)
	print("chargeRender")
	printTable(v)
	widgetList.buy.obj:registerEventScript(function (event)
		if event == "releaseUp" then
			tool.buttonSound("releaseUp","effect_12")
			-- call("charge",info.id)
			buyItem = info
			if platform == "Android" then
				getOrderId(info.id)
			elseif platform == "IOS" then
				appstoreBuy(info.productId)
			end
		end
	end)
	return obj
end

function appstoreBuy(id)
	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit"..id,time=tostring(os.time())})

	-- if id == 8 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit6",time=tostring(os.time())})
	-- elseif id == 9 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit12",time=tostring(os.time())})
	-- elseif id == 10 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit30",time=tostring(os.time())})
	-- elseif id == 11 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit60",time=tostring(os.time())})
	-- elseif id == 12 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit120",time=tostring(os.time())})
	-- elseif id == 13 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit300",time=tostring(os.time())})
	-- elseif id == 14 then
	-- 	luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit600",time=tostring(os.time())})
	-- end
end

function getOrderId(productId)
	widget.obj:setTouchEnabled(false)
	local uId = 0
	if userdata.sdkPlatformInfo and userdata.sdkPlatformInfo.uId then
		uId = userdata.sdkPlatformInfo.uId
	end
	local channelType = 0
	if chltype then
		channelType = chltype
		print("channelType:",channelType)
	end
	local url = payServerUrl.."/ydream/login?type=54&chltype="..channelType.."&charId="..userdata.UserInfo.id.."&bCharId=0".."&productid="..productId
	if getPlatform() == "sgj" then
		url = payServerUrl.."/ydream/login?type=54&chltype="..channelType.."&charId="..userdata.UserInfo.id.."&bCharId=0".."&productid="..productId
	elseif getPlatform() == "xmw" then
		url = payServerUrl.."/ydream/login?type=54&chltype="..channelType.."&charId="..userdata.UserInfo.id.."&bCharId=0".."&productid="..productId.."&appSrc=xmw".."&userId="..uId.."&access_token="..userdata.sdkPlatformInfo.uToken
	elseif getPlatform() == "ipay_chongqin" then
		url = payServerUrl.."/ydream/login?type=54&chltype="..channelType.."&charId="..userdata.UserInfo.id.."&bCharId=0".."&productid="..productId
	end
	print("url",url)
	http.request(url,onGetOrderId)
end

function onGetOrderId(header,body)
	widget.obj:setTouchEnabled(true)
	print("onGetOrderId",body)
	local tab = cjson.decode(body)
	if tab and tab.errCode == 0 then
		if tab.exorderno and tab.exorderno ~= "" then
			local uId = userdata.UserInfo.id
			local uri = payServerUrl.."/ydream/skyfill"
			local rmb = buyItem.rmb*100
			local name = ((buyItem.all ) / 10000).."万金币"
			-- local res = {orderId=tab.exorderno,price=tostring(rmb),payType="3",productName=name,productDesc=name,orderDesc=name,callback=uri}
			-- local params = cjson.encode(res)
			-- luaj.callStaticMethod("com/java/platform/Sky","SkyThirdPay",{params})
			if getPlatform() == "sgj" then
				local res2 = {orderId=tab.exorderno,price=tostring(buyItem.rmb),productId=buyItem.id,userId=uId}
				local params2 = cjson.encode(res2)
				luaj.callStaticMethod("com/java/platform/NdkPlatform","iapPay",{params2})
			elseif getPlatform() == "xmw" then
				local res3 = {orderId=tab.serial,price=tostring(buyItem.rmb),productName=name}
				local params3 = cjson.encode(res3)
				luaj.callStaticMethod("com/java/platform/NdkPlatform","platformPay",{params3})
			elseif getPlatform() == "ipay_chongqin" then
				local res2 = {orderId=tab.exorderno,price=tostring(buyItem.rmb),productId=buyItem.id,userId=uId}
				local params2 = cjson.encode(res2)
				luaj.callStaticMethod("com/java/platform/NdkPlatform","iapPay",{params2})
			end
		end
	end
end

function getCharge(rank,endCall,name)
	print (name)
	rank.list = {}
	local pt = 0
	local tpl = template['charge']
	local begin = 1
	if platform == "IOS" then
		pt = 1
	end

	for i=begin,#tpl do
		local info = {}
		local t = tpl[i]
		if t ~= nil and pt == t.platform and t.id ~=2 and t.id ~= 12 then
			-- if t.limit == -1 or (userdata.UserInfo.chargeMap[i] == nil or userdata.UserInfo.chargeMap[i] < t.limit) then
				info.id = t.id
				if name == "alipay" or t.alipay == 0 then
					local tip = t.name
					local gold = t.goldGet
					if t.limit > 0 then
						tip = tip .."(限购"..t.limit.."次)"
					else
						tip = tip .."(赠送"..(t.giftGet/10000).."万)"
					end
					gold = gold + t.giftGet
					info.tip = tip
					info.gift = ""

					-- if userdata.UserInfo.lastChargeTime/1000 < timeToDayStart(getSyncedTime()) then
						info.gift = info.gift .. "首充+"..(t.goldGet/10000).."万,"
						gold = gold + t.goldGet
					-- else
					-- 	local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
					-- 	if vipLv > 0 then
					-- 	   info.gift = info.gift.."VIP加成+"..(t.goldGet*vipLv*0.1/10000).."万,"
					-- 	   gold = gold + t.goldGet*vipLv*0.1
					-- 	end
					-- end
					-- if name == "alipay" then
					-- 	info.gift = info.gift .. "支付宝+"..(t.specialAdd/10000).."万"
					-- else
					if t.specialAdd > 0 then
						info.gift = info.gift .. "超值包+"..(t.specialAdd/10000).."万"
					end
					-- end
					gold = gold + t.specialAdd
					info.gift = info.gift .. t.tips

					info.all = gold
					info.rmb = t.rmb
					info.productId = t.productId
					table.insert(rank.list,info)
				end
			-- end
		end
	end
	if endCall then
		endCall()
	end
end
function exit()
  if this then
      event.pushEvent("ON_BACK")
   	  event.unListen("CHARGE_SUCCESS", onChargeSuccess)
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
	buy = {_type= "Button",text = {_type="Label"},text_shadow = {_type="Label"},},
	tip = {_type="Label"},
	bottom = {
		gift = {_type="Label"},
	},
	all = {
		text = {_type="Label"},
	},
}

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	tip =  {_type="Label",},
   		listView ={_type = "ScrollView"},
   		tab = {
   			_type="Button",_func=onTab,
   			text  = {_type="Label"},
   		},
   		topTip = {
   			text  = {_type="Label"}
   		},
   		topPos = {
   		    _type = "ImageView",
   		    text = {_type = "ImageView"},
   		},
  	},
  },
  scroll_bg = {
  	scroll_bar = {},
  },

  charge = {
	tmp = {},
  },
}

cacheStrategy={
	rank = {cacheTime = 5*60,},
	localData = {cacheTime = -1},
}

rankInfo = {
	alipay = {name="支付宝充值",tmp=widget.charge.tmp,cacheStrategy = cacheStrategy.localData, itemHeight= 207,interface =getCharge,parms = {"alipay"},render = chargeRender,},
	normal = {name="其他充值",tmp=widget.charge.tmp,cacheStrategy = cacheStrategy.localData, itemHeight= 207,interface =getCharge,parms = {"normal"},render = chargeRender,},
	
	--gold = {name="财富榜",top = widget.gold.top,tmp=widget.gold.tmp,cacheStrategy = cacheStrategy.localData,itemHeight= 207,interface =callServer,parms = {},render = goldRender,topTip=nil,bottomTip ="财富榜每5分钟更新一次",},
}