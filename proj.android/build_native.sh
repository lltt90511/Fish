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

if [ -z "${NDK_ROOT_FOR_ANDROID+aaa}" ];then
echo "please define NDK_ROOT_FOR_ANDROID"
exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ... use paths relative to current directory
#NDK_ROOT = $1
#COCOS2DX_ROOT=$2
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"

echo "NDK_ROOT_FOR_ANDROID = $NDK_ROOT_FOR_ANDROID"
echo "COCOS2DX_ROOT_FOR_ANDROID = $COCOS2DX_ROOT_FOR_ANDROID"
echo "APP_ROOT = $APP_ROOT"
echo "APP_ANDROID_ROOT = $APP_ANDROID_ROOT"



chmod 666 -R "$APP_ANDROID_ROOT"/assets
if [[ "$buildexternalsfromsource" ]]; then
    echo "Building external dependencies from source"
    "$NDK_ROOT_FOR_ANDROID"/ndk-build -C "$APP_ANDROID_ROOT" $* \
        "NDK_MODULE_PATH=${COCOS2DX_ROOT_FOR_ANDROID}:${COCOS2DX_ROOT_FOR_ANDROID}/cocos2dx/platform/third_party/android/source"
else
    echo "Using prebuilt externals"
    "$NDK_ROOT_FOR_ANDROID"/ndk-build -C "$APP_ANDROID_ROOT" $* \
        "NDK_MODULE_PATH=${COCOS2DX_ROOT_FOR_ANDROID}:${COCOS2DX_ROOT_FOR_ANDROID}/cocos2dx/platform/third_party/android/prebuilt"
fi
