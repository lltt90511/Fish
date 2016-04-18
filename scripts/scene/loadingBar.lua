module("scene.loadingBar", package.seeall)

-- _maxCount 最大计数
-- _bgPath 背景图路径
-- _scene 添加的场景
-- _func 回调

local labelTextList = {
	[1] = "选择单注可以调整您的单次下注金额哦\n！！！",
	[2] = "当奖金池的金额越高，您能中奖的概率\n更高哦！！",
	[3] = "点击记录可以查看游戏最近的开奖记录\n！！",
	[4] = "每天都有抽奖机会，为您带来丰厚的\n奖励哦！！",
	[5] = "输光了怎么办，不用担心，签到抽奖\n免费拿金币！！",
}

function create(_maxCount, _bgPath, _scene, _func)
	if not _scene then
		return
	end
	
	local this = TouchGroup:create()
	this:setTouchEnabled(true)
	
	local layout = Layout:create()
	layout:setTouchEnabled(true)
	layout:setSize(CCSize(Screen.width,Screen.height))
	layout:setPosition(ccp(0,0))
	layout:setBackGroundColorType(1)
	layout:setBackGroundColor(ccc3(0,0,0))
	layout:setBackGroundColorOpacity(128)
	this:addWidget(layout)
	
	if _bgPath then
		local bg = ImageView:create()
		bg:loadTexture(_bgPath,0)
		bg:setPosition(ccp(Screen.width / 2, Screen.height / 2))
		layout:addChild(bg,1)
	end

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ani/loadingmini2.ExportJson")
	local armature = CCArmature:create("loadingmini2")
    local anim = armature:getAnimation()
	layout:addNode(armature,2)
	armature:setPosition(ccp(Screen.width/2,Screen.height/2))
	anim:playWithIndex(0)

	local loadingBg = ImageView:create()
	loadingBg:loadTexture("ui/loadingBar01.png")
    loadingBg:setScale(1.68)
	loadingBg:setPosition(ccp(Screen.width / 2,80))
	layout:addChild(loadingBg,2)
	
	local loadingBar = LoadingBar:create()
	loadingBar:loadTexture("ui/loadingBar02.png",0)
    loadingBar:setScale(1.68)
	loadingBar:setPosition(ccp(Screen.width / 2,80))
	loadingBar:setPercent(0)
	layout:addChild(loadingBar,3)
	
	local label_1 = Label:create()
	label_1:setFontSize(40)
	label_1:setText("Loading")
	label_1:setPosition(ccp(Screen.width / 2 - 420, 160))
	layout:addChild(label_1,4)
	
	local label_2 = Label:create()
	label_2:setFontSize(40)
	label_2:setText("0%")
	label_2:setPosition(ccp(Screen.width / 2 + 420,160))
	layout:addChild(label_2,5)
	
	math.randomseed(os.time())
	local randomNum = math.random(1,5)
	local label_3 = Label:create()
	label_3:setFontSize(40)
	label_3:setText("游戏小贴士："..labelTextList[randomNum])
	label_3:setPosition(ccp(Screen.width / 2,300))
	layout:addChild(label_3,5)

	_scene:addChild(this,30)
	
	this.maxCount = 100
	if _maxCount then
		this.maxCount = _maxCount
	end
	this.nowCount = 0
	
	local timeHandler = nil
	local label = "Loading"
	
	this.update = function(count,text)
		this.nowCount = this.nowCount + count
		if text then
			label = text
		end
		print("update nowCount/maxCount",this.nowCount,this.maxCount)
		if this.nowCount > this.maxCount then
			print("超出最大值")
			this.nowCount = this.maxCount
		end
		label_1:setText(label)
		local percent = string.format("%0.4f", this.nowCount / this.maxCount) * 100 .. "%"
		label_2:setText(percent)
		loadingBar:setPercent(this.nowCount / this.maxCount * 100)
		if this.nowCount == this.maxCount and _func then
			_func()
		end
	end
	
	this.show = function(text,now,max)
		if text then
			label = text
		end
		if now > max then
			print("超出最大值")
			now = max
		end
		label_1:setText(label)
		local percent = string.format("%0.4f", now / max) * 100 .. "%"
		label_2:setText(percent)
		loadingBar:setPercent(now / max * 100)
		if now == max and _func then
			_func()
		end
	end
	
	this.hide = function()
		this:setVisible(false)
	end
	
	this.setMaxCount = function(count)
		this.maxCount = count
	end
	
	this.exit = function()
		if this then
			this:removeFromParentAndCleanup(true)
		end
	end
	
	return this
end
