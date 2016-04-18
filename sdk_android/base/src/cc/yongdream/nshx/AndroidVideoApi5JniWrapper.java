package cc.yongdream.nshx;

import java.util.List;

import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.Size;
import android.util.Log;
import android.view.SurfaceView;
 
/**
 * Wrapper for Android Camera API. Used by Mediastreamer to record 
 * video from webcam.
 * This file depends only on Android SDK >= 5
 */
public class AndroidVideoApi5JniWrapper {
	
    private static int numCamera;
    private static int cameraCurrentId;
	
	static public native void setAndroidSdkVersion(int version);
	public static native void putImage(long nativePtr, byte[] buffer);
	
	//添加前后设置
	static public native void setFrontOrBack(long nativePtr, int isFront);
	
	static public void activateAutoFocus(Object cam) {
		Log.d("mediastreamer", "Turning on autofocus on camera " + cam);
		Camera camera = (Camera) cam;
		if (camera != null && (camera.getParameters().getFocusMode() == Parameters.FOCUS_MODE_AUTO || camera.getParameters().getFocusMode() == Parameters.FOCUS_MODE_MACRO))
			camera.autoFocus(null); // We don't need to do anything after the focus finished, so we don't need a callback
	}
	
	//添加前后控制
	//相机数量：1为只有后置摄像头；2为前后摄像头，默认为前置
	public static Object startRecording(int width, int height, int fps, int rotation, final long nativePtr) {
		Log.e("mediastreamer", "startRecording(" +  ", " + width + ", " + height + ", " + fps + ", " + rotation + ", " + nativePtr + ")");
//		Camera camera = Camera.open(); 
		int isfront = 0;

		numCamera = Camera.getNumberOfCameras();
        CameraInfo info = new CameraInfo();
        for(int i = 0;i< numCamera;i++){
        	Camera.getCameraInfo(i, info);
//        	if(info.facing == CameraInfo.CAMERA_FACING_BACK){
//        		cameraCurrentId = i;
//        	}
        	if(info.facing == CameraInfo.CAMERA_FACING_FRONT){
        		cameraCurrentId = i;
        	}        
        }
        
		if (numCamera > 1){
			isfront = 1;
		}else{
			isfront = 0;
			cameraCurrentId = 0;
		}
        Camera camera = Camera.open(cameraCurrentId); 
//        Camera camera = Camera.open(0); 
		camera.setDisplayOrientation(90);
		applyCameraParameters(camera, width, height, fps);
		
		setFrontOrBack(nativePtr, isfront);
		  
		camera.setPreviewCallback(new Camera.PreviewCallback() {
			public void onPreviewFrame(byte[] data, Camera camera) {
				// forward image data to JNI
				putImage(nativePtr, data);
				Log.e("err", "putImage java+++++++++++++" + cameraCurrentId + "+++++++++++++++++");
			}
		});		
		
		camera.startPreview();
		Log.e("mediastreamer", "Returning camera object: " + camera);
		return camera; 
	} 
	
	public static void stopRecording(Object cam) {
		Log.d("mediastreamer", "stopRecording(" + cam + ")"); 
		Camera camera = (Camera) cam;
		 
		if (camera != null) {
			camera.setPreviewCallback(null);
			camera.stopPreview();
			camera.release(); 
		} else {
			Log.i("mediastreamer", "Cannot stop recording ('camera' is null)");
		}
	} 
	
	public static void setPreviewDisplaySurface(Object cam, Object surf) {
		Log.d("mediastreamer", "setPreviewDisplaySurface(" + cam + ", " + surf + ")");
		Camera camera = (Camera) cam;
		SurfaceView surface = (SurfaceView) surf;
		try {
			//设置预览
			camera.setPreviewDisplay(surface.getHolder());
			//surface.requestLayout();
		} catch (Exception exc) {
			exc.printStackTrace(); 
		}
	}
	
	public static Object switchCapture(Object surf, int width, int height, final long nativePtr ){
		SurfaceView surface = (SurfaceView) surf;
		Camera camera = Camera.open((cameraCurrentId + 1) % numCamera);
        cameraCurrentId = (cameraCurrentId + 1) % numCamera;
        camera.setDisplayOrientation(90);
//        CameraInfo info = new CameraInfo();
//		Camera.getCameraInfo(cameraCurrentId, info);
		
        try {
			//设置预览
			camera.setPreviewDisplay(surface.getHolder());
		} catch (Exception exc) {
			exc.printStackTrace(); 
		}
		//applyCameraParameters(camera, 320, 240, 5);
		applyCameraParameters(camera, width, height, 5);
		surface.requestLayout();
		camera.setPreviewCallback(new Camera.PreviewCallback() {
			public void onPreviewFrame(byte[] data, Camera camera) {
				// forward image data to JNI
				putImage(nativePtr, data);
//				if (i++ == 30){
//					String ROOT_PATH = Environment.getExternalStorageDirectory().getPath() + "/";
//					File pictureFile = new File(ROOT_PATH, "campic.jpg");
//					if (!pictureFile.exists()) {
//						try {
//							pictureFile.createNewFile();
//							Camera.Parameters parameters = camera.getParameters();
//							Size size = parameters.getPreviewSize();
//							YuvImage image = new YuvImage(data,
//									parameters.getPreviewFormat(), size.width, size.height,
//									null);
//							FileOutputStream filecon = new FileOutputStream(pictureFile);
//							image.compressToJpeg(
//									new Rect(0, 0, image.getWidth(), image.getHeight()),
//									90, filecon);
//						} catch (IOException e) {
//							e.printStackTrace();
//						}
//					}
//				}
				//Log.e("err", "putImage java+++++++++2++++++++++++++++++++");
			}
		});	
        camera.startPreview();
        //Log.e("err", "++++++++++++++switchCapture++++++" + info.orientation + "+++++++++");
        
        return camera;
	}
	
	protected static void applyCameraParameters(Camera camera, int width, int height, int requestedFps) {
		Parameters params = camera.getParameters();
		 
		params.setPreviewSize(width, height); 
		params.setPreviewFrameRate(15);
//		List<Integer> supported = params.getSupportedPreviewFrameRates();
//		if (supported != null) {
//			int nearest = Integer.MAX_VALUE;
//			for(Integer fr: supported) {
//				int diff = Math.abs(fr.intValue() - requestedFps);
//				if (diff < nearest) {
//					nearest = diff;
//					params.setPreviewFrameRate(fr.intValue());
//				}
//			}
//			Log.d("mediastreamer", "Preview framerate set:" + params.getPreviewFrameRate());
//		}
		Log.e("mediastreamer", "Preview framerate set:" + params.getPreviewFrameRate());
		camera.setParameters(params);		
	}
	
	static public int[] selectNearestResolutionAvailable(int requestedW, int requestedH) {
		Log.e("mediastreamer", "++++++++++++++++++++++++++++++++++++select+++++++++++++");
		Camera camera = Camera.open();
		List<Size> r = camera.getParameters().getSupportedPreviewSizes();
		camera.release();
		
		Log.e("mediastreamer", "++++++++++++++++++++++++++++++++++++select+++++++++++++");
		// inversing resolution since webcams only support landscape ones
		if (requestedH > requestedW) {
			int t = requestedH;
			requestedH = requestedW;
			requestedW = t;
		}
				
		List<Size> supportedSizes = r;

		if (supportedSizes == null) {
			Log.e("mediastreamer", "Failed to retrieve supported resolutions.");
			return null;
		}
		Log.d("mediastreamer", supportedSizes.size() + " supported resolutions :");
		for(Size s : supportedSizes) {
			Log.d("mediastreamer", "\t" + s.width + "x" + s.height);
		}
		int r1[] = null;
		
		int rW = Math.max(requestedW, requestedH);
		int rH = Math.min(requestedW, requestedH);
		
		try { 
			// look for nearest size
			Size result = null;
			int req = rW * rH;
			int minDist = Integer.MAX_VALUE;
			int useDownscale = 0;
			for(Size s: supportedSizes) {
				int dist = Math.abs(req - s.width * s.height);
				if (dist < minDist) {
					minDist = dist;
					result = s;
					useDownscale = 0;
				}
				
				/* MS2 has a NEON downscaler, so we test this too */
				int downScaleDist = Math.abs(req - s.width * s.height / 4);
				if (downScaleDist < minDist) {
					minDist = downScaleDist;
					result = s;
					useDownscale = 1;
				}
				if (s.width == rW && s.height == rH) {
					result = s;
					useDownscale = 0;
					break;
				}
			}
			r1 = new int[] {result.width, result.height, useDownscale};
			Log.e("mediastreamer", "resolution selection done (" + r1[0] + ", " + r1[1] + ", " + r1[2] + ")");
			return r1;
		} catch (Exception exc) {
			Log.e("mediastreamer", "resolution selection failed");
			exc.printStackTrace();
			return null;
		}	
	}
}

