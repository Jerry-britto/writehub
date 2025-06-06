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
    apiKey: 'AIzaSyBM0UYm00CdS1p5XWj53soLtJptsIM-TCI',
    appId: '1:282392056907:web:c248b296bdbdc97b4aa9ce',
    messagingSenderId: '282392056907',
    projectId: 'writehub-a7b40',
    authDomain: 'writehub-a7b40.firebaseapp.com',
    storageBucket: 'writehub-a7b40.firebasestorage.app',
    measurementId: 'G-L0GL6KJ6ZS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8g6A0s5SpwotyZ5CiUFfoKlajzKetYD8',
    appId: '1:282392056907:android:b0221322312d287e4aa9ce',
    messagingSenderId: '282392056907',
    projectId: 'writehub-a7b40',
    storageBucket: 'writehub-a7b40.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADLDXRIM_2j-4L6NwDQE4PhJ7fRCSH_1c',
    appId: '1:282392056907:ios:fbdf38c21642a61e4aa9ce',
    messagingSenderId: '282392056907',
    projectId: 'writehub-a7b40',
    storageBucket: 'writehub-a7b40.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );
}
