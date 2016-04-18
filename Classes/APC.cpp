#include "APC.h"
//#include "zlib.h"
#include <cocos2d.h>
#include "lz4.h"

const char* key = "SASD!@#!@EASDASf134er23u8rdhjqwaodbfncasu8ighcf";
const int keyLength = strlen(key);
APC::APC(char protocol, char *data, int data_len) {
	this->protocol= protocol;
	this->data = new char[data_len+1];
	this->data_len = data_len;
	memcpy(this->data, data, data_len);
    this->data[data_len] = '\0';
}

APC::~APC() {
	if (data != NULL) {
		delete[] data;
	}
}


bool APC::isEncrypted() {
	return protocol & (1<<6);
}

bool APC::isCompressed() {
	return protocol & (1<<4);
}

void APC::setEncryptFlag() {
	protocol |= (1<<6);
}

void APC::setUnEncryptFlag() {
	protocol &= ~(1<<6);
}

void APC::setUnCompressFlag() {
	protocol &= ~(1<<4);
}

void APC::encrypt() {
	if (isEncrypted()) {
		return;
	}
	int i;
	for (i = 0; i < data_len; i++) {
		data[i] = data[i] ^ key[i%keyLength];
	}
	setEncryptFlag();
}

void APC::unEncrypt() {
	if (!isEncrypted()) {
		return;
	}
	int i;
	
	for (i = 0; i < data_len; i++) {
		data[i] = data[i] ^ key[i%keyLength];
	}
	setUnEncryptFlag();
}

void APC::unCompress() {
	if (!isCompressed()) {
		return;
	}
    int dest_len = *(int *)data;
	char *dest = new char[dest_len+1];
    int ret = LZ4_decompress_safe(data+4, dest, data_len-4, dest_len);
//    int ret = LZ4_decompress_fast(data+4, dest, dest_len);
    if (ret < 0) {
        CCLOG("unCompress error ret=%d",ret);
		delete[] dest;
    } else {
        if (data != NULL) {
			delete[] data;
		}
        CCLOG("data len %d, dest len %d", data_len, dest_len);
        data = dest;
		data_len = dest_len;
        data[data_len] = '\0';
    }
	setUnCompressFlag();
}

