local userdata = require("logic.userdata")
local event = require"logic.event"
local package = package
module("handler.file", package.seeall)


function onUpload(t,oldName,jsonTmp,seconds,bytes)
   print("#######################onUpload#####################")
   print(t,oldName,jsonTmp,seconds,bytes)
   -- printTable(jsonTmp)
   -- local uuid = jsonTmp.url
   -- local arr = splitString(jsonTmp.url,'/')
   -- jsonTmp.url = table.concat(arr,splitURLChar)

   -- seconds = math.floor(seconds)
   -- if type(jsonTmp) ~= 'table' then
   --    return
   -- end
   local path = fileManager.path
   if t == 1 then--头像
      C_rename(path.."/"..oldName,path.."/"..jsonTmp)
      fileManager.addFile(jsonTmp,bytes)
      C_ImageToEncode(path.."/"..jsonTmp)
      event.pushEvent("UPLOAD_PERSONAL_PHOTO",{type = 1, fileName = jsonTmp})
   end
end
function onUploadError(type)
   
end

function onDownloadError(t,fileName,nowIndex)
   
end

function checkImageFileLegal(fileName)
   if fileName ~= nil and fileName ~= "" then
      local arr = splitString(fileName,".png")
      if #arr == 2 then
         local texture = CCTextureCache:sharedTextureCache():addImage(fileManager.path..fileName)
         if texture == nil then
            return false
         end
      end
   end
   return true
end

function onDownload(t,fileName,nowIndex,bytes)
   if checkImageFileLegal(fileName) == false then
      return
   end
   fileManager.addFile(fileName,bytes)
   event.pushEvent(fileName)      
end

function onProgress(t,nowIndex,per)
   --print(t,nowIndex,per)
end

function onUploadImageFailed(data)
   onPreUploadToRoomFailed(data)
end

function onUploadImageSucceed(uuid)
   if #fileManager.uploadList == 0 then
      return 
   end
   local data = fileManager.uploadList[1]
   table.remove(fileManager.uploadList,1)
   C_upload(uploadURL,data.path,data.type,data.seconds,uuid)
end

function onPreUploadToRoomFailed(data)
   alert.create(data)
   local _data = fileManager.uploadList[1]
   os.remove(_data.path)
   if _data.imgPath then
      os.remove(_data.imgPath)
   end
   table.remove(fileManager.uploadList,1)
end


function onUserChangeImageFailed(data)
   alert.create(data)
end

function onUserChangeImageSucceed(data)
   -- userdata.UserInfo.imageFile = uuid
   -- local arr = splitString(uuid,"/")
   -- local fileName = ""
   -- if #arr >= 2 then
   --    userdata.CharIdToImageFile[userdata.UserInfo.id] = {file=table.concat(arr,splitURLChar),sex=userdata.UserInfo.sex}
   -- end
   userdata.UserInfo.PicUrl = data.newImg
   userdata.CharIdToImageFile[userdata.UserInfo.uidx] = {file=data.newImg,sex=userdata.UserInfo.sex}
   event.pushEvent("HEAD_ICON_CHANGE",uuid)
end

function onGetImageFileList(data)
   --printTable(data)
   for k, v in pairs(data) do
      local fileName = ""
      if type(v.file) == type("") and v.file ~= nil and v.file ~= "" then
          local arr = splitString(v.file,"/")
          if #arr >= 2 then
              fileName = table.concat(arr,splitURLChar)
          end
      end
      if v.charId < 0 then
         userdata.CharIdToImageFile[v.charId] = {file=fileName,sex=math.random(1,2)}
      else
         userdata.CharIdToImageFile[v.charId] = {file=fileName,sex=v.sex}
      end
      event.pushEvent("getImageFileList"..v.charId,fileName)
   end
end
