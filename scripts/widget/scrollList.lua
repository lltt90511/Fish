local tool = require"logic.tool"
module("widget.scrollList", package.seeall)

function create(scorll,scrollBar,scorllBarbg,itemHeight,startX,offsetHeight,barType,column,parentModule,blankHeight,scrollHeight,topHeight)
   local this = {}
   local scollBarY = scorllBarbg:getSize().height -scrollBar:getSize().height
   local size = scorll:getSize()
   -- scorll:setClippingType(LAYOUT_CLIPPING_SCISSOR)
   --scorllBarbg:getSize().height
   if type(offsetHeight) == type(0) then
   		 scorll:setSize(CCSize(size.width,size.height +offsetHeight))
   elseif type(offsetHeight) == type(true) and offsetHeight == true then
      scorll:setSize(CCSize(size.width,size.height))
   end
   if blankHeight == nil then
      blankHeight = 0
   end
   if column == nil then
      column = 1
   end
   
   if scrollHeight == nil then
	  scrollHeight = 0
   end

   if topHeight == nil then
   	topHeight = 0
   end

   scorllBarbg:setSize(CCSize(scorllBarbg:getSize().width,scorll:getSize().height - scrollHeight))
   scorllBarbg:setVisible(false)
   this.isScorllBarBgVisible = false
   this.List = {}
   this.ListCnt = 0
   this.fy = 0
   this.obj = scorll
   this.timer = nil
   this.lastHeight = blankHeight +topHeight
   topHeight = -topHeight
   this.height = 0
   this.isOutDisplayEnabled = false
   this.pageEnabled = false
   this.totalPage = 0
   --scorll:setBounceEnabled(true)
   --scorll:setInertiaScrollEnabled(true)
   this.setItemHeight = function(_itemHeight)
      itemHeight = _itemHeight
   end
   this.pushItemToTopWithCreateEffect  = function (itemObj,time1,time2,time3,callback)
		local innerSize = scorll:getInnerContainerSize()
		local height = innerSize.height
		local _lastHeight = height - itemHeight 
		local cnt = 2
      local flag = false
		for i,v in pairs(this.List) do
			local itemWidth = v:getSize().width
			local scaleX = v:getScaleX()
			local anchorPoint = v:getAnchorPoint()
			itemWidth = itemWidth * scaleX
			--print(itemWidth)
			local px = (size.width-column*itemWidth)/(column+1)
			local x,y 
			if column == 1 then
			   x = startX 
			   y = height - (cnt-0.5)*itemHeight+topHeight
			else
			   local pxNum = cnt % column == 0 and column or cnt % column
			   x = startX+pxNum*px+(pxNum-1)*itemWidth
			   y = height-(math.ceil(cnt/column)-anchorPoint.y)*itemHeight+topHeight
			end
			cnt = cnt + 1
			local pos = tool.getPosition(v)
			tool.createEffect(tool.Effect.move,{x=x,y=y,time=time1},v)
         flag = true
		end
		local func = function ()
			local oldList = {}
			for i,v in pairs(this.List) do
				v:stopAllActions()
				table.insert(oldList,v)
			end
         if #oldList > 0 then
   			this.pushItem(oldList[#oldList])
         else
            this.pushItem(itemObj)
         end
			for i=1,#oldList do
				this.List[i+1] = oldList[i]
			end
			this.List[1] = itemObj
			this.resetAllChildPostion()
			--itemObj:setOpacity(0)
			--itemObj:setScale(0)
			local pos = tool.getPosition(itemObj)
			tool.setPosition(itemObj,pos,{x=640,y=0})
			tool.createEffect(tool.Effect.move,{x=pos.x,y=pos.y,time=time2},itemObj,function ()
				tool.createEffect(tool.Effect.shake,{scale=1,roate=5,time=time3},itemObj,function ()
					if callback then
						callback()
					end
				end)
			end)
		end
      if flag then
         performWithDelay(func,0.21)
      else
         func()
      end
   end
   -- 插入至index(1~MAX)指定行
   this.pushItemAtIndex = function (itemObj,index)
      -- 老的index位置对象
      local oldItem = this.List[index]
      local oldItemPos = tool.getPosition(oldItem)
      -- oldItem之后的所有对象位置下移
      local oldList = {}
      for i,v in pairs(this.List) do
         v:stopAllActions()
         table.insert(oldList,v)
      end
      -- 设置新的对象至oldItem位置
      this.pushItem(itemObj)
      for i=index,#oldList do
         this.List[i+1] = oldList[i]
      end
      this.List[index] = itemObj
      this.resetAllChildPostion()
   end
   this.pushItem = function (itemObj,flag)
      --local height = 0
      if barType == "chat" then
         if itemObj.chat_lbl:isVisible() == true then
            if itemObj.head_ico:isVisible() == true then
               if itemObj.chat_lbl:getContentSize().height > itemObj.head_ico:getSize().height then
                  this.lastHeight = this.lastHeight + itemObj.chat_lbl:getContentSize().height + 8
               else
                  this.lastHeight = this.lastHeight + itemObj.head_ico:getSize().height + 8
               end
            else 
               if itemObj.chat_lbl:getContentSize().height > itemObj.name_lbl:getContentSize().height then
                  this.lastHeight = this.lastHeight + itemObj.chat_lbl:getContentSize().height + 8
               else
                  this.lastHeight = this.lastHeight + itemObj.name_lbl:getContentSize().height + 8
               end
            end
         else 
            this.lastHeight = this.lastHeight + 70
         end
         this.height = this.lastHeight
      elseif barType == "privateChat" or barType == "topChat" or barType == "lampChat" then
		 local chat_bg = tool.findChild(itemObj,"chat_bg","ImageView")
		 this.lastHeight = this.lastHeight + chat_bg:getSize().height + 30
		 this.height = this.lastHeight + 12
      elseif barType == "club" then
       if column == 1 or (this.ListCnt+1)%column == 1 then
          --height = ( this.ListCnt + 1 ) *  itemHeight
          this.lastHeight = this.lastHeight + itemHeight
       end
       if this.lastHeight >= size.height - blankHeight then
          this.height = this.lastHeight + blankHeight
       else
          this.height  = this.lastHeight 
       end
      else
		 if column == 1 or (this.ListCnt+1)%column == 1 then
		    --height = ( this.ListCnt + 1 ) *  itemHeight
		    this.lastHeight = this.lastHeight + itemHeight
		 end
		 if this.lastHeight >= size.height  then
		    this.height = this.lastHeight + 30
		 else
		    this.height  = this.lastHeight 
		 end
      end
      
      if this.height > size.height then 
		 local barSize = scrollBar:getSize()
		 local barbgSize = scorllBarbg:getSize()
		 local newBarHeight = barbgSize.height*(size.height/this.height) > 50 and barbgSize.height*(size.height/this.height) or 50
		 scrollBar:setSize(CCSize(barSize.width, newBarHeight))
		 scollBarY = scorllBarbg:getSize().height -scrollBar:getSize().height
		 this.isScorllBarBgVisible = true
      else
		 this.isScorllBarBgVisible = false
      end
      
      if this.pageEnabled == true then
         if itemObj.page ~= nil then
            if this.totalPage < itemObj.page then
               this.totalPage = itemObj.page
            end
         end
      end
      if itemObj:getParent() == nil then
         scorll:addChild(itemObj)
	  end
      this.ListCnt = this.ListCnt + 1
      itemObj.item_index = table.maxn(this.List)+1
      this.List[itemObj.item_index] = itemObj
      --print(itemObj.item_index)
      if flag == nil then
         --print ("!!!!!!!!!!!!!!!!!!!")
         local innerSize = scorll:getInnerContainerSize()
         scorll:setInnerContainerSize(CCSize(innerSize.width,this.height))
         if sizeChangeFunc then
            sizeChangeFunc()
         end
         -- print ("#####################",this.height,size.height)
         this.resetAllChildPostion(flag)
      end
   end

   this.resetAllChildPostion = function (flag)
      --print(debug.traceback())
      local innerSize = scorll:getInnerContainerSize()
      if flag ~= nil then
         --print("@@@@@@@@@@@@@@@reset inner size@@@@@@@@@@@@")
         scorll:setInnerContainerSize(CCSize(innerSize.width,this.height))
         if sizeChangeFunc then
            sizeChangeFunc()
         end
      end
      if this.isScorllBarBgVisible == true then
         scorllBarbg:setVisible(true)
         scorllBarbg:setOpacity(1)
      end
      local height = innerSize.height
      local _lastHeight = height - itemHeight 
      local cnt = 1
      for i = 1,table.maxn(this.List),1 do
         local v = this.List[i]
         if v then
            if barType == "chat" then
               v:setPosition(CCPoint(startX,_lastHeight+topHeight))
               local _realHeight = 0
               if v.chat_lbl:isVisible() == true then
                  if v.head_ico:isVisible() == true then
                     if v.chat_lbl:getContentSize().height > v.head_ico:getSize().height then
                        _realHeight = v.chat_lbl:getContentSize().height + 8
                     else
                        _realHeight = v.head_ico:getSize().height + 8
                     end
                  else 
                     if v.chat_lbl:getContentSize().height > v.name_lbl:getContentSize().height then
                        _realHeight = v.chat_lbl:getContentSize().height + 8
                     else
                        _realHeight = v.name_lbl:getContentSize().height + 8
                     end
                  end
               else 
                  _realHeight = 70
               end
               _lastHeight = _lastHeight -  _realHeight
            elseif barType == "privateChat" or barType == "topChat" or barType == "lampChat" then
               local chat_bg = tool.findChild(v,"chat_bg","ImageView")
               if v.isMe == true then
                  v:setPosition(ccp(626-141,_lastHeight-12+topHeight))
               else
                  v:setPosition(ccp(14,_lastHeight-12+topHeight))
               end
               local _realHeight = chat_bg:getSize().height+30
               _lastHeight = _lastHeight - _realHeight
            else
               local itemWidth = v:getSize().width
               local scaleX = v:getScaleX()
               local anchorPoint = v:getAnchorPoint()
               itemWidth = itemWidth * scaleX
               --print(itemWidth)
               local px = (size.width-column*itemWidth)/(column+1)
               if column == 1 then
                  v:setPosition(CCPoint(startX,height - (cnt-0.5)*itemHeight+topHeight))
               else
                  local pxNum = cnt % column == 0 and column or cnt % column
                  v:setPosition(CCPoint(startX+pxNum*px+(pxNum-1)*itemWidth,height-(math.ceil(cnt/column)-anchorPoint.y)*itemHeight+topHeight))
               end
               cnt = cnt + 1
            end
         end
      end
      this.onScroll("onScrollFalse", scorll)
   end
   this.removeItem= function (itemObj)
      --local height = 0
      --printTable(itemObj)
      --print(itemObj.item_index)
      if barType == "chat" then
         if itemObj.chat_lbl:isVisible() == true then	
            if itemObj.head_ico:isVisible() == true then
               if itemObj.chat_lbl:getContentSize().height > itemObj.head_ico:getSize().height then
                  this.lastHeight = this.lastHeight - (itemObj.chat_lbl:getContentSize().height + 8)
               else
                  this.lastHeight = this.lastHeight - (itemObj.head_ico:getSize().height + 8)
               end
            else 
               if itemObj.chat_lbl:getContentSize().height > itemObj.name_lbl:getContentSize().height then
                  this.lastHeight = this.lastHeight - (itemObj.chat_lbl:getContentSize().height + 8)
               else
                  this.lastHeight = this.lastHeight - (itemObj.name_lbl:getContentSize().height + 8)
               end
            end
         else 
            this.lastHeight = this.lastHeight - 70
         end
         this.height = this.lastHeight	
      elseif barType == "topChat" then
         local chat_bg = tool.findChild(itemObj,"chat_bg","ImageView")
         this.lastHeight = this.lastHeight - chat_bg:getSize().height - 30
         this.height = this.lastHeight + 12	   
      else
         if column == 1 or (this.ListCnt-1)%column == 0 then
            this.lastHeight = this.lastHeight - itemHeight
         end
         if this.lastHeight >= size.height  then
            this.height = this.lastHeight + 30
         else
            this.height  = this.lastHeight 
         end
         --this.height = this.lastHeight + 30
      end
      local innerSize = scorll:getInnerContainerSize()
      if this.height > size.height then 
         local barSize = scrollBar:getSize()
         local barbgSize = scorllBarbg:getSize()
         local newBarHeight = barbgSize.height*(size.height/this.height) > 50 and barbgSize.height*(size.height/this.height) or 50
         scrollBar:setSize(CCSize(barSize.width, newBarHeight))
         scollBarY = scorllBarbg:getSize().height -scrollBar:getSize().height 
         --scorllBarbg:setVisible(true)
         this.isScorllBarBgVisible = true
      else
         --scorllBarbg:setVisible(false)
         this.isScorllBarBgVisible = false
      end
      scorll:setInnerContainerSize(CCSize(innerSize.width,this.height))
      if sizeChangeFunc then
         sizeChangeFunc()
      end

      if itemObj and itemObj.item_index then
         this.List[itemObj.item_index] = nil
         itemObj:removeFromParent()
         this.ListCnt = this.ListCnt - 1
      end
      this.resetAllChildPostion()
   end
   
   this.removeScorll = function ()
      --this.clear()
      scorllBarbg:stopAllActions()
      if scorll then
	 scorll:removeFromParent()
      end
      if scrollBar then
	 scrollBar:removeFromParent()
      end
      if scorllBarbg then
	 scorllBarbg:stopAllActions()
	 scorllBarbg:removeFromParent()
      end
      scorll = nil
      scrollBar = nil
      scorllBarbg = nil
   end
   this.clear = function ()
      for i,v in pairs(this.List) do
	 	 v:removeFromParent()
      end
      this.List = {}
      this.ListCnt = 0
      this.lastHeight = 0
      this.totalPage = 0
   
   end
   this.getSize = function ()
      return scorll:getSize()
   end
   this.setTouchEnabled = function(flag)
      scorll:setTouchEnabled(flag)
      for i,v in pairs(this.List) do
	 v:setTouchEnabled(flag)
      end
   end
   
   this.updateItemsVisible = function(data,event)
      if this.isOutDisplayEnabled == false then
	 return
      end
      local layout = tolua.cast(data:getInnerContainer(),"Layout")
      local icSize = tolua.cast(data:getInnerContainerSize(),"CCSize")
      local svSize = tolua.cast(data:getSize(),"CCSize") 
      --print("#############################")
      -- print(layout:getPositionX(),layout:getPositionY())
      -- print(icSize.width,icSize.height)
      -- print(svSize.width,svSize.height)
      local objSize = nil
      local ap = nil
      local layoutPosY = layout:getPositionY()
      for i,v in pairs(this.List) do
	 -- print("index",i)
		 local posY = v:getPositionY()
		 if objSize == nil then
		    objSize = v:getSize()
		 end
		 if ap == nil then
		    ap = v:getAnchorPoint()
		 end
		 if posY-ap.y*objSize.height > -layoutPosY+svSize.height or posY+(1-ap.y)*objSize.height < -layoutPosY then
		    v:setVisible(false)
		 else
		    if v:isVisible() == false then
		       --print("########scrollList visible",i)
		       v:setVisible(true)
		       if v.isFadeIn == nil then
			  v:setOpacity(0)
			  v.isFadeIn = true
			  tool.createEffect(tool.Effect.fadeIn,{time=0.3},v,
					    function()
					       v.isFadeIn = nil
					    end
					    ,true)
		       end
		     --  print(this.pageEnabled,v.page,this.totalPage,event)
		       if this.pageEnabled == true and v.page == this.totalPage and event == "onScroll" then
			  this.totalPage = this.totalPage + 1
			 --print("#########scrollList next page")
			  if parentModule and parentModule.nextPage then
			     parentModule.nextPage(this.totalPage)
			  end
		       end
		    end
		    
	 	end
      end
   end
   
   this.setIsOutDisplayEnabled = function(flag)
      this.isOutDisplayEnabled = flag
   end
   
   this.setPageEnabled = function(flag)
      this.pageEnabled = flag
   end

   this.onScroll = function (event,data)
      --print(event)
      if event == "onScroll" or event == "onScrollFalse" then
         --pos = tool.getPosition(scorllBarbg)
         --printTable(pos)
         --print("###########onScroll#########")
         this.updateItemsVisible(data,event)
         scorllBarbg:stopAllActions()
            scorllBarbg:setOpacity(255)
         
         data = tolua.cast(data,"ScrollView")
         local layout = tolua.cast(data:getInnerContainer(),"Layout")
         local icSize = tolua.cast(data:getInnerContainerSize(),"CCSize")
         local svSize = tolua.cast(data:getSize(),"CCSize")
         local diffY = icSize.height - svSize.height 
         local percent = 1+layout:getPositionY() /diffY
         --this.fy = layout:getPositionY()
         scrollBar:setPositionY(-percent*scollBarY)
     
         
         tool.createEffect(tool.Effect.delay,{time=0.5,opacity=0}, scorllBarbg,function ()
            tool.createEffect(tool.Effect.fadeTo,{time=0.5,opacity=0}, scorllBarbg,
                              function()
                              end,false)
         end)
      else
         if parentModule then
            if event == "onStopScroll" then
               if parentModule.releasePageAndScroll then
                  parentModule.releasePageAndScroll()
               end
            else
               if parentModule.onScrollTouched then
                  parentModule.onScrollTouched(event,data)
               end
            end
         end
      end
   end
   scorll:registerEventScript(this.onScroll)
   return this
end
