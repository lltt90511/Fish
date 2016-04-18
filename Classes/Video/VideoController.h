//
//  ViewController.h
//  autest
//
//  Created by yzh on 13-6-8.
//  Copyright (c) 2013年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <pthread.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "seeku.h"
//#import "msiphone_video_recordhelp.h"

static UIImageView *mVideoView;

@interface VideoController : UIViewController
{
 
    
//    VideoScene * mVideoScene;
    UIView *mView;
    //msiphone_video_recordhelp *vdo;
    //seeku *su;
    
}
 

- (void) createControl;
//- (void) setLayerViedoView : (VideoScene*) iLayerWebView URLString:(const char*) urlString;
- (void) setViedoView : (const char*) urlString;
- (void) stopVideoPlay;
//- (void) startVideoPlay: (const char*) urlString;
- (void) setHidden;
- (void) showVideo;
@end
