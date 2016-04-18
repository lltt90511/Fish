package cc.yongdream.nshx;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Calendar;

import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGLocalMessage;
import com.tencent.android.tpush.XGPushManager;

import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.Environment;
import android.text.format.Time;
import android.util.Log;

public class Util {
	
	static public mainActivity activityInstance = null;
	static Util instance = new Util();
	static public String photoId ;
	static public String photoPathString ;
	static private String writeAblePath = "/nshxFiles";
	static public String writePathString ;
	static public boolean selectImage = false;
	
	public static native void nativePushToken(int type, String token);
	public static native void nativePushData(int msgId, int msgType);
	
	public static void createWriteAblePath(){
	  if(Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())){
		  File sdPath = Environment.getExternalStorageDirectory();
	      String path = sdPath.getPath()+writeAblePath;
	      File file = new File(path);
	      if(!file.exists()){
	    	  file.mkdirs();
	      }
	      writePathString = file.getAbsolutePath();
	  }
	}
	public static void setActivity(mainActivity x){
		activityInstance = x;
		IntentFilter filter = new IntentFilter();
		filter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
		filter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
		filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
		activityInstance.registerReceiver(new NetworkConnectChangedReceiver(), filter);
	}
	
	public static void startPhoto(String id,float type,float crop,float x,float y){
		// super.onActivityResult(requestCode, resultCode, data);
        //Bundle extras = data.getExtras(); 
        //Bitmap b = (Bitmap) extras.get("data"); 
        Intent intent = new Intent();

        intent.setClass(activityInstance, PhotographActivity.class); 
        //intent.putExtra("image",b); 
        intent.putExtra("type", (int)type);
        intent.putExtra("crop", (int)crop);
        intent.putExtra("cropX", (int)x);
        intent.putExtra("cropY", (int)y);
        photoId = id;
        photoPathString = "";
        selectImage = false;
        activityInstance.startActivityForResult(intent,200); 
        
	}
	
	public static void previewFile(String filePath) {
//		Intent intent = new Intent();
//		intent.setClass(activityInstance, ShowImageActivity.class);
//		intent.putExtra("path", filePath);
//		activityInstance.startActivity(intent);
		String temp = writePathString+"/image.jpg";
		copyFile(new File(filePath),new File(temp));
		Uri uri = Uri.parse("file://"+temp); 
		 Intent intent = new Intent(Intent.ACTION_VIEW);   
		 intent.setDataAndType(uri, "image/*");  
		activityInstance.startActivity(intent);
	}
	
	public static void videoRecorder(String id,float type) {
		Intent intent = new Intent();
		intent.setClass(activityInstance, VideoRecorderActivity.class);
		intent.putExtra("type",(int)type);
		activityInstance.startActivityForResult(intent,200);
	}
	///////////////////////澶���舵��浠�//////////////////////////////
	/** 
	* 澶���跺��涓����浠� 
	* @param oldPath String ������浠惰矾寰� 濡�锛�c:/fqf.txt 
	* @param newPath String 澶���跺��璺�寰� 濡�锛�f:/fqf.txt 
	* @return boolean 
	*/ 
	static public void copyFile(File fromFile,File toFile)  { 
		
		if(!fromFile.exists()){  
		return;  
		}  
		
		if(!fromFile.isFile()){  
		return;  
		}  
		if(!fromFile.canRead()){  
		return;  
		}  
		if(!toFile.getParentFile().exists()){  
		toFile.getParentFile().mkdirs();  
		}  
		if(toFile.exists()){  
		toFile.delete();  
		}  
		
		
		try {  
		FileInputStream fosfrom = new FileInputStream(fromFile);  
		FileOutputStream fosto = new FileOutputStream(toFile);  
		
		byte[] bt = new byte[1024];  
		int c;  
		while((c=fosfrom.read(bt)) > 0){  
		fosto.write(bt,0,c);  
		}  
		//��抽��杈���ャ��杈���烘��  
		fosfrom.close();  
		fosto.close();  
		
		
		} catch (FileNotFoundException e) {  
		// TODO Auto-generated catch block  
		e.printStackTrace();  
		} catch (IOException e) {  
		// TODO Auto-generated catch block  
		e.printStackTrace();  
		}  
	}  
	
	public static void deleteFile(File delFile) {
		if(delFile == null) {
			return;
		}
		final File file = new File(delFile.getAbsolutePath());
		delFile = null;
		new Thread() {
			@Override
			public void run() {
				super.run();
				if(file.exists()) {
					file.delete();
				}
			}
		}.start();
	}
	
	public static void playVideo(String filePath) {
		//Intent intent = new Intent();
		String temp = writePathString+"/video.mp4";
		copyFile(new File(filePath),new File(temp));
		Uri uri = Uri.parse("file://"+temp); 
		 Intent intent = new Intent(Intent.ACTION_VIEW);   
		 intent.setDataAndType(uri, "video/mp4");  
		//intent.setClass(activityInstance, VideoPlayActivity.class);
		//intent.putExtra("path", filePath);
		activityInstance.startActivity(intent);
	}
	
	public static void audioRecorder(String id,float type,String filePath){
		switch((int)type) {
		case 1:
			AudioRecorderUtil.startAudioRecorder();
			break;
		case 2:
			AudioRecorderUtil.stopAudioRecorder();
			break;
		case 3:
			AudioRecorderUtil.cancelAudioRecorder();
			break;
		case 4:
			AudioRecorderUtil.playAudio(filePath);
			break;
		default:
			break;
		}
	}
	
	public static void deleteDirectory(String path){
		File file = new File(path);
        if(file.isFile()){
            file.delete();
            return;
        }
        if(file.isDirectory()){
            File[] childFile = file.listFiles();
            if(childFile == null || childFile.length == 0){
                file.delete();
                return;
            }
            for(File f : childFile){
            	deleteDirectory(f.getAbsolutePath());
            }
            file.delete();
        }
    }
	
	public static void pushRegister(String uid){
		XGPushManager.registerPush(activityInstance,uid);
	}
	
	public static void createPush(String type, String time, String content){
		XGLocalMessage msg = new XGLocalMessage();
		msg.setTitle("啪啪女神");
		msg.setContent(content);
		msg.setAction_type(1);
		
		long t = System.currentTimeMillis();
		final Calendar mCalendar = Calendar.getInstance();
		mCalendar.setTimeInMillis(t);
		int mHour = mCalendar.get(Calendar.HOUR);
		int mMinuts = mCalendar.get(Calendar.MINUTE);
		
		//转换时间
		int _time = Integer.parseInt(time);
		int _hour = 0;
		int _min = (_time - 3600) / 60;
		if (_time >= 3600)
			_hour = _time / 3600;
		if (_time >= 60)
			_min = (_time - _hour * 3600) / 60;
		
		Log.i("_time, _hour, _min", _time + ", " + _hour + " ," + _min);
		
		Log.i("mHour + _hour", mHour + "+" +  _hour);
		Log.i("mMinuts + _min", mMinuts + "+" + _min);
		msg.setHour(String.valueOf(mHour + _hour));
		msg.setMin(String.valueOf(mMinuts + _min));
		XGPushManager.addLocalNotification(activityInstance, msg);
	}
	
	public static void clearPush(String flag){
		XGPushManager.clearLocalNotifications(activityInstance);
	}
	
	public static void popWeb(String url) {
		final String furl = url;
		mainActivity.main.runOnUiThread(new Runnable()  
        {
            public void run()
            {
				PopActivity.popUrl = furl;
				mainActivity.main.startActivity(new Intent(mainActivity.main,PopActivity.class));
            }  
        });
	}
}
