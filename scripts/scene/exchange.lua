local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"

module("scene.exchange", package.seeall)

this = nil
thisParent = nil
local currentType = 1
local currentTag = 0
local checkNum = 6
local checkList = {}
local selectNum = 0
local selectArr = {1,2,5,10,50}

function create(_parent)
   thisParent = _parent
   this = tool.loadWidget("cash/exchange",widget,thisParent,99)
   initView()
   event.listen("ON_CHANGE_GOLD",onChangeGold)
   return this
end

function onChangeGold()
   widget.alert.panel_1.text_2.obj:setText(userdata.UserInfo.owncharm.."点")
   widget.alert.panel_1.text_3.obj:setText(userdata.UserInfo.owncash.."金币")
end

function initView()
   onChangeGold()
   widget.alert.panel_1.text_3.obj:setPosition(ccp(widget.alert.panel_1.text_2.obj:getPositionX()+widget.alert.panel_1.text_2.obj:getSize().width+30,widget.alert.panel_1.text_3.obj:getPositionY()))
   widget.alert.panel_1.obj:setTouchEnabled(false)
   widget.alert.panel_2.obj:setTouchEnabled(false)
   for i=1,checkNum do
       local check = widget.alert.panel_2["check_"..i].obj
       check:setTouchEnabled(false)
       checkList[i] = check
       check:registerEventScript(function(event,data1,data)
            if event == "releaseUp" then
                tool.buttonSound("releaseUp","effect_12")
                -- data = tolua.cast(data,"CheckBox")
                local isSelect = check:getSelectedState()
                if not isSelect then
                   isSelect = true
                end
                selectNum = i
                for j=1,checkNum do
                    if i ~= j then
                       checkList[j]:setSelectedState(false)
                    end
                end
            end
       end)
   end
end

function exit()
  if this then
      -- event.pushEvent("ON_BACK")
      event.unListen("ON_CHANGE_GOLD",onChangeGold)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      thisParent = nil
      currentType = 1
      currentTag = 0
      checkList = {}
  end
end

function onBack(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      if currentType == 2 then
         currentType = 1
         widget.alert.panel_1.obj:setVisible(true)
         widget.alert.panel_2.obj:setVisible(false)
         for i=1,checkNum do
             checkList[i]:setSelectedState(false)
             checkList[i]:setTouchEnabled(false) 
         end
      else
         exit()
      end
  end
end

function onLeft(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      currentTag = 1
      showPanel2()
  end
end

function onRight(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      currentTag = 2
      showPanel2()
  end
end

function showPanel2()
    currentType = 2
    widget.alert.panel_1.obj:setVisible(false)
    widget.alert.panel_2.obj:setVisible(true)
    for i=1,checkNum do
        checkList[i]:setTouchEnabled(true) 
    end
    checkList[6]:setSelectedState(true)
end

function onConfirm(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      local p = currentTag == 1 and 1000 or 1000000
      local n = 0
      if selectNum < 6 then
         n = selectArr[selectNum] 
         if userdata.UserInfo.owncharm < n*p then
            alert.create("点数不足，请前往商城充值")
            return
         end
      else
         if userdata.UserInfo.owncharm == 0 then
            alert.create("点数不足，请前往商城充值")
            return
         else
            n = userdata.UserInfo.owncharm / p
         end
      end
      call(17001,n*p)
  end
end

function onCheck(event,data1,data)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      data = tolua.cast(data,"CheckBox")
      local isPrivate = data:getSelectedState()
      isPrivate = not isPrivate
      -- data:setSelectedState(isPrivate)
   end
end

widget = {
_ignore = true,
  alert = {
    back = {_type="Button",_func=onBack},
    panel_1 = {
       btn_right = {_type="Button",_func=onRight},
       right_2 = {_type = "Label"},
       right_1 = {_type = "Label"},
       btn_left = {_type="Button",_func=onLeft},
       left_2 = {_type = "Label"},
       left_1 = {_type = "Label"},
       text_8 = {_type = "Label"},
       text_7 = {_type = "Label"},
       text_6 = {_type = "Label"},
       text_5 = {_type = "Label"},
       text_4 = {_type = "Label"},
       text_3 = {_type = "Label"},
       text_2 = {_type = "Label"},
       text_1 = {_type = "Label"},
  	},
    panel_2 = {
       title = {_type = "Label"},
       check_1 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       check_2 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       check_3 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       check_4 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       check_5 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       check_6 = {
          _type = "CheckBox",
          _func = onCheck,
          text = {_type = "Label"},
       },
       confirm = {_type="Button",_func=onConfirm},
    },
  },
}