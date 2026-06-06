// PLACEHOLDER Firebase configuration — NOT real credentials.
//
// These values are intentionally FAKE so the app compiles, runs, and shows its
// UI out of the box. With placeholders, Firebase-backed features (real auth,
// Firestore reads/writes, Storage, push) will not connect — `main.dart` catches
// the init error so the app still launches.
//
// To enable the backend, regenerate this file with real values:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// File mirrors the structure produced by the FlutterFire CLI.
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
    apiKey: 'FAKE-web-api-key-run-flutterfire-configure',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ars-placeholder',
    authDomain: 'ars-placeholder.firebaseapp.com',
    storageBucket: 'ars-placeholder.appspot.com',
    measurementId: 'G-0000000000',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'FAKE-android-api-key-run-flutterfire-configure',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ars-placeholder',
    storageBucket: 'ars-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FAKE-ios-api-key-run-flutterfire-configure',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ars-placeholder',
    storageBucket: 'ars-placeholder.appspot.com',
    iosBundleId: 'com.example.arsapplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'FAKE-macos-api-key-run-flutterfire-configure',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ars-placeholder',
    storageBucket: 'ars-placeholder.appspot.com',
    iosBundleId: 'com.example.arsapplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'FAKE-windows-api-key-run-flutterfire-configure',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'ars-placeholder',
    authDomain: 'ars-placeholder.firebaseapp.com',
    storageBucket: 'ars-placeholder.appspot.com',
    measurementId: 'G-0000000000',
  );
}
