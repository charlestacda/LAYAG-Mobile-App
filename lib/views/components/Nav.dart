import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/home.dart';
import 'package:lpu_app/views/calendar.dart';
import 'package:lpu_app/views/news.dart';
import 'package:lpu_app/views/todo.dart';
import 'package:lpu_app/views/handbook_menu.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:lpu_app/views/add_article.dart';
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
      body: const [Calendar(), ToDo(), Home(), HandbookMenu(), Notifications(), AddArticle()][currentIndex],
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
            Icons.newspaper_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications_none_outlined,
            color:Colors.white,
          ),
        ],
      ),
    );
  }
}
