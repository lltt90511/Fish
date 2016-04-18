local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data
local commonTop = require"scene.commonTop"
local backList = require"scene.backList"
local countLv = require"logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
module("scene.chatPrivate", package.seeall)

this = nil
local textInput = nil
local eventHash = {}
local expVisible = false
local expScroll = nil
targateId = 0
local targateName = nil
local thisParent = nil
local parentModule = nil
local WIDTH = 700
local currentPage = 0
local maxNum = 5
local hasExpression = false
local isToBottom = false

function create(_parent,_name,_id,_parentModule)
	thisParent = _parent
  parentModule = _parentModule
	this = tool.loadWidget("cash/chatPrivate",widget,thisParent,99)
    -- scroll = scrollList.create(widget.bg.scroll.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,200,0,true,"club",nil,package.loaded["scene.chatPrivate"],0,200,100)
    -- scroll.setIsOutDisplayEnabled(true)
	targateName = _name
    targateId = _id
    currentPage = 0
    initView(true)
    initEditBox()
    initExpression()
    changeExpressionPanelVisible(expVisible)
    widget.bg.label_2.obj:setText(_name)
    widget.bg.label_1.obj:setPositionX(widget.bg.label_2.obj:getPositionX()-widget.bg.label_2.obj:getSize().width/2-5)
    widget.bg.label_3.obj:setPositionX(widget.bg.label_2.obj:getPositionX()+widget.bg.label_2.obj:getSize().width/2+5)
    event.listen("ON_SEND_PRIVATE_MESSAGE", onSendPrivate)
    event.listen("ON_SEND_PRIVATE_MESSAGE_SUCCEED", onSendPrivateSucceed)
    -- local listSize = widget.bg.list.obj:getSize()
    -- local listInnerSize = widget.bg.list.obj:getInnerContainerSize()
    -- widget.bg.list.obj:setInnerContainerSize(CCSize(listInnerSize.width,listInnerSize.height))
    -- widget.bg.list.obj:setSize(CCSize(listSize.width,listSize.height))

    local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
    if vipLv < 6 then
       widget.bg.inviter.obj:setVisible(false)
       widget.bg.inviter.obj:setTouchEnabled(false)
    end
    widget.bg.list.obj:registerEventScript(function(event)
         -- print("event!!!!!!!!!",event)
         if event == "SCROLL_TOP" then
            print("SCROLL_TOP!!!!!!!!!!!!!!!!!!")
            if isToBottom then 
               -- print("isToBottom 2222!!!!!!!!!!!!!!!!!!") 
                return 
            end 
            currentPage = currentPage + 1
            initView(false)
         end
    end)
end

function onSendPrivate(data)
  if not this then return end
	print("onSendPrivate!!!!!!!!!!!!!!!!!!!!!!!")
	-- printTable(data)
  local id = 0
  if userdata.UserInfo.id == tonumber(data.charId) or userdata.UserInfo.charId == tonumber(data.charId) then
     id = tonumber(data.targetCharId)
  elseif userdata.UserInfo.id == tonumber(data.targetCharId) or userdata.UserInfo.charId == tonumber(data.targetCharId) then
     id = tonumber(data.charId)
  end
  -- event.pushEvent("ON_RESET_CHAT_HISTORY")
  if id ~= targateId then return end
     UserChar[id][#UserChar[id]].hadRead = 1
     updateChar(id,1)
     -- print("------------------------------------------")
     -- printTable(UserChar)
	   addMessage(true,data,nil,true)
     performWithDelay(function()
                     if not this then return end
                     isToBottom = true
                     widget.bg.list.obj:setBounceEnabled(false)
                     -- widget.bg.list.obj:scrollToBottom(0.5,true)
                     widget.bg.list.obj:jumpToBottom()
                     performWithDelay(function()
                                         if not this then return end  
                                         isToBottom = false
                                         widget.bg.list.obj:setBounceEnabled(true)
                                      end,0.6)
                  end,0.15)
end

function onSendPrivateSucceed(data)
  if not this then return end
	print("onSendPrivateSucceed!!!!!!!!!!!!!!!!!!!!!!!")
	-- printTable(data)
	addMessage(false,data,nil,true)
   performWithDelay(function()
                     if not this then return end
                     isToBottom = true
                     print("onSendPrivateSucceed scrollToBottom1!!!!!!!!!!!!!!!!!!!!")
                     widget.bg.list.obj:setBounceEnabled(false)
                     -- widget.bg.list.obj:scrollToBottom(0.5,true)
                     widget.bg.list.obj:jumpToBottom()
                     print("onSendPrivateSucceed scrollToBottom2!!!!!!!!!!!!!!!!!!!!")
                     performWithDelay(function()
                                         if not this then return end  
                     print("onSendPrivateSucceed scrollToBottom end!!!!!!!!!!!!!!!!!!!!")
                                         isToBottom = false
                                         widget.bg.list.obj:setBounceEnabled(true)
                                      end,0.6)
                  end,0.15)
end

function initView(flag)
	print("initView",targateId)
	if UserChar[targateId] then
     -- widget.bg.list.obj:removeAllItems()
     local beginCnt = 0
     local endCnt = 0
     local cnt = 0
     -- if #UserChar[targateId] > (currentPage+1)*maxNum then
     --    cnt = #UserChar[targateId] - currentPage*maxNum + 1
     --    -- beginCnt = #UserChar[targateId] - (currentPage+1)*maxNum
     -- else
     --    cnt = #UserChar[targateId]
     --    -- beginCnt = 1
     -- end
        cnt = #UserChar[targateId] - currentPage*maxNum
     -- print("cnt",cnt)
     for i=1,#UserChar[targateId] do
        if i > currentPage*maxNum and i <= (currentPage+1)*maxNum then
           local message = UserChar[targateId][cnt]
           -- printTable(message)
           if message then
               if userdata.UserInfo.id == tonumber(message.charId) or userdata.UserInfo.charId == tonumber(message.charId) then
                  addMessage(false,message,(i-1)*0.05,false)
               elseif userdata.UserInfo.id == tonumber(message.targetCharId) or userdata.UserInfo.charId == tonumber(message.targetCharId) then
                  addMessage(true,message,(i-1)*0.05,false)
               end 
           end
           cnt = cnt - 1
        elseif i > (currentPage+1)*maxNum then
           break
        end
     end
     -- if flag then
     --    performWithDelay(function()
     --                   if not this then return end
     --                   -- widget.bg.list.obj:setBounceEnabled(false)
     --                   -- widget.bg.list.obj:scrollToBottom(0.5,true)
     --                   performWithDelay(function()
     --                                       if not this then return end  
     --                                       widget.bg.list.obj:setBounceEnabled(true)
     --                                    end,0.6)
     --                end,(#UserChar[targateId]+1)*0.05)
     -- end
	end
  -- printTable(UserChar[targateId])
end

function addMessage(flag,message,time,isNew)
  time = time == nil and 0.1 or time
  local func = function()
      if not this then return end
      -- print("addMessage@!@!!!!!!!!!!!!!!!!!!")
      -- printTable(message)
      local item = nil
      local posx = 0
      if flag then
         item = widget.right.obj:clone()
      else
         item = widget.left.obj:clone()
      end
      local head = tool.findChild(item,"head","ImageView")
      local icon = tool.findChild(head,"icon","ImageView")
      icon:loadTexture("cash/qietu/main2/default.jpg")
      local image = tool.findChild(head,"image","ImageView")
      tool.loadRemoteImage(eventHash, icon, tonumber(message.charId))
      local layout = Layout:create()
      local _richText = RichText:create()
      _richText:ignoreContentAdaptWithSize(false)
      local textWidth = addSplitMessage(_richText, message)
      if hasExpression then
         _richText:setSize(CCSize(WIDTH,72))
      else
         _richText:setSize(CCSize(WIDTH,52))
      end
      -- print("textWidth",textWidth)
      if textWidth > WIDTH then     
         _richText:ignoreContentAdaptWithSize(false)
         _richText:setSize(CCSize(WIDTH, _richText:getSize().height*math.ceil(textWidth/WIDTH)))
      else
         _richText:setSize(CCSize(textWidth, _richText:getSize().height*math.ceil(textWidth/WIDTH)))
      end
      _richText:setAnchorPoint(ccp(0,0))
      _richText:setPosition(ccp(0,0))
      layout:setSize(_richText:getSize())
      layout:addChild(_richText) 
      if flag then
         layout:setPosition(ccp(26,-5-_richText:getSize().height))
      else
         layout:setPosition(ccp(-26-layout:getSize().width,-5-_richText:getSize().height))
      end
      image:addChild(layout)
      -- print("layout",_richText:getSize().width,_richText:getSize().height,layout:getSize().width,layout:getSize().height)
      image:setSize(CCSize(layout:getSize().width+40,layout:getSize().height+10))
      hasExpression = false
      -- widget.bg.list.obj:pushBackCustomItem(item)
      if isNew then
         widget.bg.list.obj:pushBackCustomItem(item)
      else
         widget.bg.list.obj:insertCustomItem(item,0)
      end
  end 
  performWithDelay(func,time)
end

function initEditBox()
   local inputSize = widget.bg.input_bg.obj:getSize()
   widget.bg.input_bg.obj:setSize(CCSize(inputSize.width,inputSize.height))
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput = tolua.cast(TextField:create(),"TextField")
   widget.bg.input_bg.obj:addNode(textInput)
   -- textInput:setPosition(ccp(2,8))
   textInput:setPosition(ccp(0,0))
   textInput:setAnchorPoint(ccp(0,0.5))
   textInput:setFontColor(ccc3(255,255,255))
   -- textInput:setFontSize(45)
   textInput:setFontSize(40)
   textInput:setFontName(DEFAULT_FONT)
   textInput:setReturnType(1)
   -- textInput:setMaxLengthEnabled(true)
   textInput:setMaxLength(20)
   textInput:setPlaceHolder("输入文字")
   textInput:setText("")
   textInput:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      print(textInput:getText())
      print(strEventName)
      local str = textInput:getText()
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         local i = 1
         local cnt = 1
         local tb = {}
         while i <= #str  do
            c = str:sub(i,i)
            ord = c:byte()
            if ord > 128 then
               table.insert(tb,str:sub(i,i+2))
               i = i+3
               cnt = cnt + 1
            else
               table.insert(tb,c)
               i = i+1
               cnt = cnt + 1
            end
            if cnt > 21 then
               alert.create("文字太长，超过输入限制")
               textInput:setText("")
               return
            end
         end
         textInput:setText(table.concat(tb))
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.bg.input_bg.obj:setTouchEnabled(true)
   widget.bg.input_bg.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput:attachWithIME()
                                                   textInput:setPosition(ccp(0,0))
                                                end
   end)
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
	  -- cleanScene()
      event.unListen("ON_SEND_PRIVATE_MESSAGE", onSendPrivate)
      event.unListen("ON_SEND_PRIVATE_MESSAGE_SUCCEED", onSendPrivateSucceed)
	  cleanEvent()
	  expVisible = false
    expScroll = nil
      targateId = 0
      currentPage = 0
    targateName = nil
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      thisParent = nil
    parentModule = nil
    hasExpression = false
    isToBottom = false
  end
end

function onBack(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     if parentModule and parentModule.resetShowChatHistory then
        parentModule.resetShowChatHistory(false)
     end
     exit()
  end
end

function initExpression()
   expScroll = scrollList.create(widget.bg.scroll.obj,widget.bg.scroll_bg.scroll_bar.obj,widget.bg.scroll_bg.obj,78,0,true,"",6,package.loaded["scene.chatPrivate"])
   local render_tmp = widget.bg.scroll.exp_tmp.obj
   render_tmp:setVisible(false)
   render_tmp:setTouchEnabled(false)
   for i = 1,40 do 
      local render = {obj=tolua.cast(render_tmp:clone(),"ImageView")}
      render.obj:setVisible(true)
      render.obj:loadTexture("expression/expression_a_0"..i..".png")
      render.obj:setTouchEnabled(true)
      render.obj:registerEventScript(
         function(event1)
            if event1 == "releaseUp" then
               local str = textInput:getText()
               str = str .. ";"..i
               textInput:setText(str) 
               -- local str = widget.input_bg.textField.obj:getContentText()
               -- str = str .. ";"..i
               -- widget.input_bg.textField.obj:setText(str) 
               
               expVisible = not expVisible
               changeExpressionPanelVisible(expVisible)
            end
         end
      )
      expScroll.pushItem(render.obj)
   end
end

function isExpression(str)
   local arr = splitString(str, ";")
   if string.sub(str,1,1) == ";" and #arr == 1 then
      local num = tonumber(arr[1])
      if num ~= nil then
         if num >= 1 and num <= 40 then
            hasExpression = true
            return num
         end
      end
   end
   return nil
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
   
   local color = ccc3(0,0,0)

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

function changeExpressionPanelVisible(flag)
   if flag == true and expScroll == nil then
      initExpression()
   end
   if expScroll then
      expScroll.setTouchEnabled(flag)
   end
   widget.bg.scroll.obj:setTouchEnabled(flag)
   widget.bg.scroll.obj:setVisible(flag)
   widget.bg.scroll_bg.obj:setVisible(flag)
end

function onExpression(event)
   if event == "releaseUp" then
      expVisible = not expVisible
      changeExpressionPanelVisible(expVisible)
   end
end

function onSend(event)
   if event == "releaseUp" then
      local str = textInput:getText()
      if str ~= "" then
         local _msg = http.urlencode(str)
         print("_msg",payServerUrl,payServerUrl.."/ydream/login?type=99&param=",_msg)
         http.request(payServerUrl.."/ydream/login?type=99&param=".._msg,
           function(header,body,flag)
	             if flag == false then
	               alert.create("服务器连接失败")
	               return 
	             end
	             local tab = cjson.decode(body)
	             printTable(tab)
	             if tab.result == "false" then
	              	alert.create("您输入的内容检测包含屏蔽字")
	             	textInput:setText(tab.param)
	              	return
	             end
	             call("privateChat",targateId,str)
	             textInput:setText("")
           end)
      end
   end
end

function onInviter(event)
   if event == "releaseUp" then
      local moraGame = package.loaded["scene.moraGame"]
      if moraGame.this then
         alert.create("已在游戏中，不能邀请其他人！")
      else
         call("enterGame", 3)
         moraGame.inviterId = targateId
      end
   end
end

widget = {
	_ignore = true,
	bg = {
		_type = "ImageView",
		back = {_type = "Button",_func = onBack};
		label_1 = {_type = "Label"},
		label_2 = {_type = "Label"},
		label_3 = {_type = "Label"},
   	exp_btn = {_type = "Button", _func = onExpression},
		input_bg = {_type = "ImageView"},
   	send_btn = {_type = "Button", _func = onSend},
		list = {_type = "ListView"},
		scroll = {
        _type = "ScrollView",
        exp_tmp = {_type = "ImageView",
                    _anchorx = 0,
                    _anchory = 0,
        },
	  },
	  scroll_bg = {
        _type = "ImageView",
        scroll_bar = {_type = "ImageView"},
	  },
    inviter = {_type = "Button",_func = onInviter},
	},
	right = {
		_type = "Layout",
		head = {
			_type = "ImageView",
			icon = {_type = "ImageView"},
			image = {_type = "ImageView"},
		},
	},
	left = {
		_type = "Layout",
		head = {
			_type = "ImageView",
			icon = {_type = "ImageView"},
      image = {_type = "ImageView"},
		},
	},
}