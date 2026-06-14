// TODO: Replace with your actual Firebase configuration
// Run: flutterfire configure --project=YOUR_PROJECT_ID
// Or manually fill in the values below from your Firebase console

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── WEB ──────────────────────────────────────────────────────────────────
  // TODO: Fill these values from Firebase Console → Project Settings → Web App
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6DBWYEkTNv7QE0P7MAbtJSlSc6YiJnw0',
    appId: '1:576056016616:web:54675719dc0de0da22535d',
    messagingSenderId: '576056016616',
    projectId: 'melz-restaurant',
    authDomain: 'melz-restaurant.firebaseapp.com',
    storageBucket: 'melz-restaurant.firebasestorage.app',
  );

  // ─── ANDROID ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // ─── IOS ──────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.melz.melzRestaurant',
  );
}
