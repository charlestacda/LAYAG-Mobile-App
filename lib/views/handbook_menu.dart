import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/main.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HandbookMenu extends StatefulWidget {
  const HandbookMenu({Key? key}) : super(key: key);

  @override
  _HandbookMenuState createState() => _HandbookMenuState();
}

class _HandbookMenuState extends State<HandbookMenu> {
  late Stream<QuerySnapshot> handbookStream;

  @override
  void initState() {
    super.initState();
    handbookStream =
        FirebaseFirestore.instance.collection('handbooks').snapshots();
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
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Help()));
              },
            ),
          ],
        ),
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
