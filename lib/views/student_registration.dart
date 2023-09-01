import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/views/privacy_policy.dart';
import 'package:lpu_app/views/registration_menu.dart';
import 'package:lpu_app/views/login.dart';

class StudentRegistration extends StatefulWidget {
  const StudentRegistration({Key? key}) : super(key: key);

  @override
  StudentRegistrationState createState() => StudentRegistrationState();
}

class StudentRegistrationState extends State<StudentRegistration> {
  FirebaseDatabase referenceData = FirebaseDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  DatabaseReference studentReference = FirebaseDatabase.instance.ref().child('Accounts');
  TextEditingController studentNumber = TextEditingController();
  TextEditingController studentEmail = TextEditingController();
  TextEditingController studentPassword = TextEditingController();
  TextEditingController studentConfirmPassword = TextEditingController();
  TextEditingController studentFName = TextEditingController();
  TextEditingController studentLName = TextEditingController();
  TextEditingController studentCollege = TextEditingController();

  RegExp pattern = RegExp('(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#%^&+=])(?=\\S+).{8,}');

  bool isPasswordEightCharacters = false;
  bool hasOneNumeric = false;
  bool hasOneSpecialCharacter = false;
  bool hasOneUpperCase = false;

  bool toggle = false;

  String? college;

  bool isRegistering = false;

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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationMenu()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'REGISTER AS STUDENT',
                      style: TextStyle(fontFamily: 'Futura', color: Color(0xffD94141), fontSize: 28, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Student ID Number'),
                    onChanged: (value) => studentNumber.text = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Email Address'),
                    onChanged: (value) => studentEmail.text = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Password'),
                    onChanged: (String password) {
                      final numericRegex = RegExp(r'(?=.*[0-9])');
                      final upperCase = RegExp(r'(?=.*[A-Z])');
                      final specialCase = RegExp(r'(?=.*[!@#$%^&*+=])');
                      studentPassword.text = password;

                      setState(() {
                        isPasswordEightCharacters = false;

                        if (password.length >= 8) {
                          isPasswordEightCharacters = true;
                        }

                        hasOneNumeric = false;

                        if (numericRegex.hasMatch(password)) {
                          hasOneNumeric = true;
                        }

                        hasOneUpperCase = false;

                        if (upperCase.hasMatch(password)) {
                          hasOneUpperCase = true;
                        }

                        hasOneSpecialCharacter = false;

                        if (specialCase.hasMatch(password)) {
                          hasOneSpecialCharacter = true;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: isPasswordEightCharacters ? AppConfig.appSecondaryTheme : Colors.transparent, border: isPasswordEightCharacters ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(50)),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Contains at least 8 characters')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: hasOneNumeric ? AppConfig.appSecondaryTheme : Colors.transparent, border: hasOneNumeric ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(50)),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Contains at least 1 number')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: hasOneUpperCase ? AppConfig.appSecondaryTheme : Colors.transparent, border: hasOneUpperCase ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(50)),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Contains at least 1 uppercase')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: hasOneSpecialCharacter ? AppConfig.appSecondaryTheme : Colors.transparent, border: hasOneSpecialCharacter ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(50)),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Contains at least 1 special character')
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Confirm Password'),
                    onChanged: (value) => studentConfirmPassword.text = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'First Name'),
                    onChanged: (value) => studentFName.text = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Last Name'),
                    onChanged: (value) => studentLName.text = value,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          hint: const Text('College'),
                          value: college,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 30,
                          items: ListConfig.colleges.map((String item) {
                            return DropdownMenuItem(value: item, child: Text(item));
                          }).toList(),
                          onChanged: (String? newCollege) {
                            setState(() {
                              college = newCollege!;
                              studentCollege.text = college!;
                            });
                          }),
                    ),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    IconButton(
                      icon: toggle ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                      color: AppConfig.appSecondaryTheme,
                      onPressed: () {
                        setState(() {
                          toggle = !toggle;
                        });
                      },
                    ),
                    const Text(
                      'I agree with the',
                      style: TextStyle(fontSize: 17),
                    ),
                    TextButton(
                      child: const Text('Privacy Policy.', style: TextStyle(fontSize: 17)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicy()));
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isRegistering) {
                        if (studentNumber.text.isEmpty || studentEmail.text.isEmpty || studentPassword.text.isEmpty || studentConfirmPassword.text.isEmpty || studentFName.text.isEmpty || studentLName.text.isEmpty || studentCollege.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Fill all the fields.',
                            fontSize: 16,
                          );
                        } else if (!RegExp(r'\S+@lpunetwork.edu.ph').hasMatch(studentEmail.text)) {
                          Fluttertoast.showToast(
                            msg: 'Invalid Email Address.',
                            fontSize: 16,
                          );
                        } else if (studentPassword.text != studentConfirmPassword.text) {
                          Fluttertoast.showToast(
                            msg: 'Password didn\'t match.',
                            fontSize: 16,
                          );
                        } else if (pattern.hasMatch(studentPassword.text) == false) {
                          Fluttertoast.showToast(
                            msg: 'Password is weak',
                            fontSize: 16,
                          );
                        } else {
                          setState(() {
                            isRegistering = true;
                          });

                          try {
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: studentEmail.text, password: studentPassword.text);

                            final user = FirebaseAuth.instance.currentUser;
                            final userID = user?.uid;

                            await studentReference.child(userID!).set({
                              'userCollege': studentCollege.text,
                              'userEmail': studentEmail.text,
                              'userFirstName': studentFName.text,
                              'userLastName': studentLName.text,
                              'userNo': studentNumber.text,
                              'userPassword': studentPassword.text,
                              'userProfile': 'default.jpg',
                              'userType': 'Student',
                            });

                            setState(() {
                              isRegistering = false;
                            });

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/register_complete.png',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.contain,
                                      )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  content: const Text(
                                    'Registration Complete! You may now log in your account',
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
                            if (exception.code == 'email-already-in-use') {
                              setState(() {
                                isRegistering = false;
                              });

                              Fluttertoast.showToast(msg: 'Email is already registered');
                            } else if (exception.code == 'weak-password') {
                              setState(() {
                                isRegistering = false;
                              });

                              Fluttertoast.showToast(msg: 'Weak password');
                            }
                          }
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
                        'REGISTER',
                        style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                      },
                      child: const Text(
                        'LOG IN INSTEAD',
                        style: TextStyle(fontFamily: 'Futura', color: AppConfig.appSecondaryTheme, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(
                          width: 2,
                          color: AppConfig.appSecondaryTheme,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
