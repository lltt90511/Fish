LJ @./handler/init.luaa   4   % % > +   7  > G  ÀgoBackScenecallbackonBack-
printbackList    
%+  :  +  :4 %    >G   ÀdeviceId,sdkplatform:
printsdkplatformdeviceIduserdata devId  params   {   4  %    >4 %    >G  registerPushToken	callonPushToken-
printtype  token     
&4  %    >+  : +  :G   ÀmessageTypemessageIdonPushData-
printuserdata msgId  msgType   ¹  %> 
4  %   >4   % >+  78:+  78:+  78:+  78:+  78:	+  78:
+  78:G   ÀipmacappModelappOperateappTypeverSdkpkgNameappInfo|splitWithTrimonAppInfo-
print				
userdata params  &str 	 Ú  ,Z,4  %     >+  2  :+  7: +  7:+  7:4 4 >% 4	 >
 T4 87%  $ T+ 7 4 >T4  % >G   ÀÀurl nilonResultrequestB/ydream/login?type=8&syskey=ymnshx&loginKey=&appSrc=xmw&code=payUrlxmwgetPlatformserverListprintTableuSession
uNameuIdsdkPlatformInfouId,uName,uSession:
print						userdata http uId  -uName  -uSession  -url  Û 6Y>4  %  >4 7 >7  TG  7  T+  77:7  T+  77:	7
  T+  77
:+  7 T4 4 7 > = + 7>4 % '  +  77>G   ÀÀ
login	callconnectencodesetSdkUserInfoxmwsdkplatformuTokenaccess_token
uNameuserNameuIdsdkPlatformInfouserIderrCodedecode
cjsononResult
print 


userdata nc header  7body  7tab 	.  !=U
4  %   >4   >	  T+  7>4 % % >4 7%	 %
 3 >+  ) :4 77777>G  ÀserverSceneSceneTypechangescene.sceneManagerloadedpackagereConnectFlag 	dictclearPushAppControllercallStaticMethod
luaocloginTokensaveSettingdisConnecttonumberonSwitchResult
print
nc result  "sceneManager   !=a
4  %   >4   >	  T+  7>4 % % >4 7%	 %
 3 >+  ) :4 77777>G  ÀserverSceneSceneTypechangescene.sceneManagerloadedpackagereConnectFlag 	dictclearPushAppControllercallStaticMethod
luaocloginTokensaveSettingdisConnecttonumberonLogoutResult
print
nc result  "sceneManager  ?   m4  %   >G  onPayResult
printresult      }+   7   
   T +   7     T +   7     T %  H  +   7   H   Àsgj	nshxsdkplatformuserdata      
4     T 4  7  % % 3 > G   	dictplatformLogin"com/java/platform/NdkPlatformcallStaticMethod	luajAndroidplatform     
4     T 4  7  % % 3 > G   	dictaccountSwitch"com/java/platform/NdkPlatformcallStaticMethod	luajAndroidplatform     
4     T 4  7  % % 3 > G   	dictlogout"com/java/platform/NdkPlatformcallStaticMethod	luajAndroidplatform Ë   4   T   T4 7% % 2  >T4 7% % 2  >G  LockScreenUnlockedScreencc/yongdream/nshx/UtilcallStaticMethod	luajAndroidplatform_flag      ¢4   T4 7% % 2 ; >G  setUserInfo"com/java/platform/NdkPlatformcallStaticMethod	luajAndroidplatform_json   ì  2 n µ4   % > 4  % >4  % >4  % >4  % >5 1 5 1 5	 1
 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1 5 1  5! 1" 5# 1$ 5% 4& % 4 >4& %	 4	 >4& % 4 >4& % 4 >4& % 4 >4& % 4 >4& % 4 >4& % 4 >4& % 4 >4' 7(%) %* 3+ >4' 7(%) %, 3- >4. 7(%/ %	 30 >4. 7(%/ %, 31 >0  G      "com/java/platform/NdkPlatform	luaj 	dictgetAppInfo 	dictgameInitAppControllercallStaticMethod
luaocregListnersetSdkUserInfo setScreenState sdkLogout sdkAccountSwitch sdkLogin getPlatform onPayResult onLogoutResult onSwitchResult onResult onLoginResult onAppInfo onPushData onPushToken platformInit onBack 
cjsonlogic.nclogic.httpscene.backListlogic.userdatarequire
* <,S>_Uka{m} ¦¢¨¨¨¨©©©©ªªªª««««¬¬¬¬­­­­®®®®¯¯¯¯°°°°²²²²²²³³³³³³´´´´´´µµµµµµµµuserdata kbackList hhttp enc b  