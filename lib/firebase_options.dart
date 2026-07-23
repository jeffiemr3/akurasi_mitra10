// Konfigurasi Firebase project "akurasi-mitra10".
//
// File ini dibuat manual dari config yang diberikan (Firebase Console >
// Project Settings > SDK setup and configuration). Kalau nanti kamu juga
// mau build untuk Android/iOS, jalankan `flutterfire configure` supaya
// appId khusus Android/iOS ikut terisi otomatis (saat ini android/ios masih
// memakai config web sebagai fallback).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini. '
          'Jalankan `flutterfire configure` untuk melengkapi.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXdX71IPsv7AvMYTJUUnIvyb3PRPRUmx8',
    appId: '1:451811488658:web:68f1776af4fff3cc75074b',
    messagingSenderId: '451811488658',
    projectId: 'akurasi-mitra10',
    authDomain: 'akurasi-mitra10.firebaseapp.com',
    storageBucket: 'akurasi-mitra10.firebasestorage.app',
    databaseURL: 'https://akurasi-mitra10-default-rtdb.firebaseio.com',
    measurementId: 'G-PT2QBZZJ4G',
  );

  // TODO: lengkapi android/ios lewat `flutterfire configure` kalau nanti
  // mau build ke Android/iOS juga (appId-nya beda dari web).
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
}
