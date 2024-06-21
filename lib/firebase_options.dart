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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAooiu5qn72DTHKpHLub_V13YpWL7nOpic',
    appId: '1:25398856906:web:c6b2c165eed67e4359b833',
    messagingSenderId: '25398856906',
    projectId: 'chat-c5da8',
    authDomain: 'chat-c5da8.firebaseapp.com',
    storageBucket: 'chat-c5da8.appspot.com',
    measurementId: 'G-Z2VEBFPEFK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1cegEIWXzGt_y1nII6fsH98818uj3eQM',
    appId: '1:25398856906:android:77ea05908eb243ff59b833',
    messagingSenderId: '25398856906',
    projectId: 'chat-c5da8',
    storageBucket: 'chat-c5da8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-J0J-TJg_c3m_2cphKsvwvsNQM7hVtOg',
    appId: '1:25398856906:ios:3af564878e2969ab59b833',
    messagingSenderId: '25398856906',
    projectId: 'chat-c5da8',
    storageBucket: 'chat-c5da8.appspot.com',
    iosBundleId: 'com.example.chat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAooiu5qn72DTHKpHLub_V13YpWL7nOpic',
    appId: '1:25398856906:web:ee144427f55044fb59b833',
    messagingSenderId: '25398856906',
    projectId: 'chat-c5da8',
    authDomain: 'chat-c5da8.firebaseapp.com',
    storageBucket: 'chat-c5da8.appspot.com',
    measurementId: 'G-81SK24Q166',
  );

}