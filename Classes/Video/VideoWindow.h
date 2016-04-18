//
//  VideoWindow.h
//  GirlFan
//
//  Created by kahntang on 6/20/14.
//
//

#ifndef __GirlFan__VideoWindow__
#define __GirlFan__VideoWindow__

#include <iostream>
#include <cocos2d.h>
#define RUN 1
#define STOP 0

class VideoWindow{
public:
    
    static VideoWindow* getInstance();
    static pthread_t pth_id;
    static pthread_cond_t cond;
    static pthread_mutex_t mutex;
    
    static void destroyInstance();
    static void* initRect(void * arg);
    void playVideo(const char * urlString);//用于播放网络视频
    static void* startVideoPlay(const char * urlString);//用于播放网络视频

    void stopVideoPlay();
    void setHidden();
    void showVideo();
    int  thread_start();
    void thread_resume();
    void thread_pause();
    int status;
protected:
    VideoWindow();
    ~VideoWindow();
private:
    static VideoWindow *videoWindow;
};

#endif /* defined(__GirlFan__VideoWindow__) */
