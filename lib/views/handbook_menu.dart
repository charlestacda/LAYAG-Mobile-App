import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lpu_app/main.dart';
import 'package:lpu_app/views/handbook.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
  final userType = Provider.of<UserTypeProvider>(context, listen: false).userType;

  return Scaffold(
    drawer: const AppDrawer(), // Retaining the drawer
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
              context,
              MaterialPageRoute(builder: (context) => const Help()),
            );
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 64), // Adjust the values as needed
        child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/handbook.png',
            width: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 64), // Adjust the values as needed
        child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/handbookmenu.png',
            width: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
            StreamBuilder<QuerySnapshot>(
              stream: handbookStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No handbooks available.'));
                } else {
                  return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 80),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                          final bool isVisibleToStudents = data['visibleToStudents'];
                          final bool isVisibleToEmployees = data['visibleToEmployees'];
                          final bool isArchived = data['archived'];

                          // Check visibility based on userType
                          if ((userType == 'Student' && isVisibleToStudents && !isArchived) ||
                              (userType == 'Faculty' && isVisibleToEmployees && !isArchived) ||
                              userType == 'Admin') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Handbook(
                                              id: document.id,
                                              title: data['title'],
                                              content: data['content'],
                                              dateAdded: data['dateAdded'].toDate(),
                                              dateEdited: data['dateEdited'].toDate(),
                                              visibleToEmployees: data['visibleToEmployees'],
                                              visibleToStudents: data['visibleToStudents'],
                                              archived: data['archived'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(data['title']),
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xFFA62D38),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18, 
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox.shrink(); // Invisible widget
                          }
                        }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
