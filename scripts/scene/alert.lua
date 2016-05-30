local tool = require"logic.tool"
module("scene.alert", package.seeall)
this = nil
function create(str,_scene,_okFunc,_cancelFunc,_okStr,_cancelStr,isHide)
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
	this = TouchGroup:create()
	this:setTouchEnabled(true)
	
	local layout = Layout:create()
	layout:setTouchEnabled(true)
	layout:setSize(CCSize(Screen.width,Screen.height))
	layout:setPosition(ccp(0,0))
	layout:setBackGroundColorType(1)
	layout:setBackGroundColor(ccc3(0,0,0))
	layout:setBackGroundColorOpacity(128)
	this:addWidget(layout)
	
	local bg = ImageView:create()
	bg:loadTexture("ui/xiaoBox.png",0)
	--bg:setSize(CCSize(536,378))
	bg:setPosition(ccp(Screen.width / 2, Screen.height / 2))
	--bg:setScale9Enabled(true)
	layout:addChild(bg,1)
	
	-- local title = Label:create()
	-- title:setFontSize(32)
	-- title:setColor(ccc3(255,255,255))
	-- title:setText("提示")
	-- title:setPosition(ccp(0, 150))
	-- title:setFontName(DEFAULT_FONT)
	-- bg:addChild(title,2)
	
	local content = Label:create()
	content:setFontSize(45)
	content:setFontName(DEFAULT_FONT)
	content:setColor(ccc3(255,255,255))
	if str == nil then
		str = "未知错误"
	end
	content:setText(str)
	content:setTextHorizontalAlignment(1)
	content:setTextVerticalAlignment(1)
	content:setAnchorPoint(ccp(0.5,1))
	content:setPosition(ccp(0,150))
	content:setSize(CCSize(600,200))
	content:ignoreContentAdaptWithSize(false)
	bg:addChild(content,2)
	
	local ok = Button:create()
	ok:loadTextures("ui/changBt01.png","ui/changBt01.png","ui/changBt01.png",0)
	ok:setPosition(ccp(-256, -128))
	if _okStr == nil or _okStr == "" then
		_okStr = "确定"
	end
	ok:registerEventScript(
		function (event1)
			if event1 == "releaseUp" then
				if _okFunc then
					_okFunc()
				end
				this.exit()
			end
		end
	)
	ok:setTouchEnabled(true)

	local okLb = Label:create()
	okLb:setText(_okStr)
	okLb:setFontName(DEFAULT_FONT)
	okLb:setFontSize(40)
	okLb:setColor(ccc3(0x80,0x4E,0x0A))
	okLb:setPosition(ccp(0,0))
	ok:addChild(okLb,1)
	local okShadow = tolua.cast(okLb:clone(),"Label")
	okShadow:setColor(ccc3(255,255,255)) -- #FF804E0A
	okShadow:setPosition(ccp(0,-2))
	ok:addChild(okShadow,0)

	bg:addChild(ok,3)
	
	local cancel = Button:create()
	cancel:loadTextures("ui/changBt01.png","ui/changBt01.png","ui/changBt01.png",0)
	cancel:setPosition(ccp(256, -128))
	if _cancelStr == nil or _cancelStr == "" then
		_cancelStr = "取消"
	end
	cancel:registerEventScript(
		function (event1)
			if event1 == "releaseUp" then
				if _cancelFunc then
					_cancelFunc()
				end
				this.exit()
			end
		end
	)

	local cancelLb = Label:create()
	cancelLb:setText(_cancelStr)
	cancelLb:setFontName(DEFAULT_FONT)
	cancelLb:setFontSize(40)
	cancelLb:setColor(ccc3(0x80,0x4E,0x0A))
	cancelLb:setPosition(ccp(0,0))
	cancel:addChild(cancelLb,1)
	local cancelShadow = tolua.cast(cancelLb:clone(),"Label")
	cancelShadow:setColor(ccc3(255,255,255))
	cancelShadow:setPosition(ccp(0,-2))
	cancel:addChild(cancelShadow,0)

	bg:addChild(cancel,4)
	_scene:addChild(this,31)
	
	if type(isHide) == type(true) and isHide == true then
	   performWithDelay(function()
	     this.exit()
	   end,1.0)
	end
	this.exit = function()
		if this then
			layout = nil
			this:removeFromParentAndCleanup(true)
			this = nil
		end
	end
end