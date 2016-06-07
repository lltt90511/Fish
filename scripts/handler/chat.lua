local event = require"logic.event"
module("handler.chat", package.seeall)

function onUserSendMessage(data)
   event.pushEvent("USER_MESSAGE",data)
end

function onSendMessageSucceed(gameData)
   event.pushEvent("ON_SEND_MESSAGE_SUCCEED",gameData)
end

function onSendMessageFailed(gameData)
   event.pushEvent("ON_SEND_MESSAGE_FAILED",gameData)
end

function onGetMessage(gameData)
   event.pushEvent("ON_GET_MESSAGE",gameData)
end

function onGetSysMessage(gameData)
   event.pushEvent("ON_GET_SYSTEM_MESSAGE",gameData)
end

function onGetprivateMessage(gameData)
   event.pushEvent("ON_SEND_MESSAGE_SUCCEED",gameData)
end