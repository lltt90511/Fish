
#ifndef __LUA_CUERL_H_
#define __LUA_CUERL_H_

#if defined(_USRDLL)
#define LUA_EXTENSIONS_DLL     __declspec(dllexport)
#else         /* use a DLL library */
#define LUA_EXTENSIONS_DLL
#endif

#if __cplusplus
extern "C" {
#endif

#include "lauxlib.h"

	int LUA_EXTENSIONS_DLL luaopen_luacurl(lua_State *L);

#if __cplusplus
}
#endif

#endif /* __LUA_CUERL_H_ */