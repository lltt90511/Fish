local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"

module("scene.binding", package.seeall)

this = nil
subWidget = nil
local textInput1 = nil
local textInput2 = nil
local sendTimer = nil
local sendNumber = nil
local isRegister = true --true是绑定，flase是解除绑定

function create(parent)
   this = tool.loadWidget("cash/binding",widget,parent,99)
   print("binding create",userdata.UserInfo.phoneNumber)
   if type(userdata.UserInfo.phoneNumber) ==  "userdata" or userdata.UserInfo.phoneNumber == "" then
      initEditBox1()
   else
      initEditBox2()
   end
   event.listen("ON_GET_PHONE",onGetPhoneCodeSucceed)
   event.listen("ON_REGISTER_PHONE",onRegisterPhoneSucceed)
   return this
end

function initEditBox1()
   isRegister = true   
   widget.panel.bg.text_3.obj:setVisible(false) 
   widget.panel.bg.input_3.obj:setVisible(false) 
   widget.panel.bg.label_3.obj:setVisible(false) 
   widget.panel.bg.unRegister.obj:setVisible(false)
   widget.panel.bg.unRegister.obj:setTouchEnabled(false)
   local inputSize1 = widget.panel.bg.input_1.obj:getSize()
   widget.panel.bg.input_1.obj:setSize(CCSize(inputSize1.width,inputSize1.height))
   textInput1 = tolua.cast(CCEditBox:create(CCSizeMake(inputSize1.width-40,inputSize1.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput1 = tolua.cast(TextField:create(),"TextField")
   widget.panel.bg.input_1.obj:addNode(textInput1)
   textInput1:setPosition(ccp(10,-40))
   textInput1:setAnchorPoint(ccp(0,0))
   textInput1:setFontColor(ccc3(255,255,255))
   textInput1:setFontSize(40)
   textInput1:setFontName(DEFAULT_FONT)
   textInput1:setReturnType(1)
   textInput1:setMaxLength(20)
   textInput1:setPlaceHolder("请输入您的手机号码")
   textInput1:setText("")
   -- textInput1:setInputMode(3)
   if type(userdata.UserInfo.phoneTmp) ~= "userdata" then
      textInput1:setText(userdata.UserInfo.phoneTmp)
   end
   textInput1:setVisible(true)

   local function editBoxTextEventHandler1(strEventName, pSender)
      print(textInput1:getText())
      print(strEventName)
      local str = textInput1:getText()
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         if #str > 11 then
            alert.create("手机号码不能大于11位")
            textInput1:setText("")
         else
            textInput1:setText(str)
         end
         -- local i = 1
         -- local cnt = 1
         -- local tb = {}
         -- while i < #str  do
         --    c = str:sub(i,i)
         --    ord = c:byte()
         --    if ord > 128 then
         --       table.insert(tb,str:sub(i,i+2))
         --       i = i+3
         --       cnt = cnt + 2
         --    else
         --       table.insert(tb,c)
         --       i = i+1
         --       cnt = cnt + 1
         --    end
         --    if cnt > 20 then
         --       break
         --    end
         -- end
         -- textInput1:setText(table.concat(tb,"",1,#tb))
      end
   end
   textInput1:registerScriptEditBoxHandler(editBoxTextEventHandler1)
   widget.panel.bg.input_1.obj:setTouchEnabled(true)
   widget.panel.bg.input_1.obj:registerEventScript(function(event)
                                                if event == "releaseUp" then
                                                   textInput1:attachWithIME()
                                                   textInput1:setPosition(ccp(10,-40))
                                                end
   end)

   local inputSize2 = widget.panel.bg.input_2.obj:getSize()
   widget.panel.bg.input_2.obj:setSize(CCSize(inputSize2.width,inputSize2.height))
   textInput2 = tolua.cast(CCEditBox:create(CCSizeMake(inputSize2.width-40,inputSize2.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput2 = tolua.cast(TextField:create(),"TextField")
   widget.panel.bg.input_2.obj:addNode(textInput2)
   textInput2:setPosition(ccp(10,-40))
   textInput2:setAnchorPoint(ccp(0,0))
   textInput2:setFontColor(ccc3(255,255,255))
   textInput2:setFontSize(45)
   textInput2:setFontName(DEFAULT_FONT)
   textInput2:setReturnType(1)
   textInput2:setMaxLength(10)
   textInput2:setPlaceHolder("请输入验证码")
   textInput2:setText("")
   textInput2:setVisible(true)
   -- textInput2:setInputMode(3)

   local function editBoxTextEventHandler2(strEventName, pSender)
      print(textInput2:getText())
      print(strEventName)
      local str = textInput2:getText()
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         if #str > 4 then
            alert.create("验证码不能超过4位")
            textInput2:setText("")
            return
         end
         -- local i = 1
         -- local cnt = 1
         -- local tb = {}
         -- while i < #str  do
         --    c = str:sub(i,i)
         --    ord = c:byte()
         --    if ord > 128 then
         --       table.insert(tb,str:sub(i,i+2))
         --       i = i+3
         --       cnt = cnt + 2
         --    else
         --       table.insert(tb,c)
         --       i = i+1
         --       cnt = cnt + 1
         --    end
         --    if cnt > 20 then
         --       break
         --    end
         -- end
         -- textInput2:setText(table.concat(tb,"",1,#tb))
      end
   end
   textInput2:registerScriptEditBoxHandler(editBoxTextEventHandler2)
   widget.panel.bg.input_2.obj:setTouchEnabled(true)
   widget.panel.bg.input_2.obj:registerEventScript(function(event)
                                                if event == "releaseUp" then
                                                   textInput2:attachWithIME()
                                                   textInput2:setPosition(ccp(10,-40))
                                                end
   end)
end

function initEditBox2()
   isRegister = false
   widget.panel.bg.text_1.obj:setVisible(false) 
   widget.panel.bg.input_1.obj:setVisible(false) 
   widget.panel.bg.input_1.obj:setTouchEnabled(false)
   widget.panel.bg.send.obj:setTouchEnabled(false)
   widget.panel.bg.send.obj:setVisible(false)
   widget.panel.bg.text_2.obj:setVisible(false) 
   widget.panel.bg.input_2.obj:setVisible(false) 
   widget.panel.bg.input_2.obj:setTouchEnabled(false)
   widget.panel.bg.label_1.obj:setVisible(false) 
   widget.panel.bg.label_2.obj:setVisible(false) 
   widget.panel.bg.btn.obj:setVisible(false)
   widget.panel.bg.btn.obj:setTouchEnabled(false)
   widget.panel.bg.btn.obj:setBright(false)

   widget.panel.bg.text_3.obj:setVisible(true) 
   widget.panel.bg.input_3.obj:setVisible(true) 
   widget.panel.bg.input_3.num.obj:setText(userdata.UserInfo.phoneNumber) 
   widget.panel.bg.label_3.obj:setVisible(true) 
   widget.panel.bg.unRegister.obj:setVisible(false)
   widget.panel.bg.unRegister.obj:setTouchEnabled(false)

   -- widget.panel.bg.text_2.obj:setText("请输入解绑验证码：")
   -- widget.panel.bg.text_2.obj:setPositionY(60)
   -- widget.panel.bg.input_2.obj:setPositionY(-30)
   
   -- widget.panel.bg.btn.label.obj:setText("确认解绑")
   -- widget.panel.bg.btn.label_shadow.obj:setText("确认解绑")
   
   -- local inputSize2 = widget.panel.bg.input_2.obj:getSize()
   -- widget.panel.bg.input_2.obj:setSize(CCSize(inputSize2.width,inputSize2.height))
   -- if textInput2 == nil then
   --    textInput2 = tolua.cast(CCEditBox:create(CCSizeMake(inputSize2.width-40,inputSize2.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   --    -- textInput2 = tolua.cast(TextField:create(),"TextField")
   --    widget.panel.bg.input_2.obj:addNode(textInput2)
   -- end
   -- textInput2:setPosition(ccp(10,-40))
   -- textInput2:setAnchorPoint(ccp(0,0))
   -- textInput2:setFontColor(ccc3(255,255,255))
   -- textInput2:setFontSize(40)
   -- textInput2:setFontName(DEFAULT_FONT) 
   -- textInput2:setReturnType(1)
   -- textInput2:setMaxLength(10)
   -- textInput2:setPlaceHolder("请输入验证码")
   -- textInput2:setText("")
   -- textInput2:setVisible(true)
   -- -- textInput2:setInputMode(3)

   -- local function editBoxTextEventHandler2(strEventName, pSender)
   --    print(textInput2:getText())
   --    print(strEventName)
   --    local str = textInput2:getText()
   --    if str == "" then
   --       return 
   --    end
   --    if strEventName == "return" or strEventName == "ended" then
   --       -- local i = 1
   --       -- local cnt = 1
   --       -- local tb = {}
   --       -- while i < #str  do
   --       --    c = str:sub(i,i)
   --       --    ord = c:byte()
   --       --    if ord > 128 then
   --       --       table.insert(tb,str:sub(i,i+2))
   --       --       i = i+3
   --       --       cnt = cnt + 2
   --       --    else
   --       --       table.insert(tb,c)
   --       --       i = i+1
   --       --       cnt = cnt + 1
   --       --    end
   --       --    if cnt > 20 then
   --       --       break
   --       --    end
   --       -- end
   --       -- textInput2:setText(table.concat(tb,"",1,#tb))
   --       if #str > 4 then
   --          alert.create("验证码不能超过4位")
   --          textInput2:setText("")
   --          return
   --       end
   --    end
   -- end
   -- textInput2:registerScriptEditBoxHandler(editBoxTextEventHandler2)
   -- widget.panel.bg.input_2.obj:registerEventScript(function(event)
   --                                              if event == "releaseUp" then
   --                                                 textInput2:attachWithIME()
   --                                                 textInput2:setPosition(ccp(10,-40))
   --                                              end
   -- end)
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_GET_PHONE",onGetPhoneCodeSucceed)
      event.unListen("ON_REGISTER_PHONE",onRegisterPhoneSucceed)
      if sendTimer then
         unSchedule(sendTimer)
         sendTimer = nil
      end
      textInput1 = nil
      textInput2 = nil
      sendNumber = nil
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

function onSend(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if textInput1:getText() == "" then
         alert.create("请输入您的手机号码")
      elseif string.len(textInput1:getText()) ~= 11 then
         alert.create("请输入正确的手机号码")
      else
         call("getPhoneCode",textInput1:getText())
      end
   end
end

function onBinding(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if isRegister == true then
         call("registerPhone",textInput2:getText())
      else
         call("unRegisterPhone",textInput2:getText())
      end
   end
end

function onUnRegister(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      -- onGetPhoneCodeSucceed()
      call("getPhoneCode",userdata.UserInfo.phoneNumber)
   end
end

function onGetPhoneCodeSucceed()
   if isRegister == true then
      sendNumber = textInput1:getText()
      textInput1:setTouchEnabled(false)
      widget.panel.bg.send.obj:setTouchEnabled(false)
      widget.panel.bg.send.obj:setBright(false)
   else
      widget.panel.bg.unRegister.obj:setTouchEnabled(false)
      widget.panel.bg.unRegister.obj:setBright(false)

      widget.panel.bg.btn.obj:setTouchEnabled(true)
      widget.panel.bg.btn.obj:setBright(true)
      widget.panel.bg.input_2.obj:setTouchEnabled(true)
   end
   if sendTimer then
      unSchedule(sendTimer)
      sendTimer = nil
   end
   local time = 5*60
   sendTimer = schedule(
         function()
            if time > 0 then
               time = time - 1
               if isRegister == true then
                  widget.panel.bg.send.label.obj:setText("剩余"..time.."秒")
                  widget.panel.bg.send.label_shadow.obj:setText("剩余"..time.."秒")
               else
                  widget.panel.bg.unRegister.label.obj:setText("剩余"..time.."秒")
                  widget.panel.bg.unRegister.label_shadow.obj:setText("剩余"..time.."秒")
               end
            else
               unSchedule(sendTimer)
               sendTimer = nil
               if isRegister == true then
                   textInput1:setTouchEnabled(true)
                   widget.panel.bg.send.label.obj:setText("发送")
                   widget.panel.bg.send.label_shadow.obj:setText("发送")
                   widget.panel.bg.send.obj:setTouchEnabled(true)
                   widget.panel.bg.send.obj:setBright(true)
               else
                   widget.panel.bg.unRegister.label.obj:setText("发送")
                   widget.panel.bg.unRegister.label_shadow.obj:setText("发送")
                   widget.panel.bg.unRegister.obj:setTouchEnabled(true)
                   widget.panel.bg.unRegister.obj:setBright(true)
               end
            end
         end,1)
end

function onRegisterPhoneSucceed(flag)
   if flag == false then
      tool.createEffect(tool.Effect.delay,{time=0.8},widget.obj,function()
         exit()
      end)
   else
       userdata.UserInfo.phoneNumber = sendNumber
       if sendTimer then
          unSchedule(sendTimer)
          sendTimer = nil
       end
       initEditBox2()
       if textInput1 then
          textInput1:setTouchEnabled(false)
          widget.panel.bg.input_1.obj:setTouchEnabled(false)
       end
       if textInput2 then
          textInput2:setTouchEnabled(false)
          widget.panel.bg.input_2.obj:setTouchEnabled(false)
       end
   end
end

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	title = {_type="ImageView",},
   		  text_1 = {_type = "Label"},
        input_1 = {_type = "ImageView"},
        send = {
           _type = "Button",
           _func = onSend,
           label = {_type = "Label"},
           label_shadow = {_type = "Label"},
        },
   		  text_2 = {_type = "Label"},
        input_2 = {_type = "ImageView"},
        label_1 = {_type = "Label"},
        label_2 = {_type = "Label"},
        btn = {
           _type = "Button",
           _func = onBinding,
           label = {_type = "Label"},
           label_shadow = {_type = "Label"},
        },
        text_3 = {_type = "Label"},
        input_3 = {
           _type = "ImageView",
           num = {_type = "Label"},
        },
        label_3 = {_type = "Label"},
        unRegister = {
           _type = "Button",
           _func = onUnRegister,
           label = {_type = "Label"},
           label_shadow = {_type = "Label"},
        },
  	},
  },
}