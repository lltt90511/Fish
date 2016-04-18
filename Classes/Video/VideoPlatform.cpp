//
//  VideoPlatform.mm
//  GirlFan
//
//  Created by kahntang on 5/23/14.
//
//


#include "platform/CCPlatformConfig.h"
#include "VideoPlatform.h"

#if (CC_TARGET_PLATFORM==CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include <android/log.h>
#elif(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
#include "VideoWindow.h"
#endif

VideoPlatform* VideoPlatform::videoPlatform = NULL;
std::string VideoPlatform::playurl = "";
bool VideoPlatform::stopFlag = false;

VideoPlatform::VideoPlatform(){
    
}
VideoPlatform::~VideoPlatform(){
    
}

void VideoPlatform::destroyInstance(){
    
}

VideoPlatform* VideoPlatform::getInstance(){
    if(!videoPlatform)
    {
        videoPlatform = new VideoPlatform();
    }
    return videoPlatform;
}

void VideoPlatform::stopVideo(){
    VideoPlatform::stopFlag = false;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    JniMethodInfo method;
    jobject jobj;
    bool isHave = JniHelper::getStaticMethodInfo(method, "cc/yongdream/nshx/mainActivity","getInstance","()Lcc/yongdream/nshx/mainActivity;");
    if (isHave)
    {
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance++++++++++++++++");
        
        //调用Java静态函数，取得对象。
        jobj = method.env->CallStaticObjectMethod(method.classID, method.methodID);
        if (jobj != NULL)
        {
            __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++stopPlay++++++++++++++++");
            
            isHave = JniHelper::getMethodInfo(method,"cc/yongdream/nshx/mainActivity","stopPlay","()V");
            if (isHave)
            {
                //调用java非静态函数, 参数1：Java对象，上面已经取得   参数2：方法ID
                __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++call stopPlay++++++++++++++++");
                method.env->CallVoidMethod(jobj, method.methodID);
            }
        }
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance end++++++++++++++++");
        
    }
    __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++jjob ++++++++++++++++");

#elif(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
    //IOS播放网络视频
    
    VideoWindow::getInstance()->stopVideoPlay();
    //    VideoScene * videoScene = VideoScene::create(urlString);
    //    videoScene->setPosition(ccpAdd(VisibleRect::leftTop(),ccp(0,0)));
    //this->addChild(videoScene);
    
    
    //    CCMenu *menu;
    //    //添加粉丝榜按钮
    //    CCMenuItem *item_fenShi = CCMenuItemImage::create("ui_room_btn_fensibang_1.png", "ui_room_btn_fensibang_2.png", this, menu_selector(RoomLayer::touch_btn));
    //    item_fenShi->setTag(114);
    //    item_fenShi->setPosition(ccpAdd(VisibleRect::center(), ccp(264, 154)));
    //    menu->addChild(item_fenShi,2);
    //    this->addChild(menu,0);
    
#endif
    
}

void VideoPlatform::hiddenVideo(){
    VideoPlatform::stopFlag = false;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    JniMethodInfo method;
    jobject jobj;
    bool isHave = JniHelper::getStaticMethodInfo(method, "cc/yongdream/nshx/mainActivity","getInstance","()Lcc/yongdream/nshx/mainActivity;");
    if (isHave)
    {
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance++++++++++++++++");
        
        //调用Java静态函数，取得对象。
        jobj = method.env->CallStaticObjectMethod(method.classID, method.methodID);
        if (jobj != NULL)
        {
            __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++hiddenVideo++++++++++++++++");
            
            isHave = JniHelper::getMethodInfo(method,"cc/yongdream/nshx/mainActivity","hiddenVideo","()V");
            if (isHave)
            {
                //调用java非静态函数, 参数1：Java对象，上面已经取得   参数2：方法ID
                __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++call hiddenVideo++++++++++++++++");
                method.env->CallVoidMethod(jobj, method.methodID);
            }
        }
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance end++++++++++++++++");
        
    }
    __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++jjob ++++++++++++++++");
    
#elif(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
    //IOS播放网络视频
    
    VideoWindow::getInstance()->setHidden();
    //    VideoScene * videoScene = VideoScene::create(urlString);
    //    videoScene->setPosition(ccpAdd(VisibleRect::leftTop(),ccp(0,0)));
    //this->addChild(videoScene);
    
    
    //    CCMenu *menu;
    //    //添加粉丝榜按钮
    //    CCMenuItem *item_fenShi = CCMenuItemImage::create("ui_room_btn_fensibang_1.png", "ui_room_btn_fensibang_2.png", this, menu_selector(RoomLayer::touch_btn));
    //    item_fenShi->setTag(114);
    //    item_fenShi->setPosition(ccpAdd(VisibleRect::center(), ccp(264, 154)));
    //    menu->addChild(item_fenShi,2);
    //    this->addChild(menu,0);
    
#endif
    
}

void VideoPlatform::playURLVideo(const char * urlString)
{
    VideoPlatform::stopFlag = true;
    
    VideoPlatform::playurl = urlString;
    
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    CCLog("jni-java开始调用");

    
    JniMethodInfo method;
    jobject jobj;
    bool isHave = JniHelper::getStaticMethodInfo(method, "cc/yongdream/nshx/mainActivity","getInstance","()Lcc/yongdream/nshx/mainActivity;");
    if (isHave)
    {
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance++++++++++++++++");
        
        //调用Java静态函数，取得对象。
        jobj = method.env->CallStaticObjectMethod(method.classID, method.methodID);
        if (jobj != NULL)
        {
            __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++playVideo++++++++++++++++");
            
            isHave = JniHelper::getMethodInfo(method,"cc/yongdream/nshx/mainActivity","playVideo","(Ljava/lang/String;)V");
            if (isHave)
            {
                //调用java非静态函数, 参数1：Java对象，上面已经取得   参数2：方法ID
                __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++call playVideo++++++++++++++++");
                jstring jurl = method.env->NewStringUTF(urlString);
                method.env->CallVoidMethod(jobj, method.methodID,jurl);
            }
        }
        __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++getInstance end++++++++++++++++");
        
    }
    
    __android_log_print(ANDROID_LOG_ERROR, "cocos2d-x debug info",  "+++++++++++jjob ++++++++++++++++");
    
//    JniMethodInfo method;
//    bool b=JniHelper::getMethodInfo(method,"com.youngdream.girlfan.GirlFan","playVideo","(Ljava/lang/String;)V");
//    if (b)
//    {
//        jstring jurl = method.env->NewStringUTF(urlString);
//        method.env->CallStaticVoidMethod(method.classID,method.methodID,jurl);
//    }
//    CCLog("jni-java函数执行完毕");

#elif(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
    //IOS播放网络视频
   
    VideoWindow::getInstance()->playVideo(urlString);
//    VideoScene * videoScene = VideoScene::create(urlString);
//    videoScene->setPosition(ccpAdd(VisibleRect::leftTop(),ccp(0,0)));
    //this->addChild(videoScene);
    
    
//    CCMenu *menu;
//    //添加粉丝榜按钮
//    CCMenuItem *item_fenShi = CCMenuItemImage::create("ui_room_btn_fensibang_1.png", "ui_room_btn_fensibang_2.png", this, menu_selector(RoomLayer::touch_btn));
//    item_fenShi->setTag(114);
//    item_fenShi->setPosition(ccpAdd(VisibleRect::center(), ccp(264, 154)));
//    menu->addChild(item_fenShi,2);
//    this->addChild(menu,0);

#endif
}


void VideoPlatform::testMethod(int type)
{
    
    CCLog("jni-java开始调用testMethod");
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    CCLog("jni-java开始调用");
    
    
#elif(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
    //IOS播放网络视频
    
#endif
}