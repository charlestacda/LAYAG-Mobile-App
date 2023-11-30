import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lpu_app/config/app_config.dart';
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
  
  runApp(
    ChangeNotifierProvider<UserTypeProvider>(
      create: (context) => UserTypeProvider(), // Provide an instance of UserTypeProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.appDebugMode,
      home: const Login(),
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppConfig.appSecondaryTheme,
        ),
      ),
    );
  }
}
