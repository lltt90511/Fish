LJ @./scene/chat/main.lua� 	7�+  7 % 4 *	 )
 >5 , 4 7 74  	 > =, , ,  , ,  4 >4 >4	 + >4 7
7 7) >+ 7% 4 >+ 7% 4 >+ 7% 4 >4 H  ���������onSystemContextSYSTEM_CONTEXTonSystemMessageSYSTEM_MESSAGEonUserMessageUSER_MESSAGElistensetVisiblesystem_layout!changeExpressionPanelVisibleinitListViewinitEditBoxCCSizesetSizeobj	thiswidgetcash/chatloadWidget�
	

tool parentModule WIDTH HEIGHT GAME_ID inputWidthChange messageList expVisible event _data  8_width  8_height  8_gameId  8_parentModule  8 � T�C4  +   7> = 4    >+   7> T�G    T�  T?�' ' 2    T1�Q0� 7 	 >5 4  7>5 4 '�  T�4	 7
 	 7
  > =T�4	 7
 4 >'  T�4 7% >+   7% >G  T�+   74	 7	 > =G   concatsetText&文字太长，超过输入限制create
alertinsert
tableord	bytecsub
endedreturngetText
print	
textInput strEventName  UpSender  Ustr Gi >cnt =tb < �  "e   T�+   7>+   74 '  '  > =G   ccpsetPositionattachWithIMEreleaseUptextInput event   � $ |�/<4   7  7    7  > 4  77 74 7 +  7 > =4 7	4
  74 7 7 >4  7% > =%
 >, 4  77 7+ >+  74 '  '  > =+  74 '  '  > =+  74 '� '� '� > =+  7'( >+  74 >+  7' >+  7' >+  7% >+  7% >+  7) >1 +  7  >4  77 7!) >4  77 7"1# >G  �� registerEventScriptsetTouchEnabled!registerScriptEditBoxHandler setVisiblesetText输入文字setPlaceHoldersetMaxLengthsetReturnTypeDEFAULT_FONTsetFontNamesetFontSize	ccc3setFontColorsetAnchorPointccpsetPositionaddNodeimage/empty.pngCCScale9SpriteCCSizeMakecreateCCEditBox	cast
toluaheight
widthCCSizesetSizegetSizeobjinput_bgwidget									344444555555566666;6<inputWidthChange textInput inputSize veditBoxTextEventHandler b m    x4      T �G  4  7  7    7  ) > G  setBounceEnabledobj	listwidget	this �  t4      T �0 �4  7  7    7  ) > 4  7  7    7  (  ) > 4  1 ( > G  G   performWithDelayscrollToBottomsetBounceEnabledobj	listwidget	this�����̙���� � 	'Am4   7  7    7  ) > 4   7  7    7  ) > 4   7  7    7  > '  +   ' I �4 +  6 >K �4  1 +    > G  � performWithDelayaddMessageremoveAllItemssetTouchEnabledsetVisibleobj	listwidget��̙����messageList   i  �  =�   T�+   7> % + $+   7 >+  , 4 + >G   � !changeExpressionPanelVisiblesetText;getTextreleaseUp			


textInput i expVisible event1  str  �  M�+  7   4 774 7774 77'N '  ) % ' 4	 7		7			> 
,   4  7  7 
 7    7 ) >  7 ) >' '( ' I&�3 4 7  7 >% >:7 7) >7 7% 	 %
 $
>7 7) >7 71 >+  77>0 �K�G  
����pushItem registerEventScript	.pngexpression/expression_a_0loadTexture  ImageView
clone	cast
toluasetTouchEnabledsetVisibleexp_tmpscene.chat.mainloadedpackagescroll_barscroll_bgobjscrollwidgetcreate					



expScroll scrollList textInput expVisible render_tmp 3' ' 'i $render 	 �  0�4    % >4 7  ' ' > T� 	  T�4 8>
  T�'  T�'(  T�H )  H tonumbersubstring;splitString

str  arr num 	 � ���B4  % >'  2  % ' 4 77	 '
 >  T
�4
 7

 7>
T
�'
 
 T

�4
 7

 4 77'  > =
  T
-�Q
,�	  T
�		 T
�4
 7

 	 >
 4
 7

7  >
	  
   T

�4
 7

 4 77 > =
T
� T
�4
 7

 4 77  > =
T
�+
  7


7>
'  
 T�4  7> 7% 
 $> 7'( > 74 > 7>74  7> 7% 7% $> 7'( > 74 > 7>74 '� '� '� > T�4 '� '  '� > '  ' I=�4 6>
  T�4   >4  7  '� %  % $>  7  >T#�4  7  '� 64 '( >  7  >4  7> 76> 7'( > 74 > 7>7K�H �RichElementTextpushBackElement	.pngexpression/expression_a_0RichElementImageisExpression	ccc3] 	name[
widthgetContentSizeDEFAULT_FONTsetFontNamesetFontSizeVsetTextcreate
LabelvipExpgetVipLvsubinsert
tablemsg	findstring(%;(%d+))######addsplitmessage
print�			









""""#######$$$$%%%%&&&&&'''''(()))))),,,,---..///000000000001111335555555555666688889999::::;;;;=====,AcountLv richText  �msg  �flag  �totalWidth �args �pattern �last_end �s �e  �cap  �vipLv H�viplbl name ccolor J> > >i <path 9_image _msg msg  �  ;}�   T8�+  7+ 77 T�+  7+ 77 T�4 7% >G  4 % >4	 7
74	 7
7+   T�+  T�+  T�+ 7  T�+ 7) >+ 7+ 77+  7+  7+ >G      	nameobjwidgetresetShowChatHistoryscene.fishMachine.mainscene.fruitMachine.mainloadedpackage-layout is in touch!!!!!!!!!!!!!!!!!!!!!!
print您不能与自己私聊!!create
alertidUserInfocharIdreleaseUp			





message userdata parentModule chatPrivate event  <fruit fish  �	 !���24      T �0 ��4    7  > 4  7> 7) > 74 +  'H > =+ 7+ 7>' 4	 '� '� '� >) '   T�4
  7 4		 '
� '� '  >	'
� %  $4 '( >  7	 >4	 '� '	  '
� > ) 4
  7 	 '
� % + 7% $4 '( > 7	 >4  +	 
 >+   T�	 7)
 >	 74
 +   7>74 7+  !> >
 =	 74
 '  '  >
 =	 74
 '  '  >
 =	  7  7
>
 =	  7 
 >	  7 )
 >	  7 1
 >4 77	 7 
  >G  G     �    pushBackCustomItemobj	listwidget registerEventScriptsetTouchEnabledaddChildsetPositionccpsetAnchorPoint	ceil	mathheightgetSizeaddSplitMessage] 	name[pushBackElementDEFAULT_FONTVRichElementText	ccc3vipExpgetVipLvCCSizesetSizeignoreContentAdaptWithSizeRichTextcreateLayout	this	


011111112WIDTH countLv message userdata parentModule chatPrivate layout 	�_richText �vipLv |num {color vflag u_vip _name HtextWidth 	? �^�97    T�+  77  T�0 �  T�(  T �1 4   >0  �G  G  �����performWithDelay 	isGMUserInfoisFake��̙����7888899userdata WIDTH countLv parentModule chatPrivate message  time  func  n    �4      T �G  4  7  7    7  ) > G  setBounceEnabledobj	listwidget	this �  �4      T �0 �4  7  7    7  ) > 4  7  7    7  (  ) > 4  1 ( > G  G   performWithDelayscrollToBottomsetBounceEnabledobj	listwidget	this�����̙���� �
2�4  7+    >+   '2  T�4  7+  ' >4 77 7'  >4   >4 1	 (  >G  � performWithDelayaddMessageremoveItemobj	listwidgetremoveinsert
table�̙����messageList data   "    	�+   > G   func  �  ,�4   % > /   / .  +    7  > +  > G   ���� removeFromParent"finish!!!!!!!!!!!!!!!!!!!!!!!
printdata hasVip count layout func  � 
t��04   % +  7> )   ) ' 4 + >D
�7 T�4  %	 >   ) T�BN� T�+ 8 +  7 T�   T�7  T�+ 7+ 77	3
 4 71 >TB�+  	  T
�/ 4 77 7) >0  �G  / 4 7+  >4 77 7) >+ 77 '( > 74 + '  > =4 77 7 > 7>+ 7+ 773 7:7 : 1	 >0 �0  �G     �    x	time y 
width	movegetSizeaddChildccpsetPosition	textgetRichTextWithColorremove
tablesetVisiblesystem_layout objwidget 	time
delayEffectcreateEffect&a11111111111111111111111111111111VIP_COM	type
pairsisInGame!playSystemMessageEffect func
print d����	
       !!!!!"""""""#######$$$%%%%%%%%%%%%%%-%-00userdata systemMessageList tool func isSystemMessagePlaying WIDTH data nhasVip mcount l  k 
v  
layout D!layoutSize  � W�7+   T�0 �)  1   >0  �G  G  ��� �� 56677isSystemMessagePlaying userdata systemMessageList tool WIDTH flag  func  �  /�7  +   T�4 7+   >4 ) >G  ��playSystemMessageEffectinsert
tablegameIdGAME_ID systemMessageList data   �  5�2  :  :4 7+   >4 ) >G  �playSystemMessageEffectinsert
table	type	textsystemMessageList data  type  _data  �  $6�
  T�+    T�4  >+    T�+  7  >4 77 7  >4 77 7  >4 77 7  >G  
�scroll_bgsetVisibleobjscrollwidgetsetTouchEnabledinitExpression							
expScroll flag  % �  ,��4      T(�+   7  % 4 > +   7  % 4 > +   7  % 4 > 4     7  ) > )   5   /  +  7 	 4
 > /  / 2   ,  / 2   ,  /  /	  /
  /  /  .  G  �� �
������	�����widgetcleanWidgetRefremoveFromParentAndCleanuponSystemContextSYSTEM_CONTEXTonSystemMessageSYSTEM_MESSAGEonUserMessageUSER_MESSAGEunListen	this 	
event parentModule tool expScroll expVisible systemMessageList isSystemMessagePlaying messageList textInput textRich WIDTH HEIGHT GAME_ID inputWidthChange  u  	�   T�+   ,  4 +  >G  �!changeExpressionPanelVisiblereleaseUpexpVisible event  
 �  %Q� T�4  7% >G  4 7 >4  >7 T
�4  7% >+   7	7
>G  4 % + >+   7	% >G    �gameChat	call
paramsetText,您输入的内容检测包含屏蔽字
falseresultprintTabledecode
cjson服务器连接失败create
alert					
textInput str header  &body  &flag  &tab  �
 C�   T�+   7> T�+ 7 >4 % 4 4 % $ >+ 74 %  $1	 >0 �G  �� request!/ydream/login?type=99&param=payServerUrl	_msg
printurlencodegetTextreleaseUptextInput http event  str _msg  �  @ \� �4   % > 4  % >4  % >4  % >4  % >4  % >4  % >4 %	 4	
 7		>)  5 2  *
 ) * 2  ) '  )  1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5  1! 5" 1# 5$ 1% 5& 1' 5( 1) 5* 3+ 3, :-3. 4( :/:031 4* :/:233 :435 :637 38 :9::3; 3< :=:>5? 0  �G  widgetscroll_bgscroll_bar 
_typeImageView 
_typeImageViewscrollexp_tmp _anchory 
_typeImageView_anchorx  
_typeScrollView	list 
_typeListViewsystem_layout 
_typeLayoutsend_btn 
_typeButtonexp_btn
_func 
_typeButtoninput_bg 
_typeImageView _ignoreonSend onExpression 	exit !changeExpressionPanelVisible onSystemContext onSystemMessage playSystemMessageEffect onUserMessage addMessage addSplitMessage isExpression initExpression initListView initEditBox create 	thisseeallpackagescene.chat.mainmodulescene.chatPrivatewidget.scrollListlogic.httplogic.countLvlogic.userdatalogic.eventlogic.toolrequire                     	 	 	 	 	           -  k / } m �  � � � � &� 9(r;yt�{����������������������������������tool Yevent Vuserdata ScountLv Phttp MscrollList JchatPrivate GmessageList ?textInput >textRich  >expScroll  >expVisible =WIDTH <HEIGHT  <GAME_ID  <systemMessageList ;isSystemMessagePlaying :inputWidthChange 9parentModule 8  