package cc.yongdream.nshx;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;

public class PopActivity extends Activity {
	public static String popUrl = "";
	WebView mWebView;
	final static Handler mHandler = new Handler();
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.pop_web);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mWebView = (WebView) findViewById(R.id.dpwebview);
        mWebView.setBackgroundColor(0);
        mWebView.loadUrl(popUrl);
        
		Button button = (Button)findViewById(R.id.webOk);
		button.setOnClickListener(new OnClickListener(){
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				PopActivity.this.finish();
			}
			
		});
    }
    
    @Override
    protected void onResume() {
        super.onResume();
    }
    
    @Override
    public void onPause() {
        super.onPause();
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
    }
    
	@Override
	public void onBackPressed() {
		
	}
}
