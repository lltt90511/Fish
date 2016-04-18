#include "AppDelegate.h"
#include "cocos2d.h"
#include "CCEventType.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include "LogicController.h"
#include <android/log.h>

#define  LOG_TAG    "main"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
using namespace cocos2d;

extern "C"
{
    
    jint JNI_OnLoad(JavaVM *vm, void *reserved)
    {
        JniHelper::setJavaVM(vm);

        return JNI_VERSION_1_4;
    }
    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_afterTakePhoto(JNIEnv *env, jobject thiz, jstring path, jstring id)
    {
       // CCAssert(false,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        const char *pathString = env->GetStringUTFChars(path, NULL);
        const char *idString = env->GetStringUTFChars(id, NULL);
        CCLOG("pathString :%s idString :%s", pathString,idString);
         LogicController::getInstance()->onTakePhoto(pathString,idString);

        env->ReleaseStringUTFChars(path, pathString);
        env->ReleaseStringUTFChars(id, idString);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_onConvertFinish(JNIEnv *env, jobject thiz, jstring path)
    {
    	// CCAssert(false,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    	const char *pathString = env->GetStringUTFChars(path, NULL);
		CCLOG("pathString :%s", pathString);
		LogicController::getInstance()->onConvertFinish(pathString);

		env->ReleaseStringUTFChars(path, pathString);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_onStopAudioRecorder(JNIEnv *env, jobject thiz,jint issuccess, jstring path,jint seconds)
	{
		// CCAssert(false,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		const char *pathString = env->GetStringUTFChars(path, NULL);
		int cseconds = seconds;
		int cissuccess = issuccess;
		CCLOG("pathString :%s", pathString);
		LogicController::getInstance()->onStopAudioRecorder(cissuccess,pathString,cseconds);

		env->ReleaseStringUTFChars(path, pathString);
	}

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_onChangedNetwork(JNIEnv *env, jobject thiz,jint type)
	{
		// CCAssert(false,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		int ctype = type;
		LogicController::getInstance()->onChangedNetwork(ctype);
	}

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_onPlayNextRecord(JNIEnv *env, jobject thiz)
	{
		LogicController::getInstance()->onPlayNextRecord();
	}

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_onBack(JNIEnv *env, jobject thiz)
	{
		LogicController::getInstance()->onBack();
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativePlatformInit(JNIEnv *env, jobject thiz, jstring devideId, jstring params)
	{
		const char *devideString = env->GetStringUTFChars(devideId, NULL);
		const char *paramsString = env->GetStringUTFChars(params, NULL);
		LogicController::getInstance()->platformInit(devideString, paramsString);
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativePlatformLoginResult(JNIEnv *env, jobject thiz, jstring uId, jstring uName, jstring uSession)
	{
		const char *uIdString = env->GetStringUTFChars(uId, NULL);
		const char *uNameString = env->GetStringUTFChars(uName, NULL);
		const char *uSessionString = env->GetStringUTFChars(uSession, NULL);
		LogicController::getInstance()->onLoginResult(uIdString, uNameString, uSessionString);
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativePlatformSwitchResult(JNIEnv *env, jobject thiz, jint result)
	{
		int cresult = result;
		LogicController::getInstance()->onSwitchResult(cresult);
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativePlatformPayResult(JNIEnv *env, jobject thiz, jint result)
	{
		int cresult = result;
		LogicController::getInstance()->onPayResult(cresult);
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativePlatformLogoutResult(JNIEnv *env, jobject thiz, jint result)
	{
		int cresult = result;
		LogicController::getInstance()->onLogoutResult(cresult);
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_Util_nativePushToken(JNIEnv *env, jobject thiz, jint type, jstring token)
	{
		int cType = type;
		const char *cToken = env->GetStringUTFChars(token, NULL);
		LogicController::getInstance()->onPushToken(cType, cToken);
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_Util_nativePushData(JNIEnv *env, jobject thiz, jint msgId, jint msgType)
	{
		int cMsgId = msgId;
		int cMsgType = msgType;
		LogicController::getInstance()->onPushData(cMsgId, cMsgType);
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_mainActivity_onVideoSucc(JNIEnv *env, jobject thiz)
	{
		LogicController::getInstance()->onVideoSucc();
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_mainActivity_onVideoError(JNIEnv *env, jobject thiz)
	{
		LogicController::getInstance()->onVideoError();
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_mainActivity_onVideoFinish(JNIEnv *env, jobject thiz)
	{
		LogicController::getInstance()->onVideoFinish();
	}

    JNIEXPORT void JNICALL Java_cc_yongdream_nshx_voice2Text_onVoiceText(JNIEnv *env, jobject thiz, jstring txt)
	{
		const char *uTxtString = env->GetStringUTFChars(txt, NULL);
		LogicController::getInstance()->onVoiceText(uTxtString);
	}

    JNIEXPORT void JNICALL Java_com_java_platform_NdkPlatform_nativeAppInfo(JNIEnv *env, jobject thiz, jstring params)
	{
		const char *paramsString = env->GetStringUTFChars(params, NULL);
		LogicController::getInstance()->onAppInfo(paramsString);
	}

    void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
    {
        if (!CCDirector::sharedDirector()->getOpenGLView())
        {
            CCEGLView *view = CCEGLView::sharedOpenGLView();
            view->setFrameSize(w, h);

            AppDelegate *pAppDelegate = new AppDelegate();
            CCApplication::sharedApplication()->run();
        }/*
        else
        {
            ccGLInvalidateStateCache();
            CCShaderCache::sharedShaderCache()->reloadDefaultShaders();
            ccDrawInit();
           // CCTextureCache::reloadAllTextures();
            CCNotificationCenter::sharedNotificationCenter()->postNotification(EVENT_COME_TO_FOREGROUND, NULL);
            CCDirector::sharedDirector()->setGLDefaultValues(); 
        }*/
    }

}
