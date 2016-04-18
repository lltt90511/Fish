#pragma once
#include <queue>
#include "APC.h"
#include <pthread.h>
class NetController
{
private:
	NetController(void);
	~NetController(void);
	static NetController* pInstance;
	pthread_mutex_t sockfdMutex;
	int sockfd;
    bool isConnecting;
	pthread_mutex_t sendQueueMutex;
	std::queue<APC*> sendQueue;
	pthread_t  read, write;
	


public:
	static NetController* getInstance();
    char *ip;
    int port;
    
    
	void run();
	int getSockfd();
	void setSockfd(int fd);
    bool isConnected();
	
    int getSendQueueLen();
	void pushSendQueue(APC* apc);
	APC* popSendQueue();
	void disConected();
	int connectServer(char* ip, int port);
    int connectServerAsync(char* ip, int port);
	void sendData(const char *data, int data_len, int protocol);


};

