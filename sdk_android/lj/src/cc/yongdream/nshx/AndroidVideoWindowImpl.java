package cc.yongdream.nshx;


import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.SurfaceHolder.Callback;

public class AndroidVideoWindowImpl {
	private SurfaceView mVideoRenderingView;
	private SurfaceView mVideoPreviewView;
	
	private VideoWindowListener mListener;
	public static interface VideoWindowListener{
		void onVideoRenderingSurfaceReady(AndroidVideoWindowImpl vw, SurfaceView surface);
		void onVideoRenderingSurfaceDestroyed(AndroidVideoWindowImpl vw);
		
		void onVideoPreviewSurfaceReady(AndroidVideoWindowImpl vw, SurfaceView surface);
		void onVideoPreviewSurfaceDestroyed(AndroidVideoWindowImpl vw);
		
	};
	/**
	 * @param renderingSurface Surface created by the application that will be used to render decoded video stream
	 * @param previewSurface Surface created by the application used by Android's Camera preview framework
	 */
	public AndroidVideoWindowImpl(SurfaceView renderview, SurfaceView preview) {
//		super(context);
//		mSurfaceHolder = getHolder();
//		mSurfaceHolder.addCallback(this);
//		
//		mSurface = mSurfaceHolder.getSurface();
		mVideoRenderingView = renderview;
		mVideoPreviewView = preview;
		mListener = null;
	}
	
	public void init() {
		Log.i("mediastream", "mVideoRenderingView surface init" +mVideoRenderingView);
		Log.i("mediastream", "mVideoPreviewView surface init" +mVideoPreviewView);

		if (mVideoRenderingView != null){
			Log.i("mediastream", "mVideoRenderingView surface init ++++++++");

			mVideoRenderingView.getHolder().addCallback(new Callback(){
				public void surfaceChanged(SurfaceHolder holder, int format,
					int width, int height) {
					Log.i("mediastream", "Video display surface is being changed.");

					synchronized(AndroidVideoWindowImpl.this){
						holder.getSurface();
					}

					if (mListener!=null) mListener.onVideoRenderingSurfaceReady(AndroidVideoWindowImpl.this, mVideoRenderingView);
					Log.w("mediastream", "Video display surface changed");
				}

				public void surfaceCreated(SurfaceHolder holder) {
					Log.w("mediastream", "Video display surface created");
				}

				public void surfaceDestroyed(SurfaceHolder holder) {
					synchronized(AndroidVideoWindowImpl.this){
					}
							
					if (mListener!=null)
						mListener.onVideoRenderingSurfaceDestroyed(AndroidVideoWindowImpl.this);
					Log.d("mediastream", "Video display surface destroyed"); 
				}
				
			});
		}
		
		
		if (mVideoPreviewView != null){
			mVideoPreviewView.getHolder().addCallback(new Callback(){
				public void surfaceChanged(SurfaceHolder holder, int format,
						int width, int height) {
					Log.i("mediastream", "Video preview surface is being changed.");
					if (mListener!=null) 
						mListener.onVideoPreviewSurfaceReady(AndroidVideoWindowImpl.this, mVideoPreviewView);
					Log.w("mediastream", "Video preview surface changed");
				}

				public void surfaceCreated(SurfaceHolder holder) {
					Log.w("mediastream", "Video preview surface created");
				}

				public void surfaceDestroyed(SurfaceHolder holder) {
					if (mListener!=null)
						mListener.onVideoPreviewSurfaceDestroyed(AndroidVideoWindowImpl.this);
					Log.d("mediastream", "Video preview surface destroyed"); 
				}
			});
		}
		
	}
	
	public void setListener(VideoWindowListener l){
		mListener=l; 
	}
	
	public  static void reflashsurfaceview(){
		Log.e("hello", "reflash_surfaceview");
	}
	
	public Surface getSurface(){
		return mVideoRenderingView.getHolder().getSurface();
	}	
}
