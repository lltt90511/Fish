echo "please define Path"
if [ -z "${NDK_ROOT_FOR_ANDROID+aaa}" ];then
echo "please define NDK_ROOT_FOR_ANDROID"
exit 1
fi
if [ -z "${COCOS2DX_ROOT_FOR_ANDROID+aaa}" ];then
echo "please define COCOS2DX_ROOT_FOR_ANDROID"
exit 1
fi
if [ $1 = 0 ]
	then
	echo "debug Build"
fi
if [ $1 = 1 ]
	then
	echo "release Build"
fi
sh build_native.sh
sh copy_assert.sh $1 $2
if [ $1 = 0 ]
	then
	ant debug
fi
if [ $1 = 1 ]
	then
	ant release
fi

if [ $1 = 2 ]
	then
	ant release
fi

if [ $1 = 3 ]
	then
	ant release
fi