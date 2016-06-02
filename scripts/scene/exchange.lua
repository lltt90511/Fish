local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"

module("scene.exchange", package.seeall)

this = nil
thisParent = nil
local checkList1 = {}
local checkList2 = {}
local checkNum1 = 2
local checkNum2 = 6
local selectNum = 0
local selectType = 0
local selectArr = {1,5,10,50,100}
local gameId = 0

function create(_parent,_id)
   thisParent = _parent
   this = tool.loadWidget("cash/exchange",widget,thisParent,99)
   gameId = _id
   selectNum = 1
   selectType = 1
   initView()
   widget.obj:registerEventScript(onBack)
   event.listen("ON_CHANGE_GOLD",onChangeGold)
   return this
end

function onChangeGold()
   widget.alert.bar_1.gold_1.num.obj:setStringValue(userdata.UserInfo.owncash)
   widget.alert.bar_1.gold_2.num.obj:setStringValue(userdata.UserInfo.owncharm)
end

function initView()
   onChangeGold()
   for i=1,checkNum1 do
       local check = widget.alert.bar_2["check_"..i].obj
       check:setSelectedState(false)
       checkList1[i] = check
       check:registerEventScript(function(event,data1,data)
            if event == "releaseUp" then
                tool.buttonSound("releaseUp","effect_12")
                -- data = tolua.cast(data,"CheckBox")
                local isSelect = check:getSelectedState()
                if not isSelect then
                   isSelect = true
                end
                selectType = i
                for j=1,checkNum1 do
                    if i ~= j then
                       checkList1[j]:setSelectedState(false)
                    end
                end
            end
       end)
   end
   widget.alert.bar_2.check_1.obj:setSelectedState(true)
   for i=1,checkNum2 do
       local check = widget.alert.bar_3["check_"..i].obj
       check:setSelectedState(false)
       checkList2[i] = check
       check:registerEventScript(function(event,data1,data)
            if event == "releaseUp" then
                tool.buttonSound("releaseUp","effect_12")
                -- data = tolua.cast(data,"CheckBox")
                local isSelect = check:getSelectedState()
                if not isSelect then
                   isSelect = true
                end
                selectNum = i
                for j=1,checkNum2 do
                    if i ~= j then
                       checkList2[j]:setSelectedState(false)
                    end
                end
            end
       end)
   end
   widget.alert.bar_3.check_1.obj:setSelectedState(true)
end

function exit()
  if this then
      -- event.pushEvent("ON_BACK")
      event.unListen("ON_CHANGE_GOLD",onChangeGold)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      thisParent = nil
      checkList1 = {}
      checkList2 = {}
      selectNum = 0
      selectType = 0
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
      local p = 0
      if gameId == 1 then
         p = selectType == 1 and 100000 or 1000
      elseif gameId == 2 then
         p = selectType == 1 and 100 or 10
      end
      local n = 0
      if selectNum < 6 then
         n = selectArr[selectNum] 
         if userdata.UserInfo.owncharm < n*p then
            alert.create("点数不足，请前往商城充值")
            return
         end
      else
         if userdata.UserInfo.owncharm < p then
            alert.create("点数不足，请前往商城充值")
            return
         else
            n = math.floor(userdata.UserInfo.owncharm/p)
         end
      end
      print("onConfirm!!!!!!!!!!!!!!!!",n,p)
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
    _type = "ImageView",
    top = {
      text = {_type = "Label"},
      back = {_type="Button",_func=onBack},
    },
    bar_1 = {
      text_1 = {_type = "Label"},
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
      text_2 = {_type = "Label"},
    },
    bar_2 = {
      _type = "ImageView",
      check_1 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_2 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
    },
    bar_3 = {
      _type = "ImageView",
      check_1 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_2 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_3 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_4 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_5 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
      check_6 = {
        _type = "CheckBox",
        text = {_type = "Label"},
      },
    },
    confirm = {_type="Button",_func=onConfirm},
  },
}