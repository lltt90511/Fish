require "common.util.string"
require "common.util.table"
local map = {}
function logServer( info )
	local http = package.loaded['logic.http']
	if http then
		local url  = loginServerUrl.."?type=3&syskey=ymnshx&info="..http.urlencode(info)
		--http.request(url)
	end
end
errorCall = nil
function onErrorCall(func)
	errorCall = func
end


function __G__TRACKBACK__(msg)
	--print ("__G__TRACKBACK__",debug)
	local str = debug.traceback()
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(str)
    print("----------------------------------------")
    if  platform == "Windows"  then
		 local f = io.open("running.log", "a")
		 f:write("\n["..os.date("%c").."]"..str)
		 f:close()
	else
		 --logServer(str)
		 if errorCall then
		 	--errorCall(str,msg)
		 end
    end
end
oldXpcall = xpcall
xpcall = function(func,callback,...)

	if callback == nil then
		callback = __G__TRACKBACK__
	end
	local parm ={ ...}
	local bac = function(msg)
		if parm ~= nil and #parm >=1 then
			callback(msg,unpack(parm))
		else
			callback(msg)
		end
	end
	oldXpcall(func,bac)
end
oldPrint = print
print = function (...)
	local parm = {...}
	if parm == nil then
		oldPrint("")
	else
		for i,v in pairs(parm) do
			if v == nil then
				parm[i] = "nil"
			elseif type(v) ~= type("") then
				parm[i] = tostring(v)
			end
			if parm[i] == nil then
				parm[i] = "nil"
			end
		end
		for i = 1,#parm do
			if parm[i] == nil then
				parm[i] = "nil"
			end
		end
		local str = table.concat(parm,"\t")
		if string.len(str)> 10000 then
			oldPrint("string too long length:"..string.len(str))
		else
			oldPrint(str)
		end
	end
end
function regListner( funcName,func )
	if isClient == nil then
		return
	end
	print("regListner", funcName,func)
	assert(type(funcName) == type(""))
	assert(type(func) == "function")
	--if not map[funcName] then
		--map[funcName] = {}
	--end	
	map[funcName]= func
	--table.insert(map[funcName], func)
end

function unRegListener(funcName)
   if isClient == nil then
      return 
   end
   map[funcName] = nil
end


function L_onError(message)
	print(ERROR,"[Error]+++++++++++++++++++++++++++++++++++++++")
	print(ERROR,message)
	print(ERROR,debug.traceback())
	print(ERROR,"[Error]---------------------------------------\n")
end



function L_onRPC( str )
	--print(str)
	local t = cjson.decode(str)
	local funcName = t.functionName
	local parameters = t.parameters
	print("Server : "..funcName,"parametersNum:"..#parameters)
	local func = map[funcName]
	if func  then
		xpcall(function()
			func(unpack(parameters))
		end)
	else
		print(funcName .. " not register")
	end	
end


function onRemuseFormBackground()
	print ("#########onRemuseFormBackground")
end
regListner("onRemuseFormBackground",onRemuseFormBackground)


function call( funcName, ... )
	assert(type(funcName) == type(""))
	print("Client : "..funcName)
	local t = {
		functionName = funcName,
		parameters = { ...}
	}
	local flag = true
	for i,v in pairs(t.parameters) do
		flag = false
	end
	if flag then
		t.parameters = nil
	end
	--printTable(t)
	-- table.insert(t,1,funcName)
	local str = cjson.encode(t)
	--print(str)
	C_senddata(str,0)
end
function encryptCall(funcName,...)
	assert(type(funcName) == type(""))
	print("Client : "..funcName)
	local t = {
		functionName = funcName,
		parameters = { ...}
	}
	local flag = true
	for i,v in pairs(t.parameters) do
		flag = false
	end
	if flag then
		t.parameters = nil
	end
	--printTable(t)
	-- table.insert(t,1,funcName)
	local str = cjson.encode(t)
	--print(str)
	C_senddata(str,1)
end
function unSchedule(handler)
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
	--print ("############unSchedule",handler)
end
function schedule(func,time)
	local handler = nil

	handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(func, time, false)
	--print ("############schedule",time,handler)
	return handler
end
function performWithDelay(func,time)
	if type(func) ~= "function" then
		print(debug.traceback())
		return 
	end
	local handler = nil
	handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
		func()
	end, time, false)
	return handler
end
timeDiff = 0
function getSyncedTime()
	return os.time() + timeDiff
end
function setAutoLockScreen(flag)
	--luaoc.callStaticMethod("AppController","setAutoLockScreen",{flag=flag})
end

function getDiffTime(t,startTime)
   if startTime == nil then
      startTime = getSyncedTime()
   end
   local diff = math.abs(startTime-t)
   --print("@@@@@@@@@@@@@@@ "..diff)
   local str = ""
   if diff >= 86400 then
      str = str .. math.floor(diff/86400).."天"
      diff = diff%86400
   elseif diff >= 3600 then
      str = str .. math.floor(diff/3600).."小时"
      diff = diff%3600 
   elseif diff >= 60 then
      str = str ..math.floor(diff/60).."分"
   else
      str = str .."1分"
   end
   return str
end

function getDiffTimeDetail(t,startTime)
   if startTime == nil then
      startTime = getSyncedTime()
   end
   local diff = math.floor(math.abs(startTime-t))
   local str = ""
   if diff >= 86400 then
	   str = str .. math.floor(diff/86400).."天"
	   diff = diff%86400
   end
   if diff >= 3600 then
      str = str .. math.floor(diff/3600).."小时"
      diff = diff%3600 
   else 
   	  str = str .."0小时"
   end
   if diff >= 60 then
      str = str ..math.floor(diff/60).."分"
      diff = diff%60 
   else 
   	  str = str .."0分"
   end
   str = str ..diff.."秒"
   return str
end

function timeToDayStart(t)
	if t == 0 then
		return 0
	end
   local tRec = os.date("*t",t)
   tRec.hour = 0
   tRec.min = 0
   tRec.sec = 0
   return os.time(tRec)
end
takePhotoFunc = nil
function setTakePhotoFuncCallBack(func)
	takePhotoFunc = func
end
function onTakePhoto(id,path)
	print ("#################onTakePhoto",id,path)
	if takePhotoFunc then
		print ("callBack",takePhotoFunc)
		takePhotoFunc({fullPath = path})
		takePhotoFunc = nil
	end
end

--1397676047259
--1397632920

regListner("onTakePhoto",onTakePhoto)
regListner("onSyncTime",function(time)
   timeDiff = time/1000 - os.time()
end )
if isClient then
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(C_doTick, 0, false)
end


function errorFunc()
	if true > nil then

	end
end

function __RESTART()
	if platform == "IOS"  then
		local function appUrlCallBack(str)
			appUrl = str.appUrl
			luaoc.callStaticMethod("AppController","openUrlWithSafari",{url=RestartUrl.."?appUrl="..appUrl.."://"})
			C_exit()
		end
		luaoc.callStaticMethod("AppController","getURLSchemes",{callback=appUrlCallBack})
	elseif platform == "Android" then
		luaj.callStaticMethod("cc/yongdream/nshx/mainActivity","restartGame",{""})
	end
end

