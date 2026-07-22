# Akurasi — Manajemen User (Flutter + Firebase)

Titik awal koding: layar **Manajemen user** (list, delete) + **Tambah user** (create),
terhubung ke Firebase Realtime Database.

## Struktur

```
lib/
  main.dart                     # entry point, init Firebase
  firebase_options.dart         # config Firebase (perlu dilengkapi, lihat di bawah)
  theme/app_colors.dart         # palet warna sesuai mockup HTML
  models/app_user.dart          # model data user
  screens/manajemen_user_screen.dart   # list user + tombol delete
  screens/tambah_user_screen.dart      # form tambah user + role Admin/Client
```

## Struktur data di Realtime Database

```
users/
  -Nabc123/
    name: "Sahat Sinaga"
    email: "sahat.sinaga@mitra10.com"
    role: "client"              # atau "admin"
    category: "Floring & Wall"  # null kalau role admin
    status: "idle"              # atau "active"
```

## Langkah setup

1. **Lengkapi `lib/firebase_options.dart`.**
   Kamu sudah kasih `apiKey`, `authDomain`, `databaseURL`, `projectId`, tapi Firebase
   butuh `appId` dan `messagingSenderId` juga (per platform: web/android/ios).
   Cara termudah & paling aman dari typo — jalankan di root project:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Ini otomatis generate ulang `firebase_options.dart` yang benar untuk semua platform
   yang kamu pilih (Android/iOS/Web), dan otomatis juga menaruh `google-services.json` /
   `GoogleService-Info.plist` di tempat yang tepat.

2. **Install dependency:**
   ```bash
   flutter pub get
   ```

3. **Atur Security Rules di Firebase Console** (Realtime Database > Rules).
   Untuk development cepat (⚠️ jangan dipakai di production):
   ```json
   {
     "rules": {
       "users": {
         ".read": true,
         ".write": true
       }
     }
   }
   ```
   Nanti sebelum rilis, ganti jadi `auth != null` atau rules yang lebih ketat
   (misal hanya admin yang bisa write ke node `users`).

4. **Run:**
   ```bash
   flutter run
   ```

## Cara jalanin TANPA install apa-apa (via GitHub)

Kamu nggak perlu install git, flutter, atau apapun di laptop. Cukup pakai browser.

### 1. Buat repo baru di GitHub
- Buka https://github.com/new
- Isi nama repo, misal `akurasi_app` — **catat nama ini**, karena dipakai di step 3.
- Pilih **Public** (GitHub Pages gratis hanya jalan di repo public).
- Klik **Create repository**, biarkan kosong (jangan centang "Add README").

### 2. Upload semua file project ini
- Di halaman repo yang baru dibuat, klik **"uploading an existing file"** (atau menu **Add file → Upload files**).
- **Drag & drop seluruh folder** `akurasi_app` (termasuk folder `.github`, `lib`, dan file `pubspec.yaml`) ke area upload. Browser modern (Chrome) akan mempertahankan struktur foldernya otomatis.
- Scroll ke bawah, klik **Commit changes**.

> Kalau drag-folder nggak jalan di browser kamu: upload manual per folder — masuk ke tiap
> subfolder pakai "Add file" satu-satu sambil ketik path lengkapnya, misal
> `lib/screens/manajemen_user_screen.dart`, GitHub otomatis bikin foldernya.

### 3. Sesuaikan nama repo di workflow (kalau beda dari `akurasi_app`)
- Buka file `.github/workflows/deploy.yml` di repo, klik ikon pensil (Edit).
- Ganti `"/akurasi_app/"` jadi `"/nama-repo-kamu/"` (harus persis sama, termasuk garis miring di awal & akhir).
- Commit changes.

### 4. Nyalakan GitHub Pages
- Repo → **Settings → Pages**.
- Di bagian **"Build and deployment" → Source**, pilih **"GitHub Actions"**.

### 5. Tunggu Actions selesai build
- Klik tab **Actions** di repo → akan ada workflow run "Deploy Flutter Web to GitHub Pages"
  yang otomatis jalan setelah commit di step 2/3.
- Tunggu sampai centang hijau ✅ (biasanya 3–5 menit — GitHub yang install & jalanin Flutter di server-nya, bukan di laptop kamu).
- Setelah selesai, buka lagi **Settings → Pages** — akan muncul link seperti:
  `https://<username-kamu>.github.io/akurasi_app/`
- Buka link itu di Chrome — aplikasinya langsung jalan di situ, dan link ini bisa
  dibuka ulang kapan saja tanpa build ulang.

### 6. Update selanjutnya
Setiap kali kamu (atau saya bantu edit lalu kasih file baru) upload ulang/replace file
lewat GitHub web UI, workflow otomatis jalan lagi dan situsnya ter-update sendiri.

### ⚠️ Catatan keamanan
Karena situsnya PUBLIC (siapa saja bisa buka link-nya), dan Security Rules Realtime
Database saat ini masih `read: true, write: true` untuk testing — **siapapun yang tau
link Firebase-nya bisa baca/ubah/hapus data user**. Ini oke untuk tahap testing, tapi
sebelum dipakai beneran:
- Ganti rules jadi butuh autentikasi (`auth != null`), dan
- Tambahkan Firebase Authentication supaya hanya user yang login yang bisa akses.



- Form "Tambah user" saat ini **hanya menulis data profil** (nama, email, role,
  kategori) ke Realtime Database — belum membuat akun login sungguhan. Untuk auth
  asli (supaya user bisa login pakai email+password), tambahkan **Firebase
  Authentication** dan panggil `createUserWithEmailAndPassword` saat simpan.
  Field password belum ada di form ini karena menunggu keputusan itu — kabari kalau
  mau saya tambahkan sekalian.
- `status` (`active`/`idle`) idealnya di-update otomatis saat user login pertama kali
  (misal lewat Cloud Function `onCreate`/`onLogin` atau di-set manual saat auth
  berhasil), bukan diisi manual selamanya.
