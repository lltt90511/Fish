package cc.yongdream.nshx;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.cocos2dx.lib.Cocos2dxHelper;

import com.umeng.analytics.game.UMGameAgent;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Bundle;
//import android.provider.DocumentsContract;
import android.provider.MediaStore; 
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import cc.yongdream.nshx.R;
public class PhotographActivity extends Activity { 
	 private Button creama=null;
	 
	 private Button gallery = null;
	   
    private ImageView img=null;
   
    private TextView text=null;
    private int cropX =0;
    private int cropY = 0;
    private  boolean isCrop = false;
    
    private File tempFile  = new File(Util.writePathString,getPhotoFileName("_old"));
    private File cropFile = new File(Util.writePathString,getPhotoFileName("_croped"));
    private File copyFile = new File(Cocos2dxHelper.getCocos2dxWritablePath(),getPhotoFileName("_copyed"));
   
    private static final int PHOTO_REQUEST_TAKEPHOTO = 1;// 拍照
    private static final int PHOTO_REQUEST_GALLERY = 2;// 从相册中选择
    private static final int PHOTO_REQUEST_CUT = 3;// 结果

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crama);
        init();
        Log.i("TAG-->","  temp:"+tempFile.getAbsolutePath()+"  crop:"+cropFile.getAbsolutePath());
        Bundle bundle = this.getIntent().getExtras(); 
        int id = (Integer)bundle.get("type");
        int crop = (Integer)bundle.get("crop");
        
       // _id = bundle.getString("id");
        if (crop == 1){
        	 cropX = (Integer)bundle.get("cropX");
        	 cropY = (Integer)bundle.get("cropY");
        	 isCrop = true;
        }else{
        	isCrop = false;
        }
        if (id == 1){ // PHOTO_REQUEST_TAKEPHOTO
        	onCamera();
        }
        if (id == 2){
        	onGallery();
        }
    }

    private void init() {
	    creama=(Button) findViewById(R.id.btn_creama);
	    
	    gallery =(Button) findViewById(R.id.btn_gallery);
	   
	    img=(ImageView) findViewById(R.id.img_creama);
	   
	    creama.setOnClickListener(cameraListener);
	    gallery.setOnClickListener(galleryListener);
	    text=(TextView) findViewById(R.id.text);
    }
    void resizeImage(Bitmap bit,File file,File out,boolean flag){
    	 BitmapFactory.Options options = new BitmapFactory.Options();
         options.inJustDecodeBounds = true;  
     
    	 Bitmap bitmap ;
    	 if (bit!= null){
    		 bitmap = bit;
    	 }else{
    		 bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
    	 }
    	 options.inJustDecodeBounds = false;   
         int bmpWidth  = bitmap.getWidth();   
         
         int bmpHeight  = bitmap.getHeight();  
         int scaleWidth ,scaleHeight;
         if (bmpWidth<640 && bmpHeight < 1136){
        	 if (!file.exists()){
        		 try{
	        	    OutputStream outputStream = new FileOutputStream(out);
	        	    bitmap.compress(Bitmap.CompressFormat.JPEG,30,outputStream );
	             	outputStream.flush();
	             	outputStream.close();
        		}catch(Exception e){
            		Log.e("photo resize",e.toString());
            		finish();
            		return ;
            	}finally{
            		//if (outputStream!=null)
            		//	outputStream.close();
            	}
            	 
             	sentPicToNext(out,true);
        	 }else{
        		 sentPicToNext(file,flag);
        	 }
         }else{
        	float x = (float) (640.0/(float)bmpWidth);
        	float y = (float) (1136.0/(float)bmpHeight);
        	float scale = x;
        	if (y<x){
        		scale = y;
        	}
        	
        	x = (bmpWidth * scale);
        	y = (bmpHeight * scale);
        	scaleWidth  =(int)( x / bmpWidth);
        	scaleHeight =(int)( y / bmpHeight);
            Matrix matrix = new Matrix();   
            matrix.postScale(scaleWidth, scaleHeight);//产生缩放后的Bitmap对象   
        	//bitmap = BitmapFactory.decodeFile(tempFile.getAbsolutePath(), options);
            Bitmap resizeBitmap  = ThumbnailUtils.extractThumbnail(bitmap, (int)x, (int)y);
        	OutputStream outputStream= null;
        	try{
        		outputStream = new FileOutputStream(out);
            	resizeBitmap.compress(Bitmap.CompressFormat.JPEG,30,outputStream );
            	outputStream.flush();
            	outputStream.close();
            	sentPicToNext(out,true);
            	
        	}catch(Exception e){
        		Log.e("photo resize",e.toString());
        		finish();
        	}finally{
        		//if (outputStream!=null)
        		//	outputStream.close();
        	}
        	 
         }
    }
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    	//super.onActivityResult(requestCode, resultCode, data);
    	Log.e("##############################################################", "requestCode "+requestCode+"  resultCode  "+resultCode);

    	if (isCrop){
	        switch (requestCode) {
		        case PHOTO_REQUEST_TAKEPHOTO:// 当选择拍照时调用
		        	if (!tempFile.exists()){
		        		finish();
		        		return ;
		        	}
		        	startPhotoZoom(Uri.fromFile(tempFile),Uri.fromFile(cropFile));
		            break;
		        case PHOTO_REQUEST_GALLERY:// 当选择从本地获取图片时
		        	if (data == null){
		        		finish();
		        		return ;
		        	}
		            startPhotoZoom(data.getData(),Uri.fromFile(cropFile));
		            break;
		        case PHOTO_REQUEST_CUT:// 返回的结果
		        	if (data == null){
		        		finish();
		        		return ;
		        	}
		            sentPicToNext(cropFile ,true);
		            
		            break;
		        default:
		        	 finish();
		        	 return ;
	        }
    	}else{
    		  switch (requestCode) {
		        case PHOTO_REQUEST_TAKEPHOTO:// 当选择拍照时调用
		        	if (!tempFile.exists()){
		        		finish();
		        		return ;
		        	}
		        	
		        	resizeImage(null,tempFile,cropFile,true);
		               
		               
		        	
		            break;
		        case PHOTO_REQUEST_GALLERY:// 当选择从本地获取图片时
		        	if (data == null){
		        		finish();
		        		return ;
		        	}
		        	try{
		        	resizeImage(MediaStore.Images.Media.getBitmap(this.getContentResolver(), data.getData()),tempFile,cropFile,false);
		        	}catch (Exception e) {
						Log.e("resizeImage(MediaStore.Images.Media",e.toString());
					}
		            break;
    		  }
    	}
    	super.onActivityResult(requestCode, resultCode, data);
    	
    }
    private OnClickListener cameraListener=new OnClickListener(){
	
        @Override
        public void onClick(View arg0) {
            // TODO Auto-generated method stub
           
            onCamera();
        }
	
	   
    };
    private OnClickListener galleryListener=new OnClickListener(){
    	
        @Override
        public void onClick(View arg0) {
            // TODO Auto-generated method stub
        	onGallery();   
        }
	
	   
    }; 
    public void onCamera(){
    	  Intent cameraintent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
          // 指定调用相机拍照后照片的储存路径
          cameraintent.putExtra(MediaStore.EXTRA_OUTPUT,
                  Uri.fromFile(tempFile));
          cameraintent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
          startActivityForResult(cameraintent, PHOTO_REQUEST_TAKEPHOTO);
      	     
    }
    public void onGallery(){
    	Intent intent = new Intent(Intent.ACTION_PICK, null);
    	intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
       
       //Intent localIntent2 = Intent.createChooser(localIntent, "选择图片");      
       startActivityForResult(intent, PHOTO_REQUEST_GALLERY);  	
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_crama, menu);
        return true;
    }
    private void startPhotoZoom(Uri uri,Uri out) {
        Intent intent = new Intent("com.android.camera.action.CROP",null);
        intent.setDataAndType(uri, "image/*");
        // crop为true是设置在开启的intent中设置显示的view可以剪裁
        intent.putExtra("crop", "true");

        // aspectX aspectY 是宽高的比例
        intent.putExtra("aspectX", cropX);
        intent.putExtra("aspectY", cropY);

        // outputX,outputY 是剪裁图片的宽高
        intent.putExtra("outputX", cropX);
        intent.putExtra("outputY", cropY);
        intent.putExtra("return-data", false);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, out);
        intent.putExtra("noFaceDetection", true);
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        //intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        startActivityForResult(intent, PHOTO_REQUEST_CUT);
    }

    // 将进行剪裁后的图片传递到下一个界面上
    private void sentPicToNext(File file,boolean delete) {
    	Log.e("start write file","");
    	
    	if (file == null){
    		file = cropFile;
    	}
        try {
            Util.copyFile(file, copyFile);
            if (delete) {
            	//file.deleteOnExit();
            	Util.deleteFile(file);
            }
            Util.deleteFile(tempFile);
            //tempFile.deleteOnExit();
            Util.selectImage = true;
            Util.photoPathString = copyFile.getAbsolutePath();
            setResult(RESULT_OK);
            finish();
        } catch (Exception e) {
            e.getStackTrace();
        } finally {
        	
           
        }
       
    }
    
    // 使用系统当前日期加以调整作为照片的名称
    private String getPhotoFileName(String sig) {
        Date date = new Date(System.currentTimeMillis());
        SimpleDateFormat dateFormat = new SimpleDateFormat(
                "'IMG'_yyyyMMdd_HHmmss");
        return dateFormat.format(date) + sig+".jpg";
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