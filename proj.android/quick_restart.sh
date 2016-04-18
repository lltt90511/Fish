sh quick_copy.sh $1 $2
ant release
adb -r install bin/nshx-release.apk
adb shell am start cc.yongdream.nshx/cc.yongdream.nshx.mainActivity