import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/account_settings.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/home.dart';
import 'package:lpu_app/views/calendar.dart';
import 'package:lpu_app/views/todo.dart';
import 'package:lpu_app/views/handbook_menu.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NewNavigation extends StatefulWidget {
  const NewNavigation({Key? key}) : super(key: key);

  @override
  BottomNavState createState() => BottomNavState();
}

class BottomNavState extends State<NewNavigation> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const [Calendar(), ToDo(), Home(), HandbookMenu(), ContactInfo()][currentIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: Colors.white,
        color:AppConfig.appSecondaryTheme,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          Icon(
            Icons.calendar_month_outlined,
            color:Colors.white,

          ),
          Icon(
            Icons.assignment_turned_in_outlined,
            color:Colors.white,
          ),
          Icon(
            Icons.home,
            color:Colors.white,
          ),
          Icon(
            Icons.book_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.contact_mail_outlined,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
