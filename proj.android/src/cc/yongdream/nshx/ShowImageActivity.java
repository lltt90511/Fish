package cc.yongdream.nshx;

import java.io.File;

import com.umeng.analytics.game.UMGameAgent;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.widget.ImageView;
import cc.yongdream.fruit.R;
public class ShowImageActivity extends Activity {
    private String logTag = "exception";
    private ImageView view; 
    private String path;
    @Override 
    protected void onCreate(Bundle savedInstanceState) { 
        super.onCreate(savedInstanceState); 
        setContentView(R.layout.photoview);
        
        Bundle bundle = this.getIntent().getExtras();
        path = (String)bundle.get("path");
        try { 
            view = (ImageView) findViewById(R.id.my_imageView);
            Bitmap b = convertToBitmap(path); 
            view.setImageBitmap(b); 
            setContentView(view);
        } catch (Exception e) { 
        	e.printStackTrace();
//            Log.v(logTag, e.getMessage()); 
//            throw new RuntimeException(e); 
        } 
    } 
    
    public Bitmap convertToBitmap(String path) {
    	File file = new File(path);
    	BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
    	return bitmap;
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