import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/models/user_model.dart';
import 'package:lpu_app/views/login.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/account_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/views/payment_procedures.dart'; // Update the path accordingly

final getCurrentUser = FirebaseAuth.instance.currentUser!;
final userID = getCurrentUser.uid;
DatabaseReference? userReference;
Future? userDetails;

Future getUserDetails() async {
  DataSnapshot snapshot = await userReference!.get();

  return UserModel.fromMap(Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userReference = FirebaseDatabase.instance.ref().child('Accounts').child(user.uid);
    }

    userDetails = getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: userDetails,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(snapshot.data.userFirstName + ' ' + snapshot.data.userLastName),
                    accountEmail: Text(snapshot.data.userEmail),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/user.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: AppConfig.appSecondaryTheme,
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(AppConfig.appSecondaryTheme.withOpacity(0.3), BlendMode.dstATop),
                        image: const AssetImage('assets/images/campus_img_2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: const Text('Payment Procedure'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentProcedures()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline_outlined),
                    title: const Text('Contact Info'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactInfo()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Account Settings'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettings()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_outlined),
                    title: const Text('Help'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app_outlined),
                    title: const Text('Log out'),
                    onTap: () async {
                      // Reset the 'dialogShown' flag to false during logout
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool('dialogShown', false);

                      // Perform the logout process
                      await FirebaseAuth.instance.signOut();

                      // Navigate to the Login screen after successful logout
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                            (route) => false, // Remove all existing routes from the stack
                      );
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // Provide alternative UI for errors
              return Text('Error loading user data');
            } else {
              // Provide alternative UI when there's no data available
              return Text('No user data available');
            }
          } else {
            // Provide an empty UI while waiting for data
            return Container();
          }
        },
      ),
    );
  }
}
