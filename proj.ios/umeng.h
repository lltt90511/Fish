//
//  umeng.h
//  Ball
//
//  Created by Azraelee on 14/12/8.
//
//

#import <Foundation/Foundation.h>

@interface umeng : NSObject
+ (void) umengPay:(NSDictionary*)dict;
+ (void) umengBuy:(NSDictionary*)dict;
+ (void) umengVersion:(NSDictionary*)dict;
+ (void) umengStartLevel:(NSDictionary*)dict;
+ (void) umengFinishLevel:(NSDictionary*)dict;
+ (void) umengFailLevel:(NSDictionary*)dict;
+ (void) umengUse:(NSDictionary*)dict;
+ (void) umengBonusCoin:(NSDictionary*)dict;
+ (void) umengBonusItem:(NSDictionary*)dict;
+ (void) umengUserLevel:(NSDictionary*)dict;
+ (void) umengUserInfo:(NSDictionary*)dict;
+ (void) umengEvent:(NSDictionary*)dict;
+ (void) umengEventLB:(NSDictionary*)dict;
+ (void) umengEventBegin:(NSDictionary*)dict;
+ (void) umengEventEnd:(NSDictionary*)dict;
+ (void) umengEventDurations:(NSDictionary*)dict;
@end
