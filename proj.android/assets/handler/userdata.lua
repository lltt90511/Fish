LJ @./handler/userdata.lua� 	 <

4  %    >+  7: +  7:+ 7% >+  7 T�+  ) :+  ) :G  � �goldActionisLotteryON_CHANGE_GOLDpushEvent	goldgiftGoldUserInfoonChangeGold
print
userdata event giftGold  gold   =  +  7 : G  �sexUserInfouserdata sex   � 
 %V+  7 7  T�+  7 2  :+  7 79  T� T�+ 76  T�4 7' 7>+ 7%    >+  7 : 	G  �� �lastChargeTimeCHARGE_SUCCESSpushEventgoldGetrmbumengPaychargechargeMapUserInfo		




userdata template event time  &id  &cnt  &tpl  7   *4  7  >G  create
alertstr   �  !-4  % >+  7: + 7% >G  � �ON_CHANGE_VIPpushEventvipExpUserInfoonChangeVipExp
printuserdata event vip   7   34  7  >G  create
alertstr   �  #6+  7 : + 7% >4 7% >G  � �修改成功create
alertON_CHANGE_NAMEpushEvent	nameUserInfouserdata event name   �  ;4   7  7  7 C  = +  7% C  =G   �ON_GET_RANK_LISTpushEventonGetRankListscene.rankloadedpackageevent rank 	 D   A4  %   >G  onGetRankListFailed
printstr   �   D4   7  % > 4  7  7  7 C  = G  onGetDailyGiftscene.loginGiftloadedpackageeffect_07playEffectAudioEnginedaily  � 	 FK4  % >+  : 4   >4 +  7>4   >D�4  > T�)  9 BN�+ 7% >G  � �ON_UPDATE_MAILpushEventuserdata	type
pairsprintTablegiftList>onGetGiftList_________________---------------------------
print



userdata event list  
 
 
i v   � 
$JX4  +  7> T�4 +  7>D�7  T�+  76' :7 	  T�4 7% 7	%	
 $	>BN�+ 7% >G  � �ON_UPDATE_MAILpushEvent枚金币num您获得了create
alert	readid
pairs
tablegiftList	typeuserdata event id  %  i v   7   h4  7  >G  create
alertstr   �  )l+  7   T�+  2  : 4 7+  7   >+ 7% >G  � �ON_UPDATE_MAILpushEventinsert
tablegiftListuserdata event gift   �  0t4  %    >+  7: +  7:+ 7%    >G  � �ON_GET_TREEpushEventtreeGiftGoldlastTreeGiftTimeUserInfoonUpdateTreeGift!!!!!!!
printuserdata event time  gold   �  ={	4  %     >4 7% >+  7: +  7:+ 7%	 >+ 7%
 >G  � �ON_GET_TREE_SUCCESSON_CHANGE_GOLDpushEventtreeGiftGoldlastTreeGiftTimeUserInfoeffect_07playEffectAudioEngineonGetTreeGiftSucceed
print	userdata event time  gold  get   �  �+  7 : + 7% >G  � �ON_GET_PHONEpushEventlastPhoneCodeTimeUserInfouserdata event time  	 8   �4  7  >G  create
alertstr   a   
�4   % '  +  > 4  % +  > G  �	uuidsaveSetting
login	calluuid  � #B�4  %    >4  > T�4   >)   T�4 7% >) T�4 7% )  1 >+  7	%
  >0  �G   �ON_REGISTER_PHONEpushEvent 8该手机已经绑定了账号，登陆该账号？绑定成功！create
alertstring	type3onRegisterPhoneSucceed!!!!!!!!!!!!!!!!!!!!!!!!
print




event relogin  $uuid  $flag  8   �4  7  >G  create
alertstr   8   �4  7  >G  create
alertstr   � 
 1�4  7% >4 %    >+  7: +  7:+ 7%	 >G  � �ON_GET_FREE_GOLDpushEventlastFreeGoldTimefreeGoldCntUserInfoonGetFreeGoldSucceed
printeffect_07playEffectAudioEngineuserdata event cnt  time   \   
�4   T�) 5  4 7  >G  create
alertgoldActionstr   6    �4   % 4 > G  	uuidsaveSetting � 	%�4   % > 4  % > 7 7 7>+  71 (  >G  � performWithDelaystartSceneSceneTypechangelogic.sceneManagerrequire7onUnregisterPhone!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~
print��̙����tool sceneManager 
 �  ,c�+  7 2  :+  7 2  :+  7 2  :+  7 : +  7 :+  7 :4 % >4   >4 % >4  >4 % >4  >+ 7	%
 >G  � �ON_GET_QUESTpushEventonGetQuestCountList3onGetQuestCountList2printTableonGetQuestCountList1
printreachedQuesttimeHashKeyhashKeyUserInfo			


userdata event hashKey  -timeHashKey  -reachedQuest  - �  )�4  7% >4 %   >4 7+  77  >+ 7	%
 >G  � �ON_FINISH_QUESTpushEventreachedQuestUserInfoinsert
tableonFinishQuestSucceed
printeffect_07playEffectAudioEngineuserdata event id   8   �4  7  >G  create
alertstr   �  )X�4  %  >+  77  T�+  72  :+  77  T�+  72  :4   >D�+  779+  779BN�+ 7% >G  � �ON_UPDATE_QUESTpushEvent
pairstimeHashKeyhashKeyUserInfoonUpdateQuestCount
print				



		userdata event list  *time  *  k v   � 	 C�4  %     >+  7:+  7:+  7 T�+  ) :+ 7%    >G  � �ON_RANDOM_GOLDpushEventisLotterylastRandomTimerandomCntUserInfoonGetRandomGoldSucceed
printuserdata event id  time  cnt  list   �  #�+  7  T�+  ) : +  7 T�+  ) :4 7  >G  �create
alertisLotteryisInGameuserdata str      
�4  %    >4 7% >G  领取成功！create
alertonGetVIPRewardSucceed
printr  s   8   �4  7  >G  create
alertstr   �  7g�4  %   >4   >+  77  T�+  77'  4 7 > T�4 7 > T�4 7 > 4   7	 7 7
 7	 7
 7 '  >
+ 7%   >+ 7% >+ 7% >G  � �ON_SET_PAOON_RESET_CHAT_HISTORYON_SEND_PRIVATE_MESSAGEpushEvent	timetargetCharNamecharNamemsgsaveChartargetCharIdtonumbercharIdidUserInfoprintTableonSendPrivateMessage
print










userdata event data  8myCharId (otherCharId ' �  3c�4  %   >4   >+  77  T�+  77'  4 7 > T�4 7 > T�4 7 > 4   7	 7 7
 7	 7
 7 ' >
+ 7%   >+ 7% >G  � �ON_RESET_CHAT_HISTORY$ON_SEND_PRIVATE_MESSAGE_SUCCEEDpushEvent	timetargetCharNamecharNamemsgsaveChartargetCharIdtonumbercharIdidUserInfoprintTable onSendPrivateMessageSucceed
print










userdata event data  4myCharId $otherCharId #     	�G  data   �  3n�4  %   >4   >4   >D%�+  77  T�+  77'  4 7	> T�4 7	> T�4 7	> 4	 	 
 7
77777'  >
4 	 >BN�G  �getChar	timetargetCharNamecharNamemsgsaveChartargetCharIdtonumbercharIdidUserInfo
pairsprintTable#onGetPrivateMessageListSucceed
print				userdata data  4( ( (k %v  %myCharId otherCharId      	�G  data   � 
  /�4  %   >4   >   T�4   >D�4 % 4 	 > =BN�G  tonumbergetPrivateMessageList	call
pairsprintTable onGetPrivateCharListSucceed
printdata  	 	 	k v       	�G  data   ^  �+  7 %   >G   �ON_FINGER_GAME_BET_SUCCEEDpushEventevent gold   8   �4  7  >G  create
alertmsg   ]  �+  7 %   >G   �ON_FINGER_GAME_BET_CHANGEpushEventevent gold   `  �+  7 %   >G   �!ON_FINGER_GAME_GUESS_SUCCEEDpushEventevent type   z  	�4  7  >+  7% >G   � ON_FINGER_GAME_GUESS_FAILEDpushEventcreate
alertevent msg  
 ]  �+  7 %   >G   �ON_FINGER_GAME_ENDTIMEpushEventevent endTime   _  �+  7 %   >G   �ON_FINGER_GAME_RESULTpushEventevent fingerInfo   Z  .�+  7    >G  �createinviterAlert ownerId  ownerCharName   X  4�+  7 >G  �createwaitInviterAlert invitorId  invitorCharName   8   �4  7  >G  create
alertmsg   �  X�4  777  >+  7  T�+  7>7  T�4  77777	>+ 7
% >G  � �(ON_FINGER_GAME_INVITE_AGREE_SUCCEEDpushEventmoraGamewidgetIDcreateSubWidgetscene.main	exit	thisinitDatascene.moraGameloadedpackage



waitInviterAlert event fingerInfo  moraGame mainScene  8   �4  7  >G  create
alertmsg   �  ?�4  7%  % $>+  7  T�+  7>G  �	exit	this拒绝了您的邀请！玩家create
alertwaitInviterAlert invitorId  invitorCharName   �  7�4  7%  % $>+  7  T�+  7>G  �	exit	this取消了邀请！玩家create
alertinviterAlert ownerId  ownerCharName   `  �+  7 %   >G   �ON_GET_ALL_ACTIVITY_INFOpushEventevent infoList   Y  �+  7 %   >G   �ON_GET_ACTIVITY_EXISTpushEventevent flag   � 	 z �� �4   % > 4  % >4  % >4  % >74  % >4  % >4 %	 4
 7>1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1  5! 1" 5# 1$ 5% 1& 5' 1( 5) 1* 5+ 1, 5- 1. 5/ 10 51 12 53 14 55 16 57 18 59 1: 5; 1< 5= 1> 5? 1@ 5A 1B 5C 1D 5E 1F 5G 1H 5I 1J 5K 1L 5M 1N 5O 1P 5Q 1R 5S 1T 5U 1V 5W 1X 5Y 1Z 5[ 1\ 5] 1^ 5_ 1` 5a 1b 5c 1d 5e 1f 5g 1h 5i 1j 5k 1l 5m 1n 5o 1p 5q 1r 5s 1t 5u 1v 5w 1x 5y 0  �G  onGetActivityExist onGetAllActivityInfo onFingerGameInviteCancel onFingerGameInviteRefuse "onFingerGameInviteAgreeFailed #onFingerGameInviteAgreeSucceed onFingerGameInviteFailed onFingerGameInviteSucceed onFingerGameInvite onFingerGameResult onFingerGameEndTime onFingerGameGuessFailed onFingerGameGuessSucceed onFingerGameBetChange onFingerGameBetFailed onFingerGameBetSucceed onGetPrivateCharListFailed  onGetPrivateCharListSucceed "onGetPrivateMessageListFailed #onGetPrivateMessageListSucceed onSendPrivateMessageFailed  onSendPrivateMessageSucceed onSendPrivateMessage onGetVIPRewardFailed onGetVIPRewardSucceed onGetRandomGoldFailed onGetRandomGoldSucceed onUpdateQuestCount onFinishQuestFailed onFinishQuestSucceed onGetQuestCountList onUnregisterPhone onGetFreeGoldFailed onGetFreeGoldSucceed onUnregisterPhoneFailed onRegisterPhoneFailed onRegisterPhoneSucceed onGetPhoneCodeFailed onGetPhoneCodeSucceed onGetTreeGiftSucceed onUpdateTreeGift onNewGiftSend onOpenGiftPackFailed onOpenGiftPackSucceed onGetGiftList onGetDailyGift onGetRankListFailed onGetRankListSucceed onUpdateUserNameSucceed onUpdateUserNameFailed onChangeVipExp onChargeFailed onChargeSucceed onSetSexSucceed onChangeGold seeallpackagehandler.userdatamodulescene.waitInviterAlertscene.inviterAlert	datatemplate.gamedatalogic.toollogic.userdatalogic.eventrequire                         
   )  , * 1 - 5 3 : 6 ? ; C A I D V K f X j h r l y t � { � � � � � � � � � � � � � � � � � � � � � � � � � � � 
+/-?1CAMEQOUSYW][a_fcjhnlspxu|z�~������������event �userdata �tool template {inviterAlert xwaitInviterAlert u  