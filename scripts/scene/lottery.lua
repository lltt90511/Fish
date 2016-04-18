local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data
local charge = require "scene.charge"

module("scene.lottery", package.seeall)

this = nil
subWidget = nil

list = {
	[1] = {icon = "jinbiIcon01.png",scale = 1.0},
	[2] = {icon = "jinbiIcon02.png",scale = 1.0},
	[3] = {icon = "jinbiIcon03.png",scale = 0.9},
	[4] = {icon = "jinbiIcon04.png",scale = 0.8},
	[5] = {icon = "jinbiIcon05.png",scale = 0.7},
	[6] = {icon = "jinbiIcon06.png",scale = 0.6},
}

local lastId = 1
local selectId = 1
local tmpList = {}
local maxNum = #template["random"]
local historyList = {}

function create(parent)
   this = tool.loadWidget("cash/lottery",widget,parent,99)
   initView()
   event.listen("ON_RANDOM_GOLD",selectAction)
   event.listen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
   refreshHistory(userdata.UserInfo.randomHistoryList)
   return this
end

function initView()
   tmpList = {}
   resetRandomCnt()
   local fx, fy = 0, 5
   local dic = {{1,0},{0,-1},{-1,0},{0,1}}
   local k = 1
   for i=1,maxNum do
       local x, y = fx + dic[k][1], fy + dic[k][2]
       fx, fy = x, y
       if (dic[k][1] == 1 and fx >= 5) or (dic[k][1] == -1 and fx <= 1) or 
     	    (dic[k][2] == 1 and fy >= 5) or (dic[k][2] == -1 and fy <= 1) then
          k = k + 1
       end  
   	   local tmp = {}
   	   tmp.obj = widget.panel.tmp.obj:clone()
   	   local tpl = template["random"][i]
   	   if tpl then
   	   	  local gold = tpl.gold/10000
   	   	  tmp.gold = tool.findChild(tmp.obj, "gold", "ImageView")
   	   	  tmp.num = tool.findChild(tmp.obj,"num","Label")
   	   	  tmp.img = tool.findChild(tmp.obj,"img","ImageView")
   	   	  tmp.num:setText(gold.."万")
   	   	  local iconTpl = nil
   	   	  if gold >= 500 then
   	   	  	 iconTpl = list[6]
   	   	  elseif gold >= 200 then
   	   	  	 iconTpl = list[5]
   	   	  elseif gold >= 100 then
   	   	  	 iconTpl = list[4] 
   	   	  elseif gold >= 80 then 
   	   	  	 iconTpl = list[3]
   	   	  elseif gold >= 50 then 
   	   	  	 iconTpl = list[2]
   	   	  else
   	   	  	 iconTpl = list[1]
   	   	  end
   	   	  tmp.gold:loadTexture("cash/qietu/tymb/"..iconTpl.icon)
   	   	  tmp.gold:setScale(iconTpl.scale)
   	   	  local posX = (x - 1) * 193 + 55
          local posY = (y - 1) * 185 + 25
    		  tmp.obj:setPosition(ccp(posX,posY))
    		  widget.panel.bg.layout.obj:addChild(tmp.obj)
          table.insert(tmpList,tmp)
    	 end
   end
end

function refreshHistory(data)
  printTable(historyList)
   for k, v in pairs(historyList) do
      if v.obj then
         v.obj:removeFromParentAndCleanup(true)
      end
   end
   historyList = {}
   if data and type(data) == type({}) then
       for i=1,4 do
           if data[i] then
               local v = {obj = tolua.cast(widget.panel.tmp.obj:clone(), "ImageView")}
               local x = 120 - (i-1)*140
               local y = -240
               v.obj:setPosition(ccp(x,y))
               v.obj:setScale(0.9)
               local gold = data[i].gold/10000
               local goldImg = tool.findChild(v.obj,"gold","ImageView")
               local iconTpl = nil
               if gold >= 500 then
                  iconTpl = list[6]
               elseif gold >= 200 then
                  iconTpl = list[5]
               elseif gold >= 100 then
                  iconTpl = list[4] 
               elseif gold >= 80 then 
                  iconTpl = list[3]
               elseif gold >= 50 then 
                  iconTpl = list[2]
               else
                  iconTpl = list[1]
               end
               goldImg:setScale(iconTpl.scale)
               goldImg:loadTexture("cash/qietu/tymb/"..iconTpl.icon)
               local num = tool.findChild(v.obj,"num","Label")
               num:setText(gold.."万")
               widget.panel.bg.obj:addChild(v.obj,10)
               table.insert(historyList,v)
           end
       end
   end
end

function onGoldActionFinish()
   widget.panel.btn.obj:setTouchEnabled(true)
   widget.panel.btn.obj:setBright(true)
end

function selectAction(id,data)
   -- print("selectAction",id) 
   AudioEngine.playEffect("effect_02")
   local main = package.loaded['scene.main']
   main.setLotteryPaoNum() 
   resetRandomCnt()
   local st = lastId 
   local delay = 0
   if tmpList[st] ~= nil then
      tmpList[st].img:setVisible(false)
      local posx = tmpList[id].obj:getPositionX() + 100
      local posy = tmpList[id].obj:getPositionY() + 488 + 100
      userdata.goldPos = {x=posx,y=posy}
   end
   st = st + 1
   if st > maxNum then
      st = 1
   end
   local totalCnt = maxNum*3 - lastId + id
   local totalDelay = 0
   local c1,c2 = totalCnt*totalCnt/4, totalCnt*totalCnt*3/4
   for i = 1, totalCnt-1 do
      if i < 5 or i > totalCnt - 5 then
         totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c1
      else 
         totalDelay = totalDelay + (i-totalCnt/2)*(i-totalCnt/2)/c2
      end
   end
   local per = 4/totalDelay

   local func = nil
   local cnt = 0
   -- printTable(tmpList)
   func = function()
      tmpList[st].img:setVisible(true)
      tmpList[st].img:setOpacity(0)
      tool.createEffect(tool.Effect.delay,{time=delay},tmpList[st].img,
                        function()
                           tmpList[st].img:setOpacity(255)

                           if st == id and cnt == totalCnt - 1 then
                              tool.createEffect(tool.Effect.blink,{time=0.5,f=3},tmpList[st].img,
                                                function()
                                                    AudioEngine.playEffect("effect_07")
                                                    lastId = id
                                                    refreshHistory(data)
                                                    userdata.isInGame = false
                                                    -- widget.panel.btn.obj:setTouchEnabled(true)
                                                    -- widget.panel.btn.obj:setBright(true)
                                                    event.pushEvent("ON_GOLD_ACTION")
                                                end
                              )
                              return
                           end

                           local _st = st                                                     
                           st = st + 1
                           if st == maxNum+1 then
                              st = 1
                           end
                           cnt = cnt + 1
                           local x = cnt
                           if x < 5 or x > totalCnt - 5 then
                              delay = (x-totalCnt/2)*(x-totalCnt/2)/c1*per
                           else 
                              delay = (x-totalCnt/2)*(x-totalCnt/2)/c2*per
                           end
                           lightDelay = delay
                           tool.createEffect(tool.Effect.fadeOut,{time=delay-0.1 > 0.1 and delay-0.1 or 0.1},tmpList[_st].img,
                                             function()
                                                -- tmpList[_st].img:setVisible(false)
                                                
                                             end
                           )
                           func()
                        end
      )
   end
   func()
end

function resetRandomCnt()
   local randomCnt = userdata.UserInfo.randomCnt
   local now = getSyncedTime() 
   local time_21 = timeToDayStart(now) + 21*3600
   local time_13 = timeToDayStart(now) + 13*3600
   local time_21_y = time_21 - 24*3600
   if now < time_13 then
      now = time_21_y
    elseif now < time_21 then
      now = time_13 
    else
      now = time_21
    end 
   if userdata.UserInfo.lastRandomTime/1000 < now then
      randomCnt = 0
   end
   local vipLv = countLv.getVipLv(userdata.UserInfo.vipExp)
   randomCnt = 2 + vipLv - randomCnt
   widget.panel.bg.num.obj:setStringValue(randomCnt)
   if randomCnt == 0 then
      widget.panel.btn.obj:setTouchEnabled(false)
      widget.panel.btn.obj:setBright(false)
   end
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_RANDOM_GOLD",selectAction)
      event.unListen("ON_GOLD_ACTION_FINISH",onGoldActionFinish)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      tmpList = {}
      historyList = {}
   end
end

function onBack(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      exit()
   end
end

function onBtn(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      widget.panel.btn.obj:setTouchEnabled(false)
      widget.panel.btn.obj:setBright(false)
      -- userdata.goldAction = true
      if userdata.isInGame == false then
         userdata.isInGame = true
      end
      if userdata.isLottery == false then
         userdata.isLottery = true
      end
      call("randomGold")
   end
end

widget = {
  	_ignore = true,
  	panel = {
  		light =  {_type = "ImageView"},
   	  	bg = {
         	back = {
        		_type = "Button",
        		_func = onBack,
        	},
  	   		num = {_type = "LabelAtlas"},
     			wenzi_1 = {_type = "ImageView"},
  	   		label_1 = {_type = "Label"},
  	   		label_2 = {_type = "Label"},
  	   		layout = {_type = "Layout"},
  	  	},
  	  	tmp = {
  	  	    _type = "ImageView",
  	  	    gold = {_type = "ImageView"},
  	  	    num = {_type = "Label"},
  	  	    img = {_type = "ImageView"}, 
  	    },
  	    btn = {
  	        _type = "Button",
            _func = onBtn,
  	        text = {_type = "Label"},
            text_shadow = {_type = "Label"},
  		},
  	},
} 