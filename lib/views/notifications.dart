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

    scheduleEventNotifications();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> scheduleEventNotifications() async {
    final now = DateTime.now();

    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('startDateTime', isGreaterThan: now)
          .orderBy('startDateTime')
          .get();

      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final startDateTime =
            (eventData['startDateTime'] as Timestamp).toDate();
        final endDateTime = (eventData['endDateTime'] as Timestamp).toDate();

        print('Event: ${eventData['title']}');
        print('Starts at: $startDateTime');
        print('Ends at: $endDateTime');
        print('-----------------------------');

        final timeDifference = startDateTime.difference(now);

        // Calculate remaining days and hours
        final remainingDays = timeDifference.inDays;
        final remainingHours = timeDifference.inHours;
        final remainingSeconds = timeDifference.inSeconds;

        print('Remaning days: $remainingDays');
        print('Remaning hours: $remainingHours');
        print('Remaning seconds: $remainingSeconds');

        print('DateTime now: $now');
        print('Start of the event: $startDateTime');
        print('End of the event: $endDateTime');

        if (remainingDays <= 1 && remainingHours > 1) {
          // Set notification for events starting in 1 day
          final eventTitle = eventData['title'] as String;
          final eventStartsTomorrow = '$eventTitle will start tomorrow';

          // Update isTomorrow flag for the event if it hasn't been updated yet
          if (!(eventData['isTomorrow'] ?? false)) {
            // Iterate through users to update their Notifications
            final usersSnapshot =
                await FirebaseFirestore.instance.collection('users').get();
            for (final userDoc in usersSnapshot.docs) {
              final userData = userDoc.data();
              final userNotifications = userData['Notifications'] ?? {};

              if (!userNotifications.containsKey(eventStartsTomorrow)) {
                userNotifications[eventStartsTomorrow] = {
                  'notifName': 'Event is Tomorrow',
                  'notifTitle': '$eventTitle will begin tomorrow',
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDoc.id)
                    .set({'Notifications': userNotifications},
                        SetOptions(merge: true));
              }
            }

            // Update isTomorrow flag for the event after notifications are sent
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventDoc.id)
                .update({'isTomorrow': true});
          }
        }

        if (remainingHours <= 1 && remainingSeconds > 1) {
          // Set notification for events starting in 1 hour
          final eventTitle = eventData['title'] as String;
          final eventStartsSoon = '$eventTitle will start soon';

          // Update isLater flag for the event if it hasn't been updated yet
          if (!(eventData['isLater'] ?? false)) {
            // Iterate through users to update their Notifications
            final usersSnapshot =
                await FirebaseFirestore.instance.collection('users').get();
            for (final userDoc in usersSnapshot.docs) {
              final userData = userDoc.data();
              final userNotifications = userData['Notifications'] ?? {};

              if (!userNotifications.containsKey(eventStartsSoon)) {
                userNotifications[eventStartsSoon] = {
                  'notifName': 'Event is Soon',
                  'notifTitle': '$eventTitle will begin in an hour',
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDoc.id)
                    .set({'Notifications': userNotifications},
                        SetOptions(merge: true));
              }
            }

            // Update isLater flag for the event after notifications are sent
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventDoc.id)
                .update({'isLater': true});
          }
        }

        // Check if the current time is between startDateTime and endDateTime
        if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
          // Set notification for ongoing events
          final eventTitle = eventData['title'] as String;
          final eventOngoing = '$eventTitle is ongoing';

          // Update isOngoing flag for the event if it hasn't been updated yet
          if (!(eventData['isOngoing'] ?? false)) {
            // Iterate through users to update their Notifications
            final usersSnapshot =
                await FirebaseFirestore.instance.collection('users').get();
            for (final userDoc in usersSnapshot.docs) {
              final userData = userDoc.data();
              final userNotifications = userData['Notifications'] ?? {};

              if (!userNotifications.containsKey(eventOngoing)) {
                userNotifications[eventOngoing] = {
                  'notifName': 'Event is Ongoing',
                  'notifTitle': '$eventTitle is currently ongoing',
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDoc.id)
                    .set({'Notifications': userNotifications},
                        SetOptions(merge: true));
              }
            }

            // Update isOngoing flag for the event after notifications are sent
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventDoc.id)
                .update({'isOngoing': true});
          }
        }
      }
    } catch (e) {
      print('Error scheduling event notifications: $e');
      // Handle error as needed
    }
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
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Stack(children: [
                      Container(
                        padding: const EdgeInsets.only(
                            bottom: 10), // Adjust padding for the button
                        child: SingleChildScrollView(
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
                                        width: 1,
                                        color: Color(0xffdbdbdb),
                                      ),
                                    ),
                                  ),
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
                                    onTap: () =>
                                        null, // Implement functionality here
                                    trailing: IconButton(
                                      onPressed: () async {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          final userID = user.uid;

                                          try {
                                            final documentSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(userID)
                                                    .get();

                                            if (documentSnapshot.exists) {
                                              final data =
                                                  documentSnapshot.data();
                                              if (data != null &&
                                                  data.containsKey(
                                                      'Notifications')) {
                                                final notifications =
                                                    data['Notifications']
                                                        as Map<String, dynamic>;

                                                MapEntry<String, dynamic>?
                                                    foundKey;
                                                for (var entry
                                                    in notifications.entries) {
                                                  if (entry.value[
                                                          'notifTitle'] ==
                                                      notifList[index]
                                                          .notifTitle) {
                                                    foundKey = entry;
                                                    break;
                                                  }
                                                }

                                                if (foundKey != null) {
                                                  await FirebaseFirestore
                                                      .instance
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
                                            print(
                                                'Error deleting notification: $e');
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
                        ),
                      ),
                    ]);
                  }
                },
              ),
            ),
            Container(
              height: 100, // Adjust button container height
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: Colors.white, // Set the background color
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final userID = user.uid;

                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userID)
                                .update({
                              'Notifications':
                                  {}, // Clear the Notifications map
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
                      style: ElevatedButton.styleFrom(
                        primary: AppConfig.appSecondaryTheme,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'CLEAR ALL',
                        style: TextStyle(
                          fontFamily: 'Futura',
                          color: AppConfig.appWhiteAlphaTheme,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
