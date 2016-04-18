local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
local chatPrivate = require"scene.chatPrivate"

module("scene.chat.main",package.seeall)

this = nil
local messageList = {}
local textInput = nil
local textRich = nil
local expScroll = nil
local expVisible = false
local WIDTH = nil
local HEIGHT = nil
local GAME_ID = nil
local systemMessageList = {}
local isSystemMessagePlaying = false
local inputWidthChange = 0
local parentModule = nil
-- payServerUrl = payServerUrl

function create(_data,_width,_height,_gameId,_parentModule)
   this = tool.loadWidget("cash/chat",widget,nil,nil,true)
   parentModule = _parentModule
   widget.obj:setSize(CCSize(_width,_height))
   WIDTH = _width
   HEIGHT = _height
   GAME_ID = _gameId
   inputWidthChange = 660-_width

   messageList = _data
   initEditBox()
   initListView()
   changeExpressionPanelVisible(expVisible)
   widget.system_layout.obj:setVisible(false)

   event.listen("USER_MESSAGE", onUserMessage)
   event.listen("SYSTEM_MESSAGE", onSystemMessage)
   event.listen("SYSTEM_CONTEXT", onSystemContext)
   return this
end

function initEditBox()
   local inputSize = widget.input_bg.obj:getSize()
   widget.input_bg.obj:setSize(CCSize(inputSize.width-inputWidthChange,inputSize.height))
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput = tolua.cast(TextField:create(),"TextField")
   widget.input_bg.obj:addNode(textInput)
   -- textInput:setPosition(ccp(2,8))
   textInput:setPosition(ccp(0,0))
   textInput:setAnchorPoint(ccp(0,0))
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
            if cnt > 20 then
               alert.create("文字太长，超过输入限制")
               textInput:setText("")
               return
            end
         end
         textInput:setText(table.concat(tb))
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.input_bg.obj:setTouchEnabled(true)
   widget.input_bg.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput:attachWithIME()
                                                   textInput:setPosition(ccp(0,0))
                                                end
   end)
end

function initListView()
   widget.list.obj:setVisible(true)
   widget.list.obj:setTouchEnabled(true)
   widget.list.obj:removeAllItems()
   for i = 1, #messageList, 1 do
      addMessage(messageList[i],i*0.05)
   end
   performWithDelay(function()
                       if not this then return end
                       widget.list.obj:setBounceEnabled(false)
                       widget.list.obj:scrollToBottom(0.5,true)
                       performWithDelay(function()
                                           if not this then return end  
                                           widget.list.obj:setBounceEnabled(true)
                                        end,0.6)
                    end,(#messageList+1)*0.05)
end

function initExpression()
   expScroll = scrollList.create(widget.scroll.obj,widget.scroll_bg.scroll_bar.obj,widget.scroll_bg.obj,78,0,true,"",6,package.loaded["scene.chat.main"])
   local render_tmp = widget.scroll.exp_tmp.obj
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
   
   local color = ccc3(255,255,255)
   if msg.type == 0 then
     local vipLv = countLv.getVipLv(msg.vipExp)
     if vipLv > 0 then
       local viplbl = Label:create()
       viplbl:setText("V"..vipLv)
       viplbl:setFontSize(40)
       viplbl:setFontName(DEFAULT_FONT)
       totalWidth = viplbl:getContentSize().width
       color = ccc3(200,0,255)
     end
   else 
      color = ccc3(255,0,0)
   end
   
   local name = Label:create()
   name:setText("["..msg.name.."] ")
   name:setFontSize(40)
   name:setFontName(DEFAULT_FONT)
   totalWidth = totalWidth + name:getContentSize().width
   
   -- printTable(args)
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

function addMessage(message, time)
   if message.isFake and userdata.UserInfo.isGM then
      return
   end
   time = time == nil and 0.1 or time
   local func = function()
      if not this then return end
      local layout = Layout:create()
      local _richText = RichText:create()
      _richText:ignoreContentAdaptWithSize(false)
      _richText:setSize(CCSize(WIDTH,72))
      local num = 1
      local color = ccc3(255,255,255)
      if message.type == 0 then
          local vipLv = countLv.getVipLv(message.vipExp)
          if vipLv > 0 then
             local _vip = RichElementText:create(num,ccc3(255,255,0),255,"V"..vipLv,DEFAULT_FONT,40)
             num = num + 1
             _richText:pushBackElement(_vip)
             color = ccc3(200,0,255)
          end
      elseif message.type == 1 then
          message.name = "活动"
          color = ccc3(255,0,0)
      elseif message.type == 2 then
          message.name = "系统"
          color = ccc3(255,0,0)
      end
        
      local _name = RichElementText:create(num,color,255,"["..message.name.."] ",DEFAULT_FONT,40)         
      _richText:pushBackElement(_name) 
      local textWidth = addSplitMessage(_richText, message)
      if textWidth > WIDTH-10 then     
         _richText:ignoreContentAdaptWithSize(false)
         _richText:setSize(CCSize(WIDTH-10, 72*math.ceil(textWidth/(WIDTH-10))))
      end
      _richText:setAnchorPoint(ccp(0,0))
      _richText:setPosition(ccp(0,0))
      layout:setSize(_richText:getSize())
      layout:addChild(_richText)     
      
      layout:setTouchEnabled(true)
      layout:registerEventScript(function(event)
         if event == "releaseUp" then
            if message.type == 0 then 
              if message.charId == userdata.UserInfo.id or message.charId == userdata.UserInfo.charId then
                 alert.create("您不能与自己私聊!!")
                 return 
              end
              print("layout is in touch!!!!!!!!!!!!!!!!!!!!!!")
              local fruit = package.loaded['scene.fruitMachine.main']
              local fish = package.loaded['scene.fishMachine.main']
              if parentModule then  
                 if parentModule == fish or parentModule == fruit then
                    if parentModule.resetShowChatHistory then
                       parentModule.resetShowChatHistory(true)
                    end
                    chatPrivate.create(parentModule.widget.obj,message.name,message.charId,parentModule)
                 end
              end
            elseif message.type == 1 then
               local activity = require"scene.activity"
               activity.create(parentModule.this)
            end
         end
      end)
      widget.list.obj:pushBackCustomItem(layout)
   end
   performWithDelay(func,time)
end

function onUserMessage(data)
   -- printTable(data)
   table.insert(messageList,data)
   if #messageList >= 50 then
       table.remove(messageList,1)
       widget.list.obj:removeItem(0)
   end
   addMessage(data)
   performWithDelay(function()    
                       if not this then return end                   
                       widget.list.obj:setBounceEnabled(false)
                       widget.list.obj:scrollToBottom(0.5,true)  
                       performWithDelay(function()
                                           if not this then return end  
                                           widget.list.obj:setBounceEnabled(true)
                                        end,0.6)
                    end,0.15)
end

function playSystemMessageEffect(flag)
   if isSystemMessagePlaying == true then 
      return
   end
   local func = nil
   func = function()
  print("playSystemMessageEffect func",userdata.isInGame)
      local data = nil
      local hasVip = false
      local count = 1
      for k,v in pairs(systemMessageList) do
          if v.type == "VIP_COM" then
             print("a11111111111111111111111111111111")
             count = k
             data = v
             hasVip = true
             break
          end
      end
      if hasVip == false then
         data = systemMessageList[1]
      end
      --print("playSystemMessageEffect func",userdata.isInGame,data.type,count,isSystemMessagePlaying)
      if userdata.isInGame == true and data and data.type ~= "VIP_COM" then--and flag == false then
         tool.createEffect(tool.Effect.delay,{time=1.0},widget.obj,function()
            func()
         end)
      else
          if #systemMessageList == 0 then
             isSystemMessagePlaying = false
             widget.system_layout.obj:setVisible(false)
             return
          end
          isSystemMessagePlaying = true
          table.remove(systemMessageList,count)
      -- tool.createEffect(tool.Effect.delay,{time=2.0},widget.system_layout.obj,
      --    function()   
            widget.system_layout.obj:setVisible(true)
            local layout = tool.getRichTextWithColor(data.text,40)   
            layout:setPosition(ccp(WIDTH,0))
            widget.system_layout.obj:addChild(layout)
            local layoutSize = layout:getSize()
            tool.createEffect(tool.Effect.move,{time=0.5*(layoutSize.width/50),x=-layoutSize.width,y=0},layout,
                  function()
                    print("finish!!!!!!!!!!!!!!!!!!!!!!!")
                    data = nil
                    hasVip = false
                    count = 1
                     layout:removeFromParent()
                     func()
                  end)
         -- end)
      end
   end
   func()
end

function onSystemMessage(data)
   if data.gameId == GAME_ID then
      table.insert(systemMessageList,data)
      playSystemMessageEffect(true)
   end
end

function onSystemContext(data,type)
   local _data = {}
   _data.text = data
   _data.type = type
   --table.insert(systemMessageList,_data)
   table.insert(systemMessageList,_data)
   -- printTable(systemMessageList)
   playSystemMessageEffect(false)
end

function changeExpressionPanelVisible(flag)
   if flag == true and expScroll == nil then
      initExpression()
   end
   if expScroll then
      expScroll.setTouchEnabled(flag)
   end
   widget.scroll.obj:setTouchEnabled(flag)
   widget.scroll.obj:setVisible(flag)
   widget.scroll_bg.obj:setVisible(flag)
end

function exit()
   if this then
      event.unListen("USER_MESSAGE", onUserMessage)
      event.unListen("SYSTEM_MESSAGE", onSystemMessage)
      event.unListen("SYSTEM_CONTEXT", onSystemContext)
      this:removeFromParentAndCleanup(true)
      this = nil
      parentModule = nil
      tool.cleanWidgetRef(widget)
      expScroll = nil
      expVisible = false
      systemMessageList = {}
      isSystemMessagePlaying = false
      messageList = {}
      textInput = nil
      textRich = nil
      WIDTH = nil
      HEIGHT = nil
      GAME_ID = nil
      inputWidthChange = 0
   end
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
              call("gameChat",str)
              textInput:setText("")
           end)
      end
   end
end

widget = {
   _ignore = true,
   input_bg = {_type = "ImageView"},
   exp_btn = {_type = "Button", _func = onExpression},
   send_btn = {_type = "Button", _func = onSend},
   system_layout = {_type = "Layout"},
   list = {_type = "ListView"},
   scroll = {_type = "ScrollView",
             exp_tmp = {_type = "ImageView",
                        _anchorx = 0,
                        _anchory = 0,
             },
   },
   scroll_bg = {
      _type = "ImageView",
      scroll_bar = {_type = "ImageView"},
   },
}
