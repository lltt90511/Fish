#ifndef __LUA_CALLBACK_H__
#define __LUA_CALLBACK_H__
#include "cocos2d.h"
#include "cocos-ext.h"
#
class LuaCallBack :public cocos2d::CCObject
{
	int							m_nScriptHandler;
	cocos2d::CCScriptEngineProtocol*		m_pScript;
public:
	static LuaCallBack* create(int _handler);
	LuaCallBack(int nHandler);
	~LuaCallBack();
	void update(float percent);
};

#endif  // __APP_DELEGATE_H__