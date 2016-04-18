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

#import "RootViewController.h"
#import "CCLuaObjcBridge.h"
#import "LogicController.h"
#import "Reachability.h"
#import "OpenUDID.h"

@implementation RootViewController
@synthesize picker_library_;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        recorder = [[RecordAudio alloc]init];
        recorder.delegate = self;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskAllButUpsideDown;
#endif
}

- (BOOL) shouldAutorotate {
    return YES;
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(void) startReachNotifier {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [reach startNotifier];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        //notificationLabel.text = @"Notification Says Reachable";
        if (reach.isReachableViaWiFi) {
            NSLog(@"wifi");
            LogicController::getInstance()->onChangedNetwork(2);
        }else if (reach.isReachableViaWWAN) {
            NSLog(@"2G or 3G");
            LogicController::getInstance()->onChangedNetwork(1);
        }
    }
    else
    {
        NSLog(@"can not reach");
        LogicController::getInstance()->onChangedNetwork(0);
        //notificationLabel.text = @"Notification Says Unreachable";
    }
}
-(void)previewDocument:(NSDictionary*)_dict {
    NSURL *url = [NSURL fileURLWithPath:[_dict objectForKey:@"path"]];
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [documentInteractionController setDelegate:self];
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview:
(UIDocumentInteractionController *) controller {
    return self;
}
//打开相册
-(void)addActionSheet1:(NSDictionary*)_dict{
    dict = _dict;
    [dict retain];
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"关闭" otherButtonTitles:@"相册",@"摄像头", nil];
//    [actionSheet showInView:self.view];
//    [actionSheet reloadInputViews];
//    actionSheetIndex = 1;
    switch ([[dict objectForKey:@"type"] intValue])
    {
        case 1:
        {
#if TARGET_IPHONE_SIMULATOR
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"demo" message:@"camera not available"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
#elif TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            //初始化类
            picker_library_ = [[UIImagePickerController alloc] init];
            //指定几总图片来源
            //UIImagePickerControllerSourceTypePhotoLibrary：表示显示所有的照片。
            //UIImagePickerControllerSourceTypeCamera：表示从摄像头选取照片。
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum：表示仅仅从相册中选取照片。
            picker_library_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //表示用户可编辑图片。
            picker_library_.allowsEditing = NO;
            //代理
            picker_library_.delegate = self;
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
#endif
        }
            break;  
        case 2:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            //初始化类
            picker_library_ = [[UIImagePickerController alloc] init];
            //指定几总图片来源
            //UIImagePickerControllerSourceTypePhotoLibrary：表示显示所有的照片。
            //UIImagePickerControllerSourceTypeCamera：表示从摄像头选取照片。
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum：表示仅仅从相册中选取照片。
            picker_library_.sourceType = UIImagePickerControllerSourceTypeCamera;
            //表示用户可编辑图片。
            picker_library_.allowsEditing = NO;
            //代理
            picker_library_.delegate = self;
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
        }
            break;
    }
}

-(void)addActionSheet2:(NSDictionary*)_dict{
    dict = _dict;
    [dict retain];
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"发送" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"关闭" otherButtonTitles:@"相册",@"摄像头",@"录音",@"视频", nil];
//    [actionSheet showInView:self.view];
//    [actionSheet reloadInputViews];
//    actionSheetIndex = 2;
    switch ([[dict objectForKey:@"type"] intValue]) {
        case 1:
        {
#if TARGET_IPHONE_SIMULATOR
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"demo" message:@"camera not available"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
#elif TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            //初始化类
            picker_library_ = [[UIImagePickerController alloc] init];
            //指定几总图片来源
            //UIImagePickerControllerSourceTypePhotoLibrary：表示显示所有的照片。
            //UIImagePickerControllerSourceTypeCamera：表示从摄像头选取照片。
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum：表示仅仅从相册中选取照片。
            picker_library_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //表示用户可编辑图片。
            picker_library_.allowsEditing = NO;
            //代理
            picker_library_.delegate = self;
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
#endif
        }
        break;
        case 2:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            //初始化类
            picker_library_ = [[UIImagePickerController alloc] init];
            //指定几总图片来源
            //UIImagePickerControllerSourceTypePhotoLibrary：表示显示所有的照片。
            //UIImagePickerControllerSourceTypeCamera：表示从摄像头选取照片。
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum：表示仅仅从相册中选取照片。
            picker_library_.sourceType = UIImagePickerControllerSourceTypeCamera;
            //表示用户可编辑图片。
            picker_library_.allowsEditing = NO;
            //代理
            picker_library_.delegate = self;
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
        }
        break;
        case 3:
        {
            if (isConverting == YES) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"有视频正在转码中，请稍后！"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            picker_library_ = [[UIImagePickerController alloc]init];
            picker_library_.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker_library_.allowsEditing = YES;
            picker_library_.delegate = self;
            picker_library_.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker_library_.videoMaximumDuration = 30.0f;
            picker_library_.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
        }
        break;
        case 4:
        {
            if (isConverting == YES) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"有视频正在转码中，请稍后！"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            picker_library_ = [[UIImagePickerController alloc]init];
            picker_library_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker_library_.allowsEditing = YES;
            picker_library_.delegate = self;
            picker_library_.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker_library_.videoMaximumDuration = 30.0f;
            picker_library_.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController: picker_library_
                               animated: YES completion:nil];
            [picker_library_ release];
        }
        break;
    }
}

static double startRecordTime=0;
static double endRecordTime=0;

-(void) startRecord:(NSDictionary *)_dict{
    [recorder stopPlay];
    [recorder startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//    [audioSession setActive:YES error:&error];
//
//    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithFloat:44100],AVSampleRateKey,
//                              [NSNumber numberWithInt:4800],AVEncoderBitRateKey,
//                              [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
//                              [NSNumber numberWithInt:kAudioFormatAppleLossless],AVFormatIDKey,
//                              [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
//                              [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
//                              nil];
//    
//    recordedTmpFile = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
//    NSLog(@"Using File called: %@",recordedTmpFile);
//    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:settings error:&error];
//    NSLog(@"%@", [error description]);
//    [recorder setMeteringEnabled:YES];
//    [recorder setDelegate:self];
//    [recorder recordForDuration:(NSTimeInterval) 30];
//    if ([recorder prepareToRecord]) {
//        [recorder record];
//    }
    
}

-(void) stopRecord:(NSDictionary *)_dict{
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    NSURL *url = [recorder stopRecord];
    NSFileManager *fm = [NSFileManager defaultManager];
    endRecordTime -= startRecordTime;
    if (endRecordTime<2.00f) {
        LogicController::getInstance()->onStopAudioRecorder(0, "", 0);
        [fm removeItemAtURL:url error:&error];
        return;
    } else if (endRecordTime>30.00f){
        endRecordTime = 30.00f;
    }
    
    NSURL *armUrl = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"audio.amr"]]];
    [recorder EncodeWAVEToAMR:[NSData dataWithContentsOfURL:url]];
    [fm removeItemAtURL:url error:&error];
    LogicController::getInstance()->onStopAudioRecorder(1, [[armUrl path] UTF8String], (int)endRecordTime);
    
//    [recorder stop];
//    [recorder release];
//    recorder = nil;
//    
//    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:recordedTmpFile options:nil];
//    CMTime audioDuration = audioAsset.duration;
//    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
//    cocos2d::CCLuaValueDict item;
//    if (audioDurationSeconds < 2.0) {
//        NSLog(@"duration small than 2 seconds");
//        NSFileManager *fm = [NSFileManager defaultManager];
//        [fm removeItemAtURL:recordedTmpFile error:&error];
//        NSLog(@"%@",[error description]);
//        item["isSuccess"] = cocos2d::CCLuaValue::booleanValue(false);
//    }else {
//        item["isSuccess"] = cocos2d::CCLuaValue::booleanValue(true);
//        item["fullPath"] = cocos2d::CCLuaValue::stringValue([[recordedTmpFile path] UTF8String]);
//        item["folder"] = cocos2d::CCLuaValue::stringValue([[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] UTF8String]);
//        item["seconds"] = cocos2d::CCLuaValue::floatValue(audioDurationSeconds);
//    }
//    int functionId = [[dict objectForKey:@"callback"] intValue];
//    cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
//    cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
//    cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
//    cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
}

-(void) cancelRecord:(NSDictionary *)_dict{
    NSURL *url = [recorder stopRecord];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtURL:url error:&error];
//    [recorder stop];
//    [recorder release];
//    recorder = nil;
//    NSFileManager *fm = [NSFileManager defaultManager];
//    [fm removeItemAtURL:recordedTmpFile error:nil];
    //[recordedTmpFile release];
}

-(void) playRecord:(NSDictionary *)_dict{
    NSURL *armUrl = [NSURL fileURLWithPath:[_dict objectForKey:@"path"]];
    [recorder play:[NSData dataWithContentsOfURL:armUrl]];
//    if (isAudioPlaying == YES) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"同一时间只能播放一段音频，请稍后！"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
//        return;
//    }
//    NSURL *path = [NSURL fileURLWithPath:[_dict objectForKey:@"path"]];
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    AVAudioPlayer *avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:path error:&error];
//    NSLog(@"%@", [error description]);
//    isAudioPlaying = YES;
//    [avPlayer setDelegate:self];
//    [avPlayer prepareToPlay];
//    [avPlayer play];
}

-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        NSLog(@"播放完成");
        LogicController::getInstance()->onPlayNextRecord();
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
}

//-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    isAudioPlaying = NO;
//    //play next
//    LogicController::getInstance()->onPlayNextRecord();
//}
//
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
//{
//    //解码错误执行的动作
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"解码错误，不支持的音频格式！"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//    isAudioPlaying = NO;
//}
//
//
//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
//{
//    //处理中断的代码
//    [player pause];
//}
//
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
//{
//    [player play];
//}

-(void) encode {
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString *_mp4Quality = AVAssetExportPresetMediumQuality;
    if ([compatiblePresets containsObject:_mp4Quality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:_mp4Quality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        _mp4Path = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", [formater stringFromDate:[NSDate date]]] retain];
        [formater release];
        isConverting = YES;
        exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
            isConverting = NO;
            [exportSession release];
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"AVAsset doesn't support mp4 quality"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void) convertFinish {
    NSLog(@"convert finish!!!!!!!!!");
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:[_videoURL path]]) {
        [fileMgr removeItemAtURL:_videoURL error:nil];
    }
    [self thumbnailImageForVideo:_mp4Path atTime:0];
//    int functionId = [[dict objectForKey:@"callback"] intValue];
//    cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
//    cocos2d::CCLuaValueDict item;
//    item["type"] = cocos2d::CCLuaValue::intValue(3);
//    item["fullPath"] = cocos2d::CCLuaValue::stringValue([_mp4Path UTF8String]);
//    item["docPath"] = cocos2d::CCLuaValue::stringValue([[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] UTF8String]);
//    cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
//    cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
//    cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
    LogicController::getInstance()->onConvertFinish([_mp4Path UTF8String]);
    [_mp4Path release];
    [_videoURL release];
    _mp4Path = nil;
    _videoURL = nil;
}

- (void) platformInit {
    NSLog(@"platformInit");
    NSString* openUDID = [OpenUDID value];
    openUDID = [@"quick_reg_i_" stringByAppendingString:openUDID];
    NSLog(@"openUDID:%@",openUDID);
    LogicController::getInstance()->platformInit([openUDID UTF8String], [@"nshx" UTF8String]);
}

- (void) pushToken:(int)type tk:(NSString*)token {
    NSLog(@"pushToken");
    LogicController::getInstance()->onPushToken(type, [token UTF8String]);
}

- (void) pushData:(int)data type:(int)tp {
    NSLog(@"pushData:%d tp:%d",data,tp);
    LogicController::getInstance()->onPushData(data,tp);
}

- (void) videoError {
    NSLog(@"videoError");
    LogicController::getInstance()->onVideoError();
}

- (void) videoSucc {
    NSLog(@"videoSucc");
    LogicController::getInstance()->onVideoSucc();
}

- (void) videoFinish {
    NSLog(@"videoFinish");
    LogicController::getInstance()->onVideoFinish();
}

-(void) thumbnailImageForVideo:(NSString *)videoURL atTime:(NSTimeInterval)time{
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost/private%@", videoURL]] options:nil] autorelease];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[[UIImage alloc] initWithCGImage:thumbnailImageRef] autorelease] : nil;
    NSArray *arr = [videoURL componentsSeparatedByString:@".mp4"];
    NSString *_path = [[NSString alloc] initWithString:[arr objectAtIndex:0]];
    _path = [_path stringByAppendingString:@"_mp4.jpg"];
    [UIImageJPEGRepresentation(thumbnailImage,0.1) writeToFile:_path atomically:YES];
}

-(void) playVideo:(NSDictionary*)_dict{
    NSString *path = [_dict objectForKey:@"path"];
    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    NSLog(@"%@",[NSString stringWithFormat:@"file://localhost/private%@", path]);
    [self presentViewController:playerView animated:YES completion:nil];
    [playerView release];
}

//对图片尺寸进行压缩
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


#pragma mark - UzysImageCropperDelegate

- (void)imageCropper:(UzysImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image
{

    NSLog(@"cropping Image Size : %@", NSStringFromCGSize(image.size));
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDate * date = [NSDate date];
    fileName = [NSString stringWithFormat:@"%lf",[date timeIntervalSince1970]];
    fileName = [fileName stringByAppendingString:@".jpg"];
    NSData *data;
    data = UIImageJPEGRepresentation(image, 0.5);
    [self dismissViewControllerAnimated:YES completion:nil];
    // Create paths to output images
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fullPath = [[NSString alloc]initWithString:pngPath];
    fullPath = [fullPath stringByAppendingString:@"/"];
    fullPath = [fullPath stringByAppendingString:fileName];
    [data writeToFile:fullPath atomically:YES];
    
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    int functionId = [[dict objectForKey:@"callback"] intValue];
    cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
    cocos2d::CCLuaValueDict item;
    item["type"] = cocos2d::CCLuaValue::intValue(1);
    item["pngPath"] = cocos2d::CCLuaValue::stringValue([pngPath UTF8String]);
    item["fullPath"] = cocos2d::CCLuaValue::stringValue([fullPath UTF8String]);
    item["fileName"] = cocos2d::CCLuaValue::stringValue([fileName UTF8String]);
    cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
    cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
    cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
    [dict release];

}

- (void)imageCropperDidCancel:(UzysImageCropperViewController *)cropper
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [dict release];
}

//3.x 用户选中图片后的回调
- (void)imagePickerController: (UIImagePickerController *)picker
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
//    NSLog(@"3.x");
    //获得编辑过的图片
    if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqual: @"public.movie"]) {
        _videoURL = [info[UIImagePickerControllerMediaURL] retain];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self encode];
        [dict release];
    }else {
        UIImage* image;
//        if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
//            image = [info objectForKey: @"UIImagePickerControllerEditedImage"];
//        }
        if ([dict objectForKey:@"width"]) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSLog(@"original Image Size : %@", NSStringFromCGSize(image.size));
            _imgCropperViewController = [[UzysImageCropperViewController alloc] initWithImage:image andframeSize:picker.view.frame.size andcropSize:CGSizeMake([[dict objectForKey:@"width"] floatValue], [[dict objectForKey:@"height"] floatValue])];
            _imgCropperViewController.delegate = self;
            [picker presentViewController:_imgCropperViewController animated:YES completion:nil];
            [_imgCropperViewController release];
            return;
        }else {
            image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            CGSize imageSize = image.size;
            float oriWidth = image.size.width;
            float oriHeight = image.size.height;
            NSLog(@"%f %f",imageSize.width,imageSize.height);
            if (oriWidth > 640 || oriHeight > 1136) {
                if (640/oriWidth < 1136/oriHeight) {
                    imageSize.width = 640;
                    imageSize.height = imageSize.height * (640/oriWidth);
                }else {
                    imageSize.width = imageSize.width * (1136/oriHeight);
                    imageSize.height = 1136;
                }
                image = [self imageWithImage:image scaledToSize:imageSize];
            }
        }
        NSDate * date = [NSDate date];
        fileName = [NSString stringWithFormat:@"%lf",[date timeIntervalSince1970]];
        fileName = [fileName stringByAppendingString:@".jpg"];
        NSData *data;
        data = UIImageJPEGRepresentation(image, 0.1);
        [self dismissViewControllerAnimated:YES completion:nil];
        // Create paths to output images
        NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *fullPath = [[NSString alloc]initWithString:pngPath];
        fullPath = [fullPath stringByAppendingString:@"/"];
        fullPath = [fullPath stringByAppendingString:fileName];
        [data writeToFile:fullPath atomically:YES];
        
        //NSFileManager *fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
        int functionId = [[dict objectForKey:@"callback"] intValue];
        cocos2d::CCLuaObjcBridge::pushLuaFunctionById(functionId);
        cocos2d::CCLuaValueDict item;
        item["type"] = cocos2d::CCLuaValue::intValue(1);
        item["pngPath"] = cocos2d::CCLuaValue::stringValue([pngPath UTF8String]);
        item["fullPath"] = cocos2d::CCLuaValue::stringValue([fullPath UTF8String]);
        item["fileName"] = cocos2d::CCLuaValue::stringValue([fileName UTF8String]);
        cocos2d::CCLuaObjcBridge::getStack()->pushCCLuaValueDict(item);
        cocos2d::CCLuaObjcBridge::getStack()->executeFunction(1);
        cocos2d::CCLuaObjcBridge::releaseLuaFunctionById(functionId);
        [dict release];
    }
}

////2.x 用户选中图片之后的回调
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    NSLog(@"2.x");
//    NSMutableDictionary * dict1= [NSMutableDictionary dictionaryWithDictionary:editingInfo];
//    [dict1 setObject:image forKey:@"UIImagePickerControllerEditedImage"];
//    //直接调用3.x的处理函数
//    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict1];
//}

// 用户选择取消
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [dict release];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheetIndex == 1) {
        
    }else if (actionSheetIndex == 2) {
        
    }
}
@end
