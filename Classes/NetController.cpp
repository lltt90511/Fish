#include "NetController.h"
#include "LogicController.h"
#include "cocos2d.h"
#include "APC.h"
#ifdef WIN32
#include "windows.h"
typedef int socklen_t;  
typedef int ssize_t;  
#define ioctl(a,b,c) (ioctlsocket(a,b,c));
#include <winsock2.h>
#pragma comment(lib,"ws2_32.lib")
#else
typedef int SOCKET;  
typedef unsigned char BYTE;  
typedef unsigned long DWORD;
#include "unistd.h"
#include "netinet/in.h"
#include <netdb.h>
#include "sys/socket.h"
#include "sys/ioctl.h"
#include "arpa/inet.h"
#include <errno.h>
#endif

USING_NS_CC;
NetController* NetController::pInstance = NULL;

NetController::NetController(void){
	this->sockfdMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
	this->sendQueueMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
	setSockfd(-1);
}


NetController::~NetController(void){
}

NetController* NetController::getInstance() {
	if (pInstance == NULL) {
		pInstance = new NetController();
	}
	return pInstance;
}



void *do_receive(void *data){
	NetController* controller = (NetController*)data;
	int readed = 0;
	int nread =0;
	int buffSize = 256*1024;
	char *revBuff = new char[buffSize];
	int apcLenth = 0;
	APC *apc = NULL;

	while(true) {
		int fd = controller->getSockfd();
		if (fd == -1){
			#ifdef WIN32
				Sleep(20);
			#else
				usleep(20000);
			#endif
			continue;
		} 

		nread = recv(fd, revBuff+readed, buffSize-readed, 0);
		if (nread <= 0) {
            CCLog("disconnected %d", fd);
            controller->disConected();
            continue;
            
		}
        CCLOG("recv %d", nread);
		readed += nread;

        while (true) {
            if (readed < 4) {
                break;
            }
            
            if (apcLenth == 0) {
                for (int i = 3; i >= 0; i--) {
                    apcLenth = (apcLenth << 8) + (unsigned char)(*(revBuff+i));
                    if (apcLenth > buffSize ) {
                        CCLog("data too large len=%d, i=%d", apcLenth, i);
                        CCAssert(true, "protocal error");
                        break;
                    }
				    CCLOG("data len %d,%d", apcLenth,i);
				}

                CCLOG("data len %d,%d", apcLenth,readed);
            }
			//apcLenth--;
            int left = readed - 4 - apcLenth;
            if (left >= 0) {
				//char protocol = revBuff[4];
				apc = new APC(1 << 6, revBuff+4, apcLenth);
				/*if (protocol & 0x01){
					apc->unEncrypt();
				}*/
				
                LogicController::getInstance()->pushRpcQueue(apc);
                if (left > 0) { // 处理粘包
                    CCLOG("left %d", left);
                    for (int k=0; k < left; k++) {
                        revBuff[k] = revBuff[readed-left+k];
                    }
                }
                apcLenth = 0;
                readed = left;
            } else {
                // 没有收完 do nothing just continue recv
                break;
            }
            
            
        }

    


	}


}

void *do_send(void *data){
	NetController* controller = (NetController*)data;
	while(true) {
        int fd = controller->getSockfd();
        if (fd == -1) {
            #ifdef WIN32
                Sleep(20);
            #else
                usleep(20000);
            #endif
			continue;
        }
        
		APC *apc = controller->popSendQueue();
		if (apc == NULL) {
			#ifdef WIN32
				Sleep(20);
			#else
				usleep(20000);
			#endif
			continue;
		}
        
		{
			//apc->encrypt();
			int dataLen = apc->data_len;
			char *sendBuf = new char[dataLen+4];
			for(int i=0; i<4; i++) {
				sendBuf[i] = (BYTE)(dataLen % (1<<8));
				dataLen = dataLen >> 8;
			}
			//sendBuf[0] = dataLen;
			int protocol = 0;
			if (apc->isEncrypted()){
				protocol = protocol | 0x1;
			}
			// 确定是否压缩 然后确定压缩方法
			/*
			if (apc->isCompressed()){
				protocol = protocol | 0x2;
			}*/
			//sendBuf[4] = protocol;//协议字段
			memcpy(sendBuf+4, apc->data, apc->data_len);
            
            CCLOG("send: %s %d,", apc->data, apc->data_len);
			int sended = 0;
			while(sended < apc->data_len + 4) {
				int num = send(fd, sendBuf, apc->data_len + 4 - sended, 0);
				if (num < 0) {
					controller->disConected();
					break;
				} else {
					sended += num;
				}
			}
			delete[] sendBuf;
		
		}

		delete apc;


	}
}

void NetController::run() {
	//pthread_t thread1,thread2;
	pthread_create(&read, NULL, do_receive, this);
	pthread_create(&write, NULL, do_send, this);
	//pthread_cancel(thread1);
}

void NetController::disConected() {
    if (isConnected()) {
		//pthread_cancel(read);
		//pthread_cancel(write);
#ifdef _WIN32

		shutdown(this->sockfd, SD_BOTH);
#else
		shutdown(this->sockfd, SHUT_RDWR);
#endif
        LogicController::getInstance()->onClose(this->sockfd);
        this->setSockfd(-1);
		//pthread_create(&read, NULL, do_receive, this);
    }
    
}

int NetController::getSockfd() {
	int ret = 0;
	pthread_mutex_lock(&this->sockfdMutex);
	ret = this->sockfd;
	pthread_mutex_unlock(&this->sockfdMutex);
	return ret;
}

void NetController::setSockfd(int fd) {
	pthread_mutex_lock(&this->sockfdMutex);
	this->sockfd = fd;
    this->isConnecting = false;
	pthread_mutex_unlock(&this->sockfdMutex);
}

bool NetController::isConnected() {
    return this->sockfd > -1;
}



int NetController::getSendQueueLen() {
    int ret = 0;
    pthread_mutex_lock(&this->sendQueueMutex);
    ret = this->sendQueue.size();
	pthread_mutex_unlock(&this->sendQueueMutex);
    return ret;
}

void NetController::pushSendQueue(APC* apc) {
	pthread_mutex_lock(&this->sendQueueMutex);
	this->sendQueue.push(apc);
	pthread_mutex_unlock(&this->sendQueueMutex);
}



APC* NetController::popSendQueue() {
	APC *apc = NULL;
	pthread_mutex_lock(&this->sendQueueMutex);
	if (!this->sendQueue.empty()) {
		apc = this->sendQueue.front();
		this->sendQueue.pop();
	}
	pthread_mutex_unlock(&this->sendQueueMutex);
	return apc;
}
void *do_connect(void *data) {
    NetController* controller = (NetController*)data;
    controller->connectServer(controller->ip, controller->port);
    return NULL;
}


//它实现一个超时时间为timeout秒的connect函数，在指定时间内返回0表示连接成功，返回-1则表示连接失败或者连接超时
int timeConnect( SOCKET sockfd, const struct sockaddr *addr, socklen_t addrlen, int timeout)
{
    DWORD no = 0, yes = 1;
    int disconnected, fd_num;
    struct timeval select_timeval;
    fd_set readfds, writefds;
    if (sockfd < 0 || NULL == addr || addrlen <= 0 || timeout < 0) return -1;
    //Set Non-blocking
	ioctl(sockfd, FIONBIO, &yes);
	//if (ioctl(sockfd, FIONBIO, &yes) < 0)
 //   {
 //       printf("ioctl: %s [%s:%d]\n", strerror(errno), __FILE__, __LINE__);
 //       return -1;
 //   }
    //CCLog("connect to %s success", ip);
    
    disconnected = connect(sockfd, addr, addrlen);
    if (disconnected)
    {

        if(errno != EINPROGRESS)
        {
			ioctl(sockfd, FIONBIO, &no);
            return -1;
        }
        else
        {
            select_timeval.tv_sec = timeout;
            select_timeval.tv_usec = 0;
            //FD_ZERO(&readfds);
            FD_ZERO(&writefds);
            //FD_SET(sockfd,&readfds);
            //writefds = readfds;
            FD_SET(sockfd,&writefds);
            fd_num = select(sockfd+1,NULL,&writefds,NULL,&select_timeval);
            if(fd_num < 0)
            {
                printf( "select: %s [%s:%d]\n", strerror(errno), __FILE__, __LINE__);
                ioctl(sockfd, FIONBIO, &no);
                return -1;
            } else if(0 == fd_num) {
                printf("connect time out\n");
                ioctl(sockfd, FIONBIO, &no);
                return -1;
            }
                if ( FD_ISSET(sockfd,&writefds)  )
                {
                    int error=0;
                    socklen_t len=sizeof(error);
#ifndef _WIN32
                    int ret = getsockopt(sockfd,SOL_SOCKET,SO_ERROR,&error,&len);
                    if(  ret <0)
                        return -1;
                    if (error!=0)
                        return -1;
#endif
                }
            
        }
    }
    ioctl(sockfd, FIONBIO, &no);
    return 0;
}



int NetController::connectServerAsync (char* ip, int port) {
	if (isConnected()) {
        return 0;
    }
    this->isConnecting = true;
    pthread_t thread;
    this->ip = ip;
    this->port = port;
    pthread_create(&thread, NULL, do_connect, this);
    return 0;
}

int NetController::connectServer(char* ip, int port) {
    if (isConnected()) {
        return -1;
    }
//#ifdef WIN32
//	 WSADATA  Ws;
//     //Init Windows Socket
//     if ( WSAStartup(MAKEWORD(2,2), &Ws) != 0 )
//     {
//         std::cout<<"Init Windows Socket Failed::"<<GetLastError()<<std::endl;
//         return -1;
//     }
//#endif
//	int sockfd;
//    
//    struct sockaddr_in servaddr;
//    
//    sockfd = socket(AF_INET, SOCK_STREAM, 0);
//
//	if (sockfd == -1){
//		CCLog("Error In Open Socket Connect LastError : %s", strerror(errno));
//		return sockfd;
//	}
//    
//    //bzero(&servaddr, sizeof(servaddr));
//	
//	memset(&servaddr, 0, sizeof(servaddr));
//    
//    servaddr.sin_family = AF_INET;
//    
//    servaddr.sin_port = htons(port);
//    
//#ifdef WIN32
//	servaddr.sin_addr.s_addr = inet_addr(ip);
//#else
//    inet_pton(AF_INET, ip, &servaddr.sin_addr);
//#endif
//    
//	CCLog("now, begin to connect to %s %d %d", ip, port, sockfd);
//    int timeout = 5;
//#ifdef WIN32
//	int ret = connect(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr));
//#else
//    int ret = timeConnect(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr), timeout);
//#endif
//	
//	if (ret == 0) {
//		this->setSockfd(sockfd);
//        CCLog("connect to %s success", ip);
//    }else{
//        this->setSockfd(-1);
//		CCLog("connect to %s faild", ip);
//    }
//
//    LogicController::getInstance()->onConnect(ret);
//    
//    return sockfd;
    
//    uint8_t ipv4[4] = {120,27,156,196};
    struct addrinfo hints, *res, *res0;
    int error, s;
    const char *cause = NULL;
    
//    char ipv4_str_buf[INET_ADDRSTRLEN] = { 0 };
//    const char *ipv4_str = inet_ntop(AF_INET, &ipv4, ipv4_str_buf, sizeof(ipv4_str_buf));
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_DEFAULT;
    error = getaddrinfo(ip, "51111", &hints, &res0);
    if (error) {
        /*NOTREACHED*/
    }
    s = -1;
    for (res = res0; res; res = res->ai_next) {
        s = socket(res->ai_family, res->ai_socktype,
                   res->ai_protocol);
        if (s < 0) {
            cause = "socket";
            continue;
        }
        
        if (connect(s, res->ai_addr, res->ai_addrlen) < 0) {
            cause = "connect";
            close(s);
            s = -1;
            continue;
        }
        
        break;  /* okay we got one */
    }
    if (s < 0) {
        /*NOTREACHED*/
    }
    freeaddrinfo(res0);
    
    int ret = timeConnect(s, (const struct sockaddr *)&res0, sizeof(res0), 5);
    if (ret == 0) {
        this->setSockfd(s);
        CCLog("connect to %s success", ip);
    }else{
        this->setSockfd(-1);
        CCLog("connect to %s faild", ip);
    }
    
    return s;
}
void NetController::sendData(const char *data, int data_len, int protocol) {
    if (!isConnected() && getSendQueueLen() >= 1) {
        CCLOG("not connected and abort send this msg");
        return;
    }
	APC *apc = new APC((char)0, (char *)data, data_len);
	if (protocol&0x1 == 1){//加密
		apc->encrypt();
	}
	this->pushSendQueue(apc);
}


