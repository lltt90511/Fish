#!/bin/bash
cd proj.ios
version=$1

echo "scriptsVersion=$1"

_TARGET_BUILD_CONTENTS_PATH=packageTmp
rm -rf $_TARGET_BUILD_CONTENTS_PATH
mkdir $_TARGET_BUILD_CONTENTS_PATH
mkdir $_TARGET_BUILD_CONTENTS_PATH/Res

echo _TARGET_BUILD_CONTENTS_PATH: $_TARGET_BUILD_CONTENTS_PATH

echo PWD: $PWD
echo Cleaning $_TARGET_BUILD_CONTENTS_PATH/
rm -rf ../build
mkdir ../build
mv ../scripts/config.lua ../config_tmp.lua
echo "scriptsVersion = $version" >../scripts/config.lua
chmod 777 ../../cocos2dx/tools/cocos2d-console/console/bin/lua/luajit-mac
python ../../cocos2dx/tools/cocos2d-console/console/cocos2d.py luacompile -s ../scripts -d ../build -e True -k l8KQKnBIgBq1RHi -b P4I7gouyNiqbYMR --disable-compile
cd ../scripts
python jit.py
cd ../proj.ios
mv ../config_tmp.lua ../scripts/config.lua 
# 函数作用:刷新资源文件夹，解决xcode不能刷新资源文件夹的bug

# 参数1:传入要操作的文件夹

function operation_folder()

{
#rm -rf $_TARGET_BUILD_CONTENTS_PATH/Res/$2
    echo "copy ../$1 to $_TARGET_BUILD_CONTENTS_PATH/Res/$2/"
    mkdir -p $_TARGET_BUILD_CONTENTS_PATH/Res/$2/
    # 判断文件夹不为空，才进行复制，防止cp命令报错
                                                     
    DIRECTORY=$PWD/../$1/
                                                     
    if [ "`ls $DIRECTORY`" != "" ]; then
        cp -RLp $DIRECTORY/ $_TARGET_BUILD_CONTENTS_PATH/Res/$2/
        find $_TARGET_BUILD_CONTENTS_PATH/Res/$2/ -name ".svn" |xargs rm -rf
        #echo operation_folder:$1 to $2 completed!
    else
        echo DIRECTORY not found!
    fi
}
                                                     
function encodeImageAndCopy()
{
    echo "encodeImage $1 $2 "
    ../imgEncode_ios <<EOF
     $1
     $2
EOF
}

                                                     
echo ""
operation_folder ios_sound sound;
operation_folder build scripts; 


chmod 777 ../imgEncode_ios
operation_folder res res;
rm -rf ../encodeTmp
mkdir ../encodeTmp
mkdir ../encodeTmp/res
encodeImageAndCopy ../res ../encodeTmp/res 

mkdir ../encodeTmp/res/battle
mkdir ../encodeTmp/res/Image
mkdir ../encodeTmp/res/nshx
encodeImageAndCopy ../unPackagedRes/res/battle  ../encodeTmp/res/battle
encodeImageAndCopy ../unPackagedRes/res/Image  ../encodeTmp/res/Image
encodeImageAndCopy ../unPackagedRes/res/nshx  ../encodeTmp/res/nshx
operation_folder unPackagedRes/music music

operation_folder encodeTmp/res/ res

echo "scriptsVersion = $version">$_TARGET_BUILD_CONTENTS_PATH/Res/scripts/config.lua
rm -f $_TARGET_BUILD_CONTENTS_PATH/Res/scripts/release.lua
rm -f $_TARGET_BUILD_CONTENTS_PATH/Res/scripts/release.luac
echo "end build sh"
cd $_TARGET_BUILD_CONTENTS_PATH/Res
zip -r ../../../update_bak_`date +%Y%m%d_%H%M`_V$version.zip  *
#cp -RLp $PWD/en.lproj/* $_TARGET_BUILD_CONTENTS_PATH/
# export
# CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate
#if [ "${PLATFORM_NAME}" =="iphoneos" ] || [ "${PLATFORM_NAME}" == "ipados"]; then
#   /Applications/Xcode.app/Contents/Developer/iphoneentitlements/gen_entitlements.py "my.company.${PROJECT_NAME}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent";
#       codesign -f -s "iPhone Developer" --entitlements "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/"
#fi
                                                     