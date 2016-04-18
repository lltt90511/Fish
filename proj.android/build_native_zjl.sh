APPNAME="nshx"

# options

buildexternalsfromsource=

usage(){
cat << EOF
usage: $0 [options]

Build C/C++ code for $APPNAME using Android NDK

OPTIONS:
-s  Build externals from source
-h  this help
EOF
}

while getopts "sh" OPTION; do
case "$OPTION" in
s)
buildexternalsfromsource=1
;;
h)
usage
exit 0
;;
esac
done

# paths

export ANDROID_SDK_ROOT=/Users/zhangjl/Documents/AndroidTools/sdk/
export ANDROID_NDK_ROOT=/Users/zhangjl/Documents/AndroidTools/android-ndk-r9d
export COCOS2DX_ROOT=/Users/zhangjl/Documents/nshx/cocos2dx
export NDK_ROOT=/Users/zhangjl/Documents/AndroidTools/android-ndk-r9d
export PATH=$PATH:$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_NDK_ROOT
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"

echo "NDK_ROOT = $NDK_ROOT"
echo "COCOS2DX_ROOT = $COCOS2DX_ROOT"
echo "APP_ROOT = $APP_ROOT"
echo "APP_ANDROID_ROOT = $APP_ANDROID_ROOT"

if [ -z "${NDK_ROOT+aaa}" ];then
echo "please define NDK_ROOT"
exit 1
fi

# ... use paths relative to current directory

#chmod 666 -R "$APP_ANDROID_ROOT"/assets
if [[ "$buildexternalsfromsource" ]]; then
    echo "Building external dependencies from source"
    "$NDK_ROOT"/ndk-build -C "$APP_ANDROID_ROOT" $* \
        "NDK_MODULE_PATH=${COCOS2DX_ROOT}:${COCOS2DX_ROOT}/cocos2dx/platform/third_party/android/source"
else
    echo "Using prebuilt externals"
    "$NDK_ROOT"/ndk-build -C "$APP_ANDROID_ROOT" $* \
        "NDK_MODULE_PATH=${COCOS2DX_ROOT}:${COCOS2DX_ROOT}/cocos2dx/platform/third_party/android/prebuilt"
fi

sh copy_assert.sh