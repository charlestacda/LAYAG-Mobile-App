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
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: _EditProfile(), // Directly use _AccountSettings widget here
      );
  }
}

class _EditProfile extends StatefulWidget {
  const _EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
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

  void fetchCollegeOnly() async {
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
              college = currentUser.userCollege ?? '';

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
      XFile? pickedFile;

      if (source == ImageSource.camera) {
        pickedFile = await ImagePicker().pickImage(source: source);
      } else {
        pickedFile = await ImagePicker().pickImage(source: source);
      }

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
                'EDIT PROFILE',
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
                                         return Image.asset(
                                  'assets/images/user.png',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                );
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r"[A-Za-z\s\W]+")), // Allow letters, spaces, and special characters
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isNotEmpty) {
                    // Capitalize the first letter of each word
                    return TextEditingValue(
                      text: newValue.text.split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() +
                              word.substring(1).toLowerCase();
                        }
                        return '';
                      }).join(' '),
                      selection: newValue.selection,
                    );
                  }
                  return newValue;
                }),
              ],
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r"[A-Za-z\s\W]+")), // Allow letters, spaces, and special characters
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isNotEmpty) {
                    // Capitalize the first letter of each word
                    return TextEditingValue(
                      text: newValue.text.split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() +
                              word.substring(1).toLowerCase();
                        }
                        return '';
                      }).join(' '),
                      selection: newValue.selection,
                    );
                  }
                  return newValue;
                }),
              ],
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
                          fetchCollegeOnly();
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
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                  content: isUpdating
                                      ? SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color:
                                                  AppConfig.appSecondaryTheme,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(16.0, 1.0, 16.0, 16.0),
                                          child: Text(
                                            'Are you sure you want to save the changes?',
                                          ),
                                        ),
                                  actionsPadding:
                                      EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                                  actions: isUpdating
                                      ? []
                                      : [
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
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          SizedBox(width: 4.0),
                                          TextButton(
                                            child: const Text(
                                              'Yes',
                                              style: TextStyle(
                                                fontFamily: 'Futura',
                                                color:
                                                    AppConfig.appSecondaryTheme,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            onPressed: isUpdating
                                                ? null
                                                : () async {
                                                    try {
                                                      setState(() {
                                                        isUpdating = true;
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

                                                      var user = FirebaseAuth
                                                          .instance.currentUser;
                                                      user?.updatePhotoURL(
                                                          newProfileURL);

                                                      setState(() {
                                                        isChanged = false;
                                                        tempProfileImage = null;
                                                        isUpdating = false;
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
                                                          isUpdating = false;
                                                        }
                                                      });
                                                    }
                                                  },
                                          ),
                                        ],
                                );
                              },
                            );
                          },
                        );
                      }
                      ;
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
