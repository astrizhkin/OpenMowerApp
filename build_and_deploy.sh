#!/bin/bash

rm -rf ./build
flutter clean
flutter build web --web-renderer canvaskit --release
#--dart-define=FLUTTER_WEB_CANVASKIT_URL=./canvaskit.js 
#--dart-define=FLUTTER_WEB_USE_SKIA=true
#--no-web-resources-cdn
#--base-href "/" 
#flutter build web --web-renderer canvaskit --no-web-resources-cdn --release

rm -rf ../open_mower_ros/web

cp -r ./build/web ../open_mower_ros
