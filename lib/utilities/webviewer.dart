import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/payment_content.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class WebViewer extends StatefulWidget {
  final String initialUrl;
  final String pageTitle;
  final String type;

  const WebViewer(
      {Key? key,
      required this.initialUrl,
      required this.pageTitle,
      required this.type})
      : super(key: key);

  @override
  _WebViewerState createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  InAppWebViewController? _webViewController;
  bool _isFullScreen = false;
  bool _showExitFullScreenButton = false;
  double _loadingProgress = 0.0;
  late User? _user;
  late Map<String, dynamic>? _userData;
  String userEmail = '';
  String userNo = '';
  String userLname = '';
  String userFname = '';
  String userCollege = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData().then((_) {
      // The user data has been fetched, now we can access it
      setState(() {
        userNo = _userData?['userNo'] ?? '';
        userLname = _userData?['userLastName'] ?? '';
        userFname = _userData?['userFirstName'] ?? '';
        userCollege = _userData?['userCollege'] ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('_shouldShowExternalAppButton: ${_shouldShowExternalAppButton()}');
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(widget.pageTitle),
              leading: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      _onWillPop();
                    },
                  ),
                ],
              ),
              actions: [
                if (_shouldShowExternalAppButton())
                  IconButton(
                    icon: Icon(Icons.help_center), // Use your desired icon
                    onPressed: () {
                      _openPaymentContent();
                    },
                  ),
                if (_shouldShowExternalAppButton())
                  IconButton(
                    icon: Icon(Icons.open_in_new), // Use your desired icon
                    onPressed: () {
                      _openExternalApp();
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    _refreshPage();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(2.0),
                child: LinearProgressIndicator(
                    value: _loadingProgress, backgroundColor: Colors.white),
              ),
            ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: InAppWebViewSettings(
                allowContentAccess: true,
                userAgent: "random",
                javaScriptEnabled: true,
                useOnDownloadStart: true,
                mediaPlaybackRequiresUserGesture: false,
                incognito: true,
              ),
              onWebViewCreated: (InAppWebViewController webViewController) {
                _webViewController = webViewController;
              },
              onLoadStart: (InAppWebViewController controller, Uri? url) {
                setState(() {
                  _loadingProgress = 0.0;
                  _showExitFullScreenButton = _isFullScreen;
                });
              },
              onLoadStop: (InAppWebViewController controller, Uri? url) {
                setState(() {
                  _loadingProgress = 1.0;
                  _showExitFullScreenButton = _isFullScreen;
                });

                if (_isFullScreen) {
                  _hideAppBarAndBottomNavigationBar();
                }

                _autofillFields();
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  _loadingProgress = progress / 100;
                });
              },
            ),
            if (_showExitFullScreenButton)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: () {
                        _exitFullScreen();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: !_isFullScreen
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () async {
                      if (await _webViewController!.canGoBack()) {
                        _webViewController!.goBack();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () async {
                      if (await _webViewController!.canGoForward()) {
                        _webViewController!.goForward();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () async {
                      final currentUrl = await _webViewController!.getUrl();
                      if (currentUrl != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied: $currentUrl'),
                          ),
                        );
                        Clipboard.setData(
                            ClipboardData(text: currentUrl.toString()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to get the URL'),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: _isFullScreen
                        ? Icon(Icons.fullscreen_exit)
                        : Icon(Icons.fullscreen),
                    onPressed: () {
                      _toggleFullScreen();
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  bool _shouldShowExternalAppButton() {
    final type = widget.type;
    print('Current Type Color: $type');

    return (type == '#00a62d');
  }

  void _openExternalApp() async {
    final currentUrl = widget.initialUrl;
    String appStoreUrl = '';

    if (currentUrl == 'online.bpi.com.ph') {
      appStoreUrl = 'com.bpi.ng.app';
    } else if (currentUrl == 'online.bdo.com.ph') {
      appStoreUrl = 'ph.com.bdo.retail';
    } else if (currentUrl == 'onlinebanking.metrobank.com.ph') {
      appStoreUrl = 'ph.com.metrobank.mcc.mbonline';
    } else if (currentUrl == 'new.gcash.com') {
      appStoreUrl = 'com.globe.gcash.android';
    }

    // Check if the app can be launched
    await LaunchApp.openApp(
      androidPackageName: appStoreUrl,
      // openStore: false
    );
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user data and password manager from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Update the state with user data
      setState(() {
        _user = user;
        _userData = userData;

        // Get the email and password based on the portal title (pageTitle)
        if (userData != null && userData.containsKey('passwordManager')) {
          List<dynamic> portals = userData['passwordManager']['portals'];
          for (var portal in portals) {
            if (portal.isNotEmpty) {
              String portalTitle = portal.keys.first;
              if (portalTitle == widget.pageTitle) {
                Map<String, dynamic> portalDetails = portal[portalTitle];
                userEmail = portalDetails['email/user'] ?? '';
                password = portalDetails['password'] ?? '';
                break; // Stop searching after finding the matching portal
              }
            }
          }
        }
      });
    }
  }

  Future<Map<String, dynamic>?> fetchPaymentMethodData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('payment_procedures')
          .where('channels', isEqualTo: widget.pageTitle)
          .limit(1) // Limit the result to 1 document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        // Handle the case where no matching document is found
        print('No matching document for pageTitle: ${widget.pageTitle}');
        return null;
      }
    } catch (e) {
      // Handle any errors that occurred during the query
      print('Error fetching payment method data: $e');
      return null;
    }
  }

  void _openPaymentContent() async {
  // Fetch payment method data based on the pageTitle
  Map<String, dynamic>? paymentMethodData = await fetchPaymentMethodData();

  if (paymentMethodData != null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PaymentContent(paymentMethod: paymentMethodData),
        );
      },
    );
  } else {
    // Handle the case where no data is found
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('No data found for pageTitle: ${widget.pageTitle}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit ${widget.pageTitle} portal?',
              style: const TextStyle(
                fontFamily: 'Futura',
                color: AppConfig.appSecondaryTheme,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text('Are you sure you want to exit?',
                style: TextStyle(fontSize: 16)),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: AppConfig.appSecondaryTheme,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  void _autofillFields() {
    if (_webViewController != null) {
      _webViewController!.evaluateJavascript(
        source: """
          var usernameField = document.getElementsByName('username')[0];
          if (usernameField) {
            usernameField.value = '$userEmail';
          }

          var loginfmt = document.getElementsByName('loginfmt')[0];
          if (loginfmt) {
            loginfmt.value = '$userEmail'; 
          }

          var usernameInput = document.querySelector('input[placeholder="Username"]');
          if (usernameInput) {
            usernameInput.value = '$userEmail';
          }

          var emailInput = document.querySelector('input[placeholder="Email"]');
          if (emailInput) {
            emailInput.value = '$userEmail';
          }

          var Lname = document.getElementsByName('Lname')[0];
          if (Lname) {
            Lname.value = '$userLname';
          }

          var Fname = document.getElementsByName('Fname')[0];
          if (Fname) {
            Fname.value = '$userFname';
          }

          var emailInput = document.querySelector('input[type="email"]');
          if (emailInput) {
            emailInput.value = '$userEmail';
          }

          var studentNo = document.getElementsByName('studentNo')[0];
          if (studentNo) {
            studentNo.value = '$userNo';
          }

          var email = document.getElementsByName('email')[0];
          if (email) {
            email.value = '$userEmail';
          }

          var loginName = document.getElementsByName('loginName')[0];
          if (loginName) {
            loginName.value = '$userEmail';
          }

          var dept = document.getElementsByName('dept')[0];
        if (dept) {
          // Check if userCollege is one of the specified values
          if ('$userCollege' == 'COECSA - DCS' || '$userCollege' == 'COECSA - DOA' || '$userCollege' == 'COECSA - DOE') {
            dept.value = 'COECSA';
          } else {
            // Keep the original value if not one of the specified values
            dept.value = '$userCollege';
          }
          
          // Trigger the change event after setting the value
          var event = new Event('change', {'bubbles': true, 'cancelable': true});
          dept.dispatchEvent(event);
        }

          var passwordInput = document.querySelector('input[type="password"]');
          if (passwordInput) {
            passwordInput.value = '$password';
          }

          var password = document.getElementsByName('password')[0];
          if (password) {
            password.value = '$password'; 
          }

          var password = document.getElementsById('password')[0];
          if (password) {
            password.value = '$password'; 
          }

          var passworedInput = document.querySelector('input[placeholder="Password"]');
          if (passworedInput) {
            passworedInput.value = '$password';
          }

          var txtUser = document.getElementsByName('txtUser')[0];
          if (txtUser) {
            txtUser.value = '$userNo';
          }

        """,
      );
    }
  }

  void _refreshPage() {
    if (_webViewController != null) {
      _webViewController!.reload();
    }
  }

  Future<void> _hideAppBarAndBottomNavigationBar() async {
    if (!_isFullScreen) {
      return;
    }

    await _webViewController!.evaluateJavascript(
      source:
          "document.body.style.marginTop = '0'; document.body.style.marginBottom = '0';",
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _showExitFullScreenButton = _isFullScreen;
    });

    if (_isFullScreen) {
      _hideAppBarAndBottomNavigationBar();
    } else {
      // Restore original margins when exiting full-screen mode
      _webViewController!.evaluateJavascript(
        source:
            "document.body.style.marginTop = '56px'; document.body.style.marginBottom = '56px';",
      );
    }
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
      _showExitFullScreenButton = false;
    });

    // Restore original margins when exiting full-screen mode
    _webViewController!.evaluateJavascript(
      source:
          "document.body.style.marginTop = '56px'; document.body.style.marginBottom = '56px';",
    );
  }
}
