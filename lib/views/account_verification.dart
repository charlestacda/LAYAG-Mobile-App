import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/views/components/Nav.dart';
import 'package:lpu_app/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountVerification extends StatefulWidget {
  const AccountVerification({Key? key}) : super(key: key);

  @override
  AccountVerificationState createState() => AccountVerificationState();
}

class AccountVerificationState extends State<AccountVerification> {
  bool isEmailVerified = false;
  Timer? timer;

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } catch (exception) {
      Fluttertoast.showToast(msg: 'Already sent an email. Please check your email spam.');
    }
  }

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      Timer.periodic(
        const Duration(minutes: 30),
        (_) async {
          await FirebaseAuth.instance.currentUser!.reload();

          setState(() {
            isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
          });

          if (isEmailVerified) timer?.cancel();
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const NewNavigation()
        : Scaffold(
            appBar: AppBar(
  title: const Text('Email Verification'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () async {
      // Perform the logout process
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('dialogShown', false);
      await FirebaseAuth.instance.signOut();

      // Navigate to the Login screen after successful logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false, // Remove all existing routes from the stack
      );
    },
  ),
),

            body: const Center(child: Text('Verification link sent on your email.')),
          );
  }
}
