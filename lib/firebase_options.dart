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
    apiKey: 'AIzaSyAgIH13NaCr8JOu70SFwQ4Rv8HdAQKkklQ',
    appId: '1:48437600413:web:bddc9d1795c98785323474',
    messagingSenderId: '48437600413',
    projectId: 'control-car-project',
    authDomain: 'control-car-project.firebaseapp.com',
    storageBucket: 'control-car-project.appspot.com',
    measurementId: 'G-PJ5WT0SY5K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8YrsmRR2aVcSLxQQg3wjPgpS1vvkLWuE',
    appId: '1:48437600413:android:9f43f30dd7a67ec4323474',
    messagingSenderId: '48437600413',
    projectId: 'control-car-project',
    storageBucket: 'control-car-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9NjKjqAFJ6gh_Tn2w3ZK5q4GIcUv2GNE',
    appId: '1:48437600413:ios:45d459f449171c27323474',
    messagingSenderId: '48437600413',
    projectId: 'control-car-project',
    storageBucket: 'control-car-project.appspot.com',
    androidClientId: '48437600413-mc2gu6j227efaehn2jg0c51pc8ak4ojn.apps.googleusercontent.com',
    iosClientId: '48437600413-hgd7c7m5t95r59bei3dgc8lmbuac8r99.apps.googleusercontent.com',
    iosBundleId: 'com.ctrcar.clientControlCar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9NjKjqAFJ6gh_Tn2w3ZK5q4GIcUv2GNE',
    appId: '1:48437600413:ios:45d459f449171c27323474',
    messagingSenderId: '48437600413',
    projectId: 'control-car-project',
    storageBucket: 'control-car-project.appspot.com',
    androidClientId: '48437600413-mc2gu6j227efaehn2jg0c51pc8ak4ojn.apps.googleusercontent.com',
    iosClientId: '48437600413-hgd7c7m5t95r59bei3dgc8lmbuac8r99.apps.googleusercontent.com',
    iosBundleId: 'com.ctrcar.clientControlCar',
  );
}