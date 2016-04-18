local event = require"logic.event"
module("handler.chat", package.seeall)

function onUserSendMessage(data)
   event.pushEvent("USER_MESSAGE",data)
end

function onSendMessageSucceed(data)

end

function onSendMessageFailed(data)

end
