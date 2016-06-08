//
//  IAP.m
//  Ball
//
//  Created by Azraelee on 14-7-31.
//
//

#import "IAP.h"
#import <StoreKit/StoreKit.h>
#import <GTMBase64.h>
#import "ProgressHUD.h"

@implementation IAP
NSString *productId = @"";
NSString *charId = @"";
NSString *buyTime = @"";
NSString *serverId = @"";
NSString *environment = @"";

-(id)init {
    if ((self = [super init])) {
        // 监听购买结果
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    NSString *data = [self getUrl];
    NSLog(@"init data:%@",data);
    if (data != NULL && ![data isEqual: @""]) {
        NSLog(@"exist iap");
        //存在未成功的订单
        [self httpConnectionWithRequest:data];
    }
    return self;
}
-(void)initData:(NSString*)cId sId:(NSString*)serId eId:(NSString*)envirId {
    charId = [[NSString alloc] initWithFormat:@"%@",cId];
    serverId = [[NSString alloc] initWithFormat:@"%@",serId];
    environment = [[NSString alloc] initWithFormat:@"%@",envirId];
}

-(void)buy:(NSString*)type buyTime:(NSString*)time
{
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"can MakePayments");
        productId = type;
        buyTime = [[NSString alloc] initWithFormat:@"%@",time];;
        [self RequestProductData:type];
        [ProgressHUD show:@"提交订单中..."];
    }
    else{
        NSLog(@"can't MakePayments");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你不能在appstore购买" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

-(void)RequestProductData:(NSString *)proId
{
    NSLog(@"RequestProductData:%@",proId);
    NSArray *product = nil;
    product = [[NSArray alloc] initWithObjects:proId, nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    [product release];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productRequest");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品数量:%d",[myProduct count]);
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    SKPayment *payment = nil;
    payment = [SKPayment paymentWithProductIdentifier:productId];
    NSLog(@"发起购买请求:%@",productId);
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [request autorelease];
}

-(void)requestProUpgradeProductData
{
    NSLog(@"请求升级");
    NSSet *productIdentifiers = [NSSet setWithObject:productId];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"错误信息");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",NULL) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
    [alerView show];
    [alerView release];
    [ProgressHUD dismiss];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"反馈信息结束");
    [ProgressHUD dismiss];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"交易结果");
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                //服务端进行验证
                [self completeTransaction:transaction];
                NSLog(@"交易完成");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"购买成功" delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                [alerView show];
                [alerView release];
//                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                NSLog(@"交易失败");
                UIAlertView *alerView0 =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"购买失败，请重新购买" delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                [alerView0 show];
                [alerView0 release];
            case SKPaymentTransactionStateRestored:
//                [self restoreTransaction:transaction];
                NSLog(@"SKPaymentTransactionStateRestored");
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"购买中");
            default:
                break;
        }
    }
}

-(void)PurchasedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Purchased Transaction");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}

SKPaymentTransaction *completeTrans;
-(void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction");
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    completeTrans = transaction;
    
    NSData *recipt64Data = [GTMBase64 encodeData:transaction.transactionReceipt];
    NSString *receiptStr = [[NSString alloc] initWithData:recipt64Data encoding:NSUTF8StringEncoding];
//    NSLog(@"complete:%@",receiptStr);
    NSString *URLPath = [NSString stringWithFormat:@"receipt=%s&time=%@&charId=%@", [receiptStr UTF8String], buyTime, charId];
    NSLog(@"url=%@",URLPath);
    
    //保存充值数据
    [self saveUrl:URLPath];
    [ProgressHUD show:@"验证订单中..."];
    [self httpConnectionWithRequest:URLPath];
}

-(void)saveUrl:(NSString*)url
{
//    NSLog(@"saveUrl:%@",url);
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:url forKey:@"iap"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
}

-(NSString*)getUrl
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *iap = [defaults objectForKey:@"iap"];//根据键值取出iap
//    NSLog(@"getUrl:%@",iap);
    return iap;
}

NSMutableData *responseData;
- (void)httpConnectionWithRequest:(NSString*)url{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",serverId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"POST"]; 
    //body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"%@",url] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody]; 
    // NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    responseData = [[NSMutableData alloc] initWithData:nil];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    NSLog(@"response length=%lld  statecode%d", [response expectedContentLength],responseCode);
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    if (responseData == nil) {
        responseData = [[NSMutableData alloc] initWithData:data];
    } else {
        [responseData appendData:data];
    }
    NSLog(@"response connection");
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    NSLog(@"response error%@", [error localizedFailureReason]);
    [ProgressHUD dismiss];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [ProgressHUD dismiss];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"response body%@", responseString);
    NSError *error;
    if (responseData != NULL && responseString != NULL && ![responseString isEqual:@""]) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        int errorCode = [[data valueForKey:@"errCode"] intValue];
        NSLog(@"errorCode:%d",errorCode);
        
        //清除队列
        if (completeTrans != NULL) {
            if (errorCode == 0 || errorCode == 1) {
                @try {
                    NSLog(@"completeTrans");
                    [[SKPaymentQueue defaultQueue] finishTransaction: completeTrans];
                    //清除数据
                    [self saveUrl:@""];
                    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证成功，交易完成！" delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                    [alerView show];
                    [alerView release];
                    return;
                }
                @catch (NSException *exception) {
                    NSLog(@"catch");
                }
                @finally {
                    
                }
            }
        }
        UIAlertView *alerView0 =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证失败！" delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        [alerView0 show];
        [alerView0 release];
    }
}

-(void)recordTransaction:(NSString *)product
{
    NSLog(@"记录交易");
}

-(void)provideContent:(NSString *)product
{
    
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    
}

-(void) restoreTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易恢复");
//    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
//    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self completeTransaction:transaction];
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"paymentQueue");
}

@end
