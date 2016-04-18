local template = require"template.gamedata".data
module("logic.countLv", package.seeall)
function getVipLv(exp)
	-- print ("vipExp           "..exp)
	local lv = 0
	local now = exp
	local max = 0
	local list = template['vipExp']
	for i,v in pairs(list) do
		if v.exp <= exp and i > lv then
			lv = i
			now = exp --- v.exp
		end	
	end
	if list[lv+1] then
		max =  list[lv+1].exp
	else
		max = list[lv].exp
		now = list[lv].exp
	end
	-- print (lv)
	return lv,now,max
end