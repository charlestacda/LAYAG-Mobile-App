import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/landing.dart';
import 'package:lpu_app/views/forgot_password.dart';
import 'package:lpu_app/views/registration_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPass = TextEditingController();

  bool isLoggingIn = false;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    userEmail.dispose();
    userPass.dispose();
    super.dispose();
  }

  void resetDialogShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('dialogShown', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 48),
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/images/Layag_Logo1.svg',
                              width: 200, // Adjust the width as needed
                              height: 200, // Adjust the height as needed
                            ),
                            SizedBox(
                                height:
                                    16), // Adjust the height to create the desired space
                            const Text(
                              'LYCEUM OF THE PHILIPPINES UNIVERSITY',
                              style: TextStyle(
                                fontFamily: 'ZapfHumanist',
                                color: Color(0xFFA33334),
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'CAVITE CAMPUS',
                              style: TextStyle(
                                fontFamily: 'ZapfHumanist',
                                color: Color(0xFFA33334),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 56),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: 56,
                            child: TextField(
                              controller: userEmail,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                  fontFamily: 'Arial', color: Colors.black),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFA33334), // Border color
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 16, right: 16),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xffA62D38),
                                ),
                                isCollapsed: true,
                                hintText: 'Student/Faculty Email',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: 56,
                            child: TextField(
                              obscureText: true,
                              controller: userPass,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                  fontFamily: 'Arial', color: Colors.black),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFA33334), // Border color
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 16, right: 16),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xffA62D38),
                                ),
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey),
                                isCollapsed: true,
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()));
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Color(0xFFA33334),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            resetDialogShown();
                            if (!isLoggingIn) {
                              try {
                                if (userEmail.text.isEmpty ||
                                    userPass.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: 'Enter your login credentials');
                                  return;
                                }

                                setState(() {
                                  isLoggingIn = true;
                                });

                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: userEmail.text.trim(),
                                  password: userPass.text.trim(),
                                );

                                final user = FirebaseAuth.instance.currentUser;
                                final userID = user?.uid;

                                if (userID != null) {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userID)
                                      .get()
                                      .then((snapshot) {
                                    if (snapshot.exists) {
                                      final userMap = snapshot.data()
                                          as Map<String, dynamic>;
                                      final userType =
                                          userMap['userType'] as String?;

                                      if (userType == 'Student' ||
                                          userType == 'Faculty' ||
                                          userType == 'Admin') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Landing()));
                                      } else {
                                        setState(() {
                                          isLoggingIn = false;
                                        });

                                        Fluttertoast.showToast(
                                            msg: 'This user is not authorized');
                                      }
                                    } else {
                                      setState(() {
                                        isLoggingIn = false;
                                      });

                                      Fluttertoast.showToast(
                                          msg: 'User data not found');
                                    }
                                  }).catchError((error) {
                                    setState(() {
                                      isLoggingIn = false;
                                    });

                                    Fluttertoast.showToast(
                                        msg:
                                            'Error fetching user data: $error');
                                  });
                                } else {
                                  setState(() {
                                    isLoggingIn = false;
                                  });

                                  Fluttertoast.showToast(
                                      msg: 'User ID not available');
                                }
                              } on FirebaseAuthException catch (exception) {
                                if (exception.code == 'user-not-found') {
                                  setState(() {
                                    isLoggingIn = false;
                                  });

                                  Fluttertoast.showToast(
                                      msg: 'User cannot be found');
                                } else if (exception.code == 'wrong-password') {
                                  setState(() {
                                    isLoggingIn = false;
                                  });

                                  Fluttertoast.showToast(msg: 'Wrong Password');
                                } else {
                                  setState(() {
                                    isLoggingIn = false;
                                  });

                                  Fluttertoast.showToast(
                                      msg:
                                          'Login failed: ${exception.message}');
                                }
                              } catch (error) {
                                setState(() {
                                  isLoggingIn = false;
                                });

                                Fluttertoast.showToast(
                                    msg: 'Error during login: $error');
                              }
                            }
                          },
                          child: isLoggingIn
                              ? const CircularProgressIndicator(
                                  color: AppConfig.appWhiteAlphaTheme,
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      fontFamily: 'Futura',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Color(0xFFA33334),
                            foregroundColor: const Color(0xffD0D0D0),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: const BorderSide(
                              width: 2,
                              color: Color(0xFFA33334),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationMenu()));
                          },
                          child: const Text(
                            'REGISTER',
                            style: TextStyle(
                                fontFamily: 'Futura',
                                color: Color(0xFFA33334),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            foregroundColor: AppConfig.appSecondaryTheme,
                            side: const BorderSide(
                              width: 2,
                              color: Color(0xFFA33334),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    ));
  }
}
