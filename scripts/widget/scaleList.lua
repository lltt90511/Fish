local tool = require"logic.tool"
module("widget.scaleList", package.seeall)

function create(parent,x,y,offsetWidth,parentModule,moveDisable)
   local this = {}
   this.list = {}
   this.listCnt = 0
   this.startPos = {}
   this.middleIndex = 0
   this.itemWidth = 0
   this.lastDirection = 0
   this.moveDistance = 0
   this.timer = nil
   parent:setTouchEnabled(true)

   this.pushItem = function(item,flag,callback)
      parent:addChild(item) 
      table.insert(this.list, item)
      this.listCnt = this.listCnt + 1
      if flag == nil then
         this.middleIndex = 1--math.ceil(this.listCnt/2)
      end
      this.resetAllChildPosition()
      this.itemWidth = item:getSize().width
      item:setTouchEnabled(true)
      local index = this.listCnt
      item:registerEventScript(function (event,data)
                                  if event == "releaseUp" or event == "cancelUp" then
                                     --print(item.isMoved,event)
                                     if math.abs(this.moveDistance) < 100 then
                                        item.isMoved = nil
                                     end
                                     if item.isMoved == nil and event == "releaseUp" then
                                        if this.middleIndex == index then
                                           if callback then
                                              callback()
                                           end 
                                        end
                                        this.middleIndex = index
                                        this.resetAllChildPosition(true,0.2)                                        
                                     else
                                        onTouched(event,data)
                                     end
                                     item.isMoved = nil
                                  elseif event == "pushDown" then
                                     onTouched(event,data)
                                  elseif event == "move" then
                                     --print(this.moveDistance)
                                     item.isMoved = true
                                     onTouched(event,data)
                                  end
      end)
   end

   this.resetAllChildPosition = function (isEffect,time)
      
      for i, v in pairs(this.list) do
         local fx = 0
         local scale = 0
         if i <= this.middleIndex-2 or i >= this.middleIndex+2 then
            scale = 0.5
            if i <= this.middleIndex-2 then
               fx = x - this.itemWidth/2 - this.itemWidth*0.7 - this.itemWidth*0.5*(this.middleIndex-2-i) - this.itemWidth*0.5/2 - (this.middleIndex-i)*offsetWidth
            else
               fx = x + this.itemWidth/2 + this.itemWidth*0.7 + this.itemWidth*0.5*(i-this.middleIndex-2) + this.itemWidth*0.5/2 + (i-this.middleIndex)*offsetWidth
            end
         elseif i <= this.middleIndex-1 or i >= this.middleIndex+1 then
            scale = 0.7
            if i <= this.middleIndex-1 then
               fx = x - this.itemWidth/2 - this.itemWidth*0.7/2 - offsetWidth
            else
               fx = x + this.itemWidth/2 + this.itemWidth*0.7/2 + offsetWidth
            end
         else
            scale = 1
            fx = x
         end
         --print(v:getSize().width,v:getSize().height)
         -- v:setPosition(ccp(fx,y))
         if isEffect then
            v:setTouchEnabled(false)
            parent:setTouchEnabled(false)
            tool.createEffect(tool.Effect.move,{time = time, x = fx, y = y},v,
                              function()
                                 v:setTouchEnabled(true)
                                 parent:setTouchEnabled(true)
                              end
                              ,true,true)
            tool.createEffect(tool.Effect.scale,{time=time, scale=scale},v,nil,true)
         else
            v:setScale(scale)
            v:setPosition(ccp(fx,y))
         end
      end
      if isEffect then
         performWithDelay(function()
                             if parentModule and parentModule.changeSelectedItem then
                                parentModule.changeSelectedItem()
                             end
                          end,time+0.2)
      else
         if parentModule and parentModule.changeSelectedItem then
            parentModule.changeSelectedItem()
         end
      end
   end

   this.exit = function ()
      if this.timer then
         tool.unSchedule(this.timer)
         this.timer = nil
      end
      for i, v in pairs(this.list) do
         v:stopAllActions()
         v:removeFromParent()
      end
      this.list = {}
   end

   function refresh(diffxx)
      local time = 0.1
      local direction = diffxx > 0 and -1 or 1
      
      for i, v in pairs(this.list) do
         
         local diffx = diffxx
         if i == this.middleIndex + direction*2 or i == this.middleIndex - direction then
            local scale = v:getScaleX()
            diffx = (this.itemWidth/2*1.2+offsetWidth)/(this.itemWidth/2*1.7+offsetWidth)*diffx
            local per = math.abs(diffx)/(this.itemWidth/2*1.2+offsetWidth)
            if i == this.middleIndex + direction*2 then
               if (scale+per*0.2) > 0.7 then
                  v:setScale(0.7)
               else
                  v:setScale(scale+per*0.2)
               end
            else
               if (scale-per*0.2) < 0.5 then
                  v:setScale(0.5)
               else
                  v:setScale(scale-per*0.2)
               end
            end
         elseif i == this.middleIndex + direction or i == this.middleIndex then
            local scale = v:getScaleX()
            local per = math.abs(diffx)/(this.itemWidth/2*1.7+offsetWidth)
            if i == this.middleIndex + direction then
               if (scale+per*0.3) >= 1 then
                  v:setScale(1)
                  this.middleIndex = this.middleIndex + direction
                  --print(this.middleIndex)
               else
                  v:setScale(scale+per*0.3)
               end
            else
               if (scale-per*0.3) < 0.7 then
                  v:setScale(0.7)
               else
                  v:setScale(scale-per*0.3)
               end
            end
         else
            diffx = (this.itemWidth/2*1+offsetWidth)/(this.itemWidth/2*1.7+offsetWidth)*diffx
         end
         local pos = {x=v:getPositionX(),y=v:getPositionY()}
         --print(pos.x,pos.y)
         --tool.setPosition(v,pos,{x=diffx,y=0})
         v:setPosition(ccp(pos.x+diffx,pos.y))
      end
   end

   function onTouched(event,data)
      local pos = data:getLocation()
      --print(pos.x,pos.y)
      print(event)
      if event == "pushDown" then
         this.startPos.x = pos.x
         this.startPos.y = pos.y
         this.moveDistance = 0
         this.lastDirection = 0
      elseif event == "move" then
         local diffx = pos.x-this.startPos.x
         local direction = diffx > 0 and -1 or 1
         --print(direction,this.lastDirection)
         if moveDisable == nil then
            if this.lastDirection == 0 or direction == this.lastDirection then 
               this.lastDirection = direction
               refresh(diffx)
               this.moveDistance = this.moveDistance + diffx
            elseif this.lastDirection ~= 0 and direction ~= this.lastDerection then
               this.lastDirection = direction
               this.resetAllChildPosition()
               this.moveDistance = 0
            end
         else
            this.lastDerection = direction
         end
         this.startPos.x = pos.x
      elseif event == "releaseUp" or event == "cancelUp" then
         if moveDisable == nil then
            if math.abs(this.moveDistance) > 500 then
               print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
               local direction = 0
               if this.moveDistance > 500 then
                  direction = - 1
               else
                  direction = 1
               end
               this.timer = tool.schedule(function()
                                             this.middleIndex = this.middleIndex + direction 
                                             if this.middleIndex <= 1 or this.middleIndex >= this.listCnt then
                                                if this.timer then
                                                   tool.unSchedule(this.timer)
                                                   this.timer = nil
                                                end
                                                if this.middleIndex <= 0 or this.middleIndex > this.listCnt then
                                                   this.middleIndex = this.middleIndex - direction
                                                end
                                                this.resetAllChildPosition(true,0.2)
                                             else
                                                this.resetAllChildPosition(true,0.2)
                                             end
                                          end,0.2)
            else
               local objPos  = nil
               local objWidth = nil
               local flag = false
               print("##################################")
               if this.middleIndex - 1 > 0 then
                  objPos = {x=this.list[this.middleIndex-1]:getPositionX(),y=this.list[this.middleIndex-1]:getPositionY()}
                  objWidth = this.list[this.middleIndex-1]:getScaleX()*this.itemWidth
                  if objPos.x > x - this.itemWidth/2 - objWidth/2 then
                     this.middleIndex = this.middleIndex - 1
                     flag = true
                  end
               end
               if flag == false then
                  if this.middleIndex + 1 <= this.listCnt then
                     objPos = {x=this.list[this.middleIndex+1]:getPositionX(),y=this.list[this.middleIndex+1]:getPositionY()}
                     objWidth = this.list[this.middleIndex+1]:getScaleX()*this.itemWidth
                     if objPos.x < x + this.itemWidth/2 + objWidth/2 then
                        this.middleIndex = this.middleIndex + 1
                        flag = true
                     end
                  end
               end	    
               this.resetAllChildPosition(true,0.2)
            end
         else
            if this.middleIndex + this.lastDerection > 0 and this.middleIndex + this.lastDerection <= this.listCnt then
               this.middleIndex = this.middleIndex + this.lastDerection
               this.resetAllChildPosition(true,0.2)
            end
         end
      end
   end
   parent:registerEventScript(onTouched)   
   return this
end
