import 'dart:async';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewer {
  static late Completer<WebViewController> webViewerCompleter;

  static late WebViewController webViewerController;

  static init() {
    webViewerCompleter = Completer<WebViewController>();

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  static get(String url, {showContentOnly = false}) {
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        webViewerController = webViewController;

        webViewerCompleter.complete(webViewController);
      },
      navigationDelegate: (NavigationRequest request) {
        if (showContentOnly == true) {
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
      },
      onPageFinished: (String url) {
        if (showContentOnly == true) {
          webViewerController.runJavascript("javascript:(function() { var footer = document.getElementsByTagName('footer')[0]; footer.parentNode.removeChild(footer); })()").then((value) {}).catchError((onError) {});
        } else {
          webViewerController.runJavascript("javascript:(function() { var footer = document.getElementsByTagName('footer')[0]; footer.parentNode.removeChild(footer); })()").then((value) {}).catchError((onError) {});
        }
      },
      onProgress: (int progress) {
        if (showContentOnly == true) {
          webViewerController.runJavascript("javascript:(function() { document.getElementById('g-navigation').remove(); document.getElementById('g-header').remove(); document.querySelectorAll('.entry-header').forEach(element => { element.remove(); }); })()").then((value) {}).catchError((onError) {});
        } else {
          webViewerController.runJavascript("javascript:(function() { document.getElementById('g-navigation').remove(); })()").then((value) {}).catchError((onError) {});
        }
      },
      onWebResourceError: (WebResourceError error) {},
      gestureNavigationEnabled: false,
    );
  }
}