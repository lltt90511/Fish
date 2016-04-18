local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local template = require"template.gamedata".data

module("scene.betAlert", package.seeall)

this = nil
thisParent = nil
parentModule = nil
local textInput = nil
local eventHash = {}
local betArr = {1000,10000,100000,1000000,2000000}
local isShowBetList = false

function create(_parent,_parentModule)
   thisParent = _parent
   parentModule = _parentModule
   this = tool.loadWidget("cash/betAlert",widget,thisParent,99)
   initBetView()
   initEditBox()
   widget.alert.triangle_touch.obj:registerEventScript(onTriangle)
   return this
end

function initBetView()
   for i=1,5 do
       widget.alert.list_layout.bg["xiala_"..i].obj:setTouchEnabled(true)
       widget.alert.list_layout.bg["xiala_"..i].obj:registerEventScript(function(event)
            if event == "releaseUp" then
               tool.buttonSound("releaseUp","effect_12")
               textInput:setText(betArr[i])
               showOrHideBetList()
            end
       end)
   end
end

function showOrHideBetList()
   local posY = widget.alert.list_layout.bg.obj:getPositionY()
   if posY == 300 then
      isShowBetList = true
      tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=0,easeOut=true},widget.alert.list_layout.bg.obj)
   elseif posY == 0 then
      isShowBetList = false
      tool.createEffect(tool.Effect.move,{time=0.5,x=0,y=300,easeOut=true},widget.alert.list_layout.bg.obj)
   end
end

function initEditBox()
   local inputSize = widget.alert.cost.obj:getSize()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(inputSize.width-50,inputSize.height),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   widget.alert.cost.obj:addNode(textInput)
   textInput:setPosition(ccp(0,0))
   textInput:setAnchorPoint(ccp(0,0))
   textInput:setFontColor(ccc3(255,255,255))
   textInput:setFontSize(40)
   textInput:setFontName(DEFAULT_FONT)
   -- textInput:setInputMode(3)
   textInput:setReturnType(1)
   textInput:setMaxLength(20)
   textInput:setPlaceHolder("输入金额")
   textInput:setText("")
   textInput:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      print(textInput:getText())
      print(strEventName)
      if isShowBetList then
         showOrHideBetList()
      end
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
               i = i + 3
               cnt = cnt + 2
            else
               table.insert(tb,c)
               i = i + 1
               cnt = cnt + 1
            end
            if cnt > 21 then
               alert.create("文字太长，超过输入限制")
               textInput:setText("")
               return
            end
         end
         textStr = table.concat(tb)
         -- local textStr = nil
         -- if #tb > 20 then
         --    textStr = table.concat(tb,"",1,20)
         -- else
         --    textStr = table.concat(tb,"",1,#tb)
         -- end
         if tonumber(textStr) then
            textStr = tostring(math.floor(tonumber(textStr)))
         end
         textInput:setText(textStr)
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.alert.cost_touch.obj:setTouchEnabled(true)
   widget.alert.cost_touch.obj:registerEventScript(function (event)
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
      cleanEvent()
      textInput = nil
      isShowBetList = false
      thisParent = nil
      parentModule = nil
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onBet(ev)
   if ev == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if textInput:getText() == "" or not tonumber(textInput:getText()) then
         textInput:setText("")
         alert.create("请输入押注金额")
      else
         if tonumber(textInput:getText()) <= 0 then
            alert.create("押注金额必须大于0")
         else
             if parentModule and parentModule.isYazhu then
                alert.create("已押注，请勿修改押注金额！")
             else
                call("fingerGameBet",math.floor(tonumber(textInput:getText())))
             end
             event.pushEvent("ON_BET_ALERT_BACK")
         end
      end
   end
end

function onTriangle(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      showOrHideBetList()
   end
end

function onBack(ev)
   if ev == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
      event.pushEvent("ON_BET_ALERT_BACK")
   end
end

widget = {
	_ignore = true,
	alert = {
		_type = "ImageView",
		btn = {_type = "Button",_func = onBet},
    list_layout = {
      _type = "Layout",
      bg = {
        _type = "Layout",
        xiala_1 = {
          _type = "ImageView",
          num = {_type = "Label"},
        },
        xiala_2 = {
          _type = "ImageView",
          num = {_type = "Label"},
        },
        xiala_3 = {
          _type = "ImageView",
          num = {_type = "Label"},
        },
        xiala_4 = {
          _type = "ImageView",
          num = {_type = "Label"},
        },
        xiala_5 = {
          _type = "ImageView",
          num = {_type = "Label"},
        },
      },
    },
    cost = {
      _type = "ImageView",
      triangle = {_type = "Button"},
    },
    title = {_type = "ImageView"},
    back = {_type = "Button",_func = onBack},
    cost_touch = {_type = "Layout"},
    triangle_touch = {_type = "Layout"},
	},
}