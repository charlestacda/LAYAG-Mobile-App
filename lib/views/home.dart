import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/main.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/payment_procedures.dart';
import 'package:lpu_app/views/todo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpu_app/views/borrow_return.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lpu_app/models/portal_model.dart';
import 'package:lpu_app/models/tip_model.dart';
import 'package:lpu_app/utilities/webviewer.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int selected = 4;
  int crossAxisCount = 2;
  double crossAxisSpacing = 2.5;
  double mainAxisSpacing = 5;
  double textSize = 14;
  bool isPopedUp = false;
  Random random = Random();
  int randomNumber = 0;
  List<String> fetchedTips = [];
  String randomTip = '';
  late FirebaseFirestore db;
  late List<Portal> portals = [];
  StreamSubscription<QuerySnapshot>? portalsSubscription;
  DateTime lastCacheRefresh = DateTime(0);
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late User? _user;
  late String userType;

  @override
  void initState() {
    super.initState();
    randomNumber = random.nextInt(8);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _promptNotificationPermissions();
    });

    fetchUserType();

    loadSelectedOption().then((value) {
      setState(() {
        switch (value) {
          case 0:
            crossAxisCount = 1;
            crossAxisSpacing = 5;
            mainAxisSpacing = 10;
            textSize = 28;
            selected = 0;
            break;
          case 1:
            crossAxisCount = 2;
            crossAxisSpacing = 2.5;
            mainAxisSpacing = 5;
            textSize = 14;
            selected = 1;
            break;
          case 2:
            crossAxisCount = 3;
            crossAxisSpacing = .1;
            mainAxisSpacing = 1;
            textSize = 10;
            selected = 2;
            break;
        }
      });
    });
  }

  Future<void> _promptNotificationPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool askedForPermission = prefs.getBool('askedForPermission') ?? false;

    if (!askedForPermission) {
      PermissionStatus status = await Permission.notification.status;

      if (status.isGranted) {
        // Permission is already granted, save the flag
        prefs.setBool('askedForPermission', true);
      } else if (status.isPermanentlyDenied) {
        // Permission is permanently denied, save the flag and handle accordingly
        prefs.setBool('askedForPermission', true);

        // Optionally: Show a message to the user that they need to enable the permission in settings
        // You might want to navigate the user to the app settings using AppSettings.openAppSettings()
      } else {
        PermissionStatus permissionStatus =
            await Permission.notification.request();
        if (permissionStatus.isGranted) {
          // Permission granted, save the flag
          prefs.setBool('askedForPermission', true);
        } else {
          // Handle if permission is not granted
          // For example, show an error message or handle it as required in your app
        }
      }
    }
  }

  Future<void> fetchUserType() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      try {
        DocumentSnapshot snapshot = await userReference.get();

        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;
          final String fetchedUserType = userData['userType'] ?? '';
          userType = userData['userType'] ?? '';

          Provider.of<UserTypeProvider>(context, listen: false)
              .setUserType(fetchedUserType);

          fetchTips(fetchedUserType);
          fetchPortals(fetchedUserType);
        } else {
          // Handle case where user document doesn't exist
        }
      } catch (e) {
        // Handle exceptions, such as FirestoreError, if any
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> fetchTips(String userType) async {
    try {
      if (userType == 'Admin') {
        setState(() {
          randomTip = 'Welcome Admin!';
          checkAndShowDialog();
        });
      } else {
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance.collection('tips').get();

        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.docs.toList();

          List<String> fetchedTipsList = documents
              .where((doc) {
                final bool visibleToStudents =
                    doc['visibleToStudents'] ?? false;
                final bool visibleToEmployees =
                    doc['visibleToEmployees'] ?? false;
                final bool archived = doc['archived'] ?? false;

                if (userType == 'Student') {
                  return visibleToStudents && !archived;
                } else if (userType == 'Faculty') {
                  return visibleToEmployees && !archived;
                }

                return false;
              })
              .map((doc) => Tip.fromFirestore(doc).content)
              .toList();

          setState(() {
            fetchedTips = fetchedTipsList;

            if (fetchedTips.isNotEmpty) {
              int randomIndex = random.nextInt(fetchedTips.length);
              randomTip = fetchedTips[randomIndex];

              // Call checkAndShowDialog here, as data has been fetched successfully
              checkAndShowDialog();
            }
          });
        } else {
          print('No tips available in the collection.');
        }
      }
    } catch (e) {
      print('Error fetching tips: $e');
    }
  }

  Future<void> fetchPortals(String userType) async {
    try {
      portalsSubscription = FirebaseFirestore.instance
          .collection('portals')
          .orderBy('dateAdded', descending: false)
          .snapshots()
          .listen((querySnapshot) {
        List<Portal> fetchedPortals = [];

        for (final doc in querySnapshot.docs) {
          bool visibleToUser = false;
          bool archived = doc['archived'];

          if (userType == 'Student') {
            visibleToUser = !archived && doc['visibleToStudents'];
          } else if (userType == 'Faculty') {
            visibleToUser = !archived && doc['visibleToEmployees'];
          } else if (userType == 'Admin') {
            visibleToUser = true; // Admin has access to all portals
          }

          if (visibleToUser) {
            fetchedPortals.add(Portal(
              id: doc.id,
              title: doc['title'],
              link: doc['link'],
              color: doc['color'],
              imageUrl: doc['imageUrl'],
              dateAdded: (doc['dateAdded'] as Timestamp).toDate(),
              dateEdited: (doc['dateEdited'] as Timestamp).toDate(),
              visibleToEmployees: doc['visibleToEmployees'],
              visibleToStudents: doc['visibleToStudents'],
              archived: archived,
            ));
          }
        }

        setState(() {
          portals = fetchedPortals;
        });
      });
    } catch (e) {
      print('Error fetching portals: $e');
    }
  }

  @override
  void dispose() {
    portalsSubscription?.cancel();
    super.dispose();
  }

  void checkAndShowDialog() async {
    // Get the shared preferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the dialog has been shown before
    bool dialogShown = prefs.getBool('dialogShown') ?? false;
    if (!dialogShown) {
      // If the dialog has not been shown, show it
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Image.asset(
                  'assets/images/register_complete.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            content: Text(
              randomTip,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
          );
        },
      );
      prefs.setBool('dialogShown', true);
      analytics.setAnalyticsCollectionEnabled(true);

      analytics.logEvent(
        name: 'show_dialog',
        parameters: <String, dynamic>{
          'dialog_shown': randomTip,
        },
      );
    }
  }

  Future<void> saveSelectedOption(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedOption', value);
  }

  // Method to load the selected option
  Future<int> loadSelectedOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedOption') ??
        1; // Default value is 1 for Option 2
  }

  @override
  Widget build(BuildContext context) {
    List<Portal> otherPortals =
        portals.where((portal) => portal.color == "#a62d38").toList();
    List<Portal> libraryPortals =
        portals.where((portal) => portal.color == "#a42d6d").toList();
    List<Portal> paymentPortals =
        portals.where((portal) => portal.color == "#00a62d").toList();
    List<Portal> adminPortals =
        portals.where((portal) => portal.color == "#2da6a6").toList();
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            // Fetch the current user details
            final user = FirebaseAuth.instance.currentUser;
            return IconButton(
              icon: ClipOval(
                child: user != null && user.photoURL != null
                    ? Image.network(
                        user.photoURL!,
                        width: 24,
                        height: 24,
                      )
                    : Image.asset(
                        'assets/images/user.png',
                        width: 24,
                        height: 24,
                      ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Notifications(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/home_header.png',
                width: double.infinity,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<int>(
                        icon: const Icon(Icons.grid_view),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Text('Large Cards'),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text('Medium Cards'),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text('Small Cards'),
                          ),
                        ],
                        onSelected: (value) async {
                          // Handle menu item selection
                          setState(() {
                            switch (value) {
                              case 0:
                                crossAxisCount = 1;
                                crossAxisSpacing = 5;
                                mainAxisSpacing = 10;
                                textSize = 28;
                                selected = 0;
                                break;
                              case 1:
                                crossAxisCount = 2;
                                crossAxisSpacing = 2.5;
                                mainAxisSpacing = 5;
                                textSize = 14;
                                selected = 1;
                                break;
                              case 2:
                                crossAxisCount = 3;
                                crossAxisSpacing = .1;
                                mainAxisSpacing = 1;
                                textSize = 10;
                                selected = 2;
                                break;
                            }
                          });

                          await saveSelectedOption(value);
                        },
                        initialValue: selected,
                      ),
                    ),
                    // Other Portals
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      shrinkWrap: true,
                      children: [
                        ...otherPortals.map((portal) {
                          return buildPortalCard(portal, textSize);
                        }),
                        if (libraryPortals.isNotEmpty)
                        GestureDetector(
                            onTap: () {
                              openLibraryDialog(libraryPortals);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      "#a42d6d".replaceAll("#", "0xFF"))),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        'assets/images/library.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'ARC Online Resources',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: textSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (paymentPortals.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              openPaymentDialog(paymentPortals);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      "#00a62d".replaceAll("#", "0xFF"))),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        'assets/images/payment.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Offsite Payment Channels',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: textSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (adminPortals.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              openAdminDialog(adminPortals);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      "#2da6a6".replaceAll("#", "0xFF"))),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        'assets/images/admin.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Administrator Links',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: textSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Button after the GridView
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reauthenticateUserBeforeOpeningDialog(context);
        },
        child: Icon(Icons.vpn_key),
        backgroundColor: AppConfig.appLightRedTheme,
      ),
    );
  }

  void reauthenticateUserBeforeOpeningDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController(text: '');
    bool isLoading = false;
    bool showPassword = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'PASSWORD MANAGER',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appSecondaryTheme,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter your password first',
                      style: TextStyle(),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: !showPassword,
                  ),
                  SizedBox(height: 16),
                  isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Align buttons to the right
                          children: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Futura',
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String enteredPassword =
                                    passwordController.text.trim();

                                if (enteredPassword.isNotEmpty) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  if (await reauthenticateUser(
                                      enteredPassword)) {
                                    Navigator.pop(
                                        context); // Close reauthentication dialog
                                    showPasswordManagerDialog(userType);
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });

                                    // Display an error message or handle incorrect password
                                    // For simplicity, you can show a SnackBar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Incorrect password!'),
                                      ),
                                    );
                                  }
                                } else {
                                  // Handle case where entered password is blank
                                  print('Entered password is blank');
                                }
                              },
                              child: Text('Enter'),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> reauthenticateUser(String enteredPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Entered Password: $enteredPassword');

        // Use Firebase Authentication to reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: enteredPassword);

        await user.reauthenticateWithCredential(credential);

        print('Reauthentication Successful');
        return true; // Reauthentication successful
      }
    } catch (e) {
      print('Reauthentication error: $e');
    }

    print('Reauthentication Failed');
    return false; // Reauthentication failed
  }

  void showPasswordManagerDialog(String userType) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user document
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      // Check if the user document exists and has the 'passwordManager' field
      if (userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)
              .containsKey('passwordManager')) {
        // Get the existing passwordManager map field
        Map<String, dynamic> passwordManager =
            (userDoc.data() as Map<String, dynamic>)['passwordManager'];

        // Fetch all portal titles
        List portalTitles = passwordManager['portals'] != null
            ? (passwordManager['portals'] as List)
                .map((item) => item.keys.first)
                .toList()
            : [];

        // Filter portals based on user type
        List<Portal> filteredPortals = portals.where((portal) {
          bool visibleToUser = false;
          if (userType == 'Student') {
            visibleToUser = portal.visibleToStudents;
          } else if (userType == 'Faculty') {
            visibleToUser = portal.visibleToEmployees;
          } else if (userType == 'Admin') {
            visibleToUser = true; // Admin has access to all portals
          }
          return visibleToUser;
        }).toList();

        // Update passwordManager with filtered portal titles
        for (Portal portal in filteredPortals) {
          // Check if the portal already exists in the passwordManager
          if (!portalTitles.contains(portal.title)) {
            // If it doesn't exist, add the portal with default values
            passwordManager['portals'].add({
              portal.title: {
                'email/user': user.email,
                'password': '',
              },
            });
            // Add the portal title to the list
            portalTitles.add(portal.title);
          }
        }

        // Update the user document with the new passwordManager
        await userDocRef
            .set({'passwordManager': passwordManager}, SetOptions(merge: true));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'PASSWORD MANAGER',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appSecondaryTheme,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  if (portalTitles.isNotEmpty)
                    SizedBox(
                      width: double
                          .maxFinite, // Make the SizedBox take up maximum width
                      height: 285, // Set a specific height for the ListView
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: portalTitles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              String selectedPortalTitle = portalTitles[index];
                              showPortalDetailsDialog(
                                selectedPortalTitle,
                                passwordManager[selectedPortalTitle],
                                passwordManager,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppConfig.appSecondaryTheme,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                portalTitles[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Text('No portal titles available.'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            fontFamily: 'Futura',
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // If 'passwordManager' field doesn't exist, create a new one
        Map<String, dynamic> passwordManager = {'portals': []};

        // Fetch all portal titles
        List<String> portalTitles =
            portals.map((portal) => portal.title).toList();

        // Filter portals based on user type
        List<Portal> filteredPortals = portals.where((portal) {
          bool visibleToUser = false;
          if (userType == 'Student') {
            visibleToUser = portal.visibleToStudents;
          } else if (userType == 'Faculty') {
            visibleToUser = portal.visibleToEmployees;
          } else if (userType == 'Admin') {
            visibleToUser = true; // Admin has access to all portals
          }
          return visibleToUser;
        }).toList();

        // Update passwordManager with filtered portal titles
        passwordManager['portals'] = filteredPortals
            .map((portal) => {
                  portal.title: {
                    'email/user': user.email,
                    'password': '',
                  },
                })
            .toList();

        // Update the user document with the new passwordManager
        await userDocRef
            .set({'passwordManager': passwordManager}, SetOptions(merge: true));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'PASSWORD MANAGER',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appSecondaryTheme,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  if (portalTitles.isNotEmpty)
                    SizedBox(
                      width: double
                          .maxFinite, // Make the SizedBox take up maximum width
                      height: 285, // Set a specific height for the ListView
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: portalTitles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              String selectedPortalTitle = portalTitles[index];
                              showPortalDetailsDialog(
                                selectedPortalTitle,
                                passwordManager[selectedPortalTitle],
                                passwordManager,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppConfig.appSecondaryTheme,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                portalTitles[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Text('No portal titles available.'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            fontFamily: 'Futura',
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  void showPortalDetailsDialog(
      String portalTitle,
      Map<String, dynamic>? portalDetails,
      Map<String, dynamic> passwordManager) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool showPassword = false;
    bool isLoading = false;

    Stream<DocumentSnapshot<Map<String, dynamic>>> portalStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: portalStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return CircularProgressIndicator(); // Loading indicator while fetching data
            }

            Map<String, dynamic>? portalDetailsMap;

            List<dynamic> portalsList = (snapshot.data
                ?.data()?['passwordManager']['portals'] as List<dynamic>);

            for (var item in portalsList) {
              if (item is Map<String, dynamic> &&
                  item.containsKey(portalTitle)) {
                portalDetailsMap = item[portalTitle];
                break;
              }
            }

            // Populate the controllers with existing data if available
            emailController.text =
                (portalDetailsMap ?? const {})['email/user'] ?? '';
            passwordController.text =
                (portalDetailsMap ?? const {})['password'] ?? '';

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(portalTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email/User'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              showPasswordManagerDialog(userType);
                            },
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontFamily: 'Futura',
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Save button logic
                              await savePortalDetails(portalTitle, {
                                'email/user': emailController.text,
                                'password': passwordController.text,
                              });
                              Navigator.pop(context);
                              showPasswordManagerDialog(userType);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> savePortalDetails(
      String portalTitle, Map<String, dynamic> details) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch user document
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          Map<String, dynamic>? passwordManager = userData?['passwordManager'];

          if (passwordManager != null &&
              passwordManager.containsKey('portals')) {
            List<dynamic> portalsList = passwordManager['portals'];

            // Find the index of the portal with the given title
            int portalIndex = portalsList.indexWhere((portal) {
              return portal.containsKey(portalTitle);
            });

            if (portalIndex != -1) {
              // If the portal with the given title exists, update its details
              portalsList[portalIndex] = {portalTitle: details};
            } else {
              // If the portal with the given title doesn't exist, add a new one
              portalsList.add({portalTitle: details});
            }

            // Update the user document with the modified passwordManager
            await userDocRef.set({
              'passwordManager': {'portals': portalsList}
            }, SetOptions(merge: true));
          }
        }
      } catch (e) {
        print('Error saving portal details: $e');
      }
    }
  }

  void openLibraryDialog(List<Portal> libraryPortals){
    int crossAxisCount = 2;
    double rowHeight = 145.0; // Adjust as needed based on your card content

    int rowCount = (libraryPortals.length / crossAxisCount).ceil();
    double gridViewHeight = rowCount * rowHeight;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ARC Online Resources', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  SizedBox(width: 15),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: gridViewHeight,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 8.0,
              children: libraryPortals.map((portal) {
                return buildPortalCard(portal, 10);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void openPaymentDialog(List<Portal> paymentPortals) {
    int crossAxisCount = 2;
    double rowHeight = 145.0; // Adjust as needed based on your card content

    int rowCount = (paymentPortals.length / crossAxisCount).ceil();
    double gridViewHeight = rowCount * rowHeight;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Offsite Payment\nChannels', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.help_center),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentProcedures()));
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: gridViewHeight,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 8.0,
              children: paymentPortals.map((portal) {
                return buildPortalCard(portal, 10);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void openAdminDialog(List<Portal> adminPortals) {
    int crossAxisCount = 2;
    double rowHeight = 145.0; // Adjust as needed based on your card content

    int rowCount = (adminPortals.length / crossAxisCount).ceil();
    double gridViewHeight = rowCount * rowHeight;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Administrator Links', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 15),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: gridViewHeight,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 8.0,
              children: adminPortals.map((portal) {
                return buildPortalCard(portal, 10);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget buildPortalCard(Portal portal, double size) {
    Color cardColor = Color(int.parse(portal.color.replaceAll("#", "0xFF")));
    return GestureDetector(
      onTap: () async {
        if (portal.title == 'GCash') {
          await LaunchApp.openApp(
            androidPackageName: 'com.globe.gcash.android',
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewer(
                initialUrl: portal.link,
                pageTitle: portal.title,
                type: portal.color,
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: portal.imageUrl.isNotEmpty
                      ? Image.network(
                          portal.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Text('Image unavailable');
                          },
                        )
                      : const SizedBox(), // Check if img is empty
                ),
                const SizedBox(height: 16),
                Text(
                  portal.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                    fontSize: size,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
