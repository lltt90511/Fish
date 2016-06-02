local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data
local loginAlert = require "scene.loginAlert"
module("scene.loginGift", package.seeall)

this = nil
subWidget = nil
local parentModule = nil
 boxList ={}
 cloneObj = nil
local giftTmpList = {}
local getEd = 0
local isGet = false

function create(parent,_parentModule)
   parentModule = _parentModule
  this = tool.loadWidget("cash/loginGift",widget,parent,99)
  cloneObj = widget.panel.bg.tmp.obj
  cloneObj:setVisible(false)
  cloneObj:setTouchEnabled(false)
  cloneObj:setPosition(ccp(-100100,0))
  initList()
  event.listen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
  event.listen("ON_CHANGE_VIP",initList)
  return this
end
function initList()
  giftTmpList = {}
  local tpl = template['dailyGift']
  local sx = -294
  local sy =364
  local addX = 300
  local addY = -320
  local maxX = 400
  local x= sx 
  local y = sy
  getEd = 0
  local today = timeToDayStart(getSyncedTime()) 
  local last = userdata.UserInfo.daylastLq
  local get = userdata.UserInfo.dayNum
  local yes = today -24*3600
  if last < yes then
     getEd = 1
  else
     get =get + 1
     if get > #tpl  then
         get = 1
      end
      getEd = get
  end
  -- local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
  -- local currentVip = template['vipExp'][vipLv]
  -- if currentVip == nil then
  --     currentVip = {daily = 100}
  --   end
  --   local multi = currentVip.daily
  --   local nextMulti = currentVip.daily
  --   local nextLv = vipLv
  --   if  template['vipExp'][vipLv+1] then
  --     nextMulti =  template['vipExp'][vipLv+1].daily
  --     nextLv = vipLv + 1
  --   end
    --print ("getEd....."..getEd.."...."..userdata.UserInfo.dailyGiftCnt)
    for i=1,#tpl do
        local obj = cloneObj:clone()
        obj:setVisible(true)
        obj:setPosition(ccp(x,y))
        x = x + addX
        if x > maxX then
          x = sx
          y = y+addY
        end
        widget.panel.bg.obj:addChild(obj)
        -- local widgetList = tool.loadWidgetForClone(GiftTmp,obj)
        -- widgetList.gold.obj:setText(tpl[i].gold*multi/100)
        -- widgetList.day.obj:setText(tpl[i].name)
        local lab_gold = tool.findChild(obj,"gold","Label")
        local lab_day = tool.findChild(obj,"day","Label")
        local check = tool.findChild(obj,"check","CheckBox")
        check:setTouchEnabled(false)
        lab_gold:setText(tpl[i].gold)
        lab_day:setText(tpl[i].name)
        if i < getEd then
            -- widgetList.check.obj:setSelectedState(true)
            check:setSelectedState(true)
        elseif i == getEd  then
             -- widgetList.check.obj:setSelectedState(false)
             -- tolua.cast(obj,"Button"):setBright(false)
             check:setSelectedState(false)
             obj:setBright(false)
        else
          -- widgetList.check.obj:setVisible(false)
            check:setSelectedState(false)
        end
        -- table.insert(giftTmpList,widgetList)
        table.insert(giftTmpList,obj)
    end
    widget.panel.bg.bottom.obj:setVisible(false)
    widget.panel.bg.bottom.bg.get.obj:setTouchEnabled(false)
    if timeToDayStart(getSyncedTime()) > userdata.UserInfo.daylastLq then
       widget.panel.bg.text.obj:setVisible(false)
    else
       widget.panel.bg.get.obj:setVisible(false)
       widget.panel.bg.get.obj:setTouchEnabled(false)
    end
    -- widget.panel.bg.bottom.bg.gold.obj:setText(tpl[getEd].gold*nextMulti/100)
    -- widget.panel.bg.bottom.bg.get.text.obj:setText("VIP"..(nextLv).."领取")
    -- widget.panel.bg.bottom.bg.get.text_shadow.obj:setText("VIP"..(nextLv).."领取")
  
end
function exit()
  if this then
      event.unListen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
      event.unListen("ON_CHANGE_VIP",initList)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      giftTmpList = {}
      this = nil
      parentModule = nil
  end
end

function onGoldActionFinish()
    tool.createEffect(tool.Effect.delay,{time=0.8},widget.obj,function()
       exit()
    end)
end

function onGetDailyGift(data)
  if isGet == false then
     isGet = true
  end
  widget.panel.bg.get.obj:setVisible(false)
  widget.panel.bg.get.obj:setTouchEnabled(false)
  widget.panel.bg.text.obj:setVisible(true)
  if userdata.goldAction == true then
     event.pushEvent("ON_GOLD_ACTION")
  end
  local tmp = giftTmpList[getEd]
  tmp:setBright(true)
  local nextTmp = giftTmpList[getEd+1]
  if nextTmp then
     nextTmp:setBright(false)
  end
  -- print("tmp$%$$$$$$$$$$$$$$$$$$$$$$$$$$$$",tmp,getEd)
  -- tmp:setBright(false)
  local check = tool.findChild(tmp,"check","CheckBox")
  check:setSelectedState(true)
  -- if parentModule and parentModule.daily == false then
  --    parentModule.daily = true
  -- end
end

function onBack(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
     --exit()
     if isGet == true then return end
     userdata.goldAction = true
     local tmp = giftTmpList[getEd]
     userdata.goldPos = {x=540+tmp:getPositionX(),y=1077+tmp:getPositionY()}
     print("onBack",540+tmp:getPositionX(),1077+tmp:getPositionY())
     call(15001)
  end
end

function onGetVIP(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
     loginAlert.create(widget.obj)
  end
end

function onClose(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     exit()
  end
end

GiftTmp = {
  _ignore=true,
  -- _type = "Button",
  check = {_type = "CheckBox",},
  gold = {_type="Label"},
  img = {_type="ImageView"},
  day = {_type="Label"},
}
widget = {
_ignore = true,
  panel = {
    bg = {
      get = {_type="Button",_func=onBack},
      tmp = {
        _type = "Button",
        check = {_type = "CheckBox",},
        gold = {_type = "Label"},
        img = {_type = "ImageView"},
        day = {_type = "Label"},
      },
      bottom = {
        bg = {
          gold = {_type="Label"},
          get =  {_type="Button",text =  {_type="Label"},text_shadow =  {_type="Label"},_func=onGetVIP},
        },
        tips =  {_type="Label"},
      },
      back = {_type = "Button",_func = onClose},
      text = {_type = "Label"},
    },
  },
}
