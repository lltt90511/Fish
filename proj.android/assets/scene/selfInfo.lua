LJ @./scene/selfInfo.lua� :   T�+  7%  % >4 +  ) >+ 77+   T�4 % +  >G    � changeSex	callsexUserInfoswitchSexeffect_12buttonSoundreleaseUptool id userdata event  data   �
 W�+  7 % 4   'c >5 2 4 777;4 777;4 777;5	 4
 4	 >D� 7 71	 >0 �BN�4 >+ 7% 4 >+ 7% 4 >+ 7% 4 >+ 7% 4 >+ 7% 4 >+ 7% 4 >4 >4 77 7) >4 >4 % >4 0  �H  ���getQuestCountList	callinitEditBoxsetTouchEnablednameEditshowDajiangON_GET_QUESTonSetDefaultImageSucceedHEAD_ICON_CHANGEonUploadSucceedUPLOAD_PERSONAL_PHOTOON_CHANGE_NAMEON_CHANGE_VIPON_CHANGE_GOLDlisteninitInfo registerEventScriptobj
pairsboxListfemalemanunKnowbg
panel	thiswidgetcash/self_infoloadWidgettool userdata event parent  X
 
 
i v  id  �   %C1+   7   7  7  +  7 77   T�'     T�'  4 7777 7	%
   $>4 7777 7	%  $>G  �鲨鱼*
seven大奖*setTextobjbarbg
panelwidget522523hashKeyUserInfo											










userdata barCnt !sevenCnt  � 
 9>	4  %   >   4 4 >D�7 7)	 >BN�
 T�4 6 7 7) >G  setSelectedStateobjboxList
pairsswitchSex
print	id  click  	  _ v   �  n�H4   7  7  7  7    7  +  77 > 4  +  77>  	 T �4   7  7  7 
 7    7  % > 4   7  7  7 
 7    7  4 '� '� '� > = 4   7  7  7  7    7  +  77> 4   7  7  7  7    7  +  77+  77> +  7  +  77> 4  7777 7  >4  7777 7 %  $>4  7777 7!>4 +  77>G  ��sexswitchSexsetPercentvipBar/vipNumsetStringValue
vipLvvipExpgetVipLvgiftGold	gold	name	ccc3setColor已绑定accountuserdataphoneNumber	typeUserInfosetTextobjidbg
panelwidget����									











userdata countLv vipLv J%now  %max  % �   /W4   +  > D�+ 7 >BN�2   ,   G  
��unListen
pairseventHash event   k v   �   7C_4      T3�4  > +   7  % > +   7  % 4 > +   7  % 4 > +   7  % 4 > +   7  %	 4
 > +   7  % 4 > +   7  % 4 > )   5  2   5  4     7  ) > +  7  4 > )   5   G  � �widgetcleanWidgetRefremoveFromParentAndCleanupboxListtextInputshowDajiangON_GET_QUESTonSetDefaultImageSucceedHEAD_ICON_CHANGEonUploadSucceedUPLOAD_PERSONAL_PHOTOON_CHANGE_NAMEON_CHANGE_VIPinitInfoON_CHANGE_GOLDunListenON_BACKpushEventcleanEvent	this					

event tool  q  
q   T�+  7%  % >4 >G   �	exiteffect_12buttonSoundreleaseUptool event   �  -w   T�+  7%  % >4 77 7'>4  7+ 7	7
>G   ��	nameUserInfosetTexttextInputsetPositionXobjnameEditwidgeteffect_12buttonSoundreleaseUptool userdata event   �  ~   T�+  7%  % >4 77 7'�>G   �setPositionXobjnameEditwidgeteffect_12buttonSoundreleaseUptool event   �   9� T�4  7% >G  4 7 >4  >7 T�4  7% >G  4	 %
 7>G  
paramchangeCharName	call,您输入的内容检测包含屏蔽字
falseresultprintTabledecode
cjson服务器连接失败create
alert	header  body  flag  tab  � -W�   T*�+  7%  % >4 77 7'�>4  7>+ 7	7
 T�4 7% >T�+ 7 >4 %  >+ 74 %  $1 >G   ��� !/ydream/login?type=99&param=payServerUrlrequest	_msg
printurlencode名字未变化create
alert	nameUserInfogetTexttextInputsetPositionXobjnameEditwidgeteffect_12buttonSoundreleaseUp				






tool userdata http event  .text _msg  �  %�   T�+  7%  % >4 >4 777%  >G   �onShangchengscene.mainloadedpackage	exiteffect_12buttonSoundreleaseUptool event  main  �  W��4  4  7> = 4    >4  7>4  %   > T�G    T�  T=�' 2    T0�Q/� 7  >5 4  7	>5
 4
 '�  T�4 7  7	 
 > =T�4 7 4 > '  T�4 7% >4  7% >G  T�4  74 7 > =G  concatsetText'用户名不能超过6个字符！create
alertinsert
tableord	bytecsub
endedreturn#str!!!!!!!!!!!getTexttextInput
print	
strEventName  XpSender  Xstr Ji <tb ; �   �   T�4 % >4  7>4  74 ' '��> =G  ccpsetPositionattachWithIMEtextInputtextInput attachWithIME
printreleaseUpevent   �  ! m��94   7  4  74 '�'L >4  7% > =% > 5  4  7 	 7 
 7    7  4 > 4    7  4 ' '��> = 4    7  4 '  '  > = 4    7  4 '� '� '� > = 4    7  '( > 4    7  4 > 4    7  ' > 4    7  ' > 4    7  % > 4    7  % > 4    7  ) > 1  4  7  >4 7	7
7 7) >4 7	7
7 71  >G   registerEventScriptsetTouchEnabled!registerScriptEditBoxHandler setVisiblesetText输入昵称setPlaceHoldersetMaxLengthsetReturnTypeDEFAULT_FONTsetFontNamesetFontSize	ccc3setFontColorsetAnchorPointccpsetPositionaddNodeobjinput_bgnameEditwidgettextInputimage/empty.pngCCScale9SpriteCCSizeMakecreateCCEditBox	cast
tolua					




-.....////////000000809editBoxTextEventHandler X �   �4    >4 73 7 :>4 % >G  uploadImage	call	path 	typeseconds fullPathinsertUploadfileManagerprintTablet   � J�   T�4 % >1 4 7% % 3 +  :	+ :
:>4  >4 7% % 3 +  ;+ ;>G  �	�  onUploadFromLocalstartPhotocc/yongdream/nshx/Util	luajsetTakePhotoFuncCallBackcallbackheight
width 	typechooseImageAppControllercallStaticMethod
luaoc ##########onUploadLocal
printreleaseUp			









imageWidth imageHeight event   callback  �  "8�4  7 4 >)   '  T�4 7 % > 4   % >8  T�7 	  T�4 %	  >4
 7% >G  头像上传成功create
alertsetDefaultImage	call	type/concat
tablesplitURLCharfileNamesplitString			



data  #arr2 uuid  �  	 '�+   7   + 4 77777+ 77> G   �
��idUserInfoobjimg
imagebg
panelwidgetloadRemoteImagetool eventHash userdata  �  r �� �4   % > 4  % >4  % >4  % >4  % >4  % >4  % >4  % >4	 %	
 4
 7

>)  5 2  5 )  5 'd '	d 2
  1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1  5! 1" 5# 1$ 5% 1& 5' 1( 5) 1* 5+ 1, 5- 3. 3b 31 3/ 4 :0:234 33 :536 37 :84) :0:9::3; :<3= :>3? :@3A :B3C :D3E :F3G :H3I :J3K :L3M :N3O :P3Q :R3S :T3U :V3W :X3Y 4 :03Z :83[ :\:]3^ 3_ :83` :\4% :0:a:c:d3f 3e :g3h 4! :0:23i :j3k :83l 4# :03m :83n :\:o:p5q 0  �G  widgetnameEditbtn 
_type
Label 
_type
Label 
_typeButton 
_type
Label
text2 
_type
Label 
_typeButtoninput_bg   
_typeImageView
panelbg  gold_get 
_type
Label 
_type
Label 
_typeButtonchangeNametext_shadow 
_type
Label 
_type
Label 
_typeButtonvipBar 
_typeLoadingBar
vipLv 
_typeLabelAtlas
seven 
_type
Labelbar 
_type
LabelvipNum 
_type
Label	gold 
_type
LabelunKnow_text 
_type
Labelfemale_text 
_type
Labelman_text 
_type
LabelunKnow 
_typeCheckBoxfemale 
_typeCheckBoxman 
_typeCheckBox	name 
_type
Labelaccount 
_type
Labelid 
_type
Label
imageupload	text 
_type
Label 
_typeButtonimg   
_typeImageView	back  
_func 
_typeButton _ignoreonSetDefaultImageSucceed onUploadSucceed onUpload initEditBox onGoldGet onChangeNameCurrent onChangeNameCancel onChangeName onBack 	exit cleanEvent initInfo switchSex showDajiang create textInputboxList	thisseeallpackagescene.selfInfomodulelogic.httplogic.countLvlogic.userdatawidget.scaleListscene.fishMachine.mainscene.fruitMachine.mainlogic.eventlogic.toolrequire                        	 	 	 	 	          /  < 1 G > U H \ W o _ v q } w � ~ � � � � � � � � � �  	

 !!""##$%''(())*+./0011112233455667789;;;tool �event �fruitMachine �fishMachine �scaleList �userdata �countLv �http �imageWidth ximageHeight weventHash v  