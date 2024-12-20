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
    apiKey: 'AIzaSyBcFC8WiDlH0QeHdeCf8HA1XPEV1L8NpQQ',
    appId: '1:140759369408:web:808e3a736317853cabcf25',
    messagingSenderId: '140759369408',
    projectId: 'osat-a9e47',
    authDomain: 'osat-a9e47.firebaseapp.com',
    storageBucket: 'osat-a9e47.appspot.com',
    measurementId: 'G-N7YR5BJMH4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAec_RlqcyeqHi1bc2V9j0E0SrfVcjxIO4',
    appId: '1:140759369408:android:cfe22387702fd119abcf25',
    messagingSenderId: '140759369408',
    projectId: 'osat-a9e47',
    storageBucket: 'osat-a9e47.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjFRs8FHbAjTahpAa6l4kDqp73wSCaMug',
    appId: '1:140759369408:ios:5864dd6ed4da5835abcf25',
    messagingSenderId: '140759369408',
    projectId: 'osat-a9e47',
    storageBucket: 'osat-a9e47.appspot.com',
    androidClientId: '140759369408-6dkg7qrlg7is9dpbugmb1383nevrisoo.apps.googleusercontent.com',
    iosClientId: '140759369408-f0kk989ataedj4rbouh3smo6bmo9m0v7.apps.googleusercontent.com',
    iosBundleId: 'in.osat.osat',
  );
}
