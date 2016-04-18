local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
module("scene.quitAlert", package.seeall)

this = nil
local parent = nil
local parentModule = nil
local topModule = nil

function create(_parent,_parentModule,_topModule)
   parent = _parent
   parentModule = _parentModule
   topModule = _topModule
   this = tool.loadWidget("cash/quitAlert",widget,parent,200)
   if UserSetting["musicOpen"] then
   	  widget.alert.check_1.obj:setSelectedState(tonumber(UserSetting["musicOpen"]) == 1)
   else
   	  widget.alert.check_1.obj:setSelectedState(true)
   end
   if UserSetting["effectOpen"] then
   	  widget.alert.check_2.obj:setSelectedState(tonumber(UserSetting["effectOpen"]) == 1)
   else
   	  widget.alert.check_2.obj:setSelectedState(true)
   end
   return this
end

function exit()
  if this then
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onCancle(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     exit()
  end
end

function onConfirm(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     print("onConfirm")
     exit()
     -- if topModule and topModule.exit then
     -- 	topModule.exit()
     -- end
     if parentModule and parentModule.onBack then
     	parentModule.onBack(event)
     end 
      parent = nil
      parentModule = nil
      topModule = nil
  end
end

function onCloseMusic(event,data1,data)
  if event == "releaseUp" then
    tool.buttonSound("releaseUp","effect_12")
    data = tolua.cast(data,"CheckBox")
    local check = data:getSelectedState()
    check = not check
     local c = 0
     if check == true then
        c = 1
        UserSetting["musicOpen"] = c
        AudioEngine.playMusic("bgm02.mp3",true)
     else
        UserSetting["musicOpen"] = c
        AudioEngine.stopMusic()
     end
     -- AudioEngine.switchMusic(check)
     -- print("onCloseMusic",Setting.music.open)
     saveSetting("musicOpen",c)
  end
end
function onCloseEffect(event,data1,data)
  if event == "releaseUp" then
    tool.buttonSound("releaseUp","effect_12")
    data = tolua.cast(data,"CheckBox")
    local check = data:getSelectedState()
    check = not check
     local c = 0
     if check == true then
        c = 1
     end
     UserSetting["effectOpen"] = c
     AudioEngine.switchEffect(check)
     saveSetting("effectOpen",c)
  end
end

widget = {
_ignore = true,
  alert = {
    btn_1 = {
    	_type = "Button",
    	_func = onCancle,
    	text = {_type = "Label"},
    	text_shadow = {_type = "Label"},
    },
    btn_2 = {
    	_type = "Button",
    	_func = onConfirm,
    	text = {_type = "Label"},
    	text_shadow = {_type = "Label"},
    },
    title = {_type = "Label"},
    check_1 = {
        _type = "CheckBox",
        _func = onCloseMusic,
    },
    label_1 = {_type = "Label"},
    check_2 = {
        _type = "CheckBox",
        _func = onCloseEffect,
    },
    label_2 = {_type = "Label"},
  },
}