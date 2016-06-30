local userdata = require"logic.userdata"
local backList = require "scene.backList"
local http = require "logic.http"
local nc = require "logic.nc"
cjson = require "cjson"

function onBack()
	print("onBack-","callback")
	backList.goBackScene()
end
function platformInit(devId,params)
	userdata.deviceId = devId
	userdata.sdkplatform = params
	print("deviceId,sdkplatform:",devId, params)
end
function onPushToken(type,token)
	print("onPushToken-",type,token)
	-- call("registerPushToken",type,token)
end
function onPushData(msgId,msgType)
	print("onPushData-",msgId,msgType)
	userdata.messageId = msgId
	userdata.messageType = msgType
	-- -2 延迟测试消息
	-- -1 测试消息
	-- 0 系统消息
	-- 1 机缘灯
	-- 2 私聊
	-- 3 礼物
	-- 4 被关注
end
function onAppInfo(params)
	print("onAppInfo-", params)
	local str = splitWithTrim(params, "|")
	userdata.appInfo.pkgName = str[1]     -- 包名
	userdata.appInfo.verSdk = str[2]      -- 安卓版本
	userdata.appInfo.appType = str[3]     -- 运营商
	userdata.appInfo.appOperate = str[4]  -- 操作系统
	userdata.appInfo.appModel = str[5]    -- 手机型号
	userdata.appInfo.mac = str[6]         -- mac地址
	userdata.appInfo.ip = str[7]          -- ip地址
end

function onLoginResult(uId,uName,uSession)
	print("uId,uName,uSession:",uId,uName,uSession)
	userdata.sdkPlatformInfo = {}
	userdata.sdkPlatformInfo.uId = uId
	userdata.sdkPlatformInfo.uName = uName
	userdata.sdkPlatformInfo.uSession = uSession
	printTable(serverList)
	local url = ""
	if getPlatform() == "xmw" then
		url = serverList[1].payUrl.."/ydream/login?type=8&syskey=ymnshx&loginKey=&appSrc=xmw&code="..uSession
	end
	if url ~= "" then
		http.request(url,onResult)
	else
		print("url nil")
	end
end

function onResult(header,body)
	print("onResult",body)
	local tab = cjson.decode(body)
	if tab.errCode ~= 0 then
		-- alert.create(tab.errMsg)
		return
	end
	if tab.userId then
		userdata.sdkPlatformInfo.uId = tab.userId
	end
	if tab.userName then
		userdata.sdkPlatformInfo.uName = tab.userName
	end
	if tab.access_token then
		userdata.sdkPlatformInfo.uToken = tab.access_token
	end
	if userdata.sdkplatform == "xmw" then
		setSdkUserInfo(cjson.encode(tab))
		nc.connect()
        -- call("login", 0, userdata.sdkPlatformInfo.uId)
	end
end

function onSwitchResult(result)
	print("onSwitchResult",result)
	if tonumber(result) == 1 then
        nc.disConnect()
        saveSetting("loginToken","")
        luaoc.callStaticMethod("AppController","clearPush",{dict=""})
        nc.reConnectFlag = false
        local  sceneManager = package.loaded["scene.sceneManager"]
        sceneManager.change(sceneManager.SceneType.serverScene)
	end
end

function onLogoutResult(result)
	print("onLogoutResult",result)
	if tonumber(result) == 1 then
        nc.disConnect()
        saveSetting("loginToken","")
        luaoc.callStaticMethod("AppController","clearPush",{dict=""})
        nc.reConnectFlag = false
        local  sceneManager = package.loaded["scene.sceneManager"]
        sceneManager.change(sceneManager.SceneType.serverScene)
	end
end

function onPayResult(result)
	print("onPayResult",result)
	-- local tips = require "scene.tips"
	-- if tonumber(result) == 0 then
	-- 	tips.create("充值失败")
	-- elseif tonumber(result) == 1 then
	-- 	tips.create("充值成功，请等待充值结果")
	-- elseif tonumber(result) == 2 then
	-- 	tips.create("支付超时")
	-- elseif tonumber(result) == 3 then
	-- 	tips.create("支付中")
	-- elseif tonumber(result) == 4 then
	--  tips.create("支付正在处理中，请留意支付成功信息")
	-- end
end

function getPlatform()
  	if userdata.sdkplatform == nil or userdata.sdkplatform == "" or userdata.sdkplatform == "nshx" then
   		return "sgj"
  	end

  	return userdata.sdkplatform
end

function sdkLogin()
	if platform == "Android" then
		luaj.callStaticMethod("com/java/platform/NdkPlatform","platformLogin",{dict=""})
	end
end

function sdkAccountSwitch()
	if platform == "Android" then
		luaj.callStaticMethod("com/java/platform/NdkPlatform","accountSwitch",{dict=""})
	end
end

function sdkLogout()
	if platform == "Android" then
		luaj.callStaticMethod("com/java/platform/NdkPlatform","logout",{dict=""})
	end
end

-- true 常亮 false 锁定
function setScreenState(_flag)
	if platform == "Android" then
		if _flag then
			luaj.callStaticMethod("cc/yongdream/nshx/Util","UnlockedScreen",{})
		else
			luaj.callStaticMethod("cc/yongdream/nshx/Util","LockScreen",{})
		end
	end
end

function setSdkUserInfo(_json)
	if platform == "Android" then
		luaj.callStaticMethod("com/java/platform/NdkPlatform","setUserInfo",{_json})
	end
end

regListner("onBack",onBack)
regListner("platformInit",platformInit)
regListner("onPushToken",onPushToken)
regListner("onPushData",onPushData)
regListner("onLoginResult",onLoginResult)
regListner("onSwitchResult",onSwitchResult)
regListner("onLogoutResult",onLogoutResult)
regListner("onPayResult",onPayResult)
regListner("onAppInfo",onAppInfo)

luaoc.callStaticMethod("AppController","gameInit",{dict=""})
luaoc.callStaticMethod("AppController","getAppInfo",{dict=""})
luaj.callStaticMethod("com/java/platform/NdkPlatform","platformInit",{""})
luaj.callStaticMethod("com/java/platform/NdkPlatform","getAppInfo",{""})