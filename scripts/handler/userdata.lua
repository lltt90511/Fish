local event = require"logic.event"
local userdata = require"logic.userdata"
local tool = require "logic.tool"
local template = require"template.gamedata".data
local inviterAlert = require"scene.inviterAlert"
local waitInviterAlert = require"scene.waitInviterAlert"

module("handler.userdata", package.seeall)

function onChangeGold(giftGold, gold)
   print("onChangeGold",giftGold,gold)
   userdata.UserInfo.giftGold = giftGold
   userdata.UserInfo.gold = gold
   event.pushEvent("ON_CHANGE_GOLD")
   -- print("onChangeGold",userdata.isLottery,userdata.goldAction)
   if userdata.isLottery == true then
   	  userdata.isLottery = false
   	  userdata.goldAction = true
   end
end


function onSetSexSucceed(sex)
	userdata.UserInfo.sex = sex
end
function onChargeSucceed(time,id,cnt)
	-- alert.create("恭喜！充值成功")
	if userdata.UserInfo.chargeMap == nil then
		userdata.UserInfo.chargeMap = {}
	end
	userdata.UserInfo.chargeMap[id] = cnt
	
	if id and id ~= "" then
		local tpl = template['charge'][id]
		if tpl then
			umengPay(tpl.rmb, 2, tpl.goldGet)
		end
  		event.pushEvent("CHARGE_SUCCESS",id,time)
	end
	userdata.UserInfo.lastChargeTime = time
end
function onChargeFailed(str)
	alert.create(str)
end
function onChangeVipExp(vip)
	print("onChangeVipExp")
	userdata.UserInfo.vipExp = vip
	event.pushEvent("ON_CHANGE_VIP")
end

function onUpdateUserNameFailed(str)
	alert.create(str)
end
function onUpdateUserNameSucceed(name)
	userdata.UserInfo.name = name
	event.pushEvent("ON_CHANGE_NAME")
	alert.create("修改成功")
end
function onGetRankListSucceed(...)
	local rank = package.loaded['scene.rank']
	rank.onGetRankList(...)
	event.pushEvent("ON_GET_RANK_LIST",...)
end

function onGetRankListFailed(str)
	print("onGetRankListFailed",str)
end
function onGetDailyGift(...)
    AudioEngine.playEffect("effect_07")
	local daily = package.loaded['scene.loginGift']
	daily.onGetDailyGift(...)

end

function onGetGiftList(list)
	print("onGetGiftList_________________---------------------------")
	userdata.giftList = list
	printTable(list)
	printTable(userdata.giftList)
	for i,v in pairs(list) do
		if type(v) == "userdata" then
			list[i] = nil
		end
	end
	event.pushEvent("ON_UPDATE_MAIL")
end

function onOpenGiftPackSucceed(id)
	if type(userdata.giftList) == "table" then
		for i,v in pairs(userdata.giftList) do
			if id == v.id then
				-- userdata.giftList[i] = nil
				userdata.giftList[i].read = 1
				-- event.pushEvent("ON_GIFT_PACK_REMOVE",id)
				if v.type == 2 then
					alert.create("您获得了"..v.num.."枚金币")
				end
			end
		end
	end
	event.pushEvent("ON_UPDATE_MAIL")
end

function onOpenGiftPackFailed(str)
	alert.create(str)
end

function onNewGiftSend(gift)
	if userdata.giftList == nil then
		userdata.giftList = {}
	end
	table.insert(userdata.giftList,gift)
	event.pushEvent("ON_UPDATE_MAIL")
end

function onUpdateTreeGift(time,gold)
	print("onUpdateTreeGift!!!!!!!",time,gold)
	userdata.UserInfo.lastTreeGiftTime = time
	userdata.UserInfo.treeGiftGold = gold
	event.pushEvent("ON_GET_TREE",time,gold)
end

function onGetTreeGiftSucceed(time,gold,get)
	print("onGetTreeGiftSucceed",time,gold,get)
    AudioEngine.playEffect("effect_07")
	userdata.UserInfo.lastTreeGiftTime = time
	userdata.UserInfo.treeGiftGold = gold
    --userdata.UserInfo.gold = userdata.UserInfo.gold + get
    event.pushEvent("ON_CHANGE_GOLD")
    event.pushEvent("ON_GET_TREE_SUCCESS")
	-- alert.create("领取成功！")
end

function onGetPhoneCodeSucceed(time)
	userdata.UserInfo.lastPhoneCodeTime = time
	event.pushEvent("ON_GET_PHONE")
end

function onGetPhoneCodeFailed(str)
    alert.create(str)
end

function onRegisterPhoneSucceed(relogin,uuid)
	print("onRegisterPhoneSucceed!!!!!!!!!!!!!!!!!!!!!!!!",relogin,uuid)
	if type(uuid) == "string" then
		print(uuid)
	end
	local flag = false
	if relogin == false then
		alert.create("绑定成功！")
		flag = true
	else
		alert.create("该手机已经绑定了账号，登陆该账号？",nil,
		function ()
			call("login", 0, uuid)--记录下
			saveSetting("uuid", uuid)
		end)
	end
    event.pushEvent("ON_REGISTER_PHONE",flag)
end

function onRegisterPhoneFailed(str)
    alert.create(str)
end

function onUnregisterPhoneFailed(str)
    alert.create(str)
end

function onGetFreeGoldSucceed(cnt,time)
    AudioEngine.playEffect("effect_07")
	print("onGetFreeGoldSucceed",cnt,time)
	userdata.UserInfo.freeGoldCnt = cnt
	userdata.UserInfo.lastFreeGoldTime = time
	event.pushEvent("ON_GET_FREE_GOLD")
	-- alert.create("领取成功！")
end

function onGetFreeGoldFailed(str)
	if goldAction == true then
	   goldAction = false	 
	end
    alert.create(str)
end

function onUnregisterPhone()
	print("onUnregisterPhone!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~")
    local sceneManager = require"logic.sceneManager"
    sceneManager.change(sceneManager.SceneType.startScene)
    tool.performWithDelay(function()
    		saveSetting("uuid", uuid)
    	end, 0.1)
end

function onGetQuestCountList(hashKey,timeHashKey,reachedQuest)
	userdata.UserInfo.hashKey = {}
	userdata.UserInfo.timeHashKey = {}
	userdata.UserInfo.reachedQuest = {}
	userdata.UserInfo.hashKey = hashKey
	userdata.UserInfo.timeHashKey = timeHashKey
	userdata.UserInfo.reachedQuest = reachedQuest
	print("onGetQuestCountList1")
	printTable(hashKey)
	print("onGetQuestCountList2")
	printTable(timeHashKey)
	print("onGetQuestCountList3")
	printTable(reachedQuest)
	event.pushEvent("ON_GET_QUEST")
end

function onFinishQuestSucceed(id)
    AudioEngine.playEffect("effect_07")
	print("onFinishQuestSucceed",id)
	table.insert(userdata.UserInfo.reachedQuest,id)
	event.pushEvent("ON_FINISH_QUEST")
	-- alert.create("领取成功！")
end

function onFinishQuestFailed(str)
    alert.create(str)
end

function onUpdateQuestCount(list,time)
	print("onUpdateQuestCount",time)
	-- printTable(list)
	if not userdata.UserInfo.hashKey then
	   userdata.UserInfo.hashKey = {}
	end
	if not userdata.UserInfo.timeHashKey then
	   userdata.UserInfo.timeHashKey = {}
	end
	for k,v in pairs(list) do
		userdata.UserInfo.hashKey[k] = v
		userdata.UserInfo.timeHashKey[k] = time
	end
	event.pushEvent("ON_UPDATE_QUEST")
end

function onGetRandomGoldSucceed(id,time,cnt,list)
	print("onGetRandomGoldSucceed",id,time,cnt)
	userdata.UserInfo.randomCnt = cnt
	userdata.UserInfo.lastRandomTime = time
	if userdata.isLottery == true then
	   userdata.isLottery = false
	end
	event.pushEvent("ON_RANDOM_GOLD",id,list)
end

function onGetRandomGoldFailed(str)
	if userdata.isInGame == true then
	   userdata.isInGame = false	
	end
	if userdata.isLottery == true then
	   userdata.isLottery = false
	end
    alert.create(str)
end

function onGetVIPRewardSucceed(r,s)
   print("onGetVIPRewardSucceed",r,s)
   alert.create("领取成功！")
end

function onGetVIPRewardFailed(str)
    alert.create(str)
end

function onSendPrivateMessage(data)
	print("onSendPrivateMessage",data)
	printTable(data)
    local myCharId = userdata.UserInfo.id or userdata.UserInfo.charId
    local otherCharId = 0
    if myCharId == tonumber(data.charId) then
       otherCharId = tonumber(data.targetCharId)
    else
       otherCharId = tonumber(data.charId)
    end
    saveChar(myCharId,otherCharId,data.msg,data.charId,data.charName,data.targetCharId,data.targetCharName,data.time,0)
    -- print("++++++++++++++++++++++++++++++")
    -- printTable(UserChar[otherCharId])
	event.pushEvent("ON_SEND_PRIVATE_MESSAGE",data)
	event.pushEvent("ON_RESET_CHAT_HISTORY")
	event.pushEvent("ON_SET_PAO")
end

function onSendPrivateMessageSucceed(data)
	print("onSendPrivateMessageSucceed",data)
	printTable(data)
    local myCharId = userdata.UserInfo.id or userdata.UserInfo.charId
    local otherCharId = 0
    if myCharId == tonumber(data.charId) then
       otherCharId = tonumber(data.targetCharId)
    else
       otherCharId = tonumber(data.charId)
    end
    saveChar(myCharId,otherCharId,data.msg,data.charId,data.charName,data.targetCharId,data.targetCharName,data.time,1)
	event.pushEvent("ON_SEND_PRIVATE_MESSAGE_SUCCEED",data)
	event.pushEvent("ON_RESET_CHAT_HISTORY")
end

function onSendPrivateMessageFailed(data)

end

function onGetPrivateMessageListSucceed(data)
	print("onGetPrivateMessageListSucceed",data)
	printTable(data)
	for k,v in pairs(data) do
   	    local myCharId = userdata.UserInfo.id or userdata.UserInfo.charId
	    local otherCharId = 0
	    if myCharId == tonumber(v.charId) then
	       otherCharId = tonumber(v.targetCharId)
	    else
	       otherCharId = tonumber(v.charId)
	    end
    	saveChar(myCharId,otherCharId,v.msg,v.charId,v.charName,v.targetCharId,v.targetCharName,v.time,0)
    	getChar(myCharId)
    end
end

function onGetPrivateMessageListFailed(data)

end

function onGetPrivateCharListSucceed(data)
	print("onGetPrivateCharListSucceed",data)
	printTable(data)
    if data then
	    for k,v in pairs(data) do
	   	    call("getPrivateMessageList",tonumber(k))	
	    end
	end
end

function onGetPrivateCharListFailed(data)

end

function onFingerGameBetSucceed(gold)
	event.pushEvent("ON_FINGER_GAME_BET_SUCCEED",gold)
end

function onFingerGameBetFailed(msg)
    alert.create(msg)
end

function onFingerGameBetChange(gold)
	event.pushEvent("ON_FINGER_GAME_BET_CHANGE",gold)
end

function onFingerGameGuessSucceed(type)
	event.pushEvent("ON_FINGER_GAME_GUESS_SUCCEED",type)
end

function onFingerGameGuessFailed(msg)
    alert.create(msg)
	event.pushEvent("ON_FINGER_GAME_GUESS_FAILED")
end

function onFingerGameEndTime(endTime)
	event.pushEvent("ON_FINGER_GAME_ENDTIME",endTime)
end

function onFingerGameResult(fingerInfo)
	event.pushEvent("ON_FINGER_GAME_RESULT",fingerInfo)
end

function onFingerGameInvite(ownerId,ownerCharName)
	-- event.pushEvent("ON_FINGER_GAME_INVITE",ownerId,ownerCharName)
	inviterAlert.create(ownerId,ownerCharName)
end

function onFingerGameInviteSucceed(invitorId,invitorCharName)
	-- event.pushEvent("ON_FINGER_GAME_INVITE_SUCCEED",invitorId,invitorCharName)
	waitInviterAlert.create()
end

function onFingerGameInviteFailed(msg)
    alert.create(msg)
end

function onFingerGameInviteAgreeSucceed(fingerInfo)
	local moraGame = package.loaded["scene.moraGame"]
    moraGame.initData(fingerInfo)
    if waitInviterAlert.this then
       waitInviterAlert.exit()
    end
    if not moraGame.this then
   	   local mainScene = package.loaded["scene.main"]
       mainScene.createSubWidget(mainScene.widgetID.moraGame)
    end
    event.pushEvent("ON_FINGER_GAME_INVITE_AGREE_SUCCEED")
end

function onFingerGameInviteAgreeFailed(msg)
    alert.create(msg)
end

function onFingerGameInviteRefuse(invitorId,invitorCharName)
	-- event.pushEvent("ON_FINGER_GAME_INVITE_REFUSE",invitorId,invitorCharName)
    alert.create("玩家"..invitorCharName.."拒绝了您的邀请！")
    if waitInviterAlert.this then
       waitInviterAlert.exit()	
    end
end

function onFingerGameInviteCancel(ownerId,ownerCharName)
	-- event.pushEvent("ON_FINGER_GAME_INVITE_CANCEL",ownerId,ownerCharName)
    alert.create("玩家"..ownerCharName.."取消了邀请！")
    if inviterAlert.this then
       inviterAlert.exit()	
    end
end

function onGetAllActivityInfo(infoList)
	event.pushEvent("ON_GET_ALL_ACTIVITY_INFO",infoList)
end

function onGetActivityExist(flag)
	event.pushEvent("ON_GET_ACTIVITY_EXIST",flag)
end