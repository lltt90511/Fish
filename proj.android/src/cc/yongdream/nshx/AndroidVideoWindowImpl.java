package cc.yongdream.nshx;


import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.SurfaceHolder.Callback;

public class AndroidVideoWindowImpl {
	private SurfaceView mVideoRenderingView;
	
	private VideoWindowListener mListener;
	public static interface VideoWindowListener{
		void onVideoRenderingSurfaceReady(AndroidVideoWindowImpl vw, SurfaceView surface);
		void onVideoRenderingSurfaceDestroyed(AndroidVideoWindowImpl vw);
		
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
		mListener = null;
	}
	
	public void init() {
		if (mVideoRenderingView != null){
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
