//
//  umeng.m
//  Ball
//
//  Created by Azraelee on 14/12/8.
//
//

#import "umeng.h"
#import "MobClick.h"
#import "MobClickGameAnalytics.h"

@implementation umeng
+ (void) umengPay:(NSDictionary*)dict {
    NSString *cash = [dict objectForKey:@"cash"];
    NSString *source = [dict objectForKey:@"source"];
    NSString *coin = [dict objectForKey:@"coin"];
    NSLog(@"umengPay,cash=%@,source=%@,coin=%@",cash,source,coin);
    [MobClickGameAnalytics pay:[cash doubleValue] source:[source intValue] coin:[coin doubleValue]];
}

+ (void) umengBuy:(NSDictionary*)dict {
    NSString *item = [dict objectForKey:@"item"];
    NSString *amount = [dict objectForKey:@"amount"];
    NSString *price = [dict objectForKey:@"price"];
    NSLog(@"umengBuy,item=%@,source=%@,price=%@",item,amount,price);
    [MobClickGameAnalytics buy:item amount:[amount intValue] price:[price doubleValue]];
}

+ (void) umengVersion:(NSDictionary*)dict {
    NSString *version = [dict objectForKey:@"version"];
    [MobClick setAppVersion:version];
}

+ (void) umengStartLevel:(NSDictionary*)dict {
    NSString *level = [dict objectForKey:@"level"];
    NSLog(@"umengStartLevel,level=%@",level);
    [MobClickGameAnalytics startLevel:level];
}

+ (void) umengFinishLevel:(NSDictionary*)dict {
    NSString *level = [dict objectForKey:@"level"];
    NSLog(@"umengFinishLevel,level=%@",level);
    if (![level isEqualToString:@""]) {
        [MobClickGameAnalytics finishLevel:level];
    } else {
        [MobClickGameAnalytics finishLevel:nil];
    }
}

+ (void) umengFailLevel:(NSDictionary*)dict {
    NSString *level = [dict objectForKey:@"level"];
    NSLog(@"umengFailLevel,level=%@",level);
    if (![level isEqualToString:@""]) {
        [MobClickGameAnalytics failLevel:level];
    } else {
        [MobClickGameAnalytics failLevel:nil];
    }
}

+ (void) umengUse:(NSDictionary*)dict {
    NSString *item = [dict objectForKey:@"item"];
    NSString *amount = [dict objectForKey:@"amount"];
    NSString *price = [dict objectForKey:@"price"];
    NSLog(@"umengUse,item=%@,amount=%@,price=%@",item,amount,price);
    [MobClickGameAnalytics use:item amount:[amount intValue] price:[price doubleValue]];
}

+ (void) umengBonusCoin:(NSDictionary*)dict {
    NSString *coin = [dict objectForKey:@"coin"];
    NSString *source = [dict objectForKey:@"source"];
    NSLog(@"umengBonusCoin,coin=%@,source=%@",coin,source);
    [MobClickGameAnalytics bonus:[coin doubleValue] source:[source intValue]];
}

+ (void) umengBonusItem:(NSDictionary*)dict {
    NSString *item = [dict objectForKey:@"item"];
    NSString *amount = [dict objectForKey:@"amount"];
    NSString *price = [dict objectForKey:@"price"];
    NSString *source = [dict objectForKey:@"source"];
    NSLog(@"umengBonusItem,item=%@,amount=%@,price=%@,source=%@",item,amount,price,source);
    [MobClickGameAnalytics bonus:item amount:[amount intValue] price:[price doubleValue] source:[source intValue]];
}

+ (void) umengUserLevel:(NSDictionary*)dict {
    NSString *level = [dict objectForKey:@"level"];
    NSLog(@"umengUserLevel,level=%@",level);
    [MobClickGameAnalytics setUserLevel:level];
}

+ (void) umengUserInfo:(NSDictionary*)dict {
    NSString *userId = [dict objectForKey:@"userId"];
    NSString *sex = [dict objectForKey:@"sex"];
    NSString *age = [dict objectForKey:@"age"];
    NSString *platform = [dict objectForKey:@"platform"];
    NSLog(@"umengUserInfo,userId=%@,sex=%@,age=%@,platform=%@",userId,sex,age,platform);
    [MobClickGameAnalytics setUserID:userId sex:[sex intValue] age:[age intValue] platform:platform];
}

+ (void) umengEvent:(NSDictionary*)dict {
    NSString *eventId = [dict objectForKey:@"eventId"];
    NSLog(@"umengEvent,eventId=%@",eventId);
    [MobClick event:eventId];
}

+ (void) umengEventLB:(NSDictionary*)dict {
    NSString *eventId = [dict objectForKey:@"eventId"];
    NSString *eventLabel = [dict objectForKey:@"eventLabel"];
    NSLog(@"umengEventLB,eventId=%@,eventLabel=%@",eventId,eventLabel);
    [MobClick event:eventId label:eventLabel];
}

+ (void) umengEventBegin:(NSDictionary*)dict {
    NSString *eventId = [dict objectForKey:@"eventId"];
    NSLog(@"umengEventBegin,eventId=%@",eventId);
    [MobClick beginEvent:eventId];
}

+ (void) umengEventEnd:(NSDictionary*)dict {
    NSString *eventId = [dict objectForKey:@"eventId"];
    NSLog(@"umengEventEnd,eventId=%@",eventId);
    [MobClick endEvent:eventId];
}

+ (void) umengEventDurations:(NSDictionary*)dict {
    NSString *eventId = [dict objectForKey:@"eventId"];
    NSString *millisecond = [dict objectForKey:@"millisecond"];
    NSLog(@"umengEventDurations,eventId=%@,millisecond=%@",eventId,millisecond);
    [MobClick event:eventId durations:[millisecond intValue]];
}
@end
