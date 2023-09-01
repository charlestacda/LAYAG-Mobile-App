import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/login.dart';

Future main() async {
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Future.delayed(const Duration(seconds: AppConfig.appSplashScreenDuration));

  await Firebase.initializeApp();

  FlutterNativeSplash.remove();
  
  runApp(const MyApp());
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
            fontFamily: 'Arial',
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppConfig.appSecondaryTheme,
            )));
  }
}
