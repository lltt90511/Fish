DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"
echo "APP_ROOT = $APP_ROOT"
echo "APP_ANDROID_ROOT = $APP_ANDROID_ROOT"
# make sure assets is exist

if [ ! $3 ]
	then
	echo "第三个参数渠道号"
	exit 2
fi

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
	# chmod 777 -R "$APP_ANDROID_ROOT"/$2
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

# sh ./copy_scripts.sh

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

copyAssert res assets
rm -rf "$APP_ROOT"/encodeTmp
mkdir "$APP_ROOT"/encodeTmp
mkdir "$APP_ROOT"/encodeTmp/res
encodeImageAndCopy "res"  "encodeTmp/res"
copyAssert encodeTmp/res assets

copyAssert sound_android assets
cp "$APP_ROOT"/sound/bgm01.mp3 assets
cp "$APP_ROOT"/sound/bgm02.mp3 assets
cp "$APP_ROOT"/sound/bgm03.mp3 assets

echo "scriptsVersion = $2" >$APP_ANDROID_ROOT/assets/config.lua

echo "appSrc = '$3'" >$APP_ANDROID_ROOT/assets/appChannel.lua