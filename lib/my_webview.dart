import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final String singal = "513c09e4-7fdb-4c49-b529-469132f5301b";
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String url = "";

  Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future<void> initPlaformState() async {
    await OneSignal.shared.setAppId(singal);
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));
    initPlaformState();
    getId().then((uuid) {
      setState(() {
        url = "https://diamanteonline.com.br";
      });
    });
    super.initState();
  }

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: AppBar(
          backgroundColor: Color(0xFF0072BB),
          elevation: 0,
        ),
      ),
      body: url.isEmpty
          ? Container()
          : WebView(
              initialUrl: url,
              navigationDelegate: (NavigationRequest request) async {
                if (request.url.contains("mailto:")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url.contains("tel:")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url.contains("whatsapp")) {
                  String fallbackUrl = request.url
                      .replaceAll("whatsapp://", "https://api.whatsapp.com/");

                  try {
                    bool launched = await launch(
                      fallbackUrl,
                      forceSafariVC: false,
                      universalLinksOnly: true,
                    );

                    if (!launched) {
                      await launch(fallbackUrl, forceSafariVC: false);
                    }
                  } catch (e) {
                    await launch(fallbackUrl, forceSafariVC: false);
                  }
                  return NavigationDecision.prevent;
                } else if (request.url.contains("maps")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url.contains("instagram") ||
                    request.url.contains("facebook")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              backgroundColor: Color(0xFF0072BB),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                // Desabilita a rolagem horizontal
                webViewController.evaluateJavascript('''
                 document.body.style.overflowX = 'hidden';
                ''');
              },
            ),
    );
  }
}
