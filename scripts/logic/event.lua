
module("logic.event", package.seeall)
eventList = {}
function listen(name,func)
	if eventList[name]== nil then
		eventList[name] = {}
	end
	if name == "simple_user_info" then
		local loadingMin = package.loaded['scene.loadingMin']
		loadingMin.create()
	end
	for i,v in pairs(eventList[name]) do
		if v == func then
			return 
		end
	end
	table.insert(eventList[name],func)
end
function unListen(name,func)
	if eventList[name] == nil then
		return
	end
	if func == nil then
	   eventList[name] = nil
	   return
	end
	for i,v in pairs(eventList[name]) do
		if v== func then
			eventList[name][i] = nil
		end
	end	
end
function pushEvent(name,...)
	if eventList[name] == nil then
		return
	end
	if name == 'simple_user_info' then
		pushEvent("LOADINGMIN_CHANGE",true)
	end
	local parms = {...}
	for i,v in pairs(eventList[name]) do
		xpcall(function ()
			v(unpack(parms))
		end)
	end
end
