import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/landing.dart';
import 'package:lpu_app/views/login.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';



class UserTypeProvider with ChangeNotifier {
  String userType = ''; // Initialize with an empty string

  void setUserType(String type) {
    userType = type;
    notifyListeners(); // Notify listeners about the change
  }
}

Future<void> main() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila')); 
  
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Future.delayed(const Duration(seconds: AppConfig.appSplashScreenDuration));

  await Firebase.initializeApp();

  FlutterNativeSplash.remove();
  
  AwesomeNotifications().initialize(
    'resource://drawable/layag_icon', // Replace with your app icon
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Default notification channel',
        defaultColor: AppConfig.appSecondaryTheme,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
    ],
  );


  runApp(
    ChangeNotifierProvider<UserTypeProvider>(
      create: (context) => UserTypeProvider(),
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: AppConfig.appDebugMode,
        // Listen to authentication state changes and navigate accordingly
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Display a loader if the connection is still in progress
            } else if (snapshot.hasData && snapshot.data != null) {
              return const Landing(); // Navigate to the Landing screen if a user is logged in
            } else {
              return const Login(); // Navigate to the Login screen if no user is logged in
            }
          },
        ),
        theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppConfig.appSecondaryTheme,
        ),
      ),
    ),
    ),
  );



  
}

  
  




