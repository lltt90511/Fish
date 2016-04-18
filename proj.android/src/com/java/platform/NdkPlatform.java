package com.java.platform;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lib.Cocos2dxRenderer;
import org.json.JSONException;
import org.json.JSONObject;

import com.iapppay.interfaces.callback.IPayResultCallback;
import com.iapppay.sdk.main.IAppPay;
import com.iapppay.sdk.main.IAppPayOrderUtils;

import cc.yongdream.nshx.mainActivity;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import android.util.Log;

public class NdkPlatform extends Activity {
	public static native void nativePlatformInit(String devideId,String params);
	public static native void nativePlatformLoginResult(String uid,String username,String uSession);
	public static native void nativePlatformSwitchResult(int result);
	public static native void nativePlatformPayResult(int result);
	public static native void nativePlatformLogoutResult(int result);
	public static native void nativeAppInfo(String params);
	
	public static String platformDeviceId = "";
	
	public static void platformInit(String s) {
	    nativePlatformInit(getDeviceId(""),"ipay_chongqin");
    	ConnectivityManager manager = (ConnectivityManager) mainActivity.main.getSystemService(Context.CONNECTIVITY_SERVICE);
    	NetworkInfo gprs = manager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
    	NetworkInfo wifi = manager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
    	Log.e("H3c", "wifi:" + wifi.isConnected() + " 3g:" + gprs.isConnected());
    	if (wifi.isConnected() == true) {
    		Cocos2dxRenderer.handleOnChangedNetwork(2);
    	}else if (gprs.isConnected() == true) {
    		Cocos2dxRenderer.handleOnChangedNetwork(1);
    	}else {
    		Cocos2dxRenderer.handleOnChangedNetwork(0);
    	}
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
	 
	 public static String getSimOperatorInfo()
	 {
		TelephonyManager telephonyManager = (TelephonyManager)mainActivity.main.getSystemService(Context.TELEPHONY_SERVICE);
		String operatorString = telephonyManager.getSimOperator();
		
		if(operatorString == null)
		{
			return "ERROR";
		}
		
		if(operatorString.equals("46000") || operatorString.equals("46002"))
		{
			//中国移动
			return "CMCC";
		}
		else if(operatorString.equals("46001"))
		{
			//中国联通
			return "CUCC";
		}
		else if(operatorString.equals("46003"))
		{
			//中国电信
			return "CTCC";
		}
		
		//error
		return "ERROR";
	 }
	 
	 public static String mac = null;
	 public static String ip = null;
	 public static void getLocalMac() {
		 final TelephonyManager tm = (TelephonyManager)mainActivity.main.getSystemService(Context.TELEPHONY_SERVICE);
	     final WifiManager wifi = (WifiManager)mainActivity.main.getSystemService(Context.WIFI_SERVICE);
	     if (wifi == null)
	    	 return;
	     WifiInfo info = wifi.getConnectionInfo();
	     mac = info.getMacAddress();
	     int ipAddress = info.getIpAddress();
	     ip = intToIp(ipAddress);
	     
	     if (mac == null && !wifi.isWifiEnabled())
	     {
	    	 new Thread() {
	    		 @Override
	    		 public void run() {
	    			 try {
		    			 wifi.setWifiEnabled(true);
		    			 for (int i = 0; i < 10; i++) {
		    				 if (mac == null) {
			    				 WifiInfo _info = wifi.getConnectionInfo();
			    				 mac = _info.getMacAddress();
		    				 }
		    				 if (mac != null)
		    					 break;
		    				 Thread.sleep(500);
		    			 }
	    			 } catch (InterruptedException e) {
	    				 Thread.currentThread().interrupt();
	    			 }
	    		 }
	    	 }.start();
	     }
	 }
	 
	 public static String intToIp(int i) {
         return (i & 0xFF ) + "." +
         ((i >> 8 ) & 0xFF) + "." +
         ((i >> 16 ) & 0xFF) + "." +
         ( i >> 24 & 0xFF);
     }   
	 
	 public static void getAppInfo(String s) throws JSONException {
		getLocalMac();
		String pkgName = mainActivity.main.getPackageName();
		String verSdk = android.os.Build.VERSION.RELEASE;
		String appType = getSimOperatorInfo();
		String appOperate = "android";
		String appModel = android.os.Build.MODEL;
		String info = pkgName + "|" + verSdk + "|" + appType + "|" + appOperate + "|" + appModel + "|" + mac + "|" + ip;
		nativeAppInfo(info);
	 }
	 
	 public static void init() {
		 IAppPay.init(mainActivity.main, IAppPay.PORTRAIT, IAppPaySDKConfig.APP_ID);
	 }
	 
	 public static void iapPay(String params) throws JSONException {
		 JSONObject jsonObject = new JSONObject(params);
		 String orderId = jsonObject.getString("orderId");
		 String productId = jsonObject.getString("productId");
		 String price = jsonObject.getString("price");
		 String userId = jsonObject.getString("userId");
		 //调用 IAppPayOrderUtils getTransdata() 获取支付参数
		 IAppPayOrderUtils orderUtils = new IAppPayOrderUtils();
		 orderUtils.setAppid(IAppPaySDKConfig.APP_ID);
		 orderUtils.setWaresid(Integer.parseInt(productId));
		 orderUtils.setCporderid(orderId);
		 orderUtils.setAppuserid(userId);
		 orderUtils.setPrice(Float.parseFloat(price));//单位 元
//		 orderUtils.setWaresname("自定义名称");//开放价格名称(用户可自定义，如果不传以后台配置为准)
		 orderUtils.setCpprivateinfo("");
		 orderUtils.setNotifyurl("");
		 final String data = orderUtils.getTransdata(IAppPaySDKConfig.APPV_KEY);
		 
		 mainActivity.main.runOnUiThread(new Runnable(){

			@Override
			public void run() {
				// TODO Auto-generated method stub
				 IAppPay.startPay(mainActivity.main, data, new IPayResultCallback() {
					
					 @Override
					 public void onPayResult(int resultCode, String signvalue, String resultInfo) {
						// TODO Auto-generated method stub
						
						 switch (resultCode) {
						 case IAppPay.PAY_SUCCESS:
							 //调用 IAppPayOrderUtils 的验签方法进行支付结果验证
							 boolean payState = IAppPayOrderUtils.checkPayResult(signvalue, IAppPaySDKConfig.PLATP_KEY);
							 if(payState){
//								 Toast.makeText(GoodsActivity.this, "支付成功", Toast.LENGTH_LONG).show();
							 }
							 break;
						 case IAppPay.PAY_ING:
							 break ;
						 default:
							 break;
						 }
					 }
					
				 });
			}});
		 
	 }
}
