
local fileManager = {}
fileManager.path = CCFileUtils:sharedFileUtils():getWritablePath()
print ("####################################",fileManager.path)
fileManager.hash = {}
fileManager.uploadList = {}
fileManager.uuidMap = {} 
fileManager.downloadingMap = {}
fileManager.albumDataMap = {} --保存uuid- desc,dearNeed
--fileManager.objMap = {}

-- function fileManager.downloadFinish(fileName, index)
--    if fileManager.objMap[index] and fileManager.objMap[index]:getParent() then
--       local obj = fileManager.objMap[index]
--       obj:loadTexture(fileName)
--       fileManager.objMap[index] = nil
--    end
-- end

fileManager.onConvertFinishFunc = nil
function fileManager.setConvertFinishCallBack(func)
   fileManager.onConvertFinishFunc = func
end

function fileManager.onConvertFinish(path)
   if fileManager.onConvertFinishFunc then
      fileManager.onConvertFinishFunc({fullPath = path})
      fileManager.onConvertFinishFunc = nil
   end
end

function fileManager.download(url,filePrefix,_type,index,writePath)
   if fileManager.downloadingMap[filePrefix] == nil then
      fileManager.downloadingMap[filePrefix] = true
      if writePath == nil then
         writePath = ""
      end
      print (url,filePrefix,_type,index,writePath)
      C_download(url,filePrefix,_type,index,writePath)
   end
end

function fileManager.addFile(name,bytes)
   if bytes > 0 then
      local now = os.time()
      fileManager.hash[name] = true
      fileManager.file:write(name.." "..now.." "..bytes.."\n")
      fileManager.file:flush()
   end
end

function fileManager.clearFile()
   local file = io.open(fileManager.path.."/info.txt","r")
   local notRemoveList = {}
   local now = os.time()
   print("@@@@@@@@@@@@@@@@clearFile@@@@@@@@@@@@@@@@@")
   if file then
      for line in file:lines() do
         print(line)
         local tab = splitString(line," ")
         --printTable(tab)
         if #tab >= 2 then
            if now - tonumber(tab[2]) > 4*86400 then
               os.remove(fileManager.path.."/"..tab[1])
            elseif now - tonumber(tab[2]) > 2*86400 and tab[3] and tonumber(tab[3]) > 1024*200 then
               os.remove(fileManager.path.."/"..tab[1])
            else	      
               table.insert(notRemoveList, line)
               fileManager.hash[tab[1]] = true	      
            end
         end
      end
      file:close()
   end
   if #notRemoveList == 0 then
      os.remove(fileManager.path.."/info.txt")
   else
      print("############################################################")
      file = io.open(fileManager.path.."/info.txt","w")
      for k, v in pairs(notRemoveList) do
         file:write(v.."\n")
      end
      file:close()
   end
   fileManager.file = io.open(fileManager.path.."/info.txt","a+")
end

function fileManager.insertUpload(data)
   table.insert(fileManager.uploadList,data)
end

return fileManager
