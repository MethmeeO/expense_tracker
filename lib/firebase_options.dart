// GENERATED FILE -- DO NOT EDIT BY HAND.
//
// This is a PLACEHOLDER. Replace this entire file by running:
//   flutterfire configure
// in the project root after creating a Firebase project. That command
// talks to your real Firebase project and overwrites this file with your
// actual apiKey/appId/projectId values for each platform (Android, iOS, web).
//
// See README.md, step 2, for the full setup walkthrough.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to generate them.',
        );
    }
  }

  // PLACEHOLDER VALUES -- replaced automatically by `flutterfire configure`.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEDibhJD0xG3H382V_o1oycchwUKWigAk',
    appId: '1:694924817842:web:c86e6baf57590e944d20ab',
    messagingSenderId: '694924817842',
    projectId: 'expensetracker2026-b8679',
    authDomain: 'expensetracker2026-b8679.firebaseapp.com',
    storageBucket: 'expensetracker2026-b8679.firebasestorage.app',
    measurementId: 'G-NH39Z0MF79',
  );
}
