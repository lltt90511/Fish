#include "LogicController.h"
//#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
extern "C" {
#include "lualib.h"
#include "lauxlib.h"
#include "lua.h"
}
#include "cocos2d.h"
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
#include "LogicController.h"
#include "NetController.h"

//extern "C" {
//#include "lualib.h"
//#include "lauxlib.h"
//#include "cjson.h"
//}


#include "capi.h"

extern void registerAPI(lua_State* L);
extern int luaopen_cjson(lua_State* L);

#ifdef WIN32
#include "windows.h"
#endif 
//USING_NS_CC
using namespace cocos2d;

LogicController* LogicController::pInstance = NULL;

LogicController::LogicController()
{
	this->rpcQueueMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    this->logicMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    this->L = pEngine->getLuaStack()->getLuaState();
    
}


LogicController::~LogicController()
{
}



LogicController* LogicController::getInstance() {
	if (pInstance == NULL) {
		pInstance = new LogicController();
	}
	return pInstance;
}


void LogicController::doTick() {
    
//    if (!NetController::getInstance()->isConnected()) {
//        return;
//    }
	while(true) {
		APC* apc = this->popRpcQueue();
		if (apc == NULL) {
			break;
		}	
//		apc->unEncrypt();
//		apc->unCompress();
        
//        CCLOG("apc: %s %d", apc->data, apc->data_len);

        pthread_mutex_lock(&this->logicMutex);
		lua_getglobal(L,"L_onError");
		lua_getglobal(L,"L_onRPC");
		lua_pushlstring(L, apc->data, apc->data_len);
		if (lua_pcall(L,1,0,-3) == 0) {
//            printf("111111 stack top=%d\n",lua_gettop(L));
			lua_pop(L,1);
		} else {
//            printf("222222 stack top=%d\n",lua_gettop(L));
			lua_pop(L,2);
		}
//        printf("############# stack top=%d\n",lua_gettop(L));
        pthread_mutex_unlock(&this->logicMutex);
		delete apc;

	}

}

void LogicController::onChangedNetwork(int type) {
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onChangedNetwork\",\"parameters\":[%d]}", type);
    APC *apc = new APC(0,cmd,strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onConvertFinish(const char *path){
    char *cmd = new char[strlen(path)+100];
    sprintf(cmd, "{\"functionName\":\"onConvertFinish\",\"parameters\":[\"%s\"]}", path);
    APC *apc = new APC(0,cmd,strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onUpload(int type, char *oldName, const char* str, int seconds,int bytes){
    //printf("%d %s %s %d\n",type,oldName,str, seconds);
    char *cmd = new char[strlen(oldName)+strlen(str)+100];
    sprintf(cmd, "{\"functionName\":\"onUpload\",\"parameters\":[%d,\"%s\",\"%s\",%d,%d]}", type, oldName, str, seconds,bytes);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onDownload(int type, char *fileName, int nowIndex,int bytes){
   // printf("%d %s %d\n",type,fileName,nowIndex);
    char *cmd = new char[strlen(fileName)+100];
    sprintf(cmd, "{\"functionName\":\"onDownload\",\"parameters\":[%d,\"%s\",%d,%d]}", type, fileName, nowIndex,bytes);
    APC *apc = new APC(0,cmd,strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onUploadError(int type){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onUploadError\",\"parameters\":[%d]}", type);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onLoadArmatureDataSucceed(const char *str) {
	char *cmd = new char[strlen(str)+100];
    sprintf(cmd, "{\"functionName\":\"onLoadArmatureDataSucceed\",\"parameters\":[\"%s\"]}", str);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onPlayNextRecord(){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onPlayNextRecord\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onDownloadError(int type, char* fileName, int nowIndex){
	char *cmd = new char[strlen(fileName)+100];
    sprintf(cmd, "{\"functionName\":\"onDownloadError\",\"parameters\":[%d,\"%s\",%d]}", type, fileName, nowIndex);
    APC *apc = new APC(0,cmd,strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onProgress(int type, int nowIndex, int per){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onProgress\",\"parameters\":[%d,%d,%d]}", type, nowIndex, per);
    APC *apc = new APC(0,cmd,strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onClose(int sockId) {
    char *cmd = new char[64];
    sprintf(cmd, "{\"functionName\":\"onClose\",\"parameters\":[%d]}", sockId);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}
// ret 0 ok !0 failed
void LogicController::onConnect(int ret) {
    char *cmd = new char[64];
    sprintf(cmd, "{\"functionName\":\"onConnect\",\"parameters\":[%d]}", ret);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onTakePhoto(const char *path, const char *id){
	char *cmd = new char[strlen(path) + strlen(id)+100];
	sprintf(cmd, "{\"functionName\":\"onTakePhoto\",\"parameters\":[\"%s\",\"%s\"]}", id,path);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onStopAudioRecorder(int isSuccess, const char *path, int seconds){
    char *cmd = new char[strlen(path)+100];
	sprintf(cmd, "{\"functionName\":\"onStopAudioRecorder\",\"parameters\":[%d,\"%s\",%d]}", isSuccess,path,seconds);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::doFile(char *file) {
    pthread_mutex_lock(&this->logicMutex);
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    pEngine->executeScriptFile(file);
    pthread_mutex_unlock(&this->logicMutex);
}

void LogicController::onBack() {
	char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onBack\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::platformInit(const char *devideId, const char* params) {
	char *cmd = new char[100 + strlen(devideId) + strlen(params)];
	sprintf(cmd, "{\"functionName\":\"platformInit\",\"parameters\":[\"%s\",\"%s\"]}", devideId, params);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onHttpRepose(int urlId){
	char *cmd = new char[1000];
	sprintf(cmd, "{\"functionName\":\"onHttpRepose\",\"parameters\":[%d]}", urlId);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onPushToken(int type, const char* token){
	char *cmd = new char[100 + strlen(token)];
	sprintf(cmd, "{\"functionName\":\"onPushToken\",\"parameters\":[%d,\"%s\"]}", type, token);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onPushData(int msgId, int msgType){
	char *cmd = new char[500];
	sprintf(cmd, "{\"functionName\":\"onPushData\",\"parameters\":[%d,%d]}", msgId, msgType);
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onLoginResult(const char* uId, const char* uName, const char* uSession){
	char *cmd = new char[100 + strlen(uSession) + strlen(uName) + strlen(uId)];
    sprintf(cmd, "{\"functionName\":\"onLoginResult\",\"parameters\":[\"%s\",\"%s\",\"%s\"]}", uId, uName, uSession);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onSwitchResult(int result){
    char *cmd = new char[200];
    sprintf(cmd, "{\"functionName\":\"onSwitchResult\",\"parameters\":[%d]}", result);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onPayResult(int result){
    char *cmd = new char[200];
    sprintf(cmd, "{\"functionName\":\"onPayResult\",\"parameters\":[%d]}", result);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onLogoutResult(int result){
    char *cmd = new char[200];
    sprintf(cmd, "{\"functionName\":\"onLogoutResult\",\"parameters\":[%d]}", result);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onVideoError(){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onVideoError\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onVideoSucc(){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onVideoSucc\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onVideoFinish(){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onVideoFinish\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onRemuseFormBackground(){
    char *cmd = new char[100];
    sprintf(cmd, "{\"functionName\":\"onRemuseFormBackground\",\"parameters\":[]}");
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}
void LogicController::onEnterBackground(){
	char *cmd = new char[100];
	sprintf(cmd, "{\"functionName\":\"onEnterBackground\",\"parameters\":[]}");
	APC *apc = new APC(0, cmd, strlen(cmd));
	this->pushRpcQueue(apc);
}

void LogicController::onVoiceText(const char* txt) {
    char *cmd = new char[1000];
    sprintf(cmd, "{\"functionName\":\"onVoiceText\",\"parameters\":[\"%s\"]}", txt);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::onAppInfo(const char* params) {
    char *cmd = new char[100 + strlen(params)];
    sprintf(cmd, "{\"functionName\":\"onAppInfo\",\"parameters\":[\"%s\"]}", params);
    APC *apc = new APC(0, cmd, strlen(cmd));
    this->pushRpcQueue(apc);
}

void LogicController::pushRpcQueue(APC *apc) {
	pthread_mutex_lock(&this->rpcQueueMutex);
	this->rpcQueue.push(apc);
	pthread_mutex_unlock(&this->rpcQueueMutex);
}



APC *LogicController::popRpcQueue() {
	APC *apc = NULL;
	pthread_mutex_lock(&this->rpcQueueMutex);
	if (!this->rpcQueue.empty()) {
		apc = this->rpcQueue.front();
		this->rpcQueue.pop();
	}
	pthread_mutex_unlock(&this->rpcQueueMutex);
	return apc;
}


