import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/views/login.dart';
import 'package:lpu_app/views/account_verification.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  LandingState createState() => LandingState();
}

class LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the authentication state, display a loader or splash screen
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            // If user data is available, navigate to the AccountVerification screen
            return const AccountVerification();
          } else {
            // If no user data is available, navigate to the Login screen
            return const Login();
          } },
      ),
    );
  }
}