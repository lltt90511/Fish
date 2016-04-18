#include "cocos2d.h"
#include "CCEGLView.h"
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "Lua_extensions_CCB.h"
#include "LuaCocoStudio.h"
#include "sqLite/lsqlite3.h"
#define ZIPFILESUFFIX ".resource"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "Lua_web_socket.h"

#endif
#ifdef ANDROID 
#include "platform/android/CCLuaJavaBridge.h"
#endif

#include "script_support/CCScriptSupport.h"
//#include "luaopen_LuaProxy.h"
#include "LogicController.h"
#include "NetController.h"
#include "capi.h"
#include "cjson/lua_extensions.h"
#include "Video/VideoPlatform.h"

//#include "catapult.h"
#include "LuaBox2D.h"
#include "luacurl.h"
//#include "tolua\LuaBall.h"
#define TEST_PROJ_C 1
//#include "CocosGUI.h" 
using namespace CocosDenshion;

USING_NS_CC;
USING_NS_CC_EXT;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{	
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

    // turn on display FPS
    pDirector->setDisplayStats(false);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);

    
    
    // register lua engine
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

    CCLuaStack *pStack = pEngine->getLuaStack();
	pStack->setXXTEAKeyAndSign("l8KQKnBIgBq1RHi", strlen("l8KQKnBIgBq1RHi"), "P4I7gouyNiqbYMR", strlen("P4I7gouyNiqbYMR"));
    lua_State *tolua_s = pStack->getLuaState();
    tolua_extensions_ccb_open(tolua_s);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    pStack = pEngine->getLuaStack();
    tolua_s = pStack->getLuaState();
    tolua_web_socket_open(tolua_s);
#endif
    
//    luaopen_LuaProxy(tolua_s);
    luaopen_lua_extensions(tolua_s);
	tolua_CocoStudio_open(tolua_s);
	tolua_Box2D_open(tolua_s);
	luaopen_luacurl(tolua_s);
	luaopen_lsqlite3(tolua_s);
//	tolua_MyContactListener_open(tolua_s);
	registerAPI(tolua_s);
    NetController::getInstance()->run();
    

	//preLoad
	//std::string writePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/music").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/res/cash").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/scripts").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/scripts/common").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/res").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().append("update/sound").c_str());
#ifdef ANDROID 
	CCLuaJavaBridge::luaopen_luaj(tolua_s);
	//android
	CCFileUtils::sharedFileUtils()->removeSearchPath("assets/");
	CCFileUtils::sharedFileUtils()->removeSearchPath("assets");
	//CCFileUtils::sharedFileUtils()->removeSearchPath("assets/cash");
	CCFileUtils::sharedFileUtils()->addSearchPath("cash");
	CCFileUtils::sharedFileUtils()->addSearchPath("common");
	CCFileUtils::sharedFileUtils()->addSearchPath("sound");
	CCFileUtils::sharedFileUtils()->addSearchPath("");

#endif

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	//iphone
    CCFileUtils::sharedFileUtils()->addSearchPath("Res/res");
    CCFileUtils::sharedFileUtils()->addSearchPath("Res/res/cash");
    CCFileUtils::sharedFileUtils()->addSearchPath("Res/scripts");
    CCFileUtils::sharedFileUtils()->addSearchPath("Res/scripts/common");
    CCFileUtils::sharedFileUtils()->addSearchPath("Res/music");
	CCFileUtils::sharedFileUtils()->addSearchPath("Res/sound");
#endif
#ifdef WIN32
#ifdef _DEBUG
	CCFileUtils::sharedFileUtils()->addSearchPath("scripts");
	CCFileUtils::sharedFileUtils()->addSearchPath("scripts/common");
	CCFileUtils::sharedFileUtils()->addSearchPath("res");
	CCFileUtils::sharedFileUtils()->addSearchPath("res/cash");
	CCFileUtils::sharedFileUtils()->addSearchPath("sound");
	CCFileUtils::sharedFileUtils()->addSearchPath("unPackagedRes/res/cash");
	CCFileUtils::sharedFileUtils()->addSearchPath("unPackagedRes");
	CCFileUtils::sharedFileUtils()->addSearchPath("unPackagedRes/res");
	CCFileUtils::sharedFileUtils()->addSearchPath("unPackagedRes/music");
#else
	std::string zip("res");
	zip.append(ZIPFILESUFFIX);
	CCFileUtils::sharedFileUtils()->addSearchPath(zip.c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath((zip+"/cash").c_str());
	CCFileUtils::sharedFileUtils()->addSearchPath((zip + "/common").c_str());
#endif
#endif
	CCFileUtils *fileUtils = CCFileUtils::sharedFileUtils();;
	setWriteAblePath(fileUtils->getWritablePath().c_str());
	pEngine->executeString("require (\"updateManager\")");
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCLog("applicationDidEnterBackground");
	LogicController::getInstance()->onEnterBackground();
	CCDirector::sharedDirector()->stopAnimation();
	
    std::string url = VideoPlatform::playurl;
    if(url.length()>0)
        VideoPlatform::stopVideo();
    SimpleAudioEngine::sharedEngine()->stopAllEffects();
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCLog("applicationWillEnterForeground");

    CCDirector::sharedDirector()->startAnimation();
    LogicController::getInstance()->onRemuseFormBackground();
    std::string url = VideoPlatform::playurl;
    if(url.length()>0)
        VideoPlatform::playURLVideo(url.c_str());

    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
    //SimpleAudioEngine::sharedEngine()->resumeAllEffects();
    
}
