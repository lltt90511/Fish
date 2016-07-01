/****************************************************************************
 Copyright (c) 2010 cocos2d-x.org
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#import <UIKit/UIKit.h>
#import "AppController.h"
#import "cocos2d.h"
#import "EAGLView.h"
#import "AppDelegate.h"

#import "RootViewController.h"
#import <sys/xattr.h>
#import <MobClick.h>
#import <MobClickGameAnalytics.h>
#import "IAP.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "LogicController.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <webViewController.h>
//#import "UMMobClick/MobClick.h"
//#import "KxMovieDecoder.h"
//#import "KxAudioManager.h"

#import "OpenUDID.h"
#import "CCLuaObjcBridge.h"

////////////////////////////////////////////////////////////////////////////////

//static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0
#define _IPHONE80_ 80000

@interface AppController()
{
    //    KxMovieDecoder      *_decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _interrupted;
    
    UIActivityIndicatorView *_activityIndicatorView;
    
    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    NSString            *_PlayUrl;
}
@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (readwrite) BOOL opening;
@property (readwrite) BOOL running;
//@property (readwrite, strong) KxArtworkFrame *artworkFrame;
@property (nonatomic, strong) NSString *mCheckResultKey;    //验签密钥

@end



@implementation AppController
@synthesize overView;
#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;
static RootViewController *rootViewControllerPtr;
static UIImageView *videov;
IAP *_iap;

int messageId = -3;
int messageType = 1;
bool once = true;

#define ABSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //add by tangjiawen
    _dispatchQueue  = dispatch_queue_create("GFVideoQuene", DISPATCH_QUEUE_SERIAL);
    _videoFrames    = [[NSMutableArray alloc] init];
    _audioFrames    = [[NSMutableArray alloc] init];
    self.opening = FALSE;
    
    
    // Override point for customization after application launch.
    
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    EAGLView *__glView = [EAGLView viewWithFrame: [window bounds]
                                     pixelFormat: kEAGLColorFormatRGBA8
                                     depthFormat: GL_DEPTH24_STENCIL8_OES//GL_DEPTH_COMPONENT16
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];;
    
    [__glView setMultipleTouchEnabled:NO];
    // Use RootViewController manage EAGLView
    
    //add a view by tangjiawen
    
    __glView.opaque = NO;
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //add a view by tangjiawen in order to insert another view in MainBoardLayer
    overView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    overView.opaque = NO;
    overView.backgroundColor = [UIColor clearColor];
    [overView addSubview:__glView];
    
    mVideoView = [[UIImageView alloc] init];
    videov = mVideoView;
    float fwidth = [UIScreen mainScreen].bounds.size.width;
    //    float fheight = [UIScreen mainScreen].bounds.size.height;
    if(fwidth>320){
        mVideoView.frame = CGRectMake(0, 20, fwidth, 240*fwidth/320);
        
    }
    else{
        mVideoView.frame = CGRectMake(0, 20, fwidth, 240*fwidth/320);
    }
    mVideoView.contentMode = UIViewContentModeScaleAspectFit;
    mVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [overView insertSubview:mVideoView belowSubview:[EAGLView sharedEGLView]];
    //[overView insertSubview:mVideoView aboveSubview:[EAGLView sharedEGLView]];
    
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = overView;
    //    viewController.view = __glView;
    rootViewControllerPtr = viewController;
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    [viewController startReachNotifier];
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    cocos2d::CCApplication::sharedApplication()->run();
    
    _iap = [IAP alloc];
    
//    UMConfigInstance.appKey = @"5757aad2e0f55aeb70002d01";
//    UMConfigInstance.ChannelId = @"HDDBH";
    
    [MobClick setLogEnabled:YES];
    [MobClick startWithAppkey:@"5757aad2e0f55aeb70002d01" reportPolicy:(ReportPolicy)0 channelId:@"hddbh"];
    //    [MobClickGameAnalytice ]
    
    //设置支付宝回调地址
    [[IapppayKit sharedInstance] setAppAlipayScheme:@"iapppay.alipay.com.AiBei.IapppayExample"];
    
    self.mCheckResultKey = mOrderUtilsCheckResultKey;
    [[IapppayKit sharedInstance] setAppId:mOrderUtilsAppId mACID:mOrderUtilsChannel];
    [[IapppayKit sharedInstance] setIapppayPayWindowOrientationMask:UIInterfaceOrientationMaskPortrait];
    
    //推送反馈(app不在前台运行时，点击推送激活时)
    //[XGPush handleLaunching:launchOptions];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
//    [XGPush handleLaunching:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //此方法在某一时刻弃用，使用application:openURL:sourceApplication:annotation:代替
    [[IapppayKit sharedInstance] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //此方法为代替application:handleOpenURL:
    [[IapppayKit sharedInstance] handleOpenUrl:url];
    return YES;
}

+ (void) videoZorder:(NSDictionary*) dict {
    NSString *zorder = [dict objectForKey:@"zorder"];
    if ([zorder isEqualToString:@"1"]) {
        [[EAGLView sharedEGLView] bringSubviewToFront:videov];
    } else {
        [[EAGLView sharedEGLView] sendSubviewToBack:videov];
    }
}

+ (void) pushRegister:(NSDictionary*)dict {
    NSString *account = [dict objectForKey:@"account"];
    NSString *server = [dict objectForKey:@"server"];
    NSString *environment = [dict objectForKey:@"environment"];
    NSLog(@"account:%@,server:%@",account,server);
    [_iap initData:account sId:server eId:environment];
    //每次游戏只进行一次初始化
    if (once) {
        //push
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(sysVer < 8){
            [self registerPush];
        }
        else{
            [self registerPushForIOS8];
        }
#else
        [self registerPush];
#endif
        //iap
        [_iap init];
        once = false;
    }
}

+ (void) creatPush:(NSDictionary*)dict {
//    [self delPush:dict];
//    NSString *type = [dict objectForKey:@"type"];
//    NSString *time = [dict objectForKey:@"time"];
//    NSString *content = [dict objectForKey:@"content"];
//    
//    int t = [time intValue];
//    //本地推送示例
//    NSDate *fireDate = [[NSDate new] dateByAddingTimeInterval:t];
//    
//    NSMutableDictionary *dicUserInfo = [[NSMutableDictionary alloc] init];
//    [dicUserInfo setValue:@"push" forKey:type];
//    NSDictionary *userInfo = dicUserInfo;
//    
//    [XGPush localNotification:fireDate alertBody:content badge:1 alertAction:nil userInfo:userInfo];
}

+ (void) gameInit:(NSDictionary*)dict {
    [rootViewControllerPtr platformInit];
}

+ (void) getDeviceId:(NSDictionary*)dict {
    NSString* openUDID = [OpenUDID value];
    openUDID = [@"quick_reg_i_" stringByAppendingString:openUDID];
    NSLog(@"getDeviceId=%@",openUDID);
    
    int functionId = [[dict objectForKey:@"callback"] intValue];
    cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
    cocos2d::CCLuaValueDict item;
    item["udid"] = cocos2d::CCLuaValue::stringValue([openUDID UTF8String]);
    cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
    cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
    cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
}

+ (int) getDeviceMemory:(NSDictionary*)dict {
    
    size_t size = sizeof(int);
    int result;
    int mib[2] = {CTL_HW,HW_PHYSMEM};
    sysctl(mib, 2, &result, &size, NULL, 0);
    return result;
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *(vmStats.free_count+vmStats.wire_count+vmStats.active_count+vmStats.inactive_count)) / 1024.0) / 1024.0;
    //return 0;
}
+ (int) getDeviceMemoryFree:(NSDictionary*)dict {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *(vmStats.free_count)) / 1024.0) / 1024.0;
    //return 0;
}

+ (void) delPush:(NSDictionary*)dict {
//    NSString *type = [dict objectForKey:@"type"];
//    [XGPush delLocalNotification:type userInfoValue:@"push"];
}

+ (void) getURLSchemes:(NSDictionary *)dict {
    NSArray *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundle = [info objectForKey:@"CFBundleIdentifier"];
    for (NSMutableDictionary *object in versionStr) {
        NSString *name = [object objectForKey:@"CFBundleURLName"];
        if ([name isEqualToString:bundle]) {
            NSArray *str = [object objectForKey:@"CFBundleURLSchemes"];
            NSString *_str = [str componentsJoinedByString:@""];
            NSLog(@"str=%@",_str);
            int functionId = [[dict objectForKey:@"callback"] intValue];
            cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
            cocos2d::CCLuaValueDict item;
            item["appUrl"] = cocos2d::CCLuaValue::stringValue([_str UTF8String]);
            cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
            cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
            cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
            break;
        }
    }
}

+ (void) openUrlWithSafari:(NSDictionary *)dict{
    NSString *url2 = [dict objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url2]];
}

+ (void) clearPush:(NSDictionary*)dict {
    NSLog(@"clearPush");
//    [XGPush clearLocalNotifications];
}

+ (void) unRegisterPush:(NSDictionary*)dict {
    NSLog(@"unRegisterPush");
//    [XGPush unRegisterDevice];
}

+ (void) clearColor:(NSDictionary*)dict {
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

+ (void) setVideoSize:(NSDictionary*)dict {
    NSString *x = [dict objectForKey:@"x"];
    NSString *y = [dict objectForKey:@"y"];
    NSString *width = [dict objectForKey:@"width"];
    NSString *height = [dict objectForKey:@"height"];
    float xx = [x floatValue];
    float yy = [y floatValue];
    float w = [width floatValue];
    float h = [height floatValue];
    float fwidth = [UIScreen mainScreen].bounds.size.width;
    float fheight = [UIScreen mainScreen].bounds.size.height;
    float ipadFactor = 1;
    float factor = [UIScreen mainScreen].nativeScale;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ipadFactor = 1;
    else
        ipadFactor = factor;
    CCRect rect = CCEGLView::sharedOpenGLView()->getViewPortRect();
    xx = rect.origin.x;
    if (xx > 0)
        fwidth = rect.size.width/factor;
    videov.frame = CGRectMake(xx/factor, yy/ipadFactor, fwidth, w*fwidth/h);
}

- (void) videoError {
    [rootViewControllerPtr videoError];
}

- (void) videoSucc {
    [rootViewControllerPtr videoSucc];
}

- (void) videoFinish {
    [rootViewControllerPtr videoFinish];
}

+ (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

+ (void) registerPush {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

+ (void) platformLogin:(NSDictionary*) dict {
    
}

+ (void) platformPay:(NSDictionary*) dict {
    NSString *orderId = [dict objectForKey:@"orderId"];
    NSString *waresId = [dict objectForKey:@"waresId"];
    NSString *amount = [dict objectForKey:@"price"];
    NSLog(@"orderId=%@,waresId=%@,amount=%@",orderId, waresId, amount);
    
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"didReceiveLocationNotification");
    //notification是发送推送时传入的字典信息
    //[XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
//    [XGPush delLocalNotification:notification];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"didRegisterUserNOtificationSettings");
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
//    NSString* deviceTokenStr = [XGPush getDeviceToken:deviceToken];
//    Boolean getToken = false;
    
//    void (^successBlock)(void) = ^(void){
//        //成功之后的处理
//        NSLog(@"[xgpush]register successBlock ,deviceToken: %@",deviceTokenStr);
//        if (getToken == false) {
//            [rootViewControllerPtr pushToken:1 tk:deviceTokenStr];
//        }
//    };
//    
//    void (^errorBlock)(void) = ^(void){
//        //失败之后的处理
//        NSLog(@"[xgpush]register errorBlock");
//    };
//    
//    //注册设备
//    [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
//    NSLog(@"deviceTokenStr is %@",deviceTokenStr);
//    if (getToken == false) {
//        [rootViewControllerPtr pushToken:1 tk:deviceTokenStr];
//    }
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"%@",str);
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"didReceiveRemoteNotification");
    
    //推送反馈(app运行时)
//    [XGPush handleReceiveNotification:userInfo];
    NSLog(@"Notification%@",userInfo);
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //程序在后台的时候
    //保存
    NSString *msgId = [userInfo objectForKey:@"messageId"];
    NSString *msgType = [userInfo objectForKey:@"type"];
    messageId = [msgId intValue];
    if (msgType) {
        messageType = [msgType intValue];
    }
//    [self onPushData:messageId type:messageType];
    
    //    Notification{
    //        aps =     {
    //            alert = "\U6d4b\U8bd5";
    //            sound = default;
    //        };
    //        key ＝ value;
    //        xg =     {
    //            bid = 0;
    //            ts = 1407218463;
    //        };
    //    }
}

- (void)onPushData:(int)data type:(int)tp
{
    [rootViewControllerPtr pushData:data type:tp];
}

+(void) chooseImage:(NSDictionary *)dict{
    //[viewController openGallery];
    [rootViewControllerPtr addActionSheet1:dict];
}

+(void) chat:(NSDictionary *)dict{
    [rootViewControllerPtr addActionSheet2:dict];
}

+(void) record:(NSDictionary *)dict{
    int type = [[dict objectForKey:@"type"]intValue];
    switch (type) {
        case 1:
            [rootViewControllerPtr startRecord:dict];
            break;
        case 2:
            [rootViewControllerPtr stopRecord:dict];
            break;
        case 3:
            [rootViewControllerPtr cancelRecord:dict];
            break;
        case 4:
            [rootViewControllerPtr playRecord:dict];
            break;
        default:
            break;
    }
}

+(void) playVideo:(NSDictionary*)dict{
    [rootViewControllerPtr playVideo:dict];
}

+(void) previewFile:(NSDictionary*)dict{
    [rootViewControllerPtr previewDocument:dict];
}

+(void) deleteDirectory:(NSDictionary*)dict{
    NSString *path = [dict objectForKey:@"path"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

+(void) appstoreBuy:(NSDictionary*)dict{
    NSString *productId = [dict objectForKey:@"productId"];
    NSString *time = [dict objectForKey:@"time"];
    NSString *orderId = [dict objectForKey:@"orderId"];
    NSLog(@"appstoreBuy:%@,time:%@",productId,time);
    [_iap buy:productId buyTime:time buyOrderId:orderId];
}

+(void) iapppayBuy:(NSDictionary*)dict{
    NSString *orderId = [dict objectForKey:@"orderId"];
    NSString *price = [dict objectForKey:@"price"];
    NSString *productId = [dict objectForKey:@"productId"];
    NSString *userId = [dict objectForKey:@"userId"];
    IapppayOrderUtils *orderInfo = [[IapppayOrderUtils alloc] init];
    orderInfo.appId         = mOrderUtilsAppId;
    orderInfo.cpPrivateKey  = mOrderUtilsCpPrivateKey;
    orderInfo.cpOrderId     = orderId;
    orderInfo.waresId       = productId;
    orderInfo.price         = price;
    orderInfo.appUserId     = userId;
    
    NSString *trandInfo = [orderInfo getTrandData];
    [[IapppayKit sharedInstance] makePayForTrandInfo:trandInfo payDelegate:self];
}

+(void) popWeb:(NSDictionary*)dict{
    NSString *url = [dict objectForKey:@"url"];
    webViewController *webView = [[webViewController alloc] initWithNibName:@"webViewController" bundle:nil];
    [rootViewControllerPtr.view addSubview:webView.view];
    [webView loadURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::CCDirector::sharedDirector()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::CCDirector::sharedDirector()->resume();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::CCApplication::sharedApplication()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::CCApplication::sharedApplication()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

/**
 * 此处方法是支付结果处理
 **/
#pragma mark - IapppayKitPayRetDelegate
- (void)iapppayKitRetPayStatusCode:(IapppayKitPayRetCodeType)statusCode
                        resultInfo:(NSDictionary *)resultInfo
{
    NSLog(@"statusCode : %d, resultInfo : %@", (int)statusCode, resultInfo);
    
    if (statusCode == IAPPPAY_PAYRETCODE_SUCCESS)
    {
        BOOL isSuccess = [IapppayOrderUtils checkPayResult:resultInfo[@"Signature"]
                                                withAppKey:self.mCheckResultKey];
        if (isSuccess) {
            //支付成功，验签成功
//            [MBProgressHUD showTextHUDAddedTo:self.view Msg:@"支付成功，验签成功" animated:YES];
        } else {
            //支付成功，验签失败
//            [MBProgressHUD showTextHUDAddedTo:self.view Msg:@"支付成功，验签失败" animated:YES];
        }
    }
    else if (statusCode == IAPPPAY_PAYRETCODE_FAILED)
    {
        //支付失败
        NSString *message = @"支付失败";
        if (resultInfo != nil) {
            message = [NSString stringWithFormat:@"%@:code:%@\n（%@）",message,resultInfo[@"RetCode"],resultInfo[@"ErrorMsg"]];
        }
        
//        [MBProgressHUD showTextHUDAddedTo:self.view Msg:message animated:YES];
    }
    else
    {
        //支付取消
        NSString *message = @"支付取消";
        if (resultInfo != nil) {
            message = [NSString stringWithFormat:@"%@:code:%@\n（%@）",message,resultInfo[@"RetCode"],resultInfo[@"ErrorMsg"]];
        }
//        [MBProgressHUD showTextHUDAddedTo:self.view Msg:message animated:YES];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    //cocos2d::CCDirector::sharedDirector()->purgeCachedData();
    //add a rtmp video view by tangjiawen
    if (self.playing) {
        
        [self stop];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self restorePlay];
            
            NSLog(@"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            //            [_decoder closeFile];
            //            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        //        [_decoder closeFile];
        //        [_decoder openFile:nil error:nil];
    }
}



-(void)showLoadingIndicators
{
    if(!_activityIndicatorView){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = mVideoView.center;
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [mVideoView addSubview:_activityIndicatorView];
        
    }
    if(!_activityIndicatorView.isAnimating)
        [_activityIndicatorView startAnimating];
}

- (void)hideLoadingIndicators
{
    if(_activityIndicatorView){
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        [_activityIndicatorView release];
        _activityIndicatorView = nil;
    }
}

-(void) play
{
    if (self.playing)
        return;
    
    //    if (!_decoder.validVideo &&
    //        !_decoder.validAudio) {
    //
    //        return;
    //    }
    
    if (_interrupted)
        return;
    
    self.playing = YES;
    _interrupted = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
    [self asyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    //    if (_decoder.validAudio)
    //        [self enableAudio:YES];
    
    [self videoSucc];
    NSLog(@"play movie");
}

- (void) startVideoPlay: (NSString *) urlString{
    if(self.running)
        return;
    
    mVideoView.hidden = NO;
    self.opening = TRUE;
    self.running = TRUE;
    NSLog(@"url=%@",urlString);
    [mVideoView setImage:nil];
    _PlayUrl = urlString;
    //    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    //    [audioManager activateAudioSession];
    
    _moviePosition = 0;
    __weak AppController *weakSelf = self;
    //    KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
    //    decoder.interruptCallback = ^BOOL(){
    //
    //        __strong AppController *strongSelf = weakSelf;
    //        return strongSelf ? [strongSelf interruptDecoder] : YES;
    //    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSError *error = nil;
        NSLog(@"openFile starting...");
        //        [decoder openFile:urlString error:&error];
        if (error != nil) {
            //            mVideoView.image = [UIImage imageNamed:@"iTunesArtwork.png"];
            //            mVideoView.contentMode = UIViewContentModeCenter;
            [self videoError];
        }
        NSLog(@"openFile finished.");
        self.opening = FALSE;
        if(!self.running)
            return;
        
        __strong AppController *strongSelf = weakSelf;
        if (strongSelf) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                //                [strongSelf setMovieDecoder:decoder withError:error];
            });
        }
    });
    
    if ([_PlayUrl compare: @"rtmp://"] == NSOrderedSame){
        
        [self showLoadingIndicators];
    }
    //    if (_decoder) {
    //        [self setupPresentView];
    //    }
}

- (void)stop
{
    //    if (!self.playing)
    //        return;
    
    self.playing = NO;
    self.running = FALSE;
    [self enableAudio:NO];
    [self hideLoadingIndicators];
}

- (void) hiddenVideo{
    mVideoView.hidden = YES;
}
- (void) stopVideoPlay {
    mVideoView.hidden = YES;
    [self stop];
    _interrupted = TRUE;
    while(self.opening){
        NSLog(@"_decoder opening......");
        [NSThread sleepForTimeInterval:0.1f];
        self.playing = NO;
    }
    while (self.decoding) {
        NSLog(@"_decoder stoped......");
        [NSThread sleepForTimeInterval:0.1f];
    }
    [self freeBufferedFrames];
    _currentAudioFramePos = 0;
    _moviePosition = 0;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    //    if(_decoder){
    //        [_decoder release];
    //    }
    //    _decoder = nil;
    _interrupted = FALSE;
    
    NSLog(@"stop movie");
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - private
/*
 - (void) setMovieDecoder: (KxMovieDecoder *) decoder
 withError: (NSError *) error
 {
 if (!error && decoder) {
 _decoder        = decoder;
 if (_decoder.isNetwork) {
 
 _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
 _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
 
 } else {
 
 _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
 _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
 }
 
 if (!_decoder.validVideo)
 _minBufferedDuration *= 10.0; // increase for audio
 
 // allow to tweak some parameters at runtime
 //        if (_parameters.count) {
 //
 //            id val;
 //
 //            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
 //            if ([val isKindOfClass:[NSNumber class]])
 //                _minBufferedDuration = [val floatValue];
 //
 //            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
 //            if ([val isKindOfClass:[NSNumber class]])
 //                _maxBufferedDuration = [val floatValue];
 //
 //            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
 //            if ([val isKindOfClass:[NSNumber class]])
 //                _decoder.disableDeinterlacing = [val boolValue];
 //
 //            if (_maxBufferedDuration < _minBufferedDuration)
 //                _maxBufferedDuration = _minBufferedDuration * 2;
 //        }
 
 // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
 _decoder.disableDeinterlacing = YES;
 if (_maxBufferedDuration < _minBufferedDuration)
 _maxBufferedDuration = _minBufferedDuration * 2;
 
 
 NSLog(@"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
 
 //        if (self.isViewLoaded) {
 
 [self setupPresentView];
 
 if ([_PlayUrl compare: @"rtmp://"] == NSOrderedSame){
 if (_activityIndicatorView.isAnimating) {
 [self restorePlay];
 }
 }
 else{
 [self restorePlay];
 }
 //        }
 
 } else {
 NSLog(@"setMovieDecoder,error=%d, %@",error.code, error.localizedDescription);
 [self hideLoadingIndicators];
 if (!_interrupted)
 [self handleDecoderMovieError: error];
 }
 [self hideLoadingIndicators];
 }
 
 */

- (void) restorePlay
{
    //    NSNumber *n = [gHistory valueForKey:_decoder.path];
    //    if (n)
    //        [self updatePosition:n.floatValue playMode:YES];
    //    else
    [self play];
}
/*
 - (void) setupPresentView
 {
 if (!_decoder.validVideo) {
 NSLog(@"fallback to use RGB video frame and UIKit");
 [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
 }
 
 if (!_decoder.validVideo) {
 //缺省图片
 //        mVideoView.image = [UIImage imageNamed:@"iTunesArtwork.png"];
 //        mVideoView.contentMode = UIViewContentModeCenter;
 [self videoError];
 }
 }
 */
- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    //                    NSUInteger count = _audioFrames.count;
                    //                    //                    NSLog(@"_audioFrames = %d", count);
                    //                    if (count > 0) {
                    //
                    //                        KxAudioFrame *frame = [[_audioFrames[0] retain] autorelease];
                    //
                    //                        if (_decoder.validVideo) {
                    //
                    //                            const CGFloat delta = _moviePosition - frame.position;
                    //
                    //                            if (delta < -2.0) {
                    //
                    //                                memset(outData, 0, numFrames * numChannels * sizeof(float));
                    //                                break; // silence and exit
                    //                            }
                    //
                    //                            [_audioFrames removeObjectAtIndex:0];
                    //
                    //                            if (delta > 2.0 && count > 1) {
                    //                                continue;
                    //                            }
                    //
                    //                        } else {
                    //
                    //                            [_audioFrames removeObjectAtIndex:0];
                    //                            _moviePosition = frame.position;
                    //                            _bufferedDuration -= frame.duration;
                    //                        }
                    //
                    //                        _currentAudioFramePos = 0;
                    //                        if(frame){
                    //                            //                            _currentAudioFrame = frame.samples;
                    //                            _currentAudioFrame = [[NSData alloc] initWithData:frame.samples];
                    //                        }
                    //                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else{
                    [_currentAudioFrame autorelease];
                    _currentAudioFrame = nil;
                }
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    //    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    //
    //    if (on && _decoder.validAudio) {
    //
    //        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
    //
    //            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
    //        };
    //
    //        [audioManager play];
    //
    //        NSLog(@"audio device smr: %d fmt: %d chn: %d",
    //              (int)audioManager.samplingRate,
    //              (int)audioManager.numBytesPerSample,
    //              (int)audioManager.numOutputChannels);
    //
    //    } else {
    //        NSLog(@"audio pause.");
    //        [audioManager pause];
    //        audioManager.outputBlock = nil;
    //    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    //    if (_decoder.validVideo) {
    //
    //        @synchronized(_videoFrames) {
    //            for (KxMovieFrame *frame in frames)
    //                if (frame.type == KxMovieFrameTypeVideo) {
    //                    [_videoFrames addObject:frame];
    //                    _bufferedDuration += frame.duration;
    //                }
    //        }
    //    }
    //
    //    if (_decoder.validAudio) {
    //
    //        @synchronized(_audioFrames) {
    //
    //            for (KxMovieFrame *frame in frames)
    //                if (frame.type == KxMovieFrameTypeAudio) {
    //                    [_audioFrames addObject:frame];
    //                    if (!_decoder.validVideo)
    //                        _bufferedDuration += frame.duration;
    //                }
    //        }
    //
    //        if (!_decoder.validVideo) {
    //
    //            for (KxMovieFrame *frame in frames)
    //                if (frame.type == KxMovieFrameTypeArtwork)
    //                    self.artworkFrame = (KxArtworkFrame *)frame;
    //        }
    //    }
    //
    //    return self.playing && _bufferedDuration < _maxBufferedDuration;
    return false;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    //    NSMutableArray *frames = nil;
    //
    //    if (_decoder.validVideo ||
    //        _decoder.validAudio) {
    //
    //        frames = [NSMutableArray arrayWithArray:[_decoder decodeFrames:0]];
    //    }
    //
    //    if (frames.count) {
    //        return [self addFrames: frames];
    //    }
    return NO;
}

- (void) asyncDecodeFrames
{
    //    if (self.decoding)
    //        return;
    //
    //    __weak AppController *weakSelf = self;
    //    __weak KxMovieDecoder *weakDecoder = _decoder;
    //
    //    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    //
    //    self.decoding = YES;
    //    dispatch_async(_dispatchQueue, ^{
    //        {
    //            __strong AppController *strongSelf = weakSelf;
    //            if (!strongSelf.playing)
    //                return;
    //        }
    //
    //        BOOL good = YES;
    //        while (good) {
    //            good = NO;
    //
    //            @autoreleasepool {
    //                __strong KxMovieDecoder *decoder = weakDecoder;
    //
    //                if (decoder && (decoder.validVideo || decoder.validAudio)) {
    //
    //                    NSArray *frames = [decoder decodeFrames:duration];
    //                    if (frames.count) {
    //
    //                        __strong AppController *strongSelf = weakSelf;
    //                        if (strongSelf)
    //                            good = [strongSelf addFrames:frames];
    //                    }
    //                }
    //            }
    //        }
    //
    //        {
    //            __strong AppController *strongSelf = weakSelf;
    //            if (strongSelf) strongSelf.decoding = NO;
    //        }
    //    });
}

- (void) tick
{
    //    //NSLog(@"tick start.........");
    //    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
    //
    //        _tickCorrectionTime = 0;
    //        _buffered = NO;
    //        [self hideLoadingIndicators];
    //    }
    //
    //    CGFloat interval = 0;
    //    if (!_buffered)
    //        interval = [self presentFrame];
    //
    //    if (self.playing) {
    //
    //        const NSUInteger leftFrames =
    //        (_decoder.validVideo ? _videoFrames.count : 0) +
    //        (_decoder.validAudio ? _audioFrames.count : 0);
    //
    //        if (0 == leftFrames) {
    //
    //            if (_decoder.isEOF) {
    //
    //                [self stop];
    //                NSLog(@"_decoderStoped set true");
    //                //add by tangjiawen 主播断开切换默认页面
    ////                mVideoView.image = [UIImage imageNamed:@"iTunesArtwork.png"];
    //                [self videoFinish];
    //                return;
    //            }
    //
    //            if (_minBufferedDuration > 0 && !_buffered) {
    //
    //                _buffered = YES;
    //                if ([_PlayUrl compare:@"rtmp://"] == NSOrderedSame) {
    //                    [self showLoadingIndicators];
    //                }
    //            }
    //        }
    //
    //        if (!leftFrames ||
    //            !(_bufferedDuration > _minBufferedDuration)) {
    //
    //            [self asyncDecodeFrames];
    //        }
    //
    //        const NSTimeInterval correction = [self tickCorrection];
    //        const NSTimeInterval time = MAX(interval + correction, 0.01);
    //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
    //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //            [self tick];
    //        });
    //    }else{
    //        NSLog(@"_decoderStoped set true");
    //    }
    //    //    NSLog(@"tick end.");
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    if (correction > 1.f || correction < -1.f) {
        
        NSLog(@"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    //    if (_decoder.validVideo) {
    //        //        NSLog(@"presentFrame video");
    //
    //        KxVideoFrame *frame = nil;
    //        @synchronized(_videoFrames) {
    //
    //            if (_videoFrames.count > 0) {
    //                frame = [[_videoFrames objectAtIndex:0] retain];
    //                [_videoFrames removeObjectAtIndex:0];
    //                _bufferedDuration -= frame.duration;
    //            }
    //        }
    //
    //        if (frame){
    //            interval = [self presentVideoFrame:frame];
    //            [frame release];
    //        }
    //
    //    } else if (_decoder.validAudio) {
    //        //        NSLog(@"presentFrame audio");
    //
    //        //interval = _bufferedDuration * 0.5;
    //        if (self.artworkFrame) {
    //
    //            mVideoView.image = [self.artworkFrame asImage];
    //            self.artworkFrame = nil;
    //        }
    //    }
    
    return interval;
}

//- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
//{
//    if (frame.format==KxVideoFrameFormatYUV) {
//        KxVideoFrameYUV *yuvFrame = [(KxVideoFrameYUV *)frame retain];
//        [mVideoView setImage:[yuvFrame asImage]];
//        [yuvFrame release];
//
//    } else {
//
//        KxVideoFrameRGB *rgbFrame = [(KxVideoFrameRGB *)frame retain];
//        [mVideoView setImage:[rgbFrame asImage]];
//        [rgbFrame release];
//    }
//
//    _moviePosition = frame.position;
//
//    return frame.duration;
//}
//
//- (void) setMoviePositionFromDecoder
//{
//    _moviePosition = _decoder.position;
//}
//
//- (void) setDecoderPosition: (CGFloat) position
//{
//    _decoder.position = position;
//}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    //    position = MIN(_decoder.duration - 1, MAX(0, position));
    //
    //    __weak AppController *weakSelf = self;
    //
    //    dispatch_async(_dispatchQueue, ^{
    //
    //        if (playMode) {
    //
    //            {
    //                __strong AppController *strongSelf = weakSelf;
    //                if (!strongSelf) return;
    //                [strongSelf setDecoderPosition: position];
    //            }
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                __strong AppController *strongSelf = weakSelf;
    //                if (strongSelf) {
    //                    [strongSelf setMoviePositionFromDecoder];
    //                    [strongSelf play];
    //                }
    //            });
    //
    //        } else {
    //
    //            {
    //                __strong AppController *strongSelf = weakSelf;
    //                if (!strongSelf) return;
    //                [strongSelf setDecoderPosition: position];
    //                [strongSelf decodeFrames];
    //            }
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                __strong AppController *strongSelf = weakSelf;
    //                if (strongSelf) {
    //                    [strongSelf setMoviePositionFromDecoder];
    //                    [strongSelf presentFrame];
    //                }
    //            });
    //        }
    //    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    _bufferedDuration = 0;
}


- (void) handleDecoderMovieError: (NSError *) error
{
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
    //                                                        message:[error localizedDescription]
    //                                                       delegate:nil
    //                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
    //                                              otherButtonTitles:nil];
    if(error!=nil){
        //        mVideoView.image = [UIImage imageNamed:@"iTunesArtwork.png"];
        //        mVideoView.contentMode = UIViewContentModeCenter;
        [self videoError];
    }
    //    [alertView show];
}

- (BOOL) interruptDecoder
{
    return _interrupted;
}

- (void)dealloc {
    [self stop];
    
    if (_dispatchQueue) {
        dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
    
    NSLog(@"%@ dealloc", self);
    
    [window release];
    [super dealloc];
}

+ (void)setAutoLockScreen:(NSDictionary*)dict{
    Boolean flag = [[dict objectForKey:@"flag"]boolValue];
    [[UIApplication sharedApplication] setIdleTimerDisabled: flag];
}



@end

