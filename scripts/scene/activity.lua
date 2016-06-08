local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local countLv = require"logic.countLv"
local scrollList = require"widget.scrollList"
local template = require"template.gamedata".data

module("scene.activity", package.seeall)

this = nil
subWidget = nil
local defult_width = 870

function create(parent)
   this = tool.loadWidget("cash/activity",widget,parent,99)
   -- widget.panel.bg.label.obj:setVisible(false)
   -- call("getAllActivityInfo")
   -- event.listen("ON_GET_ALL_ACTIVITY_INFO",onGetAllActivityInfo)
   return this
end

textList = {
	-- [1] = {size = 50,height = 65,offset = 20,list = {[1] = {r = 255,g = 249,y = 71,text = "阳春三月猴开心！！"}}},
	-- [2] = {size = 40,height = 52,offset = 50,list = {[1] = {r = 255,g = 255,y = 255,text = "活动时间：3月11日~3月29日"}}},
	-- [3] = {size = 50,height = 65,offset = 20,list = {[1] = {r = 255,g = 249,y = 71,text = "活动一：阳春回馈礼，首充尊享VIP"}}},
	-- [4] = {size = 40,height = 52,offset = 60,list = {[1] = {r = 255,g = 249,y = 255,text =  "活动期间每位用户首次充值不小于10元，立刻升级VIP3！！尊享登陆奖励金币加成300%，每天赠送3次抽奖机会，充值额外赠送总额30%的金币"}}},
 --  [5] = {size = 50,height = 65,offset = 20,list = {[1] = {r = 255,g = 249,y = 71,text = "活动二：VIP升级大礼包"}}},
 --  [6] = {size = 40,height = 52,offset = 0,list = {[1] = {r = 255,g = 249,y = 255,text =  "活动期间玩家VIP等级每提升一次，可获得升级大礼包一个，礼包金币数量=升级VIP所需的累计充值金额数*10000，奖励金币将在充值成功通过邮件发送到您的游戏账户中。单笔充值提升了多个VIP等级时，系统将按会发送对应数量的升级大礼包！"}}},
}

function onGetAllActivityInfo(infoList)
    if #infoList == 0 then
       widget.panel.bg.label.obj:setVisible(true)
    else
       widget.panel.bg.list.obj:setVisible(true)
       widget.panel.bg.list.obj:setTouchEnabled(true)
       widget.panel.bg.list.obj:removeAllItems()
    end
    printTable(infoList)
    for k,v in pairs(infoList) do  
        addActivityInfo(v.name,65,20,50,ccc3(255,0,71))
        --local startRec = os.date("*t",tonumber(v.startTime)/1000)
        --startStr = startRec.year.."-"..startRec.month.."-"..startRec.day
        --local endRec = os.date("*t",tonumber(v.endTime)/1000)
        --local timeText = startRec.year.."/"..startRec.month.."/"..startRec.day.."".."-"..endRec.year.."/"..endRec.month.."/"..endRec.day..""
        local now = getSyncedTime()
        if now < v.startTime/1000  then
            addActivityInfo("未开启：距离开启还有"..getDiffTimeDetail(v.startTime/1000,now),52,20,32,ccc3(156,156,156))
        elseif now < v.endTime/1000 then
            addActivityInfo("开启中：距离结束还有"..getDiffTimeDetail(v.endTime/1000,now),52,20,32,ccc3(0,255,0))
        else 
            addActivityInfo("已结束",52,20,32,ccc3(156,156,156))
        end
        if v.activityList ~= "" then
           local arr = splitString(v.activityList,",")
           for i = 1, #arr do
               local tmp = template['activity'][tonumber(arr[i])]
               printTable(tmp)
               if tmp then
                  if tmp.name then
                     addActivityInfo(tmp.name,65,20,50,ccc3(255,255,0))
                  end
                  local strArr = splitString(tmp.desc, "|")
                  for i = 1, #strArr do
                      addActivityInfo(strArr[i],52,0,32)
                  end
               end
           end
        end
    end
end

function addActivityInfo(text,height,offset,size,color)
	 if not color then
      color = ccc3(255,255,255)
   end
   local richText = RichText:create()
   richText:ignoreContentAdaptWithSize(false)
   richText:setSize(CCSize(defult_width,height))
   richText:setAnchorPoint(ccp(0,0))
   richText:setPosition(ccp(20,offset))
   local richElementText = RichElementText:create(1,color,255,text,DEFAULT_FONT,size)
	 richText:pushBackElement(richElementText)
   local lab = Label:create()
	 lab:setText(text)
	 lab:setFontSize(size)
   lab:setFontName(DEFAULT_FONT)
   local totalWidth = lab:getContentSize().width
	 if totalWidth > defult_width then
   	  richText:ignoreContentAdaptWithSize(false)
	    height = math.ceil(totalWidth/defult_width)*richText:getSize().height
	    richText:setSize(CCSize(defult_width,height))
	 end
   local layout = Layout:create()
   layout:setSize(CCSize(richText:getSize().width,richText:getSize().height+offset))
   layout:addChild(richText)
   widget.panel.bg.list.obj:pushBackCustomItem(layout)
end

function exit()
  if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_GET_ALL_ACTIVITY_INFO",onGetAllActivityInfo)
      widget.panel.bg.list.obj:removeAllItems()
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onBack(event)
  if event == "releaseUp" then
	 -- local main = package.loaded["scene.main"]
  -- 	 main:switchBottomBright("dating")
      tool.buttonSound("releaseUp","effect_12")
     exit()
  end
end

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	title =  {_type="ImageView",},
   		-- listView = {_type = "ScrollView"},
   		  list = {_type = "ListView"},
        label = {_type = "Label"},
  	},
  },
  scroll_bg = {
  	scroll_bar = {},
  },
}
