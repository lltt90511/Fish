local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.waitInviterAlert", package.seeall)

this = nil

function create(_scene)
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
      _scene  = _scene:getParent()
   end
   if this then this.exit() end
   this = tool.loadWidget("cash/waitInviterAlert",widget)
   _scene:addChild(this,30)
end

function exit()
  if this then
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onQuxiao(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      call(33001)
      exit()
   end
end

widget = {
	_ignore = true,
	alert = {
  		_type = "ImageView",
  		title = {_type = "ImageView"},
  		btn = {_type = "Button",_func = onQuxiao},
	},
}