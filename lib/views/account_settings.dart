import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';

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
        body: _AccountSettings(), // Directly use _AccountSettings widget here
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
  late String college = "";
  late UserModel currentUser;
  File? profileImagePath = null;
  String? profileImageURL;
  late String currentUserID;
  bool isChanged = false;
  final ImageCropper _imageCropper = ImageCropper();
  File? tempProfileImage;

  bool isUpdating = false;

  CollectionReference studentReference =
      FirebaseFirestore.instance.collection('users');
  TextEditingController studentNumber = TextEditingController();
  TextEditingController studentEmail = TextEditingController();
  TextEditingController studentPassword = TextEditingController();
  TextEditingController studentFirstName = TextEditingController();
  TextEditingController studentLastName = TextEditingController();
  TextEditingController studentCollege = TextEditingController();
  late StreamSubscription<DocumentSnapshot> _userSubscription;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    studentFirstName.addListener(onFieldChanged);
    studentLastName.addListener(onFieldChanged);
    studentCollege.addListener(onFieldChanged);

    // Subscribe to the user document snapshots
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .snapshots()
        .listen((DocumentSnapshot userSnapshot) {
      currentUser =
          UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

      setState(() {
        // Update the state here
        // ...
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of controllers to prevent memory leaks
    studentFirstName.dispose();
    studentLastName.dispose();
    studentCollege.dispose();
    _userSubscription.cancel();
  }

  void onFieldChanged() {
    setState(() {
      isChanged = studentFirstName.text != currentUser.userFirstName ||
          studentLastName.text != currentUser.userLastName ||
          college != currentUser.userCollege;
    });
  }

  void fetchUserData() async {
    User? getCurrentUser = FirebaseAuth.instance.currentUser;

    if (getCurrentUser != null) {
      currentUserID = getCurrentUser.uid;

      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(currentUserID);

        userDocRef.snapshots().listen((DocumentSnapshot userSnapshot) {
          currentUser =
              UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

          if (mounted) {
            setState(() {
              studentFirstName.text = currentUser.userFirstName ?? '';
              studentLastName.text = currentUser.userLastName ?? '';
              college = currentUser.userCollege ?? '';
              profileImageURL = currentUser.userProfile ?? '';

              isChanged =
                  (studentFirstName.text != currentUser.userFirstName) ||
                      (studentLastName.text != currentUser.userLastName) ||
                      (college != currentUser.userCollege);
            });
          }
        });
      } catch (e) {
        print("Error fetching user data: $e");
        // Handle errors as needed
      }
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String userID = FirebaseAuth.instance.currentUser?.uid ?? '';
      String fileName = userID; // Use the userID as the file name
      Reference storageReference =
          FirebaseStorage.instance.ref().child('users/userProfile/$fileName');

      String contentType = 'image/jpeg'; // Default content type

      // Determine the content type based on file extension
      if (imageFile.path.endsWith('.jpg')) {
        contentType = 'image/jpeg';
      } else if (imageFile.path.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (imageFile.path.endsWith('.png')) {
        contentType = 'image/png';
      }

      // Include SettableMetadata with the determined content type
      UploadTask uploadTask = storageReference.putFile(
        imageFile,
        SettableMetadata(contentType: contentType),
      );

      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      // Handle errors as needed
      return '';
    }
  }

  void updateUserProfile(String imageURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .update({
        'userFirstName': studentFirstName.text,
        'userLastName': studentLastName.text,
        'userCollege': studentCollege.text,
        'userProfile': imageURL,
      });

      // Update the displayed image URL after successfully updating the user profile
      setState(() {
        profileImageURL = imageURL;
      });
    } catch (e) {
      print("Error updating user profile: $e");
      // Handle errors as needed
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    File? croppedFile = await _imageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 300,
      maxHeight: 300,
      cropStyle: CropStyle.circle, // Set crop style to circle
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        hideBottomControls: true,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Crop Image',
      ),
    );

    return croppedFile; // Return the cropped file after the cropping process
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(pickedFile.path);
        if (croppedFile != null) {
          setState(() {
            tempProfileImage = croppedFile;
            isChanged = true;
          });
        }
      }
    } catch (e) {
      print("Error picking/cropping image: $e");
      // Handle errors as needed
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
              alignment: Alignment
                  .center, // Aligns the entire container content in the center
              child: const Text(
                'ACCOUNT SETTINGS',
                textAlign: TextAlign.center, // Center-align the text
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: Color(0xFFD94141),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(120),
                        onTap: () => _pickAndCropImage(ImageSource.gallery),
                        child: ClipOval(
                          child: tempProfileImage != null
                              ? Image.file(
                                  tempProfileImage!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : profileImageURL != null
                                  ? Image.network(
                                      profileImageURL!,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color:
                                                  AppConfig.appSecondaryTheme,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      AppConfig
                                                          .appSecondaryTheme),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const Icon(Icons.error);
                                      },
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
              controller: studentFirstName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppConfig
                          .appSecondaryTheme), // Set the border color when focused
                ),
                labelText: 'First Name', // Label text here
                floatingLabelStyle:
                    TextStyle(color: AppConfig.appSecondaryTheme),
                hintText: 'Enter your first name',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: studentLastName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppConfig
                          .appSecondaryTheme), // Set the border color when focused
                ),
                labelText: 'Last Name', // Label text here
                floatingLabelStyle:
                    TextStyle(color: AppConfig.appSecondaryTheme),
                hintText: 'Enter your last name',
              ),
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
                  value: college.isNotEmpty ? college : null,
                  items: ListConfig.colleges.map((String item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (String? newCollege) {
                    if (newCollege != null &&
                        ListConfig.colleges.contains(newCollege)) {
                      setState(() {
                        if (newCollege == college) {
                          isChanged = false;
                          fetchUserData();
                        } else {
                          college = newCollege;
                          isChanged = true;
                        }
                      });
                    } else {
                      // Handle the case where newCollege is null or not in ListConfig.colleges
                      // For example, show a message or set a default value
                    }
                  },
                ),
              ),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1.0, style: BorderStyle.solid, color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: isChanged
                  ? () async {
                      if (studentFirstName.text.isEmpty ||
                          studentLastName.text.isEmpty ||
                          college.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Fill all the fields.',
                          fontSize: 16,
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Disable dismissing the dialog
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, setState) {
                                return AlertDialog(
                                  titlePadding: EdgeInsets.zero,
                                  contentPadding: EdgeInsets.zero,
                                  title: isUpdating
                                      ? null
                                      : Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'SAVE CHANGES',
                                            style: TextStyle(
                                              fontFamily: 'Futura',
                                              color:
                                                  AppConfig.appSecondaryTheme,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                  content: isUpdating
                                      ? SizedBox(
                                          height:
                                              100, // Adjust the height as needed
                                          width:
                                              100, // Adjust the width as needed
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color:
                                                  AppConfig.appSecondaryTheme,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Are you sure you want to save the changes?',
                                            style: TextStyle(
                                              fontFamily: 'Futura',
                                              color: Colors.grey[900],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                  actions: isUpdating
                                      ? [] // Empty array means no actions when loading
                                      : [
                                          TextButton(
                                            child: isUpdating
                                                ? SizedBox()
                                                : const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      fontFamily: 'Futura',
                                                      color: AppConfig
                                                          .appSecondaryTheme,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                            onPressed: isUpdating
                                                ? null // Disable button during update
                                                : () async {
                                                    try {
                                                      setState(() {
                                                        isUpdating =
                                                            true; // Start update
                                                      });

                                                      String newProfileURL =
                                                          profileImageURL ?? '';
                                                      if (tempProfileImage !=
                                                          null) {
                                                        newProfileURL =
                                                            await uploadImage(
                                                                tempProfileImage!);
                                                      }

                                                      await studentReference
                                                          .doc(currentUserID)
                                                          .update({
                                                        'userFirstName':
                                                            studentFirstName
                                                                .text,
                                                        'userLastName':
                                                            studentLastName
                                                                .text,
                                                        'userCollege': college,
                                                        'userProfile':
                                                            newProfileURL,
                                                      });

                                                      setState(() {
                                                        isChanged = false;
                                                        tempProfileImage = null;
                                                        isUpdating =
                                                            false; // Update done
                                                      });

                                                      Fluttertoast.showToast(
                                                        msg:
                                                            'Changes saved successfully!',
                                                        fontSize: 16,
                                                      );

                                                      Navigator.of(context)
                                                          .pop();
                                                    } catch (e) {
                                                      print(
                                                          "Error saving changes: $e");
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            'Failed to save changes.',
                                                        fontSize: 16,
                                                      );
                                                      setState(() {
                                                        if (mounted) {
                                                          isUpdating =
                                                              false; // Update failed
                                                        }
                                                      });
                                                      // Handle errors as needed, this could be Firebase specific errors
                                                      // You may try to re-authenticate the user or handle the token issue here
                                                    }
                                                  },
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontFamily: 'Futura',
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                        ],
                                );
                              },
                            );
                          },
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppConfig.appSecondaryTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'SAVE CHANGES',
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
          ],
        ),
      ),
    );
  }
}
