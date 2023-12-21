import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewer extends StatefulWidget {
  final String initialUrl;

  const WebViewer({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _WebViewerState createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  late WebViewController _webViewController;
  late bool _showContentOnly;

  @override
  void initState() {
    super.initState();
    _showContentOnly = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Viewer'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
              initialUrl: widget.initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              },
              navigationDelegate: (NavigationRequest request) {
                if (_showContentOnly) {
                  return NavigationDecision.prevent;
                } else {
                  return NavigationDecision.navigate;
                }
              },
              onPageFinished: (String url) {
                if (_showContentOnly) {
                  _hideFooterAndHeader();
                } else {
                  _hideNavigation();
                }
              },
              gestureNavigationEnabled: false,
              userAgent: "random",
              zoomEnabled: false,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () async {
                        if (await _webViewController.canGoBack()) {
                          _webViewController.goBack();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () async {
                        if (await _webViewController.canGoForward()) {
                          _webViewController.goForward();
                        }
                      },
                    ),
                    IconButton(
  icon: Icon(Icons.content_copy),
  onPressed: () async {
    final currentUrl = await _webViewController.currentUrl();
    if (currentUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $currentUrl'),
        ),
      );
      Clipboard.setData(ClipboardData(text: currentUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get the URL'),
        ),
      );
    }
  },
),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _hideFooterAndHeader() async {
    await _webViewController.runJavascript(
      "javascript:(function() { var footer = document.getElementsByTagName('footer')[0]; footer.parentNode.removeChild(footer); })()",
    );
  }

  Future<void> _hideNavigation() async {
    await _webViewController.runJavascript(
      "javascript:(function() { document.getElementById('g-navigation').remove(); })()",
    );
  }
}
