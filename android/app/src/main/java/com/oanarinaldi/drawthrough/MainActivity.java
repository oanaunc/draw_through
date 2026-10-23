package com.oanarinaldi.drawthrough;

import android.content.*;
import android.graphics.*;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.AtomicFile;
import android.util.Base64;
import android.view.*;
import android.webkit.*;
import android.widget.Toast;
import androidx.activity.ComponentActivity;
import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.core.content.FileProvider;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.exifinterface.media.ExifInterface;
import androidx.webkit.WebViewAssetLoader;
import org.json.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Offline editorial UI with Android-owned files, picker, sharing and screen lock. */
public final class MainActivity extends ComponentActivity {
    public WebView web;
    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private String photoTarget = "";
    private ActivityResultLauncher<PickVisualMediaRequest> singlePicker;
    private ActivityResultLauncher<PickVisualMediaRequest> multiPicker;
    private boolean destroyed;
    private static final String ORIGIN = "https://appassets.androidplatform.net";

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        singlePicker = registerForActivityResult(new ActivityResultContracts.PickVisualMedia(), uri -> importPhotos(uri == null ? Collections.emptyList() : Collections.singletonList(uri)));
        multiPicker = registerForActivityResult(new ActivityResultContracts.PickMultipleVisualMedia(12), this::importPhotos);
        web = new WebView(this);
        web.setBackgroundColor(Color.rgb(244,236,221));
        android.widget.FrameLayout root = new android.widget.FrameLayout(this);
        root.setBackgroundColor(Color.rgb(244,236,221));
        root.addView(web, new android.widget.FrameLayout.LayoutParams(-1,-1));
        setContentView(root);
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, insets) -> {
            androidx.core.graphics.Insets bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout() | WindowInsetsCompat.Type.ime());
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom);
            return insets;
        });
        setLightSystemBars();
        WebSettings settings = web.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(false);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(false);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        settings.setTextZoom(Math.round(100 * getResources().getConfiguration().fontScale));
        settings.setSupportMultipleWindows(false);
        WebView.setWebContentsDebuggingEnabled((getApplicationInfo().flags & android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0);
        WebViewAssetLoader loader = new WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", new WebViewAssetLoader.AssetsPathHandler(this))
            .addPathHandler("/private/", new WebViewAssetLoader.InternalStoragePathHandler(this, getFilesDir()))
            .build();
        web.setWebViewClient(new WebViewClient() {
            @Override public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                WebResourceResponse response = loader.shouldInterceptRequest(request.getUrl());
                if (response != null) return response;
                return new WebResourceResponse("text/plain", "UTF-8", 403, "Blocked", Collections.emptyMap(), new ByteArrayInputStream(new byte[0]));
            }
            @Override public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) { return true; }
        });
        web.addJavascriptInterface(new Bridge(), "Android");
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override public void handleOnBackPressed() { web.evaluateJavascript("window.appBack && window.appBack()", value -> { if ("false".equals(value)) finish(); }); }
        });
        web.loadUrl(ORIGIN + "/assets/web/index.html");
    }
    private void importPhotos(List<Uri> uris) {
            final String target = photoTarget;
            io.execute(() -> {
                JSONArray photos = new JSONArray();
                try {
                    int count = 0;
                    for (Uri uri : uris) {
                        if (++count > (target.equals("practice") ? 1 : 12)) break;
                        Bitmap bitmap = importBitmap(uri);
                        File dir = new File(getFilesDir(), "photos");
                        if (!dir.isDirectory() && !dir.mkdirs()) throw new IOException("Cannot create photo directory");
                        String name = UUID.randomUUID() + ".jpg";
                        try (OutputStream out = new FileOutputStream(new File(dir, name))) {
                            if (!bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)) throw new IOException("Cannot save photo");
                        }
                        bitmap.recycle();
                        photos.put("/private/photos/" + name);
                    }
                    callback("window.photosImported(" + JSONObject.quote(target) + "," + photos + ")");
                } catch (Exception e) { callback("window.nativeError('This photo could not be imported. Try another photo.')"); }
            });
    }
    private void callback(String js) { runOnUiThread(() -> { if (!destroyed) web.evaluateJavascript(js, null); }); }
    private Bitmap importBitmap(Uri uri) throws IOException {
        BitmapFactory.Options bounds = new BitmapFactory.Options(); bounds.inJustDecodeBounds = true;
        try (InputStream in = getContentResolver().openInputStream(uri)) { BitmapFactory.decodeStream(in, null, bounds); }
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) throw new IOException("Unsupported image");
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inSampleSize = Math.max(1, Math.max(bounds.outWidth, bounds.outHeight) / 1800);
        Bitmap bitmap;
        try (InputStream in = getContentResolver().openInputStream(uri)) { bitmap = BitmapFactory.decodeStream(in, null, opts); }
        if (bitmap == null) throw new IOException("Unsupported image");
        try (InputStream in = getContentResolver().openInputStream(uri)) {
            ExifInterface exif = new ExifInterface(in);
            Matrix matrix = new Matrix();
            if (exif.isFlipped()) matrix.postScale(-1, 1);
            matrix.postRotate(exif.getRotationDegrees());
            Bitmap rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            if (rotated != bitmap) { bitmap.recycle(); bitmap = rotated; }
        }
        int max = Math.max(bitmap.getWidth(), bitmap.getHeight());
        if (max > 1800) {
            Bitmap scaled = Bitmap.createScaledBitmap(bitmap, Math.round(bitmap.getWidth()*1800f/max), Math.round(bitmap.getHeight()*1800f/max), true);
            bitmap.recycle(); bitmap = scaled;
        }
        return bitmap;
    }
    public final class Bridge {
        private File file(String key) {
            if (!key.matches("(?:state|study-[1-9][0-9]{0,2}|project-[a-zA-Z0-9-]{1,60})")) throw new IllegalArgumentException("Invalid document");
            File dir = new File(getFilesDir(), "documents");
            if (!dir.isDirectory() && !dir.mkdirs()) throw new IllegalStateException("Cannot create storage");
            return new File(dir, key + ".json");
        }
        @JavascriptInterface public synchronized String read(String key) {
            try {
                File f = file(key);
                if (!f.exists() && !new File(f.getPath()+".bak").exists()) return "null";
                try (InputStream in = new AtomicFile(f).openRead()) {
                    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                    byte[] chunk = new byte[8192]; int count;
                    while ((count = in.read(chunk)) != -1) buffer.write(chunk, 0, count);
                    String text = buffer.toString(StandardCharsets.UTF_8.name());
                    new JSONObject(text);
                    return text;
                }
            } catch (Exception e) { return "{\"_error\":\"Saved data could not be opened. It has been preserved.\"}"; }
        }
        @JavascriptInterface public synchronized boolean write(String key, String json) {
            AtomicFile atomic = null; FileOutputStream out = null;
            try {
                if (json.length() > 20_000_000) return false;
                new JSONObject(json);
                File target = file(key);
                if (target.exists() && !target.isFile()) return false;
                atomic = new AtomicFile(target);
                out = atomic.startWrite(); out.write(json.getBytes(StandardCharsets.UTF_8)); atomic.finishWrite(out);
                return true;
            } catch (Exception e) { if (atomic != null && out != null) atomic.failWrite(out); return false; }
        }
        @JavascriptInterface public synchronized boolean remove(String key) {
            try {
                File target = file(key);
                String previous = read(key);
                new AtomicFile(target).delete();
                java.util.regex.Matcher matches = java.util.regex.Pattern.compile("/private/photos/([a-zA-Z0-9-]+\\.jpg)").matcher(previous);
                while (matches.find()) {
                    String name = matches.group(1); boolean referenced = false;
                    File[] documents = target.getParentFile().listFiles();
                    if (documents != null) for (File doc : documents) {
                        if (!doc.isFile() || !doc.getName().endsWith(".json")) continue;
                        String otherKey = doc.getName().substring(0,doc.getName().length()-5);
                        String json = read(otherKey);
                        if (json.contains(name) || json.contains("_error")) { referenced = true; break; }
                    }
                    if (!referenced) new File(new File(getFilesDir(),"photos"),name).delete();
                }
                return !target.exists();
            } catch (Exception e) { return false; }
        }
        @JavascriptInterface public void pickPhotos(String target) {
            if (!target.equals("practice") && !target.equals("studio")) return;
            runOnUiThread(() -> { photoTarget = target; PickVisualMediaRequest request = new PickVisualMediaRequest.Builder().setMediaType(ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE).build(); if (target.equals("practice")) singlePicker.launch(request); else multiPicker.launch(request); });
        }
        @JavascriptInterface public void keepAwake(boolean enabled) {
            runOnUiThread(() -> { if (enabled) getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); else getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); });
        }
        @JavascriptInterface public void openLink(String url) {
            if (!url.equals("https://oanarinaldi.com/drawthroughprivacy.html") && !url.equals("mailto:oanarinaldi@gmail.com")) return;
            runOnUiThread(() -> { try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url))); } catch (ActivityNotFoundException e) { Toast.makeText(MainActivity.this,"No app is available to open this link",Toast.LENGTH_LONG).show(); } });
        }
        @JavascriptInterface public void exportImage(String data, boolean save) {
            io.execute(() -> {
                try {
                    if (!data.startsWith("data:image/png;base64,") || data.length() > 24_000_000) throw new IOException();
                    byte[] bytes = Base64.decode(data.substring(data.indexOf(',')+1), Base64.DEFAULT);
                    String name = "DrawThrough-" + System.currentTimeMillis() + ".png";
                    if (save) {
                        ContentValues values = new ContentValues(); values.put(MediaStore.Images.Media.DISPLAY_NAME,name); values.put(MediaStore.Images.Media.MIME_TYPE,"image/png"); values.put(MediaStore.Images.Media.RELATIVE_PATH,"Pictures/Draw Through"); values.put(MediaStore.Images.Media.IS_PENDING,1);
                        Uri uri = getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,values);
                        if (uri == null) throw new IOException();
                        try { try (OutputStream out = getContentResolver().openOutputStream(uri)) { if(out==null) throw new IOException(); out.write(bytes); } values.clear(); values.put(MediaStore.Images.Media.IS_PENDING,0); getContentResolver().update(uri,values,null,null); }
                        catch (Exception e) { getContentResolver().delete(uri,null,null); throw e; }
                        callback("window.toast('Saved to Photos')");
                    } else {
                        File dir = new File(getCacheDir(),"exports"); if (!dir.isDirectory() && !dir.mkdirs()) throw new IOException();
                        for(File old: Objects.requireNonNullElse(dir.listFiles(),new File[0])) if(old.lastModified()<System.currentTimeMillis()-86400000) old.delete();
                        File file = new File(dir,name); try(OutputStream out=new FileOutputStream(file)){out.write(bytes);}
                        Uri uri = FileProvider.getUriForFile(MainActivity.this,getPackageName()+".files",file);
                        runOnUiThread(() -> { Intent intent = new Intent(Intent.ACTION_SEND).setType("image/png").putExtra(Intent.EXTRA_STREAM,uri).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); intent.setClipData(ClipData.newRawUri("Draw Through",uri)); startActivity(Intent.createChooser(intent,"Share drawing")); });
                    }
                } catch (Exception e) { callback("window.nativeError('The image could not be exported. Your work is still saved in the app.')"); }
            });
        }
    }
    private void setLightSystemBars() {
        androidx.core.view.WindowInsetsControllerCompat controller = new androidx.core.view.WindowInsetsControllerCompat(getWindow(),getWindow().getDecorView());
        controller.setAppearanceLightStatusBars(true); controller.setAppearanceLightNavigationBars(true);
    }
    @Override protected void onResume() { super.onResume(); setLightSystemBars(); }
    @Override protected void onPause() { if(web!=null) web.evaluateJavascript("window.flushPending && window.flushPending()",null); super.onPause(); }
    @Override protected void onDestroy() { destroyed=true; getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); if(web!=null){web.removeJavascriptInterface("Android");web.destroy();} io.shutdown(); super.onDestroy(); }
}
