local mainScene = require "scene.main"
local loginScene = require"scene.login"
local tool = require "logic.tool"
local startScene = require "scene.start"
module("logic.sceneManager", package.seeall)

SceneType = {
	mainScene = 1,
    loginScene = 2,
    startScene = 3,
}

Scene = {
	[1]=mainScene,
    [2]=loginScene,
    [3]=startScene,
}

currentScene = nil
scene  = nil

function addSubScene(package,z)
	local  s = Scene[currentScene]
	if s.this then
		s.this:addChild(package.this, z)
		if s.subScene == nil then
			s.subScene = {}
	    end
	    table.insert(s.subScene,package)
	 else
	 	print ("currentScene:"..currentScene.."  s.this == null?")
	end
end
function removeSubScene(package)
	local  s = Scene[currentScene]
	if s.this then
		--s.this:addChild(package.this, z)
		if s.subScene == nil then
			s.subScene = {}
	    end
	    for i,v in pairs(s.subScene) do
	    	if v == package then
	    		s.subScene[i] = nil
	    	end
	    end
	end
end
function change(id)
	print("change", currentScene,id, type(id))
	if id == currentScene then
		return
	end	

	local m = nil
	m = Scene[id]
	print("layer", layer)
	if m  then
		tool.registerMainWidget(m)
		if not m.eventHandler then
			m.eventHandler = function ( event )
				print("eventHandler",id,event)
				if event == "exit" then
					-- 移除所以子界面
					if m.subScene then
						for i,v in pairs(m.subScene) do
							v.exit()
						end
						m.subScene = nil
					end
				end
				if m[event] then
					m[event]()
				end	
				if event == "exit" then
					m.this = nil
				end
				print("end eventHandler",id,event)
				
			end
		end	
		local layer = nil
		scene = CCScene:create()
	
		CCTextureCache:sharedTextureCache():removeUnusedTextures();
		layer = m.create()
		layer:registerScriptHandler(m.eventHandler)
		scene:addChild(layer)
		luaoc.callStaticMethod("AppController","clearColor",{dict=""})
		luaj.callStaticMethod("cc/yongdream/nshx/mainActivity","clearColor",{})
        -- if not currentScene then
        --    CCDirector:sharedDirector():runWithScene(scene)
		-- else 
        CCDirector:sharedDirector():replaceScene(CCTransitionFade:create(0.5, scene))
        --end
		currentScene = id
	end
end
