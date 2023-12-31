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
    apiKey: 'AIzaSyDoKmXy3UjUHL8HVoznjHwiXcIpaIVapsk',
    appId: '1:526357502401:web:872a72245a8d38fe4cf740',
    messagingSenderId: '526357502401',
    projectId: 'signin-example-9bcbb',
    authDomain: 'signin-example-9bcbb.firebaseapp.com',
    storageBucket: 'signin-example-9bcbb.appspot.com',
    measurementId: 'G-KZFTNPZTST',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0qWDlNMegh2A5uiHm2C6SOzuZqNPSjk4',
    appId: '1:526357502401:android:0fe354e10ac84bdd4cf740',
    messagingSenderId: '526357502401',
    projectId: 'signin-example-9bcbb',
    storageBucket: 'signin-example-9bcbb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-ZmsrgpNXLfFJZrvf2KDG4Wc6Z_kO5oA',
    appId: '1:526357502401:ios:e1d4290f336b9bf54cf740',
    messagingSenderId: '526357502401',
    projectId: 'signin-example-9bcbb',
    storageBucket: 'signin-example-9bcbb.appspot.com',
    iosClientId: '526357502401-98mco8kgn69mh5if6vj9lj35cgqmml5c.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterChatFull',
  );
}
