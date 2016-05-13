local handler = {
   nc = require"handler.nc",
   login = require"handler.login",
   fruitMachine = require"handler.fruitMachine",
   network = require"handler.network",
   userdata = require"handler.userdata",
   chat = require"handler.chat",
   file = require"handler.file",
}

module("handler.all", package.seeall)

handlerMap = {
   
   -- --network--
   -- "onChangedNetwork",
   -- --nc--
   -- "onConnect",
   -- "onClose",
   -- --userdata change--
   -- "onChangeGold",
   -- --login--
   -- "onLoginSucceed",
   -- "onLoginFailed",
   -- "onSetInitNameSucceed",
   -- "onSetInitNameFailed",
   -- --fruitMachine--
   -- "onEnterGameSucceed",
   -- "onEnterGameFailed",
   -- "onLeaveGameSucceed",
   -- "onLeaveGameFailed",
   -- "onOpenCashOne",
   -- "onOpenCash",
   -- "onUpdateGameStatus",
   -- "onGameUserActionSucceed",
   -- "onGameUserActionFailed",
   -- "onGameNotice",
   -- --chat--
   -- "onUserSendMessage",
   -- "onSendMessageSucceed",
   -- "onSendMessageFailed",
   -- "onSetSexSucceed",
   -- "onChangeVipExp",
   -- "onGetRankListSucceed",
   -- "onGetRankListFailed",
   -- "onGetDailyGift",
   -- "onChargeSucceed",
   -- "onChargeFailed",
   -- "onGetGiftList",
   -- "onOpenGiftPackSucceed",
   -- "onOpenGiftPackFailed",
   -- "onNewGiftSend",
   -- "onUpdateUserNameSucceed",
   -- "onUpdateUserNameFailed",
   
   -- --tree--
   -- "onUpdateTreeGift",
   -- "onGetTreeGiftSucceed",

   -- --binding--
   -- "onGetPhoneCodeSucceed",
   -- "onGetPhoneCodeFailed",
   -- "onRegisterPhoneSucceed",
   -- "onRegisterPhoneFailed",
   -- "onUnregisterPhoneFailed",

   -- --receive--
   -- "onGetFreeGoldSucceed",
   -- "onGetFreeGoldFailed",

   -- --quest--
   -- "onGetQuestCountList",
   -- "onFinishQuestSucceed",
   -- "onFinishQuestFailed",
   -- "onUpdateQuestCount",

   -- --lottery random--
   -- "onGetRandomGoldSucceed",
   -- "onGetRandomGoldFailed",

   -- --upload photo--
   -- "onUploadImageSucceed",
   -- "onUploadImageFailed",
   -- "onUpload",
   -- "onUploadError",
   -- "onDownload",
   -- "onDownloadError",
   -- "onProgress",
   -- "onSetDefaultImageFailed",
   -- "onSetDefaultImageSucceed",
   -- "onGetImageFileList",

   -- "onUnregisterPhone",

   -- "onBigWin",
   -- "systemContext",

   -- "onGetVIPRewardSucceed",
   -- "onGetVIPRewardFailed",

   -- "onSendPrivateMessage",
   -- "onSendPrivateMessageSucceed",
   -- "onGetPrivateMessageListSucceed",
   -- "onGetPrivateCharListSucceed",

   -- --mora game 
   -- "onFingerGameBetSucceed",
   -- "onFingerGameBetFailed",
   -- "onFingerGameBetChange",

   -- "onFingerGameGuessSucceed",
   -- "onFingerGameGuessFailed",
   -- "onFingerGameEndTime",
   -- "onFingerGameResult",

   -- "onFingerGameInvite",
   -- "onFingerGameInviteSucceed",
   -- "onFingerGameInviteFailed",
   -- "onFingerGameInviteAgreeSucceed",
   -- "onFingerGameInviteAgreeFailed",
   -- "onFingerGameInviteRefuse",
   -- "onFingerGameInviteCancel",

   -- "onGetAllActivityInfo",
   -- "onGetActivityExist",

   -- --network--
   ["onChangedNetwork"] = "onChangedNetwork",

   -- --nc--
   ["onConnect"] = "onConnect",
   ["onClose"] = "onClose",

   --login
   [1002] = "onLoginSucceed",
   [1003] = "onLoginFailed",

   --change info
   [2002] = "onChangeNameSucceed",
   [2003] = "onChangeNameFailed",
   [2102] = "onChangeSexSucceed",
   [2103] = "onChangeSexFailed",

   --change gold
   [3002] = "onChangeGold",

   --get phone code
   [4002] = "onGetPhoneCodeSucceed",
   [4003] = "onGetPhoneCodeFailed",

   --bind phone
   [5002] = "onBindPhoneSucceed",
   [5003] = "onBindPhoneFailed",

   --enter game
   [6002] = "onEnterGameSucceed",
   [6003] = "onEnterGameFailed",

   --user list
   [6102] = "onGetUserListSucceed",
   [6103] = "onGetUserListFailed",

   --leave game
   [7002] = "onLeaveGameSucceed",
   [7003] = "onLeaveGameFailed",

   --game notice
   [7104] = "onEnterGameNotice",
   [7105] = "onExitGameNotice",

   --game status
   [8002] = "onGetGameStatus",

   --bet
   [9002] = "onBetSucceed",
   [9003] = "onBetFailed",

   --send chat
   [11002] = "onSendMessageSucceed",
   [11003] = "onSendMessageFailed",

   --get chat 
   [12002] = "onGetMessage",

   --upload head image
   ["onUpload"] = "onUpload",
   ["onUploadError"] = "onUploadError",
   [13002] = "onUserChangeImageSucceed",
   [13003] = "onUserChangeImageFailed",
}


callBackList = {}
for i,funcName in pairs(handlerMap) do
	print ("newFuncName",funcName,i)
	assert(callBackList[funcName] == nil,"funcName has exist")
	callBackList[funcName] = tostring(i)
end

for i,v in pairs(handler) do
	for name,func in pairs(v) do
		if type(func) == "function" and callBackList[name] then
		  regListner(callBackList[name],func)
		end
	end
end
