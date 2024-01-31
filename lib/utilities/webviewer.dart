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
                _showHiddenContainer();
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
                    icon: Icon(Icons.auto_awesome), // Manual Autofill Icon
                    onPressed: () {
                      _manualAutofill(); // Call your manual autofill function
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

  void _manualAutofill() {
    _autofillFields();
    _autofillFields();
  }

  bool _shouldShowExternalAppButton() {
    final type = widget.type;
    print('Current Type Color: $type');

    return (type == '#00a62d');
  }

  void _openExternalApp() async {
    final currentUrl = widget.initialUrl;
    String appStoreUrl = '';

    if (currentUrl == 'https://online.bpi.com.ph' ||
        currentUrl == 'https://www.bpi.com.ph') {
      appStoreUrl = 'com.bpi.ng.app';
    } else if (currentUrl == 'https://online.bdo.com.ph') {
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
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
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

  void _showHiddenContainer() {
  if (_webViewController != null) {
    _webViewController!.evaluateJavascript(
      source: """
        var hiddenContainer = document.querySelector('.container.mg-150');
        if (hiddenContainer) {
          hiddenContainer.style.display = 'block';
          
          // Show child elements as well
          var childElements = hiddenContainer.querySelectorAll('*');
          for (var childElement in childElements) {
            childElement.style.display = 'block';
          }
        }
      """,
    );
  }
}



  void _autofillFields() {
    if (_webViewController != null) {
      _webViewController!.evaluateJavascript(
        source: """
          //myLPU
          var myLPUE = document.getElementById('username');
          var myLPUP = document.getElementById('password');
          if (myLPUE) {
            myLPUE.value = '$userEmail';
          }
          if (myLPUP) {
            myLPUP.value = '$password';
          }

          //AIMS
          var AIMSU = document.getElementsByName('txtUser')[0];
          var AIMSP = document.getElementsByName('txtPwd')[0];
          if (AIMSU) {
            AIMSU.value = '$userEmail';
          }
          if (AIMSP) {
            AIMSP.value = '$password';
          }

          //OPAC
          var OPACU = document.getElementById('ID_loginName');
          var OPACP = document.getElementById('ID_password');
          if (OPACU) {
            OPACU.value = '$userEmail';
          }
          if (OPACP) {
            OPACP.value = '$password';
          }

          //Book Borrowing Request
          var BBRLast = document.getElementsByName('Lname')[0];
          var BBRFirst = document.getElementsByName('Fname')[0];
          var BBRNum = document.getElementsByName('studentNo')[0];
          var BBREmail = document.getElementsByName('email')[0];
          var BBRDept = document.getElementsByName('dept')[0];
          if (BBRLast) {
            BBRLast.value = '$userLname';
          }
          if (BBRFirst) {
            BBRFirst.value = '$userFname';
          }
          if (BBRNum) {
            BBRNum.value = '$userNo';
            BBRNum.disabled = true;
          }
          if (BBREmail) {
            BBREmail.value = '$userEmail';
          }
          if (BBRDept) {
          if ('$userCollege' == 'COECSA - DCS' || '$userCollege' == 'COECSA - DOA' || '$userCollege' == 'COECSA - DOE') {
            BBRDept.value = 'COECSA';
          } else {
            BBRDept.value = '$userCollege';
          }
          var event = new Event('change', {'bubbles': true, 'cancelable': true});
          dept.dispatchEvent(event);
          }

          //BBA
          var BBAU = document.getElementById('loginID');
          var BBAP = document.getElementById('loginPass');
          if (BBAU) {
            BBAU.value = '$userNo';
          }
          if (BBAP) {
            BBAP.value = '$password';
          }


          //BDO
          var BDOU = document.getElementsByName('channelUserID')[0];
          var BDOP = document.getElementsByName('channelPswdPin')[0];
          if (BDOU) {
            BDOU.value = '$userEmail';
          }
          if (BDOP) {
            BDOP.value = '$password';
          }


          //Metrobank
          var usernameInput = document.querySelector('input[name="username"]');
          var passwordInput = document.querySelector('input[name="password"]');
          var loginButton = document.querySelector('#loginBtn1');

          function tapAndFill(element, value) {
          if (element) {
                    // Trigger focus event
                    element.focus();
                    
                    // Set field value
                    element.value = value;

                    // Trigger input and change events
                    element.dispatchEvent(new InputEvent('input', { bubbles: true }));
                    element.dispatchEvent(new Event('change', { bubbles: true }));
                }
            }

            tapAndFill(usernameInput, '$userEmail');
            tapAndFill(passwordInput, '$password');

            // Check if both fields have values and enable/disable the login button accordingly
            if (usernameInput && passwordInput) {
                if (usernameInput.value.trim() !== '' && passwordInput.value.trim() !== '') {
                    loginButton.removeAttribute('disabled');
                } else {
                    loginButton.setAttribute('disabled', 'true');
                }
            }
            

          //CMS
          var emailInput = document.querySelector('input[placeholder="Email"]');
var passwordInput = document.querySelector('input[placeholder="Password"]');

// Function to simulate tapping or selecting the field and filling the value
function tapAndFill(element, value) {
    if (element) {
        // Add the 'Mui-focused' class to simulate field selection
        element.classList.add('Mui-focused');

        // Trigger focus event
        element.focus();
        
        // Set field value
        element.value = value;

        // Trigger input and change events
        element.dispatchEvent(new InputEvent('input', { bubbles: true }));
        element.dispatchEvent(new Event('change', { bubbles: true }));
    }
}

// Fill the email and password fields
tapAndFill(emailInput, '$userEmail');
tapAndFill(passwordInput, '$password');


          //BPI
          var usernameInput = document.querySelector('input[placeholder="Username"]');
          var passwordInput = document.querySelector('input[placeholder="Password"]');
        
          if (usernameInput) {
          usernameInput.value = '$userEmail';
          usernameInput.dispatchEvent(new InputEvent('input', { bubbles: true }));
          usernameInput.dispatchEvent(new Event('change', { bubbles: true }));
          }
        
          if (passwordInput) {
          passwordInput.value = '$password';
          passwordInput.dispatchEvent(new InputEvent('input', { bubbles: true }));
          passwordInput.dispatchEvent(new Event('change', { bubbles: true }));
          }

          var injector = angular.element(document.querySelector('your-angular-root-element')).injector();
          var rootScope = injector.get('\$rootScope');
          rootScope.\$apply();

          var loginButton = document.querySelector('ui-bpi-button[buttontype="submit"] button');
          var form = document.querySelector('form');
          if (form && form.checkValidity()) {
            loginButton.removeAttribute('disabled');
          } else {
            loginButton.setAttribute('disabled', 'true');
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
