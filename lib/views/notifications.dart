import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/models/notification_model.dart';

List<NotificationModel> notifList = [];

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  late Future<void> notificationsFuture;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    notificationsFuture = getNotifications();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> getNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userID = user.uid;

      try {
        final documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .get();

        if (documentSnapshot.exists) {
          final data = documentSnapshot.data();
          if (data != null && data.containsKey('Notifications')) {
            final notifications = data['Notifications'] as Map<String, dynamic>;

            setState(() {
              notifList = notifications.entries.map((entry) {
                final value = entry.value as Map<String, dynamic>;
                return NotificationModel(
                  notifTitle: value['notifTitle'],
                  notifName: value['notifName'],
                );
              }).toList();
            });
          }
        }
      } catch (e) {
        print('Error fetching notifications: $e');
        // Handle error as needed
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
        body: FutureBuilder<void>(
          future: notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                physics: const ScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      padding: const EdgeInsets.all(10),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: notifList.length,
                      itemBuilder: (context, index) => Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffdbdbdb)))),
                        margin: const EdgeInsets.fromLTRB(0, 2, 0, 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications,
                            color: AppConfig.appSecondaryTheme,
                          ),
                          title: Text(
                            notifList[index].notifTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () => null, // Implement functionality here
                          trailing: IconButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                final userID = user.uid;

                                try {
                                  final documentSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userID)
                                          .get();

                                  if (documentSnapshot.exists) {
                                    final data = documentSnapshot.data();
                                    if (data != null &&
                                        data.containsKey('Notifications')) {
                                      final notifications =
                                          data['Notifications']
                                              as Map<String, dynamic>;

                                      MapEntry<String, dynamic>? foundKey;
                                      for (var entry in notifications.entries) {
                                        if (entry.value['notifTitle'] ==
                                            notifList[index].notifTitle) {
                                          foundKey = entry;
                                          break;
                                        }
                                      }

                                      if (foundKey != null) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userID)
                                            .update({
                                          'Notifications.${foundKey.key}':
                                              FieldValue.delete(),
                                        });

                                        setState(() {
                                          notifList.removeAt(index);
                                        });
                                      }
                                    }
                                  }
                                } catch (e) {
                                  print('Error deleting notification: $e');
                                  // Handle error as needed
                                }
                              }
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          width: 300,
          height: 100,
          child: Container(
            margin:
                EdgeInsets.only(bottom: 40), // Moves the button a bit higher
            child: FloatingActionButton(
              child: const Text(
                'CLEAR ALL',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appWhiteAlphaTheme,
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final userID = user.uid;

                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userID)
                        .update({
                      'Notifications': {}, // Clear the Notifications map
                    });

                    setState(() {
                      notifList
                          .clear(); // Clear the local list of notifications
                    });
                  } catch (e) {
                    print('Error clearing notifications: $e');
                    // Handle error as needed
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  width: 2,
                  color: AppConfig.appSecondaryTheme,
                ),
              ),
              backgroundColor: AppConfig.appSecondaryTheme,
            ),
          ),
        ),
      );
}
