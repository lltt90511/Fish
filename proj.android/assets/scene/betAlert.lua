LJ @./scene/betAlert.lua�  85   5 +  7% 4 4  'c >5 4 >4 >4 77	7
 74 >4 H  �onTriangleregisterEventScriptobjtriangle_touch
alertinitEditBoxinitBetView	thiswidgetcash/betAlertloadWidgetparentModulethisParenttool _parent  _parentModule   �  2   T�+  7%  % >+  7+ + 6>4 >G      �showOrHideBetListsetTexteffect_12buttonSoundreleaseUptool textInput betArr i event   � 	 !E'  ' ' I �4  777%  $67 7) >4  777%  $67 71 >0 �K �G   ��� registerEventScriptsetTouchEnabledobjxiala_bglist_layout
alertwidget		tool textInput betArr   i  �  (C'	4   7  7  7  7    7  > 	   T�/  + 7+ 773	 4  7777>T�	  T�/  + 7+ 773
 4  7777>G  � � easeOut	time ����x y� easeOut	time ����x y 	moveEffectcreateEffectgetPositionYobjbglist_layout
alertwidget� 	isShowBetList tool posY 	  � i�B,4  +   7> = 4    >+   T�4 >+   7> T�G    T�  TO�' ' 2    T1�Q0� 7 	 >5 4  7>5	 4	 '�  T�4
 7 	 7
  > = T�4
 7 4 >'  T�4 7% >+   7% >G  T�4
 7 >5 4 4 >  T	�4 4 74 4	 > =  = 5 +   74 >G     
floor	mathtostringtonumbertextStrconcatsetText&文字太长，超过输入限制create
alertinsert
tableord	bytecsub
endedreturnshowOrHideBetListgetText
print



     '''''(((((((((*****,textInput isShowBetList strEventName  jpSender  jstr Wi Ncnt Mtb L �  "q   T�+   7>+   74 '  '  > =G    ccpsetPositionattachWithIMEreleaseUptextInput event   � $u�2E4   7  7  7    7  > 4 74  74	 7
  7 >4  7% > =% >,  4  777 7+  >+   74 '  '  > =+   74 '  '  > =+   74 '� '� '� > =+   7'( >+   74 >+   7' >+   7' >+   7% >+   7% >+   7) >1 +   7 >4  77 7 7!) >4  77 7 7"1# >G  �� registerEventScriptsetTouchEnabledcost_touch!registerScriptEditBoxHandler setVisiblesetText输入金额setPlaceHoldersetMaxLengthsetReturnTypeDEFAULT_FONTsetFontNamesetFontSize	ccc3setFontColorsetAnchorPointccpsetPositionaddNodeimage/empty.pngCCScale9Spriteheight
widthCCSizeMakecreateCCEditBox	cast
toluagetSizeobj	cost
alertwidgetd




<=====>>>>>>>>??????D?EtextInput isShowBetList inputSize neditBoxTextEventHandler X �   /y4   +  > D�+ 7 >BN�2   ,   G  ��unListen
pairseventHash event   k v   �   5�4      T�4  > /   / )   5  )   5  4     7  ) > +  7  4 > )   5   G  �� �widgetcleanWidgetRefremoveFromParentAndCleanupparentModulethisParentcleanEvent	this		textInput isShowBetList tool  �  Je�   TG�+  7%  % >+  7> T�4 +  7> =   T
�+  7% >4 7%	 >T*�4 +  7> = '   T�4 7%
 >T�4   T	�4 7  T�4 7% >T�4 % 4 74 +  7> =  =  =+ 7% >G   ���ON_BET_ALERT_BACKpushEvent
floor	mathfingerGameBet	call,已押注，请勿修改押注金额！isYazhuparentModule押注金额必须大于0请输入押注金额create
alertsetTexttonumbergetTexteffect_12buttonSoundreleaseUp






tool textInput event ev  K   
�   T�+  7%  % >4 >G   �showOrHideBetListeffect_12buttonSoundreleaseUptool event   �  �   T�+  7%  % >4 >+ 7% >G   ��ON_BET_ALERT_BACKpushEvent	exiteffect_12buttonSoundreleaseUptool event ev   �
  G ^� �4   % > 4  % >4  % >4  % >74 % 4 7	>)  5
 )  5 )  5 )  2  3 ) 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 3  3	! 3
" 4 :#
:
$	3
% 3& 3' 3( :):*3+ 3, :):-3. 3/ :):031 32 :):334 35 :):6:7
:
8	3
9 3: :;
:
<	3
= :
>	3
? 4 :#
:
@	3
A :
B	3
C :
D	:	E5F 0  �G  widget
alerttriangle_touch 
_typeLayoutcost_touch 
_typeLayout	back 
_typeButton
title 
_typeImageView	costtriangle 
_typeButton 
_typeImageViewlist_layoutbgxiala_5 
_type
Label 
_typeImageViewxiala_4 
_type
Label 
_typeImageViewxiala_3 
_type
Label 
_typeImageViewxiala_2 
_type
Label 
_typeImageViewxiala_1num 
_type
Label 
_typeImageView 
_typeLayout 
_typeLayoutbtn
_func 
_typeButton 
_typeImageView _ignoreonBack onTriangle 
onBet 	exit cleanEvent initEditBox showOrHideBetList initBetView create   ��N����=��zparentModulethisParent	thisseeallpackagescene.betAlertmodule	datatemplate.gamedatalogic.userdatalogic.eventlogic.toolrequire		

%0'w2~y��������������������������������������������������������tool [event Xuserdata Utemplate QtextInput EeventHash DbetArr CisShowBetList B  