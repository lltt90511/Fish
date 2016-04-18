/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada
 
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UzysImageCropperViewController.h"
#import "RecordAudio.h"

@interface RootViewController : UIViewController <UIWebViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UzysImageCropperDelegate,AVAudioPlayerDelegate,RecordAudioDelegate,UIDocumentInteractionControllerDelegate>{
                                                        
    UIImagePickerController *picker_library_;
    NSString *fileName;
    NSDictionary *dict;
    int actionSheetIndex;
    NSError *error;
    
    //NSURL *recordedTmpFile;
    RecordAudio *recorder;
    //NSData *curAudio;
    
    NSURL *_videoURL;
    NSString *_mp4Path;
    BOOL isConverting;
    BOOL isAudioPlaying;
    UIDocumentInteractionController *documentInteractionController;
}

-(void) startReachNotifier;
-(void) platformInit;

-(void) addActionSheet1:(NSDictionary*)_dict;
-(void) addActionSheet2:(NSDictionary*)_dict;

-(void) startRecord:(NSDictionary *)_dict;
-(void) stopRecord:(NSDictionary *)_dict;
-(void) cancelRecord:(NSDictionary *)_dict;
-(void) playRecord:(NSDictionary *)_dict;

-(void) playVideo:(NSDictionary*)_dict;
-(void) previewDocument:(NSDictionary*)_dict;
-(void) pushToken:(int)type tk:(NSString*)token;
-(void) pushData:(int)data type:(int)tp;
-(void) videoError;
-(void) videoSucc;
-(void) videoFinish;
@property (nonatomic, retain) IBOutlet UIImagePickerController *picker_library_;
@property (nonatomic,retain) UzysImageCropperViewController *imgCropperViewController;
//@property (nonatomic, retain) IBOutlet NSString *fileName;
@end
