#pragma once
#include "cocos2d.h"
#include "Box2D\Box2D.h"
#include "cocos-ext.h"
#include "SimpleAudioEngine.h"
USING_NS_CC;
USING_NS_CC_EXT;

using namespace cocos2d::gui;
struct BallInfo{
	CCSprite * sprite;
	CCSprite * spritebg;
	float randirs;
	int id;
	bool Cotact;
	b2Contact *contact;
	BallInfo(CCSprite * sprite, CCSprite *spritebg, float randirs, int id) :sprite(sprite), spritebg(spritebg), randirs(randirs), id(id), Cotact(false){};

};
class CContact :CCObject{
public:
	b2Contact *contact;


};

class MyContactListener : public b2ContactListener
{
	//void executeScriptEvent(const char* eventName);
	int	m_nScriptHandler;
	CCScriptEngineProtocol*	 m_pScript;

public:
	MyContactListener(){
		m_nScriptHandler = 0;
		m_pScript = CCScriptEngineManager::sharedManager()->getScriptEngine();
	}
	void registerEventScript(int nHandler)
	{
		unregisterEventScript();
		m_nScriptHandler = nHandler;
		LUALOG("[LUA] Add MyContactListener event handler: %d", m_nScriptHandler);
	}

	void unregisterEventScript()
	{
		if (m_nScriptHandler)
		{
			m_pScript->removeScriptHandler(m_nScriptHandler);
			LUALOG("[LUA] Remove MyContactListener event handler: %d", m_nScriptHandler);
			m_nScriptHandler = 0;
		}
	}
	inline int getScriptHandler() { return m_nScriptHandler; };
	virtual void BeginContact(b2Contact* contact){
		if (m_nScriptHandler && m_pScript)
		{
			CContact * cc = new  CContact();
			cc->contact = contact;
			m_pScript->executeEvent(m_nScriptHandler, "", (CCObject*)cc, "CContact");
		}
		/*
		b2Body* bodyA = contact->GetFixtureA()->GetBody();
		b2Body* bodyB = contact->GetFixtureB()->GetBody();
		if (bodyA->GetUserData() && bodyB->GetUserData()){
			if (((BallInfo*)(bodyA->GetUserData()))->id == ((BallInfo*)(bodyB->GetUserData()))->id){
				CCSprite* spriteA = ((BallInfo*)(bodyA->GetUserData()))->spritebg;
				CCSprite* spriteB = ((BallInfo*)(bodyB->GetUserData()))->spritebg;
				
					spriteA->setTexture(CCTextureCache::sharedTextureCache()->addImage("ball_f/rededge.png"));
					//spriteA->setScale()
					spriteB->setTexture(CCTextureCache::sharedTextureCache()->addImage("ball_f/rededge.png"));

					((BallInfo*)(bodyA->GetUserData()))->Cotact = true;
					((BallInfo*)(bodyB->GetUserData()))->Cotact = true;
					CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("sound/sound_66.mp3");
			
					CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("sound/sound_61.mp3");

			}

		}
		else{
			CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("sound/sound_60.mp3");
		}
		*/
	}



};