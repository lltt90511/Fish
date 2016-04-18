#include "LuaCallBack.h"


LuaCallBack::LuaCallBack(int _handler)
{
	m_nScriptHandler = _handler;
	m_pScript = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
}

LuaCallBack* LuaCallBack::create(int _handler)
{
	LuaCallBack* call = new LuaCallBack(_handler);
	call->autorelease();
	return call;

}
LuaCallBack::~LuaCallBack()
{
	if (m_nScriptHandler){
		m_pScript->removeScriptHandler(m_nScriptHandler);
	}
}
void LuaCallBack::update(float percent){
	//double p = percent;
	//char a[40] = {0};  
	//sprintf(a, "%.5f", &percent);
	m_pScript->executeEvent(m_nScriptHandler,NULL, this, "CCObject");
}