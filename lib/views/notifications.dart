import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  late StreamSubscription<DatabaseEvent>? _subscription;



  @override
void initState() {
  super.initState();
  notificationsFuture = getNotifications();
}

@override
void dispose() {
  _subscription?.cancel(); // Cancel the Firebase listener if not null
  super.dispose();
}

  Future<void> getNotifications() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userID = user.uid;

    DatabaseReference referenceData = FirebaseDatabase.instance
        .reference()
        .child('Accounts')
        .child(userID)
        .child('Notifications');

    _subscription = referenceData.onValue.listen((DatabaseEvent event) {
  // Access the data within the DatabaseEvent object
  final dynamic snapshotData = event.snapshot.value;

  if (snapshotData != null) {
    final _notifMap = Map<dynamic, dynamic>.from(snapshotData);

    setState(() {
      notifList.clear();
      _notifMap.forEach((key, value) {
        final tasks = NotificationModel.fromMap(Map<String, dynamic>.from(value));
        notifList.add(tasks);
      });
    });
  }
});

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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const Help()));
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
                              bottom: BorderSide(width: 1, color: Color(0xffdbdbdb)))),
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
                            final delReference = await FirebaseDatabase.instance
                                .ref()
                                .child('Accounts')
                                .child(userID)
                                .child('Notifications')
                                .child(notifList[index].notifName)
                                .remove();

                            setState(() {
                              notifList.removeAt(index);
                            });
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
        width: 500,
        height: 55,
        child: FloatingActionButton(
          child: const Text('CLEAR ALL',
              style: TextStyle(
                  fontFamily: 'Futura',
                  color: Color(0xffA62D38),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          onPressed: () async {
            final delReference = await FirebaseDatabase.instance
                .ref()
                .child('Accounts')
                .child(userID)
                .child('Notifications')
                .remove();
            setState(() {
              notifList.clear();
            });
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              side: BorderSide(
                width: 2,
                color: Color(0xffA62D38),
              )),
          backgroundColor: Colors.white,
        ),
      ),
    );

}
