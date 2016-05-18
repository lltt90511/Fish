local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
local chatPrivate = require"scene.chatPrivate"

module("scene.chat.main",package.seeall)

this = nil
local thisParent = nil
local messageList = {}
local textInput = nil
local textRich = nil
local expScroll = nil
local expVisible = false
local WIDTH = 0
local GAME_ID = nil
local systemMessageList = {}
local isSystemMessagePlaying = false
local inputWidthChange = 0
local parentModule = nil
local fontHeight = 45
local currentUserPage = 0
local userRankList = {}
local currentTabCnt = 1
local privateNum = 0
local messageCnt1 = 0
local messageCnt2 = 0
local privateCnt = 0
local touchData = {}
-- payServerUrl = payServerUrl
function create(_gameId,_parent,_parentModule)
   this = tool.loadWidget("cash/chat",widget,nil,nil,true)
   thisParent = _parent
   parentModule = _parentModule
   GAME_ID = _gameId
   WIDTH = Screen.width
   currentUserPage = 1
   currentTabCnt = 1
   privateNum = 0
   messageCnt1 = 0
   messageCnt2 = 0
   privateCnt = 0
   messageList = {}
   initEditBox()
   initListView()
   changeExpressionPanelVisible(expVisible)
   resetTab()
   -- event.listen("USER_MESSAGE", onUserMessage)
   -- event.listen("SYSTEM_MESSAGE", onSystemMessage)
   -- event.listen("SYSTEM_CONTEXT", onSystemContext)
   widget.message_bg.listView3.obj:registerEventScript(function(event)
     -- print("event!!!!!!!!!",event)
     if event == "SCROLL_BOTTOM" then
        print("SCROLL_BOTTOM!!!!!!!!!!!!!!!!!!")
        currentUserPage = currentUserPage + 1
        call(6101,currentUserPage)
     end
   end)
   event.listen("ON_SEND_MESSAGE_SUCCEED", onSendMessageSucceed)
   event.listen("ON_SEND_MESSAGE_FAILED", onSendMessageFailed)
   event.listen("ON_GET_MESSAGE", onSendMessageSucceed)
   event.listen("ON_ENTER_GAME_NOTICE", onEnterGameNotice)
   event.listen("ON_EXIT_GAME_NOTICE", onExitGameNotice)
   event.listen("ON_GET_USER_LIST_SUCCEED", onGetUserListSucceed)
   event.listen("ON_GET_USER_LIST_FAILED", onGetUserListFailed)
   call(6101,currentUserPage)
   return this
end

function onEnterGameNotice(_data)
   print("onEnterGameNotice")
   printTable(_data)
   if _data.user._uidx == userdata.UserInfo.uidx then
      return
   end
   if _data.index > #userRankList then
      return
   end
   table.insert(userRankList,_data.index,_data.user)
   addRankItem(_data.user,_data.index)
   widget.tab_bg.tab_3.text.obj:setText("观众("..#userRankList..")")
end

function onExitGameNotice(_data)
   print("onExitGameNotice")
   printTable(_data)
   printTable(userRankList)
   local index = 0
   for k,v in pairs(userRankList) do
       printTable(v)
       if v._uidx == _data.user._uidx then
          break
       end
       print("!!!!!!!!!!!!!!!!!!!",v._uidx,_data.user._uidx,index)
       index = index + 1
   end
   print("index!!!!!!!!!!!!!!!!!!!!!!!!",index,#userRankList)
   if index < #userRankList then
      table.remove(userRankList,index)
      removeRankItem(index)
   end   
end

function onGetUserListSucceed(_data)
   print("onGetUserListSucceed")
   printTable(_data)
   if not _data.users or (_data.users and #_data.users==0) then
      currentUserPage = currentUserPage - 1
      return
   end
   for k,v in pairs(_data.users) do
       table.insert(userRankList,v)
   end
   print("userRankList!!!!!!!!!!!!!!!!!!!!!!!",#userRankList)
   initRankView(_data.users)
   performWithDelay(function()
                    if not this then return end
                    widget.message_bg.listView3.obj:setBounceEnabled(false)
                   -- widget.bottom_bg.rank_list.obj:scrollToBottom(0.5,true)
                    performWithDelay(function()
                                       if not this then return end  
                                          widget.message_bg.listView3.obj:setBounceEnabled(true)
                                       end,0.6)
                                     end,0.15)
   widget.tab_bg.tab_3.text.obj:setText("观众("..#userRankList..")")
end

function onGetUserListFailed(_data)
   
end

function onSendMessageSucceed(gameData)
   local message = {}
   message.from = gameData.from._nickName
   message.fromId = gameData.from._uidx
   if type(gameData.to) == type(-1) and gameData.to == -1 then
      if message.fromId == userdata.UserInfo.uidx then
         message.from = "你"
      end
      message.type = 2
      messageCnt1 = messageCnt1 + 1
   elseif type(gameData.to) == type({}) then
      message.to = gameData.to._nickName
      message.toId = gameData.to._uidx
      if gameData.qiaoqiao > 0 then
         message.type = 5
      elseif gameData.from._uidx == userdata.UserInfo.uidx or gameData.to._uidx == userdata.UserInfo.uidx then
         message.type = 4
      else
         message.type = 3
      end
      if gameData.from._uidx == userdata.UserInfo.uidx then
         message.from = "你"
      elseif gameData.to._uidx == userdata.UserInfo.uidx then
         message.to = "你"
      end
      messageCnt2 = messageCnt2 + 1
      privateCnt = privateCnt + 1
      widget.tab_bg.tab_2.text.obj:setText("私聊".."("..privateCnt..")")
   end
   local str = string.gsub(gameData.con,'(%;22|+)','%"',20)
   message.msg = str
   message.private = gameData.qiaoqiao
   message.time = os.date("*t",tonumber(os.time())/1000)
   addMessage(message)
   if chatPrivate.this then
      chatPrivate.addPrivateMessage(message)
   end
end

function onSendMessageFailed(gameData)
   alert.create(gameData.msg) 
end

function initRankView(_list)
   for k,v in pairs(_list) do   
       addRankItem(v)
   end
end

function addRankItem(item,index)       
   local obj = widget.user.obj:clone()
   obj:setTouchEnabled(true)
   obj:registerEventScript(function(event)
      if event == "releaseUp" then
         chatPrivate.create(thisParent,item._nickName,item._uidx,package.loaded["scene.fishMachine.main"]) 
      end 
   end)
   local head = tool.findChild(obj,"head","ImageView")
   userdata.CharIdToImageFile[item._uidx] = {file=item._picUrl,sex=item._sex}
   tool.getUserImage(eventHash, head, item._uidx)
   -- tool.loadRemoteImage(eventHash, rank_img, userdata.UserInfo.uidx)
   local name = tool.findChild(obj,"name","Label")
   name:setText(item._nickName)
   local vip = tool.findChild(obj,"vip","Label")
   vip:setText("VIP"..item._vip)
   if index and type(index) == type(0) then
      widget.message_bg.listView3.obj:insertCustomItem(obj,index)
   else
      widget.message_bg.listView3.obj:pushBackCustomItem(obj)
   end
end

function removeRankItem(index)
   widget.message_bg.listView3.obj:removeItem(index)
   widget.tab_bg.tab_3.text.obj:setText("观众("..#userRankList..")")
end

function initEditBox()
   local inputSize = widget.input.obj:getSize()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width-60,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput = tolua.cast(TextField:create(),"TextField")
   widget.input.obj:addNode(textInput)
   -- textInput:setPosition(ccp(2,8))
   textInput:setPosition(ccp(30,0))
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
   widget.input.obj:setTouchEnabled(true)
   widget.input.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput:attachWithIME()
                                                   textInput:setPosition(ccp(0,0))
                                                end
   end)
end

function initListView()
   widget.message_bg.listView1.obj:setVisible(true)
   widget.message_bg.listView1.obj:setTouchEnabled(true)
   widget.message_bg.listView1.obj:removeAllItems()
   widget.message_bg.listView2.obj:setVisible(false)
   widget.message_bg.listView2.obj:setTouchEnabled(false)
   widget.message_bg.listView2.obj:removeAllItems()
   widget.message_bg.listView3.obj:setVisible(false)
   widget.message_bg.listView3.obj:setTouchEnabled(false)
   widget.message_bg.listView3.obj:removeAllItems()
end

function initExpression()
   expScroll = scrollList.create(widget.message_bg.scroll.obj,widget.message_bg.scroll_bg.scroll_bar.obj,widget.message_bg.scroll_bg.obj,78,0,true,"",6,package.loaded["scene.chat.main"])
   local render_tmp = widget.message_bg.scroll.exp_tmp.obj
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

function addSplitMessage(richText, msg, cnt)
   print("######addsplitmessage")
   local totalWidth = 0
   local args = {}
   local color = ccc3(255,255,255)
   if msg.type == 1 then
      local textLabel = Label:create()
      textLabel:setText(msg.time.min..":"..msg.time.sec.." "..msg.name.."获得"..msg.money.."金币")
      textLabel:setFontSize(40)
      textLabel:setFontName(DEFAULT_FONT)
      totalWidth = textLabel:getContentSize().width
   else
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
     printTable(args)
     for i = 1, #args do
        local path = isExpression(args[i])
        if path ~= nil then
           print("path!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",path,i)
           local _image = RichElementImage:create(i+cnt, color, 255, "expression/expression_a_0"..path..".png");
           richText:pushBackElement(_image)
           
           totalWidth = totalWidth + 36
        else
           print("not expression!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",i)
           local _msg = RichElementText:create(i+cnt,color,255,args[i],DEFAULT_FONT,40) 
           richText:pushBackElement(_msg)
           
           local msg = Label:create()
           msg:setText(args[i])
           msg:setFontSize(40)
           msg:setFontName(DEFAULT_FONT)
           
           totalWidth = totalWidth + msg:getContentSize().width
        end
     end
   end

   return totalWidth
end

function addSystemMessage(message)
    local textLabel = Label:create()
    textLabel:setText("第【"..message.cnt.."】轮游戏，选中的海洋生物是"..message.inside.."和"..message.outside)
    textLabel:setFontSize(40)
    textLabel:setFontName(DEFAULT_FONT)
    local _richText = RichText:create()
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSize(textLabel:getSize().width,fontHeight))
    local _text1 = RichElementText:create(1,ccc3(255,252,204),255,"第【"..message.cnt.."】轮游戏，选中的海洋生物是",DEFAULT_FONT,40)         
    _richText:pushBackElement(_text1) 
    local _text2 = RichElementText:create(2,ccc3(253,78,62),255,message.inside,DEFAULT_FONT,40)         
    _richText:pushBackElement(_text2) 
    local _text3 = RichElementText:create(3,ccc3(255,252,204),255,"和",DEFAULT_FONT,40)         
    _richText:pushBackElement(_text3) 
    local _text4 = RichElementText:create(4,ccc3(253,78,62),255,message.outside,DEFAULT_FONT,40)         
    _richText:pushBackElement(_text4) 
    _richText:setAnchorPoint(ccp(0,0.5))
    _richText:setPosition(ccp(WIDTH,33))
    widget.system_bg.obj:addChild(_richText)
    tool.createEffect(tool.Effect.move,{time=0.5*(WIDTH/50),x=-WIDTH,y=33},_richText,
          function()
             _richText:removeFromParent()
          end)
end

function addMessage(message, time)
   printTable(message)
   time = time == nil and 0.1 or time
   local list = nil
   local posx = 0
   local func = function()
      if not this then return end
      local _label = Label:create()
      _label:setFontSize(40)
      _label:setFontName(DEFAULT_FONT)
      local layout = Layout:create()
      local _richText = RichText:create()
      _richText:ignoreContentAdaptWithSize(false)
      _richText:setSize(CCSize(WIDTH,fontHeight))
      local num = 1
      local color = ccc3(255,255,255) 
      local nowStr = message.time.min..":"..message.time.sec.." "
      if message.type == 1 then
         local _text1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)
         _richText:pushBackElement(_text1)
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width  
         local _text2 = RichElementText:create(2,ccc3(254,177,23),255,message.name,DEFAULT_FONT,40) 
         _richText:pushBackElement(_text2)   
         _label:setText(message.name)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.id == userdata.UserInfo.uidx then
                    alert.create("您不能与自己私聊!")
                    return
                 end
                 chatPrivate.create(thisParent,message.name,message.id,package.loaded["scene.fishMachine.main"]) 
              end 
         end)
         layout:addChild(_layout)
         local _text3 = RichElementText:create(3,ccc3(255,255,255),255,"获得",DEFAULT_FONT,40)         
         _richText:pushBackElement(_text3)  
         local _text4 = RichElementText:create(4,ccc3(253,78,62),255,message.money.."金币",DEFAULT_FONT,40)         
         _richText:pushBackElement(_text4) 
         list = widget.message_bg.listView1.obj 
         num = 4
      elseif message.type == 2 then
         local _name1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name1) 
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width 
         local _name2 = RichElementText:create(2,ccc3(254,177,23),255,message.from,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name2)   
         _label:setText(message.from)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.fromId == userdata.UserInfo.uidx then
                    alert.create("您不能与自己私聊!")
                    return
                 end
                 chatPrivate.create(thisParent,message.from,message.fromId,package.loaded["scene.fishMachine.main"]) 
              end 
         end)
         layout:addChild(_layout)       
         local _name3 = RichElementText:create(3,ccc3(255,255,255),255,"说：",DEFAULT_FONT,40)         
         _richText:pushBackElement(_name3)
         list = widget.message_bg.listView1.obj 
         num = 3
      elseif message.type == 3 or message.type == 4 or message.type == 5 then
         local say = message.type == 5 and "悄悄对" or "对"
         local _name1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name1) 
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width 
         local _name2 = RichElementText:create(2,ccc3(254,177,23),255,message.from,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name2) 
         _label:setText(message.from)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.fromId == userdata.UserInfo.uidx then
                    alert.create("您不能与自己私聊!")
                    return
                 end
                 chatPrivate.create(thisParent,message.from,message.fromId,package.loaded["scene.fishMachine.main"]) 
              end 
         end)
         layout:addChild(_layout)
         posx = posx + _label:getSize().width 
         local _name3 = RichElementText:create(3,ccc3(255,255,255),255,say,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name3) 
         _label:setText(say)        
         posx = posx + _label:getSize().width 
         local _name4 = RichElementText:create(4,ccc3(254,177,23),255,message.to,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name4) 
         _label:setText(message.to)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.toId == userdata.UserInfo.uidx then
                    alert.create("您不能与自己私聊!")
                    return
                 end
                 chatPrivate.create(thisParent,message.to,message.toId,package.loaded["scene.fishMachine.main"]) 
              end 
         end)
         layout:addChild(_layout) 
         local _name5 = RichElementText:create(5,ccc3(255,255,255),255,"说：",DEFAULT_FONT,40)         
         _richText:pushBackElement(_name5) 
         list = message.type == 3 and widget.message_bg.listView1.obj or widget.message_bg.listView2.obj
         num = 5
      end
        
      local textWidth = addSplitMessage(_richText, message, num)
      print("textWidth=============================================",textWidth)
      if textWidth > WIDTH-10 then     
         _richText:ignoreContentAdaptWithSize(false)
         _richText:setSize(CCSize(WIDTH-10, fontHeight*math.ceil(textWidth/(WIDTH-10))))
      end
      _richText:setAnchorPoint(ccp(0,0))
      _richText:setPosition(ccp(0,0))
      layout:setSize(_richText:getSize())
      layout:addChild(_richText)   
      if message.type >= 4 then
         widget.message_bg.listView2.obj:pushBackCustomItem(layout)
      else
         widget.message_bg.listView1.obj:pushBackCustomItem(layout)
      end
   end
   performWithDelay(func,time)
   performWithDelay(function()    
                       if not this then return end                   
                       list:setBounceEnabled(false)
                       list:scrollToBottom(0.5,true)  
                       performWithDelay(function()
                                           if not this then return end  
                                           list:setBounceEnabled(true)
                                        end,0.6)
                    end,0.15)
end

function onUserMessage(data)
   -- printTable(data)
   table.insert(messageList,data)
   if #messageList >= 50 then
       table.remove(messageList,1)
       widget.list.obj:removeItem(0)
   end
   data.time = os.date("*t",tonumber(os.time())/1000)
   addMessage(data)
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
             widget.system_bg.obj:setVisible(false)
             return
          end
          isSystemMessagePlaying = true
          table.remove(systemMessageList,count)
      -- tool.createEffect(tool.Effect.delay,{time=2.0},widget.system_layout.obj,
      --    function()   
            widget.system_bg.obj:setVisible(true)
            local layout = tool.getRichTextWithColor(data.text,40)   
            layout:setPosition(ccp(WIDTH,0))
            widget.system_bg.obj:addChild(layout)
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
   widget.message_bg.scroll.obj:setTouchEnabled(flag)
   widget.message_bg.scroll.obj:setVisible(flag)
   widget.message_bg.scroll_bg.obj:setVisible(flag)
end

function exit()
   if this then
      event.unListen("ON_SEND_MESSAGE_SUCCEED", onSendMessageSucceed)
      event.unListen("ON_SEND_MESSAGE_FAILED", onSendMessageFailed)
      event.unListen("ON_GET_MESSAGE", onSendMessageSucceed)
      event.unListen("ON_ENTER_GAME_NOTICE", onEnterGameNotice)
      event.unListen("ON_EXIT_GAME_NOTICE", onExitGameNotice)
      event.unListen("ON_GET_USER_LIST_SUCCEED", onGetUserListSucceed)
      event.unListen("ON_GET_USER_LIST_FAILED", onGetUserListFailed)
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
         -- local _msg = http.urlencode(str)
         -- print("_msg",payServerUrl,payServerUrl.."/ydream/login?type=99&param=",_msg)
         -- http.request(payServerUrl.."/ydream/login?type=99&param=".._msg,
         --   function(header,body,flag)
         --     if flag == false then
         --       alert.create("服务器连接失败")
         --       return 
         --     end
         --     local tab = cjson.decode(body)
         --     printTable(tab)
         --     if tab.result == "false" then
         --      alert.create("您输入的内容检测包含屏蔽字")
         --      textInput:setText(tab.param)
         --      return
         --     end
         --      call("gameChat",str)
         --      textInput:setText("")
         --   end)
         local _str = string.gsub(str,'"',';22|',20)
         print("str!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",str,_str)
         call(11001,-1,0,_str)
         textInput:setText("")
      end
   end
end

function onTab1(event)
   if event == "releaseUp" then
      currentTabCnt = 1
      resetTab()
   end
end

function onTab2(event)
   if event == "releaseUp" then
      currentTabCnt = 2
      privateCnt = 0
      widget.tab_bg.tab_2.text.obj:setText("私聊")
      resetTab()
   end
end

function onTab3(event)
   if event == "releaseUp" then
      currentTabCnt = 3
      resetTab()
   end
end

function resetTab()
   -- widget.tab_bg.tab_1.obj:setBright((currentTabCnt==1 and false) or true)
   -- widget.tab_bg.tab_1.obj:setTouchEnabled((currentTabCnt==1 and false) or true)
   -- widget.message_bg.listView1.obj:setVisible((currentTabCnt==1 and true) or false)
   -- widget.message_bg.listView1.obj:setTouchEnabled((currentTabCnt==1 and true) or false)
   -- widget.tab_bg.tab_2.obj:setBright((currentTabCnt==2 and false) or true)
   -- widget.tab_bg.tab_2.obj:setTouchEnabled((currentTabCnt==2 and false) or true)
   -- widget.message_bg.listView2.obj:setVisible((currentTabCnt==2 and true) or false)
   -- widget.message_bg.listView2.obj:setTouchEnabled((currentTabCnt==2 and true) or false)
   -- widget.tab_bg.tab_3.obj:setBright((currentTabCnt==3 and false) or true)
   -- widget.tab_bg.tab_3.obj:setTouchEnabled((currentTabCnt==3 and false) or true)
   -- widget.message_bg.listView3.obj:setVisible((currentTabCnt==3 and true) or false)
   -- widget.message_bg.listView3.obj:setTouchEnabled((currentTabCnt==3 and true) or false)
  if currentTabCnt == 1 then
     resetTab1(false)
     resetTab2(true)
     resetTab3(true)
   elseif currentTabCnt == 2 then
     resetTab1(true)
     resetTab2(false)
     resetTab3(true)
   elseif currentTabCnt == 3 then
     resetTab1(true)
     resetTab2(true)
     resetTab3(false)
   end
end

function resetTab1(flag)
   widget.tab_bg.tab_1.obj:setBright(flag)
   widget.tab_bg.tab_1.obj:setTouchEnabled(flag)
   widget.message_bg.listView1.obj:setVisible(not flag)
   widget.message_bg.listView1.obj:setTouchEnabled(not flag)
end

function resetTab2(flag)
   widget.tab_bg.tab_2.obj:setBright(flag)
   widget.tab_bg.tab_2.obj:setTouchEnabled(flag)
   widget.message_bg.listView2.obj:setVisible(not flag)
   widget.message_bg.listView2.obj:setTouchEnabled(not flag)
end

function resetTab3(flag)
   widget.tab_bg.tab_3.obj:setBright(flag)
   widget.tab_bg.tab_3.obj:setTouchEnabled(flag)
   widget.message_bg.listView3.obj:setVisible(not flag)
   widget.message_bg.listView3.obj:setTouchEnabled(not flag)
end

widget = {
  _ignore = true,
  tab_bg = {
    _type = "ImageView",
    tab_1 = {
      _type = "Button",_func = onTab1,
      text = {_type = "Label"},
    },
    tab_2 = {
      _type = "Button",_func = onTab2,
      text = {_type = "Label"},
    },
    tab_3 = {
      _type = "Button",_func = onTab3,
      text = {_type = "Label"},
    },
  },
  system_bg = {_type = "Layout"},
  message_bg = {
    _type = "Layout",
    listView1 = {_type = "ListView"},
    listView2 = {_type = "ListView"},
    listView3 = {_type = "ListView"},
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
  },
  expression = {_type = "Button",_func = onExpression},
  input = {_type = "ImageView"},
  send = {_type = "Button",_func = onSend},
  user = {
    _type = "Layout",
    head = {_type = "ImageView"},
    name = {_type = "Label"},
    vip = {_type = "Label"},
    line = {_type = "ImageView"},
  },
}
