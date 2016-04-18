#ifndef __LUABALL_H_
#define __LUABALL_H_
#include "../MyContactListener.h"
#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int tolua_MyContactListener_open(lua_State* tolua_S);

#endif // __LUACOCOS2D_H_
