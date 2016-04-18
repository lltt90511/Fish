local tool = require"logic.tool"
local event = require"logic.event"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local template = require"template.gamedata".data
local charge = require "scene.charge"

module("scene.vip", package.seeall)

this = nil
subWidget = nil

local currentTag = 0
local mineLayout = nil
local isMax = false
function create(parent)
   this = tool.loadWidget("cash/vip",widget,parent,99)
   initView()
   resetView()
   event.listen("ON_CHANGE_VIP",resetVip)
   return this
end

function initView()
   mineLayout = widget.tmp.obj:clone()
   mineLayout:setPosition(ccp(110,400))
   widget.obj:addChild(mineLayout)
   resetVip()
   currentTag = 0
   widget.panel.bg.btn_l.obj:setBright(false)
   widget.panel.bg.btn_l.obj:setTouchEnabled(false)
   widget.panel.bg.btn_r.obj:setBright(true)
   widget.panel.bg.btn_r.obj:setTouchEnabled(true)
   for i=1,#vipList do
   	   local info = vipList[i]
   	   if info then 
   	   	  local layout = widget.tmp.obj:clone()
   	   	  local img = tool.findChild(layout,"img","ImageView")
   	   	  local lab = tool.findChild(img,"lab","Label")
   	   	  local vip = tool.findChild(layout,"vip","ImageView")
   	   	  local num = tool.findChild(vip,"num","LabelAtlas")
   	   	  local text_1 = tool.findChild(layout,"text_1","Label")
   	   	  local text_2 = tool.findChild(layout,"text_2","Label")
   	   	  local text_3 = tool.findChild(layout,"text_3","Label")
   	   	  local text_4 = tool.findChild(layout,"text_4","Label")
          lab:setFontName(DEFAULT_FONT)
   	   	  lab:setText("累计充值"..info.rmb.."元")
   	   	  num:setStringValue(info.lv)
          text_1:setFontName(DEFAULT_FONT)
   	   	  text_1:setText("登录奖励金币加成"..info.text1.."%")
          text_2:setFontName(DEFAULT_FONT)
   	   	  text_2:setText("每天赠送"..info.text2.."次抽奖机会")
          text_3:setFontName(DEFAULT_FONT)
   	   	  text_3:setText("充值额外赠送基础金额"..info.text3.."%的金币")
   	   	  -- text_4:setText("坐庄手续费减免"..info.text4.."%")
   	   	  widget.panel.bg.list.obj:pushBackCustomItem(layout)
   	   end
   end
end

vipList = {
	[1] = {lv = 1,rmb = 10,text1 = 100,text2 = 1,text3 = 10,text4 = 20},
	[2] = {lv = 2,rmb = 20,text1 = 200,text2 = 2,text3 = 20,text4 = 20},
	[3] = {lv = 3,rmb = 50,text1 = 300,text2 = 3,text3 = 30,text4 = 20},
	[4] = {lv = 4,rmb = 100,text1 = 400,text2 = 4,text3 = 40,text4 = 20},
	[5] = {lv = 5,rmb = 200,text1 = 500,text2 = 5,text3 = 50,text4 = 20},
	[6] = {lv = 6,rmb = 500,text1 = 600,text2 = 6,text3 = 60,text4 = 20},	
  [7] = {lv = 7,rmb = 1000,text1 = 700,text2 = 7,text3 = 70,text4 = 20}, 
  [8] = {lv = 8,rmb = 2000,text1 = 800,text2 = 8,text3 = 80,text4 = 20}, 
  [9] = {lv = 9,rmb = 5000,text1 = 900,text2 = 9,text3 = 90,text4 = 20}, 
  [10] = {lv = 10,rmb = 10000,text1 = 1000,text2 = 10,text3 = 100,text4 = 20}, 
}

function resetView()
	widget.panel.bg.bar.obj:setVisible(currentTag == 0)
	widget.panel.bg.vip.obj:setVisible(currentTag == 0)
	widget.panel.bg.label.obj:setVisible(currentTag == 0)
	widget.panel.bg.btn.obj:setVisible(currentTag == 0)
  if isMax == false then
	   widget.panel.bg.btn.obj:setTouchEnabled(currentTag == 0)
  else
     widget.panel.bg.btn.obj:setTouchEnabled(false)
  end
	mineLayout:setVisible(currentTag == 0)
	widget.panel.bg.list.obj:setVisible(currentTag == 1)
	widget.panel.bg.list.obj:setTouchEnabled(currentTag == 1)
end

function resetVip()
   local vipLv,now,max = countLv.getVipLv(userdata.UserInfo.vipExp)
   widget.panel.bg.vip.num.obj:setStringValue(vipLv)
   widget.panel.bg.label.obj:setFontName(DEFAULT_FONT)
   widget.panel.bg.label.obj:setText("经验值："..now.."/"..max)
   widget.panel.bg.bar.ProgressBar.obj:setPercent(now/max*100)
   local mine_info = vipList[vipLv+1]
   if not mine_info then
      isMax = true
      mine_info = vipList[10]
      widget.panel.bg.btn.obj:loadTextures("cash/qietu/tymb/vipMax.png","cash/qietu/tymb/vipMax.png","cash/qietu/tymb/vipMax.png",0)
      widget.panel.bg.btn.obj:setTouchEnabled(false)
   end
   local mine_img = tool.findChild(mineLayout,"img","ImageView")
   local mine_lab = tool.findChild(mine_img,"lab","Label")
   local mine_vip = tool.findChild(mineLayout,"vip","ImageView")
   local mine_num = tool.findChild(mine_vip,"num","LabelAtlas")
   local mine_text_1 = tool.findChild(mineLayout,"text_1","Label")
   local mine_text_2 = tool.findChild(mineLayout,"text_2","Label")
   local mine_text_3 = tool.findChild(mineLayout,"text_3","Label")
   local mine_text_4 = tool.findChild(mineLayout,"text_4","Label")
   mine_lab:setFontName(DEFAULT_FONT)
   mine_lab:setText("累计充值"..mine_info.rmb.."元")
   mine_num:setStringValue(mine_info.lv)
   mine_text_1:setFontName(DEFAULT_FONT)
   mine_text_1:setText("登录奖励金币加成"..mine_info.text1.."%")
   mine_text_2:setFontName(DEFAULT_FONT)
   mine_text_2:setText("每天赠送"..mine_info.text2.."次抽奖机会")
   mine_text_3:setFontName(DEFAULT_FONT)
   mine_text_3:setText("充值额外赠送基础金额"..mine_info.text3.."%的金币")
   -- mine_text_4:setText("坐庄手续费减免"..mine_info.text4.."%")
end

function exit()
   if this then
      event.pushEvent("ON_BACK")
      event.unListen("ON_CHANGE_VIP",resetVip)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      mineLayout = nil
      this = nil
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
      if currentTag == 0 then
      	 currentTag = 1 
         widget.panel.bg.btn_l.obj:setBright(true)
         widget.panel.bg.btn_l.obj:setTouchEnabled(true)
         widget.panel.bg.btn_r.obj:setBright(false)
         widget.panel.bg.btn_r.obj:setTouchEnabled(false)
      else
      	 currentTag = 0 
         widget.panel.bg.btn_l.obj:setBright(false)
         widget.panel.bg.btn_l.obj:setTouchEnabled(false)
         widget.panel.bg.btn_r.obj:setBright(true)
         widget.panel.bg.btn_r.obj:setTouchEnabled(true)
      end
      resetView()
   end
end

function onUp(event)
   if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
      charge.create(widget.obj)
   end
end

widget = {
  	_ignore = true,
  	panel = {
   	  	bg = {
         	back = {
        		_type = "Button",
        		_func = onBack,
        	},
       		title = {_type = "ImageView"},
   			btn_l = {
	   		    _type = "Button",
	   		    _func = onBtn,
	   		    img = {_type = "ImageView"},
	   		},
	   		btn_r = {
	   		    _type = "Button",
	   		    _func = onBtn,
	   		    img = {_type = "ImageView"},
	   		},
	   		bar = {
	   		    _type = "ImageView",
	   		 	ProgressBar = {_type = "LoadingBar"},
	   		},
	   		vip = {
	   			_type = "ImageView",
	   		    num = {_type = "LabelAtlas"},
	   		},
	   		label = {_type = "Label"},
	   		btn = {
	   			_type = "Button",
	   			_func = onUp,
	   		},
	   		list = {_type = "ListView"},
	  	},
  	},
  	tmp = {
  		_type = "Layout",
  		line = {_type = "ImageView"},
  		img = {
  			_type = "ImageView",
  			lab = {_type = "Label"},
  		},
   		vip = {
   			_type = "ImageView",
   		    num = {_type = "LabelAtlas"},
   		},
   		text_1 = {_type = "ImageView"},
   		text_2 = {_type = "ImageView"},
   		text_3 = {_type = "ImageView"},
   		text_4 = {_type = "ImageView"},
  	},
} 