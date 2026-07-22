import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// File ini dibuat manual (bukan lewat `flutterfire configure`) supaya bisa
/// langsung dipakai tanpa install Flutter/FlutterFire CLI di komputer.
///
/// PENTING: lengkapi 3 nilai yang masih kosong di bawah (projectId,
/// messagingSenderId, appId) — ambil dari Firebase Console:
/// Project Settings > scroll ke "Your apps" > SDK config.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return web; // sementara pakai config yang sama sampai kamu tambah app Android terpisah di Firebase Console
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBXdX71IPsv7AvMYTJUUnIvyb3PRPRUmx8",
    authDomain: "akurasi-mitra10.firebaseapp.com",
    databaseURL: "https://akurasi-mitra10-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "akurasi-mitra10", // TODO: konfirmasi, biasanya sama seperti sebelum ".firebaseapp.com" di authDomain
    storageBucket: "akurasi-mitra10.firebasestorage.app", // TODO: cek nilai aslinya di console
    messagingSenderId: "ISI_DARI_CONSOLE", // TODO: wajib diisi
    appId: "ISI_DARI_CONSOLE", // TODO: wajib diisi
  );
}
