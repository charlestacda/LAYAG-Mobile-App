import 'package:flutter/material.dart';
import 'package:lpu_app/views/edit_profile.dart';
import 'package:lpu_app/views/change_password.dart';
import 'package:lpu_app/config/app_config.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({Key? key}) : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: Color(0xFFD94141),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          EditProfile(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppConfig.appSecondaryTheme, // Set card color here
                  child: SizedBox(
                    height: 120, // Adjust card height as needed
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 48, // Set icon size here
                          ),
                          const SizedBox(width: 24),
                          Flexible(
                            child: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text(
                                  'Edit\nProfile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24, // Set text size here
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 32, // Set icon size here
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ChangePassword(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppConfig.appSecondaryTheme, // Set card color here
                  child: SizedBox(
                    height: 120, // Adjust card height as needed
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 48, // Set icon size here
                          ),
                          const SizedBox(width: 24),
                          Flexible(
                            child: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text(
                                  'Change\nPassword',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24, // Set text size here
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 32, // Set icon size here
                          ),
                        ],
                      ),
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
}
