package cc.yongdream.nshx;

import com.umeng.analytics.game.UMGameAgent;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;
import cc.yongdream.nshx.R;

public class VideoPlayActivity extends Activity{
	private VideoView videoView;
	private String path;
	@Override 
    protected void onCreate(Bundle savedInstanceState) { 
        super.onCreate(savedInstanceState); 
        setContentView(R.layout.videoview);
        
        Bundle bundle = this.getIntent().getExtras();
        path = (String)bundle.get("path");
        try { 
        	Uri uri = Uri.parse(path); 
        	videoView = (VideoView)this.findViewById(R.id.VideoView01); 
        	videoView.setMediaController(new MediaController(this)); 
        	videoView.setVideoURI(uri); 
        	videoView.start(); 
        	videoView.requestFocus();
        } catch (Exception e) { 
        	e.printStackTrace();
//            Log.v(logTag, e.getMessage()); 
//            throw new RuntimeException(e); 
        } 
    } 
	
	@Override
	protected void onResume() {
		super.onResume();
		UMGameAgent.onResume(this);
	}

	@Override
	protected void onPause() {
		super.onPause();
		UMGameAgent.onPause(this);
	}
}
