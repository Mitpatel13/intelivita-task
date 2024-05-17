// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCW_bqxbTgZ4ZAJ-_DK59cIMrHHnBlyfdQ',
    appId: '1:738231014947:web:c6812eed2fe36addd64396',
    messagingSenderId: '738231014947',
    projectId: 'intelivita-task',
    authDomain: 'intelivita-task.firebaseapp.com',
    storageBucket: 'intelivita-task.appspot.com',
    measurementId: 'G-J8SPV5DDFW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATOHjVo14Hnkw7G3cE87Wgsovw7uQSkRM',
    appId: '1:738231014947:android:e150dc99915bb36bd64396',
    messagingSenderId: '738231014947',
    projectId: 'intelivita-task',
    storageBucket: 'intelivita-task.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAyD6fWdaX5ka-Q1-BiAlF2MGB2dmLIDMM',
    appId: '1:738231014947:ios:753681f30bd42222d64396',
    messagingSenderId: '738231014947',
    projectId: 'intelivita-task',
    storageBucket: 'intelivita-task.appspot.com',
    androidClientId: '738231014947-jhrfsvfhngibvsvnmv2gkolt8f4ps76m.apps.googleusercontent.com',
    iosClientId: '738231014947-nha48r2daqgmajeqvufhoimsu2c4ucnl.apps.googleusercontent.com',
    iosBundleId: 'com.example.intelivitaTask',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAyD6fWdaX5ka-Q1-BiAlF2MGB2dmLIDMM',
    appId: '1:738231014947:ios:753681f30bd42222d64396',
    messagingSenderId: '738231014947',
    projectId: 'intelivita-task',
    storageBucket: 'intelivita-task.appspot.com',
    androidClientId: '738231014947-jhrfsvfhngibvsvnmv2gkolt8f4ps76m.apps.googleusercontent.com',
    iosClientId: '738231014947-nha48r2daqgmajeqvufhoimsu2c4ucnl.apps.googleusercontent.com',
    iosBundleId: 'com.example.intelivitaTask',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCW_bqxbTgZ4ZAJ-_DK59cIMrHHnBlyfdQ',
    appId: '1:738231014947:web:91aa192ab275e1b4d64396',
    messagingSenderId: '738231014947',
    projectId: 'intelivita-task',
    authDomain: 'intelivita-task.firebaseapp.com',
    storageBucket: 'intelivita-task.appspot.com',
    measurementId: 'G-19FVRBXD0C',
  );

}