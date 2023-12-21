import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/login.dart';

TextEditingController userEmail = TextEditingController();

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
          color: AppConfig.appSecondaryTheme,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'FORGOT PASSWORD',
                      style: TextStyle(fontFamily: 'Futura', color: Color(0xffD94141), fontSize: 28, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: userEmail,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: 'Arial'),
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Email Address', contentPadding: EdgeInsets.all(10)),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail.text);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/email_sent.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              content: const Text(
                                'Check your email for confirmation and instructions',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Futura', fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                              actions: [
                                SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(16),
                                            foregroundColor: AppConfig.appSecondaryTheme,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'GO BACK TO LOG IN',
                                              style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            width: double.infinity,
                                          ),
                                        )
                                      ],
                                    )),
                              ],
                            );
                          },
                        );
                      } on FirebaseAuthException catch (exception) {
                        if (exception.code == 'user-not-found') {
                          Fluttertoast.showToast(msg: 'Email not found');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: AppConfig.appSecondaryTheme,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      width: double.infinity,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
