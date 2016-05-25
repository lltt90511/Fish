local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.userAlert", package.seeall)

this = nil
thisParent = nil
local parentModule = nil
local uGrade = 0
local uId = 0
local uName = ""
local eventHash = {}
local data = {}

function create(_parent,_userData,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   data = _userData
   this = tool.loadWidget("cash/userAlert",widget,thisParent,99)
   widget.obj:registerEventScript(onBack)
   widget.alert.title.obj:loadTexture("cash/qietu/user/v"..data.grade..".png")
   widget.alert.id.obj:setText(data.id)
   widget.alert.id.obj:setPosition(ccp(widget.alert.title.obj:getPositionX()+widget.alert.title.obj:getSize().width*2+10,widget.alert.id.obj:getPositionY()))
   widget.alert.name.obj:setText(data.name)
   widget.alert.send.obj:setPosition(ccp(widget.alert.name.obj:getPositionX()+widget.alert.name.obj:getSize().width+10+widget.alert.send.obj:getSize().width/2,widget.alert.send.obj:getPositionY()))
   widget.alert.send.obj:setVisible(false)
   widget.alert.send.obj:setTouchEnabled(false)
   local isShow3 = false
   local isShow4 = false
   local isShow5 = false
   local isShow6 = false
   if userdata.UserInfo.GM == 1 then
      isShow3 = true
      isShow4 = true
      isShow5 = true
      isShow6 = true
   else
      if userdata.UserInfo.uGrade > data.grade then
         isShow3 = true
         isShow4 = true
         widget.alert.btn_1.obj:setPosition(ccp(widget.alert.btn_1.obj:getPositionX(),-10))
         widget.alert.btn_2.obj:setPosition(ccp(widget.alert.btn_2.obj:getPositionX(),-10))
         widget.alert.btn_3.obj:setPosition(ccp(widget.alert.btn_3.obj:getPositionX(),-120))
         widget.alert.btn_4.obj:setPosition(ccp(widget.alert.btn_4.obj:getPositionX(),-120))
      else
         widget.alert.btn_1.obj:setPosition(ccp(widget.alert.btn_1.obj:getPositionX(),-30))
         widget.alert.btn_2.obj:setPosition(ccp(widget.alert.btn_2.obj:getPositionX(),-30))
      end
   end
   widget.alert.btn_3.obj:setVisible(isShow3)
   widget.alert.btn_3.obj:setTouchEnabled(isShow3) 
   widget.alert.btn_4.obj:setVisible(isShow4)
   widget.alert.btn_4.obj:setTouchEnabled(isShow4) 
   widget.alert.btn_5.obj:setVisible(isShow5)
   widget.alert.btn_5.obj:setTouchEnabled(isShow5) 
   widget.alert.btn_6.obj:setVisible(isShow6)
   widget.alert.btn_6.obj:setTouchEnabled(isShow6) 
   userdata.CharIdToImageFile[data.id] = {file=data.pic,sex=data.sex}
   tool.getUserImage(eventHash, widget.alert.head.icon.obj, data.id)
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end

function exit()
  if this then
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      cleanEvent()
      this = nil
      thisParent = nil
      parentModule = nil
      uGrade = 0
      uId = 0
      uName = ""
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
      if parentModule and parentModule.setPanelSay then
         parentModule.setPanelSay(data.id,data.name,0)
      end
      exit()
   end
end

function onBtn2(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if parentModule and parentModule.setPanelSay then
         parentModule.setPanelSay(data.id,data.name,1)
      end
      exit()
   end
end

function onBtn3(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      
   end
end

function onBtn4(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      
   end
end

function onBtn5(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      
   end
end

function onBtn6(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      
   end
end

function onSend(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      
   end
end

widget = {
	_ignore = true,
	alert = {
    _type = "ImageView",
    back = {_type="Button",_func=onBack},
    head = {
      _type = "ImageView",
      icon = {_type = "ImageView"},
    },
    title = {_type = "ImageView"},
    id = {_type = "Label"},
    name = {_type = "Label"},
    btn_1 = {
      _type = "Button",
      _func=onBtn1,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    btn_2 = {
      _type = "Button",
      _func=onBtn2,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    btn_3 = {
      _type = "Button",
      _func=onBtn3,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    btn_4 = {
      _type = "Button",
      _func=onBtn4,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    btn_5 = {
      _type = "Button",
      _func=onBtn5,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    btn_6 = {
      _type = "Button",
      _func=onBtn6,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
    send = {
      _type = "Button",
      _func=onSend,
      label = {_type = "Label"},
      label_shadow = {_type = "Label"},
    },
	},
}