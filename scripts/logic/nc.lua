module("logic.nc", package.seeall)

connected = false
hurtTimer = nil
connectId = 1

function connect()
   local server = serverList[connectId]
   C_connectAsync(server.ip, server.port)
   setUploadURL(server.uploadURL)
   setDownloadURL(server.downloadURL)
   setPayServerUrl(server.payUrl)
end

function stopTimer()
	if hurtTimer then
		unSchedule(hurtTimer)
		hurtTimer = nil
	end
end

function startTimeHandler()
	stopTimer()
	onTick()
	hurtTimer = schedule(onTick,3)
end

function disConnect()
	connected = false
	setAutoLockScreen(true)
	C_close()
end

function onTick()
	call("syncTime")
end
