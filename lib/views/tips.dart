import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';

class Tips extends StatelessWidget {
  List quotes = [
    'Organize your study place',
    'Drink water regularly',
    'Manage your time',
    'Get a good night\'s sleep',
    'Be aware of your surroundings and allow yourself to be present in the moment',
    'Prepare healthy meals and snacks',
    'Today, make yourself a priority and treat yourself accordingly',
    'Exercise Regularly',
    'Always stay true to yourself and never let what somebody says distract you from your goals',
    'Don\'t skip your meals',
    'Create a route',
    'Spend some time in the sunlight',
    'It is okay to take a rest from all the hustle',
  ];

  Widget dialogContent(BuildContext context) {
    int randomQuotes = Random().nextInt(quotes.length);

    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(
                top: 18.0,
              ),
              margin: const EdgeInsets.only(top: 13.0, right: 8.0),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: RichText(
                      text: const TextSpan(style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Futura'), children: [
                        TextSpan(text: 'DAILY ', style: TextStyle(color: Color(0xffD94141))),
                        TextSpan(text: 'STUDY TIPS!', style: TextStyle(color: AppConfig.appSecondaryTheme)),
                      ]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Text(
                      '${quotes[randomQuotes]}',
                      style: const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w400, fontFamily: 'Open Scans'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )),
          Positioned(
            right: 20.0,
            top: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: AppConfig.appSecondaryTheme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.white,
      child: dialogContent(context),
    );
  }
}
