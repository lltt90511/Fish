LJ @./widget/scrollListV2.luaÊ 	  ([4  % 4 7> =2  : 4 77 7>%	 >:3 ::
:
:) :'  :'  :2  :2  :4   >4  >H _initFunc
_inititemListinfoListinnerHeight
maxIdisDrawdefauleItembg  barLayoutgetInnerContainer	cast
toluainnerLayoutobj	timeos6#####################createScrollList!!!!!!!!!!!!
print		

obj  )bar  )barBg  )defauleItem  )config  )this ! =  Z4  +    >G   À_onScrollthis event   Ü
" É*34  % 4 7> =  T2  7  T2  :77  T72  :777  T77'  :777  T77'  :777  T77'  :7	  T2  :	7	7
  T7	3 :
7  T2  :+  77 >+  77  3 777:>7  7>3 7:7:: 77
  T7 7 777777:7  74 7 77 7> =7 7 7>7 7777777: 7 7 74 77	 > ='  : 7 7 7'  >: 7  7 1! >0  G   À registerEventScriptconfigsetOpacitybarHeight2barHeightbgbarCCSizesetSizeheightOffsetheight  
width	sizegetSizey x setPositionobjgetPosition	func x y pos	item	leftbottomtopemptySizescroll	timeos4#####################initScrollList!!!!!!!!!!!!
print			""""######$$$$%%%%%%%%%%%&&&&&&&&&&((((()))))))))))+++++++++--....../0002033tool this  config  pos FVsize HbgSize $$ ¬  %a	+  7 3 :9 +  7  T	+  : +  7 T4 +  >G   À_updateInnerSizeisDraw
maxId	info  infoList	this id  info      )>l+  7 6   T+  7 3 :9 +  7 6 :+  7 6 7  T+  777  T+  777+  7 6 77+  7 6 7>G   ÀobjitemSetFunc	funcconfig	item	info  infoListthis id  *newInfo  * ¦   ,v	4   +  7> D)  :)  :BNú+   '  : +   2  : G   ÀinfoList
maxIdid	infoitemList
pairs	this   _ item   O   +   ) :  4  +  ) > G   À_touchEnableisDrawthis     4   +  > 4  +  > 4  +  > 4  +  ) > G   À_touchEnable_updateAllItemPostion_createVisItem_updateInnerSizethis  K   +   7     7  '  ) > G   ÀscrollToTopobjthis       G   @  4  +    >G   À_touchEnablethis flag   v  +  7 77  T+  7 77  >G   ÀonScrollEvent	funcconfigthis event   g  
    T +  7 6 77>G   Àobj	iteminfoListthis id  callback   ý  _F1 :  1 : 1 : 1 : 1	 : 1 :
 1 : 1 : 1 : 1 : 0  G   effectWithObj onScrollEvent touchEnable scrollBottom scrollToTop 	draw stopDraw removeAllItem updateItem addNewItem  %%//225599??EEFFthis   ´   X¨4  77 7 77!>7 777 7 77	
  T7 77	7
  T7 77	7
7 77	7  T7 77	77  7>7  74 7 > =: 7 7 7 T7 7: 7 7 7>7 7 74 77	 7		!		7
  	
	> =7 7 7!7  : G  barHeight2barHeightsetSizegetSizebarinnerHeight
widthCCSizesetInnerContainerSizegetInnerContainerSizeobjbottomtopemptySizeheight	size	itemrowNumscrollconfig
maxId	ceil	math					this  Yline 	PinnerHeight KinnerSize ,barSize  ?   ¿4    % >G  onScroll_onScrollthis   Y  !Ð4  +  +    >G   ÀÀ_onTouchItemthis item event  data   Ô 5nÂ4  77 77 777!> 7 77 7   T0    ' I3 7		 
	 7	
	>	:	7	 9	7	 
	 7		7>	:7	
	 7		) >	7	
	 7		1 >	0 Kæ0  G  G   registerEventScriptsetTouchEnabled
indexaddChildobj  
clonedefauleItemitemListrowNumscroll	itemconfigheight	size	ceil	math						

this  5visLine )itemNum %oldNum #  i item      ÖG  this  flag   ¯   !ã+   7      T+  7  7  7     T+   ) : +  7  7  7  +  7 7 > G  À ÀreleaseitemLongPress	funcconfig	infoitem this  ô
 _Ù# 7 >7  > T4 777>4 >:3
 7:7::	) :+  7+  773 71	 >7	  T0  G   T77	777	74 7 >'   T4 7 >'  T7 7>T T7 7>7 T7  T7 77  T	7 7777>T T 0  G   ÀcancelUpitemClick	funcconfig	inforeleaseUpstopAllActionsabs	math	move obj 	time ÿ
delayEffectcreateEffectrelease  pressPosC_CLOCKpressTimeyx
index
printpushDownonScrollEventgetLocation







##tool this  `item  `event  `data  `pos \diffx )diffy  Ó  ?¬+      +    +      (   T(  + 7  7+   ) >G  À ÀscrollToPercentVerticalobjÐµæÌ³æýÈdiffTime diff height this percent time     É+   7   +  773 + 77> G     Àbgbar 	time³æÌ	³¦þfadeOutEffectcreateEffecttool this  ¥;Ðþ7   > T4 >: 7  7>7 7 77	 7
777 7 77	 7
77!:  T Te7 7 7 T0 d7  7>7 7 77	 7
774 >7 4 %  4 >(   TD7 7 77	 7
77!7   'À T7   T4 >7 (  T7  7 : T'  : 7 '   T '   T'  '  T' : 4 >: 7 : +  7+  773	 7
 1 >0 0  T Tÿ7  7>7 7 77	 7
77'   T'  7 '   T>7 7 7>7   7 7 77	 7
77!7 7  7!'ÿ >7 7 7">7 7 7#>+  7+  77$3% 7 7	 7&>:':(7 7>+  7+  773) 7 7 1	* >4+ 7,7	 7-77!>7	 7-77"7	 7
7. ' 7/  ' I	7
0 6

7/ 6

  T7-

  T7-
 T7/ 717-
97/ 7-
719717-
71:17-
:17-
Kâ' 7/  ' Ir	7
0 6

7/ 6

  T7-
  T/72
  T72)  :-:
2:-
72
7:7	 7374772
>7 75) >T72
  T727- T72)  :7272)  :72)  :-)  :27 75) >4+ 7,7	 7
7.!>7	 7
7."7 7647 7	 7-778  7	 7-797'7	 7
77:7  7	 7-77 7	 7-797(7	 7
77> =K0  G  G   À	leftpos
widthccpsetPositionsetVisibleitemSetFunc	func	info
indexinfoListitemListrowNum	item
floor	math  	time ÿyxgetPositionX 	time³æÌ	³¦ý	movesetPositionYstopAllActionssetOpacitybgbarbarHeight2onScrollFalseonScroll obj 	time 
delayEffectcreateEffectoldPercentpercentAddoldPercentTime
diffy	xxxx
printcancelUpreleaseUppushPercenttopemptySizescrollconfigheight	sizeinnerHeightgetPositionYinnerLayoutC_CLOCKscrollPushTimepushDownonScrollEventÿÀ#çÌ³³æÿ



  !!!"$$$%'''(+,,,---.......5.58::::<<<<??????????@@@ACCCCDDDDDEEEEEEEEEEEEEFFFFFFGGGGGHHHHHHHJJJJJJJJJJJJJJJJKKKKKKKKMKPPPPPPPPQQQQQSSSSTTTTTUVVVWWXXXXXXXXYYYYZZZZ[\\\]]^Taaaaabcccddeefffggghhhjklllmmmmmmnnnnnoqqqqqqqrrrsssstttuuwwwwwzzzzzzzzz{{{{{{||||||||||||||||||||||||||||||||||||||||atool this  event  y height 	y ZdiffTime Lheight :percent 9diff 4y >ûoldy 9y ,line 4£startId 	  i id info item index s s si qid pinfo mitem kl =.r ( ò   @ 4   % > 4 % 4 7>1 5 1 5	 1
 5 1 5 1 5 1 5 1 5 1 5 1 5 0  G  _onScroll _onTouchItem _touchEnable _createVisItem _updateAllItemPostion _updateInnerSize _initFunc 
_init create seeallpackagewidget.scrollListV2modulescene.toolrequire        (  ] * ¥ _ ¾ ¨ Á ¿ Ô Â Ø Ö ü Ù ~þ ~~tool   