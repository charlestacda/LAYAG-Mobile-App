import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/main.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/payment_procedures.dart';
import 'package:lpu_app/views/todo.dart';
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
  bool isPopedUp = false;
  Random random = Random();
  int randomNumber = 0;
  List<String> fetchedTips = [];
  String randomTip = '';
  late FirebaseFirestore db;
  late List<Portal> portals = [];
  StreamSubscription<QuerySnapshot>? portalsSubscription;
  DateTime lastCacheRefresh = DateTime(0);
  late Timer _timer;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    randomNumber = random.nextInt(8);

    fetchUserType();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/images/home_header.png',
              width: double.infinity,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 8.0,
                shrinkWrap:
                    true, // Added this to allow content to wrap its height
                children: portals.map((portal) {
                  Color cardColor =
                      Color(int.parse(portal.color.replaceAll("#", "0xFF")));
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WebViewer(initialUrl: portal.link),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Modify the code where you display the image in the UI
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
                                          return const Text(
                                              'Image unavailable');
                                        },
                                      )
                                    : const SizedBox(), // Check if img is empty
                              ),
                              const SizedBox(height: 16),
                              Text(
                                portal.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
