#!/bin/bash
version=$2
aVersion=$3
if [ $1 = "0" ]
    then
    echo "Debug"
    #version=999999
fi
if [ $1 = "1" ]
    then
    echo "Full Release"
    #version=$[$2+1]
fi
if [ $1 = "2" ]
    then
    echo "Min Release"
fi
echo "scriptsVersion=$2 appVersion = $3"

_TARGET_BUILD_CONTENTS_PATH=$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH

echo _TARGET_BUILD_CONTENTS_PATH: $_TARGET_BUILD_CONTENTS_PATH

echo PWD: $PWD
echo Cleaning $_TARGET_BUILD_CONTENTS_PATH/
rm -rf $_TARGET_BUILD_CONTENTS_PATH/Res
mkdir $_TARGET_BUILD_CONTENTS_PATH/Res
rm -rf ../build
mkdir ../build
mv ../scripts/config.lua ../config_tmp.lua
mv ../scripts/release.lua ../release_tmp.lua
if [ $1 == 0 ]
    then
    echo "module('release', package.seeall) release = false" > ../scripts/release.lua
else 
    if [ $1 == 1 ]
    then
        echo "module('release', package.seeall) release = true ; appstore=true;" > ../scripts/release.lua
    else
        echo "module('release', package.seeall) release = true" > ../scripts/release.lua
    fi
fi
echo "scriptsVersion = $version appVersion = $aVersion" >../scripts/config.lua
chmod 777 ../../cocos2dx/tools/cocos2d-console/console/bin/lua/luajit-mac
python ../../cocos2dx/tools/cocos2d-console/console/cocos2d.py luacompile -s ../scripts -d ../build -e True -k l8KQKnBIgBq1RHi -b P4I7gouyNiqbYMR --disable-compile
mv ../config_tmp.lua ../scripts/config.lua 
mv ../release_tmp.lua ../scripts/release.lua 
#cd ../scripts
#python jit.py
#cd ../proj.ios
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

if [ $1 != 0 ]
    then
    chmod 777 ../imgEncode_ios
    operation_folder res res;
    rm -rf ../encodeTmp
    mkdir ../encodeTmp
    mkdir ../encodeTmp/res
    encodeImageAndCopy ../res ../encodeTmp/res 

    if [ $1 != 2 ] 
    then
        mkdir ../encodeTmp/res/battle
        mkdir ../encodeTmp/res/Image
        mkdir ../encodeTmp/res/nshx
        encodeImageAndCopy ../unPackagedRes/res/battle  ../encodeTmp/res/battle
        encodeImageAndCopy ../unPackagedRes/res/Image  ../encodeTmp/res/Image
        encodeImageAndCopy ../unPackagedRes/res/nshx  ../encodeTmp/res/nshx
        operation_folder unPackagedRes/music music;
    fi
    operation_folder encodeTmp/res/ res;

else
    operation_folder res res;
    # operation_folder unPackagedRes/music music;
    # operation_folder unPackagedRes/res/battle res/battle;
    # operation_folder unPackagedRes/res/Image res/Image;
    # operation_folder unPackagedRes/res/nshx res/nshx;
    
fi
echo "write scripts version"
echo "scriptsVersion = $version" 
echo "end build sh"
#cp -RLp $PWD/en.lproj/* $_TARGET_BUILD_CONTENTS_PATH/
# export
# CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate
#if [ "${PLATFORM_NAME}" =="iphoneos" ] || [ "${PLATFORM_NAME}" == "ipados"]; then
#   /Applications/Xcode.app/Contents/Developer/iphoneentitlements/gen_entitlements.py "my.company.${PROJECT_NAME}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent";
#       codesign -f -s "iPhone Developer" --entitlements "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/"
#fi
                                                     