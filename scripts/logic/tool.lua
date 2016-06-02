local math,platform = math,platform
module("logic.tool", package.seeall)
MainPackage = nil

function getStarStr(star,limit)
	local str = ""
	if limit == nil then
		limit = star
	end
	if limit < star then
		limit = star
	end

 	for i = 1,limit do
		if star >= i then
			str = str .. "1"
		else
			str = str .. "0"
		end
	end
	return str
end
function registerMainWidget(package)
	MainPackage = package
end
function setMainWidgetTouchEnabled(flag)
	MainPackage.setTouchEnabled(flag)
end
function findChild(widget,name,type)
	if not type then
		type = "Widget"
	end
	--print(widget:getChildByName(name))
	return tolua.cast(widget:getChildByName(name), type)
end
function cleanWidgetRef(widget)
	widget.obj = nil
	widget.shadow = nil
	for i,v in pairs(widget) do
		if type(v) == "table" then
			cleanWidgetRef(v)
		end
	end
end

function unregisterWidgetEvent(widget)
	if widget.obj then
		widget.obj:setTouchEnabled(false)
		widget.obj:unregisterEventScript()
	end
	for i,v in pairs(widget) do
		if type(v) == "table" then
			unregisterWidgetEvent(v)
		end
	end
end

function setWidgetVal(parent,name,val)
	local w1 = findChild(parent,name,"Label")
	local w2 = findChild(w1,name,"Label")
	w1:setText(val)
	if w2 ~= nil then
		w2:setText(val)
	end
	--local shadow = 
	--widget.shadow:setText(val)
end
function setLabelVal(widget,val)
	widget.obj:setText(val)
	if widget.shadow ~= nil then
		widget.shadow:setText(val)
	end
end
function addTouchHandler(widget,func)
	widget.obj:setTouchEnabled(true)
	widget.obj:registerEventScript(func)
end
addHandler = addTouchHandler
buttonTime = nil
function buttonSound(event,effect)
	--print (event,os.time())
	if event == "pushDown" then
		AudioEngine.playEffect(effect)
	end
	if  event == "releaseUp" then
		AudioEngine.playEffect(effect)
	end
end
function loadWidgetForClone(widgetList,widget)
	print ("loadWidgetForClone")
	local widgetListNow = cloneTable(widgetList)
	loadEachWidget(widgetListNow,widget)
	return widgetListNow
end
function loadEachWidget(widget,parent,name)
	if not widget._ignore then
		if widget._name then
			name = widget._name 
		end
		local type = "Widget"
		if widget._type then
			type = widget._type 
		end
		--print(name)
		widget.obj =tolua.cast(parent:getChildByName(name), type)
		local orgParent = parent
		parent = widget.obj 
		if type=="Layout" then
		   local func = widget._func
		   if func then
		      local func2 = function(event,data)

		      	   if widget._ingnoreEffect ~= true then
		      	   		local effect = "system_01"
		      	   		if widget._effect ~= nil then
		      	   			effect = widget._effect
		      	   		end
		      	   		buttonSound(event,effect)
		      	   end
			 	   func(event,data,widget.obj,widget._data);
		      end
		      widget.obj:registerEventScript(func2)
		      widget.obj:setTouchEnabled(true)
		   end
		end
		if type == "Button" or type == "CheckBox" then
		   local func = widget._func
		   if func then
		      local func2 = function(event,data)
		      		--print (event,name)
		      	   if widget._ingnoreEffect ~= true then
		      	   		local effect = "system_01"
		      	   		if widget._effect ~= nil then
		      	   			effect = widget._effect
		      	   		end
		      	   		buttonSound(event,effect)
		      	   end
			 	   func(event,data,widget.obj,widget._data);
		      end
		      widget.obj:registerEventScript(func2)
		      widget.obj:setTouchEnabled(true)
		   end
		   
		end
		if type == "Button" then
			if widget._noStroke then
				--local obj = tolua.cast( widget.obj,"CCNode")
				local font =  tolua.cast(widget.obj:getTitleRender(),"CCLabelTTF")
				font:disableStroke()
			end
			-- 按钮文字纵向调整
			if widget._textAnchorY then
				local lb =  tolua.cast(widget.obj:getTitleRender(),"CCLabelAtlas")
				local pos =  getPosition(lb)
				local posX = 0
				if widget._textAnchorX then
					posX = widget._textAnchorX
				end
				lb:setPosition(CCPoint(pos.x + posX, pos.y + widget._textAnchorY))
			end
		end
		if type == "Label" then
		   local func = widget._func
		   if func then
		      local func2 = function(event,data)
			 func(event,data,widget.obj,widget.data)
		      end
		      widget.obj:registerEventScript(func2)
		      widget.obj:setTouchEnabled(true)
		   end
		   if widget.font_normal == nil or (platform == "Windows" ) then
		      widget.obj:setFontName(DEFAULT_FONT)
		   end

			local font =  tolua.cast(widget.obj:getVirtualRenderer(),"CCLabelTTF")
			if widget.specailColor ~= true  then
				if widget._colorR then
					widget.obj:setColor(ccc3(widget._colorR,widget._colorG,widget._colorB))
				end
			else
				if widget._colorR then
					widget.obj:setColor(ccc3(255,255,255))
					font:setFontFillColor(ccc3(widget._colorR,widget._colorG,widget._colorB))
				else
					local color  = widget.obj:getColor()
					font:setFontFillColor(ccc3(color.r,color.g,color.b))
					widget.obj:setColor(ccc3(255,255,255))
				end
			end
			--widget.font:setString("xxxx")
			if widget._shadow then
				local margin = nil
				local left = nil
				local right = nil
				local top= nil
				local bottom= nil
				local align = nil
				local layoutParam = tolua.cast(widget.obj:getLayoutParameter(2),"RelativeLayoutParameter")
				if layoutParam and layoutParam:getLayoutType() == 2 then
					 align = layoutParam:getAlign()
					 margin = layoutParam:getMargin()
					 --margin = Margin(margin)
					 left = margin.left
					 right = margin.right
					 top = margin.top
					 bottom = margin.bottom
					-- print (left,right,top,bottom)
				end
				widget.shadow = tolua.cast(widget.obj:clone(),"Label")
				widget.shadow:setName(name)
                local r,g,b = 26,26,26
                if widget._shadowColor  ~= nil then
					r =  widget._shadowColor.r
					g =  widget._shadowColor.g
					b = widget._shadowColor.b
				end
				widget.shadow:setColor(ccc3(r, g, b))
				
				widget.shadow:setPosition(CCPoint(widget.obj:getPositionX(),widget.obj:getPositionY()))
				
				widget.obj:removeFromParent()
				widget.shadow:addChild(widget.obj)
				--widget.obj:setVisible(true)
				widget.obj:setPosition(CCPoint( -1,1))
				orgParent:addChild(widget.shadow)
				--widget.shadow:setVisible(true)
				if margin then
					local layoutParam = tolua.cast(widget.shadow:getLayoutParameter(2),"RelativeLayoutParameter")
					layoutParam:setAlign(align)
					margin = layoutParam:getMargin()
					margin.left = left
					margin.right = right
					margin.top = top
					margin.bottom = bottom
					widget.shadow:getParent():updateSizeAndPosition()
				end
			end
			if widget._stroke then
				local r,g,b =0,0,0
				if widget._strokeColor  ~= nil then
					r =  widget._strokeColor.r
					g =  widget._strokeColor.g
					b = widget._strokeColor.b
				end
			   if widget._strokeLen then
			      font:enableStroke(ccc3(r,g,b),widget._strokeLen)
			   else
			      font:enableStroke(ccc3(r,g,b),1)
			   end
			end
		end
		if type == "Button" then
			widget.obj:setTitleFontName(DEFAULT_FONT)
		end
		if type == "ScrollView" then
			local func = widget._func
			if func then
				widget.obj:registerEventScript(func)
			end
			-- widget.obj:setClippingType(LAYOUT_CLIPPING_SCISSOR)
		end
		if type == "Slider" then
			local func = widget._func
			if func then
				widget.obj:registerEventScript(func)
			end
		end
		if type == "PageView" then
			-- widget.obj:setClippingType(LAYOUT_CLIPPING_SCISSOR)
		end
		if widget._anchorx and widget._anchory then
			widget.obj:setAnchorPoint(ccp(widget._anchorx , widget._anchory))
			if widget._posx then
				widget.obj:setPositionPercent(CCPoint(widget._posx , widget._posy))
			end
		end
	end
	for name,v in pairs(widget) do
		if type(v) == "table" then

			loadEachWidget(v,parent,name)
		end

	end
end

function setSelfAndChildTouchEnabled(widget,flag)
	widget.obj:setTouchEnabled(flag)
	for name,v in pairs(widget) do
		if type(v) == "table" then
			setSelfAndChildTouchEnabled(v,flag)
		end
	end
end

function loadWidget(file,widgetList,this,z,onlyWidget,addH)
	--print(file)
	local thisflag = true
	local this2 = this

	if not this then
		this = TouchGroup:create()
		thisflag = false
	end
	if addH ==nil then
		addH = 0
	end
    local reader = GUIReader:shareReader()
    --local widget = reader:widgetFromBinaryFile(file..".csb")
    print (file)
    local widget = reader:widgetFromJsonFile(file..".json")
    widgetList.addSizeHeight=0
   	if widgetList._bottomEmptyHeight == nil then
   		widgetList._bottomEmptyHeight = 0
   	end
 	if not widgetList._noSizeChange then
    	if widgetList._mainFullSize then
    		local size = widget:getSize()
    		local height =size.height
    		widget:setSize(CCSize(Screen.width,addH+ Main_Screen.useHeight - widgetList._bottomEmptyHeight))
    		widgetList.addSizeHeight = Main_Screen.useHeight - height - widgetList._bottomEmptyHeight+addH
    	else
	    	local size = widget:getSize()
	    	local offset = Screen.height - 1920
		    widget:setSize(CCSize(Screen.width, size.height+offset+addH))
		end
	end
 
    print ("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",widgetList.addSizeHeight  )
    if widgetList._mainSub then
    	local size = widget:getSize()
    	widget:setAnchorPoint(ccp(0.0,1.0))
    	widget:setPosition(ccp(0,Screen.height - Main_Screen.top))
    else
    	  widget:setAnchorPoint(ccp(0.0 , 0.5))
   		 widget:setPosition(CCPoint(0,Screen.height/2))
    end
  	if widgetList._changePostion then
		if widgetList._top then
			local size = widget:getSize()
			local top = Screen.height - size.height/2-187
			widget:setPosition(CCPoint(0,top))
		end

	end
	if not onlyWidget then
		if z == nil then
			print (tolua.type(this))
			if tolua.type(this) == "TouchGroup" then
			    this:addWidget(widget)
			else
		   	   this:addChild(widget)
		   	end
		else
			--this:addWidget(widget)
			--this:setZOrder(z)
			--if this:getRootWidget() then
			--print (this)
			print (tolua.type(this))
			if tolua.type(this) == "TouchGroup" then
			    this:getRootWidget():addChild(widget,z)
			else
				this:addChild(widget,z)
			end
			--else
				--this:addWidget(widget)
			    --this:setZOrder(z)
			--end
		end
	else
		if this2 then
           if z ~= nil then
              this2:addChild(widget,z)
           else 
              this2:addChild(widget)
           end
		end
		thisflag = true
	end
    widgetList.obj = widget
    if widgetList then
    	loadEachWidget(widgetList,widget)
    end
    if thisflag then
    	return widget
    else
   		return this
   	end
end

function createColorBG(this,color)

	local layer = CCLayerColor:create(ccc4(512, 512, 512, 512), 640, 960);  
	--layer:ignoreAnchorPointForPosition(false);  
	layer:setPosition(640/ 2, 960/ 2);  
	this:addChild(layer,-1);  
end
--CCFadeIn
--CCFadeOut
Effect ={
	fadeIn = 1,
	fadeOut = 2,
	fadeTo = 3,
	move = 4,
	scale = 5,
	ripple = 6,
	liquid = 7,
	endLipuid = 8,
	ShatteredTiles3D = 9,
	SkewTo = 10,
	rotate = 11,
	delay = 12,
	blink = 13,
	shake = 14,
	bezier = 15,
}

function createTwoEffet(e,param,e2,param2,obj,callBack)
    createEffect(e,param,obj,function ()
    	createEffect(e2,param2,obj,callBack)
    end)
end
function createGroupEffect(obj,actionList,callBack,preAction,anim,info)
	if info == nil then
		info = {}
	end
	local cnt = 1
	
	local func = nil
	local handler = nil
	info.stopGroupAction = function ()
		if handler then
			obj:stopAction(handler)
		end
	end
	func = function ()
		handler = nil
		local action = actionList[cnt]
		cnt = cnt + 1
		if action == nil then
			info.stopGroupAction = nil
			if callBack then
				callBack()
			end
		else
			handler = createEffect(action[1],action[2],obj,func,preAction,anim)
		end
		
	end
	func()

end
notWidgetType = {
	CCNode = 1,
	CCNodeRGBA = 1,
	CCSprite = 1,
	CCArmature = 1,
	CCEditBox = 1,
	TouchGroup = 1,
	CCParticleSystemQuad = 1,
	CCParticleSystem = 1,
	CCScene = 1,
}
function createEffect(e,param,obj,callBack,preAction,anim)
	local action = nil

	if e == Effect.fadeIn then
		action = CCFadeIn:create(param.time)
	elseif e == Effect.fadeOut  then
		action = CCFadeOut:create(param.time)
	elseif e == Effect.fadeTo then
		action = CCFadeTo:create(param.time,param.opacity)
	elseif e == Effect.shake then

		local roate = obj:getRotation()
		action = CCRotateTo:create(param.time,param.roate+roate)
		local action2 = CCRotateTo:create(param.time,roate - param.roate)
		local action3 = CCRotateTo:create(param.time, roate)
		action = CCSequence:createWithTwoActions(action,action2)
		action = CCSequence:createWithTwoActions(action,action3)
	elseif e == Effect.move then
		local class = tolua.type(obj)
		local parent = obj:getParent()
		local isWidget = false
		local parentIsLayout = false
		--print(class)
		if notWidgetType[class] == 1 then
			obj = tolua.cast(obj,"CCNode")
			isWidget = false
		else
			obj = tolua.cast(obj,"Widget")
			isWidget = true
		end
		if isWidget and parent ~= nil then
			local posType = LAYOUT_ABSOLUTE
			--print (tolua.type(parent))
			if notWidgetType[tolua.type(parent)]~= 1  and  parent:getWidgetType()== WidgetTypeContainer then
				parent = tolua.cast(parent,"Layout")
				if parent:getLayoutType()  == LAYOUT_RELATIVE then
					posType = LAYOUT_RELATIVE
				end
			end
			if posType == LAYOUT_RELATIVE then
				local layoutParam = tolua.cast(obj:getLayoutParameter(LAYOUT_PARAMETER_RELATIVE),"RelativeLayoutParameter")
				local pos = {x= obj:getPositionX(),y=obj:getPositionY()}
				if param.abs ~= true then
					param.x = param.x -pos.x
					param.y = param.y -pos.y
				end
	
				local margin = layoutParam:getMargin()
				local now = os.time()
				local left = margin.left
				local right = margin.right
				local top = margin.top
				local bottom = margin.bottom
				local setMargin = function  (time)
					local percent =  time / param.time
					margin.left = left + param.x * percent
					margin.right = right + param.x * percent
					margin.top = top + param.y * percent
					
					margin.bottom = bottom + param.y * percent
					parent:updateSizeAndPosition()
				end
				local timer = nil
				local timeAll = 0
				--local t0 = socket.gettime()
				local startTime = C_CLOCK()
				setMargin(timeAll)
				local func  
				func = function (dt)
					
					timeAll =  C_CLOCK() - startTime
					--print (timeAll)
					if timeAll > param.time then
						--unSchedule(timer)
						--margin = layoutParam:getMargin()
						margin.left = left + param.x 
						margin.right = right + param.x
						margin.top =  top + param.y 
						margin.bottom = bottom + param.y
						parent:updateSizeAndPosition()
	
						if callBack then
							callBack()
						end
						return 
					else
						setMargin(timeAll)
						createEffect(Effect.delay,{time=0.03},obj,func,true,false)
					end
			    end
				func()
				return  
			end
		end
		if param.sabs == true then
			local pos = getPosition(obj)
			param.x = pos.x+param.x
			param.y = pos.y+param.y
		end
		
		   action = CCMoveTo:create(param.time,CCPoint(param.x,param.y))
		
	elseif e == Effect.scale then
		if param.scaleX ~= nil then
			action = CCScaleTo:create(param.time,param.scaleX,param.scaleY)
		else
			action = CCScaleTo:create(param.time,param.scale)
		end
	elseif e == Effect.ripple then
		 action = CCRipple3D:create(param.time, param.size, param.pos, param.radius,param.waves, param.amplitude);  
	elseif e == Effect.liquid then
		action = CCLiquid:create(param.time, param.size, param.waves, param.amplitude);
	elseif e == Effect.endLipuid then
		action = CCLiquid:create(0, param.size, 0, 0);
	elseif e== Effect.ShatteredTiles3D then
		action = CCShatteredTiles3D:create(param.time,param.size,param.width,true)
	elseif e== Effect.SkewTo then
		action = CCSkewTo:create(param.time, param.x, param.y);
	elseif e==Effect.rotate then
		action = CCRotateTo:create(param.time,param.rotate);
	elseif e == Effect.delay then
		action  = CCDelayTime:create(param.time)
	elseif e == Effect.blink then
		action = CCBlink:create(param.time,param.f)
	elseif e == Effect.bezier then
	   local config = ccBezierConfig()
	   config.endPosition = ccp(param.x3,param.y3)
	   config.controlPoint_1 = ccp(param.x1,param.y1)
	   config.controlPoint_2 = ccp(param.x2,param.y2)
	   action = CCBezierTo:create(param.time,config)
	end

	if param.easeIn == true then
	   action = CCEaseIn:create(action,1)
	elseif param.easeOut == true then
	   action = CCEaseOut:create(action,1)
	end
	
	local orgAction = action


    if callBack then
    	--print("createEffect")
	   local allBack = CCCallFunc:create(function()
	    	--performWithDelay(function()
			callBack(obj,orgAction)
			--end,param.time)
	   end)
	   
	   action = CCSequence:createWithTwoActions(action,allBack)
    end
    if not preAction and param.noStop ~= true then
       obj:stopAllActions()
    end
    if anim ~= true and  tolua.cast(obj,"Widget") ~=nil then
       --print (obj:getName(),e)
    end
    --print ("create")
    if obj and obj:getParent() ~= nil then
    	--print ("createSucceed")
       obj:runAction(action)
       return action
    end
    return nil

end
EnterAddEffect = {
	shake = 1,
	drop = 2,
}
function createEnterEffect(obj,diffpos,time,callback,anim,addEffect)
	local pos = {x= obj:getPositionX(),y=obj:getPositionY()}

	local class = tolua.type(obj)
	local parent = obj:getParent()
	local isWidget = false
	if notWidgetType[class] then
		obj = tolua.cast(obj,"CCNode")
		isWidget = false
	else
		obj = tolua.cast(obj,"Widget")
		isWidget = true
	end

	if isWidget  then
		local posType = LAYOUT_ABSOLUTE
		--print (tolua.type(parent))
		if notWidgetType[tolua.type(parent)]~= 1  and  parent:getWidgetType()== WidgetTypeContainer then
			parent = tolua.cast(parent,"Layout")
			if parent:getLayoutType()  == LAYOUT_RELATIVE then
				posType = LAYOUT_RELATIVE
			end
		end
		if posType == LAYOUT_RELATIVE then	
			local layoutParam = tolua.cast(obj:getLayoutParameter(LAYOUT_PARAMETER_RELATIVE),"RelativeLayoutParameter")
			local margin = layoutParam:getMargin()
			margin.left = margin.left + diffpos.x 
			margin.right = margin.right + diffpos.x
			margin.top =  margin.top + diffpos.y 
			margin.bottom = margin.bottom + diffpos.y	
			parent:updateSizeAndPosition()		
		end

	end
	obj:setPosition(CCPoint(pos.x+diffpos.x,pos.y+diffpos.y))
	local x = 0
	local y =0 
	if diffpos.x ~= 0 then
	   x = 20
	end
	if diffpos.y ~= 0 then
	   y = -20
	end
	
	if addEffect == nil then
		createGroupEffect(obj,{
			{Effect.move,{time=time-0.02,x=pos.x,y=pos.y,easeIn=diffpos.easeIn,easeOut=diffpos.easeOut}},
			},callback,true,anim)
	elseif addEffect == EnterAddEffect.drop then
		createGroupEffect(obj,
				  {
				     {Effect.move,{time=time-0.1,x=pos.x,y=pos.y,easeIn=diffpos.easeIn,easeOut=diffpos.easeOut}},
				  },function()
				     performWithDelay(function()
							 local pos = getPosition(obj)
							 createEffect(Effect.bezier,{time=0.1,x1=pos.x,y1=pos.y,x2=pos.x+x,y2=pos.y+y,x3=pos.x,y3=pos.y},obj,function ()
							 	if callback then
							 		callback()
							 	end
							 	setPosition(obj,pos)
							 end,true)
					 end,0)
				    end,true,anim
		)
	elseif addEffect == EnterAddEffect.shake then
		local rotate = 5
		local timeE = 0.05
		local height = 4
		createGroupEffect(obj,{
			{Effect.move,{time=time-0.02,x=pos.x,y=pos.y,easeIn=diffpos.easeIn,easeOut=diffpos.easeOut}},
			},
		function ()
		   createEffect(Effect.rotate,{time = timeE,rotate=rotate},obj,nil,true)
		   createEffect(Effect.move,{time=timeE,x=0,y=height,sabs=true},obj,
				function ()
				   createEffect(Effect.rotate,{time = timeE/2,rotate=0},obj,nil,true)
				   createEffect(Effect.move,{time=timeE/2,x=0,y=-height,sabs=true},obj,
						function ()
						   createEffect(Effect.rotate,{time = timeE/2,rotate=-rotate},obj,nil,true)
						   createEffect(Effect.move,{time=timeE/2,x=0,y=height/2,sabs=true},obj,
								function ()
								   createEffect(Effect.rotate,{time = timeE/2,rotate=0},obj,nil,true)
								   createEffect(Effect.move,{time=timeE/2,x=0,y=-height/2,sabs=true},obj,callback,true)
								end,true)

						end,true)
				end,true)
		end,true,anim)
	end
end
function createExitEffect(obj,diffpos,time,recovery,callback)
	if type(recovery) == "function" then
		--print ("createExitEffect arge#3 is Function :not Boolean")
		return
	end 
	local pos = getPosition(obj)

	--obj:setPosition(CCPoint(pos.x+diffpos.x,pos.y+diffpos.y))
	if recovery then

		createEffect(Effect.move,{time=time,x=pos.x+diffpos.x,y=pos.y+diffpos.y,easeIn=diffpos.easeIn,easeOut=diffpos.easeOut},obj,function()
			setPosition(obj,pos,{x=0,y=0})

			if callback then
				callback()
			end
		end,true)
	else
		--print ("createExitEffect")
		createEffect(Effect.move,{time=time,x=pos.x+diffpos.x,y=pos.y+diffpos.y,easeIn=diffpos.easeIn,easeOut=diffpos.easeOut},obj,callback,true)
	end
end


function longPress(event,data,info,longPressFunc)
	local pos = data:getLocation()
	if event == "pushDown" then
		--info.clickTime = os.time()
		--info.longPress = false
		info.longPressInfo ={
			clickTime = os.time(),
			longPress = false,
			Timer = nil,
			startpos ={x=pos.x,y=pos.y},
		}
		info.longPressInfo.Timer = performWithDelay(function()
			print ("longPressTimer start")
			longPressFunc(info,event,data)
			info.longPressInfo.longPress = true
		end,0.3)
	elseif event == "move" then
		if info.longPressInfo == nil then
			return 0
		end
		local diffx = pos.x - info.longPressInfo.startpos.x
		local diffy = pos.y - info.longPressInfo.startpos.y
		if math.abs(diffx) > 30 or math.abs(diffy) > 30 then
			unSchedule(info.longPressInfo.Timer)
		end
	else
		if info.longPressInfo == nil then
			return 0
		end
		if info.longPressInfo then
			unSchedule(info.longPressInfo.Timer)
		end
	end
	if info.longPressInfo then
		return info.longPressInfo.longPress
	else
		return 0
	end
end

function setOffsetPostion(new,offset)


end
function distance(a,b)

		local disx = a.x -b.x
		local disy = a.y - b.y
		return math.sqrt(disx*disx , disy*disy)

end

function getPosition(old)
	if not old then
		print("old is nil")
		return
	end
	local pos = {}
	local obj = nil
	local class = tolua.type(old)
	local parent = old:getParent()
	local isWidget = false
	local parentIsLayout = false
	if notWidgetType[class] == 1 then
		obj = tolua.cast(old,"CCNode")
		isWidget = false
	else
		obj = tolua.cast(old,"Widget")
		isWidget = true
	end
	if isWidget then
		local posType = LAYOUT_ABSOLUTE
		if notWidgetType[tolua.type(parent)]~= 1  and  parent:getWidgetType()== WidgetTypeContainer then
			parent = tolua.cast(parent,"Layout")
			if parent:getLayoutType()  == LAYOUT_RELATIVE then
				posType = LAYOUT_RELATIVE
			end
		end
		if posType == LAYOUT_RELATIVE then	
			--print ("LAYOUT_PARAMETER_RELATIVE Get")
			local layoutParam = tolua.cast(obj:getLayoutParameter(LAYOUT_PARAMETER_RELATIVE),"RelativeLayoutParameter")
			local margin = layoutParam:getMargin()
			pos.left = margin.left
			pos.right = margin.right
			pos.top = margin.top
			pos.bottom = margin.bottom
			pos.type = LAYOUT_RELATIVE
			pos.align = layoutParam:getAlign()
			pos.x = obj:getPositionX()
			pos.y = obj:getPositionY()
		else -- type == 0
			pos.type =LAYOUT_ABSOLUTE
		end
	else
		pos.type =LAYOUT_ABSOLUTE
	end
	pos.x = obj:getPositionX()
	pos.y = obj:getPositionY()
	return pos
end


function setPosition(new,pos,offset,noParent)
	if offset == nil then
		offset  ={x =0 ,y = 0}
	end
	local obj = nil
	local class = tolua.type(new)
	local parent = new:getParent()
	local isWidget = false
	if notWidgetType[class] then
		obj = tolua.cast(new,"CCNode")
		isWidget = false
	else
		obj = tolua.cast(new,"Widget")
		isWidget = true
	end

	if isWidget and pos.type  == LAYOUT_RELATIVE then
		local posType = LAYOUT_ABSOLUTE
		--print ("WidgetType",parent:getWidgetType())
		if notWidgetType[tolua.type(parent)]~= 1  and  parent:getWidgetType()== WidgetTypeContainer then
			parent = tolua.cast(parent,"Layout")
			if parent:getLayoutType()  == LAYOUT_RELATIVE then
				posType = LAYOUT_RELATIVE
			end
		end
		if posType == LAYOUT_RELATIVE then	
			--print ("LAYOUT_PARAMETER_RELATIVE Put")
			local left = 0	
			local right = 0
			local top = 0
			local bottom = 0

			left = pos.left+offset.x		
			right = pos.right+offset.x
			top = pos.top-offset.y
			bottom = pos.bottom-offset.y

			local layoutParam = tolua.cast(obj:getLayoutParameter(LAYOUT_PARAMETER_RELATIVE),"RelativeLayoutParameter")
			layoutParam:setAlign(pos.align)
			local margin = layoutParam:getMargin()
			margin.left = left
			margin.right = right
			margin.top = top
			margin.bottom = bottom
			if noParent ~= true then
			 	obj:getParent():updateSizeAndPosition()
			end
			return 
		end
	end
	--print ("LAYOUT_ABSOLUTE Put")
	local x = pos.x + offset.x
	local y = pos.y + offset.y
	--print ("#####################")
	obj:setPosition(CCPoint(x,y))
end

function bezier(obj,start,xend,time,func,controlPoint)
	if time == nil then
		time = 0.4
	end
	local x= xend.x -start.x
	local y = xend.y - start.y
  	local config = ccBezierConfig()
    config.endPosition = ccp(xend.x,xend.y)
    if y < 0 then
        y = 0
    end
    if type(controlPoint) == type({}) then
	    config.controlPoint_1 = ccp(start.x+controlPoint.x,start.y+controlPoint.y)
	    config.controlPoint_2 = ccp(xend.x+controlPoint.x,xend.y+controlPoint.y)
    else
	    config.controlPoint_1 = ccp(start.x,start.y+y+50)
	    config.controlPoint_2 = ccp(start.x+x,start.y+y+50)
	end
    local action = CCBezierTo:create(time,config)
	 local allBack = CCCallFunc:create(function()
	 	if func then
	    	func()
	    end
   	end)
		action = CCEaseInOut:create(action,1)  
   	action = CCSequence:createWithTwoActions(action,allBack)

    obj:setPosition(ccp(start.x,start.y))
    obj:runAction(action)
end
goldAnim = bezier

function loadAnim(name,pngNum)
	--for i=1,pngNum do
      --  CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Anim/"..name.."/"..name ..(i-1) ..".png","Anim/"..name .."/"..name ..(i-1)  ..".plist","Anim/"..name.."/"..name ..".ExportJson")
	--end
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Anim/"..name.."/"..name ..".ExportJson")

end

function unLoadAnim(animName,pngNum)
   if pngNum == nil then
      CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Anim/"..animName.."/"..animName..".ExportJson")
   else 
      local name = animName
      print("unloadAnimAsync "..name)
      local event = package.loaded["logic.event"]
      local path = "Anim/"..name.."/"..name ..".ExportJson"
      CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
      for i=0,pngNum-1 do
	 local file = "Anim/"..name.."/"..name..i..".png"
	 local plist = "Anim/"..name.."/"..name..i..".plist"
	 print(plist)
	 CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plist)
	 local fullpath =CCFileUtils:sharedFileUtils():fullPathForFilename(file)
	 
	 CCTextureCache:sharedTextureCache():removeTextureForKey(fullpath)
      end
   end
end

loadingAnim = 0
unloadQueue = {}
function loadAnimAsync(name,pngNum,callBack)
   print ("1###############################################")
   local this = {}
   local event = package.loaded["logic.event"]
   this.func = nil
   this.path = "Anim/"..name.."/"..name ..".ExportJson"
   this.loaded = false
   this.delete = false
   this.func = function()
      if this.delete == true then
	 	  unLoadAnimAsync(name,pngNum)
      else
		  callBack()
		  this.loaded = true
      end
      loadingAnim = loadingAnim - 1
      if loadingAnim == 0 then
      	 checkUnloadQueue()
      end
   end
   this.remove = function ()
      if this.loaded == true then
	 		unLoadAnimAsync(name,pngNum)
      else
	 		this.delete = true
      end
   end
   loadingAnim = loadingAnim + 1
   C_LoadAnimAsync(this.path,this.func)
   return this
  -- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync(path)
end
function checkUnloadQueue()
	for i,v in pairs(unloadQueue) do
		local name = v[1]
		local pngNum = v[2]
		print("unloadAnimAsync "..name)
		local event = package.loaded["logic.event"]
		local path = "Anim/"..name.."/"..name ..".ExportJson"
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
		for i=0,pngNum-1 do
			local file = "Anim/"..name.."/"..name..i..".png"
			local plist = "Anim/"..name.."/"..name..i..".plist"
			print(plist)
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plist)
			local fullpath =CCFileUtils:sharedFileUtils():fullPathForFilename(file)
			
			CCTextureCache:sharedTextureCache():removeTextureForKey(fullpath)
		end
	end
	unloadQueue = {}
end
function unLoadAnimAsync(name,pngNum)
   table.insert(unloadQueue,{name,pngNum})
   if loadingAnim == 0 then
   		checkUnloadQueue()
   end
end


function numEffectWithObj(obj,start,max,_type,px,callback)
   local this = {}
   --this.hash = {}
   this.splitArr = {}
   this.nowNum = start
   obj:stopAllActions()
   local ans = max-start
   local minusFlag = false
   if ans < 0 then
      minusFlag = true
      ans = -ans
   end
   -- while (ans > 0) do
   --    local a = math.ceil(ans/3)
   --    if minusFlag == true then
   --       table.insert(this.splitArr,-a)
   --    else
   --       table.insert(this.splitArr,a)
   --    end
   --    ans = ans - a
   -- end
   for i = 1, 10 do
      if minusFlag == true then
         table.insert(this.splitArr,-ans/10)
      else 
         table.insert(this.splitArr,ans/10)
      end
   end

   this.index = #this.splitArr
   
   this.getEveryNum = function(num)
      local arr = {}
      local i = 1
      if num == 0 then
         return {0}
      else
         while num ~= 0 do
            arr[i] = num % 10
            i = i + 1
            num = math.floor(num/10)
         end
         return arr
      end
   end
   
   this.nextNum = function(num,max)
      local sum = num + this.splitArr[this.index]
      local arr1 = this.getEveryNum(num)
      local arr2 = this.getEveryNum(sum)
      local flag = false
      if #arr1 ~= #arr2 then
         flag = true
      end
      this.index = this.index - 1
      print(sum)
      return sum,flag
   end
   
   this.numEffect = function(obj,num,max)
      if _type == 1 then
         obj:setText(num)
      elseif _type == 2 then
         obj:setStringValue(num)
      end
      AudioEngine.playEffect("system_07")
      this.nowNum = num
      createEffect(Effect.delay,{time=0.05},obj,
                   function()
                      if num == max then
                         if callback then
                            callback()
                         end
                         return
                      else
                         local flag = false
                         num,flag = this.nextNum(num,max)
                         if flag == true then
                            local pos = getPosition(obj)
                            createEffect(Effect.move,{time=0.05,x=pos.x+px,y=pos.y},obj,
                                         function()
                                            local pos1 = getPosition(obj)
                                            setPosition(obj,pos1,{x=-px,y=0})
                                            this.numEffect(obj,num,max)
                                         end,true
                            )
                         else
                            this.numEffect(obj,num,max) 
                         end
                      end
                   end,true,true
      )
   end

   this.numEffect(obj,start,max)

   return this
end

function setBackButtonAndEnter(back_btn,label,func,noMove)
	local font =  tolua.cast(label:getVirtualRenderer(),"CCLabelTTF")
	--label:setPosition(ccp(185,0))
	label:setColor(ccc3(0xee,0xee,0xee))
	-- font:enableStroke(ccc3(0x46,0x26,0x0e),3)
	back_btn:setAnchorPoint(ccp(0,0.5))
	if noMove ~=true then
		local pos = getPosition(back_btn)
		if pos.top <= 10 then
			pos.top = 4
		end
		if pos.top >= 40 then
			pos.top = 4+41
		end
		setPosition(back_btn,pos)
	end
	createEffect(Effect.delay,{time=0.25},label,function()
		createEnterEffect(label,{x=0,y=5},0.2,nil,false,EnterAddEffect.shake)
	end,true)
   	createEnterEffect(back_btn,{x=0,y=-200},0.3,function ()
   		--back_btn:updateSizeAndPosition()
   		if func then
   			func()
   		end
   	end,false,EnterAddEffect.drop)
end

function setBtnListAnimation(btnList,isShowBottom)
	local enterI = 0
	if #btnList == 0 then
		return 
	end
	local pos = btnList[1].pos
	for i,v in pairs(btnList) do
		if v.pos then
			pos = v.pos
			break
		end
	end
	for i,v in pairs(btnList) do
		if v.obj and v.pos then
			setPosition(v.obj,pos)
			createEnterEffect(v.obj,{x=-640,y=0,easeIn=true},0.3,function()
				setPosition(v.obj,v.pos)
				createEnterEffect(v.obj,{x=0,y=-v.pos.y+pos.y,easeIn=true},0.15,function ()
					local o = v.btn_name
					if o == nil then
						o = v.Image
					end
					if o then
					createEffect(Effect.shake,{time=0.1,roate=5},o)
				end
				end,EnterAddEffect.drop)
			end)
		end
	end
	if isShowBottom then
		local main = package.loaded['scene.main']
		main.showBottomPanel()
	end
end


function setTextAli(str)
	local t={}
	local lenInByte = #str
	local width = 0
	 local i = 1
	while i<=lenInByte do
	    local curByte = string.byte(str, i)
	    local byteCount = 1
	     if curByte>0 and curByte<=127 then
	        byteCount = 1
	    elseif curByte>=192 and curByte<223 then
	        byteCount = 2
	    elseif curByte>=224 and curByte<239 then
	        byteCount = 3
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
	    end
	    local char = string.sub(str, i, i+byteCount-1)
	  	table.insert(t,char)
	  	print (i,char,curByte,byteCount)
	  	i = i + byteCount 
	end
	return table.concat(t,"\n")
end

function refreshJtEffect(jtEffect,current,total)
   if current == nil then
      if jtEffect.left.isPlaying == true then
	 jtEffect.left.isPlaying = nil
	 jtEffect.left.img1.obj:stopAllActions()
	 jtEffect.left.img2.obj:stopAllActions()
      end
      if jtEffect.right.isPlaying == true then
	 jtEffect.right.isPlaying = nil
	 jtEffect.right.img1.obj:stopAllActions()
	 jtEffect.right.img2.obj:stopAllActions()
      end
      return
   end
   local func = nil
   func = function(layout) 
      if layout.isPlaying == nil then
	 layout.isPlaying = true
	 local effectFunc = nil
	 effectFunc = function()
	    layout.img1.light.obj:setVisible(true)
	    createEffect(Effect.delay,{time=0.3},layout.img1.obj,
			 function()
			    layout.img1.light.obj:setVisible(false)
			    layout.img2.light.obj:setVisible(true)
			    createEffect(Effect.delay,{time=0.3},layout.img2.obj,
					 function()
					    layout.img2.light.obj:setVisible(false)
					    effectFunc()
					 end
			    )
			 end
	    )
	 end
	 effectFunc()
      end
   end
   if current == 1 and total == 1 then
      jtEffect.obj:setVisible(false)
   else 
      jtEffect.obj:setVisible(true)
      jtEffect.left.obj:setVisible(false)
      jtEffect.right.obj:setVisible(false)
      if current < total then
	 jtEffect.right.obj:setVisible(true)
	 func(jtEffect.right)
      end
      if current > 1 then
	 jtEffect.left.obj:setVisible(true)
	 func(jtEffect.left)
      end
   end
end

function objLoop(obj,diffTime,call)
	local func = nil
	func = function ()
		if call() then
			createEffect(Effect.delay,{time=diffTime},obj,func,true)
		end
	end
	func()
end

RemoteImageList = {}
RemotePhotoList = {}
schedule(function ()
	if #RemoteImageList >0 then
		call("getImageFileList",RemoteImageList)
		RemoteImageList = {}
	end
	if #RemotePhotoList >0 then
		call("getPhotoFileList",RemotePhotoList)
		RemotePhotoList = {}
	end
end,1/30)
function getUserImage(eventHash,obj,charId,loadendFunc)
	local userdata =package.loaded['logic.userdata']
	getImageFile("role/man_head.png","role/girl_head.png",RemoteImageList,"getImageFileList",userdata.CharIdToImageFile,eventHash,charId,obj,loadendFunc)
end
function getImageFile(defaltMan,defaultGril,list,eventPer,cache,eventHash,charId,obj,loadendFunc)
	local event = package.loaded['logic.event']	
	local eventName = eventPer..charId
	local load = function (body)
		if  body.file == "" then
			print("unfind!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			if body.sex == 1 then
				obj:loadTexture(defaltMan)
			else
				obj:loadTexture(defaultGril)
			end
			if loadendFunc then
				loadendFunc()
			end
		elseif fileManager.hash[body.file] == true then
			print("find!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			if obj then
				obj:loadTexture(fileManager.path..body.file)
				if loadendFunc then
					loadendFunc()
				end
			end
		else
			print ("body!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",body.file)
			-- printTable(eventHash)
			eventHash[body.file] = true
			event.listen(body.file,
			   function()
			   	  event.unListen(body.file)
			      eventHash[body.file] = nil
				  if obj then
					 obj:loadTexture(fileManager.path..body.file)
				  end
					if loadendFunc then
						loadendFunc()
					end
			   end
			)
			fileManager.download(downloadURL,splitString(body.file,"")[1],0,0)
		end
	end
	local body = cache[charId]
	if body ~= nil then
		load(body)
		return 
	end
	print("nil!@!~!@@@@@@@@@@@@@@@@@@@@@@@@@@@###")
end
function loadRemoteImage(eventHash,obj,charId,loadendFunc)
	local userdata =package.loaded['logic.userdata']
	loadRemoteFile("role/man_head.png","role/girl_head.png",RemoteImageList,"getImageFileList",userdata.CharIdToImageFile,eventHash,charId,obj,loadendFunc)
end
function loadRemotePhoto(eventHash,obj,charId,loadendFunc)
	local userdata =package.loaded['logic.userdata']
	loadRemoteFile("role/man.png","role/girl.png",RemotePhotoList,"getPhotoFileList",userdata.CharIdToPhotoFile,eventHash,charId,obj,loadendFunc)
end
function loadRemoteFile(defaltMan,defaultGril,list,eventPer,cache,eventHash,charId,obj,loadendFunc)
	local event = package.loaded['logic.event']	
	local eventName = eventPer..charId
	local load = function (body)
		if  body.file == "" then
			if body.sex == 1 then
				obj:loadTexture(defaltMan)
			else
				obj:loadTexture(defaultGril)
			end
			if loadendFunc then
				loadendFunc()
			end
		elseif fileManager.hash[body.file] == true then
			if obj then
				obj:loadTexture(fileManager.path.."/"..body.file)
				if loadendFunc then
					loadendFunc()
				end
			end
		else
			print (body.file)
			eventHash[body.file] = true
			event.listen(body.file,
			   function()
			   	  event.unListen(body.file)
			      eventHash[body.file] = nil
				  if obj then
					 obj:loadTexture(fileManager.path.."/"..body.file)
				  end
					if loadendFunc then
						loadendFunc()
					end
			   end
			)
			fileManager.download(downloadURL,splitString(body.file,"")[1],0,0)
		end
	end
	local body = cache[charId]
	if body ~= nil then
		load(body)
		return 
	end
	eventHash[eventName] = true
    event.listen(eventName,function()
    	--print ("unEvent...")
    	event.unListen(eventName)
    	eventHash[eventName] = nil
		load(cache[charId])
     end)
    table.insert(list,tonumber(charId))
end

function playTextEffect(path,num,obj,offset,_scale,_callback)
   if offset == nil then offset = 0 end
   if _scale == nil then _scale = 1 end
   local objSize = obj:getSize()
   local y = objSize.height/2
   local dis = 90*_scale
   local star = "dispel/flash01.png"
   local start = objSize.width/2 + offset
   local fadeInTime = 0.5
   local delay = 2
   local delayDiff = 0.1
   local fadeOutTime = 0.3
   local fadeOutTimeDiff = 0.15
   local moveMax = 200*_scale
   local moveDiff = 40*_scale
   local bottomMove = 10
   local start2 = objSize.width/2 + offset
   local dis2 = 150*_scale
   local parent = obj
   start = start - dis*(num/2 +0.5)
   start2 = start2 - dis2*(num/2 +0.5)
   AudioEngine.playEffect("system_57")
   --AudioEngine.stopMusic()
   for i=1,num do
      local x= start +dis*i
      local x2 = start2 + dis2*i
      local image2 = tolua.cast(ImageView:create(),"ImageView")
      image2:loadTexture(path..i..".png")
     
      parent:addChild(image2,10001)
      image2:setPosition(ccp(x2,y))
      image2:setOpacity(200)
      image2:setScale(math.abs(num/2-i)*_scale+_scale)
      createEffect(Effect.move,{x=x,y=y,time=fadeInTime},image2)
      createEffect(Effect.fadeTo,{opacity=25, time=fadeInTime,easeIn=true},image2,nil,true)
      createEffect(Effect.scale,{scale=_scale,time=fadeInTime},image2,
			function ()
			   image2:removeFromParentAndCleanup(true)
			end,true)
    
      local image = tolua.cast(ImageView:create(),"ImageView")
      image:loadTexture(path..i..".png")
      parent:addChild(image,10000)
      image:setScale(_scale)
      image:setPosition(ccp(x,y))
      image:setOpacity(0)
      local starNum = math.random(5,10)   
      performWithDelay(
      	 function ()
      	    for ii =1,starNum do
      	       performWithDelay(
      		  function ()
      		  	 if parent ~= nil or parent:getParent() ~= nil then return end
                 local imageStar = tolua.cast(ImageView:create(),"ImageView")
                 imageStar:loadTexture(star)
      		     imageStar:setScale(math.random(1,20)/40)
      		     imageStar:setRotation(math.random(0,360))
      		     parent:addChild(imageStar,10005)
      		     local sx,sy = x+math.random(-100,100),y+math.random(-100,20)
      		     imageStar:setPosition(ccp(sx,sy))

      		     createEffect(Effect.move,{time=delay/2,x=sx,y=sy+math.random(25,100)},imageStar,
      				       function()
      					  imageStar:removeFromParentAndCleanup(true)
      				       end
      		     )
      		  end,math.random(1,1000)/1000)
      	    end
      	 end,0.1*i)
   
      createEffect(Effect.fadeTo,{opacity=255, time=fadeInTime,easeIn=true},image,
			function ()			      
               createEffect(Effect.delay,{time=delay+delayDiff*math.abs(num/2-i)},image,
                                 function()
                                    for j=1,5 do
                                       local imageClone = tolua.cast(ImageView:create(),"ImageView")
                                       imageClone:loadTexture(path..i..".png")
                                       parent:addChild(imageClone,10000-j)
                                       imageClone:setScale(_scale)
                                       imageClone:setPosition(ccp(x,y))
                                       imageClone:setOpacity(180-j*30)
                                       createEffect(Effect.move,{time=fadeOutTime+j*fadeOutTimeDiff,x=x,y=y+moveMax-moveDiff*math.abs(num/2-i),easeOut=true},imageClone)
                                       createEffect(Effect.fadeTo,{opacity=0, time=fadeOutTime+j*fadeOutTimeDiff,easeIn=true},imageClone,
                                                         function ()
                                                            imageClone:removeFromParentAndCleanup(true)
                                                         end,true)
                                    end
                                    createEffect(Effect.move,{time=fadeOutTime,x=x,y=y+moveMax-moveDiff*math.abs(num/2-i)},image)
                                    createEffect(Effect.fadeOut,{time=fadeOutTime,easeIn=true},image,
                                                      function ()
                                                         image:removeFromParentAndCleanup(true)
                                                      end,true)
                                 end
			   )
			end
      )
   end
   createEffect(Effect.delay,{time=fadeInTime+delay+fadeOutTime+delayDiff*num/2},obj,_callback,true)
end

function spliteText(str)
    local tb = {}
    i = 1
    while i < #str  do
       c = str:sub(i,i)
       ord = c:byte()
       if ord > 128 then
          table.insert(tb,str:sub(i,i+2))
          i = i+3
       else
          table.insert(tb,c)
          i=i+1
       end
    end
    return tb
end

-- imgLv - Lv图片；lv - Lv标签字；value - 等级
function setAtlasLvPos(imgLv, lv, value)
	local old = lv:getSize().width
	lv:setStringValue(value)
	local new = lv:getSize().width
	local dis = -(new-old)/3
	imgLv:setPosition(ccp(imgLv:getPositionX()+dis,imgLv:getPositionY()))
	lv:setPosition(ccp(lv:getPositionX()+dis,lv:getPositionY()))
end

function checkCardDays(t, _days)
	if t == nil or t == 0 then
		return false
	end
	local startTime = getSyncedTime()
	local diff = math.abs(startTime-t)
	local day = 0
	if diff >= 86400 then
		day = math.floor(diff/86400)
	end
	print("card day", day)
	if day > _days then
		return false
	end

	return true
end

function checkCanGetCard(t)
	if t == nil then
		return false
	end
	if t == 0 then
		return true
	end

	local date1 = os.date("*t",t)
	local date2 = os.date("*t",getSyncedTime())
	print("date1.month, date2.month",date1.month, date2.month)
	print("date1.day, date2.day",date1.day, date2.day)
	if date1.month == date2.month then
		if date1.day ~= date2.day then
			return true
		end
	end

	return false
end

function convertHexToRGB(hex)  
   local red = string.sub(hex, 3, 4)  
   local green = string.sub(hex, 5, 6)  
   local blue = string.sub(hex, 7, 8)  
   red = tonumber(red, 16) 
   green = tonumber(green, 16)
   blue = tonumber(blue, 16)  
   return red, green, blue  
end 

function getRichTextWithColor(str,fontSize)
   local layout = Layout:create()
   local richText = RichText:create()

   local totalWidth = 0
   local height = 0
   local args = {}
   local pattern = '((0x)(%x%x%x%x%x%x))'
   local last_end = 1
   local s,e,cap = string.find(str,pattern, 1)
   if s == nil then
      table.insert(args,{text=str,isColor=false})
   elseif s > 1 then
      table.insert(args,{text=string.sub(str,1,s-1),isColor=false})
   end

   while s do
      if s ~= 1 or cap ~= '' then         
         table.insert(args,{text=cap,isColor=true})
      end
      last_end = e + 1
      s,e,cap = string.find(str,pattern,last_end)
      if s == nil then
         table.insert(args,{text=string.sub(str,last_end),isColor=false})
      elseif s > last_end then
         table.insert(args,{text=string.sub(str,last_end,s-1),isColor=false})
      end
   end
 
   for i = 1, #args do
      if args[i].isColor == false then 
         local _msg = nil
         if args[i-1] ~= nil and args[i-1].isColor == true then
            _msg = RichElementText:create(i,ccc3(convertHexToRGB(args[i-1].text)),255,args[i].text,DEFAULT_FONT,fontSize)             
         else 
            _msg = RichElementText:create(i,ccc3(255,255,255),255,args[i].text,DEFAULT_FONT,fontSize)
         end
         richText:pushBackElement(_msg)

         local msg = Label:create()
         msg:setText(args[i].text)
         msg:setFontSize(fontSize)
         msg:setFontName(DEFAULT_FONT)
         
         totalWidth = totalWidth + msg:getContentSize().width
         height = msg:getContentSize().height
      end
   end

   richText:ignoreContentAdaptWithSize(false)
   richText:setSize(CCSize(totalWidth,height))
   richText:setAnchorPoint(ccp(0,0))
   richText:setPosition(ccp(0,0))
   layout:setSize(CCSize(totalWidth,height))
   layout:addChild(richText)

   return layout
end
