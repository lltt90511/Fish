package cc.yongdream.nshx;

import java.io.File;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxRenderer;

import android.media.MediaPlayer;
import android.media.MediaRecorder;

public class AudioRecorderUtil {
	
	private static MediaRecorder mediaRecorder;
	private static MediaPlayer mediaPlayer;
    public static boolean isRecording = false;
    public static boolean isPlaying = false;
    private static File file = new File(Util.writePathString,"audiorecorder.amr");;
    private static File copyFile = new File(Cocos2dxHelper.getCocos2dxWritablePath(),"audiorecorder.amr");
    
	public static void startAudioRecorder(){
		 try {
	            if (file.exists()) {
	                file.delete();
	            }
	            mediaRecorder = new MediaRecorder();
	            // 设置音频录入源
	            mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
	            // 设置录制音频的输出格式
	            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.RAW_AMR);
	            // 设置音频的编码格式
	            mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
	            // 设置录制音频文件输出文件路径
	            mediaRecorder.setOutputFile(file.getAbsolutePath());
	            mediaRecorder.setMaxDuration(60000);
	            // 准备、开始
	            mediaRecorder.prepare();
	            mediaRecorder.start();
	            
	            isRecording=true;
	     } 
		 catch (Exception e) {
	            e.printStackTrace();
	     }
	}
	
	public static void stopAudioRecorder(){
		if (isRecording) {
			mediaRecorder.stop();
			mediaRecorder.release();
			mediaRecorder = null;
			isRecording = false;
			
			int seconds = 0;
			int isSuccess = 0;
			try {
				mediaPlayer = new MediaPlayer();
				mediaPlayer.reset();
				mediaPlayer.setDataSource(file.getAbsolutePath());
				mediaPlayer.prepare();
				seconds = mediaPlayer.getDuration()/1000;
				mediaPlayer.release();
				mediaPlayer = null;
				if (seconds < 2) {
					
				}else {
					Util.copyFile(file, copyFile);
					isSuccess = 1;
				}
				Util.deleteFile(file);
			}catch(Exception e) {
				e.printStackTrace();
			}
			Cocos2dxRenderer.handleOnStopAudioRecorder(isSuccess,copyFile.getAbsolutePath(),seconds);
		}
	}
	
	public static void playAudio(String filePath){
//		String temp = Util.writePathString+"/audio.amr";
//		Util.copyFile(new File(filePath),new File(temp));
//		Uri uri = Uri.parse("file://"+temp); 
//		Intent intent = new Intent(Intent.ACTION_VIEW);
//		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//		intent.setDataAndType(uri, "audio");
//		Util.activityInstance.startActivity(intent);
		if (isPlaying) {
			return;
		}else {
			try {
				isPlaying = true;
				String temp = Util.writePathString+"/audio.amr";
				File fileTmp = new File(temp);
				Util.copyFile(new File(filePath),fileTmp);
				mediaPlayer = new MediaPlayer();
				mediaPlayer.reset();
				mediaPlayer.setDataSource(fileTmp.getAbsolutePath());
				mediaPlayer.prepare();
				mediaPlayer.start();
				mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
					
					@Override
					public void onCompletion(MediaPlayer mp) {
						// TODO Auto-generated method stub
						playNextRecord();
					}
				});
				mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
					
					@Override
					public boolean onError(MediaPlayer mp, int what, int extra) {
						// TODO Auto-generated method stub
						playNextRecord();
						return false;
					}
				});
			}catch (Exception e) {
				e.printStackTrace();
				playNextRecord();
			}
		}
	}
	
	public static void playNextRecord() {
		if (mediaPlayer != null) {
			mediaPlayer.release();
			mediaPlayer = null;
		}
		isPlaying = false;
		Cocos2dxRenderer.handleOnPlayNextRecord();
	}
	
	public static void cancelAudioRecorder(){
		if (isRecording) {
			mediaRecorder.stop();
			mediaRecorder.release();
			mediaRecorder = null;
			isRecording = false;
			Util.deleteFile(file);
		}
	}
}
