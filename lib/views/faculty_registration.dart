import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/views/registration_menu.dart';
import 'package:lpu_app/views/privacy_policy.dart';
import 'package:lpu_app/views/login.dart';

class FacultyRegistration extends StatefulWidget {
  const FacultyRegistration({Key? key}) : super(key: key);

  @override
  FacultyRegistrationState createState() => FacultyRegistrationState();
}

class FacultyRegistrationState extends State<FacultyRegistration> {
  FirebaseFirestore referenceData = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  CollectionReference<Map<String, dynamic>> facultyReference =
      FirebaseFirestore.instance.collection('users');
  TextEditingController facultyNumber = TextEditingController();
  TextEditingController facultyEmail = TextEditingController();
  TextEditingController facultyPassword = TextEditingController();
  TextEditingController facultyConfirmPassword = TextEditingController();
  TextEditingController facultyFirstName = TextEditingController();
  TextEditingController facultyLastName = TextEditingController();
  TextEditingController facultyCollege = TextEditingController();

  RegExp pattern =
      RegExp('(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#%^&+=])(?=\\S+).{8,}');

  bool isPasswordEightCharacters = false;
  bool hasOneNumeric = false;
  bool hasOneSpecialCharacter = false;
  bool hasOneUpperCase = false;
  bool passwordsMatch = false;
  bool hasOneLowerCase = false;

  bool toggle = false;

  String? college;

  bool isRegistering = false;
  bool isPrivacyPolicyChecked = false;

  List<bool> fieldEmpty = List.filled(7, true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: AppConfig.appSecondaryTheme,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationMenu()));
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
                    alignment: Alignment
                        .center, // Align the content of the container to the center
                    child: Text(
                      'REGISTER AS EMPLOYEE',
                      textAlign:
                          TextAlign.center, // Center the text horizontally
                      style: TextStyle(
                        fontFamily: 'Futura',
                        color: Color(0xffD94141),
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[0]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'Employee ID Number',
                      suffixIcon: fieldEmpty[0]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        fieldEmpty[0] = value.isEmpty;
                        facultyNumber.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[1]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'Email Address',
                      suffixIcon: fieldEmpty[1]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        fieldEmpty[1] = value.isEmpty;
                        facultyEmail.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[2]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'Password',
                      suffixIcon: fieldEmpty[2]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (String password) {
                      final numericRegex = RegExp(r'(?=.*[0-9])');
                      final lowerCase = RegExp(r'(?=.*[a-z])');
                      final upperCase = RegExp(r'(?=.*[A-Z])');
                      final specialCase = RegExp(r'(?=.*[!@#$%^&*+=])');
                      facultyPassword.text = password;

                      setState(() {
                        fieldEmpty[2] = password.isEmpty;
                        isPasswordEightCharacters = false;

                        if (password.length >= 8) {
                          isPasswordEightCharacters = true;
                        }

                        hasOneNumeric = false;

                        if (numericRegex.hasMatch(password)) {
                          hasOneNumeric = true;
                        }

                        hasOneLowerCase = false;

                        if (lowerCase.hasMatch(password)) {
                          hasOneLowerCase = true;
                        }

                        hasOneUpperCase = false;

                        if (upperCase.hasMatch(password)) {
                          hasOneUpperCase = true;
                        }

                        hasOneSpecialCharacter = false;

                        if (specialCase.hasMatch(password)) {
                          hasOneSpecialCharacter = true;
                        }

                        if (facultyPassword.text.isNotEmpty ||
                            facultyConfirmPassword.text.isNotEmpty) {
                          passwordsMatch = facultyPassword.text ==
                              facultyConfirmPassword.text;
                        } else {
                          passwordsMatch = false;
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
                        decoration: BoxDecoration(
                            color: isPasswordEightCharacters
                                ? AppConfig.appSecondaryTheme
                                : Colors.transparent,
                            border: isPasswordEightCharacters
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)),
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
                        decoration: BoxDecoration(
                            color: hasOneNumeric
                                ? AppConfig.appSecondaryTheme
                                : Colors.transparent,
                            border: hasOneNumeric
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)),
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
                        decoration: BoxDecoration(
                            color: hasOneLowerCase
                                ? AppConfig.appSecondaryTheme
                                : Colors.transparent,
                            border: hasOneLowerCase
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)),
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
                      const Text('Contains at least 1 lowercase')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                            color: hasOneUpperCase
                                ? AppConfig.appSecondaryTheme
                                : Colors.transparent,
                            border: hasOneUpperCase
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)),
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
                        decoration: BoxDecoration(
                            color: hasOneSpecialCharacter
                                ? AppConfig.appSecondaryTheme
                                : Colors.transparent,
                            border: hasOneSpecialCharacter
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)),
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
                      const Text('Contains  at least 1 special')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: passwordsMatch
                              ? AppConfig.appSecondaryTheme
                              : Colors.transparent,
                          border: passwordsMatch
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: passwordsMatch
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Password and Confirm Password match')
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[3]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'Confirm Password',
                      suffixIcon: fieldEmpty[3]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        fieldEmpty[3] = value.isEmpty;
                        facultyConfirmPassword.text = value;

                        // Check if both passwords match whenever confirm password field changes
                        if (facultyPassword.text.isNotEmpty ||
                            facultyConfirmPassword.text.isNotEmpty) {
                          passwordsMatch = facultyPassword.text ==
                              facultyConfirmPassword.text;
                        } else {
                          passwordsMatch = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[4]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'First Name',
                      suffixIcon: fieldEmpty[4]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        fieldEmpty[4] = value.isEmpty;
                        facultyFirstName.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: fieldEmpty[5]
                              ? Colors.red
                              : Colors
                                  .grey, // Change border color based on condition
                          width: 1.0,
                        ),
                      ),
                      hintText: 'Last Name',
                      suffixIcon: fieldEmpty[5]
                          ? Icon(Icons.error_outline, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        fieldEmpty[5] = value.isEmpty;
                        facultyLastName.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: fieldEmpty[6]
                            ? Colors.red
                            : Colors
                                .grey, // Change border color based on condition
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Text('College'),
                        value: college,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 30,
                        items: ListConfig.colleges.map((String item) {
                          return DropdownMenuItem(
                              value: item, child: Text(item));
                        }).toList(),
                        onChanged: (String? newCollege) {
                          setState(() {
                            college = newCollege;
                            facultyCollege.text = college ??
                                ''; // Set the text field based on selection
                            // Validate if an item has been selected or not
                            fieldEmpty[6] = college ==
                                null; // Update fieldEmpty based on selection
                          });
                        },
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16), // Set text color and size
                        dropdownColor:
                            Colors.white, // Set dropdown background color
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    IconButton(
                      icon: toggle
                          ? const Icon(Icons.check_box)
                          : const Icon(Icons.check_box_outline_blank),
                      color: AppConfig.appSecondaryTheme,
                      onPressed: () {
                        setState(() {
                          toggle = !toggle;
                          isPrivacyPolicyChecked = toggle;
                        });
                      },
                    ),
                    const Text(
                      'I agree with the',
                      style: TextStyle(fontSize: 17),
                    ),
                    TextButton(
                      child: const Text('Privacy Policy.',
                          style: TextStyle(fontSize: 17)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PrivacyPolicy()));
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isRegistering) {
                        if (facultyNumber.text.isEmpty ||
                            facultyEmail.text.isEmpty ||
                            facultyPassword.text.isEmpty ||
                            facultyConfirmPassword.text.isEmpty ||
                            facultyFirstName.text.isEmpty ||
                            facultyLastName.text.isEmpty ||
                            facultyCollege.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Fill all the fields.',
                            fontSize: 16,
                          );
                        } else if (!RegExp(r'\S+@lpu.edu.ph')
                            .hasMatch(facultyEmail.text)) {
                          Fluttertoast.showToast(
                            msg: 'Invalid Email Address.',
                            fontSize: 16,
                          );
                        } else if (facultyPassword.text !=
                            facultyConfirmPassword.text) {
                          Fluttertoast.showToast(
                            msg: 'Password didn\'t match.',
                            fontSize: 16,
                          );
                        } else if (pattern.hasMatch(facultyPassword.text) ==
                            false) {
                          Fluttertoast.showToast(
                            msg: 'Password is weak',
                            fontSize: 16,
                          );
                        } else if (!isPrivacyPolicyChecked) {
                          // Check if Privacy Policy is checked
                          Fluttertoast.showToast(
                            msg: 'Please agree to the Privacy Policy',
                            fontSize: 16,
                          );
                        } else {
                          setState(() {
                            isRegistering = true;
                          });

                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: facultyEmail.text,
                                    password: facultyPassword.text);

                            final user = FirebaseAuth.instance.currentUser;
                            final userID = user?.uid;

                            await facultyReference.doc(userID).set({
                              'userCollege': facultyCollege.text,
                              'userEmail': facultyEmail.text,
                              'userFirstName': facultyFirstName.text,
                              'userLastName': facultyLastName.text,
                              'userNo': facultyNumber.text,
                              'userPassword': facultyPassword.text,
                              'userProfile': 'default.jpg',
                              'userType': 'Faculty',
                            });

                            setState(() {
                              isRegistering = true;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                isRegistering = false;
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
                                    style: TextStyle(
                                        fontFamily: 'Futura',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  actions: [
                                    SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Login()));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                foregroundColor:
                                                    AppConfig.appSecondaryTheme,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'GO BACK TO LOG IN',
                                                  style: TextStyle(
                                                      fontFamily: 'Futura',
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                width: double.infinity,
                                              ),
                                            )
                                          ],
                                        )),
                                  ],
                                );
                              },
                            ).then((_) {
                              // Optionally, you can put this outside the showDialog to reset the form.
                              _formKey.currentState?.reset();
                            });
                          } on FirebaseAuthException catch (exception) {
                            if (exception.code == 'email-already-in-use') {
                              setState(() {
                                isRegistering = false;
                              });

                              Fluttertoast.showToast(
                                  msg: 'Email is already registered');
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
                      padding: EdgeInsets.all(16),
                      // Set a fixed width to ensure consistent button width
                      minimumSize: Size(double.infinity, 50),
                      // Your existing button style...
                    ),
                    child: isRegistering
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontFamily: 'Futura',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            width: double.infinity,
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
                                builder: (context) => const Login()));
                      },
                      child: const Text(
                        'LOG IN INSTEAD',
                        style: TextStyle(
                            fontFamily: 'Futura',
                            color: AppConfig.appSecondaryTheme,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
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
