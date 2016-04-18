local tool = require"scene.tool"
local event = require"logic.event"
module("widget.coverFlow",package.seeall)

function create(parent,parentModule,centerX,centerY,offsetWidth,cnt,pageDisabled)
   local this = {}
   this.listCnt = 0
   this.list = {}
   this.middleIndex = 0
   this.itemWidth = 0
   this.renderFunc = nil
   this.delayIndex = nil
   this.pageHash = {}
   this.startPos = {}
   this.lastDirection = 0

   this.pushItem = function(item)
      table.insert(this.list,item)
      this.listCnt = this.listCnt + 1
      item.coverFlowIndex = this.listCnt    
      if this.listCnt <= cnt then
	 this.middleIndex = math.ceil((this.listCnt + 1) / 2)
	 this.addRender(this.listCnt)
	 this.itemWidth = item.obj:getSize().width
      end
      this.resetAllChildPosition(true)
   end

   this.resetAllChildPosition = function(isEffect)
      local nearNums = math.ceil((cnt-1)/2)
      for i = this.middleIndex-nearNums,this.middleIndex+nearNums do
	 local scale = 0
	 local fx = 0
	 local fz = 0
	 local skewY = 0
	 local j = i
	 if pageDisabled == true then
	    if i < 1 and this.middleIndex + nearNums < this.listCnt + i then
	       j = this.listCnt + i 
	    elseif i > this.listCnt and i - this.listCnt < this.middleIndex - nearNums  then
	       j = i - this.listCnt
	    end
	 end
	 if this.list[j] and this.list[j].obj then
	    if i <= this.middleIndex-2 or i >= this.middleIndex+2 then
	       scale = 0.5
	       fz = this.middleIndex - 2
	       if i <= this.middleIndex - 2 then
		  skewY = -5
	       else
		  skewY = 5
	       end
	    elseif i <= this.middleIndex-1 or i >= this.middleIndex+1 then
	       scale = 0.85
	       fz = this.middleIndex - 1
	       if i <= this.middleIndex - 1 then
		  skewY = -5
	       else
		  skewY = 5
	       end
	    else
	       scale = 1
	       fz = this.middleIndex
	       skewY = 0
	    end
	    fx = centerX + (i-this.middleIndex)*offsetWidth

	    if isEffect then
	       this.list[j].obj:stopAllActions()
	       this.list[j].obj:setZOrder(fz)
	       this.list[j].obj:setTouchEnabled(false)
	       local func
	       func = function(time)
		  this.list[j].obj:setVisible(true)
		  local lastX = this.list[j].obj:getPositionX()
		  local diffx = 0
		  if lastX > fx then
		     diffx = 40
		  elseif lastX < fx then
		     diffx = -40
		  end
		  --tool.createEffect(tool.Effect.SkewTo,{time=time,x=0,y=skewY},this.list[j].obj,nil,true)
		  tool.createEffect(tool.Effect.move,{time=time,x=fx+diffx,y=centerY},this.list[j].obj,
				    function()
				       this.list[j].obj:setTouchEnabled(true)
				       if diffx ~= 0 then
					  tool.createEffect(tool.Effect.move,{time=time,x=fx,y=centerY},this.list[j].obj,nil,true)
				       end
				    end,true
		  )
		  local lastScale = this.list[j].obj:getScaleX()
		  local diffs = 0
		  if lastScale > scale then
		     -- diffs = 0.05
		  elseif lastScale < scale then
		     -- diffs = -0.05
		  end
		  tool.createEffect(tool.Effect.scale,{time=time,scale=scale+diffs},this.list[j].obj,
				    function()
				       if diffs ~= 0 then
					  tool.createEffect(tool.Effect.scale,{time=0.1,scale=scale},this.list[j].obj,nil,true)
				       end
				    end
				    ,true)
	       end
	       if this.delayIndex == j then
		  tool.createEffect(tool.Effect.delay,{time = 0.3},this.list[j].obj,function() func(0.1) end,true)
	       else
		  func(0.3)
	       end
	    else
	       this.list[j].obj:setVisible(true)
	       this.list[j].obj:setScale(scale)
	       this.list[j].obj:setPosition(ccp(fx,centerY))
	       this.list[j].obj:setZOrder(fz)	
	    end
	 end
      end      
   end
   
   this.click = function(data)
      if data.coverFlowIndex == this.middleIndex then
	 event.pushEvent("COVER_FLOW_CLICK"..data.obj.eventId)
      elseif data.coverFlowIndex == this.middleIndex+1 then
	 if data.obj.page ~= nil then
	    if this.pageHash[data.obj.page+1] == nil then
	       this.pageHash[data.obj.page+1] = true
	       if parentModule and parentModule.nextPage then
		  parentModule.nextPage(data.obj.page+1)
	       end
	    end
	 end
	 this.next()
      elseif data.coverFlowIndex == this.middleIndex-1 then
	 this.previous()
      elseif pageDisabled == true then
	 if data.coverFlowIndex > this.middleIndex then
	    this.previous()
	 else
	    this.next()
	 end
      end
   end
   this.addRender = function(index,isDelay)
      --print("addRender",index)
      local data = this.list[index]
      this.renderFunc(data)
      data.obj:setVisible(false)
      data.obj:setPosition(ccp(centerX,centerY))
      if isDelay == true then
	 this.delayIndex = index
      else
	 this.delayIndex = nil
      end
      data.obj:setZOrder(0)
      data.obj:setScale(0.5)
      parent:addChild(data.obj)
      event.pushEvent("COVER_FLOW_ADDED"..data.obj.eventId)
      data.obj:setTouchEnabled(true)
      data.obj:registerEventScript(function(event1,data1)
				      onTouched(event1,data1,data)
				      -- if event1 == "pushDown" then
				      -- 	 onTouched(event1,data1,data)
				      -- elseif event1 == "releaseUp" or event1 == "cancelUp" then
				      -- 	 if event1 == "releaseUp" then
				      -- 	    this.click(data)
				      -- 	 else
				      -- 	    onTouched(event1,data1,data)
				      -- 	 end
				      -- elseif event1 == "move" then
				      -- 	 onTouched(event1,data1,data)
				      -- end
				   end
      )
   end

   this.next = function()
      this.lastDirection = 0
      if this.isAutoSwitch == true then
	 parent:stopAllActions()
	 this.autoSwitch()
      end
      local nearNums = math.ceil((cnt-1)/2)
      local removeIndex = this.middleIndex - nearNums
      local addIndex = this.middleIndex + nearNums + 1 
      if pageDisabled == true then
	 addIndex = addIndex > this.listCnt and addIndex - this.listCnt or addIndex
	 removeIndex = removeIndex < 1 and this.listCnt + removeIndex or removeIndex
      end
      if removeIndex >= 1 and removeIndex ~= addIndex then
	 this.list[removeIndex].obj:setZOrder(0)
	 tool.createEffect(tool.Effect.move,{time=0.3,x=centerX,y=centerY},this.list[removeIndex].obj,
			   function()
			      this.list[removeIndex].obj:stopAllActions()
			      this.list[removeIndex].obj:removeFromParentAndCleanup(true)
			      this.list[removeIndex].obj = nil
			   end
	 )
      end
      this.middleIndex = this.middleIndex + 1
      if pageDisabled == true then
	 this.middleIndex = this.middleIndex > this.listCnt and this.middleIndex - this.listCnt or this.middleIndex
      end
      if addIndex <= this.listCnt and removeIndex ~= addIndex then
	 this.addRender(addIndex,true)
      else 
	 this.delayIndex = nil
      end
      this.resetAllChildPosition(true)
   end

   this.previous = function()
      this.lastDirection = 1
      if this.isAutoSwitch == true then
	 parent:stopAllActions()
	 this.autoSwitch()
      end
      local nearNums = math.ceil((cnt-1)/2)
      local removeIndex = this.middleIndex + nearNums
      local addIndex = this.middleIndex - nearNums - 1
      if pageDisabled == true then
	 addIndex = addIndex < 1 and addIndex + this.listCnt or addIndex
	 removeIndex = removeIndex > this.listCnt and removeIndex - this.listCnt or removeIndex
      end
      if removeIndex <= this.listCnt and removeIndex ~= addIndex then
	 this.list[removeIndex].obj:setZOrder(0)
	 tool.createEffect(tool.Effect.move,{time=0.3,x=centerX,y=centerY},this.list[removeIndex].obj,
			   function()
			      this.list[removeIndex].obj:stopAllActions()
			      this.list[removeIndex].obj:removeFromParentAndCleanup(true)
			      this.list[removeIndex].obj = nil
			   end
	 )
      end
      this.middleIndex = this.middleIndex - 1
      if pageDisabled == true then
	 this.middleIndex = this.middleIndex < 1 and this.middleIndex + this.listCnt or this.middleIndex
      end
      if addIndex >= 1 and removeIndex ~= addIndex then
	 this.addRender(addIndex,true)
      else
	 this.delayIndex = nil
      end
      this.resetAllChildPosition(true)
   end
   
   this.autoSwitch = function()
      local func = nil
      this.isAutoSwitch = true
      func = function()
	 tool.createEffect(tool.Effect.delay,{time=5},parent,
			   function()
			      if this.lastDirection == 0 then
				 this.next()
			      else
				 this.previous()
			      end
			      func()
			   end
	 )
      end
      func()
   end

   this.clear = function()
      parent:stopAllActions()
      for k, v in pairs(this.list) do
	 if v.obj then
	    v.obj:stopAllActions()
	    v.obj:removeFromParentAndCleanup(true)
	    v.obj = nil   
	 end
      end
      this.list = nil
      this.renderFunc = nil
      this.pageHash = nil
      this.isAutoSwitch = nil
   end
   
   function onTouched(event,data,item)
      local pos = data:getLocation()
      if event == "pushDown" then
	 this.startPos.x = pos.x
	 this.startPos.time = C_CLOCK()
	 this.startPos.direction = 0
      elseif event == "move" then
	 local diffx = pos.x - this.startPos.x 
	 local diffTime = C_CLOCK() - this.startPos.time
	 if diffx > 30 then
	    this.startPos.direction = 1
	 elseif diffx < -30  then
	    this.startPos.direction = 2
	 end
	 this.startPos.x = pos.x
      elseif event == "releaseUp" or event == "cancelUp" then
	 if this.startPos.direction == 0 and event == "releaseUp" then
	    this.click(item)
	 elseif this.startPos.direction == 1 then
	    this.previous()
	 elseif this.startPos.direction == 2 then
	    this.next()
	 end
      end
   end
   parent:registerEventScript(onTouched)
  
   return this
end
