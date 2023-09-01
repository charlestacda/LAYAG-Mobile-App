import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';

final getCurrentUser = FirebaseAuth.instance.currentUser!;
final currentUserID = getCurrentUser.uid;

DatabaseReference studentReference = FirebaseDatabase.instance.ref().child('Accounts');
TextEditingController studentNumber = TextEditingController();
TextEditingController studentEmail = TextEditingController();
TextEditingController studentPassword = TextEditingController();
TextEditingController studentFirstName = TextEditingController();
TextEditingController studentLastName = TextEditingController();
TextEditingController studentCollege = TextEditingController();

// void main() => runApp(const AccountSettings());

class AccountSettings extends StatelessWidget {
  const AccountSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
            ),
            color: AppConfig.appSecondaryTheme,
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: const _AccountSettings(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AccountSettings extends StatefulWidget {
  const _AccountSettings({Key? key}) : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<_AccountSettings> {
  TextEditingController studentCollege = TextEditingController();

  String? college;
  File? profileImagePath;
  File? profileImageFilename;

  pickImage(ImageSource gallery) async {
    try {
      final profileImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (profileImage == null) {
        return;
      }

      setState(() {
        profileImagePath = File(profileImage.path);
        profileImageFilename = File(profileImage.name);
      });
    } on PlatformException catch (exception) {
      Fluttertoast.showToast(
        msg: 'Something went wrong... ${exception.details}',
        fontSize: 16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 15, right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(fontFamily: 'Futura', color: Color(0xFFD94141), fontSize: 28, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Stack(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.transparent, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(120),
                            )),
                        onPressed: () => pickImage(ImageSource.gallery),
                        child: profileImagePath != null
                            ? Image.file(
                                profileImagePath!,
                                height: 200,
                              )
                            : Column(
                                children: const [
                                  ImageIcon(
                                    AssetImage('assets/images/user.png'),
                                    size: 200,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: AppConfig.appSecondaryTheme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'First Name'),
              onChanged: (value) => studentFirstName.text = value,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Last Name'),
              onChanged: (value) => studentLastName.text = value,
            ),
            const SizedBox(
              height: 20,
            ),
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
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                if (studentFirstName.text.isEmpty || studentLastName.text.isEmpty || studentCollege.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Fill all the fields.',
                    fontSize: 16,
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('SAVE CHANGES', style: TextStyle(fontFamily: 'Futura', color: AppConfig.appSecondaryTheme, fontSize: 16, fontWeight: FontWeight.w600)),
                        content: Text('Are you sure want to save the changes?', style: TextStyle(fontFamily: 'Futura', color: Colors.grey[900], fontSize: 15, fontWeight: FontWeight.w400)),
                        actions: [
                          TextButton(
                            child: const Text('Yes', style: TextStyle(fontFamily: 'Futura', color: AppConfig.appSecondaryTheme, fontSize: 14, fontWeight: FontWeight.w400)),
                            onPressed: () async {
                              studentReference.child(currentUserID).update({
                                'userFirstName': studentFirstName.text,
                                'userLastName': studentLastName.text,
                                'userCollege': studentCollege.text,
                              }).asStream;

                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Cancel', style: TextStyle(fontFamily: 'Futura', color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w400)),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
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
                  'SAVE CHANGES',
                  style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
