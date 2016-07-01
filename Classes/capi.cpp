#include "capi.h"
#include "NetController.h"
#include "LogicController.h"
#include "platform/CCCommon.h"
#include "lz4.h"
#include "map"
#include <curl/curl.h>
#include <platform/CCFileUtils.h>
#include <stdio.h>
#include <CCLuaEngine.h>
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#endif
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "Video/VideoPlatform.h"
//#endif
#include <cstring>
#include <cocos-ext.h>
#include "LuaCallBack.h"
#include "tolua_fix.h"
#ifndef _WIN32
#include <sys/time.h>
#endif
#ifdef _WIN32
#include <windows.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#pragma comment(lib,"Netapi32.lib")
#endif
USING_NS_CC;
typedef struct _BinaryPack {
	std::map<std::string, char*> *modMap;
} BinaryPack,*PBinaryPack;
std::string writablePath;
void setWriteAblePath(const char*  path){
	writablePath = path;
}
typedef struct _UploadData {
    char* url;
    char* path;
    int type;
    int seconds;
    char* uuid;
    //lua_State* L;
}UploadData;

typedef struct _DownloadData{
    char* url;
    char* fileName;
    char* writePath;
    int type;
    int nowIndex;
    //int callbackRef;
    //lua_State* L;
}DownloadData;
bool isUpdating = false;
static std::map<std::string, BinaryPack* > binaryPackList;

std::vector<pthread_t> uploadThreadVec(2);
std::vector<pthread_t> downloadThreadVec(3);
std::queue<UploadData> uploadQueue;
std::queue<DownloadData> downloadQueue;
pthread_mutex_t downloadMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t uploadMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t requireMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;

static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *stream) {
    size_t retcode;
    return retcode;
}

static size_t write_callback(void *buffer, size_t size, size_t count, void *stream) {
    std::string * pStream = static_cast<std::string *>(stream);
    (*pStream).append((char *)buffer, size * count);
    
    return size * count;
}

int progressFunc(void *buffer, double a, double b, double c, double d) {
    int *per = (int *)buffer;
    *per = (int)(b/a*100);
    return 0;
}

void* getFilename(const char* path)
{
    char *fullpathname = new char[strlen(path)+100];
    strcpy(fullpathname, path);
    char* save_name, *pos;
    int name_len;
    name_len = strlen(fullpathname);
    pos = fullpathname + name_len;
    int i = name_len-1;
    while(fullpathname[i] != '/' && pos != fullpathname){
        pos--;
        i--;
    }
    if(pos == fullpathname)
    {
        save_name = fullpathname+1;
        return save_name;
    }
    name_len = name_len-(pos-fullpathname);
    save_name = (char*) malloc(name_len+1);
    memcpy(save_name,pos,name_len+1);
    delete [] fullpathname;
    return save_name; 
}

void* getUUIDFromFileName(const char* fileName)
{
    char *UUID = new char[strlen(fileName)+100];
    char *name;
    strcpy(UUID,fileName);
    int i;
    for (i = 0; i < strlen(fileName); ++i) {
        if (UUID[i] == '+') {
            UUID[i] = '/';
        }
    }
    name = (char*) malloc(strlen(fileName)+1);
    memcpy(name, UUID, strlen(fileName)+1);
    delete [] UUID;
    return name;
}
#ifndef __arm64__
#define INT_PTR long int
#else
#define INT_PTR long
#endif
void *do_upload(void *datai){
    INT_PTR i = (INT_PTR)(datai);
    CCLOG("upload thread %d run\n", i);
    while (true) {
        UploadData data;
        pthread_mutex_lock(&uploadMutex);
        if (!uploadQueue.empty()) {
            data = uploadQueue.front();
            uploadQueue.pop();
            pthread_mutex_unlock(&uploadMutex);
        }else{
            pthread_mutex_unlock(&uploadMutex);
            break;
        }
        int progress_buff = 0;
        int hash[101] = {0};
        char* url = data.url;
        char* path = data.path;
        std::string fullPath = path;
        char *fileName = (char*)getFilename(fullPath.c_str());
		std::string pathToSave = writablePath;
		CCLOG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n%s %s %s %d\n", data.url, fullPath.c_str(),data.uuid, data.type);
		CCLOG("%s\n", pathToSave.c_str());
        CURL *curl;
        
        CURLM *multi_handle;
        int still_running;
        std::string write_buff;
        struct curl_httppost *formpost=NULL;
        struct curl_httppost *lastptr=NULL;
        struct curl_slist *headerlist=NULL;
        static const char buf[] = "Expect:";
        
        /* Fill in the file upload field. This makes libcurl load data from
         the given file name when curl_easy_perform() is called. */
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "file",
                     CURLFORM_FILE, fullPath.c_str(),
                     CURLFORM_END);
        
        /* Fill in the filename field */
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "filename",
                     CURLFORM_COPYCONTENTS, fullPath.c_str(),
                     CURLFORM_END);
        
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "uuid",
                     CURLFORM_COPYCONTENTS, data.uuid,
                     CURLFORM_END);
        /* Fill in the submit field too, even if this is rarely needed */
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "submit",
                     CURLFORM_COPYCONTENTS, "send",
                     CURLFORM_END);
        
        curl = curl_easy_init();
        multi_handle = curl_multi_init();
        
        /* initalize custom header list (stating that Expect: 100-continue is not
         wanted */
        headerlist = curl_slist_append(headerlist, buf);
        if(curl && multi_handle) {
            
            /* what URL that receives this POST */
            curl_easy_setopt(curl, CURLOPT_URL, url);
            curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
            curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
            
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
            curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &write_buff);
            
            curl_multi_add_handle(multi_handle, curl);
            
            curl_multi_perform(multi_handle, &still_running);
            
            do {
                struct timeval timeout;
                int rc; /* select() return code */
                
                fd_set fdread;
                fd_set fdwrite;
                fd_set fdexcep;
                int maxfd = -1;
                
                long curl_timeo = -1;
                
                FD_ZERO(&fdread);
                FD_ZERO(&fdwrite);
                FD_ZERO(&fdexcep);
                
                /* set a suitable timeout to play around with */
                timeout.tv_sec = 1;
                timeout.tv_usec = 0;
                
                curl_multi_timeout(multi_handle, &curl_timeo);
                if(curl_timeo >= 0) {
                    timeout.tv_sec = curl_timeo / 1000;
                    if(timeout.tv_sec > 1)
                        timeout.tv_sec = 1;
                    else
                        timeout.tv_usec = (curl_timeo % 1000) * 1000;
                }
                
                /* get file descriptors from the transfers */
                curl_multi_fdset(multi_handle, &fdread, &fdwrite, &fdexcep, &maxfd);
                
                /* In a real-world program you OF COURSE check the return code of the
                 function calls.  On success, the value of maxfd is guaranteed to be
                 greater or equal than -1.  We call select(maxfd + 1, ...), specially in
                 case of (maxfd == -1), we call select(0, ...), which is basically equal
                 to sleep. */
                
                rc = select(maxfd+1, &fdread, &fdwrite, &fdexcep, &timeout);
                
                switch(rc) {
                    case -1:
                        /* select error */
                        break;
                    case 0:
                    default:
                        /* timeout or readable/writable sockets */
                        //printf("perform!\n");
                        curl_multi_perform(multi_handle, &still_running);
                        //printf("running: %d!\n", still_running);
                        double upLen = 0;
                        double length = 0;
                        curl_easy_getinfo(curl, CURLINFO_CONTENT_LENGTH_UPLOAD, &length);
                        curl_easy_getinfo(curl, CURLINFO_SIZE_UPLOAD, &upLen);
                        progress_buff = int(upLen/length*100);
                        if (hash[progress_buff] == 0) {
                            LogicController::getInstance()->onProgress(data.type, -1, progress_buff);
                            hash[progress_buff] = 1;
                        }
                        if (still_running == 0) {
                            long retcode = 0;
                            long code = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &retcode);
                            if (code == CURLE_OK && retcode == 200) {
								CCLOG("upload success %s\n", write_buff.c_str());
                                LogicController::getInstance()->onUpload(data.type, fileName, write_buff.c_str(),data.seconds,length);
                            }else {
                                LogicController::getInstance()->onUploadError(data.type);
                            }
                            delete [] fileName;
                        }
                        break;
                }
            } while(still_running);
            
            curl_multi_cleanup(multi_handle);
            
            /* always cleanup */
            curl_easy_cleanup(curl);
            
            /* then cleanup the formpost chain */
            curl_formfree(formpost);
            
            /* free slist */
            curl_slist_free_all (headerlist);
			
			delete[] data.path;
			delete[] data.url;
			delete[] data.uuid;
			//delete data;
			
        }
    }
   // pthread_cancel(uploadThreadVec[i]);
#ifdef _WIN32 
	uploadThreadVec[i].p = NULL;
#else
	uploadThreadVec[i] = (pthread_t)NULL;
#endif
	CCLOG("upload thread %d cancel\n", i);
    return NULL;
}

int C_upload(lua_State* L) {
    pthread_mutex_lock(&uploadMutex);
    char* urlTmp = (char *)lua_tostring(L,1);
	char* url = new char[strlen(urlTmp) + 1];
	strcpy(url, urlTmp);
    char* path = (char *)lua_tostring(L,2);
    int type = lua_tointeger(L, 3);
    int seconds = 0;
    char* uuid = NULL;
    if (lua_gettop(L) >= 4) {
        seconds = lua_tointeger(L, 4);
    }
    if (lua_gettop(L) >= 5) {
       char * uuidTmp = (char *)lua_tostring(L, 5);
	   uuid = new char[strlen(uuidTmp) + 1];
	   strcpy(uuid, uuidTmp);
    }
	CCFileUtils *fileUtils = CCFileUtils::sharedFileUtils();
	std::string pathStr = fileUtils->fullPathForFilename(path);
	char *pathFull = new char[pathStr.length()+1];
	strcpy(pathFull, pathStr.c_str());
    UploadData data;
	data.url = url, data.path = pathFull, data.type = type, data.seconds = seconds, data.uuid = uuid;
    uploadQueue.push(data);
    pthread_mutex_unlock(&uploadMutex);
    for (int i = 0; i < uploadThreadVec.size(); ++i) {
#ifdef _WIN32 
     if (uploadThreadVec[i].p == NULL) {  
#else
		 if  (uploadThreadVec[i] == NULL) {
#endif
            pthread_create(&(uploadThreadVec[i]), NULL, do_upload,(void*)i);
            break;
        }
    }
    return 1;
}

bool createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, NULL);
    if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
    {
        return false;
    }
    return true;
#endif
}
    
bool createDirectoryBack(std::string path) {
    if (createDirectory(path.c_str()) == true) {
        return true;
    }else {
        int _index = path.find_last_of("/");
        if (createDirectoryBack(path.substr(0,_index)) == true) {
            return createDirectoryBack(path);
        }
        return false;
    }
}
    
void *do_download(void *datai) {
    INT_PTR i = (INT_PTR)(datai);
//    printf("download thread %d run\n", i);
    while (true) {
        DownloadData data;
        pthread_mutex_lock(&downloadMutex);
        if (!downloadQueue.empty()) {
            data = downloadQueue.front();
            downloadQueue.pop();
            pthread_mutex_unlock(&downloadMutex);
        }else {
            pthread_mutex_unlock(&downloadMutex);
            break;
        }
	
		char * fileName = data.fileName;
		char * writePath = data.writePath;
      //  char url[1000], fileName[1000],writePath[1000];
     //   strcpy(writePath, data.writePath);
      //  strcpy(url, data.url);
      //  strcpy(fileName,data.fileName);
        //char* fileName = data.fileName;
        char *UUID = (char*)getUUIDFromFileName(fileName);
		char * url = new char[strlen(data.url) + strlen(UUID) + 1];
		strcpy(url, data.url);
        std::string pathToSave = writablePath;
//        printf("$$$$$$$$$$$$$$$$$$$$$$$$$$\n%s %s %d\n",UUID,fileName,data.type);
        std::string content;
        int progress_buff = 0;
        int hash[101] = {0};
		char error[101] = {};
        CURL *curl = NULL;
        CURLM *multi_handle;
        int still_running;
        CURLcode code;
        code = curl_global_init(CURL_GLOBAL_DEFAULT);
        curl = curl_easy_init();
        multi_handle = curl_multi_init();
        if (curl && multi_handle) {
			strcat(url, UUID);
            code = curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, error);
            code = curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);//超时
            code = curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
            code = curl_easy_setopt(curl, CURLOPT_URL, url);
            code = curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
            code = curl_easy_setopt(curl, CURLOPT_WRITEDATA, &content);
            code = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
            code = curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
            code = curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION,progressFunc);
            code = curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &progress_buff);
			code = curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
			int ret = 0;
			ret = curl_multi_add_handle(multi_handle, curl);
			ret=0;
			while (true){
				ret = curl_multi_perform(multi_handle, &still_running);
				if (ret == CURLM_OK){
					break;
				}
			}
            do {
                struct timeval timeout;
                int rc; /* select() return code */
                
                fd_set fdread;
                fd_set fdwrite;
                fd_set fdexcep;
                int maxfd = -1;
                
                long curl_timeo = -1;
                
                FD_ZERO(&fdread);
                FD_ZERO(&fdwrite);
                FD_ZERO(&fdexcep);
                
				/* set a suitable timeout to play around with */
				timeout.tv_sec = 1;
				timeout.tv_usec = 0;

				curl_multi_timeout(multi_handle, &curl_timeo);
				if (curl_timeo >= 0) {
					timeout.tv_sec = curl_timeo / 1000;
					if (timeout.tv_sec > 1)
						timeout.tv_sec = 1;
					else
						timeout.tv_usec = (curl_timeo % 1000) * 1000;
				}

				/* get file descriptors from the transfers */
				curl_multi_fdset(multi_handle, &fdread, &fdwrite, &fdexcep, &maxfd);

				/* In a real-world program you OF COURSE check the return code of the
				function calls.  On success, the value of maxfd is guaranteed to be
				greater or equal than -1.  We call select(maxfd + 1, ...), specially in
				case of (maxfd == -1), we call select(0, ...), which is basically equal
				to sleep. */
				if (maxfd == -1){
					rc = 0;
				}
				else{
					rc = select(maxfd + 1, &fdread, &fdwrite, &fdexcep, &timeout);
				}
                switch(rc) {
                    case -1:
                        /* select error */
                        break;
                    case 0:
                    default:
                        /* timeout or readable/writable sockets */
                        //printf("perform!\n");
                        curl_multi_perform(multi_handle, &still_running);
                        //printf("################%f",progress_buff);
                        if (hash[progress_buff] == 0) {
                            LogicController::getInstance()->onProgress(data.type, data.nowIndex, progress_buff);
                            hash[progress_buff] = 1;
                        }
                        //printf("running: %d!\n", still_running);
                        if (still_running == 0) {
                            long retcode = 0;
                            code = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &retcode);
                            if (code == CURLE_OK && retcode == 200) {
                                double length = 0;
                                code = curl_easy_getinfo(curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &length);
                                //printf("retcode = %ld\n", retcode);
								
								char * fileNameTmp = new char[500];
								char* pathToSaveStr = new char[pathToSave.length() + strlen(fileName)+1];
                                strcpy(pathToSaveStr, pathToSave.c_str());
                                if (strcmp(writePath, "") == 0) {
									strcpy(fileNameTmp, fileName);
                                    strcpy(pathToSaveStr,strcat(pathToSaveStr,fileName));
                                }else {
									strcpy(fileNameTmp, writePath);
                                    strcpy(pathToSaveStr,strcat(pathToSaveStr,writePath));
                                }
                                FILE *file = fopen(pathToSaveStr, "wb+");
                                //fseek(file, 0, SEEK_SET);
                                if (file == NULL) {
                                    std::string _path = std::string(pathToSaveStr);
                                    int _index = _path.find_last_of("/");
                                    
                                    createDirectoryBack(_path.substr(0,_index));
                                    file = fopen(pathToSaveStr, "wb+");
                                }
                                if (file) {
                                    fwrite(content.c_str(),1,length,file);
                                    fclose(file);
									file = NULL;
									bool a = CCFileUtils::sharedFileUtils()->getCode();
									if ((a == false && isUpdating == true) || (a == true && isUpdating == false))
									{
										//加密
										CCFileUtils::sharedFileUtils()->encodeImage(pathToSaveStr);
									}
                                }
								LogicController::getInstance()->onDownload(data.type, fileNameTmp, data.nowIndex, length);
								delete[] fileNameTmp;
								delete[] pathToSaveStr;
//                                if (data.callbackRef > 0) {
//                                    lua_rawgeti(data.L, LUA_REGISTRYINDEX, data.callbackRef);
//                                    lua_pushstring(data.L, fileName);
//                                    lua_call(data.L, 1, 0);
//                                    luaL_unref(data.L, LUA_REGISTRYINDEX, data.callbackRef);
//                                }
                            }else {
                                LogicController::getInstance()->onDownloadError(data.type, fileName, data.nowIndex);
                            }
                            delete [] UUID;
                        }
                        break;
                }
            } while(still_running);
            curl_multi_cleanup(multi_handle);
            curl_easy_cleanup(curl);
        }
		delete[] fileName;
		delete[] url;
		delete[] writePath;
    }
    //pthread_cancel(downloadThreadVec[i]);
#ifdef _WIN32 
	downloadThreadVec[i].p = NULL;
#else
	downloadThreadVec[i] = NULL;
#endif
    
//    printf("download thread %d cancel\n", i);
    return NULL;
}

struct httpResultData{
	char* data;
	int dataLen;
	int writeLen;
};
struct httpRequest{
	int id;
	httpResultData header, body;
	char * url;
	void clean(){
		httpRequest * request = this;
		delete[]request->url;
		delete[]request->header.data;
		delete[]request->body.data;
	}
	void init(int id,char *url){
		httpRequest * request = this;
		request->id = id;
		request->url = new char[strlen(url)+1];
		strcpy(request->url, url);
		httpResultData *header = &request->header;
		httpResultData *body = &request->body;
		
		header->writeLen = 0;
		header->dataLen = 512;
		header->data = new char[header->dataLen];
		header->data[0] = 0;
		body->writeLen = 0;
		body->dataLen = 512;
		body->data = new char[body->dataLen];
		body->data[0] = 0;
	}
};
std::map<int,httpRequest*> httpRequestMap;
static size_t write_result(void *ptr, size_t size, size_t nmemb, void *stream)
{	
	httpResultData *data = (httpResultData *)stream;
	char * re = (char*)ptr;
	if (data->writeLen + size*nmemb + 1 > data->dataLen){
		
		while (data->writeLen + size*nmemb + 1 > data->dataLen)
			data->dataLen = data->dataLen * 2;
//		printf("http reset cache Size:%d\n", data->dataLen);
		char * newStr = new char[data->dataLen];
		strcpy(newStr, data->data);
		delete[] data->data;
		data->data = newStr;
	}
	for (int i = 0; i < size*nmemb; i++){
		if (re[i] != 0)
			data->data[data->writeLen++] = re[i];
	}
	data->data[data->writeLen] = 0;
	return size*nmemb;
}
void *do_require(void *data) {
	httpRequest * request = (httpRequest *)data;
	char * url = request->url;
	
	CURL *curl;
	CURLcode res;
	try{
		curl = curl_easy_init();
		if (curl) {
//			printf("url:%s\n", url);
			curl_easy_setopt(curl, CURLOPT_URL, url);
            curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
			/* example.com is redirected, so we tell libcurl to follow redirection */
			curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
			/* send all data to this function  */
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_result);
			/* we want the headers be written to this file handle */
			curl_easy_setopt(curl, CURLOPT_HEADERDATA,&request->header);

			/* we want the body be written to this file handle instead of stdout */
			curl_easy_setopt(curl, CURLOPT_WRITEDATA,& request->body);
			/* Perform the request, res will get the return code */
			res = curl_easy_perform(curl);
			/* Check for errors */
			if (res != CURLE_OK){
				//fprintf(stderr, "curl_easy_perform() failed: %s\n",
				//	curl_easy_strerror(res));
				LogicController::getInstance()->onHttpRepose(request->id);
				request->clean();
				delete request;
			}
			else{
                pthread_mutex_lock(&requireMutex);
				httpRequestMap[request->id] = request;
                pthread_mutex_unlock(&requireMutex);
				LogicController::getInstance()->onHttpRepose(request->id);
			}
			
			
			curl_easy_cleanup(curl);

		}
	}catch (...){
		
	}
	return NULL;
}
int C_getHttpRepose(lua_State* L){
	int id = lua_tointeger(L, 1);
    pthread_mutex_lock(&requireMutex);
	httpRequest * req = httpRequestMap[id];
    pthread_mutex_unlock(&requireMutex);
	if (req == NULL){
		lua_pushinteger(L, -1);
		return 1;
	}
	else{
		lua_pushinteger(L, 0);
		lua_pushstring(L, req->header.data);
		lua_pushstring(L, req->body.data);
		req->clean();
		delete req;
        pthread_mutex_lock(&requireMutex);
		httpRequestMap[id] = NULL;
        pthread_mutex_unlock(&requireMutex);
		return 3;
	}
	
}
int C_http(lua_State* L) {
	int urlId  = lua_tointeger(L, 1);
	char* url = (char *)lua_tostring(L, 2);
	httpRequest * request = new httpRequest();
	request->init(urlId,url);
	pthread_t thread;
	pthread_create(&thread, NULL, do_require, request);
	return 1;
}
int C_download(lua_State* L) {
    pthread_mutex_lock(&downloadMutex);
    
    const char* urlTmp = tolua_tostring(L, 1, 0);
    char* url = new char[strlen(urlTmp) + 1];
    strcpy(url, urlTmp);
    url[strlen(urlTmp)] = 0;
    
    const char* fileNameTmp = tolua_tostring(L, 2, 0);
    char* fileName = new char[strlen(fileNameTmp) + 1];
    strcpy(fileName, fileNameTmp);
    fileName[strlen(fileNameTmp)] = 0;
    
    //char* url = (char *)lua_tostring(L,1);
    //char* fileName = (char *)lua_tostring(L, 2);
    int type = lua_tointeger(L, 3);
    int nowIndex = lua_tointeger(L, 4);
    //char* writePath = (char *)lua_tostring(L, 5);
    
    const char* writePathTmp = tolua_tostring(L, 5, 0);
    char* writePath = new char[strlen(writePathTmp) + 1];
    strcpy(writePath, writePathTmp);
    writePath[strlen(writePathTmp)] = 0;
    
    DownloadData data  ;
	data.url = url, data.type = type, data.nowIndex = nowIndex, data.writePath = writePath ,data.fileName = fileName;
    //strcpy(data.fileName, fileName);
    //delete [] fileName;
    downloadQueue.push(data);
    pthread_mutex_unlock(&downloadMutex);
    for (int i = 0; i < downloadThreadVec.size(); ++i){
#ifdef _WIN32 
		if (downloadThreadVec[i].p == NULL) {
#else
		if (downloadThreadVec[i] == NULL) {
#endif
        
            pthread_create(&(downloadThreadVec[i]), NULL, do_download, (void*)i);
            break;
        }
    }
    return 1;
}

int C_rename(lua_State* L) {
    char* oldName = (char*)lua_tostring(L,1);
    char* newName = (char*)lua_tostring(L,2);
    //return rename(oldName,newName);
    
    unsigned long nSize = 0;
    unsigned char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(oldName, "rb", &nSize);
    
    FILE *file = fopen(newName, "wb+");
    if (file == NULL) {
        std::string _path = std::string(newName);
        int _index = _path.find_last_of("/");
        createDirectoryBack(_path.substr(0,_index));
        file = fopen(newName, "wb+");
    }
    if (file) {
        fwrite(pBuffer, 1, nSize, file);
        fclose(file);
        file = NULL;
    }
    
    remove(oldName);
    
    return 1;
}

int C_connect(lua_State* L) {
	char* ipTmp = (char *)lua_tostring(L,1);
	char * ip = new char[strlen(ipTmp) + 1];
	strcpy(ip, ipTmp);
	int port = lua_tointeger(L,2);
	int sockId = NetController::getInstance()->connectServer(ip, port);
    lua_pushinteger(L, sockId);
	return 1;
}

int C_connectAsync(lua_State* L) {
	char* ipTmp = (char *)lua_tostring(L, 1);
	char * ip = new char[strlen(ipTmp) + 1];
	strcpy(ip, ipTmp);
    int port = lua_tointeger(L, 2);
    NetController::getInstance()->connectServerAsync(ip, port);
    return 0;
}

int C_senddata(lua_State* L) {
	size_t data_len;
	const char *json_str = lua_tolstring(L,1,&data_len);
	//)]
	int protocol = lua_tointeger(L, 2);
	NetController::getInstance()->sendData(json_str,data_len,protocol);
	return 0;

}
int C_close(lua_State* L) {
	NetController::getInstance()->disConected();
	return 0;
}

int C_doTick(lua_State* L) {
	LogicController::getInstance()->doTick();
	return 0;
}

int C_LoadBinaryPack(lua_State* L)
{
	CCLog( "C_LoadBinaryPack start");
	//LOG(ERROR) << "C_LoadBinaryPack start";
	if(!lua_isstring(L,1)){
		CCLog( "C_LoadBinaryPack need packName as string");
		return 0;
	}

	const char* fileName = lua_tostring(L, 1);

	FILE *in = fopen(fileName, "r");

	if (in == NULL) {
		CCLog( "C_LoadBinaryPack can not open %s", fileName);
		return 0;
	}

	std::string packName = std::string(fileName);
	char *source = (char *)malloc(4 * 1024 * 1024);

	int readed = 0;
	int inputSize = 0;

	while(1) {
		readed = fread(source+inputSize, 1, 1024, in);
		if (readed <= 0) {
			break;
			fclose(in);
		} else {
			inputSize = inputSize + readed;
		}
	}

	//char a[4] = {0};
	int i;
	int origLen = 0;
	for (i = 0; i < 4; i++) {
		origLen = (origLen << 8) + (unsigned char)(source[i]);
	}
	
	//for ()
	//int origLen = atoi(a);
	CCLog( "orig len: %d", origLen);
	char *dest = (char *)malloc(origLen);

	int ret = LZ4_decompress_safe ((const char *)source+4, dest, inputSize-4, origLen);

	if (ret < 0 ) {
		CCLog( "C_LoadBinaryPack error! LZ4_decompress_safe error! ret=%d", ret);
	}
	BinaryPack* pBinaryPack = NULL;
	pBinaryPack = binaryPackList[packName];
	if (pBinaryPack != NULL) {
		std::map<std::string, char*>::iterator idx;
		for (idx = pBinaryPack->modMap->begin(); idx != pBinaryPack->modMap->end(); idx ++) {
			free(idx->second);
		}
		pBinaryPack->modMap->clear();
	} else {
		pBinaryPack = (BinaryPack*)malloc(sizeof(BinaryPack));
		pBinaryPack->modMap = new std::map<std::string, char*>;
		CCLog( "BinaryPack len:%ld", sizeof(BinaryPack));
		binaryPackList[packName] = pBinaryPack;
	}



	readed = 0;
	int headLen = 0;
	int contentLen = 0;

	while(1) {
		headLen = 0;
		contentLen = 0;
		headLen = (unsigned char)dest[readed];
		readed ++;
		for (i = 0; i < 4; i++) {
			contentLen = (contentLen << 8) + (unsigned char)dest[readed];
			readed ++;
		}
		CCLog( "headLen: %d contentLen: %d", headLen, contentLen);
		char *name = (char *)malloc(headLen + 1);
		char *content = (char *)malloc(contentLen + 1);
		memset(name, 0, headLen+1);
		memset(content, 0, contentLen+1);
		for (i = 0; i < headLen; i++) {
			name[i] = dest[readed];
			readed ++;
		}
		name[i] = '\0';
		CCLog(  "name: %s" ,name); 
		for (i = 0; i < contentLen; i++) {
			content[i] = dest[readed];
			readed ++;
		}
		content[i] = '\0';
		std::string sname = std::string(name);
		pBinaryPack->modMap->insert(make_pair(sname,content));


		if (readed >= origLen) {
			
			break;
		}
		
	}


	free(source);
	free(dest);
	CCLog( "C_LoadBinaryPack %s finished", packName.c_str());
	

	return 0;
}

int C_CustomModuleLoader(lua_State* L)
{
	if (!lua_isstring(L, 1)) {
		CCLog("C_CustomModuleLoader error, arg type error!");
		return 0;
	}
	const char * name =  lua_tostring(L,1);

	std::string moduleName = std::string(name);
	char * fileContent = NULL;;

	std::map<std::string,BinaryPack*>::iterator idx =  binaryPackList.begin();
	for(;idx != binaryPackList.end();idx++)
	{
		fileContent = idx->second->modMap->find(moduleName)->second;
		if(fileContent != NULL)
		{
			idx->second->modMap->erase(moduleName);
			luaL_loadbuffer(L,fileContent,strlen(fileContent),name);
			return 1;
		}
	}

	luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
		lua_tostring(L, 1), name, lua_tostring(L, -1));
	return 0;
}

int C_CustomMonduleLoaderForZip(lua_State* L){
	if (!lua_isstring(L, 1)) {
		CCLog("C_CustomModuleLoader error, arg type error!");
		return 0;
	}
	const char * name = lua_tostring(L, 1);

	std::string moduleName = std::string(name);
	std::string moduleFile = moduleName;
	for (int i = 0; i<moduleFile.size(); i++){
		if (moduleFile.at(i) == '.'){
			moduleFile.replace(i,1, "/");
		}
	}
	
	unsigned long size = 0;
	unsigned char * fileContent = CCFileUtils::sharedFileUtils()->getFileData((moduleFile + ".lua").c_str(), "r", &size);;
	if (size > 0){
		luaL_loadbuffer(L, (char*)fileContent, size, name);
		delete[] fileContent;
		return 1;
	}
		
	luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
		lua_tostring(L, 1), name, lua_tostring(L, -1));
	return 0;
}

int C_log(lua_State* L)
{
	if (!lua_isstring(L, 1)) {
		CCLog("C_log error, arg type error!");
		return 0;
	}
	const char * msg = lua_tostring(L,1);
	//char* msg2 = new char[msg2]
	CCLog("%s",msg);
	return 0;
}
char * platform[] = {
    "",
	"Windows",
	"IOS",
	"Android",
    "MAC"
};
int C_platform(lua_State* L){
	int p = 0;
#ifdef __APPLE__
    p=4;
#endif
#ifdef _WIN32
	p = 1;
#endif // _WIN32
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	p = 2;
#endif

#ifdef linux
	p = 3;
#endif
	lua_pushstring(L, platform[p]);
	return 1;
}
#ifdef _WIN32
long long getSystemTime() {
	DWORD start, stop;
	start = GetTickCount();
	return start;
}
#else
#include <sys/timeb.h>
long long getSystemTime() {
	struct timeb t;
	ftime(&t);
	return 1000 * t.time + t.millitm;
}
#endif
int C_CLOCK(lua_State* L){
	
	lua_pushnumber(L, getSystemTime ()/ 1000.0);
	return 1;
}

int C_LoadAnimAsync(lua_State* tolua_S){

	const char* fileTmp = tolua_tostring(tolua_S, 1, 0);
	char* file = new char[strlen(fileTmp) + 1];
	strcpy(file, fileTmp);
	file[strlen(fileTmp)] = 0;
	int nHandler = toluafix_ref_function(tolua_S, 2, 0);
	LuaCallBack* self = new LuaCallBack(nHandler);
	cocos2d::extension::CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfoAsync(file, self, schedule_selector(LuaCallBack::update));
	//int nID = (self) ? (int)self->m_uID : -1;
	//int* pLuaID = (self) ? &self->m_nLuaID : NULL;
	//toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)self, "LuaCallBack");

	return 1;
}
const char * encryptKey = "xsdsdasd#@$dsadas1231243dzxcasd123!";
int keyLen = strlen(encryptKey);
int C_unEncryptString(lua_State * tolua_S){
	const char* str = tolua_tostring(tolua_S, 1, 0);
	int  len = strlen(str);
	int  current = 0;
	char * ret = new char[len + 1 ];
	int currentWrite = 0;
	while (current < len){
		unsigned char c1,c2,c3,c4;
		c1 = str[current++] ^ encryptKey[0 % keyLen];
		c2 = str[current++] ^ encryptKey[1 % keyLen];
		c3 = str[current++] ^ encryptKey[2 % keyLen];
		c4 = str[current++] ^ encryptKey[3 % keyLen];
		
		int currentLen = 0;
		if (c1 != ' '){
			currentLen += (c1 - '0') * 1000;
		}
		if (c2 != ' '){
			currentLen += (c2 - '0') * 100;
		}
		if (c3 != ' '){
			currentLen += (c3 - '0') * 10;
		}
		if (c4 != ' '){
			currentLen += (c4 - '0') * 1;
		}
		bool flag = true;
		if (currentLen > 9999)break;
		for (int i = 0; i < currentLen; i++){
			char c = str[current++];
			if (c == 20){
				if (flag){
					//printf("%s  %d %d %d\n", ret,currentWrite,i,keyLen);
					flag = false;
				}
				c = str[current++] - 20;
			}
			ret[currentWrite++] = c ^ encryptKey[(i + 4) % keyLen];
			ret[currentWrite] = 0;
		}
		//printf("%s\n", ret);
		//current += 2;// 删除两个控制位?
		//current += currentLen + 4;
	}
	ret[currentWrite] = 0;
	lua_pushstring(tolua_S, ret);
	//delete ret;
	return 1;
}
int C_encryptString(lua_State * tolua_S){
	const char* str = tolua_tostring(tolua_S, 1, 0);
	//int  num = (int)tolua_tonumber(tolua_S, 2, 0);
	int  len = strlen(str);
	char * ret = new char[len*2 + 1 + 4];//前四个个字节是长度
	char lengthChar[6] = {0};
	sprintf(ret, "%4d", len);
	int current = 0; // 预留4位
	for (int i = 0; i < 4; i++){
		ret[current++] = ret[i] ^ encryptKey[(i) % keyLen];
	}
	
	for (int i = 0; i < len; i++){
		char c = str[i] ^ encryptKey[(i + 4) % keyLen];
		if (c >=0 && c <= 20){
			ret[current++] = 20;
			ret[current++] = c+20;
		}else{
			ret[current++] = c;
		}
	}
	ret[current] = 0;
	lua_pushstring(tolua_S, ret);
	delete ret;
	return  1;
}
int C_IsImageEncoded(lua_State* L)
{
	int code = lua_tointeger(L, 1);
	CCLog("code%d", code);
	if (code == 0)
	{
		CCFileUtils::sharedFileUtils()->setCode(false);
	}
	else if (code == 1)
	{
		CCFileUtils::sharedFileUtils()->setCode(true);
	}
	return 0;
}
    
int C_IsUpdating(lua_State* L)
{
    int code = lua_tointeger(L, 1);
    if (code > 0) {
        isUpdating = true;
    }else {
        isUpdating = false;
    }
    return 0;
}

int C_CopyAndEncodeImage(lua_State* L)
{
	char* urlTmp = (char*)lua_tostring(L, 1);
	char* url = new char[strlen(urlTmp) + 1];
	strcpy(url, urlTmp);
    unsigned long nSize = 0;
    unsigned char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(url, "rb", &nSize);
    std::string _path = std::string(url);
    int _index = _path.find_last_of("//");
    std::string folderName = _path.substr(0, _index);
    char* path = (char*)folderName.append("/copy_image.jpg").c_str();
    FILE *file = fopen(path, "wb+");
    fwrite(pBuffer, 1, nSize, file);
    fclose(file);
    file = NULL;
    if (CCFileUtils::sharedFileUtils()->getCode()) {
        CCFileUtils::sharedFileUtils()->encodeImage(path);
    }
    return 0;
}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
int C_playVideo(lua_State* L)
{
    char* url = (char*)lua_tostring(L,1);
    VideoPlatform::playURLVideo(url);
    return 0;
}
int C_stopVideo(lua_State* L)
{
    VideoPlatform::stopVideo();
	VideoPlatform::playurl = "";
    return 0;
}
int C_hideVideo(lua_State* L)
{
    VideoPlatform::hiddenVideo();
    return 0;
}
#endif
int C_ImageToEncode(lua_State* L)
{
	char *pathTmp = (char *) lua_tostring(L, 1);
	char *path = new char[strlen(pathTmp)+1];
	strcpy(path, pathTmp);
    if (CCFileUtils::sharedFileUtils()->getCode()) {
        CCFileUtils::sharedFileUtils()->encodeImage(path);
    }
	return 0;
}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
typedef struct _ASTAT_
{
	ADAPTER_STATUS adapt;
	NAME_BUFFER    NameBuff[30];
}ASTAT, *PASTAT;

ASTAT Adapter;
int C_getMACAddress(lua_State* L)
{
	NCB Ncb;
	UCHAR uRetCode;
	char NetName[50];
	LANA_ENUM   lenum;
	int      i;

	memset(&Ncb, 0, sizeof(Ncb));
	Ncb.ncb_command = NCBENUM;
	Ncb.ncb_buffer = (UCHAR *)&lenum;
	Ncb.ncb_length = sizeof(lenum);
	uRetCode = Netbios(&Ncb);
	//printf("The NCBENUM return code is: 0x%x \n", uRetCode);
	lua_newtable(L);
#ifdef _DEBUG 
	lua_pushnumber(L, 122335);
#else
	lua_pushnumber(L, -1);
#endif
	lua_rawseti(L, -2, 0);
	int s = 0;
	for (i = 0; i < lenum.length; i++)
	{
		memset(&Ncb, 0, sizeof(Ncb));
		Ncb.ncb_command = NCBRESET;
		Ncb.ncb_lana_num = lenum.lana[i];

		uRetCode = Netbios(&Ncb);

		memset(&Ncb, 0, sizeof (Ncb));
		Ncb.ncb_command = NCBASTAT;
		Ncb.ncb_lana_num = lenum.lana[i];

		strcpy((char*)Ncb.ncb_callname, "*               ");
		Ncb.ncb_buffer = (unsigned char *)&Adapter;
		Ncb.ncb_length = sizeof(Adapter);

		uRetCode = Netbios(&Ncb);
		
		if (uRetCode == 0)
		{
			char mac[200] = { 0 };
			sprintf(mac,"%02x%02x%02x%02x%02x%02x",
				Adapter.adapt.adapter_address[0],
				Adapter.adapt.adapter_address[1],
				Adapter.adapt.adapter_address[2],
				Adapter.adapt.adapter_address[3],
				Adapter.adapt.adapter_address[4],
				Adapter.adapt.adapter_address[5]);
			//lua_pushnumber(L,)
			lua_pushstring(L, mac);
			lua_rawseti(L, -2, s + 1);
			s++;
		}
	}
	return 1;
}
#else
int C_getMACAddress(lua_State* L)
{
	lua_pushstring(L,"");
	return 1;
}

#endif
int C_getDPI(lua_State* L){
	int  width = 0;
		
		int  height = 0;
#ifdef WIN32
		width  = GetSystemMetrics(SM_CXSCREEN);
		height = GetSystemMetrics(SM_CYSCREEN);
#endif
		lua_pushinteger(L, width * 100000 + height);
		return 1;
}
    int C_exit(lua_State* L){
        exit(0);
    }
void registerAPI(lua_State* L)
{
	lua_register(L,"C_connect",		C_connect);
    lua_register(L, "C_connectAsync", C_connectAsync);
	lua_register(L,"C_senddata",	C_senddata);
	lua_register(L,"C_close",		C_close);
	lua_register(L,"C_doTick",		C_doTick);
	lua_register(L,"C_LoadBinaryPack",		C_LoadBinaryPack);
	lua_register(L,"C_CustomModuleLoader",		C_CustomModuleLoader);
	lua_register(L,"C_log",		C_log);
	lua_register(L, "C_platform", C_platform);
    lua_register(L, "C_upload", C_upload);
    lua_register(L, "C_download", C_download);
    lua_register(L, "C_rename", C_rename);
	lua_register(L, "C_CLOCK", C_CLOCK);
	lua_register(L, "C_LoadAnimAsync", C_LoadAnimAsync);
	lua_register(L, "C_encryptString", C_encryptString);
	lua_register(L, "C_unEncryptString", C_unEncryptString);
	lua_register(L, "C_http", C_http);
	lua_register(L, "C_getHttpRepose", C_getHttpRepose);
	lua_register(L, "C_IsImageEncoded", C_IsImageEncoded);
    lua_register(L, "C_IsUpdating", C_IsUpdating);
	lua_register(L, "C_ImageToEncode", C_ImageToEncode);
    lua_register(L, "C_CopyAndEncodeImage", C_CopyAndEncodeImage);
	lua_register(L, "C_getMACAddress", C_getMACAddress);
	lua_register(L, "C_getDPI", C_getDPI);
    lua_register(L, "C_exit", C_exit);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    lua_register(L, "C_playVideo", C_playVideo);
    lua_register(L, "C_stopVideo", C_stopVideo);
    lua_register(L, "C_hideVideo", C_hideVideo);
#endif

#ifdef WIN32 
#ifndef _DEBUG 
	CCLuaEngine::defaultEngine()->getLuaStack()->addLuaLoader(C_CustomMonduleLoaderForZip);
#endif
#endif
}