local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
local template = require"template.gamedata".data

payServerUrl = payServerUrl

module("scene.loginAlert", package.seeall)

this = nil
subWidget = nil
buyItem = nil

local tmp = nil
function create(parent)
   this = tool.loadWidget("cash/login_alert",widget,parent,99)
   AudioEngine.playEffect("effect_06")
   widget.obj:registerEventScript(onBack)
   resetText()
   return this
end

function resetText()
   local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
   if platform == "IOS" then
     tmp = template['charge'][14-vipLv]
     if vipLv == 6 then
        tmp = template['charge'][9]
     end
   else
     tmp = template['charge'][7-vipLv]
     if vipLv == 6 then
        tmp = template['charge'][2]
     end
   end
   if tmp.rmb then
      widget.alert.btn.text.obj:setText(tmp.rmb.."元购买")
      widget.alert.btn.text_shadow.obj:setText(tmp.rmb.."元购买")
   end
   local tip = tmp.name
   local gift = tmp.tips
   local gold = tmp.goldGet
   if tmp.limit > 0 then
      tip = tip .."(限购"..tmp.limit.."次)"
   else
      tip = tip .."(赠送"..(tmp.giftGet/10000).."万)"
   end
   widget.alert.text_1.obj:setText(tip)
   gold = gold + tmp.giftGet
   if tmp.tips == "" then
      if userdata.UserInfo.lastChargeTime/1000 < timeToDayStart(getSyncedTime()) then
         gift = gift .. "首充+"..(tmp.goldGet/10000).."万,"
         gold = gold + tmp.goldGet
      end
      gift = gift .. "超值包+"..(tmp.specialAdd/10000).."万"
      gold = gold + tmp.specialAdd
   end
   tmp.all = gold
   tmp.rmb = t.rmb
   tmp.productId = t.productId
   widget.alert.text_2.obj:setText("合计:"..(gold/10000).."万")
   widget.alert.text_3.obj:setText(gift)
end

function onBtn(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      -- call("charge",tmp.id)
      buyItem = tmp
      if platform == "Android" then
        getOrderId(tmp.id)
      elseif platform == "IOS" then
        appstoreBuy(info.productId)
      end
  end
end

function appstoreBuy(id)
  luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit"..id,time=tostring(os.time())})

  -- if id == 8 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit6",time=tostring(os.time())})
  -- elseif id == 9 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit12",time=tostring(os.time())})
  -- elseif id == 10 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit30",time=tostring(os.time())})
  -- elseif id == 11 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit60",time=tostring(os.time())})
  -- elseif id == 12 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit120",time=tostring(os.time())})
  -- elseif id == 13 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit300",time=tostring(os.time())})
  -- elseif id == 14 then
  --   luaoc.callStaticMethod("AppController","appstoreBuy",{productId="com.youngdream.fruit600",time=tostring(os.time())})
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

function onBack(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
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
  alert = {
    _type = "ImageView",
    btn = {
        _type="Button",
        _func=onBtn,
       	text =  {_type="Label"},
        text_shadow =  {_type="Label"},
  	},
  	back = {_type = "Button",_func = onBack},
  	text_1 = {_type = "Label"},
  	text_2 = {_type = "Label"},
  	text_3 = {_type = "Label"},
  },
}