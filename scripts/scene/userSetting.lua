
UserSetting = {}
UserChar = {}

function initSetting()
	local SettingSql =[=[
		select * from Setting;
	]=]
	local setting = fDB.query(SettingSql)
	UserSetting = {}
	for i,v in pairs(setting) do
		UserSetting[v.name]=v.val
	end
	print("initSetting!!!!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@@############################$$$$$$$$$$$$$$$$$$$$$$$$")
	printTable(UserSetting)
	--if true > nil then

	--end
end
function saveSetting(name,values)
	local SettingSQL = ""
	if values == nil then
		SettingSQL = "delete from  Setting  where name =\""..name.."\";"
	else
		if UserSetting[name] == nil then
			SettingSQL = "insert into Setting values(\""..name.."\",\""..values.."\");";
		else
			SettingSQL = "update Setting set val = \""..values.."\" where name =\""..name.."\";"
		end
	end

	print (SettingSQL)
	fDB.exec(SettingSQL)
	UserSetting[name] = tostring(values)
end

function saveChar(myCharId,otherCharId,msg,charId,charName,targetCharId,targetCharName,time,hadRead)
    local saveCharSQL = ""
	if myCharId == nil then
		return
	else
		saveCharSQL = "insert into UserChar values(NULL,\""..myCharId.."\",\""..otherCharId.."\",\""..msg.."\",\""..charId.."\",\""..charName.."\",\""..targetCharId.."\",\""..targetCharName.."\",\""..time.."\",\""..hadRead.."\");"
	end
	print("saveChar!!!!!!!!!!!!!!!!!")
	print(saveCharSQL)
	fDB.exec(saveCharSQL)
	setChar(myCharId,msg,charId,charName,targetCharId,targetCharName,time,hadRead)
end

function updateChar(otherCharId,hadRead)
	local updateCharSQL = ""
	if otherCharId == nil then
	   return
	else
	   updateCharSQL = "update UserChar set hadRead = \""..hadRead.."\" where otherCharId =\""..otherCharId.."\";"
	end  
	print("updateChar!!!!!!!!!!!!!!!!!")
	print(updateCharSQL)
	fDB.exec(updateCharSQL)
end

function getChar(myCharId)
	local getCharSql =[=[
		select * from UserChar where myCharId = ]=]..[=["]=]..myCharId..[=["]=]..[=[;
	]=]
	local charList = fDB.query(getCharSql)
	print("getchar!!!!!!!!!!!!!!!!!")
	UserChar = {}
	for i,v in pairs(charList) do
		setChar(myCharId,v.msg,v.charId,v.charName,v.targetCharId,v.targetCharName,v.time,v.hadRead)
	end
end

function deleteChar(otherCharId,time)
	local deleteCharSql = "delete from UserChar where otherCharId = \""..otherCharId.."\" and time < \""..time.."\";"
	local charList = fDB.query(deleteCharSql)
	print("deleteChar!!!!!!!!!!!!!!!!!")
	-- UserChar = {}
	-- for i,v in pairs(charList) do
	-- 	setChar(myCharId,v.msg,v.charId,v.charName,v.targetCharId,v.targetCharName,v.time,v.hadRead)
	-- end
end

function setChar(myCharId,msg,charId,charName,targetCharId,targetCharName,time,hadRead)
	-- local index = #UserChar + 1
	-- if UserChar[index] == nil then
	--    UserChar[index] = {}
	-- end
	-- UserChar[index].msg = msg
	-- UserChar[index].charId = charId
	-- UserChar[index].charName = charName
	-- UserChar[index].targetCharId = targetCharId
	-- UserChar[index].targetCharName = targetCharName
	-- UserChar[index].time = time
	-- UserChar[index].hadRead = hadRead
    local id = 0
    if myCharId == tonumber(charId) then
       id = tonumber(targetCharId)
    else
       id = tonumber(charId)	
    end
    -- print("id!!@@",id)
    if not UserChar[id] then
       UserChar[id]	 = {}
    end
    local list = {}
    list.msg = msg
    list.charId = charId
    list.charName = charName
    list.targetCharId = targetCharId
    list.targetCharName = targetCharName
    list.time = time
    list.hadRead = hadRead
    table.insert(UserChar[id],list)
 --    print("setChar")
	-- printTable(UserChar)  
end

initSetting()