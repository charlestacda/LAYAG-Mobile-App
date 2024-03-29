import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/landing.dart';
import 'package:lpu_app/views/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';




class UserTypeProvider with ChangeNotifier {
  String userType = ''; // Initialize with an empty string

  void setUserType(String type) {
    userType = type;
    notifyListeners(); // Notify listeners about the change
  }
}

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);


Future<void> main() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila')); 
  
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Future.delayed(const Duration(seconds: AppConfig.appSplashScreenDuration));

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

WidgetsFlutterBinding.ensureInitialized();

try {
    final directory = await getApplicationDocumentsDirectory();
    print('Application Documents Directory: ${directory.path}');
  } catch (e) {
    print('Error getting directory: $e');
  }


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

// Check if the app was terminated for more than 3 hours
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lastTerminationTimestamp = prefs.getInt('last_termination_timestamp');
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  int threeHoursInMillis = 3 * 60 * 60 * 1000; // 3 hours in milliseconds

  if (lastTerminationTimestamp != null &&
      currentTimestamp - lastTerminationTimestamp > threeHoursInMillis) {
    // If more than 3 hours, log out the user
    await FirebaseAuth.instance.signOut();
  }



  runApp(
    ChangeNotifierProvider<UserTypeProvider>(
      create: (context) => UserTypeProvider(),
      child: MaterialApp(
        title: AppConfig.appName,
        navigatorObservers: [
      observer, // Include Firebase Analytics observer in navigatorObservers
    ],
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
  
// Save the current timestamp when the app is terminated
  runAppObserver((AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      prefs.setInt('last_termination_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
  });
}

void runAppObserver(Function(AppLifecycleState) callback) {
  WidgetsBinding.instance?.addObserver(AppLifecycleObserver(callback));
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  final Function(AppLifecycleState) callback;

  AppLifecycleObserver(this.callback);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    callback(state);
  }
}



  
  




