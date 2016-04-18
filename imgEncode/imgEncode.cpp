// imgEncode.cpp : 定义控制台应用程序的入口点。
//

#include "windows.h"
#include "stdafx.h"
#include <stdio.h>
#include <io.h>
#include <string>
#include <fstream>
#include <iostream>
#include <direct.h>

using namespace std;
#define KEY 123456 //密码

void Folder(string, string);
bool ecodeFile(string, string);
unsigned char* getFileData(const char*, const char*, unsigned long *);

int _tmain(int argc, _TCHAR* argv[])
{
	string a, b;
	cout << "请选择源文件目录\n";
	cin >> a;
	cout << "请选择输出目录\n";
	cin >> b;

	Folder(a, b);

	system("pause");
	return 0;
}

void Folder(string folderPath, string desPath)
{
	_finddata_t FileInfo;
	string strfind = folderPath + "\\*";
	long Handle = _findfirst(strfind.c_str(), &FileInfo);

	if (Handle == -1L)
	{
		cerr << "can not match the folder path" << endl;
		exit(-1);
	}
	_mkdir(desPath.c_str());
	do{
		//判断是否有子目录
		if (FileInfo.attrib & _A_SUBDIR)
		{
			//文件夹
			if ((strcmp(FileInfo.name, ".") != 0) && (strcmp(FileInfo.name, "..") != 0))
			{
				string newPath = folderPath + "\\" + FileInfo.name;
				string afterPath = desPath + "\\" + FileInfo.name;
				_mkdir(afterPath.c_str());
				Folder(newPath, afterPath);
			}
		}
		else
		{
			//文件
			ecodeFile(folderPath + "\\" + FileInfo.name, desPath + "\\" + FileInfo.name);
		}
	} while (_findnext(Handle, &FileInfo) == 0); _findclose(Handle);
}

bool ecodeFile(string pFileName, string desFileName)
{
	string s = pFileName.substr(pFileName.length() - 3, pFileName.length());
	if (s == "png" || s == "jpg")
	{
		unsigned long nSize = 0;
		unsigned char* pBuffer = getFileData(pFileName.c_str(), "rb", &nSize);

		unsigned char* newBuf = new unsigned char[nSize];
		int newblen = nSize;
		if (pBuffer != NULL && nSize > 0)
		{
			for (int i = 0; i < nSize; i++)
			{
				newBuf[i] = pBuffer[i] ^ KEY;
			}
			string savepath = desFileName;
			string end = pFileName.substr(pFileName.length() - 3, pFileName.length());

			errno_t err;
			FILE *fp = NULL;
			err = fopen_s(&fp, savepath.c_str(), "wb+");
			//FILE *fp = fopen(savepath.c_str(), "wb+");
			fwrite(newBuf, 1, newblen, fp);
			cout << savepath + " 加密完成\n" << endl;
			fclose(fp);
			return true;
		}
	}
	return false;
}

unsigned char* getFileData(const char* pszFileName, const char* pszMode, unsigned long * pSize)
{
	unsigned char * pBuffer = NULL;
	*pSize = 0;
	do
	{
		// read the file from hardware
		//std::string fullPath = fullPathForFilename(pszFileName);
		std::string fullPath = pszFileName;
		errno_t err;
		FILE *fp = NULL;
		err = fopen_s(&fp, fullPath.c_str(), pszMode);
		//FILE *fp = fopen(fullPath.c_str(), pszMode);
		fseek(fp, 0, SEEK_END);
		*pSize = ftell(fp);
		fseek(fp, 0, SEEK_SET);
		pBuffer = new unsigned char[*pSize];
		*pSize = fread(pBuffer, sizeof(unsigned char), *pSize, fp);
		fclose(fp);
	} while (0);

	if (!pBuffer)
	{
		std::string msg = "Get data from file(";
		msg.append(pszFileName).append(") failed!");
	}

	return pBuffer;
}