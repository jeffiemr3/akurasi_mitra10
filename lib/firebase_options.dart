// File ini dibuat manual dari config yang kamu kasih.
// apiKey, authDomain, databaseURL, projectId sudah terisi.
// TODO: lengkapi appId & messagingSenderId dari Firebase Console
// (Project settings > General > Your apps), atau jalankan:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// supaya file ini di-generate otomatis & benar untuk Android/iOS/Web sekaligus.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXdX71IPsv7AvMYTJUUnIvyb3PRPRUmx8',
    appId: 'TODO_ISI_WEB_APP_ID',
    messagingSenderId: 'TODO_ISI_SENDER_ID',
    projectId: 'akurasi-mitra10',
    authDomain: 'akurasi-mitra10.firebaseapp.com',
    databaseURL: 'https://akurasi-mitra10-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO_ISI_ANDROID_API_KEY',
    appId: 'TODO_ISI_ANDROID_APP_ID',
    messagingSenderId: 'TODO_ISI_SENDER_ID',
    projectId: 'akurasi-mitra10',
    databaseURL: 'https://akurasi-mitra10-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_ISI_IOS_API_KEY',
    appId: 'TODO_ISI_IOS_APP_ID',
    messagingSenderId: 'TODO_ISI_SENDER_ID',
    projectId: 'akurasi-mitra10',
    databaseURL: 'https://akurasi-mitra10-default-rtdb.firebaseio.com',
    iosBundleId: 'com.mitra10.akurasi', // sesuaikan dengan bundle id kamu
  );
}
