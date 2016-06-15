local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.chargeAlert", package.seeall)

this = nil
thisParent = nil
local chargeListIOS = {6,12,30,60,118,298}
local chargeListANDROID = {10,50,100,200,500,1000}
local chargeNum = 0
local textInput1 = nil
local textInput2 = nil
local recommendId = 0
local alertType = 0
local chargeType = 0 --1 ios 2 aibei
function create(_parent,_type)
   thisParent = _parent
   alertType = _type
   this = tool.loadWidget("cash/chargeAlert",widget,thisParent,15)
   widget.alert.bar_1.text_1.bg.text.obj:setText(userdata.UserInfo.nickName)
   -- initView()
   initInput()
   onChangeGold()
   chargeType = 1
   if alertType == 2 then
      widget.bg.obj:setVisible(false)
      widget.obj:registerEventScript(onBack)
   end
   if platform == "IOS" then
      chargeNum = chargeListIOS[1]
      if userdata.UserInfo.aip == 0 then
         widget.alert.obj:setSize(CCSize(widget.alert.obj:getSize().width,1025))
         widget.alert.confirm.obj:setPosition(ccp(0,-955))
         widget.alert.bar_3.obj:setPosition(ccp(0,widget.alert.bar_2.obj:getPositionY()))
         widget.alert.ios.obj:setVisible(false)
         widget.alert.ios.obj:setTouchEnabled(false)
         widget.alert.aibei.obj:setVisible(false)
         widget.alert.aibei.obj:setTouchEnabled(false)
      else
         widget.alert.obj:setSize(CCSize(widget.alert.obj:getSize().width,1115))
         widget.alert.confirm.obj:setPosition(ccp(0,-1045))
         widget.alert.bar_2.obj:setPosition(ccp(0,widget.alert.bar_3.obj:getPositionY()))
         widget.alert.ios.obj:setBright(false)
         widget.alert.ios.obj:setVisible(true)
         widget.alert.ios.obj:setTouchEnabled(false)
         widget.alert.aibei.obj:setVisible(true)
         widget.alert.aibei.obj:setTouchEnabled(true)
      end
      widget.alert.bar_2.obj:setVisible(false)
      widget.alert.bar_3.obj:setVisible(true)
      for i=1,6 do
          widget.alert.bar_2["btn_"..i].obj:setTouchEnabled(false)
          widget.alert.bar_2["btn_"..i].text.obj:setText(chargeListANDROID[i].."元")
          widget.alert.bar_2["btn_"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 tool.buttonSound("releaseUp","effect_12")
                 chargeNum = chargeListANDROID[i]
                 for j=1,6 do
                     if i == j then
                         widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(false)
                         widget.alert.bar_2["btn_"..j].obj:setBright(false)
                         widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(5,3,0))
                     else
                         widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(true)
                         widget.alert.bar_2["btn_"..j].obj:setBright(true)
                         widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(254,177,23))
                     end
                 end
              end
           end)
          widget.alert.bar_3["btn_"..i].text.obj:setText(chargeListIOS[i].."元")
          widget.alert.bar_3["btn_"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 tool.buttonSound("releaseUp","effect_12")
                 chargeNum = chargeListIOS[i]
                 for j=1,6 do
                     if i == j then
                         widget.alert.bar_3["btn_"..j].obj:setTouchEnabled(false)
                         widget.alert.bar_3["btn_"..j].obj:setBright(false)
                         widget.alert.bar_3["btn_"..j].text.obj:setColor(ccc3(5,3,0))
                     else
                         widget.alert.bar_3["btn_"..j].obj:setTouchEnabled(true)
                         widget.alert.bar_3["btn_"..j].obj:setBright(true)
                         widget.alert.bar_3["btn_"..j].text.obj:setColor(ccc3(254,177,23))
                     end
                 end
              end
           end)
      end
      widget.alert.bar_3.btn_1.obj:setTouchEnabled(false)
      widget.alert.bar_3.btn_1.obj:setBright(false)
      widget.alert.bar_3.btn_1.text.obj:setColor(ccc3(5,3,0))
   else
      chargeNum = chargeListANDROID[1]
      widget.alert.obj:setSize(CCSize(widget.alert.obj:getSize().width,1025))
      widget.alert.confirm.obj:setPosition(ccp(0,-955))
      widget.alert.ios.obj:setVisible(false)
      widget.alert.ios.obj:setTouchEnabled(false)
      widget.alert.aibei.obj:setVisible(false)
      widget.alert.aibei.obj:setTouchEnabled(false)
      widget.alert.bar_2.obj:setVisible(true)
      widget.alert.bar_3.obj:setVisible(false)
      for i=1,6 do
          widget.alert.bar_3["btn_"..i].obj:setTouchEnabled(false)
           widget.alert.bar_2["btn_"..i].text.obj:setText(chargeListANDROID[i].."元")
           widget.alert.bar_2["btn_"..i].obj:registerEventScript(function(event)
              if event == "releaseUp" then
                 tool.buttonSound("releaseUp","effect_12")
                 chargeNum = chargeListANDROID[i]
                 textInput2:setText("")
                 for j=1,6 do
                     if i == j then
                         widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(false)
                         widget.alert.bar_2["btn_"..j].obj:setBright(false)
                         widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(5,3,0))
                     else
                         widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(true)
                         widget.alert.bar_2["btn_"..j].obj:setBright(true)
                         widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(254,177,23))
                     end
                 end
              end
           end)
      end
      widget.alert.bar_2.btn_1.obj:setTouchEnabled(false)
      widget.alert.bar_2.btn_1.obj:setBright(false)
      widget.alert.bar_2.btn_1.text.obj:setColor(ccc3(5,3,0))
   end
   event.listen("ON_CHANGE_GOLD",onChangeGold)
   event.listen("ON_GET_CHARGEID_SUCCEED", onGetChargeIdSucceed)
   call(21001,-10000,0,0)
end

function onChangeGold()
   widget.alert.bar_1.gold_1.num.obj:setStringValue(userdata.UserInfo.owncash)
   widget.alert.bar_1.gold_2.num.obj:setStringValue(userdata.UserInfo.owncharm)
end

function onGetChargeIdSucceed(data)
  if data.money == -100 then
     if data.transid ~= 0 then
        recommendId = data.transid
        textInput1:setText(recommendId)
     end
  else
     if platform == "IOS" then 
        if data.paytype == 2 then
           luaoc.callStaticMethod("AppController","iapppayBuy",{orderId=data.transid,price=tostring(data.money),productId=1,userId=userdata.UserInfo.uidx})
        elseif data.paytype == 24 then
           luaoc.callStaticMethod("AppController","appstoreBuy",{orderId=data.transid,productId="com.youngdream.hddbh"..chargeNum,time=tostring(os.time())})
        end
     else
        local res = {orderId=data.transid,price=tostring(data.money),productId=1,userId=userdata.UserInfo.uidx}
        local params = cjson.encode(res)
        luaj.callStaticMethod("com/java/platform/NdkPlatform","iapPay",{params})
     end
  end
end

function showCharge()
   for i=1,6 do
       widget.alert.bar_2["btn_"..i].text.obj:setText(chargeList[i].."元")
       widget.alert.bar_2["btn_"..i].obj:registerEventScript(function(event)
          if event == "releaseUp" then
             tool.buttonSound("releaseUp","effect_12")
             chargeNum = chargeList[i]
             textInput2:setText("")
             for j=1,6 do
                 if i == j then
                     widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(false)
                     widget.alert.bar_2["btn_"..j].obj:setBright(false)
                     widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(5,3,0))
                 else
                     widget.alert.bar_2["btn_"..j].obj:setTouchEnabled(true)
                     widget.alert.bar_2["btn_"..j].obj:setBright(true)
                     widget.alert.bar_2["btn_"..j].text.obj:setColor(ccc3(254,177,23))
                 end
             end
          end
       end)
   end
   widget.alert.bar_2.btn_1.obj:setTouchEnabled(false)
   widget.alert.bar_2.btn_1.obj:setBright(false)
   widget.alert.bar_2.btn_1.text.obj:setColor(ccc3(5,3,0))
end

function initInput()
   local inputSize = widget.alert.bar_1.text_3.bg.obj:getSize()
   textInput1 = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width-60,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   widget.alert.bar_1.text_3.bg.obj:addNode(textInput1)
   textInput1:setPosition(ccp(30,0))
   textInput1:setAnchorPoint(ccp(0,0.5))
   textInput1:setFontColor(ccc3(255,255,255))
   textInput1:setFontSize(40)
   textInput1:setFontName(DEFAULT_FONT)
   textInput1:setReturnType(1)
   textInput1:setMaxLength(20)
   textInput1:setPlaceHolder("输入推荐人ID")
   textInput1:setText("")
   textInput1:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      local str = textInput1:getText()
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
               alert.create("数字太长，超过输入限制")
               textInput1:setText("")
               return
            end
         end
         textInput1:setText(table.concat(tb))
         if tonumber(textInput1:getText()) then
            recommendId = tonumber(textInput1:getText())
         else
            recommendId = 0
            textInput1:setText("")
            alert.create("请输入数字")
         end
      end
   end
   textInput1:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.alert.bar_1.text_3.bg.obj:setTouchEnabled(true)
   widget.alert.bar_1.text_3.bg.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput1:attachWithIME()
                                                   textInput1:setPosition(ccp(30,0))
                                                end
   end)

   local inputSize = widget.alert.bar_2.input.obj:getSize()
   textInput2 = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   widget.alert.bar_2.input.obj:addNode(textInput2)
   textInput2:setPosition(ccp(0,0))
   textInput2:setAnchorPoint(ccp(0,0.5))
   textInput2:setFontColor(ccc3(255,255,255))
   textInput2:setFontSize(40)
   textInput2:setFontName(DEFAULT_FONT)
   textInput2:setReturnType(1)
   textInput2:setMaxLength(20)
   textInput2:setPlaceHolder("输入金额")
   textInput2:setText("")
   textInput2:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      local str = textInput2:getText()
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
               alert.create("数字太长，超过输入限制")
               textInput2:setText("")
               return
            end
         end
         textInput2:setText(table.concat(tb))
         if tonumber(textInput2:getText()) then
            chargeNum = math.floor(tonumber(textInput2:getText()))
         else
            textInput2:setText("")
            alert.create("请输入数字")
         end
      end
   end
   textInput2:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.alert.bar_2.input.obj:setTouchEnabled(true)
   widget.alert.bar_2.input.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput2:attachWithIME()
                                                   textInput2:setPosition(ccp(0,0))
                                                end
   end)
   if platform == "IOS" then
      widget.alert.bar_2.input.obj:setTouchEnabled(false)
   end
end

function exit()
  if this then
      if alertType == 1 then
         event.pushEvent("ON_BACK")
      end
      event.unListen("ON_CHANGE_GOLD",onChangeGold)
      event.unListen("ON_GET_CHARGEID_SUCCEED", onGetChargeIdSucceed)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      thisParent = nil
      chargeList = {}
      chargeNum = 0
      textInput1 = nil
      textInput2 = nil
      recommendId = 0
      alertType = 0
      chargeType = 1
  end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
   end
end

function onConfirm(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if platform == "IOS" then
         if chargeType == 1 then
            call(21001,chargeNum*100,recommendId,24)
         elseif chargeType == 2 then
            call(21001,chargeNum*100,recommendId,2)
         end
      else
         call(21001,chargeNum*100,recommendId,2)
      end
      print("onConfirm!!!!!!!!!!!!!!!!!!!!!!",chargeNum)
   end       
end

function onIOS(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      chargeType = 1
      widget.alert.ios.obj:setBright(false)
      widget.alert.ios.obj:setTouchEnabled(false)
      widget.alert.aibei.obj:setBright(true)
      widget.alert.aibei.obj:setTouchEnabled(true)
      widget.alert.bar_2.obj:setVisible(false)
      widget.alert.bar_3.obj:setVisible(true)
      chargeNum = chargeListIOS[1]
      for i=1,6 do
          widget.alert.bar_2["btn_"..i].obj:setBright(true)
          widget.alert.bar_2["btn_"..i].obj:setVisible(false)
          widget.alert.bar_2["btn_"..i].obj:setTouchEnabled(false)
          widget.alert.bar_2["btn_"..i].text.obj:setColor(ccc3(254,177,23))
          widget.alert.bar_3["btn_"..i].obj:setVisible(true)
          widget.alert.bar_3["btn_"..i].obj:setTouchEnabled(true)
      end
      widget.alert.bar_3.btn_1.obj:setTouchEnabled(false)
      widget.alert.bar_3.btn_1.obj:setBright(false)
      widget.alert.bar_3.btn_1.text.obj:setColor(ccc3(5,3,0))
      widget.alert.bar_2.input.obj:setTouchEnabled(false)
   end   
end

function onAIBEI(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      chargeType = 2
      widget.alert.ios.obj:setBright(true)
      widget.alert.ios.obj:setTouchEnabled(true)
      widget.alert.aibei.obj:setBright(false)
      widget.alert.aibei.obj:setTouchEnabled(false)
      widget.alert.bar_2.obj:setVisible(true)
      widget.alert.bar_3.obj:setVisible(false)
      chargeNum = chargeListANDROID[1]
      for i=1,6 do
          widget.alert.bar_2["btn_"..i].obj:setVisible(true)
          widget.alert.bar_2["btn_"..i].obj:setTouchEnabled(true)
          widget.alert.bar_3["btn_"..i].obj:setBright(true)
          widget.alert.bar_3["btn_"..i].obj:setVisible(false)
          widget.alert.bar_3["btn_"..i].obj:setTouchEnabled(false)
          widget.alert.bar_3["btn_"..i].text.obj:setColor(ccc3(254,177,23))
      end
      widget.alert.bar_2.btn_1.obj:setTouchEnabled(false)
      widget.alert.bar_2.btn_1.obj:setBright(false)
      widget.alert.bar_2.btn_1.text.obj:setColor(ccc3(5,3,0))
      widget.alert.bar_2.input.obj:setTouchEnabled(true)
   end   
end

widget = {
  _ignore = true,
  alert = {
    _type = "ImageView",
    top = {
      text = {_type = "Label"},
      back = {_type="Button",_func=onBack},
    },
    bar_1 = {
      text_1 = {
        _type = "Label",
        bg = {
          _type = "ImageView",
          text = {_type = "Label"},
        },
      },
      line_1 = {_type = "ImageView"},
      text_2 = {_type = "Label"},
      gold_1 = {
        _type = "ImageView",
        text = {_type = "Label"},
        num = {_type = "LabelAtlas"},
      },
      gold_2 = {
        _type = "ImageView",
        text = {_type = "Label"},
        num = {_type = "LabelAtlas"},
      },
      line_2 = {_type = "ImageView"},
      text_3 = {
        _type = "Label",
        bg = {_type = "ImageView"},
      },
    },
    bar_2 = {
      _type = "ImageView",
      text = {_type = "Label"},
      btn_1 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_2 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_3 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_4 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_5 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_6 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      input = {_type = "ImageView"},
    },
    bar_3 = {
      _type = "ImageView",
      text = {_type = "Label"},
      btn_1 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_2 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_3 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_4 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_5 = {
        _type = "Button",
        text = {_type = "Label"},
      },
      btn_6 = {
        _type = "Button",
        text = {_type = "Label"},
      },
    },
    confirm = {_type="Button",_func=onConfirm},
    ios = {
      _type = "Button",
      _func = onIOS,
      text = {_type = "Label"},
    },
    aibei = {
      _type = "Button",
      _func = onAIBEI,
      text = {_type = "Label"},
    },
  },
  bg = {_type = "ImageView"},
}