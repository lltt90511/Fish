package cc.yongdream.nshx;

import cc.yongdream.nshx.pps.R;
import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.Window;
import android.view.WindowManager;

public class FirstPage extends Activity {

	private final int SPLASH_DISPLAY_LENGHT = 2000; // 延迟2秒 
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,  WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		
		setContentView(R.layout.first_page);
        new Handler().postDelayed(new Runnable() {  
            public void run() {  
                Intent mainIntent = new Intent(FirstPage.this, mainActivity.class);  
                FirstPage.this.startActivity(mainIntent);  
                FirstPage.this.finish();  
            }  
  
        }, SPLASH_DISPLAY_LENGHT);
	}

}
