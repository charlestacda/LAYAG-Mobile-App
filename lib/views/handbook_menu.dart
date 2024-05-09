import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:provider/provider.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/main.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HandbookMenu extends StatefulWidget {
  const HandbookMenu({Key? key}) : super(key: key);

  @override
  _HandbookMenuState createState() => _HandbookMenuState();
}

class _HandbookMenuState extends State<HandbookMenu> {
  late Stream<QuerySnapshot> handbookStream;
  late User? _user;
  late String userType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    handbookStream =
        FirebaseFirestore.instance.collection('handbooks').snapshots();
    checkForNewHandbooks();
  }

  Future<void> checkForNewHandbooks() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  if (_auth.currentUser != null) {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid;

    // Reference to the user's handbook collection
    final userHandbookCollectionRef = _firestore.collection('users').doc(userId).collection('handbooks');

    // Get a list of handbook IDs the user already has
    final userHandbookIds = await userHandbookCollectionRef.get().then((querySnapshot) => querySnapshot.docs.map((doc) => doc.id).toList());

    // Reference to the 'handbooks' collection
    final handbooksRef = _firestore.collection('handbooks');

    // Update existing handbooks
    await Future.forEach(userHandbookIds, (handbookId) async {
      final userHandbookDocRef = userHandbookCollectionRef.doc(handbookId);
      final handbookDocSnapshot = await handbooksRef.doc(handbookId).get();
      if (handbookDocSnapshot.exists) {
        final handbookTitle = handbookDocSnapshot.data()?['title'];
        final handbookContent = handbookDocSnapshot.data()?['content'];
        
        // Update the title and content fields in the user's handbook document
        await userHandbookDocRef.update({
          'title': handbookTitle,
          'content': handbookContent,
        });

        // Call function to update notification when content is updated
        await updateHandbookContent(handbookId, handbookContent, userId!);

        print('Notification added for user: ${currentUser?.email} - Handbook ID: $handbookId');
      }
    });

    // Fetch all handbooks that are not yet stored for the user
    final handbooksSnapshot = await handbooksRef.get();

    if (handbooksSnapshot.docs.isNotEmpty) {
      // Loop through each handbook and store it in the user's collection if not already present
      for (final handbookDoc in handbooksSnapshot.docs) {
        final handbookId = handbookDoc.id;
        if (!userHandbookIds.contains(handbookId)) {
          final title = handbookDoc.data()['title'];
          final content = handbookDoc.data()['content'];

          // Store the handbook in the user's collection with the ID as the document name
          await userHandbookCollectionRef.doc(handbookId).set({
            'title': title,
            'content': content,
          });

          // Do something with the new handbook, like showing a notification or updating UI
          print('New handbook stored for user: ${currentUser?.email} - ID: $handbookId');
        }
      }
    } else {
      print('No handbooks found in the database.');
    }
  } else {
    print('No user is currently logged in.');
  }
}

Future<void> updateHandbookContent(String handbookId, String newContent, String userId) async {
  final handbookRef = _firestore.collection('handbooks').doc(handbookId);

  // Update the content of the handbook
  await handbookRef.update({
    'content': newContent,
  });

  // Call the notification function only when content is updated
  final handbookDoc = await handbookRef.get();
  if (handbookDoc.exists) {
    final handbookTitle = handbookDoc.data()?['title'];
    final handbookContent = handbookDoc.data()?['content'];
    await checkAndUpdateNotification(handbookId, handbookTitle, handbookContent, userId, _firestore);
  }
}

Future<void> checkAndUpdateNotification(String handbookId, String handbookTitle, String handbookContent, String userId, FirebaseFirestore firestore) async {
  // Reference to the 'handbooks' collection
  final handbooksRef = firestore.collection('handbooks');

  // Get the previous content of the handbook
  final prevContentQuery = await handbooksRef.doc(handbookId)
      .collection('previous_content')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  String prevContent = '';
  if (prevContentQuery.docs.isNotEmpty) {
    prevContent = prevContentQuery.docs.first.data()['content'];
  }

  // Check if content has been updated
  if (prevContent != handbookContent) {
    final notificationName = '$handbookTitle updated';
    final notificationTitle = 'The $handbookTitle has been updated!';

    final uniqueNotificationId = Uuid().v4(); // Generate a unique ID for the notification

    // Add the notification directly under the 'Notifications' map within the user's document
    final notificationRef = firestore.collection('users').doc(userId);
    await notificationRef.update({
      'Notifications.$uniqueNotificationId': { // Use the unique ID as the key
        'notifName': notificationName,
        'notifTitle': notificationTitle,
      },
    });

    print('Notification added for user: $userId - Handbook ID: $handbookId');
    sendUpdateNotification(uniqueNotificationId, '$handbookTitle updated!', 'The $handbookTitle has been updated!');

    // Update the previous content in the database
    await handbooksRef.doc(handbookId).collection('previous_content').add({
      'content': handbookContent,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> sendUpdateNotification(String uniqueId, String title, String message) async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId.hashCode, // Use the unique ID as the notification ID
          channelKey: 'basic_channel', // Channel key defined in initialization
          title: title,
          body: message,
        ),
      );
    } else {
      // Handle the case when notification permission is not granted
      // You may choose to show a message or log a warning
      print("Notification permission is not granted. Notification not sent.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<UserTypeProvider>(context, listen: false).userType;

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
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(children: [
          Positioned.fill(
            child: Container(
              color: Colors.brown[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/handbook.png',
                        width: double.infinity,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  color: Colors.brown[600],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: handbookStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No handbooks available.'));
                    } else {
                      List<DocumentSnapshot> visibleHandbooks =
                          snapshot.data!.docs.where((document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        final bool isVisibleToStudents =
                            data['visibleToStudents'];
                        final bool isVisibleToEmployees =
                            data['visibleToEmployees'];
                        final bool isArchived = data['archived'];

                        return ((userType == 'Student' &&
                                isVisibleToStudents &&
                                !isArchived) ||
                            (userType == 'Faculty' &&
                                isVisibleToEmployees &&
                                !isArchived) ||
                            userType == 'Admin');
                      }).toList();

                      if (visibleHandbooks.isEmpty) {
                        return Center(child: Text('No visible handbooks.'));
                      } else {
                        List<Widget> handbookWidgets =
                            visibleHandbooks.map((document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                          final bool isVisibleToStudents =
                              data['visibleToStudents'];
                          final bool isVisibleToEmployees =
                              data['visibleToEmployees'];
                          final bool isArchived = data['archived'];

                          if ((userType == 'Student' &&
                                  isVisibleToStudents &&
                                  !isArchived) ||
                              (userType == 'Faculty' &&
                                  isVisibleToEmployees &&
                                  !isArchived) ||
                              userType == 'Admin') {
                            return GestureDetector(
                              onTap: () async {
                                String documentURL = data['content'];
                                String fileName =
                                    'handbook_${DateTime.now().millisecondsSinceEpoch}.pdf';
                                String localPath =
                                    ''; // Path where the PDF will be saved locally

                                Completer<void> completer = Completer<void>();

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return WillPopScope(
                                      onWillPop: () async =>
                                          false, // Disable back button
                                      child: AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 20),
                                            Text('Opening handbook...'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // Check if the file exists locally
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  localPath = '${directory.path}/$fileName';

                                  bool fileExists =
                                      await File(localPath).exists();

                                  if (!fileExists) {
                                    // File doesn't exist locally, download it
                                    HttpClient client = HttpClient();
                                    var request = await client
                                        .getUrl(Uri.parse(documentURL));
                                    var response = await request.close();
                                    var bytes =
                                        await consolidateHttpClientResponseBytes(
                                            response);
                                    File file = File(localPath);
                                    await file.writeAsBytes(bytes);
                                  }

                                  // Open the document using PdftronFlutter with the local file path
                                  await PdftronFlutter.openDocument(localPath);
                                  completer
                                      .complete(); // Complete the completer when the document is loaded
                                } catch (e) {
                                  print('Error handling document: $e');
                                  // Handle errors (e.g., show a message to the user)
                                  completer
                                      .complete(); // Complete the completer in case of an error
                                }

                                await completer
                                    .future; // Wait for the completer to complete before closing the dialog
                                Navigator.of(context)
                                    .pop(); // Close the dialog after the completer completes
                              },
                              child: Container(
                                width: 180,
                                height: 250,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/handbook_cover.png',
                                      width: 180,
                                      height: 250,
                                      fit: BoxFit.contain,
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              for (var word
                                                  in data['title'].split(' '))
                                                TextSpan(
                                                  text: '$word\n',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink(); // Invisible widget
                          }
                        }).toList();

                        if (handbookWidgets.length == 1) {
                          // Single handbook, positioned in the middle
                          return Center(
                            child: handbookWidgets[0],
                          );
                        } else if (handbookWidgets.length == 2) {
                          // Two handbooks, side by side
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: handbookWidgets,
                          );
                        } else {
                          // More than two handbooks, adjust layout accordingly
                          List<Widget> topRow = handbookWidgets.sublist(0, 2);
                          Widget middleWidget = handbookWidgets.length % 2 == 0
                              ? SizedBox.shrink()
                              : handbookWidgets[handbookWidgets.length ~/ 2];
                          List<Widget> bottomRow = handbookWidgets.sublist(2);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: topRow,
                              ),
                              SizedBox(
                                  height:
                                      20), // Adjust the spacing between rows
                              middleWidget,
                              SizedBox(
                                  height:
                                      20), // Adjust the spacing between rows
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: bottomRow,
                              ),
                            ],
                          );
                        }
                      }
                    }
                  },
                ),
                Container(
                  height: 20,
                  color: Colors.brown[600],
                ),
              ],
            ),
          ),
        ]));
  }
}
