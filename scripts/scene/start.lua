local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local nc = require"logic.nc"

module("scene.start", package.seeall)

this = nil
subWidget = nil

function create(parent)
   this = tool.loadWidget("cash/start",widget,parent,99)
   AudioEngine.playMusic("bgm01.mp3",true)
   initView()
   return this
end

function armatureBlend(armature)
    local fff = ccBlendFunc()
    local f =  {GL_SRC_ALPHA, GL_ONE};
    fff.src = f[1]
    fff.dst = f[2]
    armature:setBlendFunc(fff)
end

function initView()
	local light = CCSprite:create("cash/qietu/start/guang.png")
	light:setPosition(ccp(540,1290))
	light:setScale(2.0)
	armatureBlend(light)
	widget.bg.obj:addNode(light)
  lightAni(light)
	widget.hua_1.obj:setScale(0)
	widget.hua_2.obj:setScale(0)
	tool.createEffect(tool.Effect.scale,{time=0.2,scale=1.2}, widget.hua_1.obj,
				function()
					tool.createEffect(tool.Effect.scale,{time=0.01,scale=1}, widget.hua_1.obj)
				end)
	tool.createEffect(tool.Effect.scale,{time=0.2,scale=1.2}, widget.hua_2.obj,
				function()
					tool.createEffect(tool.Effect.scale,{time=0.01,scale=1}, widget.hua_2.obj)
				end)
	for i=1,15 do
		local star = tool.findChild(widget.obj,"star_"..i,"ImageView")
		star:setOpacity(0)
		starAction(star)
	end
end

function lightAni(obj)
   local action = CCRotateBy:create(60.0,180)
   local callBack = CCCallFunc:create(function()
      lightAni(obj)
   end)
   action = CCSequence:createWithTwoActions(action,callBack)
   obj:runAction(action)
end

function starAction(obj)
	if not this or not obj then
		return
	end
	tool.createEffect(tool.Effect.fadeIn,{time=math.random(0.4,1.0)},obj,function()
		tool.createEffect(tool.Effect.fadeOut,{time=math.random(0.4,1.0)},obj,function()
			starAction(obj)
		end)
	end)
end

function exit()
   if this then
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
   end
end

function onBegin(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if platform == "Windows" then
        local sceneManager = require"logic.sceneManager"
    	  sceneManager.change(sceneManager.SceneType.loginScene)
      else
        if getPlatform() == "sgj" or getPlatform() == "ipay_chongqin" then
          if UserSetting.uuid ~= nil and UserSetting.uuid ~= "" then
            print("login uuid", UserSetting.uuid)
            nc.connect()
            call("login", 0, UserSetting.uuid)
          else
            if userdata.deviceId then
              print("login deviceId", userdata.deviceId)
              nc.connect()
              call("login", 0, userdata.deviceId)
            end
          end
        elseif getPlatform() == "xmw" then
          nc.disConnect()
          saveSetting("uuid","")
          sdkLogin()
        end
      end
   end
end

widget = {
	_ignore = true,
    bg = {_type = "ImageView"},
   	title = {_type = "ImageView"},
   	gold_r = {_type = "ImageView"},
   	gold_l = {_type = "ImageView"},
   	btn = {_type = "Button",_func = onBegin},
   	hua_1 = {_type = "ImageView"},
   	hua_2 = {_type = "ImageView"},
   	star_l = {_type = "ImageView"},
   	star_2 = {_type = "ImageView"},
   	star_3 = {_type = "ImageView"},
   	star_4 = {_type = "ImageView"},
   	star_5 = {_type = "ImageView"},
   	star_6 = {_type = "ImageView"},
   	star_7 = {_type = "ImageView"},
   	star_8 = {_type = "ImageView"},
   	star_9 = {_type = "ImageView"},
   	star_l0 = {_type = "ImageView"},
   	star_l1 = {_type = "ImageView"},
   	star_l2 = {_type = "ImageView"},
   	star_l3 = {_type = "ImageView"},
   	star_l4 = {_type = "ImageView"},
   	star_l5 = {_type = "ImageView"},
}