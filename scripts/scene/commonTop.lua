local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require"logic.countLv"
local quitAlert = require"scene.quitAlert"
local backList = require"scene.backList"
local exchange = require"scene.exchange"

module("scene.commonTop",package.seeall)

this = nil
local thisParent = nil
local parentModule = nil
local eventHash = {}
isShowChatHistory = false
local messageNum = 0

function create(_parent,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   this = tool.loadWidget("cash/common_top",widget,nil,nil,true)
   thisParent:addChild(this,10)
   this:setPosition(ccp(0,0))

   tool.setWidgetVal(widget.top.name_bg.obj,"name",userdata.UserInfo.nickName)
      
   backList.setBackScene(onBack)
   event.listen("ON_CHANGE_VIP", onChangeVip)
   onChangeVip()
   event.listen("HEAD_ICON_CHANGE", onSetDefaultImageSucceed)
   onSetDefaultImageSucceed()
   -- widget.top.head.obj:setTouchEnabled(true)
   -- widget.top.head.obj:registerEventScript(
   --    function(event)
   --       if event == "releaseUp" then
   --          tool.buttonSound("releaseUp","effect_12")
   --          if messageNum > 0 then
   --             messageNum = 0
   --             widget.top_bg.image.pao.obj:setVisible(false)
   --          end
   --          if not isShowChatHistory and table.maxn(UserChar) > 0 then
   --             isShowChatHistory = true
   --             local chatHistory = package.loaded['scene.chatHistory']
   --             chatHistory.create(thisParent,package.loaded["scene.commonTop"],true)
   --          end
   --       end
   --    end)

   -- initPaoView()
   -- event.listen("ON_SET_PAO", setPao)

   registerEvent()
end

function initPaoView()
   for k,v in pairs(UserChar) do
      for m,n in pairs(v) do
         if tonumber(n.hadRead) == 0 then
            messageNum = messageNum + 1             
         end
      end
   end
   if messageNum > 0 then
      widget.top_bg.image.pao.obj:setVisible(true)
      showPao(messageNum)
   else
      widget.top_bg.image.pao.obj:setVisible(false)
   end
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end


function onSetDefaultImageSucceed()
   -- tool.loadRemoteImage(eventHash, widget.top_bg.image.obj, userdata.UserInfo.id)
   tool.getUserImage(eventHash, widget.top.head.icon.obj, userdata.UserInfo.uidx)
end

function registerEvent()
   event.listen("ON_CHANGE_GOLD", onChangeGold)
   onChangeGold()
end

function unRegisterEvent()
   event.unListen("ON_CHANGE_GOLD", onChangeGold)
end

function onChangeGold()
   if this == nil then
      return
   end
   if userdata.goldAction == false then
      widget.top.gold_bg.num.obj:setStringValue(userdata.UserInfo.owncash)
   end
end

function onChangeVip()
   widget.top.vip.obj:loadTexture("cash/qietu/user/v"..userdata.UserInfo.uGrade..".png")
end

function onRecharge(event)
   if event == "releaseUp" then
      -- call("addGold",10000)
      tool.buttonSound("releaseUp","effect_12")
      local charge = require"scene.chargeAlert"
      charge.create(thisParent,2)
   end
end

function onExchange(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(18001)
      exchange.create(thisParent)
   end
end
function setPao()
   if not this or isShowChatHistory then return end
   messageNum = messageNum + 1
   showPao(messageNum)
end

function showPao(num)
   if messageNum > 10 then
      widget.top_bg.image.pao.num.obj:setText("10+")
   else
      widget.top_bg.image.pao.num.obj:setText(messageNum)
   end
   widget.top_bg.image.pao.obj:setVisible(true)
   activityAni(widget.top_bg.image.pao.obj)
end

function activityAni(obj)
   if not this or not obj:isVisible() then return end
   tool.createEffect(tool.Effect.scale,{time=0.3,scale=1.2},obj,function()
       tool.createEffect(tool.Effect.scale,{time=0.12,scale=1.0},obj,function() 
           tool.createEffect(tool.Effect.delay,{time=math.random(1,5),scale=1.0},obj,function() 
               activityAni(obj) 
           end)
       end)
   end)
end

function exit()
   if this then
      print("commonTop exit!!!!!!!!!!")
      cleanEvent()
      backList.removeList(onBack)
      -- backList.setBackScene(nil,true)
      event.unListen("ON_CHANGE_VIP", onChangeVip)
      event.unListen("HEAD_ICON_CHANGE", onSetDefaultImageSucceed)
      unRegisterEvent()
      this = nil
      thisParent = nil
      parentModule = nil
      isShowChatHistory = false
      messageNum = 0
      tool.cleanWidgetRef(widget)     
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      -- parentModule.onBack(event)
      -- exit()
      quitAlert.create(thisParent,parentModule,package.loaded["scene.commonTop"])
   end
end

widget = {
   _noSizeChange = true,
   _ignore = true,
   top = {
      _type = "ImageView",
      close = {_type = "Button",_func = onBack},
      get = {_type = "Button", _func = onRecharge},
      gold_bg = {
         _type = "ImageView",
         num = {_type = "LabelAtlas"},
         add = {_type = "Button",_func = onExchange},
      },
      name_bg = {
         _type = "ImageView",
         name = {_type = "Label"},
      },
      vip = {_type = "ImageView"},    
      head = {
         _type = "ImageView",
         icon = {_type = "ImageView"},
      },
   },
}
