local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require"logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
local chatPrivate = require"scene.chatPrivate"
module("scene.chatHistory", package.seeall)

local eventHash = {}
local thisParent = nil
local parentModule = nil
local WIDTH = 800
local currentPage = 0
local maxNum = 9
local charList = {}

function create(_parent,_parentModule,_isInGame)
	thisParent = _parent
	parentModule = _parentModule
	this = tool.loadWidget("cash/chatHistory",widget,thisParent,15)
    -- scroll = scrollList.create(widget.bg.scroll.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,200,20,true,"club",nil,package.loaded["scene.chatHistory"],0,0,100)
    -- scroll.setIsOutDisplayEnabled(true)
	print("his create---------------------------------------------------------------------")
	-- printTable(UserChar)
	-- printTable(UserChar)
	-- printTable(charList)
	-- printTable(charList)
	if _isInGame ~= nil and _isInGame then
	   maxNum = 11
	   local bgSize = widget.bg.obj:getSize()
	   local listSize = widget.bg.list.obj:getSize()
       local listInnerSize = widget.bg.list.obj:getInnerContainerSize()
       local sizeAdd = Screen.height-bgSize.height-168
       widget.bg.list.obj:setInnerContainerSize(CCSize(listInnerSize.width,Screen.height-168-20))
       widget.bg.list.obj:setSize(CCSize(listSize.width,Screen.height-168-20))	
       widget.bg.obj:setSize(CCSize(bgSize.width,Screen.height-168)) 
       widget.bg.obj:setPositionY(0)
       widget.bg.back.obj:setPositionY(widget.bg.back.obj:getPositionY()+sizeAdd)
	end
	onResetChatHistory()
    event.listen("ON_RESET_CHAT_HISTORY", onResetChatHistory)
    widget.bg.list.obj:registerEventScript(function(event)
       -- print("event!!!!!!!!!",event)
       if event == "SCROLL_BOTTOM" then
          print("SCROLL_BOTTOM!!!!!!!!!!!!!!!!!!")
          currentPage = currentPage + 1
          initChatHistoryList()
		   performWithDelay(function()
		                     if not this then return end
		                     widget.bg.list.obj:setBounceEnabled(false)
		                     widget.bg.list.obj:scrollToBottom(0.5,true)
		                     performWithDelay(function()
		                                         if not this then return end  
		                                         widget.bg.list.obj:setBounceEnabled(true)
		                                      end,0.6)
		                  end,0.15)
	   end
    end)
end

function onResetChatHistory()
	-- print('ON_RESET_CHAT_HISTORY@!!!!!!!!!!!!!!!!!!!!!!!!!')
    currentPage = 0
	charList = {}
	for k,v in pairs(UserChar) do
		local list = {}
		list.id = k
		list.time = tonumber(v[#v].time) 
		local readNum = 0
		for m,n in pairs(v) do
			if n.hadRead and tonumber(n.hadRead) == 0 then
               readNum = readNum + 1           
			end
		end
		list.readNum = readNum
		table.insert(charList,list)
		-- charList[k] = readNum
	end
	table.sort(charList,charSort)
	widget.bg.list.obj:removeAllItems()
    initChatHistoryList()
end

function charSort(a,b)
	-- print("sort!!!!!!!!!!!!!!!!!!")
	if a.readNum > b.readNum then
	   return true
	elseif a.readNum == b.readNum then
	   return a.time > b.time	
	else
	   return false
	end
end

function initChatHistoryList()
	if not this then return end
	print("initChatHistoryList")
	printTable(charList)
	local cnt = 1
	for k,v in pairs(charList) do
		if cnt > currentPage*maxNum and cnt <= (currentPage+1)*maxNum then
			local char = UserChar[v.id]
		    local list = char[#char]
			local charId = 0
			local charName = ""
			if userdata.UserInfo.id == tonumber(list.charId) or userdata.UserInfo.charId == tonumber(list.charId) then
			   charId = tonumber(list.targetCharId)
			   charName = list.targetCharName
		    elseif userdata.UserInfo.id == tonumber(list.targetCharId) or userdata.UserInfo.charId == tonumber(list.targetCharId) then
		       charId = tonumber(list.charId)
			   charName = list.charName	
			end
		   	local item = widget.tmp.obj:clone()
			local head = tool.findChild(item,"head","ImageView")
			head:loadTexture("cash/qietu/main2/default.jpg")
			local time = tool.findChild(item,"time","Label")
			local name = tool.findChild(item,"name","Label")
			local info = tool.findChild(item,"info","Label")
			local pao = tool.findChild(item,"pao","ImageView")
			if v.readNum > 0 and (not chatPrivate.this or (chatPrivate.this and chatPrivate.targateId ~= charId)) then
			   pao:setVisible(true)	
			   local num = tool.findChild(pao,"num","Label")
			   if v.readNum > 9 then
			   	  num:setText("9+")
			   else
			   	  num:setText(v.readNum)
			   end	
			   activityAni(pao)
			else
			   pao:setVisible(false)	
			end
			-- print("id---------",charId,charName,list.msg)
		    tool.loadRemoteImage(eventHash, head, charId)
		    name:setText(charName)
		    local tRec = os.date("*t",tonumber(list.time)/1000-timeDiff)
		    time:setText(tRec.year.."-"..tRec.month.."-"..tRec.day.." "..tRec.hour..":"..tRec.min..":"..tRec.sec)
		    name:setPosition(ccp(time:getPositionX()+time:getSize().width+10,name:getPositionY()))
		    local posx = 0
			local layout = Layout:create()
	        local _richText = RichText:create()
	        _richText:ignoreContentAdaptWithSize(false)
	        _richText:setSize(CCSize(WIDTH,72))
	        local textWidth = addSplitMessage(_richText,list)
	        if textWidth > WIDTH then     
	           _richText:ignoreContentAdaptWithSize(false)
	           _richText:setSize(CCSize(WIDTH, _richText:getSize().height*math.ceil(textWidth/WIDTH)))
	        else
	           _richText:setSize(CCSize(textWidth, _richText:getSize().height*math.ceil(textWidth/WIDTH)))
	        end 
	        _richText:setAnchorPoint(ccp(0,1))
	        _richText:setPosition(ccp(190,75))
	        item:addChild(_richText)
			widget.bg.list.obj:pushBackCustomItem(item)
			item:setTouchEnabled(true)
			item:registerEventScript(function(event)
		        if event == "releaseUp" then
		           tool.buttonSound("releaseUp","effect_12")
		           chatPrivate.create(widget.obj,charName,charId)
		           if v.readNum > 0 then
		           	  v.readNum = 0
		           	  pao:setVisible(false)
		           end
		           updateChar(charId,1)
		           for m,n in pairs(UserChar[charId]) do
   					   n.hadRead = 1	
		           end	
		        end
		    end)
	    elseif cnt > (currentPage+1)*maxNum then
	       break
		end
		cnt = cnt + 1
	end
end

function activityAni(obj)
   if not this or not obj:isVisible() then return end
   tool.createEffect(tool.Effect.scale,{time=0.3,scale=1.2},obj,function()
       tool.createEffect(tool.Effect.scale,{time=0.12,scale=1.0},obj,function() 
           tool.createEffect(tool.Effect.delay,{time=math.random(1,5),scale=1.0},obj,function() 
               activityAni(obj) 
           end)
       end)
   end)
end

function addSplitMessage(richText, msg)
   print("######addsplitmessage")
   local totalWidth = 0
   local args = {}
   local pattern = '(%;(%d+))'
   local last_end = 1
   local s,e,cap = string.find(msg.msg,pattern, 1)
   if s == nil then
      table.insert(args,msg.msg)
   elseif s > 1 then
      table.insert(args,string.sub(msg.msg,1,s-1))
   end
   while s do
      if s ~= 1 or cap ~= '' then         
         table.insert(args,cap)
      end
      last_end = e + 1
      s,e,cap = string.find(msg.msg,pattern,last_end)
      if s == nil then
         table.insert(args,string.sub(msg.msg,last_end))
      elseif s > last_end then
         table.insert(args, string.sub(msg.msg,last_end,s-1))
      end
   end
   
   local color = ccc3(255,255,255)

   for i = 1, #args do
      local path = isExpression(args[i])
      if path ~= nil then
         print(path)
         local _image = RichElementImage:create(i+1, color, 255, "expression/expression_a_0"..path..".png");
         richText:pushBackElement(_image)
         
         totalWidth = totalWidth + 72
      else
         local _msg = RichElementText:create(i+1,color,255,args[i],DEFAULT_FONT,40) 
         richText:pushBackElement(_msg)
         
         local msg = Label:create()
         msg:setText(args[i])
         msg:setFontSize(40)
         msg:setFontName(DEFAULT_FONT)
         
         totalWidth = totalWidth + msg:getContentSize().width
      end
   end

   return totalWidth
end

function isExpression(str)
   local arr = splitString(str, ";")
   if string.sub(str,1,1) == ";" and #arr == 1 then
      local num = tonumber(arr[1])
      if num ~= nil then
         if num >= 1 and num <= 40 then
            return num
         end
      end
   end
   return nil
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
end

function exit()
  if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_RESET_CHAT_HISTORY", onResetChatHistory)
	  -- cleanScene()
	  cleanEvent()
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      thisParent = nil
      parentModule = nil
      currentPage = 0
      charList = {}
  end
end

function onBack(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     if parentModule and parentModule == package.loaded["scene.commonTop"] then
     	parentModule.isShowChatHistory = false
     end
     exit()
  end
end

widget = {
	_ignore = true,
	bg = {
		_type = "ImageView",
		-- scroll = {_type = "ScrollView"},
		back = {_type = "Button",_func = onBack};
		list = {_type = "ListView"},
	},
	tmp = {
		_type = "Layout",
		bg = {_type = "ImageView"},
		head = {_type = "ImageView"},
		time = {_type = "Label"},
		name = {_type = "Label"},
		pao = {
			_type = "ImageView",
			num = {_type = "Label"},
		},
	},
	scroll_bg = {
	  	scroll_bar = {},
	},
}