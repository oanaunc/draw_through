#!/usr/bin/env python3
"""Build the Android offline catalog directly from the Apple source; never abridge lessons."""
import json, pathlib, re, shutil, hashlib
root = pathlib.Path(__file__).resolve().parents[2]
dest = root/'android/app/src/main/assets/web'
source = root/'DrawThrough'
text = (source/'Lessons.swift').read_text()
foundations = []
for m in re.finditer(r'\.init\(id: (\d+), title: ("(?:[^"\\]|\\.)*"), subtitle: ("(?:[^"\\]|\\.)*"), minutes: (\d+),\s*idea: ("(?:[^"\\]|\\.)*"),\s*observation: ("(?:[^"\\]|\\.)*"),\s*steps: (\[.*?\]),\s*check: ("(?:[^"\\]|\\.)*"), transfer: ("(?:[^"\\]|\\.)*")\)', text, re.S):
    id,title,subtitle,minutes,idea,observation,steps,check,transfer=m.groups()
    foundations.append(dict(id=int(id),title=json.loads(title),subtitle=json.loads(subtitle),minutes=int(minutes),idea=json.loads(idea),observation=json.loads(observation),steps=json.loads(steps),check=json.loads(check),transfer=json.loads(transfer)))
assert len(foundations)==20
lessons = foundations + json.loads((source/'Resources/ExtendedCourse.json').read_text())
workshops = json.loads((source/'Resources/LessonWorkshops.json').read_text())
assert len(lessons)==len(workshops)==100
chapters=json.loads('['+re.search(r'static let chapters = \[(.*?)\]',text,re.S).group(1)+']')
notes=json.loads('['+re.search(r'static let chapterNotes = \[(.*?)\]',text,re.S).group(1)+']')
for lesson in lessons:
    lesson['chapter']=(lesson['id']-1)//5 if lesson['id']<=20 else 4+(lesson['id']-21)//10
    lesson['workshop']=next(w for w in workshops if w['lessonID']==lesson['id'])
    lesson['image']=f"images/Lesson-{lesson['id']:03d}.jpg"
    assert len(' '.join([lesson[k] for k in ['idea','observation','check','transfer']]+lesson['steps']+[lesson['workshop'][k] for k in ['setup','demonstration','mistakes','challenge']]).split())>=330
(dest/'course.json').write_text(json.dumps(dict(chapters=chapters,notes=notes,lessons=lessons),ensure_ascii=False,indent=2)+'\n')
(dest/'images').mkdir(exist_ok=True)
hashes=[]
for lesson in lessons:
    p=source/'Resources/CourseReferences'/pathlib.Path(lesson['image']).name
    hashes.append(hashlib.sha256(p.read_bytes()).hexdigest())
    shutil.copy2(p,dest/lesson['image'])
assert len(set(hashes))==100
for name in ['OnboardingPlace','OnboardingArrange','OnboardingTrace']:
    asset=source/'Resources/Assets.xcassets'/f'{name}.imageset'
    img=next(i['filename'] for i in json.loads((asset/'Contents.json').read_text())['images'] if 'filename' in i)
    shutil.copy2(asset/img,dest/'images'/f'{name}{pathlib.Path(img).suffix}')
icon=source/'Resources/Assets.xcassets/AppIcon.appiconset'
img=next(i['filename'] for i in json.loads((icon/'Contents.json').read_text())['images'] if 'filename' in i)
from PIL import Image
Image.open(icon/img).convert('RGB').resize((192,192)).save(root/'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png')
print('Synced 100 full lessons, 100 workshops, 100 distinct images and all onboarding artwork.')
