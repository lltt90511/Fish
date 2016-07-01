
local luaoc = {}

local CCLuaObjcBridge = CCLuaObjcBridge

function luaoc.callStaticMethod(className, methodName, args)
   if platform == "IOS" then
      print("111111111111111111111111111",methodName)
      local ok, ret = CCLuaObjcBridge.callStaticMethod(className, methodName, args)
      print(ok,ret)
      if not ok then
	 local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
				   className, methodName, tostring(args), tostring(ret))
	 if ret == -1 then
	    print(msg .. "INVALID PARAMETERS")
	 elseif ret == -2 then
	    print(msg .. "CLASS NOT FOUND")
	 elseif ret == -3 then
	    print(msg .. "METHOD NOT FOUND")
	 elseif ret == -4 then
	    print(msg .. "EXCEPTION OCCURRED")
	 elseif ret == -5 then
	    print(msg .. "INVALID METHOD SIGNATURE")
	 else
	    print(msg .. "UNKNOWN")
	 end
      end

      return ok, ret
   else
      return  false,nil
   end
end

return luaoc
