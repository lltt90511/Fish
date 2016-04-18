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

import com.xinmei365.game.proxy.DoAfter;
import com.xinmei365.game.proxy.GameProxy;
import com.xinmei365.game.proxy.PayCallBack;
import com.xinmei365.game.proxy.XMExitCallback;
import com.xinmei365.game.proxy.XMLoginCheckerV3;
import com.xinmei365.game.proxy.XMUser;
import com.xinmei365.game.proxy.XMUserListener;
import com.xinmei365.game.proxy.XMUtils;

import cc.yongdream.nshx.mainActivity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;

public class NdkPlatform extends Activity {
	public static native void nativePlatformInit(String devideId,String params);
	public static native void nativePlatformLoginResult(String uid,String username,String uSession);
	public static native void nativePlatformSwitchResult(int result);
	public static native void nativePlatformPayResult(int result);
	public static native void nativePlatformLogoutResult(int result);
	
	public static String platformDeviceId = "";
	private static XMUser mUser;
	
	public static void init() {
		GameProxy.getInstance().setUserListener(mainActivity.main, new XMUserListener() {
			
			@Override
			public void onLogout(Object customObject) {
				// TODO Auto-generated method stub
				mUser = null;
				mainActivity.main.runOnUiThread(new Runnable(){

					@Override
					public void run() {
						// TODO Auto-generated method stub
						nativePlatformLogoutResult(1);
					}});
			}
			
			@Override
			public void onLoginSuccess(XMUser user, Object customObject) {
				// TODO Auto-generated method stub
				mUser = user;
				String uid = user.getUserID();
				String uname = user.getUsername();
				String token = user.getToken();
				String channelid = user.getChannelID();
				String channeluserid = user.getChannelUserId();
				String channellabel = user.getChannelLabel();
//				nativePlatformLoginResult(channeluserid, uname, token);
				doCheckLogin();
			}
			
			@Override
			public void onLoginFailed(String arg0, Object customObject) {
				// TODO Auto-generated method stub
//				runOnMainThread("登录失败");
			}
		});
		
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
	
	/**
	 * 检查登录状态操作说明：
	 * 登陆成功获取到SDK返回的用户信息后（如uid、token等），需上传用户信息到游戏服务器，
	 * 游戏服务器与我方服务器进行通信，进行用户信息校验，收到校验成功的结果后，方可认为登录成功，
	 * 以下代码仅为示例代码，请向游戏服务器请求用户信息验证
	 */
	public static void doCheckLogin() {
        if (mUser == null) {
        	runOnMainThread("请先登录");
            return;
        }
        
		XMLoginCheckerV3 checker = new XMLoginCheckerV3(mainActivity.main);
		checker.fetchDataAndDo(mUser, new DoAfter<String>() {

			@Override
			public void afterSuccess(String t) {
				//校验用户信息成功，进入游戏，同时调用数据接口
				//TODO 进入游戏
//				doSetExtData();
				final String uid = mUser.getUserID();
				final String uname = mUser.getUsername();
				final String token = mUser.getToken();
				final String channelid = mUser.getChannelID();
				final String channeluserid = mUser.getChannelUserId();
				final String channellabel = mUser.getChannelLabel();
				mainActivity.main.runOnUiThread(new Runnable(){

					@Override
					public void run() {
						// TODO Auto-generated method stub
						nativePlatformLoginResult(channeluserid, uname, token);
					}});
			}

			@Override
			public void afterFailed(String msg, Exception e) {
				runOnMainThread("验证登录失败");
			}
		});
	}
	
	/**
	  * 数据上传接口说明：(需在进入服务器、角色升级、创建角色处分别调用，否则无法上传apk)
	  * @param activity       上下文Activity，不要使用getApplication()
	  * @param data           上传数据 
	  * 
	  * _id                   当前情景，目前支持 enterServer，levelUp，createRole
	  *                       游戏方需在进入服务器、角色升级、创建角色处分别调用
	  * roleId                当前登录的玩家角色ID，必须为数字，若如，传入userid
	  * roleName              当前登录的玩家角色名，不能为空，不能为null，若无，传入"游戏名称+username"
	  * roleLevel             当前登录的玩家角色等级，必须为数字，若无，传入1
	  * zoneId                当前登录的游戏区服ID，必须为数字，若无，传入1
	  * zoneName              当前登录的游戏区服名称，不能为空，不能为null，若无，传入"无区服"
	  * balance               当前用户游戏币余额，必须为数字，若无，传入0
	  * vip                   当前用户VIP等级，必须为数字，若无，传入1  
	  * partyName             当前用户所属帮派，不能为空，不能为null，若无，传入"无帮派"
	  */
	public static void setExtData(String params) throws JSONException {
//		Map<String,String> datas = new HashMap<String,String>();
//		datas.put("_id", "enterServer");
//		datas.put("roleId", "13524696");
//		datas.put("roleName", "方木");
//		datas.put("roleLevel", "24");
//		datas.put("zoneId", "1");
//		datas.put("zoneName", "墨土1区");
//		datas.put("balance", "88");
//		datas.put("vip", "2");
//		datas.put("partyName", "无尽天涯");
//		JSONObject obj = new JSONObject(datas);
		
		GameProxy.getInstance().setExtData(mainActivity.main, params);
	}
	
	public static void runOnMainThread(String text) {
		final String ftext = text;
  	    mainActivity.main.runOnUiThread(new Runnable() {                                                                                     
            public void run() {
            	Toast.makeText(mainActivity.main, ftext, Toast.LENGTH_SHORT).show();
            }
  	   	});
	}
	
	public static void platformInit(String s) {
	    nativePlatformInit(getDeviceId(""), getChanelLabel());
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
	 
	 /**
	  * 登录
	  */
	 public static void platformLogin() {
		GameProxy.getInstance().login(mainActivity.main, "login");
	 }
	 
	 /**
	 * 不定额支付接口说明：
	 * @param context       上下文Activity
	 * @param itemName      游戏币名称，如金币、钻石等 
	 * @param unitPrice     游戏道具单位价格，单位为人民币分
	 * @param defaultCount  购买道具数量
	 * @param callBackInfo  游戏开发者自定义字段，会与支付结果一起通知到游戏服务器，游戏服务器可通过该字段判断交易的详细内容（金额 角色等）
	 * @param callBackUrl   支付结果通知地址，支付完成后我方后台会向该地址发送支付通知
	 * @param payCallBack   支付回调接口
	 * @throws JSONException 
	 */
	 public static void platformPay(String params) throws JSONException {
		 JSONObject jsonObject = new JSONObject(params);
		 final String price = jsonObject.getString("price");
		 final String count = jsonObject.getString("count");
		 final String roleId = jsonObject.getString("uid");
		 final String bCharId = jsonObject.getString("bcharid");
		 final String callBackUrl = jsonObject.getString("callbackurl");
		 final JSONObject json = new JSONObject();
		 json.put("uid", roleId);
		 json.put("bcharid", bCharId);
		 json.put("userid", mUser.getChannelUserId());
		 
		 GameProxy.getInstance().pay(mainActivity.main, Integer.parseInt(price),"钻石", Integer.parseInt(count), json.toString(), callBackUrl, new PayCallBack() {
		       @Override
		       public void onSuccess(String successInfo) {
		    	   nativePlatformPayResult(1);
		       }
		       @Override
		       public void onFail(String failInfo){
		    	   nativePlatformPayResult(0);
		       }
		   });
	 }
	 
	 public static void logout() {
		GameProxy.getInstance().logout(mainActivity.main, "logout"); 
	 }
	 
	 public static void doExit() {
		GameProxy.getInstance().exit(mainActivity.main, new XMExitCallback() {
			
			@Override
			public void onNo3rdExiterProvide() {
				//渠道不存在退出界面，如百度移动游戏等，此时需在此处弹出游戏退出确认界面，否则会出现渠道审核不通过情况
				//游戏定义自己的退出界面 ，实现退出逻辑
				AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity.main);
				builder.setTitle("确认退出游戏吗？");
				builder.setPositiveButton("退出", new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						//该方法必须在退出时调用
						GameProxy.getInstance().applicationDestroy(mainActivity.main);
						
						/****  退出逻辑需确保能够完全销毁游戏                       ****/
						mainActivity.main.finish();
//						onDestroy();
						/****  退出逻辑请根据游戏实际情况，勿照搬Demo ****/
					}
				});
				builder.show();
			}
			
			@Override
			public void onExit() {
				//渠道存在退出界面，如91、360等，此处只需进行退出逻辑即可，无需再弹游戏退出界面；
//				Toast.makeText(mainActivity.main, "由渠道退出界面退出", Toast.LENGTH_LONG).show();
				//该方法必须在退出时调用
				GameProxy.getInstance().applicationDestroy(mainActivity.main);
				
				/****  退出逻辑需确保能够完全销毁游戏                       ****/
				mainActivity.main.finish();
//				onDestroy();
				/****  退出逻辑请根据游戏实际情况，勿照搬Demo ****/
			}
		});
	}
	 
	/**
	 * 用于获取渠道标识，游戏开发者可在任意处调用该方法获取到该字段，含义请参照《如何区分渠道》中的渠道与ChannelLabel对照表
	 * @return
	 */
	public static String getChanelLabel() {
		XMUtils.getManifestMeta(mainActivity.main, "TD_CHANNEL_ID");
		String channel = XMUtils.getChannelLabel(mainActivity.main);
		return channel;
	}
}
