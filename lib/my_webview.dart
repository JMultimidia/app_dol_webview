import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Importante para o Android no WebView novo
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Importante para o iOS no WebView novo
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyWebView extends StatefulWidget {
  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final String signalAppId = "513c09e4-7fdb-4c49-b529-469132f5301b";
  late final WebViewController _controller;
  String url = "";

  @override
  void initState() {
    super.initState();

    // Configura a barra de status
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));

    // Inicializa o OneSignal (Nova API v5)
    initOneSignal();

    // Inicializa o Controller do WebView (Nova API v4)
    _initWebViewController();

    // Busca o ID e carrega a URL
    getId().then((uuid) {
      setState(() {
        url = "https://diamanteonline.com.br";
        // Carrega a URL no controller
        _controller.loadRequest(Uri.parse(url));
      });
    });
  }

  // --- CONFIGURAÇÃO DO WEBVIEW (NOVA VERSÃO) ---
  void _initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0072BB))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Se quiser colocar uma barra de progresso, é aqui
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Injeta o JS para esconder rolagem horizontal (Substitui evaluateJavascript)
            controller
                .runJavaScript("document.body.style.overflowX = 'hidden';");
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Lógica de navegação externa
            if (request.url.startsWith("mailto:") ||
                request.url.startsWith("tel:") ||
                request.url.contains("maps")) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.contains("whatsapp")) {
              _handleWhatsapp(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.contains("instagram") ||
                request.url.contains("facebook")) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Configuração específica para Android (opcional, mas recomendada para debugging)
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> initOneSignal() async {
    // Nova API do OneSignal v5 removeu o .shared
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(signalAppId);
    await OneSignal.Notifications.requestPermission(true);
  }

  Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    }
  }

  // Atualizado para usar launchUrl (url_launcher v6)
  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $urlString';
    }
  }

  Future<void> _handleWhatsapp(String urlString) async {
    String fallbackUrl =
        urlString.replaceAll("whatsapp://", "https://api.whatsapp.com/");

    final Uri uri = Uri.parse(fallbackUrl);

    try {
      // Tenta abrir app externo
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Tenta abrir no browser se falhar
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
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
      // Se a URL estiver vazia, mostra Container, senão mostra o WebViewWidget
      body: url.isEmpty
          ? Container(color: Colors.white) // Um fundo branco enquanto carrega
          : WebViewWidget(controller: _controller),
    );
  }
}
