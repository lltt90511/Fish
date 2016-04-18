package cc.yongdream.nshx;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxRenderer;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.NetworkInfo.State;
import android.net.wifi.WifiManager;
import android.os.Parcelable;
import android.util.Log;

public class NetworkConnectChangedReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
    	//判断应用是否在运行  
    	ActivityManager am = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE); 
    	List<RunningTaskInfo> list = am.getRunningTasks(100); 
    	boolean isAppRunning = false; 
    	String MY_PKG_NAME = "cc.yongdream.nshx"; 
    	for (RunningTaskInfo info : list) { 
    		if (info.topActivity.getPackageName().equals(MY_PKG_NAME) || info.baseActivity.getPackageName().equals(MY_PKG_NAME)) { 
    			isAppRunning = true; 
    			Log.i("H3c",info.topActivity.getPackageName() + " info.baseActivity.getPackageName()="+info.baseActivity.getPackageName()); 
    			break;
    		}
    	} 
    	  
    	 
    	//运行中才去重启蓝牙，否则会导致安装了这个应用后蓝牙无法关闭 
    	if(isAppRunning == false){ 
    		return;
    	}  
        if (WifiManager.WIFI_STATE_CHANGED_ACTION.equals(intent.getAction())) {
            int wifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, 0);
            Log.e("H3c", "wifiState" + wifiState);
            switch (wifiState) {
            case WifiManager.WIFI_STATE_DISABLED:
                break;
            case WifiManager.WIFI_STATE_DISABLING:
                break;
            //
            }
        }
        
        if (WifiManager.NETWORK_STATE_CHANGED_ACTION.equals(intent.getAction())) {
            Parcelable parcelableExtra = intent
                    .getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
            if (null != parcelableExtra) {
                NetworkInfo networkInfo = (NetworkInfo) parcelableExtra;
                State state = networkInfo.getState();
                boolean isConnected = state == State.CONNECTED;
                Log.e("H3c", "isConnected" + isConnected);
                if (isConnected) {
                	
                } else {

                }
            }
        }
     
        if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
        	ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
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
    }
}