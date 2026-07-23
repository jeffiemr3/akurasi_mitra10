// File ini dibuat manual sebagai TITIK AWAL saja.
//
// SANGAT DISARANKAN untuk menggantinya dengan hasil generate resmi:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Perintah di atas otomatis mengisi appId & measurementId yang benar untuk
// tiap platform (web/android/ios) dan menaruh google-services.json /
// GoogleService-Info.plist di tempat yang tepat.
//
// Nilai di bawah ini memakai projectId/apiKey/authDomain yang sudah ada dari
// project sebelumnya (Firestore). Untuk Realtime Database, kamu WAJIB
// mengisi `databaseURL` (lihat Firebase Console > Realtime Database > url
// di bagian atas halaman, formatnya https://<project-id>-default-rtdb.
// <region>.firebasedatabase.app).

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
    apiKey: 'AIzaSyDb0HS3M_-e1tjxGmVXaYpweN_8ExrAMV0',
    appId: '1:859391207472:web:db81eec614766288b5e5f5',
    messagingSenderId: '859391207472',
    projectId: 'arctic-totem-zj1d7',
    authDomain: 'arctic-totem-zj1d7.firebaseapp.com',
    storageBucket: 'arctic-totem-zj1d7.firebasestorage.app',
    // TODO: isi dengan URL Realtime Database asli dari Firebase Console.
    databaseURL: 'https://arctic-totem-zj1d7-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // TODO: lengkapi android/ios lewat `flutterfire configure` jika dipakai.
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
}
