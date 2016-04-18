//
//  webViewController.h
//  Ball
//
//  Created by Azraelee on 14-8-22.
//
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;

-(void)loadURL:(NSString*)url;
-(IBAction)back:(id)sender;
@end
