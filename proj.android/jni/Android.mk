LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)


LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := hellolua/main.cpp \
                   ../../Classes/cjson/fpconv.c\
                   ../../Classes/cjson/lua_cjson.c\
                   ../../Classes/cjson/lua_extensions.c\
                   ../../Classes/cjson/strbuf.c\
                   ../../Classes/AppDelegate.cpp\
                   ../../Classes/APC.cpp\
                   ../../Classes/Video/VideoPlatform.cpp\
                   ../../Classes/capi.cpp\
                   ../../Classes/LogicController.cpp\
                   ../../Classes/lz4.c\
                   ../../Classes/NetController.cpp\
                   ../../Classes/LuaBox2D.cpp\
                   ../../Classes/luacurl.c\
                   ../../Classes/LuaCallBack.cpp\
                   ../../Classes/sqLite/lsqlite3.c\
                   ../../Classes/sqLite/sqlite3.c
                   
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes

LOCAL_STATIC_LIBRARIES := curl_static_prebuilt

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_lua_static
LOCAL_WHOLE_STATIC_LIBRARIES += box2d_static
LOCAL_WHOLE_STATIC_LIBRARIES += chipmunk_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static

include $(BUILD_SHARED_LIBRARY)


$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)
$(call import-module,scripting/lua/proj.android)
$(call import-module,cocos2dx/platform/third_party/android/prebuilt/libcurl)
$(call import-module,extensions)
$(call import-module,external/Box2D)
$(call import-module,external/chipmunk)