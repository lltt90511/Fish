DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"
echo "APP_ROOT = $APP_ROOT"
echo "APP_ANDROID_ROOT = $APP_ANDROID_ROOT"
# make sure assets is exist

function copyAssert()
{
	echo "copy $1 to $2"
	for file in "$APP_ROOT"/$1/*
	do
	if [ -d "$file" ]; then
		cp -rf "$file" "$APP_ANDROID_ROOT"/$2
	fi

	if [ -f "$file" ]; then
		cp "$file" "$APP_ANDROID_ROOT"/$2
	fi
	done
	chmod 777 -R "$APP_ANDROID_ROOT"/$2
	echo "end copy $1"
}
function encodeImageAndCopy()
{
 echo "encodeImage $1 $2 "
echo "$OS"
cd $APP_ROOT
if [ "$OS" = "Windows_NT" ];then
./imgEncode_win.exe <<EOF
	 $1
	 $2
EOF

else
./imgEncode_ios <<EOF
	 $1
	 $2
EOF
fi
cd $APP_ANDROID_ROOT
}
echo "clean dirty file"
if [ -d "$APP_ANDROID_ROOT"/assets ]; then
    rm -rf "$APP_ANDROID_ROOT"/assets
fi

mkdir "$APP_ANDROID_ROOT"/assets

cd ../scripts
rm -rf ../build
mkdir ../build
echo "lua jit all scripts"
if [ "$OS" = "Windows_NT" ];then
sh build.sh
else
python jit.py
fi
cd ../proj.android
echo "end build"

copyAssert build assets
copyAssert android_sound assets
if [ $1 = 0 ]
	then
	copyAssert res assets
	copyAssert unPackagedRes/music assets
	copyAssert unPackagedRes/res assets
	
	echo "scriptsVersion = 999999" >$APP_ANDROID_ROOT/assets/config.lua
	 echo "module('release', package.seeall) release = false" > $APP_ANDROID_ROOT/assets/release.lua
fi
if [ $1 = 1 ]
	then
	copyAssert res assets
#	//cd ..
	rm -rf "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp/res
	encodeImageAndCopy "res"  "encodeTmp/res"
#cd proj.android
	copyAssert encodeTmp/res assets
	echo "scriptsVersion = $2" >$APP_ANDROID_ROOT/assets/config.lua
	echo "module('release', package.seeall) release = true" > $APP_ANDROID_ROOT/assets/release.lua
fi
if [ $1 = 2 ]
	then
	copyAssert res assets
	copyAssert unPackagedRes/music assets
	copyAssert unPackagedRes/res assets
#	//cd ..
	rm -rf "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp/res
	encodeImageAndCopy "res"  "encodeTmp/res"
	encodeImageAndCopy "unPackagedRes/res"  "encodeTmp/res"
#cd proj.android
	copyAssert encodeTmp/res assets
	echo "scriptsVersion = $2" >$APP_ANDROID_ROOT/assets/config.lua
	echo "module('release', package.seeall) release = true ; isSelfServer =true;" > $APP_ANDROID_ROOT/assets/release.lua
fi

if [ $1 = 3 ]
	then
	copyAssert res assets
	copyAssert unPackagedRes/music assets
	copyAssert unPackagedRes/res assets
#	//cd ..
	rm -rf "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp
	mkdir "$APP_ROOT"/encodeTmp/res
	encodeImageAndCopy "res"  "encodeTmp/res"
	encodeImageAndCopy "unPackagedRes/res"  "encodeTmp/res"
#cd proj.android
	copyAssert encodeTmp/res assets
	echo "scriptsVersion = $2" >$APP_ANDROID_ROOT/assets/config.lua
	echo "module('release', package.seeall) release = true ;" > $APP_ANDROID_ROOT/assets/release.lua
fi