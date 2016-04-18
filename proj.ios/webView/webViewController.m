//
//  webViewController.m
//  Ball
//
//  Created by Azraelee on 14-8-22.
//
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadURL:(NSString*)url
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
}

-(IBAction)back:(id)sender
{
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view.superview.layer addAnimation:animation forKey:@"animation"];
    [self.view removeFromSuperview];
}

- (void)dealloc {
    [_btnBack release];
    [_webView release];
    [super dealloc];
}
@end
