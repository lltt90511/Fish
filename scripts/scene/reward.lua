local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.reward", package.seeall)

this = nil
subWidget = nil
local getList = {}
local unGetList = {}
local unFinishList = {}
local posx = 714
local posy = 1485-(1120-1067) --1485是list的相对坐标 1120-1067是list的高减去list的偏移量 这样算出来的是list上item的起始坐标
local isPush = true

function create(parent,rankList)
   this = tool.loadWidget("cash/reward",widget,parent,99)
   call("getQuestCountList")
   widget.panel.bg.list.obj:setItemModel(widget.tmp.obj)
   event.listen("ON_GET_QUEST",inintView)
   event.listen("ON_FINISH_QUEST",onFinishQuest)
   event.listen("ON_UPDATE_QUEST",inintView)
   event.listen("ON_GOLD_ACTION_FINISH",inintView)
   return this
end

function inintView()
	print("inintView")
  getList = {}
  unGetList = {}
  unFinishList = {}
	widget.panel.bg.list.obj:removeAllItems()
	printTable(userdata.UserInfo.hashKey)
	print("------------------------------")
	printTable(userdata.UserInfo.timeHashKey)
	print("==============================")
	printTable(userdata.UserInfo.reachedQuest)
  print("getSyncedTime()",getSyncedTime())
   for k,v in pairs(template['quest']) do
   	   print("k:",k)
   	   local tpl = userdata.UserInfo.hashKey[tostring(k)] 
   	   if tpl == nil then
   	   	  tpl = 0
   	   end
   	   if v then
          local isReached = false
	 	      for m,n in pairs(userdata.UserInfo.reachedQuest) do
    	 	 	    if tonumber(n) == v.id then
    	 	 		     isReached = true
    	 	 		     break
    	 	 	    end
    	 	  end
   	   	  if tonumber(tpl) >= v.finishCnt then
   	   	 	   if v.timeType == 0 then
   	   	 	 	    if isReached == true then
	   	   	  	 	   table.insert(getList,{id = k,cnt = tonumber(tpl)})
	   	   	  	  else 
                   table.insert(unGetList,{id = k,cnt = tonumber(tpl)})
				        end
			       elseif v.timeType == 3 then
				         local startTime = timeToDayStart(getSyncedTime())
				         if userdata.UserInfo.timeHashKey[tostring(k)] and startTime < userdata.UserInfo.timeHashKey[tostring(k)]/1000 then
   	   	  	    	  if isReached then
                       table.insert(getList,{id = k,cnt = tonumber(tpl)})
                    else
                       table.insert(unGetList,{id = k,cnt = tonumber(tpl)})
                    end
				         else
                    table.insert(unFinishList,{id = k,cnt = 0})
				         end
			       end
		      else
             table.insert(unFinishList,{id = k,cnt = tonumber(tpl)})
  	   	  end
   	   end
   end 
   local cnt = 0
   local addItemFunc = function(obj,data,flag,c)
       local tmp = template['quest'][data.id]
       local title = tool.findChild(obj,"title","Label")
       title:setText(tmp.name)
       local info = tool.findChild(obj,"info","Label")
       info:setText(tmp.desc)
       local gold = tool.findChild(obj,"gold","ImageView")
       local img_gold = tool.findChild(gold,"gold","ImageView")
       local lab_gold = tool.findChild(gold,"label","Label")
       lab_gold:setText(tmp.rewardCnt)
       local bar = tool.findChild(obj,"bar","ImageView")
       local loadingBar = tool.findChild(bar,"ProgressBar","LoadingBar")
       local curCnt = data.cnt
       local btn = tool.findChild(obj,"btn","Button")
       local text = tool.findChild(btn,"text","Label")
       local text_shadow = tool.findChild(btn,"text_shadow","Label")
       if flag == 1 then
          if data.id == 518 or data.id == 519 then
             curCnt = 1
          end
          text:setText("领取")
          text_shadow:setText("领取")
          btn:setBright(true)
          btn:setTouchEnabled(true)
          btn:registerEventScript(function(ev)
              if ev == "releaseUp" then
                 tool.buttonSound("releaseUp","effect_12")
                 local container = widget.panel.bg.list.obj:getInnerContainer()
                 local offsetY = container:getPositionY()
                 print("offsetY",offsetY)
                 userdata.goldAction = true
                 userdata.goldPos = {x=posx,y=posy-c*243+1067+offsetY}
                 if 1067+offsetY > c*243+89 then
                    isPush = false
                 else
                    isPush = true
                    -- event.pushEvent("ON_GOLD_ACTION")
                 end
                 call("getQuestReward",data.id)
              end
           end)
       elseif flag == 2 then
          if data.id == 518 or data.id == 519 then
             curCnt = 0
          end
          text:setText("未完成")
          text_shadow:setText("未完成")
          btn:setTouchEnabled(false)
          btn:setBright(false)
       elseif flag == 3 then  
          if data.id == 518 or data.id == 519 then
             curCnt = 1
          end                  
          text:setText("已领取")
          text_shadow:setText("已领取")
          btn:setBright(false)
          btn:setTouchEnabled(false)
       end
       if curCnt > tmp.finishCnt then
          curCnt = tmp.finishCnt
       end
       local percent = curCnt/tmp.finishCnt
       if percent > 1 then
          percent = 1
       end
       loadingBar:setPercent(percent*100)
       local label = tool.findChild(obj,"label","Label")
       label:setText(curCnt.."/"..tmp.finishCnt)
   end
   for i,j in pairs(unGetList) do
       widget.panel.bg.list.obj:pushBackDefaultItem()
       local obj = tolua.cast(widget.panel.bg.list.obj:getItem(cnt),"Button")
       addItemFunc(obj,j,1,cnt)
       cnt = cnt + 1
   end
   for i,j in pairs(unFinishList) do
       widget.panel.bg.list.obj:pushBackDefaultItem()
       local obj = tolua.cast(widget.panel.bg.list.obj:getItem(cnt),"Button")
       addItemFunc(obj,j,2,cnt)
       cnt = cnt + 1
   end
   for i,j in pairs(getList) do
       widget.panel.bg.list.obj:pushBackDefaultItem()
       local obj = tolua.cast(widget.panel.bg.list.obj:getItem(cnt),"Button")
       addItemFunc(obj,j,3,cnt)
       cnt = cnt + 1
   end
end

function onFinishQuest()
   if isPush == true then
      event.pushEvent("ON_GOLD_ACTION")
   else
      inintView()
   end
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
      -- local main = package.loaded['scene.main']
      -- main.setRewardPaoNum()
  	  event.unListen("ON_GET_QUEST",inintView)
  	  event.unListen("ON_FINISH_QUEST",onFinishQuest)
      event.unListen("ON_UPDATE_QUEST",inintView)
      event.unListen("ON_GOLD_ACTION_FINISH",inintView)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
   end
end

function getPos(obj)
  print(obj)
   local pos = {x=0,y=0}
   local finalPosX = 0
   local finalPosY = 0
   local layoutParam = tolua.cast(obj:getLayoutParameter(LAYOUT_PARAMETER_LINEAR),"RelativeLayoutParameter")
   print(layoutParam,obj:getLayoutParameter(LAYOUT_PARAMETER_LINEAR))
   if layoutParam then
      print("layoutParam getPos!!!!!!!!!!!!!!!!!")
      local mg = layoutParam:getMargin()
      local cs = obj:getSize()
      local ap = obj:getAnchorPoint()
      local align = layoutParam:getAlign()
      print("align",align)
      local parent = obj:getParent()--widget.panel.bg.list.obj
      local p = parent:getParent()
      print("parent",parent,type(parent),p)
      local layoutSize = p:getSize()
      print("layoutSize",layoutSize.width,layoutSize.height)
      local pa = p:getAnchorPoint()
      local offset = {x= - layoutSize.width * pa.x , y = - layoutSize.height * pa.y }
      print("offset",offset.x,offset.y)
      finalPosX = ap.x * cs.width;
      finalPosY = layoutSize.height - ((1.0 - ap.y) * cs.height);
      print (finalPosX,finalPosY) 
      print (finalPosX,finalPosY)
      finalPosX = finalPosX + offset.x
      finalPosY = finalPosY + offset.y
      print (finalPosX,finalPosY)
    end
    pos.x = pos.x + finalPosX
    pos.y = pos.y + finalPosY
    --print (pos.x,pos.y)
    return pos
end
      

widget = {
  	_ignore = true,
  	panel = {
	  	bg = {
	     	back = {
	    		_type = "Button",
	    		_func = onBack,
	    	},
	   		title = {_type = "ImageView"},
	   		list = {_type = "ListView"},
      },
  	},
  	scroll_bg = {
  	    _type = "ImageView",
  	    scroll_bar = {_type = "ImageView"},
    },
    tmp = {
      _type = "Button",
      title = {_type = "Label"},
      info = {_type = "Label"},
      gold = {
        _type = "ImageView",
        gold = {_type = "ImageView"},
        label = {_type = "Label"},
      },
      bar = {
          _type = "ImageView",
        ProgressBar = {_type = "LoadingBar"},
      },
      label = {_type = "Label"},
      btn = {
        _type = "Button",
        text = {_type = "Label"},
        text_shadow = {_type = "Label"},
      },
    },
} 