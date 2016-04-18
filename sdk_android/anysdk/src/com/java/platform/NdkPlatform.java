package com.java.platform;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lib.Cocos2dxRenderer;
import org.json.JSONException;
import org.json.JSONObject;

import com.anysdk.framework.AdsWrapper;
import com.anysdk.framework.IAPWrapper;
import com.anysdk.framework.PushWrapper;
import com.anysdk.framework.ShareWrapper;
import com.anysdk.framework.SocialWrapper;
import com.anysdk.framework.UserWrapper;
import com.anysdk.framework.java.AnySDK;
import com.anysdk.framework.java.AnySDKAds;
import com.anysdk.framework.java.AnySDKAnalytics;
import com.anysdk.framework.java.AnySDKIAP;
import com.anysdk.framework.java.AnySDKListener;
import com.anysdk.framework.java.AnySDKParam;
import com.anysdk.framework.java.AnySDKPush;
import com.anysdk.framework.java.AnySDKShare;
import com.anysdk.framework.java.AnySDKSocial;
import com.anysdk.framework.java.AnySDKUser;
import com.anysdk.framework.java.ToolBarPlaceEnum;

import cc.yongdream.nshx.mainActivity;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
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
	private static final String TAG_STRING = "ANYSDK";
	private static Dialog myDialog = null;
	
	public static void init() {
	    /**
	     * appKey、appSecret、privateKey不能使用Sample中的值，需要从打包工具中游戏管理界面获取，替换
	     * oauthLoginServer参数是游戏服务提供的用来做登陆验证转发的接口地址。
	     */
		String appKey = "23B1A2A2-2906-0B88-D670-2C2F5C1AA968";
	    String appSecret = "bebe3e007932d1c64299e17463650ecb";
	    String privateKey = "36F4CF4FB40DB17BCC059E5EF73D5177";
	    String oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php";
		AnySDK.getInstance().initPluginSystem(mainActivity.main, appKey, appSecret, privateKey, oauthLoginServer);

		/**
		 * 对用户系统、支付系统、广告系统、统计系统、社交系统、推送系统、分享系统设置debug模式
		 * 注意：debug模式开启，即开启了SDK的测试模式，所以上线前务必把debug模式设置为false
		 */
		AnySDKUser.getInstance().setDebugMode(false);
		AnySDKPush.getInstance().setDebugMode(false);
		AnySDKAnalytics.getInstance().setDebugMode(false);
		AnySDKAds.getInstance().setDebugMode(false);
		AnySDKShare.getInstance().setDebugMode(false);
		AnySDKSocial.getInstance().setDebugMode(false);
		AnySDKIAP.getInstance().setDebugMode(false);
		/**
		 * 初始化完成后，必须立即为系统设置监听，否则无法即使监听到回调信息
		 */
		hideToolBar();
  	    mainActivity.main.runOnUiThread(new Runnable() {                                                                                     
            public void run() {
            	setListener();
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
	
	public static void platformInit(String s) {
	    nativePlatformInit(getDeviceId(""),AnySDK.getInstance().getCustomParam());
	}
	
	public static void runOnMainThread(String text) {
		final String ftext = text;
  	    mainActivity.main.runOnUiThread(new Runnable() {                                                                                     
            public void run() {
            	Toast.makeText(mainActivity.main, ftext, Toast.LENGTH_SHORT).show();
            }
  	   	});
	}
	
	public static void setListener() {
		/**
		 * 为用户系统设置监听
		 */
		AnySDKUser.getInstance().setListener(new AnySDKListener() {

			@Override
			public void onCallBack(int arg0, String arg1) {
				// TODO Auto-generated method stub
				Log.e(TAG_STRING, arg1);
				switch(arg0)
				{
					case UserWrapper.ACTION_RET_INIT_SUCCESS://初始化SDK成功回调
						hideToolBar();
						break;
					case UserWrapper.ACTION_RET_INIT_FAIL://初始化SDK失败回调
	//					Exit();
						break;
					case UserWrapper.ACTION_RET_LOGIN_SUCCESS://登陆成功回调
						Log.e(TAG_STRING, "User is online");
						Log.d(TAG_STRING, String.valueOf(AnySDKUser.getInstance().isLogined()));
						String uId = String.valueOf(AnySDKUser.getInstance().getUserID());
						nativePlatformLoginResult(uId, "", "");
				        break;
					case UserWrapper.ACTION_RET_LOGIN_NO_NEED://登陆失败回调
						runOnMainThread("登录失败");
					case UserWrapper.ACTION_RET_LOGIN_TIMEOUT://登陆失败回调
						runOnMainThread("登录失败");
				    case UserWrapper.ACTION_RET_LOGIN_CANCEL://登陆取消回调
					case UserWrapper.ACTION_RET_LOGIN_FAIL://登陆失败回调
						Log.e(TAG_STRING, "fail");
						AnySDKAnalytics.getInstance().logError("login", "fail");
						runOnMainThread("登录失败");
				    	break;
					case UserWrapper.ACTION_RET_LOGOUT_SUCCESS://登出成功回调
						nativePlatformLogoutResult(1);
						break;
					case UserWrapper.ACTION_RET_LOGOUT_FAIL://登出失败回调
						Log.e(TAG_STRING, "登出失败");
						nativePlatformLogoutResult(0);
						break;
					case UserWrapper.ACTION_RET_PLATFORM_ENTER://平台中心进入回调
						break;
					case UserWrapper.ACTION_RET_PLATFORM_BACK://平台中心退出回调
						break;
					case UserWrapper.ACTION_RET_PAUSE_PAGE://暂停界面回调
						break;
					case UserWrapper.ACTION_RET_EXIT_PAGE://退出游戏回调
	//			         Exit();
						break;
					case UserWrapper.ACTION_RET_ANTIADDICTIONQUERY://防沉迷查询回调
						Log.e(TAG_STRING, "防沉迷查询回调");
						break;
					case UserWrapper.ACTION_RET_REALNAMEREGISTER://实名注册回调
						Log.e(TAG_STRING, "实名注册回调");
						break;
					case UserWrapper.ACTION_RET_ACCOUNTSWITCH_SUCCESS://切换账号成功回调
						nativePlatformSwitchResult(1);
						break;
					case UserWrapper.ACTION_RET_ACCOUNTSWITCH_FAIL://切换账号失败回调
						nativePlatformSwitchResult(0);
						break;
					case UserWrapper.ACTION_RET_OPENSHOP://打开游戏商店回调
						break;
					default:
						break;
				}
			}
		});
		
		/**
		 * 为支付系统设置监听
		 */
		AnySDKIAP.getInstance().setListener(new AnySDKListener() {
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				String temp = "fail";
				switch(arg0)
				{
				case IAPWrapper.PAYRESULT_INIT_FAIL://支付初始化失败回调
					break;
				case IAPWrapper.PAYRESULT_INIT_SUCCESS://支付初始化成功回调
					break;
				case IAPWrapper.PAYRESULT_SUCCESS://支付成功回调
					temp = "Success";
//					showDialog(temp, temp);
					nativePlatformPayResult(1);
					break;
				case IAPWrapper.PAYRESULT_FAIL://支付失败回调
					nativePlatformPayResult(0);
//					showDialog(temp, temp);
					break;
				case IAPWrapper.PAYRESULT_CANCEL://支付取消回调
//					showDialog(temp, "Cancel" );
					break;
				case IAPWrapper.PAYRESULT_NETWORK_ERROR://支付超时回调
					nativePlatformPayResult(2);
//					showDialog(temp, "NetworkError");
					break;
				case IAPWrapper.PAYRESULT_PRODUCTIONINFOR_INCOMPLETE://支付超时回调
					nativePlatformPayResult(2);
//					showDialog(temp, "ProductionInforIncomplete");
					break;
				/**
				 * 新增加:正在进行中回调
				 * 支付过程中若SDK没有回调结果，就认为支付正在进行中
				 * 游戏开发商可让玩家去判断是否需要等待，若不等待则进行下一次的支付
				 */
				case IAPWrapper.PAYRESULT_NOW_PAYING:
					nativePlatformPayResult(3);
//					showTipDialog();
					break;
				case IAPWrapper.PAYRESULT_RECHARGE_SUCCESS://充值成功回调
					nativePlatformPayResult(1);
					break;
				default:
					break;
				}
			}
		});

		/**
		 * 为广告系统设置监听
		 */
		AnySDKAds.getInstance().setListener(new AnySDKListener() {
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				switch (arg0) {
				case AdsWrapper.RESULT_CODE_AdsDismissed://广告消失回调
					break;
				case AdsWrapper.RESULT_CODE_AdsReceived://接受到网络回调
					break;
				case AdsWrapper.RESULT_CODE_AdsShown://显示网络回调
					break;
				case AdsWrapper.RESULT_CODE_PointsSpendFailed://积分墙消费失败
					break;
				case AdsWrapper.RESULT_CODE_PointsSpendSucceed://积分墙消费成功
					break;
				case AdsWrapper.RESULT_CODE_OfferWallOnPointsChanged://积分墙积分改变
					break;
				case AdsWrapper.RESULT_CODE_NetworkError://网络出错
					break;

				default:
					break;
				}
				
			}
		});
		/**
		 * 为分享系统设置监听
		 */
		AnySDKShare.getInstance().setListener(new AnySDKListener() {
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				switch (arg0) {
				case ShareWrapper.SHARERESULT_CANCEL://取消分享	
					break;
				case ShareWrapper.SHARERESULT_FAIL://分享失败
					break;
				case ShareWrapper.SHARERESULT_NETWORK_ERROR://分享网络出错
					break;
				case ShareWrapper.SHARERESULT_SUCCESS://分享结果成功
					break;

				default:
					break;
				}
				
			}
		});
		/**
		 * 为社交系统设置监听
		 */
		AnySDKSocial.getInstance().setListener(new AnySDKListener() {
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				switch (arg0) {
				case SocialWrapper.SOCIAL_SIGNIN_FAIL://社交登陆失败
					break;
				case SocialWrapper.SOCIAL_SIGNIN_SUCCEED://社交登陆成功
					break;
				case SocialWrapper.SOCIAL_SIGNOUT_FAIL://社交登出失败
					break;
				case SocialWrapper.SOCIAL_SIGNOUT_SUCCEED://社交登出成功
					break;
				case SocialWrapper.SOCIAL_SUBMITSCORE_FAIL://提交分数失败
					break;
				case SocialWrapper.SOCIAL_SUBMITSCORE_SUCCEED://提交分数成功
					break;
				default:
					break;
				}
				
			}
		});

		/**
		 * 为推送系统设置监听
		 */
		AnySDKPush.getInstance().setListener(new AnySDKListener() {
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				switch (arg0) {
				case PushWrapper.ACTION_RET_RECEIVEMESSAGE://接受到推送消息
					
					break;

				default:
					break;
				}
			}
		});
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
  	    mainActivity.main.runOnUiThread(new Runnable() {                                                                                     
            public void run() {     
            	AnySDKUser.getInstance().login();
            }
  	   	});
	 }
	 
	 /**
	  * 支付
	  * @param price 商品价格(整型) 整数
	  * @param productId 商品id
	  * @param productName 商品名
	  * @param serverId 服务器id，若无填1
	  * @param count 商品份数(除非游戏需要支持一次购买多份商品，否则传1即可)
	  * @param roleId 游戏角色id
	  * @param roleName 游戏角色名
	  * @param roleGrade 游戏角色等级
	  * @param roleBalance 用户游戏内虚拟币余额，如元宝，金币，符石
	  * @throws JSONException 
	  */
	 public static void platformPay(String params) throws JSONException {
		 JSONObject jsonObject = new JSONObject(params);
		 String price = jsonObject.getString("price");
		 String productId = jsonObject.getString("productid");
		 String productName = jsonObject.getString("productname");
		 String serverId = jsonObject.getString("serverid");
		 String count = jsonObject.getString("count");
		 String roleId = jsonObject.getString("uid");
		 String roleName = jsonObject.getString("name");
		 String roleGrade = jsonObject.getString("level");
		 String roleBalance = jsonObject.getString("balance");
		 Map<String, String> mProductionInfo = new HashMap<String, String>();
		 mProductionInfo.put("Product_Price", price);
		 mProductionInfo.put("Product_Id", productId);
		 mProductionInfo.put("Product_Name", URLDecoder.decode(productName));
		 mProductionInfo.put("Server_Id", serverId);
		 mProductionInfo.put("Product_Count", count);
		 mProductionInfo.put("Role_Id", roleId);
		 mProductionInfo.put("Role_Name", URLDecoder.decode(roleName));
		 mProductionInfo.put("Role_Grade", roleGrade);
		 mProductionInfo.put("Role_Balance", roleBalance);
		 JSONObject json = new JSONObject();
		 json.put("uid", roleId);
		 json.put("bcharid", jsonObject.getString("bcharid"));
		 
		 mProductionInfo.put("EXT", json.toString());
		 
		 ArrayList<String> idArrayList =  AnySDKIAP.getInstance().getPluginId();
		 if (idArrayList.size() == 1) {
		     AnySDKIAP.getInstance().payForProduct(idArrayList.get(0), mProductionInfo);
		 }
		 else {
//		     ChoosePayMode(idArrayList);
		 }
	 }
	 
	 /**
	  * 切换账号
	  */
	 public static void accountSwitch() {
		 if (AnySDKUser.getInstance().isFunctionSupported("accountSwitch")) {
			 AnySDKUser.getInstance().callFunction(("accountSwitch"));
		 }
	 }
	 
	 /**
	  * 登出
	  */
	 public static void logout() {
		 if (AnySDKUser.getInstance().isFunctionSupported("logout")) {
			 AnySDKUser.getInstance().callFunction("logout");
		 }
	 }
	 
	 /**
	  * 显示悬浮栏 1:左上角 2:右上角 3:左边中间 4:右边中间 5:左下角 6:右下角
	  */
	 public static void showToolBar() {
		 AnySDKParam param = new AnySDKParam(ToolBarPlaceEnum.kToolBarTopRight.getPlace());
		 AnySDKUser.getInstance().callFunction("showToolBar", param);
	 }
	 
	 /**
	  * 隐藏悬浮栏
	  */
	 public static void hideToolBar() {
		 if (AnySDKUser.getInstance().isFunctionSupported("hideToolBar")) {
			 AnySDKUser.getInstance().callFunction("hideToolBar");
		 }
	 }
	 
	 /**
	  * 奇虎360实名注册
	  */
	 public static void realNameRegister() {
		 if (AnySDKUser.getInstance().isFunctionSupported("realNameRegister")) {
			 AnySDKUser.getInstance().callFunction("realNameRegister");
		 }
	 }
	 
	 /**
	  * 奇虎防沉迷查询
	  */
	 public static void antiAddictionQuery() {
		 if (AnySDKUser.getInstance().isFunctionSupported("antiAddictionQuery")) {
			 AnySDKUser.getInstance().callFunction("antiAddictionQuery");
		 }
	 }
	 
	 /**
	  * UC,上海益玩
	  * @param roleId 角色ID
	  * @param roleName 角色名称
	  * @param roleLevel 角色等级
	  * @param zoneId 服务器ID
	  * @param zoneName 服务器名称
	  * @param dataType 数据类型 1为进入游戏 2为创建角色
	  * @param ext 扩展字段
	 * @throws JSONException 
	  */
	 public static void submitLoginGameRole(String params) throws JSONException {
		 if (AnySDKUser.getInstance().isFunctionSupported("submitLoginGameRole")) {
			 JSONObject jsonObject = new JSONObject(params);
			 String roleId = jsonObject.getString("uid");
			 String roleName = jsonObject.getString("name");
			 String roleLevel = jsonObject.getString("roleLevel");
			 String zoneId = jsonObject.getString("serverid");
			 String zoneName = jsonObject.getString("servername");
			 String dataType = jsonObject.getString("datatype");
			 String ext = jsonObject.getString("ext");
			 Map<String, String> map = new HashMap<String, String>();
			 map.put("roleId", roleId);
			 map.put("roleName", roleName);
	    	 map.put("roleLevel", roleLevel);
	    	 map.put("zoneId", zoneId);
	    	 map.put("zoneName", zoneName);
	    	 map.put("dataType", dataType);
	    	 map.put("ext", ext); 
	    	 AnySDKParam param = new AnySDKParam(map);
	    	 AnySDKUser.getInstance().callFunction("submitLoginGameRole",param);
		 }
	 }
}
