#pragma once

extern "C" {
#include "lualib.h"
#include "lauxlib.h"
#include "lua.h"
//#include "tolua_fix.h"
}

void setWriteAblePath(const char * path);

void registerAPI(lua_State* L);