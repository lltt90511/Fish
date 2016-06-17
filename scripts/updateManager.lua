isClient = true
platform = C_platform()
PLATFORM = platform
serverList = {}
Screen = {width = 1080,height=1920}
Main_Screen = {top = 129,topN=46,useHeight = 960-129-110,bottom = 110}
RestartUrl = "http://nshx.youngdream.cc/update/restart.html"

--DEFAULT_FONT = "Hiragino Sans GB W6"
if platform == "IOS" then
   DEFAULT_FONT = "Avenir-Black"
elseif platform =="Windows" then
   DEFAULT_FONT ="Microsoft YaHei UI Bold"
else
   DEFAULT_FONT ="Droid Sans Fallback"

end
--DEFAULT_FONT = "STHeiti Medium"

NETWORK_TYPE = 2--0、无网络 1、2g3g 2、wifi他、
require"common.system.core"
md5 = require "md5"
require"config"
require "deploy"
require "appChannel"
local http = require"logic.http"
require "umeng"
require "scene.alert"
require "logic.guideUpload"
luaoc = require"luaoc"
luaj = require "luaj"
cjson = require "cjson"
print("version:",scriptsVersion)
uploadURL = "http://115.236.35.202:9237/file_uploader.php"
downloadURL = "http://115.236.35.202:9237/"
GUIDE_CHAR_ID = 0
GUIDE_VIDEO_ID = nil
local updateManager = {}
local path = CCFileUtils:sharedFileUtils():getWritablePath()
print(path)
loginServerUrl = ""
payServerUrl = ""
local serverVersion = nil
local versionInfoCnt = nil
local versionInfoHasCnt = nil
local newFileCnt = nil
local newFileHasCnt = nil
local fileHash = {}
local scene = nil
local layer = nil
local label = nil
local logFile = nil
local successFile = nil
local finishCallBack = nil
local bar = nil
local logHash = nil
local finishAnim = nil
local finishLoad = nil
local haveUpdate = false
local appstoreVersion = nil
defaultList = {}
C_IsUpdating(1)
C_IsImageEncoded(isImageEncoded)

SERVER_LIST_PATH = nil
function download(url,filePrefix,_type,index,writePath)
   if writePath == nil then
      writePath = ""
   end
   C_download(url,filePrefix,_type,index,writePath)
end
local updateServerListRequest = {}
function downloadServerList()
   -- download(updateDownLoadURL,"update/serverList.json",5,0)
   if isappstore then
      SERVER_LIST_PATH = "update/appstoreServerList.json"
   else 
      SERVER_LIST_PATH = "update/serverList.json"
   end
   -- print("downloadServerList!!!!!!!!!!!!!!!!!!!!!!!!!",updateDownLoadURL)
   -- local curlId = http.request(updateDownLoadURL..SERVER_LIST_PATH,onDownloadServerList)
   local curlId = http.request(updateDownLoadURL.."updateFiles/cfg.json",onDownloadServerList)
   table.insert(updateServerListRequest,curlId)
end

function getStrFromFile(fileName)
   local file = io.open(path..fileName,"r")
   local line = ""
   if file then
      for str in file:lines() do
         line = line .. str
      end
      file:close()
   end
   return line
end

function getGameLoginFile(fileName)
   local file = io.open(path..fileName,"r")
   if file == nil then
      file = io.open(path..fileName,"w")
   end
   return file
end
function finishUpdate()
   finishLoad = true
   bar.update(100)
   -- performWithDelay(function() bar.exit() layer:addChild(jumpBtn()) end,0)
   performWithDelay(function() bar.exit() end,0)
   finish()
   -- 有更新并且更新完成
   if haveUpdate then
      local file = getGameLoginFile("GameFirstUpdate.txt")
      local str = file:read("*all")
      print("haveUpdate",str)
      -- 2为第一次更新完成
      if str == nil or str == "" then
         file:write("2")
         file:close()
         -- uploadGuide(2)
      end
   end
end
function finish()
   if not getFirstLogin() then
      gameInit()
   else
      if finishAnim then
         gameInit()
      end
   end
end
function getFirstLogin()
   -- local file = getGameLoginFile("GameFirstLogin.txt")
   -- local str = file:read("*all")
   -- print("getFirstLogin",str)
   -- if str == nil or str == "" then
   --    file:write("1")
   --    file:close()
   --    -- if platform == "IOS" then
   --    --   luaoc.callStaticMethod("AppController","getDeviceId",{callback=onDeviceId})
   --    -- end
   --    -- uploadGuide(1)
   --    return true
   -- end
   return false
end
function firstLaunch()
   local file = getGameLoginFile("GameFirstLaunch.txt")
   local str = file:read("*all")
   print("firstLaunch",str)
   -- 第一次打开应用
   if str == nil or str == "" then
      file:write("0")
      file:close()
      -- uploadGuide(1)
   end
end
function gameInit()
   if timehandler then
      unSchedule(timehandler)
      timehandler = nil
   end
   -- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Anim/sceneAnim_01/sceneAnim_01.ExportJson")
   require"init"
end
function onDeviceId(str)
   -- uploadGuide(1)
end
function setUploadURL(url)
   uploadURL = url
end
function setDownloadURL(url)
   downloadURL = url
end
function setGuideCharId(id)
   GUIDE_CHAR_ID = id
   print("GUIDE_CHAR_ID",id)
end
function setGuideVideoId(id)
   if id then
      GUIDE_VIDEO_ID = id
      print("GUIDE_VIDEO_ID",id)
   end
end

function setLoginServerUrl(url)
   print ("setLoginServerUrl",url)
   loginServerUrl = url
end

function setPayServerUrl(url)
   print("setPayServerUrl",url)
   payServerUrl  = url
end

function onDownloadServerList(header,body,flag)
   print("onDownloadServerList!!!!!!!!!!!!!!!!!!")
   if flag ==false then
      
      return 
   end
   for i,v in pairs(updateServerListRequest) do
      http.cancelRequest(v)
   end
   updateServerListRequest = {}
   print("@@@@@@@@@@@@@@@@@download server list@@@@@@@@@@@@@@@@@@@@")
   print("body",body)
   --local line = getStrFromFile(fileName)
   -- print(body)
   local tab = cjson.decode(body)
   -- printTable(tab)
   if tab.restartUrl then
      RestartUrl = tab.restartUrl
   end
   for k,v in pairs(tab) do
      table.insert(serverList,v)
   end
   defaultList = tab.defaultAnnounce
   if defaultList == nil then
      defaultList = {}
   end
   --uploadURL = tab.uploadURL
   --downloadURL = tab.downloadURL
   serverVersion = tab.build
   if tab.AppVersion then
      version = tab.AppVersion
   end
   setServerUrl(tab.loginServerUrl)
   appstoreVersion = tab.appstoreversion
   --loginServerUrl = ""
   --appstore审核中
   -- if isappstore ~= nil and isappstore == true and tab.appstorechecking ~= nil and tab.appstorechecking == 1 then
   --    finishUpdate()
   --    return
   -- end
   firstLaunch()
   if scriptsVersion >= tab.build  then
      local flag = checkUnfinishedFile()
      if flag == true then
         print("88888888888888888 true")
         finishUpdate() 
      else
         print("88888888888888888 false")
         finishCallBack = finishUpdate
      end
   else
      print("ready to download updateList")
      haveUpdate = true
      --download(updateDownLoadURL,"update/updateList.json",6,0)
      http.request(updateDownLoadURL.."updateFiles/updateList.json",onDownloadUpdateList)
   end
end

function checkUnfinishedFile()
   print("checkUnfinishedFile")
   logFile = io.open(path.."updateFiles/log.txt","r")
   successFile = io.open(path.."updateFiles/success.txt","r")
   local flag = true
   if logFile and successFile then
      local successHash = {}
      for line in successFile:lines() do
         print(line)
         successHash[line] = true
      end
      successFile:close()
      successFile = io.open(path.."updateFiles/success.txt","a+")
      newFileCnt = 0
      newFileHasCnt = 0
      logHash = {}
      for line in logFile:lines() do
         newFileCnt = newFileCnt + 1
         local tab = splitString(line," ")
         logHash[tab[1]] = true
         if successHash[tab[1]] == nil then
            flag = false
            download(updateDownLoadURL,tab[2],8,0,tab[1])
         else
            newFileHasCnt = newFileHasCnt + 1
         end
      end
      logFile:close()
      if flag == false then
         -- label:setString("更新资源："..newFileHasCnt.."/"..newFileCnt)
         bar.show("更新版本信息：",newFileHasCnt,newFileCnt)
      else
         successFile:close()
      end
   end
   return flag
end

function checkIOSCanUpdate(hash)
   if isappstore ~= nil and isappstore == true then
      print("###############################")
      print("checkIOSCanUpdate")
      local _maxCanBuild = -1
      for k, v in pairs(hash) do
         if v.appstoreversion == appstoreVersion and v.build > _maxCanBuild then
            _maxCanBuild = v.build
         end
      end
      if _maxCanBuild ~= -1 then
         serverVersion = _maxCanBuild
      end
      print(serverVersion)
      print("###############################")
   end
end

function onDownloadUpdateList(header,body)
   print("onDownloadUpdateList",scriptsVersion,serverVersion)
   --local line = getStrFromFile(fileName)
   local tab = cjson.decode(body)
   -- printTable(tab)
   local hash = {}
   for k, v in pairs(tab.updateList) do
      hash[v.build] = v
   end
   -- printTable(hash)
   checkIOSCanUpdate(hash)
   if scriptsVersion >= serverVersion then
      local flag = checkUnfinishedFile()
      if flag == true then
         finishUpdate()
      else
         finishCallBack = finishUpdate
      end
      return
   end
   if hash[serverVersion] and hash[scriptsVersion] and hash[serverVersion].version == hash[scriptsVersion].version then
      local flag = checkUnfinishedFile() 
      local func = function ()
         versionInfoCnt = 0
         versionInfoHasCnt = 0
         for i = 1, serverVersion do
            if hash[i] then
               versionInfoCnt = versionInfoCnt + 1
               download(updateDownLoadURL,"updateFiles/v"..i..".json",7,0)
            end
         end
         -- label:setString("更新版本信息：0/"..versionInfoCnt)
         bar.show("更新版本信息：",0,versionInfoCnt)
         finishCallBack = finishUpdate
      end
      if flag == true then
         func()
      else
         finishCallBack = function()
            package.loaded["config"] = nil 
            require"config"
            if scriptsVersion == serverVersion then
               finishUpdate()
            else
               func()
            end
         end
      end
   else
      luaj.callStaticMethod("cc/yongdream/nshx/Util","deleteDirectory",{path.."update"})
      luaoc.callStaticMethod("AppController","deleteDirectory",{path=path.."update"})
      package.loaded["config"] = nil
      require"config"
      if scriptsVersion >= serverVersion then
         finishUpdate()
      elseif hash[scriptsVersion] and hash[serverVersion] and hash[serverVersion].version == hash[scriptsVersion].version then
         downloadServerList() --客户端与服务端版本号不同，引擎版本号相同，重新进入更新
      else
         if platform == "Android" then
            alert.create("检测到新版本，是否前去更新？",nil,function()
               luaj.callStaticMethod("cc/yongdream/nshx/mainActivity","goToDownLoad",{hash[serverVersion].url})
            end,nil,"立即更新","暂不更新")
         elseif platform == "IOS" then
            alert.create("请前往APPSTORE重新下载app")
         else
            label:setString("请重新下载app")
         end
         print("please download the latest app")
      end
   end
end

function checkFileLegal(savePath)
   local s1,e1 = string.find(savePath,".lua")
   local s2,e2 = string.find(savePath,".luac")
   local s3,e3 = string.find(savePath,".ogg")
   local s4,e4 = string.find(savePath,".caf")

   if s2 ~= nil then --.luac
      if PLATFORM == "IOS" then
         return true
      end
      return false
   elseif s1 ~= nil then --.lua
      if PLATFORM ~= "IOS" then
         return true
      end
      return false
   elseif s3 ~= nil then --.ogg 
      if PLATFORM == "Android" then
         return true
      end
      return false
   elseif s4 ~= nil then --.caf 
      if PLATFORM == "IOS" then
         return true
      end
      return false
   end

   return true
end

function onDownloadVersionInfo(fileName)
   print("fileName!!!!!!!!!!!!!!!",fileName)
   versionInfoHasCnt = versionInfoHasCnt + 1
   -- label:setString("更新版本信息："..versionInfoHasCnt.."/"..versionInfoCnt)
   bar.show("更新版本信息：",versionInfoHasCnt,versionInfoCnt)
   local line = getStrFromFile(fileName)
   local tab = cjson.decode(line)
   local version = tonumber(splitString(splitString(fileName,"updateFiles/v")[1],".json")[1])
   -- printTable(tab)
   print(version)
   for k, v in pairs(tab) do
      if (fileHash[v.savePath] == nil or fileHash[v.savePath].version < version) and checkFileLegal(v.savePath) == true then
         fileHash[v.savePath] = v
         fileHash[v.savePath].version = version
      end
   end
   if versionInfoHasCnt == versionInfoCnt then
      os.remove(path.."updateFiles/log.txt")
      os.remove(path.."updateFiles/success.txt")
      logFile = io.open(path.."updateFiles/log.txt","a+")
      successFile = io.open(path.."updateFiles/success.txt","a+")
      newFileCnt = 0
      newFileHasCnt = 0
      logHash = {}
      for k, v in pairs(fileHash) do
         newFileCnt = newFileCnt + 1
         logFile:write(v.savePath.." "..v.url.."\n")
         logHash[v.savePath] = true
         download(updateDownLoadURL,v.url,8,0,v.savePath)
      end
      logFile:close()
      -- label:setString("更新资源：0/"..newFileCnt)
	  bar.show("更新资源：",0,newFileCnt)
   end
end

function onDownloadNewFile(fileName)
   if logHash[fileName] == true then
      newFileHasCnt = newFileHasCnt + 1
      -- label:setString("更新资源："..newFileHasCnt.."/"..newFileCnt)
      bar.show("更新资源：",newFileHasCnt,newFileCnt)
      successFile:write(fileName.."\n")
      successFile:flush()
      if newFileCnt == newFileHasCnt then
         successFile:close()
         finishCallBack()
      end
   end
end

function onChangedNetwork(t)
   NETWORK_TYPE = t
   print("updateManager network type"..NETWORK_TYPE)
   if NETWORK_TYPE == 0 then
      label:setString("请检查网络")
   else
      downloadServerList()
   end
end

function main()
   regUpdateListener()
   
   -- if platform ~= "Windows" and platform ~= "MAC" then
   --    Screen.width = CCEGLView:sharedOpenGLView():getFrameSize().width
   --    Screen.height = CCEGLView:sharedOpenGLView():getFrameSize().height
   --    Screen.height = 640 /Screen.width * Screen.height
   --    Screen.width = 640
   --    if Screen.height < 960 then
   --       Screen.height = 960
   --    end
   -- else
   --    Screen.height = 640 /Screen.width * Screen.height
   --    Screen.width = 640
   -- end
   -- Main_Screen.useHeight = Main_Screen.useHeight + Screen.height - 960
   Screen.width  = 1080
   Screen.height = 1920
   Main_Screen.useHeight = 0
   CCEGLView:sharedOpenGLView():setDesignResolutionSize(Screen.width, Screen.height, 2);
   
   scene = CCScene:create()
   layer = CCLayer:create()
   label = CCLabelTTF:create("",DEFAULT_FONT,50)
   label:setAnchorPoint(0.5,0.5)
   label:setPosition(Screen.width/2,300)
   scene:addChild(layer)
   layer:addChild(label,100)
   -- layer:addChild(showBgAnim())
   CCDirector:sharedDirector():runWithScene(scene)
   
   local loadingBar = require "scene.loadingBar"
   bar = loadingBar.create(newFileCnt,nil,layer)
   
   if platform == "Windows" or platform == "MAC" then
      downloadServerList()
   end
end

function jumpBtn()
   local touch = TouchGroup:create()
   touch:setTouchEnabled(true)
   local ly = Layout:create()
   ly:setTouchEnabled(true)
   ly:setSize(CCSize(Screen.width,Screen.height))
   ly:setPosition(ccp(0,0))
   touch:addWidget(ly)
   local ok = Button:create()
   ok:loadTextures("nsUI/tiaoguo01.png","nsUI/tiaoguo02.png","nsUI/tiaoguo02.png",0)
   ok:setPosition(ccp(80, 36))
   ok:registerEventScript(
      function (event)
         if event == "releaseUp" then
            finishAnim = true
            if finishLoad then
               finish()
            end
         end
      end
   )
   ok:setTouchEnabled(true)
   ly:addChild(ok)
   return touch
end

timehandler = nil
function showBgAnim()
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Anim/sceneAnim_01/sceneAnim_01.ExportJson")
   local armature = CCArmature:create("sceneAnim_01")
   local anim = armature:getAnimation()
   -- armature:setAnchorPoint(ccp(0.5,0.5))
   armature:setPosition(ccp(Screen.width/2,Screen.height/2))
   anim:playWithIndex(0,-1,-1,0)
   anim:registerEventScript(function(event)
                               if event == "COMPLETE" then
                                  timehandler = performWithDelay(
                                     function()
                                        if anim then
                                           anim:playWithIndex(0,-1,-1,0)
                                        end
                                     end, 20)
                                  finishAnim = true
                                  if finishLoad then
                                     finish()
                                  end
                               end
                            end
   )
   return armature
end

function onDownloadError(t,nowIndex)
   if t == 7 or t == 8 then
      --label:setString("更新失败，重启或重装应用")
   end
end

function onProgress(t,nowIndex,per)
   
end

function onDownload(t,fileName,nowIndex,bytes)
   print(t,fileName,nowIndex,bytes)
   if t == 5 then --自动更新serverList
      onDownloadServerList(fileName)
   elseif t == 6 then --自动更新updateList
      onDownloadUpdateList(fileName)
   elseif t == 7 then --更新版本信息文件
      onDownloadVersionInfo(fileName)
   elseif t == 8 then --更新资源及脚本
	  onDownloadNewFile(fileName) 
   end
end

function regUpdateListener()
   regListner("onChangedNetwork",onChangedNetwork)
   regListner("onDownload", onDownload)
   regListner("onDownloadError", onDownloadError)
   regListner("onProgress", onProgress)
end

function unRegUpdateListener()
   
end
function test()
   local data =require"battle.data"
   data.setRunningInfo("xxx",true)
   local res =data.getRunningInfo()
   if res.xxx == "true" then
      print ("true")
   end
   print ("false")
end
--print (md5.sumhexa("123456"))
function getStrFromFile2(fileName)
   local file = io.open(fileName,"r")
   local list = {}
   if file then
      for str in file:lines() do
         table.insert(list,str)
      end
      file:close()
   end
   return list
end



--[[
yongdream serial file
---------------------------
sahkgsdjkfd892342nda89cyhacu
---------------------------
]]
function findChild(widget,name,type)
   if not type then
      type = "Widget"
   end
   --print(widget:getChildByName(name))
   return tolua.cast(widget:getChildByName(name), type)
end


function initEditBox(parent,label,initText,mode,flag,minLen,maxLen, compare,ismail)
   local textInput = tolua.cast(CCEditBox:create(CCSizeMake(360,56),CCScale9Sprite:create("Image/empty.png")),"CCEditBox")
   parent:addNode(textInput)
   textInput:setPosition(ccp(-50,0))
   textInput:setFontColor(ccc3(255,255,255))
   textInput:setFontSize(30)
   textInput:setFontName(DEFAULT_FONT)
   textInput:setReturnType(1)
   textInput:setMaxLength(maxLen)  
   textInput:setText("")
   textInput:setVisible(true)
   label:setVisible(true)
   label:setText("")
   textInput:setPlaceHolder(initText)
   textInput:setInputFlag(flag)
   textInput:setInputMode(mode)
   
   local editBoxTextEventHandler = function (strEventName, pSender)
      local str = textInput:getText()
      if str == "" then
         return 
      end
      if strEventName == "return" or strEventName == "ended" then
         
      end
   end
   textInput:registerScriptEditBoxHandler(editBoxTextEventHandler)
   parent:setTouchEnabled(true)
   parent:registerEventScript(function (event)
                                 if event== "releaseUp" then
                                    textInput:attachWithIME()
                                    textInput:setPosition(ccp(-50,0))
                                 end
   end)
   return textInput

end
alertFunc = nil
function alert(text)
   if alertFunc then
      alertFunc(text)
   end
end
function registerKey()
   if platform ~= "Windows" and platform ~= "MAC" then
      Screen.width = CCEGLView:sharedOpenGLView():getFrameSize().width
      Screen.height = CCEGLView:sharedOpenGLView():getFrameSize().height
      Screen.height = 640 /Screen.width * Screen.height
      Screen.width = 640
      if Screen.height < 960 then
         Screen.height = 960
      end
   else
      Screen.height = 640 /Screen.width * Screen.height
      Screen.width = 640
   end
   Main_Screen.useHeight = Main_Screen.useHeight + Screen.height - 960
   CCEGLView:sharedOpenGLView():setDesignResolutionSize(Screen.width, Screen.height, 2)

   local scene = CCScene:create()
   local this = TouchGroup:create()
   local reader = GUIReader:shareReader()
   local widget = reader:widgetFromJsonFile("nshx/registerKey.json")
   this:addWidget(widget)
   scene:addChild(this)
   local name = findChild(widget,"name","Widget")
   local key = findChild(widget,"key","Widget")
   local key_text = findChild(widget,"key_text","Label")
   local name_text = findChild(widget,"name_text","Label")
   local btn = findChild(widget,"confirm_btn","Button")
   local al = findChild(widget,"alert","Widget")
   local bg = findChild(al,"bg","Widget")
   local alLabel = findChild(bg,"label","Label")
   local altitle = findChild(bg,"tital","Label")
   local ok_btn = findChild(bg,"ok_btn","Button")
   local na = initEditBox(name,name_text,"请输入名字",kEditBoxInputModeSingleLine,kEditBoxInputFlagSensitive,5,10000,nil,false)
   local ser = initEditBox(key,key_text,"请输入序列号",kEditBoxInputModeSingleLine,kEditBoxInputFlagSensitive,5,1000,nil,false)
   al:setVisible(false)
   al:setTouchEnabled(false)
   alertFunc = function (text)
      bg:setVisible(true)
      al:setVisible(true)
      al:setTouchEnabled(true)
      ok_btn:setTouchEnabled(true)
      altitle:setText("")
      alLabel:setText(text)
      ok_btn:registerEventScript(function (event)
                                    if event == "releaseUp" then
                                       al:setVisible(false)
                                       al:setTouchEnabled(false)
                                       ok_btn:setTouchEnabled(false)     
                                    end
      end)


   end
   CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Anim/loadingmini2/loadingmini2.ExportJson")
   btn:setTouchEnabled(true)
   btn:registerEventScript(function (event)
                              if event == "releaseUp" then
                                 local armature = CCArmature:create("loadingmini2")
                                 local anim = armature:getAnimation()
                                 anim:playWithIndex(0)
                                 al:addNode(armature)
                                 armature:setPosition(ccp(Screen.width/2,Screen.height/2))
                                 local macTable = C_getMACAddress()
                                 local url = "http://mail.youngdream.cc:8088/ydream/login?syskey=ymnshx&type=98&userName="..na:getText().."&userPasswd="..ser:getText().."&mac="..macTable[1]
                                 print (url)
                                 http.request(url,function (header,body,flag)
                                                 --saveSerial(randomKey())
                                                 armature:removeFromParentAndCleanup(true)
                                                 btn:setTouchEnabled(true)
                                                 al:setVisible(false)
                                                 al:setTouchEnabled(false)
                                                 if flag ==false then
                                                    alert("注册服务器不在线？")
                                                    return 
                                                 end
                                                 print (header)
                                                 print(body)
                                                 local result = cjson.decode(body)
                                                 
                                                 if result.errCode == 0 then
                                                    saveSerial(result.serial)
                                                    alert("注册成功，请不要移动或者删除serial.key,并且请重启游戏！")
                                                 else
                                                    alert(result.errMsg)
                                                 end
                                 end)
                                 al:setVisible(true)
                                 al:setTouchEnabled(true)
                                 btn:setTouchEnabled(false)
                                 bg:setVisible(false)

                                 --alertFunc("感谢注册")
                              end
   end)
   CCDirector:sharedDirector():runWithScene(scene)
end
function checkSerial(str)
   if string.len(str) ~= 20 then
      print(">????")
      return false
   end
   local kList = {}
   for i=1,5 do
      local k = 0
      for j = 1,4 do
         local code = string.byte(str,(i-1)*4+j)
         if code <=57 then
            code = code - 48
         else
            code = code - 97 + 10
         end

         k = k + code
      end
      table.insert(kList,k)
   end
   --printTable(kList)
   if kList[1] + kList[3] == kList[2]+kList[4] and kList[5] == 128 then
      return true
   end
   return false
end
--[[
xxxx-xxxx-xxxx-xxxx-xxxx
]]
--[[
48-57 0-9
97-122 a-z
]]
function randomKey()
   local keyCodeList = {}
   local keyCodeSum = {0,0,0,0,128}
   local max = 35

   for i = 1,4 do
      local r = math.random(0,max)
      keyCodeList[i] = r
      keyCodeSum[1] = keyCodeSum[1] + r
      r = math.random(0,max)
      keyCodeList[i+2*4] = r
      keyCodeSum[3] = keyCodeSum[3] + r
   end
   keyCodeSum[2] = math.ceil((keyCodeSum[1]+keyCodeSum[3]) /2)
   keyCodeSum[4] = keyCodeSum[1]+keyCodeSum[3] - keyCodeSum[2]

   for i,v in pairs({2,4,5}) do
      local cnt = 0
      while true do
         cnt = cnt + 1
         local maxk= keyCodeSum[v]
         for j = 1,3 do
            local r = math.random(0,math.min(math.ceil(maxk/(4-j)),max))
            keyCodeList[(v-1)*4+j] = r
            maxk = maxk -r
         end
         if maxk <= max then
            keyCodeList[(v-1)*4+4] = maxk
            break
         end
      end
      if cnt > 500 then
         print ("create failed!!!!")
         return ""
      end
   end
   for i = 1,20 do
      local char = keyCodeList[i]
      if char <10 then
         keyCodeList[i] = char + 48
      else
         keyCodeList[i] = char - 10 + 97
      end
   end
   local out = string.char(unpack(keyCodeList))
   return out
end

--[[
48-57 0-9
97-122 a-z
65 - 90 A-Z
]]
local sssfile = "serial.key"
function saveSerial(key)
   local serial = key
   local file = io.open(sssfile,"w")
   file:close()
   file = io.open(sssfile,"a+")
   file:write("------------------youngdream serial fial------------------\n")
   file:write(serial)
   file:write("\n----------------------------------------------------------\n")
   file:close()
end

function getUnpackStr(list)
   for i = 1,#list do
      local char = list[i]
      if char <10 then
         list[i] = char + 48
      else
         list[i] = char - 10 + 97
      end
   end
   local serial = string.char(unpack(list))
   return serial
end

function reStoreSerial(str,mac)
   local endStr = {}
   for i=1,string.len(str) do
      endStr[i] = string.byte(str,i)
      if endStr[i] <=57 then
         endStr[i] = endStr[i] - 48
      else
         endStr[i] = endStr[i] - 97 +10
      end
   end 
   local macRes = {}
   for i,v in pairs({2,4,7}) do
      for ii,vv in pairs({3,4,8,1}) do
         macRes[(i-1)*4+ii] =  endStr[(v-1)*8+vv]
      end
   end
   local rMac = getUnpackStr(macRes)
   print (rMac)
   if rMac ~= mac then
      return ""
   end
   local keyList = {}

   for i,v in pairs({1,3,5,6,8}) do
      for ii,vv in pairs({2,4,6,7}) do
         keyList[(i-1)*4+ii]  = endStr[(v-1)*8+vv] 
      end
   end
   local key = getUnpackStr(keyList)
   print(key)
   return key
end

function _winMain()
   print ("winMain")
   if  platform =="Windows" then
      
      if C_getDPI then
         local dpi = 0
         dpi = C_getDPI()
         local width,height = math.floor(dpi/100000) ,dpi%100000
         --width,height = 1366,768
         height = height - 100
         width = height/1136*640
         --print (width,height)
         --assert(false,"xxx")
         local openView = CCEGLView:sharedOpenGLView()
         openView:setFrameSize(width,height)
      end
      if false then
         -- assert(false,"xxx")
         local file = io.open("path.txt","w+")
         file:write(path)
         file:close()
         local macTable = C_getMACAddress()
         printTable(macTable)
         if macTable[0] == 122335 then
            main()
            return 
         end
         local strList = getStrFromFile2(sssfile)
         if #strList >= 2 then
            local key = strList[2]
            for i=1,#macTable do
               local mac = macTable[i]
               print (key)
               local k   = reStoreSerial(key,mac)
               print (k)
               if checkSerial(k) then
                  main()
                  return
               end
            end
         end
         registerKey()
      else
         main()
      end
   else
      main()
   end
end

xpcall(_winMain)

