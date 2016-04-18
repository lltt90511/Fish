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

import com.pps.sdk.listener.PPSPlatformListener;
import com.pps.sdk.platform.PPSPlatform;
import com.pps.sdk.platform.PPSResultCode;
import com.pps.sdk.services.PPSUser;

import cc.yongdream.nshx.mainActivity;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.telephony.TelephonyManager;
import android.util.Log;

public class NdkPlatform extends Activity {
	public static native void nativePlatformInit(String devideId,String params);
	public static native void nativePlatformLoginResult(String uid,String username,String uSession);
	public static native void nativePlatformSwitchResult(int result);
	public static native void nativePlatformPayResult(int result);
	public static native void nativePlatformLogoutResult(int result);
	
	public static String platformDeviceId = "";
	public static PPSUser ppsUser = null;
	
	public static void ppsInit() {
		int initNum = PPSPlatform.initPPSPlatform(mainActivity.main,"2935");
		Log.e("platform", String.valueOf(initNum));
		PPSPlatform.startGame(mainActivity.main);
		PPSPlatform.setDebug(false);
		
//		mainActivity.main.runOnUiThread(new Runnable(){
//			@Override
//			public void run() {
//				PPSPlatform.getInstance().initSlideBar(mainActivity.main);
//            }
//  	   	});
	}
	
	public static void init() {
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
	
	public static void platformInit(String s) {
	    nativePlatformInit(getDeviceId(""),"ppns");
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
	 
	 public final static Handler mHandler = new Handler();
	 
	 public static void platformLogin() {
//		mainActivity.main.runOnUiThread(new Runnable(){
//			@Override
//			public void run() {
        		PPSPlatform.getInstance().ppsLogin(mainActivity.main,new PPSPlatformListener() {
        			@Override
        			public void leavePlatform() {
        				// TODO Auto-generated method stub
        				super.leavePlatform();
        				System.out.println("离开PPS游戏联运平台");
        			}

        			@Override
        			public void loginResult(int resultCode, PPSUser user) {
        				// TODO Auto-generated method stub
        				super.loginResult(resultCode, user);
        				if(resultCode == PPSResultCode.SUCCESSLOGIN){
        					ppsUser = user;
        					System.out.println("用户登入成功");
        					System.out.println("uid => " + user.uid);
        					System.out.println("timestamp => " + user.timestamp);
        					System.out.println("sign => " + user.sign);
        					final String uid = user.uid;
        					final String name = user.name;
        					final String sign = user.sign;
        					
        					mainActivity.main.runOnUiThread(new Runnable(){

								@Override
								public void run() {
									// TODO Auto-generated method stub
									//添加 SDK浮标
//									PPSPlatform.getInstance().initSlideBar(mainActivity.main);
									nativePlatformLoginResult(uid, name, sign);
								}
        					});
        				}
        				if(resultCode == PPSResultCode.ERRORLOGIN){
        					System.out.println("用户登入失败");
        					ppsUser = null;
        				}
        			}
        		});
//              }
//      	});
	 }
	 
	 public static void platformPay(String params) throws JSONException {
		JSONObject jsonObject = new JSONObject(params);
		String price = jsonObject.getString("price");
		String roleId = jsonObject.getString("uid");
		String sId = jsonObject.getString("sid");
		String bCharId = jsonObject.getString("bcharid");
		
		JSONObject json = new JSONObject();
		json.put("uid", roleId);
		json.put("bcharid", bCharId);
		json.put("userid", ppsUser.uid);
		
  	    mainActivity.main.runOnUiThread(new Runnable() {
            public void run() {
				PPSPlatform.getInstance().ppsPayment(mainActivity.main,6,"dfsfds","ppsmobile_s1","userData",new PPSPlatformListener() {
					@Override
					public void leavePlatform() {
						// TODO Auto-generated method stub
						super.leavePlatform();
						System.out.println("离开PPS游戏联运平台");
					}
		
					@Override
					public void paymentResult(int result) {
						// TODO Auto-generated method stub
						super.paymentResult(result);
						if (result == PPSResultCode.SUCCESSPAYMENT) {
							System.out.println("充值成功");
							//PPS服务器会通知游戏方后台进行发放元宝
							//这个地方只是作为一个提示充值成功，不代表PPS后台已经成功通知游戏方发放元宝完成
							mainActivity.main.runOnUiThread(new Runnable(){
								@Override
								public void run() {
									nativePlatformPayResult(1);
								}
					  	   	});
						}else{
							System.out.println("充值失败");
							mainActivity.main.runOnUiThread(new Runnable(){
								@Override
								public void run() {
									nativePlatformPayResult(0);
								}
					  	   	});
						}
					}
				});
            }
  	   	});
	 }
	 
	 public static void logout() {
		mainActivity.main.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				PPSPlatform.getInstance().ppsLogout(mainActivity.main, new PPSPlatformListener() {
					@Override
					public void logout() {
						// TODO Auto-generated method stub
						super.logout();
						//账户已经成功退出   游戏方需要在此回调中关闭游戏进程
						mainActivity.main.finish();
					}
				});
            }
  	   	});
	 }
	 
	 public static void showToolBar() {
		//添加 SDK浮标
//		mainActivity.main.runOnUiThread(new Runnable(){
//			@Override
//			public void run() {
//				PPSPlatform.getInstance().initSlideBar(mainActivity.main);
//            }
//  	   	});
	 }
	 
	 public static void accountSwitch() {
		mainActivity.main.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				PPSPlatform.getInstance().ppsChangeAccount(mainActivity.main,new PPSPlatformListener(){
					@Override
					public void leavePlatform() {
						// TODO Auto-generated method stub
						super.leavePlatform();
						System.out.println("离开PPS游戏联运平台");
					}
		
					@Override
					public void loginResult(int resultCode, PPSUser user) {
						// TODO Auto-generated method stub
						super.loginResult(resultCode, user);
						if(resultCode == PPSResultCode.SUCCESSLOGIN){
							System.out.println("用户登入成功");
							System.out.println("uid => " + user.uid);
							System.out.println("timestamp => " + user.timestamp);
							System.out.println("sign => " + user.sign);
							
        					final String uid = user.uid;
        					final String name = user.name;
        					final String sign = user.sign;
        					
        					mainActivity.main.runOnUiThread(new Runnable(){

								@Override
								public void run() {
									// TODO Auto-generated method stub
									nativePlatformLoginResult(uid, name, sign);
								}
        					});
						}
						if(resultCode == PPSResultCode.ERRORLOGIN){
							System.out.println("用户登入失败");
						}
					}
					@Override
					public void logout() {
						// TODO Auto-generated method stub
						super.logout();
						if(!PPSPlatform.getInstance().isLogin()){
							System.out.println("" + "");
						}
					}   
				});
            }
  	   	});
	 }
	 
	 static int gameNum = 0;
	 
	 public static void sendSDKEvent(String event, String _id) {
		 gameNum = 0;
		 final String fid = "ppsmobile_s" + _id;
		 Log.e("platform", "start");
		 if (event.equals("enterGame")) {
			mainActivity.main.runOnUiThread(new Runnable(){
				@Override
				public void run() {
					gameNum = PPSPlatform.getInstance().enterGame(mainActivity.main, fid);
	            }
	  	   	});
		 } else if (event.equals("createRole")) {
			mainActivity.main.runOnUiThread(new Runnable(){
				@Override
				public void run() {
					gameNum = PPSPlatform.getInstance().createRole(mainActivity.main, fid);
	            }
	  	   	});
		 }
		 Log.e("platform", String.valueOf(gameNum));
	 }
}
