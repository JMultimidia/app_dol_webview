# App Webview
## _WebView developed with Flutter_

[![N|JMultimidia](https://res.cloudinary.com/jmultimidia/image/upload/v1714013494/jmultimidia/images/powered_by_jmultimidia.png)](https://jmultimidia.com.br)

WebView developed with Flutter with successful approval on PlayStore and AppStore

- App Android and iOS WebViewer
- Using fvm 3.7.10
- ✨Icons Generator✨

## Features

- Application that simulates a native app and is easily approved by Google and Apple
- Icon generator from a single png file with dimensions 1024x1024
- Image of a solid color to create background and display on the sign-in screen on Android devices
- Sending Push Notifications through OneSignal
- Easily change webvier url in /lib/my_webviwer.dart file
- In your code editor search and Replace com.jmultimidia.dol with your package name (ex. com.mywebsite.myapp)

## Installation

Requires [Dart programming language | Dart](https://dart.dev/).
Requires [Flutter](https://flutter.dev/).
Requires [FVM](https://fvm.app/).

## OneSignal (Push Notifications)

- In the /lib/my_webview.dart file on line 17 change "513c09e4-7fdb-4c49-b529-469132f5301b" to your One Signal ID. final String singal = "513c09e4-7fdb-4c49-b529-469132f5301b";

## Install the dependencies and dev Dependencies.

```sh
fvm use 3.7.10
fvm flutter clean
fvm flutter pub get
```

For iOS

```sh
cd ios
sudo gem install cocoapods-deintegrate cocoapods-clean
pod deintegrate
pod cache clean --all
rm Podfile
rm Podfile.lock
```