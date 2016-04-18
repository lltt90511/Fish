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

@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate,UIApplicationDelegate> {
    UIWindow *window;
    RootViewController    *viewController;
    
    UIImageView *mVideoView;

}
@property (strong, nonatomic) UIView *overView;

+(void) chooseImage:(NSDictionary*) dict;
+(void) chat:(NSDictionary*) dict;
+(void) record:(NSDictionary*) dict;
+(void) playVideo:(NSDictionary*)dict;
+(void) previewFile:(NSDictionary*)dict;
+(void) setAutoLockScreen:(NSDictionary*)dict;
+(void) deleteDirectory:(NSDictionary*)dict;
+(void) appstoreBuy:(NSDictionary*)product;
+(void) pushRegister:(NSDictionary*)dict;
+(void) popWeb:(NSDictionary*)dict;
+ (int) getDeviceMemory:(NSDictionary*)dict ;
+ (int) getDeviceMemoryFree:(NSDictionary*)dict ;
+ (int) getCurrentNetWork:(NSDictionary*)dict;
- (void)onPushData:(int)data type:(int)tp;
- (void) startVideoPlay: (NSString *) urlString;
- (void) stopVideoPlay;
+ (void) registerPush;
+ (void) delPush:(NSDictionary*)dict;
+ (void) clearPush:(NSDictionary*)dict;
+ (void) unRegisterPush:(NSDictionary*)dict;
+ (void) gameInit:(NSDictionary*)dict;
+ (void) getDeviceId:(NSDictionary*)dict;
+ (void) platformLogin:(NSDictionary*) dict;
+ (void) platformPay:(NSDictionary*) dict;
+ (void) openUrlWithSafari:(NSDictionary *)dict;
@end

