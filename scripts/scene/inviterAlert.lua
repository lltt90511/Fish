local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.inviterAlert", package.seeall)

this = nil
local eventHash = {}
local ownerId = 0
local ownerCharName = ""

function create(_id,_charName)
   if not _scene then
      local sceneManager = package.loaded["logic.sceneManager"]
      if sceneManager.currentScene then
        _scene = sceneManager.Scene[sceneManager.currentScene].this
      else
          return 
      end
   end
   AudioEngine.playEffect("effect_06")
   while tolua.type(_scene) ~= "CCScene" do
      _scene = _scene:getParent()
   end
   if this then this.exit() end
   ownerId = _id 
   ownerCharName = _charName
   this = tool.loadWidget("cash/inviterAlert",widget)
   _scene:addChild(this,30)
   widget.alert.name.obj:setText(ownerCharName)
   tool.loadRemoteImage(eventHash, widget.alert.head.icon.obj, ownerId)
   return this
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
      ownerId = 0
      ownerCharName = ""
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onTongYi(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call("fingerGameInviteAgree",ownerId)
      exit()
   end
end

function onJujue(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call("fingerGameInviteRefuse",ownerId)
      exit()
   end
end

widget ={
	_ignore = true,
	alert = {
  		_type = "ImageView",
  		tongyi = {_type = "Button",_func = onTongYi},
  		jujue = {_type = "Button",_func = onJujue},
      head = {
         _type = "ImageView",
         icon = {_type = "ImageView"},
      },
      yazhu = {_type = "ImageView"},
      jinbi = {_type = "ImageView"},
      name = {_type = "Label"},
      yaoqing = {_type = "ImageView"},
      game = {_type = "Label"},
	},
}