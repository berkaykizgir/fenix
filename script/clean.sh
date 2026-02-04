#!/bin/bash

flutter clean; rm -f pubspec.lock; flutter pub get; cd ios; pod deintegrate; pod install; cd ..; flutter pub get;