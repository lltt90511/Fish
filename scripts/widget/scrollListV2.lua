local tool = require"scene.tool"
module("widget.scrollListV2", package.seeall)

--[[
	scrollListV2 
	obj scroll对象
	bar 滚动栏 （孩子）
	barBg 滚动栏底 （父亲）
	config 配置数组
		-- scroll {emptySize(上下空余距离)={top,bottom},heightOffset(高度添加),rowNum(列数),}
		-- item   {size(可见高度)={width,height},pos(放置偏移)={x,y}} 
		-- func   {itemSetFunc(item,info),itemClick(info),itemLongPress(info)}

	
	--对外接口见_intfunc
	--特别说明：
	0.addNewItem来添加对象 （需要自己建立索引 索引从1开始 也代表所在位置） 所有对象添加完成后 调用draw
	1.不要自己去取widget来设置一些参数，因为某个对象不可见的时候它的widget也是不存在的
	2.设置widget只有一条途径 就是我主动来调用 itemSetFunc的时候
	3.itemSetFunc 被调用的两种情况 1.该物件进入视野 2. 该物件被更新并且当时可见（updateItem）
	4.当删除对象（可能需要变换所有索引） 或者大量updateItem 的时候 建议先 stopDraw  然后 removeAllItem 再插入所有数据
	  由于插入对象只是在数据层，所以这个过程很快，需要担心界面会卡住 最后不要忘记调用draw
]]

function create(obj,bar,barBg,defauleItem,config)
	print("#####################createScrollList!!!!!!!!!!!!",os.time())
	local this = {}
	this.obj = obj
	this.innerLayout = tolua.cast(this.obj:getInnerContainer(),"Layout")
	this.bar = {bg = barBg,bar=bar}
	this.defauleItem = defauleItem
	this.isDraw = false
	this.maxId = 0
	this.innerHeight = 0
	this.infoList = {} -- 对象列表  (所有可能被看到的对象)
	this.itemList = {} -- 实例列表  (只建立会被看到或者可能被看到的对象数量)
	_init(this,config)
	_initFunc(this)
	return this
end 

function _init(this,config)
	print("#####################initScrollList!!!!!!!!!!!!",os.time())
	if config == nil then
		config = {}
	end
	if config.scroll == nil then
		config.scroll = {}
	end
	if  config.scroll.emptySize == nil then
		config.scroll.emptySize = {}
	end
	if config.scroll.emptySize.top == nil then
		config.scroll.emptySize.top = 0
	end
	if config.scroll.emptySize.bottom == nil then
		config.scroll.emptySize.bottom = 0
	end

	if config.scroll.emptySize.left == nil then
		config.scroll.emptySize.left = 0
	end
	if config.item == nil then
		config.item = {}
	end
	if config.item.pos == nil then
		config.item.pos = {x=0,y=0}
	end
	if config.func == nil then
		config.func = {}
	end
	local pos = tool.getPosition(this.obj)
	tool.setPosition(this.obj,pos,{x=0,y=config.scroll.emptySize.top})
	

	local size = this.obj:getSize()
	this.size = {width = size.width,height = size.height}
	if config.scroll.heightOffset ~= nil then
		this.size.height = this.size.height + config.scroll.heightOffset + config.scroll.emptySize.top
		this.obj:setSize(CCSize(this.size.width,this.size.height))
	end
	local bgSize = this.bar.bg:getSize()
	this.barHeight = this.size.height -config.scroll.emptySize.top -config.scroll.emptySize.bottom
	
	this.bar.bg:setSize(CCSize(bgSize.width,this.barHeight ))
	
	this.barHeight2 = 0
	this.bar.bg:setOpacity(0)
	this.config = config
	this.obj:registerEventScript(function (event)
		_onScroll(this,event)
	end)
end
-- 所有对外的接口
function _initFunc(this)
	--添加一个对象 你需要自己保存对象的索引
	this.addNewItem = function (id,info)
		this.infoList[id] ={info = info,item = nil}
		--print (id,this.maxId )
		if id > this.maxId then
			this.maxId = id
			if this.isDraw == true then
				_updateInnerSize(this)
			end
		end
	end
	--更新一个对象的数据 根据id索引
	this.updateItem = function (id,newInfo)
		if this.infoList[id] == nil then
			this.infoList[id] = {info = newInfo,item = nil}
		end
		this.infoList[id].info = newInfo
		if this.infoList[id].item  and this.config.func.itemSetFunc then
			this.config.func.itemSetFunc(this.infoList[id].item.obj,this.infoList[id].info)
		end
	end
	--移除多有对象
	this.removeAllItem = function ( )
		for _,item in pairs(this.itemList) do
			item.info = nil
			item.id = nil
		end
		this.maxId = 0
		--this.itemList = {}
		this.infoList = {}
		-- body
	end
	--大量数据插入 防止重绘拖慢系统
	this.stopDraw = function ()
		this.isDraw = false
		_touchEnable(this,false)
	end
	--两种情况调用该函数
	-- 1.所有数据设置完成后，第一次绘制
	-- 2.绘制区域变化时
	-- 3.大量数据插入 禁用即时重绘后恢复
	this.draw = function ()
		_updateInnerSize(this)
		_createVisItem(this)
		_updateAllItemPostion(this)
		_touchEnable(this,true)
	end
	this.scrollToTop = function ()
		this.obj:scrollToTop(0,true)
	end
	this.scrollBottom = function ()
		--this.obj:scrollToBottom(0,true)
	end

	this.touchEnable =  function(flag)
		_touchEnable(this,flag)
	end

    this.onScrollEvent = function(event)
       if this.config.func.onScrollEvent then
          this.config.func.onScrollEvent(event)
       end
    end

    this.effectWithObj = function(id,callback)
       if callback then
          callback(this.infoList[id].item.obj)
       end
    end
end


function _updateInnerSize(this)
	--print ("xxxxxxxxxxxxxxxxx",this.maxId,this.config.scroll.rowNum)
	local line = math.ceil( this.maxId / this.config.scroll.rowNum )
	local innerHeight = line * this.config.item.size.height
	if this.config.scroll.emptySize ~= nil then
		if this.config.scroll.emptySize.top then
			innerHeight = innerHeight + this.config.scroll.emptySize.top
		end
		if this.config.scroll.emptySize.bottom then
			innerHeight = innerHeight + this.config.scroll.emptySize.bottom
		end
	end
	local innerSize = this.obj:getInnerContainerSize()
	this.obj:setInnerContainerSize(CCSize(innerSize.width,innerHeight))
	this.innerHeight = innerHeight
	if this.innerHeight  < this.size.height then
		this.innerHeight  = this.size.height
	end
	local barSize =this.bar.bar:getSize()
	this.bar.bar:setSize(CCSize(barSize.width,this.size.height/innerHeight*this.barHeight))
	this.barHeight2 = this.barHeight  - this.size.height/innerHeight*this.barHeight
	--print ("innerHeight",innerHeight,this.barHeight2 )
end
function _updateAllItemPostion(this)
	 _onScroll(this,"onScroll")
end
function _createVisItem(this)
	local visLine = math.ceil ( this.size.height / this.config.item.size.height) +1
	local itemNum = visLine * this.config.scroll.rowNum
	--print (visLine,itemNum)
	local oldNum = #this.itemList
	if oldNum >= itemNum then
		return
	end
	for i = oldNum+1,itemNum do
		local item ={obj =  this.defauleItem:clone(),info= nil}
		this.itemList[i] = item
		this.obj:addChild(item.obj)
		item.index = i
		item.obj:setTouchEnabled(true)
		item.obj:registerEventScript(function (event,data)
			_onTouchItem(this,item,event,data)
		end)
	end
end

function _touchEnable(this,flag)

end
function _onTouchItem(this,item,event,data)
	local pos = data:getLocation()
    this.onScrollEvent(event)
	if event == "pushDown" then
		print(item.index,pos.x,pos.y)
		item.pressTime = C_CLOCK()
	
		item.pressPos = {x=pos.x,y=pos.y}
		item.release = false

		tool.createEffect(tool.Effect.delay,{time=0.5},item.obj,function()
			if item.info and this.config.func.itemLongPress then
				item.release = true
			    this.config.func.itemLongPress(item.info.info)
			end
		end)
	end
	if item.pressPos == nil then
		return 
	end
	if event == "move" then
		local diffx = pos.x - item.pressPos.x
		local diffy = pos.y - item.pressPos.y
		if math.abs(diffx) > 30 or math.abs(diffy) > 30 then
			item.obj:stopAllActions()
		end
	elseif event == "releaseUp" then
		item.obj:stopAllActions()
		if item.release ==false and item.info and this.config.func.itemClick then
			this.config.func.itemClick(item.info.info)
		end
	elseif event == "cancelUp" then

	end

end

function _onScroll(this,event)
   this.onScrollEvent(event)
	 if event == "pushDown" then
	 	this.scrollPushTime = C_CLOCK()
	 	local y = this.innerLayout:getPositionY()
	 	local height = this.innerHeight- this.size.height - this.config.scroll.emptySize.top
	 	y = this.innerHeight + y - this.size.height - this.config.scroll.emptySize.top
		
	 	this.pushPercent =  y/height
	 end
	 if event == "releaseUp" or event == "cancelUp" then
	 	if this.innerHeight  >= this.size.height then
			return 
		end
	 	local y = this.innerLayout:getPositionY()
	 	y = this.innerHeight + y - this.size.height - this.config.scroll.emptySize.top
	 	local diffTime = C_CLOCK() - this.scrollPushTime
	 	print ("xxxx",diffTime,diffy)
	 	if diffTime < 0.5 then
	 		local height = this.innerHeight- this.size.height - this.config.scroll.emptySize.top
	 		local percent = y/height  
	 		diffTime = diffTime * 2
	 		local diff = 1/diffTime*(percent - this.pushPercent )
	 		if diff *height > 960 then
	 			diff = 1136*2 / height
	 		end
	 		if this.oldPercentTime and C_CLOCK()- this.oldPercentTime <0.6 then
	 			diff  = this.percentAdd *diff
	 			this.pushPercent =  this.oldPercent
	 		else
	 			this.percentAdd = 0
	 		end
	 		percent =this.pushPercent + diff
	 		if diff < 0 then 
	 			diff = -diff
	 		end
	 		if percent < 0 then
	 			percent = 0 
	 		end
	 		if percent >=1 then
	 			percent = 1
	 		end

	 		this.oldPercent = percent
	 		this.oldPercentTime = C_CLOCK()
	 		this.percentAdd  = this.percentAdd  + 1
	 		tool.createEffect(tool.Effect.delay,{time=0},this.obj,function()
	 			local time = 2*diffTime*diff*height/1000
	 			if time <0.1 then
	 				time = 0.1
	 			end

	 			this.obj:scrollToPercentVertical(percent*100,time,false)
	 		end)
	 	else

	 	end
	 end
	 if event == "onScroll" or event == "onScrollFalse" then
	 	--this.innerLayout = tolua.cast(this.obj:getInnerContainer(),"Layout")
		local y = this.innerLayout:getPositionY()
		
		--print ("y:"..y,"innerHeight:"..this.innerHeight,"height:"..this.size.height)
		y = this.innerHeight + y - this.size.height - this.config.scroll.emptySize.top
		if y < 0 then
			y = 0
		end
		if this.barHeight2 > 0 then
			local oldy = this.bar.bar:getPositionY()
			local y = -this.barHeight2*y/(this.innerHeight- this.size.height - this.config.scroll.emptySize.top)
			this.bar.bg:setOpacity(255)
			this.bar.bar:stopAllActions()
			this.bar.bar:setPositionY((oldy+y)/2)

			tool.createEffect(tool.Effect.move,{time=0.05,x=this.bar.bar:getPositionX(),y=y},this.bar.bar)
			tool.createEffect(tool.Effect.delay,{time=0.5},this.bar.bg,function ()
				tool.createEffect(tool.Effect.fadeOut,{time=0.2},this.bar.bg)
			end)
		end
		-- 确定第一个item的位置,重设所有item的位置
		local line = math.floor(y / this.config.item.size.height)
		y = y % this.config.item.size.height

		local startId = line * this.config.scroll.rowNum  
		for i = 1,#this.itemList do
			local id  = startId +i
			local info = this.infoList[startId +i]
			local item = this.itemList[i]
			if info ~= nil and info.item ~= nil and info.item ~= item  then
				this.itemList[item.index] = info.item
				this.itemList[info.item.index] = item
				local index = item.index
				item.index = info.item.index
				info.item.index = index
				item = info.item
			end
		end
		for i = 1,#this.itemList do
			local id  = startId +i
			local info = this.infoList[startId +i]
			local item = this.itemList[i]
			if info ~= nil then
				if info.item == nil then
					if item.info ~= nil then
						item.info.item = nil
					end
					item.info = info
					info.item = item
					info.info.obj = item.obj
					this.config.func.itemSetFunc(item.obj,info.info)
					item.obj:setVisible(true)
				end
			else
				if item.info ~= nil and item.info.item == item then
					item.info.obj = nil
					item.info.info.obj = nil
					item.info.item = nil
					item.info = nil
				end
				item.obj:setVisible(false)
			end	

			local l = math.floor((i-1)/ this.config.scroll.rowNum) +line 
			local r = (i-1) % this.config.scroll.rowNum + 1
			item.obj:setPosition(ccp(this.config.item.size.width*(r-0.5)+this.config.item.pos.x+this.config.scroll.emptySize.left,this.innerHeight - ((l+0.5)*this.config.item.size.height+this.config.item.pos.y+this.config.scroll.emptySize.top)))
				
		end
	 end
end

-- getItemObj  对象克隆需求(行为动画)
-- scrollTop / scrollBottom / scrollToObj (obj在中间)
-- getScrollHeight ,setScrollHeight
-- backUpData / recoverData  备份所有可能的当前状态变成一个数组，用来做可能的恢复
