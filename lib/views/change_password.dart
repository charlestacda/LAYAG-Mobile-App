import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpu_app/config/app_config.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool isPasswordEightCharacters = false;
  bool containsNumber = false;
  bool containsLowercase = false;
  bool containsUppercase = false;
  bool containsSpecialChar = false;
  bool isNewPasswordsMatch = false;
  bool isButtonEnabled = false;

  bool isCurrentPasswordNotEmpty = false;

  @override
  void initState() {
    super.initState();
    currentPasswordController.addListener(checkCurrentPasswordNotEmpty);
  }

  void checkCurrentPasswordNotEmpty() {
    setState(() {
      isCurrentPasswordNotEmpty = currentPasswordController.text.isNotEmpty;
      isButtonEnabled = isCurrentPasswordNotEmpty &&
          isPasswordEightCharacters &&
          containsNumber &&
          containsLowercase &&
          containsUppercase &&
          containsSpecialChar &&
          isNewPasswordsMatch;
    });
  }

  Future<void> _showConfirmationDialog() async {
    bool? confirm;

    confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'CONFIRM PASSWORD CHANGE',
            style: TextStyle(
              fontFamily: 'Futura',
              color: AppConfig.appSecondaryTheme,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text('Are you sure you want to change your password?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appSecondaryTheme,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      // Display loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.1, // Set your preferred width here
              height: MediaQuery.of(context).size.width *
                  0.5, // Set your preferred height here
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      );

      try {
        await _changePassword();
        // Password changed successfully
        Navigator.of(context).pop(); // Dismiss loading dialog

        setState(() {
          // Clear fields and reset conditions if the password is successfully changed
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmNewPasswordController.clear();
          isPasswordEightCharacters = false;
          containsNumber = false;
          containsLowercase = false;
          containsUppercase = false;
          containsSpecialChar = false;
          isNewPasswordsMatch = false;
          isButtonEnabled = false;
        });

        Fluttertoast.showToast(
          msg: 'Password updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (error) {
        // Password change failed
        Navigator.of(context).pop(); // Dismiss loading dialog

        Fluttertoast.showToast(
          msg: 'The Current Password field is incorrect.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        print('Error changing password: $error');
      }
    }
  }

  Future<void> _changePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the new password is empty
      if (newPasswordController.text.isEmpty) {
        print('New password is empty.');
        throw 'New password is empty.';
      }

      // Check if the current password is empty or if the user is not authenticated
      if (currentPasswordController.text.isEmpty || user == null) {
        print('Current password is empty or user is not authenticated.');
        throw 'Current password is empty or user is not authenticated.';
      }

      // Re-authenticate the user with the current password
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPasswordController.text);
      await user.reauthenticateWithCredential(credential);

      // If the current password is correct, update the password in Firebase
      await user.updatePassword(newPasswordController.text);
    } catch (error) {
      print('Error changing password: $error');
      throw error; // Password change failed
    }
  }

  void checkPasswordConditions(String value) {
    setState(() {
      isPasswordEightCharacters = value.length >= 8;
      containsNumber = RegExp(r'\d').hasMatch(value);
      containsLowercase = RegExp(r'[a-z]').hasMatch(value);
      containsUppercase = RegExp(r'[A-Z]').hasMatch(value);
      containsSpecialChar =
          RegExp(r'[!@#$%^&*()_+={}\[\]|;:"<>,./?]').hasMatch(value);
    });

    checkPasswordsMatch();
  }

  void checkPasswordsMatch() {
    final newPassword = newPasswordController.text;
    final confirmNewPassword = confirmNewPasswordController.text;

    setState(() {
      isNewPasswordsMatch = newPassword.isNotEmpty &&
          confirmNewPassword.isNotEmpty &&
          newPassword == confirmNewPassword;
      isButtonEnabled = isCurrentPasswordNotEmpty &&
          isPasswordEightCharacters &&
          containsNumber &&
          containsLowercase &&
          containsUppercase &&
          containsSpecialChar &&
          isNewPasswordsMatch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double textFieldWidth = MediaQuery.of(context).size.width - 32;

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'CHANGE PASSWORD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: Color(0xFFD94141),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: textFieldWidth,
                child: TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  onChanged: (_) => checkCurrentPasswordNotEmpty(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppConfig.appSecondaryTheme,
                      ),
                    ),
                    labelText: 'Current Password',
                    floatingLabelStyle:
                        TextStyle(color: AppConfig.appSecondaryTheme),
                    hintText: 'Enter your current password',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: textFieldWidth,
                child: TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  onChanged: (value) => checkPasswordConditions(value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppConfig.appSecondaryTheme,
                      ),
                    ),
                    labelText: 'New Password',
                    floatingLabelStyle:
                        TextStyle(color: AppConfig.appSecondaryTheme),
                    hintText: 'Enter your new password',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildConditionIndicator(
                  isPasswordEightCharacters, 'Contains at least 8 characters'),
              const SizedBox(height: 10),
              buildConditionIndicator(
                  containsNumber, 'Contains at least 1 number'),
              const SizedBox(height: 10),
              buildConditionIndicator(
                  containsLowercase, 'Contains at least 1 lowercase'),
              const SizedBox(height: 10),
              buildConditionIndicator(
                  containsUppercase, 'Contains at least 1 uppercase'),
              const SizedBox(height: 10),
              buildConditionIndicator(
                  containsSpecialChar, 'Contains at least 1 special character'),
              const SizedBox(height: 10),
              buildConditionIndicator(isNewPasswordsMatch,
                  'New Password and Confirm New Password\nmatch'),
              const SizedBox(height: 20),
              SizedBox(
                width: textFieldWidth,
                child: TextFormField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  onChanged: (_) => checkPasswordsMatch(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppConfig.appSecondaryTheme,
                      ),
                    ),
                    labelText: 'Confirm New Password',
                    floatingLabelStyle:
                        TextStyle(color: AppConfig.appSecondaryTheme),
                    hintText: 'Confirm your new password',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: textFieldWidth,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _showConfirmationDialog : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppConfig.appSecondaryTheme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'CHANGE PASSWORD',
                    style: TextStyle(
                      fontFamily: 'Futura',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildConditionIndicator(bool isConditionMet, String conditionText) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isConditionMet
                ? AppConfig.appSecondaryTheme
                : Colors.transparent,
            border: isConditionMet
                ? Border.all(color: Colors.transparent)
                : Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(50),
          ),
          child: isConditionMet
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
        Text(conditionText)
      ],
    );
  }
}
