local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
local http = require"logic.http"
module("scene.selfInfo", package.seeall)

this = nil
boxList ={}
textInput = nil

local imageWidth = 100
local imageHeight = 100
local eventHash = {}

function create(parent)
    this = tool.loadWidget("cash/self_info",widget,parent,99)
    boxList = {[0]=widget.panel.bg.unKnow,[1]=widget.panel.bg.man,[2]=widget.panel.bg.female}
    for i,v in pairs(boxList) do
        v.obj:registerEventScript(function (event,data)
            if event == "releaseUp" then
               tool.buttonSound("releaseUp","effect_12")
               switchSex(i,true)
               if userdata.UserInfo.sex ~= i then
                  call(2101, i)
               end
            end
        end)
    end
    initInfo()
    event.listen("ON_CHANGE_GOLD",initInfo)
    event.listen("ON_CHANGE_VIP",initInfo)
    event.listen("ON_CHANGE_NAME",initInfo)
    event.listen("UPLOAD_PERSONAL_PHOTO", onUploadSucceed)
    event.listen("HEAD_ICON_CHANGE", onUserChangeImageSucceed)
    event.listen("ON_GET_QUEST", showDajiang)
    onUserChangeImageSucceed()
    --widget.nameEdit.obj:setPositionX(540)
    widget.nameEdit.obj:setTouchEnabled(true)
    initEditBox()
    -- call("getQuestCountList")
   return this
end

function showDajiang()
   local barCnt = userdata.UserInfo.hashKey["523"]
   local sevenCnt = userdata.UserInfo.hashKey["522"]
   if not barCnt then
      barCnt = 0
   end
   if not sevenCnt then
      sevenCnt = 0
   end
   widget.panel.bg.bar.obj:setText("大奖*"..barCnt)
   widget.panel.bg.seven.obj:setText("鲨鱼*"..sevenCnt)
end

function switchSex(id,click)
  print ("switchSex",id)
  for _,v in pairs(boxList) do
      v.obj:setSelectedState(false)
  end
  if click ~= true then
   boxList[id].obj:setSelectedState(true)
 end
end
function initInfo()
    widget.panel.bg.id.obj:setText(userdata.UserInfo.uidx)
    if type(userdata.UserInfo.phoneNumber) ~=  "userdata" then
       widget.panel.bg.account.obj:setText("已绑定")
       widget.panel.bg.account.obj:setColor(ccc3(255,255,255))
    end
    widget.panel.bg.name.obj:setText(userdata.UserInfo.nickName)
    widget.panel.bg.gold.obj:setText(userdata.UserInfo.owncash)
    -- local vipLv,now,max = countLv.getVipLv(userdata.UserInfo.vipExp)
    widget.panel.bg.vipLv.obj:setStringValue(userdata.UserInfo.vipLv)
    -- widget.panel.bg.vipNum.obj:setText(now.."/"..max)
    -- widget.panel.bg.vipBar.obj:setPercent(now/max*100)
    switchSex(userdata.UserInfo.sex)
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
     event.pushEvent("ON_BACK")
     event.unListen("ON_CHANGE_GOLD",initInfo)
     event.unListen("ON_CHANGE_VIP",initInfo)
     event.unListen("ON_CHANGE_NAME",initInfo)
     event.unListen("UPLOAD_PERSONAL_PHOTO", onUploadSucceed)
     event.unListen("HEAD_ICON_CHANGE", onUserChangeImageSucceed)
     event.unListen("ON_GET_QUEST", showDajiang)
     textInput = nil
     boxList = {}
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
function onChangeName(event)
    if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
        widget.nameEdit.obj:setPositionX(540)
        textInput:setText(userdata.UserInfo.nickName)
    end
end
function onChangeNameCancel(event)
    if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
        widget.nameEdit.obj:setPositionX(-1000)
    end
end
function onChangeNameCurrent(event) 
    if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
         widget.nameEdit.obj:setPositionX(-1000)
         local text = textInput:getText()
         if text == userdata.UserInfo.nickName then
            alert.create("名字未变化")
         else
            -- local _msg = http.urlencode(text)
            -- print("_msg",_msg)
            -- http.request(payServerUrl.."/ydream/login?type=99&param=".._msg,
            --   function(header,body,flag)
            --     if flag == false then
            --       alert.create("服务器连接失败")
            --       return 
            --     end
            --     local tab = cjson.decode(body)
            --     printTable(tab)
            --     if tab.result == "false" then
            --      alert.create("您输入的内容检测包含屏蔽字")
            --      return
            --     end
            --     call("changeCharName",tab.param)
            --   end)
            call("2001",text)
        end
    end
end
function onGoldGet(event)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
    exit()
    local main = package.loaded['scene.main']
    main.onShangcheng("releaseUp")
  end
end
function initEditBox()
   textInput = tolua.cast(CCEditBox:create(CCSizeMake(411,76),CCScale9Sprite:create("image/empty.png")),"CCEditBox")
   -- textInput = tolua.cast(TextField:create(),"TextField")
   widget.nameEdit.input_bg.obj:addNode(textInput)
   -- textInput:setPosition(ccp(-233+200,159))
   textInput:setPosition(ccp(5,-5))
   textInput:setAnchorPoint(ccp(0,0))
   textInput:setFontColor(ccc3(255,255,255))
   textInput:setFontSize(40)
   textInput:setFontName(DEFAULT_FONT)
   textInput:setReturnType(1)
   textInput:setMaxLength(20)
   textInput:setPlaceHolder("输入昵称")
   textInput:setText("")
   textInput:setVisible(true)

   local function editBoxTextEventHandler(strEventName, pSender)
      print(textInput:getText())
      print(strEventName)
      local str = textInput:getText()
      print("#str!!!!!!!!!!!",#str,str)
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         local i = 1
         local tb = {}
         while i <= #str do
            c = str:sub(i,i)
            ord = c:byte()
            if ord > 128 then
               table.insert(tb,str:sub(i,i+2))
               i = i+3
            else
               table.insert(tb,c)
               i = i+1
            end
            if #tb > 6 then
               alert.create("用户名不能超过6个字符！")
               textInput:setText("")
               return
            end
         end
         textInput:setText(table.concat(tb))
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   widget.nameEdit.input_bg.obj:setTouchEnabled(true)
   widget.nameEdit.input_bg.obj:registerEventScript(function (event)
          if event == "releaseUp" then
             -- tool.buttonSound("releaseUp","effect_12")
             print("textInput attachWithIME")
             textInput:attachWithIME()
             -- textInput:setPosition(ccp(-233+200,159))
             textInput:setPosition(ccp(5,-5))
          end
   end)
end

function onUpload(event)
   if event == "releaseUp" then
      print("##########onUploadLocal")
      C_upload("http://120.27.156.196:8080/User/WebForm1.aspx","cash/qietu/tymb/xiaopuhuo.png",1,0,0) 
      -- local callback=function(t)
      --    printTable(t)
      --    -- fileManager.insertUpload({path=t.fullPath,type=1,seconds=0})
      --    -- call("uploadImage")      
      --    C_upload("http://120.27.156.196:8080/User/WebForm1.aspx",t.fullPath,1,0,0)   
      -- end
      -- luaoc.callStaticMethod("AppController","chooseImage",{width=imageWidth,height=imageHeight,type=1,callback=callback})
      -- setTakePhotoFuncCallBack(callback)
      -- luaj.callStaticMethod("cc/yongdream/nshx/Util","startPhoto",{"onUploadFromLocal",2,1,imageWidth,imageHeight})   
   end
end

function onUploadSucceed(data)
   -- local uuid = data.fileName
   -- local arr2 = splitString(data.fileName,splitURLChar)
   -- local uuid = nil
   -- if #arr2 >= 2 then
   --    uuid = table.concat(arr2,"/")
   --    uuid = splitString(uuid,"")[1]
   -- end
   if data and type(data) == type({}) then
      if data.type == 1 then --头像
         call(13001,data.fileName)
         alert.create("头像上传成功")
      end
   end
end

function onUserChangeImageSucceed(data)
   print("onUserChangeImageSucceed")
   -- tool.loadRemoteImage(eventHash, widget.panel.bg.image.img.obj, userdata.UserInfo.uidx)
end

widget = {
   _ignore = true,
   panel = {
      bg = {
         back = {_type="Button",_func=onBack},
         image = {
            img = {_type = "ImageView"},
            upload = {
               _type="Button",
               text = {_type="Label"},
               _func = onUpload,
            },
         },
         id = {_type="Label"},
         account = {_type="Label"},
         name = {_type="Label"},
         man = {_type = "CheckBox",},
         female = {_type = "CheckBox",},
         unKnow = {_type = "CheckBox",},
         man_text = {_type="Label"},
         female_text = {_type="Label"},
         unKnow_text = {_type="Label"},
         gold = {_type="Label"},
         vipNum = {_type="Label"},
         bar= {_type="Label"},
         seven= {_type="Label"},
         vipLv = {_type = "LabelAtlas"},
         vipBar = {_type = "LoadingBar"},
         changeName =  {
            _type="Button",_func =onChangeName,
            text = {_type="Label"},
            text_shadow = {_type="Label"},
         },
         gold_get= {
            _type="Button",
            text = {_type="Label"},
            text_shadow = {_type="Label"},
            _func  = onGoldGet,
         },
      },
      

   },
   nameEdit = {
      input_bg = {_type = "ImageView"},
      back = {_type="Button",_func=onChangeNameCancel},
      text2 = {_type="Label"},
      text = {_type="Label"},
      btn = {
         _type="Button",_func=onChangeNameCurrent,
         text = {_type="Label"},
         text_shadow = {_type="Label"},
      },
   },

}
