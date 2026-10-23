#!/usr/bin/env python3
"""Build with an existing private upload key; never print credentials."""
import json, os, pathlib, subprocess
project=pathlib.Path(__file__).resolve().parents[1]
config_path=pathlib.Path(os.environ.get('DRAWTHROUGH_SIGNING_CONFIG',str(pathlib.Path.home()/'.local/share/drawthrough/android-upload/signing.json')))
if not config_path.is_file():
    raise SystemExit('Upload signing is not configured. See android/README.md. Do not replace an existing Play upload key.')
config=json.loads(config_path.read_text())
env=dict(os.environ)
for field,var in [('keystore','DRAWTHROUGH_UPLOAD_KEYSTORE'),('storePassword','DRAWTHROUGH_UPLOAD_STORE_PASSWORD'),('keyPassword','DRAWTHROUGH_UPLOAD_KEY_PASSWORD'),('alias','DRAWTHROUGH_UPLOAD_KEY_ALIAS')]:env[var]=config[field]
env.setdefault('JAVA_HOME','/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home')
env.setdefault('ANDROID_HOME',str(pathlib.Path.home()/'Library/Android/sdk'))
subprocess.run([str(project/'gradlew'),'-p',str(project),'bundleRelease','assembleRelease','lintRelease'],env=env,check=True)
