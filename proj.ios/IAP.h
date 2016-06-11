//
//  IAP.h
//  Ball
//
//  Created by Azraelee on 14-7-31.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAP : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

-(id)init;
-(void)initData:(NSString*)cId sId:(NSString*)serId eId:(NSString*)envirId;
-(void)requestProUpgradeProductData;
-(void)RequestProductData:(NSString *)proId;
-(void)buy:(NSString *)type buyTime:(NSString*)time buyOrderId:(NSString*)orderId;
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void)PurchasedTransaction:(SKPaymentTransaction *)transaction;
-(void)completeTransaction: (SKPaymentTransaction *)transaction;
-(void)failedTransaction: (SKPaymentTransaction *)transaction;
-(void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
-(void)restoreTransaction: (SKPaymentTransaction *)transaction;
-(void)provideContent:(NSString *)product;
-(void)recordTransaction:(NSString *)product;
@end
