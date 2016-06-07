local tool = require"logic.tool"
local nc = require"logic.nc"
module("scene.login", package.seeall)

this = nil
textInput = nil
function create()
   this = tool.loadWidget("cash/login_scene",widget)
   nc.connect()
   initEditBox()
   return this
end

function initEditBox()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(411,76),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   widget.account_bg.obj:addNode(textInput)
   textInput:setPosition(ccp(0,0))
   textInput:setFontColor(ccc3(255,255,255))
   textInput:setFontSize(40)
   textInput:setFontName(DEFAULT_FONT)
   textInput:setReturnType(1)
   textInput:setMaxLength(10)
   textInput:setPlaceHolder("输入帐号")
   textInput:setText("")
   textInput:setVisible(true)
 
   local function editBoxTextEventHandler(strEventName, pSender)
      print(textInput:getText())
      print(strEventName)
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.account_bg.obj:setTouchEnabled(true)
   widget.account_bg.obj:registerEventScript(function (event)
                                                if event == "releaseUp" then
                                                   textInput:attachWithIME()
                                                   textInput:setPosition(ccp(0,0))
                                                end
   end)
end

function enter()
   
end

function exit()
   if this then
      textInput:removeFromParentAndCleanup(true)
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
      textInput = nil
   end
end

function enterTransitionFinish()
    --call("login", 0, "zjl")
end

function exitTransitionStart()

end

function onLogin(event)
   if event == "releaseUp" then
      local str = textInput:getText()
      if str ~= "" then
         call(1001, "1", str,tonumber(appSrc))
      end
   end
end

widget = {
   _ignore = true,
   account_bg = {_type = "ImageView"},
   account_name = {_type = "Label"},
   login_btn = {_type = "Button", 
                label = {_type = "Label"},
                _func = onLogin,
   },
}
