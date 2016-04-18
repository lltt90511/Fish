#pragma once

#include <string>
class APC
{
public:
	char protocol;
	char *data;
	int data_len;

	//APC();
	APC(char protocol, char *data, int data_len);
    ~APC();
	void encrypt();
	void unEncrypt();
	void unCompress();


	bool isEncrypted();
	bool isCompressed();
private:
	void setEncryptFlag();
	void setUnEncryptFlag();
	void setUnCompressFlag();


};
