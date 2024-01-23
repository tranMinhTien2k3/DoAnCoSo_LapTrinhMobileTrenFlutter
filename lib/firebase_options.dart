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
    apiKey: 'AIzaSyCj_G7UyPD6AjdZ1iDYv8zRtL7kSh157Fg',
    appId: '1:644038501885:web:cba3e250841d9ceddde594',
    messagingSenderId: '644038501885',
    projectId: 'appdemo-88d5f',
    authDomain: 'appdemo-88d5f.firebaseapp.com',
    storageBucket: 'appdemo-88d5f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJrQDOL0T_KArM_PbrOnG8nwU4X0x1g0o',
    appId: '1:644038501885:android:799e211dada22508dde594',
    messagingSenderId: '644038501885',
    projectId: 'appdemo-88d5f',
    storageBucket: 'appdemo-88d5f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOjrey5qM59r1eKOjDvsfWscD0JHlVdCA',
    appId: '1:644038501885:ios:75747ec502e74261dde594',
    messagingSenderId: '644038501885',
    projectId: 'appdemo-88d5f',
    storageBucket: 'appdemo-88d5f.appspot.com',
    iosBundleId: 'com.example.appdemo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOjrey5qM59r1eKOjDvsfWscD0JHlVdCA',
    appId: '1:644038501885:ios:f26a3f4f076b01c3dde594',
    messagingSenderId: '644038501885',
    projectId: 'appdemo-88d5f',
    storageBucket: 'appdemo-88d5f.appspot.com',
    iosBundleId: 'com.example.appdemo.RunnerTests',
  );
}
