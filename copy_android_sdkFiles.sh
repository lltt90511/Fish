DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_SDK_ROOT="$DIR/proj.android"
SDK_BASE_ROOT="$DIR/sdk_android/base"
SDK_ANYSDK_ROOT="$DIR/sdk_android/anysdk"
SDK_LJ_ROOT="$DIR/sdk_android/lj"
SDK_PPS_ROOT="$DIR/sdk_android/pps"

# rm -rf "$APP_SDK_ROOT"/*

function copySdkFiles()
{
	echo "--------------copy sdkFiles--------------"
	for file in "$1"/*
	do
	if [ -d "$file" ]; then
		echo "$file"
		echo "$2"
		cp -rf "$file" "$2"
	fi

	if [ -f "$file" ]; then
		echo "$file"
		echo "$2"
		cp "$file" "$2"
	fi
	done
	echo "------------end copy sdkFiles------------"
}

if [ "$1" = "base" ]
	then
	copySdkFiles $SDK_BASE_ROOT $APP_SDK_ROOT
elif [ "$1" = "anysdk" ]
	then
	copySdkFiles $SDK_ANYSDK_ROOT $APP_SDK_ROOT
elif [ "$1" = "lj" ]
	then
	copySdkFiles $SDK_LJ_ROOT $APP_SDK_ROOT
elif [ "$1" = "pps" ]
	then
	copySdkFiles $SDK_PPS_ROOT $APP_SDK_ROOT
else
	echo "-------------error sdk name--------------"
fi