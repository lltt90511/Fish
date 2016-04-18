local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.gameLoading", package.seeall)

this = nil
thisParent = nil
parentModule = nil
isEnded = false
endFunc = nil
gameTitle = 1

function create(_parent,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   this = tool.loadWidget("cash/loading", widget, thisParent)
   isEnded = false
   endFunc = nil
   playLoading()
end

function playLoading() 
	local str = template["tips"][math.random(#template["tips"])].tip
	widget.bg.tips_label.obj:setText("小提示："..str)

	for i = 1, 3 do
		widget.bg["titlebg"..i].obj:setVisible(false)
	end
	widget.bg["titlebg"..gameTitle].obj:setVisible(true)

	for i=1,15 do
		local star = tool.findChild(widget.bg.obj,"star_"..i,"ImageView")
		star:setOpacity(0)
		starAction(star)
	end

	local per = 0
	widget.bg.bar_bg.bar.obj:setPercent(0) 
	widget.bg.loading_label.obj:setText("正在读取游戏资源：0%")
	local func = nil 
	func = function()
		performWithDelay(
			function() 
				per = per + 2
				widget.bg.bar_bg.bar.obj:setPercent(per)
				widget.bg.loading_label.obj:setText("正在读取游戏资源："..per.."%")
				if per < 100 then
					func()
				else 
					isEnded = true
					if endFunc ~= nil then
						performWithDelay(endFunc,0.5)
				    end
				end
			end,0.03)
	end
	func()
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
		this = nil
		parentModule = nil
		thisParent = nil
	end
end

widget = {
	_ignore = true,
	bg = {
		_type = "ImageView",
		bar_bg = {_type = "ImageView", bar = {_type = "LoadingBar"}},
		loading_label = {_type = "Label", _stroke = true, _strokeLen = 3},
		tips_label = {_type = "Label", _stroke = true, _strokeLen = 3},
		titlebg1 = {_type = "ImageView"},
		titlebg2 = {_type = "ImageView"},
		titlebg3 = {_type = "ImageView"},
	},
}
