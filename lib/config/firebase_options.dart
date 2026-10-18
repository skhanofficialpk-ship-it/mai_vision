// Firebase configuration for MAI Coaching Academy.
// Web values below are real, copied from Firebase Console > Project Settings > Your apps > Web app.
// Android/iOS/macOS blocks remain placeholders since this project currently only targets Flutter Web.
// If you add mobile platforms later, run `flutterfire configure` (or repeat the manual
// Firebase Console steps) to fill those in.
//
// NOTE: storageBucket is intentionally omitted everywhere below. This project
// uses Firebase Authentication + Cloud Firestore only (Spark/free plan) and
// never initializes Firebase Storage.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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

  // Real config for the MAI Coaching Academy web app (project: mai-vision).
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCa9AVnJkLrnaWPI36wStmvF4mnw3JElwM',
    appId: '1:848343796661:web:67ccccdb5d749bdb8ca7fc',
    messagingSenderId: '848343796661',
    projectId: 'mai-vision',
    authDomain: 'mai-vision.firebaseapp.com',
    storageBucket: 'mai-vision.firebasestorage.app',
  );

  // NOT YET CONFIGURED — only needed if you build an Android version of this app.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: '848343796661',
    projectId: 'mai-vision',
  );

  // NOT YET CONFIGURED — only needed if you build an iOS version of this app.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '848343796661',
    projectId: 'mai-vision',
    iosBundleId: 'com.maivision.academy',
  );

  // NOT YET CONFIGURED — only needed if you build a macOS version of this app.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: '848343796661',
    projectId: 'mai-vision',
    iosBundleId: 'com.maivision.academy',
  );
}
