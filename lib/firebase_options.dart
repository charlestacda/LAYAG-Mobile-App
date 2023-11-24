// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABSAgV_aHPZYw5jdTDXxPCVsMwZqq8sIU',
    appId: '1:157513689407:web:153184673d9625c477cb8a',
    messagingSenderId: '157513689407',
    projectId: 'lpu-app-database-e0c6c',
    authDomain: 'lpu-app-database-e0c6c.firebaseapp.com',
    databaseURL: 'https://lpu-app-database-e0c6c-default-rtdb.firebaseio.com',
    storageBucket: 'lpu-app-database-e0c6c.appspot.com',
    measurementId: 'G-Y85DB8TDM4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAF2lKfqYx9HkWfas2TRhGZHwsSop3PRqo',
    appId: '1:157513689407:android:5efc4404cf42863e77cb8a',
    messagingSenderId: '157513689407',
    projectId: 'lpu-app-database-e0c6c',
    databaseURL: 'https://lpu-app-database-e0c6c-default-rtdb.firebaseio.com',
    storageBucket: 'lpu-app-database-e0c6c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA36rJy_UPBFr3HHgupeHm9vpr4mAYTcrc',
    appId: '1:157513689407:ios:0aa8c22b5057ce9e77cb8a',
    messagingSenderId: '157513689407',
    projectId: 'lpu-app-database-e0c6c',
    databaseURL: 'https://lpu-app-database-e0c6c-default-rtdb.firebaseio.com',
    storageBucket: 'lpu-app-database-e0c6c.appspot.com',
    iosBundleId: 'com.lpudevteam.lpuApp',
  );
}
