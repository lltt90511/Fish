local regListner = regListner
require"curl"
module("logic.http", package.seeall)

curlId = 1
requireList = {}
function urlencode(str)

  --Ensure all newlines are in CRLF form
  str = string.gsub (str, "\r?\n", "\r\n")

  --Percent-encode all non-unreserved characters
  --as per RFC 3986, Section 2.3
  --(except for space, which gets plus-encoded)
  str = string.gsub (str, "([^%w%-%.%_%~ ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)

  --Convert spaces to plus signs
  str = string.gsub (str, " ", "+")

  return str 
end
function request(url,callBack)
	print ("request",url)
	
	curlId = curlId + 1
	requireList[curlId] = callBack
	C_http(curlId,url)
	return curlId
end
function cancelRequest(curlId)
	requireList[curlId] = nil
end
tips =[[ c++ http回调接口，由于可能出现各种字符，所以不直接在接口中返回数据(转换成json太麻烦)，而通过二次调用C++接口获取数据 ]]
function onHttpRepose(curlId)
	print ("###############################################onHttpRepose",curlId)
	local ret,header,body = C_getHttpRepose(curlId)
	--print (id,header,body)
	if ret == -1 then
		-- 获取失败
		print("http repose 获取失败...",curlId)
		local call = requireList[curlId]
		requireList[curlId] = nil 
		if call ~= nil then
			print ("call???????????????????")
			call("","",false)
		end
	end
	if ret == 0 then
		local call = requireList[curlId]
		requireList[curlId] = nil 
		if call ~= nil then
			call(header,body,true)
		end
	end

end
regListner("onHttpRepose",onHttpRepose)

