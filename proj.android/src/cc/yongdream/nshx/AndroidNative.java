package cc.yongdream.nshx;

import android.util.Log;

public class AndroidNative {

	static{  
//		System.loadLibrary("imeida");
//		System.loadLibrary("girlfanvideo");
	}  
	public native void setVideoWindows(Object wid);
	public native void setAndroidSdkVersion(int version);
	public native void startRoomPlay(String arurl);
	public native void stopRoomPlay();
	//public native void checkSign(String key, String value);
	public native void setLog(int i); 
	
	public static void reflashsurfaceview() {
		Log.e("hello", "reflash_surfaceview");
	}
}
