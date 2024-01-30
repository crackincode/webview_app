import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Webview'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent)
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: (progress) {
        print(progress);
      },
      onPageStarted: (url) {
        print(url);
      },
      onPageFinished: (url) {
        print(url);
      },
      onWebResourceError: (error) {
        print(error);
      },
      onNavigationRequest: (request) {
        print(request.url);

        if (request.url.startsWith('share:')) {
          Share.share(request.url.substring(8));
          return NavigationDecision.prevent;
        }
        // check mailto: and tel: links
        if (request.url.startsWith('mailto:') ||
            request.url.startsWith('tel:') ||
            request.url.startsWith('whatsapp:')) {
          Uri uri = Uri.parse(request.url);
          canLaunchUrl(uri).then((canLaunch) {
            print('Can launch url: $canLaunch');
            if (canLaunch) {
              print('Launching url: $uri');
              launchUrl(uri);
            } else {
              print('Cannot launch url: $uri');
            }
          }).catchError((error) {
            print('Error launching url: $error');
          });
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ))
    ..loadRequest(Uri.parse('https://amphibi.jogjaide.web.id/'));

  Future<bool> exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
            child: SafeArea(child: WebViewWidget(controller: controller)),
            onWillPop: () => exitApp(context)));
  }
}
