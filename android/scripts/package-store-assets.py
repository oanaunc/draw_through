#!/usr/bin/env python3
"""Package genuine Android captures without cropping or changing the UI."""
import hashlib,json,pathlib
from PIL import Image,ImageDraw,ImageFont,ImageOps
root=pathlib.Path(__file__).resolve().parents[2]
output=root/'release/google-play'
fontfile=root/'android/app/src/main/assets/web/fonts/GFSDidot-Regular.ttf'
ink='#1b1915';clay='#6e523c';warm='#f4ecdd'
manifest=[]
phone_names=['01-Learn','02-References','03-Workshop','04-Practice','05-Journal','06-Observation','07-Light-Table','09-Own-Photo']
for kind,names,size in [('phone',phone_names,(1080,1920)),('tablet',['01-Learn','02-References','03-Workshop','04-Practice','05-Journal','07-Light-Table'],(1920,1080))]:
 folder=output/f'raw-{kind}'
 dest=output/f'screenshots-{kind}';dest.mkdir(parents=True,exist_ok=True)
 for n in names:
  p=folder/(n+'.png')
  if not p.exists():continue
  im=Image.open(p).convert('RGB');im.thumbnail(size,Image.Resampling.LANCZOS)
  canvas=Image.new('RGB',size,warm);canvas.paste(im,((size[0]-im.width)//2,(size[1]-im.height)//2))
  target=dest/(n+'.png');canvas.save(target,optimize=True)
  manifest.append(dict(source=str(p.relative_to(root)),sourceSHA256=hashlib.sha256(p.read_bytes()).hexdigest(),output=str(target.relative_to(root)),outputSHA256=hashlib.sha256(target.read_bytes()).hexdigest(),width=size[0],height=size[1],method='Full capture, proportional fit on warm-paper canvas; no UI cropping or alteration.'))
asset=root/'DrawThrough/Resources/Assets.xcassets/AppIcon.appiconset'
name=next(i['filename'] for i in json.loads((asset/'Contents.json').read_text())['images'] if 'filename'in i)
Image.open(asset/name).convert('RGBA').resize((512,512),Image.Resampling.LANCZOS).save(output/'icon-512.png',optimize=True)
canvas=Image.new('RGB',(1024,500),warm);d=ImageDraw.Draw(canvas)
for y in range(500):
 t=y/500;d.line((0,y,1024,y),fill=tuple(round(a*(1-t)+b*t) for a,b in zip((250,244,230),(232,219,196))))
font=ImageFont.truetype(str(fontfile),52);small=ImageFont.truetype(str(fontfile),23)
d.text((48,100),'Draw Through',font=font,fill=ink)
d.text((50,184),'Learn to look.',font=small,fill=clay)
d.text((50,222),'Make your mark.',font=small,fill=clay)
d.text((50,329),'100 lessons. 100 references.',font=small,fill=clay)
for num,box in [(21,(465,65,690,225)),(31,(714,65,950,225)),(26,(570,250,810,430))]:
 im=Image.open(root/f'DrawThrough/Resources/CourseReferences/Lesson-{num:03d}.jpg').convert('RGB');im=ImageOps.fit(im,(box[2]-box[0],box[3]-box[1]),method=Image.Resampling.LANCZOS);canvas.paste(im,box[:2])
canvas.save(output/'feature-1024x500.png',optimize=True)
(output/'ScreenshotManifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
for kind in ['phone','tablet']:
 images=list((output/f'screenshots-{kind}').glob('*.png'))
 if not images:continue
 thumb_w=270;thumb_h=480 if kind=='phone' else 152
 sheet=Image.new('RGB',(thumb_w*4,(thumb_h+30)*((len(images)+3)//4)),warm);draw=ImageDraw.Draw(sheet)
 for i,p in enumerate(sorted(images)):
  im=Image.open(p);im.thumbnail((thumb_w,thumb_h));x=i%4*thumb_w;y=i//4*(thumb_h+30);sheet.paste(im,(x,y));draw.text((x+5,y+thumb_h+5),p.stem,fill=ink)
 sheet.save(output/f'Overview-{kind}.jpg',quality=90)
print('Packaged',len(manifest),'verified-source store screenshots, icon and feature graphic.')
