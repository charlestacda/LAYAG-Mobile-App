import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/faculty_registration.dart';
import 'package:lpu_app/views/student_registration.dart';
import 'package:lpu_app/views/login.dart';

class RegistrationMenu extends StatefulWidget {
  const RegistrationMenu({Key? key}) : super(key: key);

  @override
  RegistrationMenuState createState() => RegistrationMenuState();
}

class RegistrationMenuState extends State<RegistrationMenu> {
 Widget regStudent() => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRegistration())),
      child: Card(
        color: const Color(0xffD94141),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Image.asset('assets/images/register_selection_student.png'),
              const SizedBox(height: 16),
              const Text(
                'Register as Student',
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

Widget regFaculty() => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultyRegistration())),
      child: Card(
        color: const Color(0xffD94141),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Image.asset('assets/images/register_selection_teacher.png'),
              const SizedBox(height: 16),
              const Text(
                'Register as Employee',
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );


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
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          regStudent(),
                          const SizedBox(height: 8),
                          regFaculty(),
                        ],
                      )),
                )
              ],
            ),
          ),
        ));
  }
}
