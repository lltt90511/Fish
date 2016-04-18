//
//  VideoPlatform.h
//  GirlFan
//
//  Created by kahntang on 5/23/14.
//
//

#ifndef __GirlFan__VideoPlatform__
#define __GirlFan__VideoPlatform__

#include <iostream>
#include "cocos2d.h"

using namespace cocos2d;
class VideoPlatform : public CCLayer
{
public:
   
    static VideoPlatform* getInstance();
    static void destroyInstance();
    void static playURLVideo(const char * urlString);//用于播放网络视频
    void static stopVideo();//用于播放网络视频
    void static hiddenVideo();//用于播放网络视频
    void testMethod(int type);
    static std::string playurl;
    static bool stopFlag;

protected:
    VideoPlatform();
    ~VideoPlatform();
    
private:
    static VideoPlatform *videoPlatform;
    
};

#endif /* defined(__GirlFan__VideoPlatform__) */
