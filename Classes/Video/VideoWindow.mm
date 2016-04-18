//

//  VideoWindow.mm

//  GirlFan

//

//  Created by kahntang on 6/20/14.

//

//

//



//  VideoWindow.cpp



//  GirlFan



//



//  Created by kahntang on 6/18/14.



//



//







#include "VideoWindow.h"

#include "pthread.h"

#include "VideoController.h"





VideoWindow* VideoWindow::videoWindow = NULL;

pthread_cond_t  VideoWindow::cond;

pthread_mutex_t  VideoWindow::mutex;

pthread_t   VideoWindow::pth_id;

int status = STOP;



static VideoController *g_ViewController=nil;



VideoWindow::VideoWindow(){
    status = STOP;
    
    if(g_ViewController==NULL)
        
        g_ViewController = [[VideoController alloc] init];
    
    
    
}





VideoWindow::~VideoWindow(){
    
    
    
    [g_ViewController release];
    
    
    
}



int VideoWindow::thread_start(){
    
    int errCode=0;
    do {
//        pthread_cond_t cond;
//        pthread_mutex_t mutex;
//        pthread_t pth_id;
        pthread_mutex_init(&mutex,NULL);
        pthread_cond_init(&cond,NULL);
        pthread_attr_t tAttr;
        errCode=pthread_attr_init(&tAttr);
        CC_BREAK_IF(errCode!=0);
        errCode=pthread_attr_setdetachstate(&tAttr, PTHREAD_CREATE_DETACHED);
        if(errCode!=0)
        {
            pthread_attr_destroy(&tAttr);
            break;
        }
        CCLOG("==================%d",11);
        
        errCode=pthread_create(&pth_id, &tAttr, initRect, NULL);
        CCLOG("==================%d",12);
        
        timespec to;
        to.tv_sec = time(NULL) + 1;
        to.tv_nsec = 1;
        pthread_mutex_lock(&mutex);
        pthread_cond_timedwait(&cond, &mutex, &to);
        pthread_mutex_unlock(&mutex);
        CCLOG("==================%d",13);
        status = RUN;
        //        sleep(1);
        
    } while (0);
    return errCode;
    
}
void VideoWindow::thread_pause(){
    
    if (status == RUN)
    {
        pthread_mutex_lock(&mutex);
        status = STOP;
        printf("thread stop!\n");
        
        [g_ViewController stopVideoPlay];
//        pthread_join(pth_id, NULL);
//        pthread_exit(NULL);

        pthread_mutex_unlock(&mutex);
    }
    else
    {
        
        printf("pthread pause already\n");
        
    }
    
}





void VideoWindow::thread_resume(){
    
    
    if (status == STOP)
    {
        
        pthread_mutex_lock(&mutex);
        
        status = RUN;
        
        pthread_cond_signal(&cond);
        
        printf("pthread run!\n");
        
        pthread_mutex_unlock(&mutex);
        
    }
    else
    {
        
        printf("pthread run already\n");
        
    }
    
}





void VideoWindow::destroyInstance()

{
    
    do
        
    {
        
        if(videoWindow)
            
        {
            
            delete videoWindow;
            
            
            
            videoWindow = NULL;
            
            
            
        }
        
        
        
    } while(0);
    
    
    
}



void* VideoWindow::initRect(void * arg){
    
    
    
//    pthread_mutex_init(&mutex,NULL);
    
    pthread_cond_init(&cond,NULL);
    
    
    
    g_ViewController = [[VideoController alloc] init];
    
    [g_ViewController createControl];
    
    
    
    timespec to;
    
    to.tv_sec = time(NULL) + 3;
    
    to.tv_nsec = 0;
    
    pthread_mutex_lock(&mutex);
    
    pthread_cond_timedwait(&cond, &mutex, &to);
    
    pthread_mutex_unlock(&mutex);
    
    
    
}



void VideoWindow::stopVideoPlay(){
    
//    pthread_mutex_lock(&mutex);
    
    [g_ViewController stopVideoPlay];
    status = STOP;
//    pthread_join(pth_id, NULL);
//    pthread_mutex_unlock(&mutex);

    
}



void VideoWindow::setHidden(){
    
    [g_ViewController setHidden];
    
}



void VideoWindow::showVideo(){
    
    [g_ViewController showVideo];
    
    
    
}



void* VideoWindow::startVideoPlay(const char * urlString){
    g_ViewController = [[VideoController alloc] init];
    [g_ViewController startVideoPlay : urlString];
    
}



VideoWindow* VideoWindow::getInstance(){
    
    if(!videoWindow)
    {
        
        videoWindow = new VideoWindow();
        
    }
    
    return videoWindow;    
    
    
    
}



void VideoWindow::playVideo(const char * urlString){
    
    if (status == STOP)
    {
    //g_ViewController = [[VideoController alloc] init];
    
        [g_ViewController setViedoView : urlString];
        status = RUN;
    }
    
    
    
}