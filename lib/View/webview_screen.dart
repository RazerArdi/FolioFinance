import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a controller for the WebView
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: Text('Berita'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
