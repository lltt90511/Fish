#pragma once
#include <queue>
#include "APC.h"
#include "pthread.h"
extern "C" {
#include "lualib.h"
#include "lauxlib.h"
#include "lua.h"
}
class LogicController
{
private:
	LogicController();
	~LogicController();
	static LogicController* pInstance;
	std::queue<APC*> rpcQueue;
	pthread_mutex_t rpcQueueMutex;
    pthread_mutex_t logicMutex;
    lua_State* L;



public:
	static LogicController* getInstance();

	void pushRpcQueue(APC* apc);
	APC* popRpcQueue();
	void doTick();
    void onClose(int sockId);
    void onConnect(int ret);
    void doFile(char *);
    void onUpload(int type, char* oldName, const char* str, int seconds,int bytes);
    void onDownload(int type, char* fileName, int nowIndex,int bytes);
    void onConvertFinish(const char *path);
    void onChangedNetwork(int type);
    void onProgress(int type, int nowIndex, int per);
    void onDownloadError(int type, char* fileName, int nowIndex);
    void onUploadError(int type);
    void onPlayNextRecord();
    void onLoadArmatureDataSucceed(const char *str);
	void onTakePhoto(const char *path, const char *ev);
    void onStopAudioRecorder(int isSuccess, const char *path, int seconds);
	void onBack();
	void onHttpRepose(int urlId);
	void platformInit(const char* devideId, const char*params);
    void onPushToken(int type, const char* token);
    void onPushData(int msgId, int msgType);
    void onLoginResult(const char* uId, const char* uName, const char* uSession);
    void onVideoError();
    void onVideoSucc();
    void onVideoFinish();
    void onRemuseFormBackground();
	void onEnterBackground();
    void onSwitchResult(int result);
    void onPayResult(int result);
    void onLogoutResult(int result);
    void onVoiceText(const char* txt);
    void onAppInfo(const char*params);
};

