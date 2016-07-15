package cc.yongdream.nshx;
import java.io.File;
import java.io.IOException;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.graphics.PixelFormat;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.net.Uri;

import org.cocos2dx.lib.*;

import com.java.platform.NdkPlatform;
import com.umeng.analytics.game.UMGameAgent;

import cc.yongdream.nshx.mainActivity;
import cc.yongdream.nshx.AndroidVideoWindowImpl;
import cc.yongdream.nshx.AndroidVideoWindowImpl.VideoWindowListener;

public class mainActivity extends Cocos2dxActivity{
	
	//保存当前Activity实例， 静态变量 
	public static Activity mActivity = null; 
	public static mainActivity girlfan =null;
	FrameLayout mFrameLayer;
	private MediaPlayer mediaPlayer;    //播放器控件
	AndroidNative video = new AndroidNative();  
	
	
	public static final int buildVersion = Integer.parseInt(Build.VERSION.SDK);
	AndroidVideoWindowImpl mVideoWindow;
	public VideoWindowListener mListener;
	public SurfaceHolder mSurfaceHolder;
	public SurfaceView mVideoRenderingView;
	public static Cocos2dxGLSurfaceView glSurfaceView;
	
	public static float marginLeft =0.0f;
	public static float marginTop =0.0f;
	public static float marginScale =0.0f;
	public static float marginWidth = 0.0f;
	public static float marginHeight = 0.0f;
	
	public static Activity main = null;
	public final static Handler mHandler = new Handler();
	
	public native void onVideoSucc();
	public native void onVideoFinish();
	public native void onVideoError();
	
	public static mainActivity getInstance() {//返回实例  
		Log.e("GirlFan", "获取对象 getInstance");
		return girlfan;  
	}  

    public static void reflashsurfaceview() {
		Log.e("hello", "reflash_surfaceview");
	}
	
	protected void onCreate(Bundle savedInstanceState){
		//super.unregisterReceiver(new NetworkConnectChangedReceiver());
		super.onCreate(savedInstanceState);
		girlfan = this; 

//		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,              
//				WindowManager.LayoutParams.FLAG_FULLSCREEN);      
//		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,              
//				WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);       
//		DisplayMetrics outMetrics = new DisplayMetrics();      
//		this.getWindowManager().getDefaultDisplay().getMetrics(outMetrics); 
//		Log.e("GirlFan","width:"+ outMetrics.widthPixels);
//		Log.e("GirlFan","height:"+ outMetrics.heightPixels);
//		GameSurfaceView.SCREEN_WIDTH = outMetrics.widthPixels;      
//		GameSurfaceView.SCREEN_HEIGHT = outMetrics.heightPixels;      
//		GameSurfaceView gameView = new GameSurfaceView(this);      
		 
		Log.e("GirlFan", "onCreate show");
		
		main = this;
		Log.i("mainActivity:", "onCreate");
		NdkPlatform.init();
		mHandler.post(new Runnable(){
			public void run(){
				UMGameAgent.setDebugMode(true);//设置输出运行时日志
				UMGameAgent.init(main);
			}
		});
	}
	
    public Cocos2dxGLSurfaceView  onCreateView() { 
    	Util.createWriteAblePath();
    	glSurfaceView = new Cocos2dxGLSurfaceView(this); 
    	glSurfaceView.setEGLConfigChooser(8 , 8, 8, 8, 16, 8);
		glSurfaceView.getHolder().setFormat(PixelFormat.RGBA_8888);

//    	glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
//    	glSurfaceView.getHolder().setFormat(PixelFormat.RGB_565);
    	glSurfaceView.setZOrderOnTop(true);
    	Util.setActivity(this);
    	return glSurfaceView; 
   }
    
   public static void clearColor(){
	   //glSurfaceView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
   }
    
   public static void setCutType(String type){
	   Log.e("girlfan", "#################"+type);
	   if(type!=null && type.equals("1")){
		   glSurfaceView.setEGLConfigChooser(8 , 8, 8, 8, 16, 8);
		   glSurfaceView.getHolder().setFormat(PixelFormat.RGBA_8888);
	   }
	   else{
		   glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
		   glSurfaceView.getHolder().setFormat(PixelFormat.RGB_565);
	   }
	   Log.e("girlfan", "****************"+type);
   }
   
   
    public void playVideo(String url){
 	    Log.e("GirlFan", url);
//    	this.setCutType("1");
// 	    url = "/mnt/sdcard/video/shipin01.mp4";
// 	    url = "/mnt/sdcard2/test.mp4";
// 	    url = "video/shipin01.mp4";
// 	    url = "rtmp://218.66.170.4/live/Z59m8njK88893026";
 	    if(url.indexOf("rtmp://")!=-1){
 	    	openWebView();
 	    	video.startRoomPlay(url);
 	    	video.setVideoWindows(mVideoWindow);
 	    }
 	    else{
// 	    	String path = getApplicationContext().getPackageResourcePath();
// 	    	url = path+url;
 	    	createMediaView(url);
 	    }
    	
    }
 
    public void hiddenVideo(){
    	Log.e("GirlFan", "hiddenVideo");
//     	this.setCutType("2");
    	//girlfan.stopRoomPlay();
  	    this.runOnUiThread(new Runnable() {//在主线程里添控件                                                                                        
            public void run() {     
         		if (mVideoRenderingView != null){
         			mVideoRenderingView.setVisibility(View.INVISIBLE);
   				}
            }
  	   	});
    }
    public void stopPlay(){
    	
 	    Log.e("GirlFan", "stopPlay");
 	    video.stopRoomPlay();
//    	this.setCutType("2");
 	    this.runOnUiThread(new Runnable() {//在主线程里添控件                                                                                        
           public void run() {     
				if (mVideoRenderingView == null)
					return ;
//        	    girlfan.mVideoRenderingView.setVisibility(View.INVISIBLE);    // 置到Top层  
        	   ViewGroup vg = (ViewGroup)mVideoRenderingView.getParent();  
//        	   if(vg.findViewById(mVideoRenderingView.getId()) != null)
        	   try{
        		   vg.removeView(mVideoRenderingView); 
				   
        	   }catch(Exception e){
//        		   Log.e("GirlFan", e.getMessage());
        	   }
        	   finally{
					mVideoRenderingView = null;
        	   }
//        	   girlfan.mVideoRenderingView.setZOrderOnTop(false);

           }
 	   	});
 	    
 	   if(mediaPlayer != null)  
 		  mediaPlayer.release();  
 	    //mVideoRenderingView.setVisibility(0);
    	//glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
// 		mVideoRenderingView.getHolder().setFormat(PixelFormat.TRANSPARENT);  // 设置背景为透明 
// 	    mFrameLayer.removeView(mVideoRenderingView); 
    }
    
    public void createMediaView(String url){
    	Log.e("GirlFan", "createMediaView");
//    	String path=getApplicationContext().getPackageResourcePath();
//		String s = path + "/" + url;
    	final String furl = url;
  	    this.runOnUiThread(new Runnable() {//在主线程里添加别的控件                                                                                        
             public void run() {                                                                                                                            
                  //初始化webView                                                                                                                            
             	 Log.e("GirlFan", "Media show");
                  
             	 WindowManager winManager=(WindowManager)getSystemService(Context.WINDOW_SERVICE);
             	 int width  = winManager.getDefaultDisplay().getWidth();
             	 int height = winManager.getDefaultDisplay().getHeight();
//             	 setTitle(winManager.getDefaultDisplay().getWidth()+"*"+winManager.getDefaultDisplay().getHeight());
  		    	 Log.e("GirlFan", width+"*"+height);

             	 ViewGroup.LayoutParams framelayout_view =  new     FrameLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT,         
                          ViewGroup.LayoutParams.FILL_PARENT);        

//             	 ViewGroup.LayoutParams framelayout_view =  new     FrameLayout.LayoutParams(540,480*540/640);
//             	 ViewGroup.LayoutParams framelayout_view =  new     ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,         
// 	                               ViewGroup.LayoutParams.WRAP_CONTENT);        
 	       		 mVideoRenderingView = new SurfaceView(girlfan);
 	       		 mVideoRenderingView.setLayoutParams(framelayout_view);
 	       		 //mVideoRenderingView.setBackgroundColor(Color.BLUE);
 	       		 //mVideoRenderingView.requestFocus();//获取焦点  
// 	       		 mVideoRenderingView.setFocusableInTouchMode(true);//设置为可触控  
 	       		 mVideoRenderingView.setZOrderOnTop(false);    // 置到Top层  
// 	       		 mVideoRenderingView.getHolder().setFormat(PixelFormat.TRANSPARENT);  // 设置背景为透明 
 	       		 //setContentView(mVideoRenderingView);  
 	       		//初始化一个空的布局
 	       		mFrameLayer = new FrameLayout(girlfan); 
 	       		final float scale = girlfan.getResources().getDisplayMetrics().density;
 		    	Log.e("GirlFan", "+++++"+ scale);
// 		    	mFrameLayer..setFormat(PixelFormat.TRANSPARENT);
 	       		FrameLayout.LayoutParams framelayout_frame ;
 	       		double factor = (double)width/640.0;
				 Log.e("GirlFan", ""+factor);
				if(marginWidth>0){
 	       			
 	       			framelayout_frame =  new     FrameLayout.LayoutParams((int)((double)marginWidth *factor),(int)((double)marginHeight*factor));
 	       			framelayout_frame.topMargin=(int)((double)marginTop*factor);
 	       			framelayout_frame.leftMargin=(int)((double)marginLeft*factor);
					 Log.e("GirlFan", (int)((double)marginWidth *factor)+" "+(int)((double)marginHeight*factor)+" "+(int)((double)marginTop*factor)+" "+(int)((double)marginLeft*factor));
 	       		}
 	       		else{
 	       			framelayout_frame =  new     FrameLayout.LayoutParams((int)(width),(int)(width*480/640));
 	       			framelayout_frame.topMargin=(int)((double)46*((double)width/(double)640));
 	       		}
 	       		//mFrameLayer.setBackgroundColor(Color.RED);
 	       		//framelayout_frame.gravity = Gravity.CENTER; 
 	       		mFrameLayer.addView(mVideoRenderingView);
 	       	    addContentView(mFrameLayer, framelayout_frame);
 	       	    SurfaceHolder surfaceHolder = mVideoRenderingView.getHolder();
 	       	    surfaceHolder.addCallback(new Callback() {
	
	                 @Override
	                 public void surfaceDestroyed(SurfaceHolder holder) {
	                	 Log.e("GirlFan","mVideoRenderingView Destroyed");
	                 }
	
	                 @Override
	                 public void surfaceCreated(SurfaceHolder holder) {
	                	 Log.e("GirlFan","mVideoRenderingView Created");
	                     mediaPlay(furl);
	                 }
	
	                 @Override
	                 public void surfaceChanged(SurfaceHolder holder, int format,
	                                 int width, int height) {
	                	 Log.e("GirlFan","mVideoRenderingView Changed");
//	                	 mediaPlay(furl);
	                 }
	         });
// 	       	    try {
// 	       	    	 Thread.sleep(1000);
//					 
//					 mediaPlayer.setDisplay(surfaceHolder);  //把视频显示在SurfaceView上
////		 	       	 mediaPlayer.setOnPreparedListener(new videoPreparedL(0));  //设置监听事件
//		 	       	 mediaPlayer.prepare();  
//		 	       	 mediaPlayer.start();  
//				} catch (Exception e) {
//					// TODO Auto-generated catch block
//					Log.e("GirlFan", e.getMessage());
//				}
 	       	   
 	    	
             }                                                                                                                                              
         });   
    }
    
    public boolean fileExists(String url){
    	try{
//    		String path=getApplicationContext().getPackageResourcePath();
            File f=new File(url);
            if(!f.exists()){
                    return false;
            }
	    }catch (Exception e) {
	            // TODO: handle exception
	            return false;
	    }
	    return true;
    }
    
    public void mediaPlay(String url){
    	try {
    		
    		mediaPlayer =  new MediaPlayer();
	    	mediaPlayer.setDisplay(mVideoRenderingView.getHolder());
	    	AssetFileDescriptor afd = getApplicationContext().getAssets().openFd(url);
	    	mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
//	    	url = "/mnt/sdcard/video/shipin01.mp4";
//	    	afd.close();
	    	Log.e("GirlFan", url);
//	    	mediaPlayer.setDataSource(url);
	    	mediaPlayer.prepareAsync();
	    	mediaPlayer.setOnErrorListener(new OnErrorListener(){
				@Override
				public boolean onError(MediaPlayer mp, int what, int extra) {
					// TODO Auto-generated method stub
					Log.e("GirlFan", "error");
					onVideoError();
					return false;
				}
	    		
	    	});
	    	mediaPlayer.setOnPreparedListener(new OnPreparedListener() {
	
	                public void onPrepared(MediaPlayer mp) {
	                        Log.e("GirlFan", "开始了");
	//                        System.out.println("position:" + mPositon);
	//                        mediaPlayer.seekTo(mPositon);
	//                        start.setEnabled(false);
	                        onVideoSucc();
	                        if(mediaPlayer.isPlaying()){   //判断之前是否在播放
	                        	mediaPlayer.seekTo(0);  //是的就跳到0播放
	                        }else{
	                        	mediaPlayer.start();
	                        }
	                        
	                }
	
	        });
	    	mediaPlayer.setOnCompletionListener(new OnCompletionListener() {
	
	                public void onCompletion(MediaPlayer mp) {
	                        Log.e("GirlFan", "结束了");
	                        onVideoFinish();
	                }
	        });
    	}catch(Exception e){
    		 Log.e("GirlFan", e.getMessage());
    		 onVideoError();
    	}
    	
    }
    
    public void mediaStop(){
    	Log.e("GirlFan","mediaPlay stop");
    	if(mediaPlayer!=null){
    		mediaPlayer.release();
    	}
    }
    
    public static void setVideoSize(String left, String top, String width, String height){
    	marginLeft = Float.parseFloat(left);
    	marginTop  = Float.parseFloat(top);
//    	marginScale = Float.parseFloat(scale);
    	marginWidth = Float.parseFloat(width);
    	marginHeight = Float.parseFloat(height);
    }
    
    class videoPreparedL implements OnPreparedListener {
		int postSize;
		public videoPreparedL(int postSize) {
			this.postSize = postSize;
		}

		public void onPrepared(MediaPlayer mp) {//准备完成
			
			if (mediaPlayer != null) { 
				mediaPlayer.start();  //开始播放视频
			} else {
				return;
			}
		}
	}
	
	public void openVideo(final String url){
		video.setLog(1);
		video.setAndroidSdkVersion(buildVersion);
	    Log.e("GirlFan", String.valueOf(buildVersion));
	    this.runOnUiThread(new Runnable() {//在主线程里添加别的控件                                                                                        
            public void run() {                     
            	if(mVideoRenderingView!=null){
            		if(url.lastIndexOf("-1")>0){
            			mVideoRenderingView.setVisibility(View.INVISIBLE);
            		}
            		else{
            			mVideoRenderingView.setVisibility(View.VISIBLE);
            		}
        	    	
        	    	if(mVideoWindow==null){
        	    		mVideoWindow = new AndroidVideoWindowImpl(mVideoRenderingView, null);
            			mVideoWindow
            					.setListener(new AndroidVideoWindowImpl.VideoWindowListener() {
            						@Override
            						public void onVideoRenderingSurfaceReady(
            								AndroidVideoWindowImpl vw, SurfaceView surface) {
            							video.setVideoWindows(vw);
            						}

            						@Override
            						public void onVideoRenderingSurfaceDestroyed(
            								AndroidVideoWindowImpl vw) {
            							// 注释掉这行，否则会出现bug
            							video.setVideoWindows(null);
            						}

            					});

            			mVideoWindow.init();
        	    	}
        	    	video.startRoomPlay(url);
        			if(url.lastIndexOf("-1")>0){
        				video.setVideoWindows(null);
            		}
            		else{
            			video.setVideoWindows(mVideoWindow);
            		}
        	    }
            }
	    });
	    
    }
 
	public void openWebView() { 

 	    Log.e("GirlFan", "playVideo");
 	    video.setLog(1);
 	    video.setAndroidSdkVersion(buildVersion);
	    Log.e("GirlFan", String.valueOf(buildVersion));
	    if(mVideoRenderingView!=null){
	    	mVideoRenderingView=null;
	    }
 	    this.runOnUiThread(new Runnable() {//在主线程里添加别的控件                                                                                        
            public void run() {                                                                                                                            
                 //初始化webView                                                                                                                            
            	 Log.e("GirlFan", "playVideo show");

                 
            	 WindowManager winManager=(WindowManager)getSystemService(Context.WINDOW_SERVICE);
            	 int width  = winManager.getDefaultDisplay().getWidth();
            	 int height = winManager.getDefaultDisplay().getHeight();
//            	 setTitle(winManager.getDefaultDisplay().getWidth()+"*"+winManager.getDefaultDisplay().getHeight());
 		    	 Log.e("GirlFan", width+"*"+height);

            	 ViewGroup.LayoutParams framelayout_view =  new     FrameLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT,         
                         ViewGroup.LayoutParams.FILL_PARENT);        

//            	 ViewGroup.LayoutParams framelayout_view =  new     FrameLayout.LayoutParams(540,480*540/640);
//            	 ViewGroup.LayoutParams framelayout_view =  new     ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,         
//	                               ViewGroup.LayoutParams.WRAP_CONTENT);        
	       		 mVideoRenderingView = new SurfaceView(girlfan);
	       		 mVideoRenderingView.setLayoutParams(framelayout_view);
	       		 //mVideoRenderingView.setBackgroundColor(Color.BLUE);
	       		 //mVideoRenderingView.requestFocus();//获取焦点  
//	       		 mVideoRenderingView.setFocusableInTouchMode(true);//设置为可触控  
	       		 mVideoRenderingView.setZOrderOnTop(false);    // 置到Top层  
//	       		 mVideoRenderingView.getHolder().setFormat(PixelFormat.TRANSPARENT);  // 设置背景为透明 
	       		 //setContentView(mVideoRenderingView);  
	       		//初始化一个空的布局
	       		mFrameLayer = new FrameLayout(girlfan); 
	       		final float scale = girlfan.getResources().getDisplayMetrics().density;
		    	Log.e("GirlFan", "+++++"+ scale);
//		    	mFrameLayer..setFormat(PixelFormat.TRANSPARENT);
	       		FrameLayout.LayoutParams framelayout_frame =  new     FrameLayout.LayoutParams((int)(width),(int)(width*480/640));
	       		//mFrameLayer.setBackgroundColor(Color.RED);
	       		//framelayout_frame.gravity = Gravity.CENTER; 
	       		framelayout_frame.topMargin=(int)((double)46*((double)width/(double)640));
	       		mFrameLayer.addView(mVideoRenderingView);
                  
	       	    addContentView(mFrameLayer, framelayout_frame);
//          	    ViewGroup.LayoutParams framelayout_video =  new     ViewGroup.LayoutParams(480,360);                          
////          	    		new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT,         
////          	                               ViewGroup.LayoutParams.FILL_PARENT);        
//		        FrameLayout framelayout = new FrameLayout(girlfan);   
//		        framelayout.setLayoutParams(framelayout_video);     
//		        framelayout.setBackgroundColor(Color.RED);
//		    	Log.e("GirlFan", "playVideo1");
//                
//                /*初始化线性布局 里View*/
//		    	mVideoRenderingView = new SurfaceView(girlfan);
//			    mVideoRenderingView.setBackgroundColor(Color.BLUE);
//			    mVideoRenderingView.requestFocus();//获取焦点  
//			    mVideoRenderingView.setFocusableInTouchMode(true);//设置为可触控  
//			    mVideoRenderingView.setZOrderOnTop(true);    // 置到Top层  
//			    mVideoRenderingView.getHolder().setFormat(PixelFormat.TRANSPARENT);  // 设置背景为透明
//
//			    Log.e("GirlFan", "mVideoRenderingView");
//		   	    mVideoRenderingView.setLayoutParams(framelayout_video);
                                  
                //mFrameLayer.addView(mVideoRenderingView);

		    	Log.e("GirlFan", "mVideoWindow");
		       	mVideoWindow = new AndroidVideoWindowImpl(mVideoRenderingView, null);

				mVideoWindow
						.setListener(new AndroidVideoWindowImpl.VideoWindowListener() {
							@Override
							public void onVideoRenderingSurfaceReady(
									AndroidVideoWindowImpl vw, SurfaceView surface) {
								video.setVideoWindows(vw);
							}

							@Override
							public void onVideoRenderingSurfaceDestroyed(
									AndroidVideoWindowImpl vw) {
								// 注释掉这行，否则会出现bug
//								setVideoWindows(null);
							}

						});

				mVideoWindow.init();                                                                                                             
                //把webView加入到线性布局             
                                                                               
            }                                                                                                                                              
        });   
         
     }
    
	public static void restartGame(String s) {
     	Intent intent = main.getIntent();
     	main.finish();
     	main.startActivity(intent);
     	android.os.Process.killProcess(android.os.Process.myPid()); 
	}
    
	public static void goToDownLoad(String s) {
     	Intent intent = new Intent();       
        intent.setAction("android.intent.action.VIEW");   
        Uri content_url = Uri.parse(s);  
        intent.setData(content_url); 
        main.startActivity(intent);
	}
	
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    	//super.onActivityResult(requestCode, resultCode, data);
    	// Bundle bundle = data.getExtras();
    	// String idString = bundle.getString("id");
    	 //String path = bundle.getString("path");
    	if (Util.selectImage == true ){
    		Util.selectImage = false;
	    	 Log.e("TAG-->", ""+Util.photoPathString+"  "+Util.photoId);
	    	 Cocos2dxRenderer.handelTakePhoto(Util.photoPathString,Util.photoId);
    	}
    }
    static {
//    	System.loadLibrary("imeida");
//    	System.loadLibrary("girlfanvideo");
        System.loadLibrary("cocos2dlua");
    } 
    
	@Override
	protected void onResume() {
		super.onResume();
		UMGameAgent.onResume(this);
		if (!Util.isLock)
			Util.AcquireWakeLock();
	}

	@Override
	protected void onPause() {
		super.onPause();
		UMGameAgent.onPause(this);
		Util.ReleaseWakeLock();
	}
}

class LuaGLSurfaceView extends Cocos2dxGLSurfaceView{
	
	public static native void nativeSetApkPath(final String pApkPath);
	public LuaGLSurfaceView(Context context){
		super(context);
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
    	// exit program when key back is entered
		Log.e("onKeyDown:", String.valueOf(keyCode));
    	if (keyCode == KeyEvent.KEYCODE_BACK) {
    		android.os.Process.killProcess(android.os.Process.myPid());
    	}
        return super.onKeyDown(keyCode, event);
    }
}
