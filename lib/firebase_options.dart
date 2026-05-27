import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError('Only Android is supported');
  }
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_APP_ID:android:YOUR_HASH',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'ninjkids-app',
    storageBucket: 'ninjkids-app.appspot.com',
  );
}
