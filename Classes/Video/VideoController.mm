//
//  ViewController.m
//  autest
//
//  Created by yzh on 13-6-8.
//  Copyright (c) 2013年 yzh. All rights reserved.
//

#import "VideoController.h"
#import "EAGLView.h"
#import "AppController.h"

@interface VideoController ()

@end

@implementation VideoController

- (id)init{
    self = [super init];
//    CCLog("init video ++++++++++++");
    if (self) {
        // init code here.
        
    }
    return self;
}

+ (id)sharedVideoView {
    
    @synchronized(self) {
        
        if (mVideoView == nil)
        
        mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        
    }
    
    return mVideoView;
    
}
-(void) createControl{
    
    float fwidth = [UIScreen mainScreen].bounds.size.width;
    float fheight = [UIScreen mainScreen].bounds.size.height;
    
    if (mVideoView==nil) {
        //mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        
        if(fwidth>320){
            mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fwidth, 240*fwidth/320)];
            
        }
        else{
            mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fwidth, 240*fwidth/320)];
            
        }
        
    }

    
     //mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
}

-(void) stopVideoPlay {
    
//    [su lib_seeku_single_play_stop];
    
    AppController * delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    //    [delegate.overView insertSubview:mVideoView aboveSubview:[EAGLView sharedEGLView]];
    //    [delegate.overView insertSubview:mVideoView belowSubview:[EAGLView sharedEGLView]];
    [delegate hiddenVideo];
    [delegate stopVideoPlay];

    
    
}

-(void) startVideoPlay : (const char*) urlString{
//    CCLog("setLayerViedoView video ++++++++++++");
//    su=[[seeku alloc] init];
//    vdo=[[msiphone_video_recordhelp alloc] init];
//    
    NSString * nstring = [NSString  stringWithUTF8String:urlString];
//
//    CCLog("setLayerViedoView video ++++++++++++%s", urlString);
//    mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
//    NSDictionary *myDict =[NSDictionary dictionaryWithObjectsAndKeys:mVideoView,@"imgview",nstring,@"playAdress", nil];
//    [su lib_seeku_single_play_start:myDict];
    
//    [[EAGLView sharedEGLView] addSubview:mVideoView];
    
    
}
-(void) setHidden{
//    AppController * delegate = (AppController *)[[UIApplication sharedApplication] delegate];
//    //    [delegate.overView insertSubview:mVideoView aboveSubview:[EAGLView sharedEGLView]];
//    [delegate.overView insertSubview:mVideoView belowSubview:[EAGLView sharedEGLView]];
    AppController * delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    //    [delegate.overView insertSubview:mVideoView aboveSubview:[EAGLView sharedEGLView]];
    //    [delegate.overView insertSubview:mVideoView belowSubview:[EAGLView sharedEGLView]];
    [delegate hiddenVideo];

//    [[EAGLView sharedEGLView] sendSubviewToBack:mVideoView];
}

-(void) showVideo{
    mVideoView.hidden = NO;

//    [[EAGLView sharedEGLView] bringSubviewToFront:mVideoView];
}

-(void) setViedoView :  (const char*) urlString{
    NSLog(@"setLayerViedoView video ++++++++++++");
//    su=[[seeku alloc] init];
//    vdo=[[msiphone_video_recordhelp alloc] init];
    
    NSString * nstring = [NSString  stringWithUTF8String:urlString];
    
//    CCLog("setLayerViedoView video ++++++++++++%s", urlString);
    float fwidth = [UIScreen mainScreen].bounds.size.width;
    float fheight = [UIScreen mainScreen].bounds.size.height;
    
    if (mVideoView==nil) {
        //mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];

        if(fwidth/fheight>320/240){
            mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fwidth*240/320, fheight)];

        }
        else{
            mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fwidth, fheight*320/240)];

        }
        
    }
    NSDictionary *myDict =[NSDictionary dictionaryWithObjectsAndKeys:mVideoView,@"imgview",nstring,@"playAdress", nil];
//    [su lib_seeku_single_play_start:myDict];
    
//    mVideoView.image = [UIImage imageNamed:@"taoxin.png"];

    AppController * delegate = (AppController *)[[UIApplication sharedApplication] delegate];
//    [delegate.overView insertSubview:mVideoView aboveSubview:[EAGLView sharedEGLView]];
//    [delegate.overView insertSubview:mVideoView belowSubview:[EAGLView sharedEGLView]];
    [delegate startVideoPlay:nstring];
//    EAGLView* eaglView = [EAGLView sharedEGLView];
//    eaglView.backgroundColor = [UIColor clearColor];
//    [eaglView setOpaque:false];
    
//    UIView *view = [[UIView alloc]init];
//    view.backgroundColor = [UIColor clearColor];
    
//    [[EAGLView sharedEGLView] setAlpha:0];
//    [[EAGLView sharedEGLView] setHidden:true];
    
//    [delegate.overView addSubview:mVideoView];

//    [[EAGLView sharedEGLView] addSubview:mVideoView];
}
/*
-(void) setLayerViedoView : (VideoScene*) iLayerVideoView URLString:(const char*) urlString{
    CCLog("setLayerViedoView video ++++++++++++");
    su=[[seeku alloc] init];
    vdo=[[msiphone_video_recordhelp alloc] init];
    
    mVideoScene = iLayerVideoView;
    
    cocos2d::CCSize size = mVideoScene-> getContentSize();
    CCLog("+++++++%f========%f", size.width, size.height);
    
    NSString * nstring = [NSString  stringWithUTF8String:urlString];
//    mView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 640 , 360)];
//    
//    mView.backgroundColor = [UIColor greenColor];
 
    CCLog("setLayerViedoView video ++++++++++++%s", urlString);
//    mVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    //    mVideoView.image = [UIImage imageNamed:@"Icon-114.png"];
//    mVideoView.backgroundColor = [UIColor greenColor];
    NSDictionary *myDict =[NSDictionary dictionaryWithObjectsAndKeys:mVideoView,@"imgview",nstring,@"playAdress", nil];
    [su lib_seeku_single_play_start:myDict];
    
//    NSString *urlBase = [NSString stringWithCString:urlString encoding:NSUTF8StringEncoding];
    
//    [mView addSubview:mVideoView];
//    [self.view addSubview:mVideoView];
//    [mVideoView release];
    [[EAGLView sharedEGLView] addSubview:mVideoView];
    
//    [[EAGLView sharedEGLView] addSubview:mView];
    
}
*/
- (void)viewDidLoad
{
    	// Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidUnload
{
    //终止音频会话
//    [su lib_audioSession_uninitialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
