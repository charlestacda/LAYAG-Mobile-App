import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  HelpState createState() => HelpState();
}

class HelpState extends State<Help> {
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
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    'HOW TO USE',
                    style: TextStyle(
                      fontFamily: 'Futura',
                      color: Color(0xffD94141),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text:
                            'The LPU-C mobile application is designed to provide digital services for the entire '
                                'LPU-Cavite institution and its stakeholders. The goal is to put focus on the importance and continuous '
                                'improvement of customer services, digital connectedness, seamless cross-device integration, and '
                                'act as a one-stop-shop that is accessible, centralized and mobile-driven.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'Home Page'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
                      child: Image.asset(
                        'assets/images/lpu-app-home.png',
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'This is the home page of the mobile app. In this section, the user can access '
                                'the MyLPU Classroom, Aims portal, contact information, and payment procedures by tapping on '
                                'their respective buttons.',
                          ),
                        ],
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'Academic Calendar'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
                      child: Image.asset(
                        'assets/images/lpu-app-calendar.png',
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'The user must tap the calendar icon in the bottom navigation bar '
                                'in order to view the \'Academic Calendar\'.',
                          ),
                        ],
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'To-Do List'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
                      child: Image.asset(
                        'assets/images/lpu-app-sample.png',
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'In the To-Do-List section, the user can add a task by tapping the button. '
                                'Every task that is created has a color that denotes the task\'s due date. If the due date '
                                'of a particular task is greater than two days, the app will set the color of the task to green. '
                                'If the due date is equal to one or two days, the task color will be set to yellow. Lastly, '
                                'if the task is due, the color of the task will be set to red. If the task is marked completed, '
                                'the system will remove the task from the list then display it under the task completed list.',
                          ),
                        ],
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'News and Events'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
                      child: Image.asset(
                        'assets/images/lpu-app-news.png',
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'By tapping the icon button on the bottom navigation, the user can access the \'News and Events\' sections. '
                                'Each article posted will depend on the user\'s departmental affiliation.',
                          ),
                        ],
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'Notifications'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 20),
                      child: Image.asset(
                        'assets/images/lpu-app-notif.png',
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'The user can see all the notifications from the \'News and Events\' and \'To-Do List\' by tapping its icon button. '
                                'Tapping the \'Clear All\' button will remove all the notifications displayed.',
                          ),
                        ],
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(text: 'To know more about LPU-App, please'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10), // Add spacing here
                            TextButton(
                              child: const Text(
                                'click here',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppConfig.appSecondaryTheme,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                URL.launch(
                                    'https://drive.google.com/file/d/1mTH-5GG_Zf8QohVUrwwOROdHiArxTmZz/view?usp=sharing');
                              },
                            ),
                          ],
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: 'for more information.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
