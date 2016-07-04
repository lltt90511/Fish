module("logic.nc", package.seeall)

connected = false
hurtTimer = nil
connectId = 1

function connect()
   -- local server = serverList[connectId]
   print("connect!!!!!!!!!!!!!!!")
   printTable(serverList)
   C_connectAsync(serverList["SocketIp"], serverList["SocketPort"])
   -- C_connectAsync("10.0.39.11", "51111")
   -- setUploadURL(server.uploadURL)
   setDownloadURL(serverList["Srv_Img"])
   -- setPayServerUrl(server.payUrl)
end

function stopTimer()
	if hurtTimer then
		unSchedule(hurtTimer)
		hurtTimer = nil
	end
end

function startTimeHandler()
	stopTimer()
	-- onTick()
	-- hurtTimer = schedule(onTick,3)
end

function disConnect()
	connected = false
	setAutoLockScreen(true)
	C_close()
end

function onTick()
	-- call("syncTime")
end
