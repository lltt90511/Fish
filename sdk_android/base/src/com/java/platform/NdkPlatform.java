package com.java.platform;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

import org.apache.http.util.EncodingUtils;

import cc.yongdream.nshx.mainActivity;

import android.app.Activity;
import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import android.util.Log;

public class NdkPlatform extends Activity {
	public static native void nativePlatformInit(String devideId,String params);
	public static native void nativePlatformLoginResult(String uid,String username);
	public static native void nativePlatformQuit();
	public static native void nativePlatformPaymentResult(int result);
	public static native void nativePlatformUserLogout();
	
	public static String platformDeviceId = "";
	
	public static void platformInit(String s) {
	    nativePlatformInit(getDeviceId(""),"");
	}
    
    public static String getDeviceId(String s) {
        TelephonyManager tm = (TelephonyManager) mainActivity.main.getSystemService(TELEPHONY_SERVICE);
        if( tm.getDeviceId() != null ) {
            platformDeviceId = tm.getDeviceId();
            Log.i("DeviceId:", platformDeviceId);
        }
        else {
            try {
                getDeviceIdAndStore();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        platformDeviceId = "quick_reg_a_" + platformDeviceId;
        return platformDeviceId;
    }
	
	 public static String macAddress = null;
	 //获取mac地址
	 public static void getLocalMacAddress(Context context) {
		 final TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
	     final WifiManager wifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
	     if (wifi == null) return;
	     
	     macAddress = tm.getDeviceId();
	     if (macAddress == null) {
		     WifiInfo info = wifi.getConnectionInfo();  
		     macAddress = info.getMacAddress();
	     }
	     
	     if (macAddress == null && !wifi.isWifiEnabled())
	     {
	    	 new Thread() {
	    		 @Override
	    		 public void run() {
	    			 try {
		    			 wifi.setWifiEnabled(true);
		    			 for (int i = 0; i < 10; i++) {
		    				 macAddress = tm.getDeviceId();
		    				 if (macAddress == null) {
			    				 WifiInfo _info = wifi.getConnectionInfo();
			    				 macAddress = _info.getMacAddress();
		    				 }
		    				 if (macAddress != null) break;
		    				 Thread.sleep(500);
		    			 }
	    			 } catch (InterruptedException e) {
	    				 Thread.currentThread().interrupt();
	    			 }
	    		 }
	    	 }.start();
	     }
	 }
	 
	 //获取deviceId并存储
	 private static void getDeviceIdAndStore() throws IOException
	 {
		 if (!IsSdcardExist())
		 {
			 Log.i("getDeviceIdAndStore:", "noSDCard");
			 return;
		 }
		 
		 //可以读取到mac地址则直接读取不保存
		 getLocalMacAddress(mainActivity.main);
		 if (macAddress != null)
		 {
			 platformDeviceId = macAddress;
			 return;
		 }
		 
		 String filePath = "/" + downDir + "/Android/data/cc.yongdream.nshx";
		 File saveFile = new File(filePath, "system");
		 
		 if (saveFile.exists())
		 {
			 //已经存在该文件则读取
			 FileInputStream inStream = new FileInputStream(saveFile);
			 int length = inStream.available();
			 byte[] buffer = new byte[length];
			 inStream.read(buffer);
			 platformDeviceId = EncodingUtils.getString(buffer, "UTF-8");
			 Log.i("platformDeviceId: exists:", platformDeviceId);
			 inStream.close();
		 }
		 else
		 {
			 //不存在文件则写入
			 File file = new File(filePath + "/");
			 file.mkdirs();
			 
			 if (macAddress == null)
			 {
				 UUID uid = UUID.randomUUID();
				 macAddress = uid.toString();
			 }
			 FileOutputStream outStream = new FileOutputStream(saveFile);
			 outStream.write(macAddress.getBytes());
			 outStream.close();
			 platformDeviceId = macAddress;
			 Log.i("platformDeviceId: notexists:", platformDeviceId);
		 }
	 }
	 
	 public static String downDir = "sdcard";
	 public static boolean IsSdcardExist()
	 {
        File download = new File("/sdcard-ext/");
        
        if (download.exists()){
    	    downDir = "sdcard-ext";
    	    return true;
        }
        
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
        {
    	    downDir = "sdcard";
    	    return true;
        }
        
        return false;
	 }
}
