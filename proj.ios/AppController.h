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

//#import<IapppayKit/IapppayKit.h>
//#import<IapppayKit/IapppayOrderUtils.h>

//商户在爱贝注册的应用ID
static NSString *mOrderUtilsAppId = @"30055354";

//渠道号
static NSString *mOrderUtilsChannel = @"HDDBH";

//商户验签公钥
static NSString *mOrderUtilsCheckResultKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCJkcACSvvBkSPxOKHgDl8oCyxPUKkkDYPZCwWxgz4iMmluppc5e8c1eddX24TrPmBORJWqVf2s3HKUMem/rMcVHCxZJ0C49UkfGQCjoLLXZI5aXww4itZl/rFWnkSKHisUes250WKFZjwmw2DlCjMtcLbkXx1oGEqJqmijhBP0rQIDAQAB";

//商户在爱贝注册的应用ID对应的应用私钥
static NSString *mOrderUtilsCpPrivateKey = @"MIICXAIBAAKBgQCD2/6puqO0W8Nlf1a9X8Xdsk8ANAAQ9o+uQRYo5yPXOVtGJVppC+hccuF6FRw55J3ec/hPXx5FD7eFBtxdiLK8kiGZp9PrJoRPq4OiAiPFCtmFtcJnW+ujTrUA517fT9Mqx3nDwkjvb98asOHXukQtgWN07yVGAXLPIIpxlDX5oQIDAQABAoGAVbj58IID10co2p1UWL0gt6YqMemceWqxsgliTKkn5c3GBu5VvqEdKK0O5P1AYmq8L1iZf5BI74DuQC9bp/sspvXLuBNvk5I6GLvgmYkeysKLhG7PyfHRXWhepBUAEjooa4FpGOiU0t8gvzXauTLtkjZuBITaP72O7I4fK5EtsoECQQDT+KAtfrtzlbnLuLzKrIe6ST++29TrOrUvQek526yrEhr+DteVd9bDK4xpez5yW663NIVL34j2cFif/3dhB4JpAkEAnz9+zO2kHBJLYWOKOZdA9bmIurrTRlXF8HZk/GE0xOuFInkBMeO8+PbQOZ4ZbuYlJG4m+7ar5VHuY+t59qfmeQJBAI1C5KRND+kwf9hHLfG3VuCLjiLIZ7W3syViPGZlgkWjVD+5bmxap9H7RKDLFEur09yd8LMmriTlq/o8ircsBPkCQBAWnRvdAlBntL/hC4zn8AMjPGIJD+EyNy4k9+zbcTZXyPqDmRBOPsA0RzMa+tzOWYBFtKCHgvRHA7uKhabarZkCQEOnUZFSIhTObH+CAExi0RKMg4C+Eor+6drk7X2wgUHO2M/tTZCBNSzCwFO9g4bFox+SKtpD/GfuVucpn/jTnnk=";

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
+(void) iapppayBuy:(NSDictionary*)product;
+(void) pushRegister:(NSDictionary*)dict;
+(void) popWeb:(NSDictionary*)dict;
+ (int) getDeviceMemory:(NSDictionary*)dict ;
+ (int) getDeviceMemoryFree:(NSDictionary*)dict ;
//+ (int) getCurrentNetWork:(NSDictionary*)dict;
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

