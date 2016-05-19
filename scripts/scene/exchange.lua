local tool = require"logic.tool"
local event = require"logic.event"

module("scene.about", package.seeall)

this = nil
subWidget = nil

function create(parent)
   this = tool.loadWidget("cash/about",widget,parent,99)
   hideInfo()
   return this
end

function hideInfo()
  widget.panel.bg.name.text.obj:setText("富豪水果机")
  widget.panel.bg.num.text.obj:setText("V1.0")
  widget.panel.bg.QQ.obj:setVisible(false)
end

function exit()
  if this then
      event.pushEvent("ON_BACK")
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

widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       	title = {_type="ImageView",},
   		icon = {_type = "ImageView"},
   		name = {
   		   _type = "Label",
   		   text = {_type = "Label"},
   		},
   		num = {
   		   _type = "Label",
   		   text = {_type = "Label"},
   		},
   		QQ = {
   		   _type = "Label",
   		   text = {_type = "Label"},
   		},
   		tip = {_type = "ImageView"},
   		label = {_type = "Label"},
  	},
  },
}