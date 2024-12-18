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
    apiKey: 'AIzaSyDf6_MNUh1VaN1HE5u2j226wMDR7c6wkXY',
    appId: '1:266530804747:web:68883ac856819c2136630e',
    messagingSenderId: '266530804747',
    projectId: 'discursia-b2e55',
    authDomain: 'discursia-b2e55.firebaseapp.com',
    storageBucket: 'discursia-b2e55.firebasestorage.app',
    measurementId: 'G-30C7R933ST',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxYdCQSSYcSOXBLL4djkEPL5E-WPsj-eI',
    appId: '1:266530804747:android:5e0e4290995cc9b036630e',
    messagingSenderId: '266530804747',
    projectId: 'discursia-b2e55',
    storageBucket: 'discursia-b2e55.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCnU5vbJ2Uc171ad87vkkCGXLeJAgt5yA',
    appId: '1:266530804747:ios:504f36b4b1b33e6936630e',
    messagingSenderId: '266530804747',
    projectId: 'discursia-b2e55',
    storageBucket: 'discursia-b2e55.firebasestorage.app',
    iosBundleId: 'com.alex.discursia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCnU5vbJ2Uc171ad87vkkCGXLeJAgt5yA',
    appId: '1:266530804747:ios:504f36b4b1b33e6936630e',
    messagingSenderId: '266530804747',
    projectId: 'discursia-b2e55',
    storageBucket: 'discursia-b2e55.firebasestorage.app',
    iosBundleId: 'com.alex.discursia',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDf6_MNUh1VaN1HE5u2j226wMDR7c6wkXY',
    appId: '1:266530804747:web:532b61687ebbb72336630e',
    messagingSenderId: '266530804747',
    projectId: 'discursia-b2e55',
    authDomain: 'discursia-b2e55.firebaseapp.com',
    storageBucket: 'discursia-b2e55.firebasestorage.app',
    measurementId: 'G-97HYXG718N',
  );
}