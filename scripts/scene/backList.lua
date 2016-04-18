module("scene.backList",package.seeall)

_list = {}

function setBackScene(_func, _flag)
	if _flag then
		_list = {}
	end
	if not _func then
		print("_func got nil")
		return
	end
	for i,v in pairs(_list) do
		if v == _func then
			print("_func exists")
			return
		end
	end
	table.insert(_list, _func)
end

function goBackScene()
	print("goBackScene")
	if #_list > 0 then
		_list[#_list]("releaseUp")
	else
		goExitGame()
	end
end

function removeList(_func)
	print("removeList")
	if #_list > 0 then
		for i,v in pairs(_list) do
			if v == _func then
				table.remove(_list, i)
				return
			end
		end
	end
end

function goExitGame()
	print("goExitGame")
    luaj.callStaticMethod("org.cocos2dx.lib.Cocos2dxGLSurfaceView","OnExit",{})
end