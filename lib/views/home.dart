import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/payment_procedures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpu_app/views/borrow_return.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isPopedUp = false;
  Random random = Random();
  int randomNumber = 0;

  @override
  void initState() {
    super.initState();
    randomNumber = random.nextInt(8);
    checkAndShowDialog();
  }

  void checkAndShowDialog() async {
    // Get the shared preferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the dialog has been shown before
    bool dialogShown = prefs.getBool('dialogShown') ?? false;
    if (!dialogShown) {
      // If the dialog has not been shown, show it
      await showDialog(
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
            content: Text(
              ListConfig.popups[randomNumber],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
          );
        },
      );          
      prefs.setBool('dialogShown', true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/images/home_header.png',
              width: double.infinity,
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                height: 700,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: GridView.count(physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 8.0, children: [
                  GestureDetector(
                    onTap: () {
                      URL.launch('https://www.lpu.edu.ph/');
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppConfig.appSecondaryTheme, borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                              Expanded(child: Image.asset('assets/images/home_contact_information.png', fit: BoxFit.contain)),
                              const SizedBox(height: 16),
                              const Text('LPU Official Website',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                            ]),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      URL.launch('https://lpu.mrooms.net/');
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppConfig.appSecondaryTheme, borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                              Expanded(child: Image.asset('assets/images/home_mylpu_classroom.png', fit: BoxFit.contain)),
                              const SizedBox(height: 16),
                              const Text('myLPU e-Learning',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                            ]),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      URL.launch('https://aimscavite.lpu.edu.ph/lpucvt/students/');
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppConfig.appSecondaryTheme, borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                              Expanded(child: Image.asset('assets/images/home_aims_student_portal.png', fit: BoxFit.contain)),
                              const SizedBox(height: 16),
                              const Text('AIMS Student Portal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                            ]),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BorrowReturn(userEmail: getCurrentUser.email!),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConfig.appSecondaryTheme,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Image.asset(
                                  'assets/images/home_library_module.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Book Reservation Portal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  )),
                            ]),
                          )),
                    ),
                  ),
                ])),
          ]),
        ),
      ),
    );
  }
}
