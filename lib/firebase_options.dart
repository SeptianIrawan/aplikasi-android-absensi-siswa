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
    apiKey: 'AIzaSyB3Fw-ez86GrsVhz17Eefh-cwGwIScfCuk',
    appId: '1:907872328622:web:370949935dcf6f16fb863f',
    messagingSenderId: '907872328622',
    projectId: 'absensi-58403',
    authDomain: 'absensi-58403.firebaseapp.com',
    storageBucket: 'absensi-58403.firebasestorage.app',
    measurementId: 'G-058W7X048D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhezU8nKMZsLtSlJiuACCd-zp2jgR-GXc',
    appId: '1:907872328622:android:51bac219c608f15cfb863f',
    messagingSenderId: '907872328622',
    projectId: 'absensi-58403',
    storageBucket: 'absensi-58403.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgXbtJw-u9pEEyAChHLat0U9AGSoOpJKc',
    appId: '1:907872328622:ios:dc124d61fe9f6f32fb863f',
    messagingSenderId: '907872328622',
    projectId: 'absensi-58403',
    storageBucket: 'absensi-58403.firebasestorage.app',
    iosBundleId: 'com.example.aplikasiAbsensiSederhana',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgXbtJw-u9pEEyAChHLat0U9AGSoOpJKc',
    appId: '1:907872328622:ios:dc124d61fe9f6f32fb863f',
    messagingSenderId: '907872328622',
    projectId: 'absensi-58403',
    storageBucket: 'absensi-58403.firebasestorage.app',
    iosBundleId: 'com.example.aplikasiAbsensiSederhana',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3Fw-ez86GrsVhz17Eefh-cwGwIScfCuk',
    appId: '1:907872328622:web:94d57fcbf3eec790fb863f',
    messagingSenderId: '907872328622',
    projectId: 'absensi-58403',
    authDomain: 'absensi-58403.firebaseapp.com',
    storageBucket: 'absensi-58403.firebasestorage.app',
    measurementId: 'G-PYRGK10BNT',
  );

}