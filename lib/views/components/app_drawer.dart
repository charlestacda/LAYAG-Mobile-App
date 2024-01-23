import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/models/user_model.dart';
import 'package:lpu_app/views/handbook_menu.dart';
import 'package:lpu_app/views/login.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/account_settings.dart';
import 'package:lpu_app/views/handbook.dart';
import 'package:lpu_app/views/todo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/views/payment_procedures.dart';
import 'package:lpu_app/utilities/webviewer.dart';




class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  late Stream<UserModel?> userDetailsStream;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userDetailsStream = getUserDetails(user.uid);
      _subscription = userDetailsStream.listen((data) {
        if (mounted) {
          setState(() {
            // Update the state with the new data if needed
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  Stream<UserModel?> getUserDetails(String userId) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  return firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!);
    } else {
      return null;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<UserModel?>(
        stream: userDetailsStream,
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            UserModel user = snapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user.userFirstName + ' ' + user.userLastName),
                  accountEmail: Text(user.userEmail),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: user.userProfile != null && user.userProfile.isNotEmpty
                          ? Image.network(
                              user.userProfile,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle error loading the network image
                                return Image.asset(
                                  'assets/images/user.png',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/user.png',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                    ),backgroundColor: AppConfig.appSecondaryTheme,
                  ),
                  decoration: BoxDecoration(
                    color: AppConfig.appSecondaryTheme,
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                        AppConfig.appSecondaryTheme.withOpacity(0.3),
                        BlendMode.dstATop,
                      ),
                      image: const AssetImage('assets/images/campus_img_2.png'),
                      fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: const Text('Payment Procedure'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentProcedures()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline_outlined),
                    title: const Text('Contact Info'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactInfo()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountSettings()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_outlined),
                    title: const Text('Help'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Help()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app_outlined),
                    title: const Text('Log out'),
                    onTap: () async {
                      // Reset the 'dialogShown' flag to false during logout
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('dialogShown', false);

                      InAppWebViewController.clearAllCache();

                      // Perform the logout process
                      await FirebaseAuth.instance.signOut();

                      // Navigate to the Login screen after successful logout
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) =>
                            false, // Remove all existing routes from the stack
                      );
                    },
                  ),
                ],
              );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}