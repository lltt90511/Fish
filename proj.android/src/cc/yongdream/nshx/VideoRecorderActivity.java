package cc.yongdream.nshx;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxRenderer;

import cc.yongdream.fruit.R;
import com.opensource.utils.DateUtil;
import com.opensource.utils.StringUtil;
import com.umeng.analytics.game.UMGameAgent;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.media.CamcorderProfile;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.media.MediaRecorder.OnErrorListener;
import android.media.MediaRecorder.OnInfoListener;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.provider.MediaStore.Images.Thumbnails;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;

public class VideoRecorderActivity extends BaseActivity implements SurfaceHolder.Callback, OnInfoListener, OnErrorListener{
	private static final int MEDIA_TYPE_IMAGE = 1;
	private static final int MEDIA_TYPE_VIDEO = 2;
	private static final String TAG = VideoRecorderActivity.class.getSimpleName();
	
	private File copyFile = new File(Cocos2dxHelper.getCocos2dxWritablePath(),getVideoFileName("_copyed"));
	public void setOnInfoListener (OnInfoListener l){
		
	}
	public boolean onError (MediaPlayer mp, int what, int extra){
		return true;
	}
	private SurfaceView mSurfaceView;
	private ImageButton mIbtnCancel;
	private ImageButton mIbtnOk;
	private ImageButton mIbtnChange;
	private Button mButton;
	private TextView mTvTimeCount;
	
	private SurfaceHolder mSurfaceHolder;
	private MediaRecorder mMediaRecorder;
	private Camera mCamera;
	private int currentCameraIndex = 0;
	
	private File mOutputFile;
	
	private boolean mIsRecording = false;
	
	private Resources mResources;
	private String mPackageName;
	
	private List<Size> mSupportVideoSizes;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Bundle bundle = this.getIntent().getExtras(); 
		int id = (Integer)bundle.get("type");

		mResources = getResources();
		mPackageName = getPackageName();
		
		if (id == 1) {
			setContentView(R.layout.activity_video_recorder);
			initView();
		}else if (id == 2) {
			onGallery();
		}
	}
	
	public void onGallery(){
		Intent intent = new Intent(Intent.ACTION_PICK, null);
		intent.setDataAndType(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, "video/mp4");
       
    	//Intent localIntent2 = Intent.createChooser(localIntent, "选择图片");      
    	startActivityForResult(intent, 2);  	
	}
	 
	@TargetApi(Build.VERSION_CODES.GINGERBREAD_MR1)
	@SuppressLint("NewApi")
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.e("videorecorderactivity onactivityresult", "requestCode "+requestCode+"  resultCode  "+resultCode);
		switch (requestCode) {
			case 2:	
				try {	
					if (data == null) {
						finish();
						return;
					}
					Uri uri = data.getData();
					String[] proj = { MediaStore.Video.Media.DATA };
					Cursor actualimagecursor = extracted(uri, proj);	 
					int actual_image_column_index = actualimagecursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA);	 
					actualimagecursor.moveToFirst();	 
					String img_path = actualimagecursor.getString(actual_image_column_index);
					File file = new File(img_path);
					MediaMetadataRetriever retriever = new MediaMetadataRetriever();
			        retriever.setDataSource(file.getAbsolutePath());
			        Log.e("videorecorderactivity onactivityresult",retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE));
			        if (retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE).equals("video/mp4") == false) {
			        	new AlertDialog.Builder(VideoRecorderActivity.this)
						.setTitle("提示")
						.setMessage("不支持的视频格式，请选择MP4格式的视频！")
						.setPositiveButton("确定", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								finish();
							}
						}).show();
			        	return;
			        }
					//data.putExtra(Config.YUNINFO_RESULT_DATA, mOutputFile);
					Util.copyFile(file,copyFile);
					createVideoThumbnail(copyFile);
					//mOutputFile.deleteOnExit();
					//Util.deleteFile(mOutputFile);
					Cocos2dxRenderer.handelOnConvertFinish(copyFile.getAbsolutePath());
					finish();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					new AlertDialog.Builder(VideoRecorderActivity.this)
					.setTitle("提示")
					.setMessage("不支持的视频格式，请选择MP4格式的视频！")
					.setPositiveButton("确定", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							finish();
						}
					}).show();
					return;
				}	
				break;
			default:
	        	 finish();
	        	 return ;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	@SuppressWarnings("deprecation")
	private Cursor extracted(Uri uri, String[] proj) {
		return managedQuery(uri,proj,null,null,null);
	}
	@SuppressWarnings("deprecation")
	private void initView() {
		
		mSurfaceView = (SurfaceView) findViewById(mResources.getIdentifier("yuninfo_sv_recorder_preview", "id", mPackageName));
		mButton = (Button) findViewById(mResources.getIdentifier("yuninfo_btn_video_record", "id", mPackageName));
		mIbtnCancel = (ImageButton) findViewById(mResources.getIdentifier("yuninfo_ibtn_video_cancel", "id", mPackageName));
		mIbtnOk = (ImageButton) findViewById(mResources.getIdentifier("yuninfo_ibtn_video_ok", "id", mPackageName));
		mIbtnChange = (ImageButton) findViewById(mResources.getIdentifier("yuninfo_ibtn_video_change", "id", mPackageName));
		mIbtnCancel.setOnClickListener(mCancelListener);
		mIbtnOk.setOnClickListener(mOkListener);
		mIbtnChange.setOnClickListener(onChangeListener);
		mIbtnChange.setVisibility(View.VISIBLE);
		mIbtnCancel.setVisibility(View.INVISIBLE);
		mIbtnOk.setVisibility(View.INVISIBLE);
		mTvTimeCount = (TextView) findViewById(mResources.getIdentifier("yuninfo_tv_recorder_time_count", "id", mPackageName));
		mTvTimeCount.setVisibility(View.INVISIBLE);
		
		mButton.setBackgroundResource(mResources.getIdentifier("yuninfo_btn_video_start", "drawable", mPackageName));
		mButton.setOnClickListener(mBtnListener);
		
		mSurfaceHolder = mSurfaceView.getHolder();
		mSurfaceHolder.addCallback(this);
		
		if(Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
			try {
				mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
			} catch (Exception e) {
				Log.d(TAG, e.toString());
			}
		}
		
	}
	
	private void exit(final int resultCode, final Intent data) {
		if(mIsRecording) {
			new AlertDialog.Builder(VideoRecorderActivity.this)
			.setTitle("提示")
			.setMessage("正在录制视频，是否退出？")
			.setPositiveButton("确定", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					stopRecord();
					if(resultCode == RESULT_CANCELED) {
						Util.deleteFile(mOutputFile);
					}
					setResult(resultCode, data);
					finish();
				}
			})
			.setNegativeButton("取消", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					
				}
			}).show();
			return;
		}
		if(resultCode == RESULT_CANCELED) {
			Util.deleteFile(mOutputFile);
		}
		setResult(resultCode, data);
		finish();
	}
	
	@SuppressLint("HandlerLeak")
	private Handler mHandler = new Handler() {
		
		@Override
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case Config.YUNINFO_ID_TIME_COUNT:
				if(mIsRecording) {
					if(msg.arg1 > msg.arg2) {
//					mTvTimeCount.setVisibility(View.INVISIBLE);
						mTvTimeCount.setText("00:00");
						stopRecord();
					} else {
						mTvTimeCount.setText("00:" + (msg.arg2 - msg.arg1));
						Message msg2 = mHandler.obtainMessage(Config.YUNINFO_ID_TIME_COUNT, msg.arg1 + 1, msg.arg2);
						mHandler.sendMessageDelayed(msg2, 1000);
					}
				}
				break;

			default:
				break;
			}
		};
		
	};
	
	private View.OnClickListener mBtnListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			if(mIsRecording) {
				stopRecord();
			} else {
				startRecord();
			}
		}
	};
	
	private View.OnClickListener mCancelListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			exit(RESULT_CANCELED, null);
		}
	};
	
	private View.OnClickListener mOkListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			Intent data = new Intent();
			if(mOutputFile != null && !StringUtil.isEmpty(mOutputFile.getAbsolutePath())) {
				data.putExtra(Config.YUNINFO_RESULT_DATA, mOutputFile);
				Util.copyFile(mOutputFile,copyFile);
				createVideoThumbnail(copyFile);
//				mOutputFile.deleteOnExit();
				Util.deleteFile(mOutputFile);
				Cocos2dxRenderer.handelOnConvertFinish(copyFile.getAbsolutePath());
			}
			exit(RESULT_OK, data);
		}
	};
	
	@SuppressLint("NewApi")
	private View.OnClickListener onChangeListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// TODO Auto-generated method stub
			int cameraCount = 0;
		    Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
		    cameraCount = Camera.getNumberOfCameras(); // get cameras number
		          
		    for ( int camIdx = 0; camIdx < cameraCount;camIdx++ ) {
		        Camera.getCameraInfo( camIdx, cameraInfo ); // get camerainfo
		        if ( cameraInfo.facing != currentCameraIndex) { // 代表摄像头的方位，目前有定义值两个分别为CAMERA_FACING_FRONT前置和CAMERA_FACING_BACK后置
		            try {            
		            	//mCamera = Camera.open( camIdx );
		            	mIbtnChange.setVisibility(View.INVISIBLE);
		            	currentCameraIndex = camIdx;
		            	mCamera.stopPreview();
		            	releaseCamera();
		            	try {
			            	openCamera();
			            	mCamera.setPreviewDisplay(mSurfaceHolder);
			            	mCamera.startPreview();
		            	}catch (Exception e) {
		            		e.printStackTrace();
		            	}
		            } catch (Exception e) {
		                e.printStackTrace();
		            }
		        }
		    }
		}
	};
	
	private Bitmap createVideoThumbnail(File file) {
        Bitmap bitmap = null;
        try {
            bitmap = ThumbnailUtils.createVideoThumbnail(file.getAbsolutePath(), Thumbnails.MINI_KIND);
            bitmap = ThumbnailUtils.extractThumbnail(bitmap, 160, 240);
            String imgPath = file.getAbsolutePath().replaceAll(".mp4", "_mp4.jpg");
            File imgFile = new File(imgPath);
            try {
				OutputStream outputStream = new FileOutputStream(imgFile);
				bitmap.compress(Bitmap.CompressFormat.JPEG,	30, outputStream);
				try {
					outputStream.flush();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				try {
					outputStream.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
        } catch(IllegalArgumentException ex) {
            // Assume this is a corrupt video file
        } catch (RuntimeException ex) {
            // Assume this is a corrupt video file.
        } finally {
            try {
                //retriever.release();
            } catch (RuntimeException ex) {
                // Ignore failures while cleaning up.
            }
        }
        return bitmap;
    }
	
	private String getVideoFileName(String sig) {
        Date date = new Date(System.currentTimeMillis());
        SimpleDateFormat dateFormat = new SimpleDateFormat(
                "'VID'_yyyyMMdd_HHmmss");
        return dateFormat.format(date) + sig+".mp4";
    }
	
	@SuppressLint("NewApi")
	private void openCamera() {
		//Open camera
		try {
			//currentCameraIndex = 0;
			this.mCamera = Camera.open(currentCameraIndex);
			Camera.Parameters parameters = mCamera.getParameters();
			parameters.setRotation(90);
			System.out.println(parameters.flatten());
			parameters.set("orientation", "portrait");
//			parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
			mCamera.setParameters(parameters);
			mCamera.lock();
			if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
				try {
					mCamera.setDisplayOrientation(90);
				} catch (NoSuchMethodError e) {
					e.printStackTrace();
				}
			}
			mSupportVideoSizes = parameters.getSupportedVideoSizes();
			if(mSupportVideoSizes == null || mSupportVideoSizes.isEmpty()) {  //For some device can't get supported video size
				String videoSize = parameters.get("video-size");
				Log.d(TAG, videoSize.toString());
				mSupportVideoSizes = new ArrayList<Camera.Size>();
				if(!StringUtil.isEmpty(videoSize)) {
					String [] size = videoSize.split("x");
					if(size.length > 1) {
						try {
							int width = Integer.parseInt(size[0]);
							int height = Integer.parseInt(size[1]);
							mSupportVideoSizes.add(mCamera.new Size(width, height));
						} catch (Exception e) {
							Log.d(TAG, e.toString());
						}
					}
				}
			}
			for (Size size : mSupportVideoSizes) {
				Log.d(TAG, size.width + "<>" + size.height);
			}
		} catch (Exception e) {
			Log.d(TAG, "Open Camera error\n" + e.toString());
		}
	}
	
	@SuppressLint("NewApi")
	private boolean initVideoRecorder() {

		mCamera.unlock();
		mMediaRecorder = new MediaRecorder();

		// Step 1: Unlock and set camera to MediaRecorder
		//LogUtil.i("Camera", mCamera);
		//LogUtil.i("Camera", mMediaRecorder);
		mMediaRecorder.setCamera(mCamera);
		
		// Step 2: Set sources   
//		recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
//	    recorder.setVideoSource(MediaRecorder.VideoSource.DEFAULT);
//	    recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
//	    recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
//	    recorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
		try {
			mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
			mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);
		} catch (Exception e) {
			mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.DEFAULT);
			mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.DEFAULT);
			e.printStackTrace();
		}

		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
			try {
//				mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
//				mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
//				mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
//				int width = 800;
//				int height = 480;
//				if(mSupportVideoSizes != null && !mSupportVideoSizes.isEmpty()) {
//					int lwd = Math.abs(mSupportVideoSizes.get(0).width-800);
//					for (Size size : mSupportVideoSizes) {
//						int wd = Math.abs(size.width - 800);
//						if(wd < lwd) {
//							width = size.width;
//							height = size.height;
//							lwd = wd;
//						} else {
//							break;
//						}
//					}
//				}
//				mMediaRecorder.setVideoSize(width, height);//视频尺寸    
//				mMediaRecorder.setVideoFrameRate(15);//视频帧频率       
//				mMediaRecorder.setMaxDuration(30000);//最大期限 
				CamcorderProfile lowProfile = CamcorderProfile.get(CamcorderProfile.QUALITY_LOW);
				CamcorderProfile hightProfile = CamcorderProfile.get(CamcorderProfile.QUALITY_HIGH);
				if(lowProfile != null && hightProfile != null) {
//					int audioBitRate = lowProfile.audioBitRate > 128000 ? 128000 : lowProfile.audioBitRate;
//					lowProfile.audioBitRate = audioBitRate > hightProfile.audioBitRate ? hightProfile.audioBitRate : audioBitRate;
//					lowProfile.audioSampleRate = 48000 > hightProfile.audioSampleRate ? hightProfile.audioSampleRate : 48000;
////					lowProfile.duration = 20 > hightProfile.duration ? hightProfile.duration : 20;
////					lowProfile.videoFrameRate = 20 > hightProfile.videoFrameRate ? hightProfile.videoFrameRate : 20;
//					lowProfile.duration = hightProfile.duration;
//					lowProfile.videoFrameRate = hightProfile.videoFrameRate;
//					lowProfile.videoBitRate = 1500000 > hightProfile.videoBitRate ? hightProfile.videoBitRate : 1500000;;
					if(mSupportVideoSizes != null && !mSupportVideoSizes.isEmpty()) {
						int width = 800;
						int height = 480;
						Collections.sort(mSupportVideoSizes, new SizeComparator());
						int lwd = Math.abs(mSupportVideoSizes.get(0).width-800);
						for (Size size : mSupportVideoSizes) {
							int wd = Math.abs(size.width - 800);
							if(wd < lwd) {
								width = size.width;
								height = size.height;
								lwd = wd;
							}
						}
						lowProfile.videoFrameWidth = width;
						lowProfile.videoFrameHeight = height;
					}
					lowProfile.audioCodec = MediaRecorder.AudioEncoder.AAC;
					lowProfile.videoCodec = MediaRecorder.VideoEncoder.H264;
					lowProfile.fileFormat = MediaRecorder.OutputFormat.MPEG_4;
					lowProfile.videoBitRate = 900000;
					lowProfile.audioBitRate = 48000;
					lowProfile.duration = 30;
					lowProfile.videoFrameRate = 15;
					System.out.println("=="+lowProfile.audioBitRate);
					System.out.println("=="+lowProfile.audioChannels);
					System.out.println("=="+lowProfile.audioCodec);
					System.out.println("=="+lowProfile.audioSampleRate);
					System.out.println("=="+lowProfile.duration);
					System.out.println("=="+lowProfile.fileFormat);
					System.out.println("=="+lowProfile.quality);
					System.out.println("=="+lowProfile.videoBitRate);
					System.out.println("=="+lowProfile.videoCodec);
					System.out.println("=="+lowProfile.videoFrameHeight);
					System.out.println("=="+lowProfile.videoFrameWidth);
					System.out.println("=="+lowProfile.videoFrameRate);

					mMediaRecorder.setProfile(lowProfile);
				}
			} catch (Exception e) {
				try {
					mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
				} catch (Exception ex) {
					e.printStackTrace();
				}
				try {
					mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.DEFAULT);
				} catch (Exception ex) {
					e.printStackTrace();
				}
				if(mSupportVideoSizes != null && !mSupportVideoSizes.isEmpty()) {
					Collections.sort(mSupportVideoSizes, new SizeComparator());
					Size size = mSupportVideoSizes.get(0);
					try {
						mMediaRecorder.setVideoSize(size.width, size.height);
					} catch (Exception ex) {
						e.printStackTrace();
					}
				} else {
					try {
						mMediaRecorder.setVideoSize(640, 480); // Its is not on android docs but
						// it needs to be done. (640x480
						// = VGA resolution)
					} catch (Exception ex) {
						e.printStackTrace();
					}
				}
				e.printStackTrace();
			}
		} else {
			try {
				mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
			} catch (Exception e) {
				e.printStackTrace();
			}
			try {
				mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.DEFAULT);
			} catch (Exception e) {
				e.printStackTrace();
			}
			if(mSupportVideoSizes != null && !mSupportVideoSizes.isEmpty()) {
				Collections.sort(mSupportVideoSizes, new SizeComparator());
				Size size = mSupportVideoSizes.get(0);
				try {
					mMediaRecorder.setVideoSize(size.width, size.height);
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				try {
					mMediaRecorder.setVideoSize(640, 480); // Its is not on android docs but
					// it needs to be done. (640x480
					// = VGA resolution)
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

		}
			
		// Step 4: Set output file
		mOutputFile = new File(Util.writePathString, "Video_" 
				+ DateUtil.getSystemDate("yyyy_MM_dd_HHmmss") + ".mp4");
		mMediaRecorder.setOutputFile(mOutputFile.getAbsolutePath());

		// Step 5: Set the preview output
		mMediaRecorder.setPreviewDisplay(mSurfaceHolder.getSurface());
		
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
			try {
				mMediaRecorder.setOrientationHint(90);
			} catch (NoSuchMethodError e) {
				e.printStackTrace();
			}
		}

		
		// Step 6: Prepare configured MediaRecorder

//		 mMediaRecorder.setCamera(mCamera);
//
//	        mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.CAMCORDER);
//	        mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);
//	        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
//
//	            mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);
//	            mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
//	            mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.DEFAULT);
//
//	        } else {
//	        	CamcorderProfile camcorderProfile = CamcorderProfile.get(CamcorderProfile.QUALITY_HIGH);
//	        	mMediaRecorder.setProfile(camcorderProfile);
//
//	            mMediaRecorder.setVideoSize(720, 480);
//	        }
//
//	        mOutputFile = new File(Environment.getExternalStorageDirectory(), "Video_" 
//					+ DateUtil.getSystemDate("yyyy_MM_dd_HHmmss") + ".mp4");
//			mMediaRecorder.setOutputFile(mOutputFile.getAbsolutePath());
//	        mMediaRecorder.setMaxDuration(60000);
//	        mMediaRecorder.setPreviewDisplay(mSurfaceHolder.getSurface());
//
//	        try {
//	            mMediaRecorder.prepare();
//	        } catch (IllegalStateException e) {
//	            releaseMediaRecorder();
//	            return false;
//	        } catch (IOException e) {
//	            releaseMediaRecorder();
//	            return false;
//	        }
		return true;
	}
	
	private void releaseMediaRecorder() {
		if (mMediaRecorder != null) {
			mMediaRecorder.reset(); // clear recorder configuration
			mMediaRecorder.release(); // release the recorder object
			mMediaRecorder = null;
			mCamera.lock(); // lock camera for later use
		}
	}
	
	private void releaseCamera() {
		if (mCamera != null) {
			mCamera.release(); // release the camera for other applications
			mCamera = null;
		}
	}
	
	private void startRecord() {
		try {
			// initialize video camera
			if (initVideoRecorder()) {
				// Camera is available and unlocked, MediaRecorder is prepared,
				// now you can start recording
				//if (isPreview) {
					
				//}   
				
				mMediaRecorder.prepare();
				
				//mCamera.stopPreview();
				//mCamera.release();
				//mCamera = null;
				mMediaRecorder.setOnInfoListener(this);
				mMediaRecorder.setOnErrorListener(this);
				mMediaRecorder.start();
				mIbtnChange.setVisibility(View.INVISIBLE);
				mButton.setBackgroundResource(mResources.getIdentifier("yuninfo_btn_video_stop", "drawable", mPackageName));
//				mButton.setEnabled(false);
			} else {
				// prepare didn't work, release the camera
				releaseMediaRecorder();
				// inform user
				mButton.setBackgroundResource(mResources.getIdentifier("yuninfo_btn_video_start", "drawable", mPackageName));
			}
			mTvTimeCount.setVisibility(View.VISIBLE);
			mTvTimeCount.setText("00:0" + (Config.YUNINFO_MAX_VIDEO_DURATION / 1000));
			Message msg = mHandler.obtainMessage(Config.YUNINFO_ID_TIME_COUNT, 1, Config.YUNINFO_MAX_VIDEO_DURATION / 1000);
			mHandler.sendMessage(msg);
			mIsRecording = true;
	   } catch (IllegalStateException e) {
			Log.d("VideoPreview", "IllegalStateException preparing MediaRecorder: "	+ e.getMessage());
			releaseMediaRecorder();
			//return false;
		} catch (IOException e) {
			Log.d("VideoPreview", "IOException preparing MediaRecorder: " + e.getMessage());
			releaseMediaRecorder();
			//return false;
		} catch (Exception e) {
			showShortToast("该操作系统不支持此功能");
			e.printStackTrace();
			exit(RESULT_ERROR, null);
		}
	}
	

	private void stopRecord() {
		// stop recording and release camera
		Log.d(TAG, mOutputFile.getAbsolutePath());
		try {
			mMediaRecorder.stop(); // stop the recording
		} catch (Exception e) {
			if(mOutputFile != null && mOutputFile.exists()) {
				mOutputFile.delete();
				mOutputFile = null;
			}
			Log.d(TAG, e.toString());
		}
		releaseMediaRecorder(); // release the MediaRecorder object
		mCamera.lock(); // take camera access back from MediaRecorder
//		releaseCamera(); // release camera
		mButton.setBackgroundResource(mResources.getIdentifier("yuninfo_btn_video_start", "drawable", mPackageName));
		mIsRecording = false;
		
		mButton.setVisibility(View.GONE);
		mIbtnCancel.setVisibility(View.VISIBLE);
		mIbtnOk.setVisibility(View.VISIBLE);
		mIbtnChange.setVisibility(View.GONE);
	}
	
	/**
	 * 
	 * @param activity
	 * @param cameraId
	 * @param camera
	 */
	@SuppressLint("NewApi")
	public static void setCameraDisplayOrientation(Activity activity, int cameraId, Camera camera) {
	     Camera.CameraInfo info = new Camera.CameraInfo(); //Since API level 9
	     Camera.getCameraInfo(cameraId, info);
	     int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
	     int degrees = 0;
	     switch (rotation) {
	         case Surface.ROTATION_0: degrees = 0; break;
	         case Surface.ROTATION_90: degrees = 90; break;
	         case Surface.ROTATION_180: degrees = 180; break;
	         case Surface.ROTATION_270: degrees = 270; break;
	     }

	     int result;
	     if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
	         result = (info.orientation + degrees) % 360;
	         result = (360 - result) % 360;  // compensate the mirror
	     } else {  // back-facing
	         result = (info.orientation - degrees + 360) % 360;
	     }
	     camera.setDisplayOrientation(result);
	 }
	
	@Override
	protected void onResume() {
		super.onResume();
		openCamera();
		UMGameAgent.onResume(this);
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		releaseCamera();
		UMGameAgent.onPause(this);
	}


	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		if(mCamera != null) {
			try {
				mCamera.setPreviewDisplay(holder);
				mCamera.startPreview();
			} catch (Exception e) {
				Log.d(TAG, "Error setting camera preview: " + e.toString());
			}
		}
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		// TODO Auto-generated method stub
		mSurfaceHolder = holder;
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		if (mCamera != null) {
			try {
				mCamera.stopPreview();
				releaseCamera();
			} catch (Exception e) {
				Log.d(TAG, "Error setting camera preview: " + e.toString());
			}
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if(keyCode == KeyEvent.KEYCODE_BACK) {
			exit(RESULT_CANCELED, null);
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
	
	
	private class SizeComparator implements Comparator<Size> {

		@Override
		public int compare(Size lhs, Size rhs) {
			return rhs.width - lhs.width;
		}
	}


	@Override
	public void onError(MediaRecorder arg0, int arg1, int arg2) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void onInfo(MediaRecorder arg0, int arg1, int arg2) {
		// TODO Auto-generated method stub
		
	}	
}
