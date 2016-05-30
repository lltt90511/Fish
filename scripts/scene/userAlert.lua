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
alertHeight = 590

function create(_parent,_userData,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   data = _userData
   this = tool.loadWidget("cash/userAlert",widget,thisParent,99)
   widget.obj:registerEventScript(onBack)
   widget.bg.name.obj:setText(data.name)
   widget.bg.title.obj:loadTexture("cash/qietu/user/v"..data.grade..".png")
   widget.bg.id.obj:setText("("..data.id..")")
   
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
         alertHeight = 450
         widget.bg.obj:setSize(CCSize(widget.bg.obj:getSize().width,alertHeight))
      else
         alertHeight = 310
         widget.bg.obj:setSize(CCSize(widget.bg.obj:getSize().width,alertHeight))
      end
   end
   widget.bg.btn_3.obj:setVisible(isShow3)
   widget.bg.btn_3.obj:setTouchEnabled(isShow3) 
   widget.bg.btn_4.obj:setVisible(isShow4)
   widget.bg.btn_4.obj:setTouchEnabled(isShow4) 
   widget.bg.btn_5.obj:setVisible(isShow5)
   widget.bg.btn_5.obj:setTouchEnabled(isShow5) 
   widget.bg.btn_6.obj:setVisible(isShow6)
   widget.bg.btn_6.obj:setTouchEnabled(isShow6) 
   userdata.CharIdToImageFile[data.id] = {file=data.pic,sex=data.sex}
   tool.getUserImage(eventHash, widget.bg.head.icon.obj, data.id)
end

function resetAlertPos(pos)
   widget.bg.obj:setPosition(ccp(pos.x,pos.y))
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
      call(19001,1,data.id,5)
      -- if parentModule and parentModule.setPanelSay then
      --    parentModule.setPanelSay(data.id,data.name,0)
      -- end
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
      call(19001,1,data.id,1)
      exit()
   end
end

function onBtn4(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(19001,2,data.id,1)
      exit()
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

widget = {
	_ignore = true,
	bg = {
    _type = "Layout",
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
      text = {_type = "Label"},
    },
    btn_2 = {
      _type = "Button",
      _func=onBtn2,
      text = {_type = "Label"},
    },
    btn_3 = {
      _type = "Button",
      _func=onBtn3,
      text = {_type = "Label"},
    },
    btn_4 = {
      _type = "Button",
      _func=onBtn4,
      text = {_type = "Label"},
    },
    btn_5 = {
      _type = "Button",
      _func=onBtn5,
      text = {_type = "Label"},
    },
    btn_6 = {
      _type = "Button",
      _func=onBtn6,
      text = {_type = "Label"},
    },
	},
}