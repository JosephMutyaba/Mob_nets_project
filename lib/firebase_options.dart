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
        return macos;
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
    apiKey: 'AIzaSyAmQZdxq0FiS5xBT_wH_ix4ASXB5nv9SO0',
    appId: '1:12901778451:web:331e0bb63aa4934dc8abe6',
    messagingSenderId: '12901778451',
    projectId: 'mobnetsproject',
    authDomain: 'mobnetsproject.firebaseapp.com',
    storageBucket: 'mobnetsproject.appspot.com',
    measurementId: 'G-WG46B3J8HQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCVe4-gA9KlDSIQDJDy-qC86ffVDlvRhYQ',
    appId: '1:12901778451:android:961ddb18171a4ac4c8abe6',
    messagingSenderId: '12901778451',
    projectId: 'mobnetsproject',
    storageBucket: 'mobnetsproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgpu0TkCgubfq65H4mhtJjy0EdhU0dUP4',
    appId: '1:12901778451:ios:ca323aa0404a2f61c8abe6',
    messagingSenderId: '12901778451',
    projectId: 'mobnetsproject',
    storageBucket: 'mobnetsproject.appspot.com',
    iosBundleId: 'com.example.test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgpu0TkCgubfq65H4mhtJjy0EdhU0dUP4',
    appId: '1:12901778451:ios:ca323aa0404a2f61c8abe6',
    messagingSenderId: '12901778451',
    projectId: 'mobnetsproject',
    storageBucket: 'mobnetsproject.appspot.com',
    iosBundleId: 'com.example.test',
  );
}