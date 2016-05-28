local http = require("logic.http")
cjson = require "cjson"
luaoc = require "luaoc"
luaj = require "luaj"
local lgServerUrl = ""
local dId = ""
local cId = ""

function setServerUrl(url)
	if url then
		lgServerUrl = url
	end
end
function getDeviceId()
	return dId
end
function setDeviceId()
	if platform == "IOS"  then
		local function deviceIdCallBack(str)
			dId = str.udid
		end
		luaoc.callStaticMethod("AppController","getDeviceId",{callback=deviceIdCallBack})
	elseif platform == "Android" then
		local function platformInit(devId,params)
			dId = devId
			print("deviceId,sdkplatform:",did, params)

		end
		regListner("platformInit",platformInit)
		luaj.callStaticMethod("com/java/platform/NdkPlatform","platformInit",{""})
		--dId = luaj.callStaticMethod("com/java/platform/NdkPlatform","getDeviceId",{""})
	end
end

setDeviceId()

function setCharId(_id)
	if _id and _id ~= "" then
		cId = _id
	end
end

function uploadGuide(actionId)
	print("uploadGuide", lgServerUrl, cId, actionId)
	-- umengEvent(actionId)
	if lgServerUrl == nil or lgServerUrl == "" then
		print("lgServerUrl got nil")
		return
	end
	if cId == nil or cId == "" then
		cId = 0
	end
	if dId == nil or dId == "" then
		setDeviceId()
		return
	end
	http.request(lgServerUrl.."?type=102&syskey=ymnshx&deviceId="..dId.."&charid="..cId.."&actionId="..actionId,
		function(header,body,flag)
			if flag == false then
				print("连接服务器失败")
				return
			end
			local tab = cjson.decode(body)
			if tab.errCode == 0 then
				print("uploadGuide succeed")
			else
				print("uploadGuide failed")
			end
		end)
end