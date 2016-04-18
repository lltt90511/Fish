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
   --network--
   "onChangedNetwork",
   --nc--
   "onConnect",
   "onClose",
   --userdata change--
   "onChangeGold",
   --login--
   "onLoginSucceed",
   "onLoginFailed",
   "onSetInitNameSucceed",
   "onSetInitNameFailed",
   --fruitMachine--
   "onEnterGameSucceed",
   "onEnterGameFailed",
   "onLeaveGameSucceed",
   "onLeaveGameFailed",
   "onOpenCashOne",
   "onOpenCash",
   "onUpdateGameStatus",
   "onGameUserActionSucceed",
   "onGameUserActionFailed",
   "onGameNotice",
   --chat--
   "onUserSendMessage",
   "onSendMessageSucceed",
   "onSendMessageFailed",
   "onSetSexSucceed",
   "onChangeVipExp",
   "onGetRankListSucceed",
   "onGetRankListFailed",
   "onGetDailyGift",
   "onChargeSucceed",
   "onChargeFailed",
   "onGetGiftList",
   "onOpenGiftPackSucceed",
   "onOpenGiftPackFailed",
   "onNewGiftSend",
   "onUpdateUserNameSucceed",
   "onUpdateUserNameFailed",
   
   --tree--
   "onUpdateTreeGift",
   "onGetTreeGiftSucceed",

   --binding--
   "onGetPhoneCodeSucceed",
   "onGetPhoneCodeFailed",
   "onRegisterPhoneSucceed",
   "onRegisterPhoneFailed",
   "onUnregisterPhoneFailed",

   --receive--
   "onGetFreeGoldSucceed",
   "onGetFreeGoldFailed",

   --quest--
   "onGetQuestCountList",
   "onFinishQuestSucceed",
   "onFinishQuestFailed",
   "onUpdateQuestCount",

   --lottery random--
   "onGetRandomGoldSucceed",
   "onGetRandomGoldFailed",

   --upload photo--
   "onUploadImageSucceed",
   "onUploadImageFailed",
   "onUpload",
   "onUploadError",
   "onDownload",
   "onDownloadError",
   "onProgress",
   "onSetDefaultImageFailed",
   "onSetDefaultImageSucceed",
   "onGetImageFileList",

   "onUnregisterPhone",

   "onBigWin",
   "systemContext",

   "onGetVIPRewardSucceed",
   "onGetVIPRewardFailed",

   "onSendPrivateMessage",
   "onSendPrivateMessageSucceed",
   "onGetPrivateMessageListSucceed",
   "onGetPrivateCharListSucceed",

   --mora game 
   "onFingerGameBetSucceed",
   "onFingerGameBetFailed",
   "onFingerGameBetChange",

   "onFingerGameGuessSucceed",
   "onFingerGameGuessFailed",
   "onFingerGameEndTime",
   "onFingerGameResult",

   "onFingerGameInvite",
   "onFingerGameInviteSucceed",
   "onFingerGameInviteFailed",
   "onFingerGameInviteAgreeSucceed",
   "onFingerGameInviteAgreeFailed",
   "onFingerGameInviteRefuse",
   "onFingerGameInviteCancel",

   "onGetAllActivityInfo",
   "onGetActivityExist",
}


callBackList = {}
for i,funcName in pairs(handlerMap) do
	print ("newFuncName",funcName)
	assert(callBackList[funcName] == nil,"funcName has exist")
	callBackList[funcName] = funcName
end

for i,v in pairs(handler) do
	for name,func in pairs(v) do
		if type(func) == "function" and callBackList[name] then
		  regListner(name,func)
		end
	end
end
