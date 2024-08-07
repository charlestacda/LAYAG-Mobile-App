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
  String userType = '';

  void setUserType(String type) {
    userType = type;
    notifyListeners();
  }
}

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

Future<void> main() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Future.delayed(
      const Duration(seconds: AppConfig.appSplashScreenDuration));

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
    'resource://drawable/layag_icon',
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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lastTerminationTimestamp = prefs.getInt('last_termination_timestamp');
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  int threeHoursInMillis = 3 * 60 * 60 * 1000;

  if (lastTerminationTimestamp != null &&
      currentTimestamp - lastTerminationTimestamp > threeHoursInMillis) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(
    ChangeNotifierProvider<UserTypeProvider>(
      create: (context) => UserTypeProvider(),
      child: MaterialApp(
        title: AppConfig.appName,
        navigatorObservers: [
          observer,
        ],
        debugShowCheckedModeBanner: AppConfig.appDebugMode,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              return const Landing();
            } else {
              return const Login();
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

  runAppObserver((AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      prefs.setInt(
          'last_termination_timestamp', DateTime.now().millisecondsSinceEpoch);
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
