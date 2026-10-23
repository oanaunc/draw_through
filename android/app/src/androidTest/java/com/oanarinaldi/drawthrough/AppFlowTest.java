package com.oanarinaldi.drawthrough;

import android.graphics.Bitmap;
import android.os.SystemClock;
import android.view.MotionEvent;
import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.*;
import org.junit.runner.RunWith;
import org.json.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;
import static org.junit.Assert.*;

@RunWith(AndroidJUnit4.class)
public class AppFlowTest {
 private ActivityScenario<MainActivity> scenario;
 private String js(String code) throws Exception {
  CountDownLatch latch=new CountDownLatch(1);AtomicReference<String> result=new AtomicReference<>();
  scenario.onActivity(a->a.web.evaluateJavascript("(()=>{try{return "+code+"}catch(e){return 'ERROR:'+e.message}})()",v->{result.set(v);latch.countDown();}));
  assertTrue("JavaScript callback timed out",latch.await(10,TimeUnit.SECONDS));return result.get();
 }
 private void run(String code) throws Exception {String result=js("(()=>{"+code+";return true;})()");assertEquals("true",result);}
 private void ready() throws Exception {long end=SystemClock.uptimeMillis()+15000;while(SystemClock.uptimeMillis()<end){if("true".equals(js("!!window.appReady")))return;SystemClock.sleep(100);}fail("App did not load");}
 @Before public void launch() throws Exception {scenario=ActivityScenario.launch(MainActivity.class);ready();run("state=defaults();state.onboarded=true;saveState();practice=null;project=null;route={name:'learn'};stack=[];render()");}
 @After public void close(){if(scenario!=null)scenario.close();}
 private void shell(String command) throws Exception {try(android.os.ParcelFileDescriptor fd=InstrumentationRegistry.getInstrumentation().getUiAutomation().executeShellCommand(command);InputStream input=new android.os.ParcelFileDescriptor.AutoCloseInputStream(fd)){while(input.read()!=-1){}}}
 private void capture(String name) throws Exception {
  SystemClock.sleep(450);Bitmap bitmap=InstrumentationRegistry.getInstrumentation().getUiAutomation().takeScreenshot();
  File dir=new File(InstrumentationRegistry.getInstrumentation().getTargetContext().getExternalFilesDir(null),"qa");dir.mkdirs();File file=new File(dir,name+".png");
  try(OutputStream out=new FileOutputStream(file)){bitmap.compress(Bitmap.CompressFormat.PNG,100,out);}bitmap.recycle();
  shell("mkdir -p /sdcard/Download/DrawThroughCaptures");shell("cp "+file.getAbsolutePath()+" /sdcard/Download/DrawThroughCaptures/"+file.getName());
 }

 private byte[] bytes(InputStream input) throws Exception {try(InputStream in=input;ByteArrayOutputStream out=new ByteArrayOutputStream()){byte[] buffer=new byte[8192];int n;while((n=in.read(buffer))!=-1)out.write(buffer,0,n);return out.toByteArray();}}
 @Test public void completeOfflineCourseAndArtwork() throws Exception {
  android.content.Context c=InstrumentationRegistry.getInstrumentation().getTargetContext();JSONObject course=new JSONObject(new String(bytes(c.getAssets().open("web/course.json")),StandardCharsets.UTF_8));JSONArray lessons=course.getJSONArray("lessons");assertEquals(100,lessons.length());assertEquals(12,course.getJSONArray("chapters").length());Set<String> hashes=new HashSet<>();
  for(int i=0;i<100;i++){JSONObject l=lessons.getJSONObject(i);assertEquals(i+1,l.getInt("id"));JSONObject w=l.getJSONObject("workshop");assertEquals(i+1,w.getInt("lessonID"));assertTrue(w.getString("demonstration").length()>150);assertEquals(3,l.getJSONArray("steps").length());byte[] data=bytes(c.getAssets().open("web/"+l.getString("image")));assertNotNull(android.graphics.BitmapFactory.decodeByteArray(data,0,data.length));hashes.add(Base64.getEncoder().encodeToString(MessageDigest.getInstance("SHA-256").digest(data)));}
  assertEquals(100,hashes.size());assertEquals("false",js("!!document.querySelector('.page').scrollWidth && document.documentElement.scrollWidth>window.innerWidth"));
  capture("01-Learn");run("route={name:'references'};render()");capture("02-References");run("navigate('lesson',100)");assertEquals("true",js("document.body.textContent.includes('Your independent assignment')"));run("document.querySelector('.fixed-action').scrollIntoView();window.scrollTo(0,0)");capture("03-Workshop");
 }
 @Test public void realDrawingUndoCompletionAndRecreation() throws Exception {
  run("Android.remove('study-1');navigate('lesson',1);document.querySelector('[data-action=practice]').click()");assertEquals("true",js("document.querySelector('[data-action=complete]').disabled"));
  JSONArray rect=new JSONArray(js("(()=>{let r=document.querySelector('#practiceCanvas').getBoundingClientRect();return [r.x,r.y,r.width,r.height,window.devicePixelRatio]})()"));
  float d=(float)rect.getDouble(4),x=(float)(rect.getDouble(0)+rect.getDouble(2)*.2)*d,y=(float)(rect.getDouble(1)+rect.getDouble(3)*.35)*d;
  scenario.onActivity(a->{long t=SystemClock.uptimeMillis();float top=0;for(int i=0;i<12;i++){MotionEvent e=MotionEvent.obtain(t,t+i*16,i==0?MotionEvent.ACTION_DOWN:i==11?MotionEvent.ACTION_UP:MotionEvent.ACTION_MOVE,x+i*13,y+top+i*5,0);a.web.dispatchTouchEvent(e);e.recycle();}});SystemClock.sleep(300);
  assertEquals("1",js("practice.strokes.length"));run("document.querySelector('[data-action=undo]').click()");assertEquals("0",js("practice.strokes.length"));run("document.querySelector('[data-action=redo]').click()");assertEquals("1",js("practice.strokes.length"));
  run("const t=document.querySelector('#reflection');t.value='I noticed the direction of the line.';t.dispatchEvent(new Event('input',{bubbles:true}));flushPending()");capture("04-Practice");run("document.querySelector('[data-action=complete]').click()");assertEquals("1",js("completed()"));
  scenario.recreate();ready();assertEquals("1",js("completed()"));run("route={name:'journal'};render()");assertEquals("true",js("document.body.textContent.includes('I noticed the direction')"));capture("05-Journal");run("practice=null;navigate('practice',1)");assertEquals("1",js("practice.strokes.length"));assertEquals("true",js("!!practice.completedAt"));
 }
 private void dragLayer() throws Exception {
  JSONArray rect=new JSONArray(js("(()=>{const r=document.querySelector('.layer').getBoundingClientRect();return [r.x+r.width/2,r.y+r.height/2,devicePixelRatio]})()"));
  float density=(float)rect.getDouble(2),x=(float)rect.getDouble(0)*density,y=(float)rect.getDouble(1)*density;
  scenario.onActivity(a->{long time=SystemClock.uptimeMillis();for(int i=0;i<8;i++){MotionEvent e=MotionEvent.obtain(time,time+i*20,i==0?0:i==7?1:2,x+25*density*i/7,y,0);a.web.dispatchTouchEvent(e);e.recycle();}});SystemClock.sleep(200);
 }
 private void pinchLayer() throws Exception {
  JSONArray rect=new JSONArray(js("(()=>{const r=document.querySelector('.layer').getBoundingClientRect();return [r.x+r.width/2,r.y+r.height/2,devicePixelRatio]})()"));
  float density=(float)rect.getDouble(2),x=(float)rect.getDouble(0)*density,y=(float)rect.getDouble(1)*density,half=40*density;
  scenario.onActivity(a->{long time=SystemClock.uptimeMillis();MotionEvent.PointerProperties[] properties=new MotionEvent.PointerProperties[2];MotionEvent.PointerCoords[] coords=new MotionEvent.PointerCoords[2];for(int i=0;i<2;i++){properties[i]=new MotionEvent.PointerProperties();properties[i].id=i;properties[i].toolType=MotionEvent.TOOL_TYPE_FINGER;coords[i]=new MotionEvent.PointerCoords();coords[i].pressure=1;coords[i].size=1;coords[i].x=x+(i==0?-half:half);coords[i].y=y;}
   int[] actions={MotionEvent.ACTION_DOWN,MotionEvent.ACTION_POINTER_DOWN|(1<<MotionEvent.ACTION_POINTER_INDEX_SHIFT),MotionEvent.ACTION_MOVE,MotionEvent.ACTION_POINTER_UP|(1<<MotionEvent.ACTION_POINTER_INDEX_SHIFT),MotionEvent.ACTION_UP};
   for(int i=0;i<actions.length;i++){if(i==2){float dx=(float)(half*1.1*Math.cos(Math.PI/12)),dy=(float)(half*1.1*Math.sin(Math.PI/12));coords[0].x=x-dx;coords[0].y=y-dy;coords[1].x=x+dx;coords[1].y=y+dy;}
    int count=i==0||i==4?1:2;MotionEvent event=MotionEvent.obtain(time,time+i*30,actions[i],count,properties,coords,0,0,1,1,0,0,android.view.InputDevice.SOURCE_TOUCHSCREEN,0);a.web.dispatchTouchEvent(event);event.recycle();}
  });SystemClock.sleep(200);
 }
 @Test public void galleryStudioTransformPersistenceAndDuplicate() throws Exception {
  run("navigate('reference',31);document.querySelector('[data-action=viewer]').click();document.querySelector('[data-action=viewmono]').click();document.querySelector('[data-action=viewgrid]').click()");assertEquals("true",js("viewer.mono && viewer.grid"));capture("06-Observation");run("appBack();document.querySelector('[data-action=arrange]').click()");
  assertEquals("1",js("project.layers.length"));SystemClock.sleep(700);dragLayer();pinchLayer();assertEquals("25",js("Math.round(project.layers[0].x)"));assertEquals("15",js("Math.round(project.layers[0].rotation)"));capture("07-Light-Table");run("adjustPanel();document.querySelector(\"[data-action=layermode][data-value='2']\").click()");SystemClock.sleep(1000);assertEquals("2",js("selectedLayer().mode"));capture("08-Adjust");run("closeModal();const id=project.id;project=null;loadProject(id)");assertEquals("25",js("Math.round(project.layers[0].x)"));assertEquals("15",js("Math.round(project.layers[0].rotation)"));run("appBack();route={name:'home'};render();document.querySelector('[data-action=duplicate]').click()");assertEquals("2",js("state.projects.length"));assertEquals("true",js("read('project-'+state.projects[0].id).layers.length===1"));
 }
 @Test public void corruptFilesPreservedAndFailureReported() throws Exception {
  File documents=new File(InstrumentationRegistry.getInstrumentation().getTargetContext().getFilesDir(),"documents");documents.mkdirs();File bad=new File(documents,"study-17.json");try(FileOutputStream out=new FileOutputStream(bad)){out.write("corrupt-do-not-overwrite".getBytes(StandardCharsets.UTF_8));}
  run("practice=null;navigate('practice',17)");assertEquals("true",js("document.body.textContent.includes('preserved')"));assertEquals("true",js("!document.querySelector('#practiceCanvas')"));assertEquals("corrupt-do-not-overwrite",new String(bytes(new FileInputStream(bad)),StandardCharsets.UTF_8));bad.delete();
  run("appBack();Android.remove('study-2');navigate('practice',2)");
  File blocked=new File(documents,"study-2.json");assertTrue(blocked.mkdir());
  try {
   run("practice.strokes=[{tool:0,points:[[20,20,.5],[50,50,.5]]}];practice.dirty=true;window.failureResult=savePractice(true)");assertEquals("false",js("window.failureResult"));assertEquals("true",js("document.body.textContent.includes('Keep this screen open')"));assertEquals("0",js("completed()"));run("closeModal();practice.dirty=false");
  } finally { blocked.delete(); }

 }
 private String dump(android.view.accessibility.AccessibilityNodeInfo n,int depth){if(n==null||depth>12)return "";StringBuilder out=new StringBuilder();out.append(n.getText()).append(" | ").append(n.getContentDescription()).append(" | ").append(n.getClassName()).append("\n");for(int i=0;i<n.getChildCount();i++)out.append(dump(n.getChild(i),depth+1));return out.toString();}
 private android.view.accessibility.AccessibilityNodeInfo findText(android.view.accessibility.AccessibilityNodeInfo node,String text){
  if(node==null)return null;
  String label=String.valueOf(node.getText())+" "+String.valueOf(node.getContentDescription());
  if(label.toLowerCase().contains(text.toLowerCase()))return node;
  for(int i=0;i<node.getChildCount();i++){android.view.accessibility.AccessibilityNodeInfo found=findText(node.getChild(i),text);if(found!=null)return found;}return null;
 }
 private boolean clickText(String text) throws Exception {
  android.view.accessibility.AccessibilityNodeInfo node=findText(InstrumentationRegistry.getInstrumentation().getUiAutomation().getRootInActiveWindow(),text);
  if(node==null)return false;
  android.graphics.Rect rect=new android.graphics.Rect();node.getBoundsInScreen(rect);long now=SystemClock.uptimeMillis();
  for(int action:new int[]{MotionEvent.ACTION_DOWN,MotionEvent.ACTION_UP}){MotionEvent e=MotionEvent.obtain(now,SystemClock.uptimeMillis(),action,rect.centerX(),rect.centerY(),0);InstrumentationRegistry.getInstrumentation().getUiAutomation().injectInputEvent(e,true);e.recycle();}return true;
 }
 @Test public void systemPhotoPickerAndNativeImageExport() throws Exception {
  android.content.Context context=InstrumentationRegistry.getInstrumentation().getTargetContext();android.content.ContentResolver resolver=context.getContentResolver();
  android.content.ContentValues values=new android.content.ContentValues();values.put(android.provider.MediaStore.Images.Media.DISPLAY_NAME,"DrawThrough-QA-reference.jpg");values.put(android.provider.MediaStore.Images.Media.MIME_TYPE,"image/jpeg");values.put(android.provider.MediaStore.Images.Media.RELATIVE_PATH,"Pictures/Draw Through QA");values.put(android.provider.MediaStore.Images.Media.IS_PENDING,1);
  android.net.Uri uri=resolver.insert(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI,values);assertNotNull(uri);
  try {
   try(InputStream input=context.getAssets().open("web/images/Lesson-031.jpg");OutputStream output=resolver.openOutputStream(uri)){output.write(bytes(input));}
   values.clear();values.put(android.provider.MediaStore.Images.Media.IS_PENDING,0);resolver.update(uri,values,null,null);
   run("Android.remove('study-3');practice=null;navigate('practice',3);document.querySelector('[data-action=practicephoto]').click()");
   boolean clicked=false;long end=SystemClock.uptimeMillis()+10000;
   while(SystemClock.uptimeMillis()<end){if(clickText("DrawThrough-QA-reference") || clickText("Photo taken on")){clicked=true;break;}SystemClock.sleep(250);}
   if(!clicked){capture("10-System-Picker");System.out.println(dump(InstrumentationRegistry.getInstrumentation().getUiAutomation().getRootInActiveWindow(),0));}
   assertTrue("Generated reference must be visible in Android's system picker",clicked);
   end=SystemClock.uptimeMillis()+10000;boolean imported=false;
   while(SystemClock.uptimeMillis()<end){if("true".equals(js("!!practice.personal"))){imported=true;break;}clickText("Select");SystemClock.sleep(250);}
   assertTrue("Picker result must be copied into private app storage",imported);assertEquals("2",js("practice.referenceChoice"));capture("09-Own-Photo");run("practice=null;loadPractice(getLesson(3))");assertEquals("true",js("practice.personal.startsWith('/private/photos/')"));
   run("appBack();createProject('A4',getLesson(31));exportComposition(true)");
   end=SystemClock.uptimeMillis()+10000;boolean exported=false;
   while(SystemClock.uptimeMillis()<end){try(android.database.Cursor cursor=resolver.query(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI,new String[]{android.provider.MediaStore.Images.Media._ID},android.provider.MediaStore.Images.Media.DISPLAY_NAME+" LIKE ?",new String[]{"DrawThrough-%"},null)){exported=cursor!=null&&cursor.getCount()>1;}if(exported)break;SystemClock.sleep(250);}assertTrue("Native PNG export must be present in media storage",exported);
  } finally { resolver.delete(uri,null,null); }
 }

}
