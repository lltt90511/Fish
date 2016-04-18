package cc.yongdream.nshx;

import android.graphics.ImageFormat;
import android.hardware.Camera;
import android.util.Log;

public class AndroidVideoApi8JniWrapper {
	public static Object startRecording(int width, int height, int fps, int rotation, final long nativePtr) {
		Log.d("mediastreamer", "startRecording(" + ", " + width + ", " + height + ", " + fps + ", " + rotation + ", " + nativePtr + ")");
		Camera camera = Camera.open(); 

		AndroidVideoApi5JniWrapper.applyCameraParameters(camera, width, height, fps);
		  
		int bufferSize = (width * height * ImageFormat.getBitsPerPixel(camera.getParameters().getPreviewFormat())) / 8;
		camera.addCallbackBuffer(new byte[bufferSize]);
		camera.addCallbackBuffer(new byte[bufferSize]);
		
		camera.setPreviewCallbackWithBuffer(new Camera.PreviewCallback() {
			public void onPreviewFrame(byte[] data, Camera camera) {
				// forward image data to JNI
				AndroidVideoApi5JniWrapper.putImage(nativePtr, data);
				Log.e("err", "putImage java+++++++++++++++++++++++++++++");
				camera.addCallbackBuffer(data);
			}
		});
		 
		camera.startPreview();
		Log.e("mediastreamer", "Returning camera object: " + camera);
		return camera; 
	} 
	
	public static void stopRecording(Object cam) {
		Camera camera = (Camera) cam;
		 
		if (camera != null) {
			camera.setPreviewCallbackWithBuffer(null);
			camera.stopPreview();
			camera.release(); 
		} else {
			Log.i("mediastreamer", "Cannot stop recording ('camera' is null)");
		}
	} 

}
