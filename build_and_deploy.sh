#!/bin/bash

rm -rf ./build
flutter clean
flutter build web --web-renderer canvaskit

rm -rf ../open_mower_ros/web

cp -r ./build/web ../open_mower_ros
