/*
** Lua binding: MyContactListener
** Generated automatically by tolua++-1.0.92 on 01/14/14 19:41:04.
*/

#include "LuaBall.h"
#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"
extern "C" {
#include "tolua_fix.h"
}

typedef int LUA_FUNCTION;
/* Exported function */
TOLUA_API int  tolua_MyContactListener_open (lua_State* tolua_S);


/* function to release collected object via destructor */
#ifdef __cplusplus

static int tolua_collect_LUA_FUNCTION (lua_State* tolua_S)
{
 LUA_FUNCTION* self = (LUA_FUNCTION*) tolua_tousertype(tolua_S,1,0);
	Mtolua_delete(self);
	return 0;
}

static int tolua_collect_MyContactListener (lua_State* tolua_S)
{
 MyContactListener* self = (MyContactListener*) tolua_tousertype(tolua_S,1,0);
	Mtolua_delete(self);
	return 0;
}
#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"MyContactListener");
 tolua_usertype(tolua_S,"b2ContactListener");
 tolua_usertype(tolua_S,"LUA_FUNCTION");
 tolua_usertype(tolua_S,"CCObject");
 tolua_usertype(tolua_S,"b2Contact");
 tolua_usertype(tolua_S,"CContact");
}

/* get function: contact of class  CContact */
#ifndef TOLUA_DISABLE_tolua_get_CContact_contact_ptr
static int tolua_get_CContact_contact_ptr(lua_State* tolua_S)
{
  CContact* self = (CContact*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'contact'",NULL);
#endif
   tolua_pushusertype(tolua_S,(void*)self->contact,"b2Contact");
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: contact of class  CContact */
#ifndef TOLUA_DISABLE_tolua_set_CContact_contact_ptr
static int tolua_set_CContact_contact_ptr(lua_State* tolua_S)
{
  CContact* self = (CContact*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'contact'",NULL);
  if (!tolua_isusertype(tolua_S,2,"b2Contact",0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->contact = ((b2Contact*)  tolua_tousertype(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: new of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_new00
static int tolua_MyContactListener_MyContactListener_new00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"MyContactListener",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   MyContactListener* tolua_ret = (MyContactListener*)  Mtolua_new((MyContactListener)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"MyContactListener");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: new_local of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_new00_local
static int tolua_MyContactListener_MyContactListener_new00_local(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"MyContactListener",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   MyContactListener* tolua_ret = (MyContactListener*)  Mtolua_new((MyContactListener)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"MyContactListener");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerEventScript of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_registerEventScript00
static int tolua_MyContactListener_MyContactListener_registerEventScript00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"MyContactListener",0,&tolua_err) ||
	 (tolua_isvaluenil(tolua_S, 2, &tolua_err) || !toluafix_isfunction(tolua_S, 2, "LUA_FUNCTION", 0, &tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  MyContactListener* self = (MyContactListener*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION nHandler = ((LUA_FUNCTION)toluafix_ref_function(tolua_S, 2, 0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'registerEventScript'", NULL);
#endif
  {
   self->registerEventScript(nHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerEventScript'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: unregisterEventScript of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_unregisterEventScript00
static int tolua_MyContactListener_MyContactListener_unregisterEventScript00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"MyContactListener",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  MyContactListener* self = (MyContactListener*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'unregisterEventScript'", NULL);
#endif
  {
   self->unregisterEventScript();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'unregisterEventScript'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getScriptHandler of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_getScriptHandler00
static int tolua_MyContactListener_MyContactListener_getScriptHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"MyContactListener",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  MyContactListener* self = (MyContactListener*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getScriptHandler'", NULL);
#endif
  {
   LUA_FUNCTION tolua_ret = (LUA_FUNCTION)  self->getScriptHandler();
   {
#ifdef __cplusplus
    void* tolua_obj = Mtolua_new((LUA_FUNCTION)(tolua_ret));
     tolua_pushusertype(tolua_S,tolua_obj,"LUA_FUNCTION");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#else
    void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(LUA_FUNCTION));
     tolua_pushusertype(tolua_S,tolua_obj,"LUA_FUNCTION");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#endif
   }
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getScriptHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: BeginContact of class  MyContactListener */
#ifndef TOLUA_DISABLE_tolua_MyContactListener_MyContactListener_BeginContact00
static int tolua_MyContactListener_MyContactListener_BeginContact00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"MyContactListener",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"b2Contact",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  MyContactListener* self = (MyContactListener*)  tolua_tousertype(tolua_S,1,0);
  b2Contact* contact = ((b2Contact*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'BeginContact'", NULL);
#endif
  {
   self->BeginContact(contact);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'BeginContact'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_MyContactListener_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CContact","CContact","CCObject",NULL);
  tolua_beginmodule(tolua_S,"CContact");
   tolua_variable(tolua_S,"contact",tolua_get_CContact_contact_ptr,tolua_set_CContact_contact_ptr);
  tolua_endmodule(tolua_S);
  #ifdef __cplusplus
  tolua_cclass(tolua_S,"MyContactListener","MyContactListener","b2ContactListener",tolua_collect_MyContactListener);
  #else
  tolua_cclass(tolua_S,"MyContactListener","MyContactListener","b2ContactListener",NULL);
  #endif
  tolua_beginmodule(tolua_S,"MyContactListener");
   tolua_function(tolua_S,"new",tolua_MyContactListener_MyContactListener_new00);
   tolua_function(tolua_S,"new_local",tolua_MyContactListener_MyContactListener_new00_local);
   tolua_function(tolua_S,".call",tolua_MyContactListener_MyContactListener_new00_local);
   tolua_function(tolua_S,"registerEventScript",tolua_MyContactListener_MyContactListener_registerEventScript00);
   tolua_function(tolua_S,"unregisterEventScript",tolua_MyContactListener_MyContactListener_unregisterEventScript00);
   tolua_function(tolua_S,"getScriptHandler",tolua_MyContactListener_MyContactListener_getScriptHandler00);
   tolua_function(tolua_S,"BeginContact",tolua_MyContactListener_MyContactListener_BeginContact00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_MyContactListener (lua_State* tolua_S) {
 return tolua_MyContactListener_open(tolua_S);
};
#endif

