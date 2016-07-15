local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
local scrollList = require"widget.scrollList"
local chatPrivate = require"scene.chatPrivate"
local userAlert = require"scene.userAlert"

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
local fontHeight = 52
local currentUserPage = 0
local currentUserPageNO = 15
local userRankList = {}
local currentTabCnt = 1
local privateNum = 0
local messageCnt1 = 0
local messageCnt2 = 0
local privateCnt = 0
local userAllCnt = 0
local isPrivate = 0
local targetId = -1
local targetName = ""
local max_list_y = -100
local defultTitleW = 110
local eventHash = {}
local nameType = 0
local targetList = {}

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
   messageList[1] = {}
   messageList[2] = {}
   messageList[3] = {}
   messageList[4] = {}
   widget.input_1.check.obj:setTouchEnabled(false) 
   initEditBox()
   initListView()
   -- changeExpressionPanelVisible(expVisible)
   resetTabStatus()
   resetPanelSay()
   -- print("create!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",widget.message_bg.obj:getPositionY())
   -- printTable(tool.getPosition(widget.message_bg.obj))
   -- widget.message_bg.listView4.obj:registerEventScript(function(event)
   --   -- print("event!!!!!!!!!",event)
   --   if event == "SCROLL_BOTTOM" then
   --      print("SCROLL_BOTTOM!!!!!!!!!!!!!!!!!!")
   --      currentUserPage = currentUserPage + 1
   --      call(6101,currentUserPage)
   --   end
   -- end)
   event.listen("ON_SEND_MESSAGE_SUCCEED", onSendMessageSucceed)
   event.listen("ON_SEND_MESSAGE_FAILED", onSendMessageFailed)
   event.listen("ON_GET_MESSAGE", onSendMessageSucceed)
   event.listen("ON_ENTER_GAME_NOTICE", onEnterGameNotice)
   event.listen("ON_EXIT_GAME_NOTICE", onExitGameNotice)
   event.listen("ON_GET_USER_LIST_SUCCEED", onGetUserListSucceed)
   event.listen("ON_GET_USER_LIST_FAILED", onGetUserListFailed)
   event.listen("ON_SYSTEM_CONTEXT", onSystemContext)
   event.listen("ON_USER_OPERATE_SUCCEED", onUserOperateSucceed)
   event.listen("ON_GET_SYSTEM_MESSAGE", onGetSystemMessage)

   -- call(6101,currentUserPage)
   -- performWithDelay(function()
   --   call(6101,1)
   -- end,2.0)
   call(6101,0)
   return this
end

function onGetSystemMessage(_data)
   local message = {}
   message.type = -3
   message.msg = _data.msg 
   message.time = os.date("*t",tonumber(os.time()))
   addMessage(message,widget.message_bg.listView1.obj)
   addMessage(message,widget.message_bg.listView3.obj)
end

function onUserOperateSucceed(_data)
   local message = {}
   message.type = -2
   message.fromId = _data.fromU._uidx
   message.fromGrade = _data.fromU._uGrade
   message.fromSex = _data.fromU._sex
   message.fromPic = _data.fromU._picUrl
   if _data.fromU._uidx == userdata.UserInfo.uidx then
      message.fromName = "你"
   else
      message.fromName = _data.fromU._nickName
   end 
   message.toId = _data.toU._uidx
   message.toGrade = _data.toU._uGrade
   message.toSex = _data.toU._sex
   message.toPic = _data.toU._picUrl
   if _data.toU._uidx == userdata.UserInfo.uidx then
      message.toName = "你"
   else
      message.toName = _data.toU._nickName
   end 
   message.time = os.date("*t",tonumber(os.time()))
   message.msg = _data.msg
   addMessage(message,widget.message_bg.listView1.obj)
end

function onEnterGameNotice(_data)
   print("onEnterGameNotice")
   if _data.user._uidx == userdata.UserInfo.uidx then
      return
   end
   if _data.index > #userRankList then
      return
   end
   table.insert(userRankList,_data.index+1,_data.user)
   addRankItem(_data.user,_data.index)
   userAllCnt = userAllCnt + 1
   widget.tab_bg.tab_4.text.obj:setText("观众("..userAllCnt..")")
   local message = {}
   message.type = -1
   message.name = _data.user._nickName
   message.id = _data.user._uidx
   message.grade = _data.user._uGrade
   message.pic = _data.user._picUrl
   message.sex = _data.user._sex
   message.time = os.date("*t",tonumber(os.time()))
   setMessage(message,1)
end

function onExitGameNotice(_data)
   print("onExitGameNotice")
   local index = 0
   for k,v in pairs(userRankList) do
       -- printTable(v)
       index = index + 1
       if v._uidx == _data.user._uidx then
          break
       end
       -- print("!!!!!!!!!!!!!!!!!!!",v._uidx,_data.user._uidx,index)
   end
   if index <= #userRankList then
      table.remove(userRankList,index)
      removeRankItem(index-1)
   end   
end

function onGetUserListSucceed(_data)
   print("onGetUserListSucceed")
   -- printTable(_data)
   if not _data.users or (_data.users and #_data.users==0) then
      if currentUserPage > 1 then
         currentUserPage = currentUserPage - 1
      end
      return
   end
   print("userRankList!!!!!!!!!!!!!!!!!!!!!!!",#userRankList)
   userAllCnt = _data.Count
   initRankView(_data.users)
   performWithDelay(function()
                    if not this then return end
                    widget.message_bg.listView4.obj:setBounceEnabled(false)
                   -- widget.bottom_bg.rank_list.obj:scrollToBottom(0.5,true)
                    performWithDelay(function()
                                       if not this then return end  
                                          widget.message_bg.listView4.obj:setBounceEnabled(true)
                                       end,0.6)
                                     end,0.15)
   widget.tab_bg.tab_4.text.obj:setText("观众("..userAllCnt..")")
end

function onGetUserListFailed(_data)
   
end

function onSendMessageSucceed(gameData)
   local message = {}
   message.from = gameData.from._nickName
   message.fromId = gameData.from._uidx
   message.fromGrade = gameData.from._uGrade
   message.fromSex = gameData.from._sex
   message.fromPic = gameData.from._picUrl
   if type(gameData.to) == type(-1) and gameData.to == -1 then
      if message.fromId == userdata.UserInfo.uidx then
         message.from = "你"
      end
      message.type = 2
      messageCnt1 = messageCnt1 + 1
   elseif type(gameData.to) == type({}) then
      message.to = gameData.to._nickName
      message.toId = gameData.to._uidx
      message.toGrade = gameData.to._uGrade
      message.toSex = gameData.to._sex
      message.toPic = gameData.to._picUrl
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
      if currentTabCnt ~= 2 and message.type ~= 3 then
         widget.tab_bg.tab_2.text.obj:setText("私聊".."("..privateCnt..")")
      end
   end
   local str = string.gsub(gameData.con,'(%;22|+)','%"',20)
   message.msg = str
   message.private = gameData.qiaoqiao
   message.time = os.date("*t",tonumber(os.time()))
   if message.type == 2 then
      setMessage(message,1)
   elseif message.type == 3 then
      setMessage(message,1)
   elseif message.type == 4 or message.type == 5 then
      setMessage(message,2)
   end
   if chatPrivate.this then
      chatPrivate.addPrivateMessage(message)
   end
end

function onSendMessageFailed(gameData)
   alert.create(gameData.msg) 
end

function initRankView(_list)
   local cnt = #userRankList
   print("initRankView",cnt)
   for k,v in pairs(_list) do   
       table.insert(userRankList,v)
       addRankItem(v,cnt)
       cnt = cnt + 1
   end
end

function addRankItem(item,index)       
  -- print("addRankItem!!!!!!!!!!!!!!!!!!!!!",index)
   local obj = widget.user.obj:clone()
   obj:setTouchEnabled(true)
   obj:registerEventScript(function(event)
      if event == "releaseUp" then
         if item._uidx == userdata.UserInfo.uidx then
            -- alert.create("您不能与自己私聊")
            return
         end
         local user = {}
         user.grade = item._uGrade
         user.id = item._uidx
         user.name = item._nickName 
         user.sex = item._sex
         user.pic = item._picUrl
         userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
         local container = widget.message_bg.listView4.obj:getInnerContainer()
         local _index = widget.message_bg.listView4.obj:getIndex(obj)
         local offset = container:getSize().height + container:getPositionY() 
         local pos = {x=0,y=0}
         print("addRankItem!!!!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(),offset,_index)
         pos.x = (Screen.width - 540)/2
         pos.y = 110+offset-(_index+1)*120+60
         userAlert.resetAlertPos(pos)
      end 
   end)
   local grade = tool.findChild(obj,"grade","ImageView")
   grade:loadTexture("cash/qietu/user/v"..item._uGrade..".png")
   local name = tool.findChild(obj,"name","Label")
   name:setText(item._nickName)
   local id = tool.findChild(obj,"id","Label")
   id:setText("("..item._uidx..")")
   local head = tool.findChild(obj,"head","ImageView")
   local icon = tool.findChild(head,"icon","ImageView")
   userdata.CharIdToImageFile[item._uidx] = {file=item._picUrl,sex=item._sex}
   tool.getUserImage(eventHash, icon, item._uidx)
   if index and type(index) == type(0) then
      widget.message_bg.listView4.obj:insertCustomItem(obj,index)
   else
      widget.message_bg.listView4.obj:pushBackCustomItem(obj)
   end
end

function removeRankItem(index)
   userAllCnt = userAllCnt - 1
   if userAllCnt < 0 then
      userAllCnt = 0
   end
   widget.message_bg.listView4.obj:removeItem(index)
   widget.tab_bg.tab_4.text.obj:setText("观众("..userAllCnt..")")
end

function initEditBox()
   local inputSize = widget.input_2.obj:getSize()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width-128,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput = tolua.cast(TextField:create(),"TextField")
   widget.input_2.obj:addNode(textInput)
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
      print("editBoxTextEventHandler!!!!!!!!!!!")
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
   widget.input_2.obj:setTouchEnabled(true)
   widget.input_2.obj:registerEventScript(function (event)
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
   widget.message_bg.listView4.obj:setVisible(false)
   widget.message_bg.listView4.obj:setTouchEnabled(false)
   widget.message_bg.listView4.obj:removeAllItems()
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
   -- print("######addsplitmessage")
   local totalWidth = 0
   local args = {}
   local color = ccc3(255,255,255)
   if msg.type == -3 then
      local nowStr = ""
      if msg and msg.time then
         nowStr = string.format("%02d", msg.time.hour)..":"..string.format("%02d", msg.time.min).." "
      end
      local textLabel = Label:create()
      textLabel:setText(nowStr.."系统消息:"..msg.msg)
      textLabel:setFontSize(40)
      textLabel:setFontName(DEFAULT_FONT)
      totalWidth = textLabel:getContentSize().width
   elseif msg.type == -2 then
      local nowStr = ""
      if msg and msg.time then
         nowStr = string.format("%02d", msg.time.hour)..":"..string.format("%02d", msg.time.min).." "
      end
      local textLabel = Label:create()
      textLabel:setText(nowStr..msg.toName.."被"..msg.fromName..msg.msg)
      textLabel:setFontSize(40)
      textLabel:setFontName(DEFAULT_FONT)
      totalWidth = textLabel:getContentSize().width
   elseif msg.type == -1 then
      local nowStr = ""
      if msg and msg.time then
         nowStr = string.format("%02d", msg.time.hour)..":"..string.format("%02d", msg.time.min).." "
      end
      local textLabel = Label:create()
      textLabel:setFontSize(40)
      textLabel:setFontName(DEFAULT_FONT)
      if msg.grade < 11 then
         textLabel:setText(nowStr.."欢迎"..msg.name.."进入房间")
      elseif msg.grade < 17 then
         textLabel:setText(nowStr.."欢迎"..msg.name.."莅临指导")
      elseif msg.grade < 25 then
         textLabel:setText(nowStr.."热烈欢迎"..msg.name.."屈尊降临")
      elseif msg.grade < 27 then
         textLabel:setText(nowStr.."全体起立，恭候"..msg.name.."大驾光临")
      elseif msg.grade == 27 then
         textLabel:setText(nowStr.."全体起立，恭候"..msg.name.."创世之神降临凡间")
      elseif msg.grade == 28 then
         textLabel:setText(nowStr.."全体起立，恭候"..msg.name.."宇宙霸主降临凡间")
      end
      totalWidth = textLabel:getContentSize().width
      totalWidth = totalWidth + defultTitleW
   elseif msg.type == 0 then
      local nowStr = ""
      if msg and msg.time then
         nowStr = string.format("%02d", msg.time.hour)..":"..string.format("%02d", msg.time.min).." "
      end
      local textLabel = Label:create()
      textLabel:setText(nowStr.."第【"..msg.cnt.."】轮游戏，选中的海洋生物是"..msg.inside.."和"..msg.outside)
      textLabel:setFontSize(40)
      textLabel:setFontName(DEFAULT_FONT)
      totalWidth = textLabel:getContentSize().width
   elseif msg.type == 1 then
   else
       local nowStr = ""
       if msg and msg.time then
          nowStr = string.format("%02d", msg.time.hour)..":"..string.format("%02d", msg.time.min).." "
       end
       if msg.type == 2 then
          local textLabel = Label:create()
          textLabel:setText(nowStr..msg.from.."说："..msg.msg)
          textLabel:setFontSize(40)
          textLabel:setFontName(DEFAULT_FONT)
          totalWidth = textLabel:getContentSize().width
       elseif msg.type == 3 or msg.type == 4  then 
          local textLabel = Label:create()
          textLabel:setText(nowStr..msg.from.."对"..msg.to.."说："..msg.msg)
          textLabel:setFontSize(40)
          textLabel:setFontName(DEFAULT_FONT)
          totalWidth = textLabel:getContentSize().width
       elseif msg.type == 5 then 
          local textLabel = Label:create()
          textLabel:setText(nowStr..msg.from.."悄悄对"..msg.to.."说："..msg.msg)
          textLabel:setFontSize(40)
          textLabel:setFontName(DEFAULT_FONT)
          totalWidth = textLabel:getContentSize().width
       end
       if msg.fromGrade then
          totalWidth = totalWidth + defultTitleW
       end
       if msg.toGrade then
          totalWidth = totalWidth + defultTitleW
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
    _richText:setSize(CCSize(textLabel:getSize().width,52))
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

function addMessage(message, list, time)
   -- printTable(message)
   time = time == nil and 0.1 or time
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
      local nowStr = ""
      if message and message.time then
         nowStr = string.format("%02d", message.time.hour)..":"..string.format("%02d", message.time.min).." "
      end
      if message.type == -3 then
         local _text1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)
         _richText:pushBackElement(_text1)  
         local _text2 = RichElementText:create(2,ccc3(255,0,0),255,"系统消息:"..message.msg,DEFAULT_FONT,40)
         _richText:pushBackElement(_text2)
         num = 2
      elseif message.type == -2 then
         local _text1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)
         _richText:pushBackElement(_text1)
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width 
         local _image1 = RichElementImage:create(2, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.toGrade..".png");
         _richText:pushBackElement(_image1)
         posx = posx + defultTitleW
         local _text2 = RichElementText:create(3,ccc3(254,177,23),255,message.toName,DEFAULT_FONT,40)         
         _richText:pushBackElement(_text2) 
         _label:setText(message.toName)
         local x = posx
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
            if event == "releaseUp" then
               if message.toId == userdata.UserInfo.uidx then
                  -- alert.create("您不能与自己私聊!")
                  return
               end
               local user = {}
               user.grade = message.toGrade
               user.id = message.toId
               user.name = message.toName 
               user.sex = message.toSex
               user.pic = message.toPic
               userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
               local container = list:getInnerContainer()
               local _index = list:getIndex(layout)
               local offset = layout:getPositionY() + container:getPositionY()
               local pos = {x=0,y=0}
               print("offset!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(), layout:getPositionY())
               pos.x = x+_layout:getSize().width/2
               pos.y = 126+offset
               userAlert.resetAlertPos(pos)
            end 
          end)
         layout:addChild(_layout)
         posx = posx + _label:getSize().width 
         local _text3 = RichElementText:create(4,ccc3(255,255,255),255,"被",DEFAULT_FONT,40)         
         _richText:pushBackElement(_text3) 
         _label:setText("被")    
         posx = posx + _label:getSize().width 
         local _image2 = RichElementImage:create(5, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.fromGrade..".png");
         _richText:pushBackElement(_image2)
         posx = posx + defultTitleW
         local _text4 = RichElementText:create(6,ccc3(254,177,23),255,message.fromName,DEFAULT_FONT,40)         
         _richText:pushBackElement(_text4)
         _label:setText(message.fromName)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
            if event == "releaseUp" then
               if message.id == userdata.UserInfo.uidx then
                  -- alert.create("您不能与自己私聊!")
                  return
               end
               local user = {}
               user.grade = message.fromGrade
               user.id = message.fromId
               user.name = message.fromName 
               user.sex = message.fromSex
               user.pic = message.fromPic
               userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
               local container = list:getInnerContainer()
               local _index = list:getIndex(layout)
               local offset = layout:getPositionY() + container:getPositionY()
               local pos = {x=0,y=0}
               print("offset!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(), layout:getPositionY())
               pos.x = posx+_layout:getSize().width/2
               pos.y = 126+offset
               userAlert.resetAlertPos(pos)
            end 
          end)
         layout:addChild(_layout)
         local _text5 = RichElementText:create(7,ccc3(255,255,255),255,message.msg,DEFAULT_FONT,40)         
         _richText:pushBackElement(_text5)  
         num = 7
      elseif message.type == -1 then
         local _welcome = ""
         local _room = ""
         if message.grade < 11 then
            _welcome = "欢迎"
            _room = "进入房间"
         elseif message.grade < 17 then
            _welcome = "欢迎"
            _room = "莅临指导"
         elseif message.grade < 25 then
            _welcome = "热烈欢迎"
            _room = "屈尊降临"
         elseif message.grade < 27 then
            _welcome = "全体起立，恭候"
            _room = "大驾光临"
         elseif message.grade == 27 then
            _welcome = "全体起立，恭候"
            _room = "创世之神降临凡间"
         elseif message.grade == 28 then
            _welcome = "全体起立，恭候"
            _room = "宇宙霸主降临凡间"
         end
        local _text1 = RichElementText:create(1,ccc3(255,252,204),255,nowStr,DEFAULT_FONT,40)         
        _richText:pushBackElement(_text1) 
        _label:setText(nowStr)        
        posx = posx + _label:getSize().width
        local _text2 = RichElementText:create(2,ccc3(255,252,204),255,_welcome,DEFAULT_FONT,40)         
        _richText:pushBackElement(_text2) 
        _label:setText(_welcome)        
        posx = posx + _label:getSize().width 
        local _image = RichElementImage:create(3, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.grade..".png");
        _richText:pushBackElement(_image)
        posx = posx + defultTitleW
        local _text3 = RichElementText:create(4,ccc3(253,78,62),255,message.name,DEFAULT_FONT,40)         
        _richText:pushBackElement(_text3) 
        _label:setText(message.name)
        local _layout = Layout:create()
        _layout:setSize(CCSize(_label:getSize().width,fontHeight))
        _layout:setPosition(ccp(posx,0))       
        _layout:setTouchEnabled(true)
        _layout:registerEventScript(function(event)
            if event == "releaseUp" then
               if message.id == userdata.UserInfo.uidx then
                  -- alert.create("您不能与自己私聊!")
                  return
               end
               local user = {}
               user.grade = message.grade
               user.id = message.id
               user.name = message.name 
               user.sex = message.sex
               user.pic = message.pic
               userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
               local container = list:getInnerContainer()
               local _index = list:getIndex(layout)
               local offset = layout:getPositionY() + container:getPositionY()
               local pos = {x=0,y=0}
               print("offset!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(), layout:getPositionY())
               pos.x = posx+_layout:getSize().width/2
               pos.y = 126+offset
               userAlert.resetAlertPos(pos)
            end 
          end)
        layout:addChild(_layout)
        local _text4 = RichElementText:create(5,ccc3(255,252,204),255,_room,DEFAULT_FONT,40)         
        _richText:pushBackElement(_text4) 
        num = 5
      elseif message.type == 0 then
          local _text1 = RichElementText:create(1,ccc3 (255,255,255),255,nowStr,DEFAULT_FONT,40)
          _richText:pushBackElement(_text1)
          local _text2 = RichElementText:create(2,ccc3(255,252,204),255,"第【"..message.cnt.."】轮游戏，选中的海洋生物是",DEFAULT_FONT,40)         
          _richText:pushBackElement(_text2) 
          local _text3 = RichElementText:create(3,ccc3(253,78,62),255,message.inside,DEFAULT_FONT,40)         
          _richText:pushBackElement(_text3) 
          local _text4 = RichElementText:create(4,ccc3(255,252,204),255,"和",DEFAULT_FONT,40)         
          _richText:pushBackElement(_text4) 
          local _text5 = RichElementText:create(5,ccc3(253,78,62),255,message.outside,DEFAULT_FONT,40)         
          _richText:pushBackElement(_text5) 
          num = 5
      elseif message.type == 1 then
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
         -- _layout:setTouchEnabled(true)
         -- _layout:registerEventScript(function(event)
         --      if event == "releaseUp" then
         --         if message.id == userdata.UserInfo.uidx then
         --            alert.create("您不能与自己私聊!")
         --            return
         --         end
         --         userAlert.create(thisParent,message.grade,message.id,message.name) 
         --      end 
         -- end)
         layout:addChild(_layout)
         local _text3 = RichElementText:create(3,ccc3(255,255,255),255,"获得",DEFAULT_FONT,40)         
         _richText:pushBackElement(_text3)  
         local _text4 = RichElementText:create(4,ccc3(253,78,62),255,message.msg,DEFAULT_FONT,40)         
         _richText:pushBackElement(_text4) 
         local _text5 = RichElementText:create(5,ccc3(255,255,255),255,"点游戏豆",DEFAULT_FONT,40)         
         _richText:pushBackElement(_text5) 
         num = 5
      elseif message.type == 2 then
         local _name1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name1) 
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width 
         local _image = RichElementImage:create(2, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.fromGrade..".png");
         _richText:pushBackElement(_image) 
         posx = posx + defultTitleW
         local _name2 = RichElementText:create(3,ccc3(254,177,23),255,message.from,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name2)   
         _label:setText(message.from)
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.fromId == userdata.UserInfo.uidx then
                    -- alert.create("您不能与自己私聊!")
                    return
                 end
                 local user = {}
                 user.grade = message.fromGrade
                 user.id = message.fromId
                 user.name = message.from 
                 user.sex = message.fromSex
                 user.pic = message.fromPic
                 userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
                 local container = list:getInnerContainer()
                 local _index = list:getIndex(layout)
                 local offset = layout:getPositionY() + container:getPositionY()
                 local pos = {x=0,y=0}
                 pos.x = posx+_layout:getSize().width/2
                 pos.y = 126+offset
                 userAlert.resetAlertPos(pos)
              end 
         end)
         layout:addChild(_layout)       
         local _name3 = RichElementText:create(4,ccc3(255,255,255),255,"说："..message.msg,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name3)
         num = 4
      elseif message.type == 3 or message.type == 4 or message.type == 5 then
         local say = message.type == 5 and "悄悄对" or "对"
         local _name1 = RichElementText:create(1,ccc3(255,255,255),255,nowStr,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name1) 
         _label:setText(nowStr)        
         posx = posx + _label:getSize().width 
         local _image1 = RichElementImage:create(2, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.fromGrade..".png");
         _richText:pushBackElement(_image1) 
         posx = posx + defultTitleW
         local _name2 = RichElementText:create(3,ccc3(254,177,23),255,message.from,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name2) 
         _label:setText(message.from)
         local x = posx
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.fromId == userdata.UserInfo.uidx then
                    -- alert.create("您不能与自己私聊!")
                    return
                 end
                 local user = {}
                 user.grade = message.fromGrade
                 user.id = message.fromId
                 user.name = message.from 
                 user.sex = message.fromSex
                 user.pic = message.fromPic
                 userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
                 local container = list:getInnerContainer()
                 local _index = list:getIndex(layout)
                 local offset = layout:getPositionY() + container:getPositionY()
                 local pos = {x=0,y=0}
                 print("offset!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(), layout:getPositionY())
                 pos.x = x+_layout:getSize().width/2
                 pos.y = 126+offset
                 userAlert.resetAlertPos(pos)
              end 
         end)
         layout:addChild(_layout)
         posx = posx + _label:getSize().width 
         local _name3 = RichElementText:create(4,ccc3(255,255,255),255,say,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name3) 
         _label:setText(say)        
         posx = posx + _label:getSize().width 
         local _image2 = RichElementImage:create(5, ccc3(255,255,255), 255, "cash/qietu/user/v"..message.toGrade..".png");
         _richText:pushBackElement(_image2) 
         posx = posx + defultTitleW
         local _name4 = RichElementText:create(6,ccc3(254,177,23),255,message.to,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name4) 
         _label:setText(message.to)
         local x = posx
         local _layout = Layout:create()
         _layout:setSize(CCSize(_label:getSize().width,fontHeight))
         _layout:setPosition(ccp(posx,0))       
         _layout:setTouchEnabled(true)
         _layout:registerEventScript(function(event)
              if event == "releaseUp" then
                 if message.toId == userdata.UserInfo.uidx then
                    -- alert.create("您不能与自己私聊!")
                    return
                 end
                 local user = {}
                 user.grade = message.toGrade
                 user.id = message.toId
                 user.name = message.to 
                 user.sex = message.toSex
                 user.pic = message.toPic
                 userAlert.create(thisParent,user,package.loaded["scene.chat.main"]) 
                 local container = list:getInnerContainer()
                 local _index = list:getIndex(layout)
                 local offset = layout:getPositionY() + container:getPositionY()
                 local pos = {x=0,y=0}
                 print("offset!!!!!!!!!!!!!!!!!!!!",container:getSize().height,container:getPositionY(), layout:getPositionY())
                 pos.x = x+_layout:getSize().width/2
                 pos.y = 126+offset
                 userAlert.resetAlertPos(pos)
              end 
         end)
         layout:addChild(_layout) 
         local _name5 = RichElementText:create(7,ccc3(255,255,255),255,"说："..message.msg,DEFAULT_FONT,40)         
         _richText:pushBackElement(_name5) 
         num = 7
      end
        
      local textWidth = addSplitMessage(_richText, message, num)
      -- print("textWidth=============================================",textWidth, WIDTH-52)
      if textWidth > WIDTH-52 then     
         _richText:ignoreContentAdaptWithSize(false)
         _richText:setSize(CCSize(WIDTH-52, fontHeight*math.ceil(textWidth/(WIDTH-52))))
      end
      _richText:setAnchorPoint(ccp(0,0))
      _richText:setPosition(ccp(10,0))
      layout:setSize(_richText:getSize())
      layout:addChild(_richText)   
      -- print("addMessage!!!!!!!!!!!!!!!!!!!!!!!!!!!!",message.type)
      list:pushBackCustomItem(layout)
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
   func()
   -- performWithDelay(func,time)
end

function setMessage(message,id)
   local list = widget.message_bg["listView"..id].obj
   table.insert(messageList[id],message)
   if #messageList[id] >= 50 then
      table.remove(messageList[id],1)
      list:removeItem(0)
   end
   addMessage(message,list)
end

function playSystemMessageEffect()
   -- print("playSystemMessageEffect",userdata.isInGame)
   if isSystemMessagePlaying == true then
      return
   end
   local func = nil
   func = function()
      if userdata.isInGame == true then
         tool.createEffect(tool.Effect.delay,{time=1.0},widget.obj,function()
            func()
         end)
      else
          if type(systemMessageList) == type({}) and #systemMessageList == 0 then
             isSystemMessagePlaying = false
             return
          end
          isSystemMessagePlaying = true
          local data = table.remove(systemMessageList,1)
          local layout = Layout:create()
          local richText = RichText:create()
         local _text1 = RichElementText:create(1,ccc3(254,177,23),255,data.name,DEFAULT_FONT,40) 
         richText:pushBackElement(_text1)     
         local _text2 = RichElementText:create(2,ccc3(255,255,255),255,"获得",DEFAULT_FONT,40)         
         richText:pushBackElement(_text2)  
         -- local msg = getWinStr(data.money)
         local _text3 = RichElementText:create(3,ccc3(253,78,62),255,tostring(data.money),DEFAULT_FONT,40)         
         richText:pushBackElement(_text3)  
         local _text4 = RichElementText:create(4,ccc3(255,255,255),255,"点游戏豆",DEFAULT_FONT,40)         
         richText:pushBackElement(_text4)  
         local label = Label:create()
         label:setText(data.name.."获得"..tostring(data.money).."点游戏豆")
         label:setFontSize(40)
         label:setFontName(DEFAULT_FONT) 
         richText:ignoreContentAdaptWithSize(false)
         richText:setSize(CCSize(label:getSize().width+5,label:getSize().height))
         richText:setAnchorPoint(ccp(0,0))
         richText:setPosition(ccp(0,0))
         layout:setSize(CCSize(label:getSize().width,label:getSize().height))
         layout:addChild(richText)
         layout:setPosition(ccp(widget.system_bg.obj:getSize().width,(66-label:getSize().height)/2))
          widget.system_bg.obj:addChild(layout)
          local size = layout:getSize()  
          tool.createEffect(tool.Effect.move,{time=0.5*(size.width/50),x=-size.width,y=0},layout,
              function()
                 layout:removeFromParent()
                 func()
              end)
      end
   end
   func()
end

function onSystemContext(data)
   print("onSystemContext")
   -- printTable(data)
   for k,v in pairs(data.msg) do
       table.insert(systemMessageList,v) 
   end
   -- table.insert(systemMessageList,data)
   -- printTable(systemMessageList)
   playSystemMessageEffect()
end

function getWinStr(money)
    local str = ""
    local car = math.floor(money/100000)
    local shoe = math.floor((money%100000)/10000)
    local origami = math.floor(((money%100000)%10000)/1000)
    local flower = math.floor((((money%100000)%10000)%1000)/100)
    if car > 0 then
       str = str..car.."辆兰博基尼"
    end
    if shoe > 0 then
      str = str..shoe.."双水晶鞋"
    end
    if origami > 0 then
      str = str..origami.."只千纸鹤"
    end
    if flower > 0 then
      str = str..flower.."朵玫瑰"
    end
    return str
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

function resetPanelSay()
    widget.input_1.say.text.obj:setText("所有人")
    widget.input_1.say.obj:registerEventScript(function(event)
        if #targetList == 0 then
           return
        end
        tool.buttonSound("releaseUp","effect_12")
        local posY = widget.panel_say.bg.obj:getPositionY()
        if posY == max_list_y then
           tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.panel_say.bg.obj)
        elseif posY == 0 then
           tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.panel_say.bg.obj)
        end
    end)
    widget.panel_say.bg.obj:setPosition(ccp(widget.panel_say.bg.obj:getPositionX(),max_list_y))
    widget.panel_say.bg.label_1.obj:setTouchEnabled(true)
    widget.panel_say.bg.label_1.obj:registerEventScript(function(event)
       targetId = -1
       targetName = "" 
       nameType = 0
       isPrivate = 0
       widget.input_1.check.obj:setTouchEnabled(false) 
       if widget.input_1.check.obj:getSelectedState() == true then
          widget.input_1.check.obj:setSelectedState(false) 
       end
       widget.input_1.say.text.obj:setText("所有人")
       local posY = widget.panel_say.bg.obj:getPositionY()
       if posY == 0 then
          tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.panel_say.bg.obj)
       end
    end)
    setSayList()
end

function setSayList()
   max_list_y = -100    
   for i=1,5 do
       if targetList[i] then
          max_list_y = max_list_y - 80
          widget.panel_say.bg["line_"..i].obj:setVisible(true)
          widget.panel_say.bg["label_"..i+1].obj:setVisible(true)
          widget.panel_say.bg["label_"..i+1].obj:setText(targetList[i].name)
          widget.panel_say.bg["label_"..i+1].obj:setTouchEnabled(true)
          widget.panel_say.bg["label_"..i+1].obj:registerEventScript(function(event)
             targetId = targetList[i].id
             targetName = targetList[i].name 
             nameType = 1
             widget.input_1.check.obj:setTouchEnabled(true) 
             widget.input_1.say.text.obj:setText(targetName)
             local posY = widget.panel_say.bg.obj:getPositionY()
             if posY == 0 then
                tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=max_list_y,easeIn=true},widget.panel_say.bg.obj)
             end
          end)
       else
          widget.panel_say.bg["line_"..i].obj:setVisible(false)
          widget.panel_say.bg["label_"..i+1].obj:setVisible(false)
       end
   end
   widget.panel_say.bg.obj:setSize(CCSize(390,-max_list_y))
   widget.panel_say.bg.obj:setPosition(ccp(0,max_list_y))
end

function setPanelSay(_id,_name,_private)
    nameType = 1
    local isIn = false
    for k,v in pairs(targetList) do
        if v.id == _id and v.name == _name then
           isIn = true
        end
    end
    if not isIn then
       local _t = {}
       _t.id = _id
       _t.name = _name
       table.insert(targetList,_t)
       if #targetList > 5 then
          table.remove(targetList,1)
       end
       setSayList()
    end
    targetId = _id
    targetName = _name
    isPrivate = _private
    widget.input_1.say.text.obj:setText(_name)
    -- widget.panel_say.bg.label_1.obj:setText(targetName)
    widget.input_1.check.obj:setTouchEnabled(true)
    if isPrivate == 1 then
       widget.input_1.check.obj:setSelectedState(true)
    elseif isPrivate == 0 then
       widget.input_1.check.obj:setSelectedState(false)
    end
end

function cleanEvent()
   for k, v in pairs(eventHash) do
      event.unListen(k)
   end
   eventHash = {}
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
      event.unListen("ON_SYSTEM_CONTEXT", onSystemContext)
      event.unListen("ON_USER_OPERATE_SUCCEED", onUserOperateSucceed)
      event.unListen("ON_GET_SYSTEM_MESSAGE", onGetSystemMessage)
      cleanEvent()
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
      WIDTH = 0
      GAME_ID = nil
      inputWidthChange = 0
      userRankList = {}
      messageList = {}
      currentUserPage = 0
      currentTabCnt = 1
      privateNum = 0
      messageCnt1 = 0
      messageCnt2 = 0
      privateCnt = 0
      userAllCnt = 0
      isPrivate = 0
      targetId = -1
      targetName = ""
      max_list_y = -100
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
         -- print("str!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",str,_str)
         if nameType == 0 then
            call(11001,-1,isPrivate,_str)
         elseif nameType == 1 then
            call(11001,targetId,isPrivate,_str)
         end
         textInput:setText("")
      end
   end
end

function onTab1(event)
   if event == "releaseUp" then
      currentTabCnt = 1
      resetTabStatus()
   end
end

function onTab2(event)
   if event == "releaseUp" then
      currentTabCnt = 2
      privateCnt = 0
      widget.tab_bg.tab_2.text.obj:setText("私聊")
      resetTabStatus()
   end
end

function onTab3(event)
   if event == "releaseUp" then
      currentTabCnt = 3
      resetTabStatus()
   end
end

function onTab4(event)
   if event == "releaseUp" then
      currentTabCnt = 4
      resetTabStatus()
   end
end

function resetTabStatus()
   resetTab(1)
   resetTab(2)
   resetTab(3)
   resetTab(4)
   resetListOrder()
end

function resetTab(tag)
   local flag = true
   if tag == currentTabCnt then
      flag = false
   end
   print("resetTab!!!!!!!!!!!!!!",tag,currentTabCnt,flag)
   widget.tab_bg["tab_"..tag].obj:setBright(flag)
   widget.tab_bg["tab_"..tag].obj:setTouchEnabled(flag)
   widget.message_bg["listView"..tag].obj:setVisible(not flag)
   widget.message_bg["listView"..tag].obj:setTouchEnabled(not flag)
end

function resetListOrder()
   for i=1,4 do
       if i == currentTabCnt then
          widget.message_bg["listView"..i].obj:setZOrder(10)
        else
          widget.message_bg["listView"..i].obj:setZOrder(0)
       end
   end   
end

function onCheck(event,data1,data)
   if event == "releaseUp" then
      if nameType == 0 then
         return
      end
      tool.buttonSound("releaseUp","effect_12")
      data = tolua.cast(data,"CheckBox")
      local p = data:getSelectedState()
      p = not p
      isPrivate = p and 1 or 0
      -- data:setSelectedState(isPrivate)
   end
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
    tab_4 = {
      _type = "Button",_func = onTab4,
      text = {_type = "Label"},
    },
  },
  system_bg = {_type = "Layout"},
  message_bg = {
    _type = "Layout",
    listView1 = {_type = "ListView"},
    listView2 = {_type = "ListView"},
    listView3 = {_type = "ListView"},
    listView4 = {_type = "ListView"},
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
  input_1 = {
    _type = "ImageView",
    say = {
      _type = "Layout",
      text = {_type = "Label"},
    },
    check = {_type = "CheckBox",_func = onCheck},
    text = {_type = "Label"},
  },
  input_2 = {
    _type = "ImageView",
    send = {_type = "Button",_func = onSend},
  },
  user = {
    _type = "Layout",
    grade = {_type = "ImageView"},
    name = {_type = "Label"},
    id = {_type = "Label"},
    line = {_type = "Layout"},
    head = {
      _type = "ImageView",
      icon = {_type = "ImageView"},
    },
  },
  panel_say = {
    _type = "Layout",
    bg = {
      _type = "Layout",
      label_1 = {_type = "Label"},
      label_2 = {_type = "Label"},
      label_3 = {_type = "Label"},
      label_4 = {_type = "Label"},
      label_5 = {_type = "Label"},
      label_6 = {_type = "Label"},
      line_1 = {_type = "Layout"},
      line_2 = {_type = "Layout"},
      line_3 = {_type = "Layout"},
      line_4 = {_type = "Layout"},
      line_5 = {_type = "Layout"},
    },
  },
}
