local tool = require"logic.tool"
local event = require"logic.event"

module("scene.service", package.seeall)

this = nil
subWidget = nil
local defult_width = 860

function create(parent)
   this = tool.loadWidget("cash/service",widget,parent,99)
   -- resetText()

   if platform == "IOS" then
     widget.panel.bg.bottom.obj:setVisible(false)
   end

   return this
end

textList = {
	  -- [1] = {size = 40,height = 52,offset = 80,list = {[1] = {r = 255,g = 249,y = 71,text = "游戏下载地址:"},
		 --    										                         [2] = {r = 255,g = 255,y = 255,text = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"}}},
    -- [1] = {size = 40,height = 52,offset = 80,list = {[1] = {r = 255,g = 249,y = 71,text = "联通，电信手机用户暂时无法使用话费充值，推荐使用支付宝，银行卡，话费充值卡进行充值，感谢您的支持！"}}},
    [1] = {size = 40,height = 52,offset = 80,r = 255,g = 249,y = 71,text = "1.充值后金币未到账怎么办？"},
    [2] = {size = 40,height = 52,offset = 0,r = 255,g = 255,y = 255,text = "游戏中充值购买金币都是立即到账的，如果出现5分钟内未到账的情况，请联系客服QQ号码2045339517反馈你的ID和充值时间，充值金额等，客服核实后将尽快补发，并根据延期到账的时间额外赠送20%~50%金币作为补偿。"},
    [3] = {size = 40,height = 52,offset = 80,r = 255,g = 249,y = 71,text = "2.充值榜奖励的金币如何领取？"},
    [4] = {size = 40,height = 52,offset = 0,r = 255,g = 255,y = 255,text = "当日24点名列充值榜前20名的玩家，可以在24点以后，点击昨日充值榜找到自己的名次，在最后一列奖励金币处点击按钮领取奖励。"},
    [5] = {size = 40,height = 52,offset = 80,r = 255,g = 249,y = 71,text = "3.为什么有时候下注了没有获得奖励？"},
    [6] = {size = 40,height = 52,offset = 0,r = 255,g = 255,y = 255,text = "我们的游戏是网络游戏，是否成功下注以服务器收到的下注信息为准，如果手机网络情况不佳，或者在倒计时最后3秒内下注，有可能倒计时结束前服务器未收到，这种情况下不会扣除下注金币，也不会获得奖励金币，请在较好的网络情况下进行游戏。"},
}

function resetText()
   widget.panel.bg.list.obj:setVisible(true)
   widget.panel.bg.list.obj:setTouchEnabled(true)
   widget.panel.bg.list.obj:removeAllItems()
   print("resetText---------------------",#textList)
   for i=1,#textList do
   	   local textInfo = textList[i]
   	   if textInfo then
   	   	  local str = ""
	   	    local height = textInfo.height
          local textLabel = Label:create()
   	   	  local lab = Label:create()
   		    lab:setText(textInfo.text)
   		    lab:setFontSize(textInfo.size)
   	      lab:setFontName(DEFAULT_FONT)
   	      local totalWidth = lab:getContentSize().width
          print("----",totalWidth,defult_width)
   		    if totalWidth > defult_width then
             height = math.ceil(totalWidth/defult_width)*height
         	   textLabel:ignoreContentAdaptWithSize(false)
   		    end
          print("----!!!",totalWidth,defult_width,height)
          textLabel:setSize(CCSize(defult_width,height))
          textLabel:setText(textInfo.text)
          textLabel:setFontSize(textInfo.size)
          textLabel:setFontName(DEFAULT_FONT)
          textLabel:setAnchorPoint(ccp(0,0))
          textLabel:setColor(ccc3(textInfo.r,textInfo.g,textInfo.y))
          textLabel:setPosition(ccp(20,textInfo.offset))
		      local heightAdd = 0
		      if i == 1 then
		  	     heightAdd = 40
		      end
   		    local layout = Layout:create()
          -- layout:setBackGroundColorType(LAYOUT_COLOR_GRADIENT)
   		    layout:setSize(CCSize(defult_width,height+textInfo.offset+heightAdd))
   		    layout:addChild(textLabel)
          if textInfo.offset > 0 then
              local image = ImageView:create()
              image:loadTexture("cash/qietu/tymb/hfengexian.png")
              image:setPosition(ccp(layout:getSize().width/2,textInfo.offset/2))
              layout:addChild(image)
          end
   		    widget.panel.bg.list.obj:pushBackCustomItem(layout)
   	   end
   end
end

function exit()
  if this then
      event.pushEvent("ON_BACK")
      widget.panel.bg.list.obj:removeAllItems()
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end

function onBack(event)
  if event == "releaseUp" then
     exit()
  end
end

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	title =  {_type="ImageView",},
   		bottom = {_type = "ImageView"},
   		list = {
        _type = "ListView",
        panel_1 = {
          _type = "Layout",
          label_1 = {_type = "Label"},
          label_2 = {_type = "Label"},
          line = {_type = "ImageView"},
        },
        panel_2 = {
          _type = "Layout",
          label_1 = {_type = "Label"},
          label_2 = {_type = "Label"},
          line = {_type = "ImageView"},
        },
        panel_3 = {
          _type = "Layout",
          label_1 = {_type = "Label"},
          label_2 = {_type = "Label"},
        },
      },
  	},
  },
  scroll_bg = {
  	scroll_bar = {},
  },
}
