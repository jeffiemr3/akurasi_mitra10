# Akurasi Mitra10 — Flutter + Firebase Realtime Database

Rebuild dari versi React/AI Studio sebelumnya menjadi **Flutter**, fokus pada
4 fitur inti:

1. **Login awal** (2 langkah: nama user → kata sandi)
2. **Manajemen User** (list, tambah, aktif/nonaktifkan, hapus)
3. **Upload Data** (stok WMS vs NAV: file Excel, copy-paste teks, atau input manual)
4. **Pemberian Misi** (penugasan kategori audit ke auditor)

Fitur lain dari versi lama (Hasil laporan HIT/MISS/OVER, halaman "Kerjakan
Misi Hari Ini", grafik donut, dsb) **belum dipindahkan** — silakan minta lagi
kalau mau dilanjutkan, supaya fokus perbaikan sekarang tidak melebar.

## Struktur proyek

```
lib/
  main.dart                        # entry point, init Firebase, auth gate
  firebase_options.dart            # config Firebase (lengkapi dulu, lihat di bawah)
  theme/app_colors.dart            # palet warna sesuai mockup asli
  models/
    app_user.dart
    category_assignment.dart       # + AuditItem, isInvalidCategoryName
  services/
    realtime_db_service.dart       # semua baca/tulis ke Realtime Database
    excel_import_service.dart      # parsing .xlsx/.xls/.csv & paste teks
  widgets/
    app_badge.dart
    common_widgets.dart            # AppCard, PrimaryButton, AppTextField, dll
  screens/
    login_username_screen.dart
    login_password_screen.dart
    menu_utama_screen.dart
    manajemen_user_screen.dart
    tambah_user_screen.dart
    upload_data_screen.dart
    mission_setup_screen.dart
```

## Struktur data di Realtime Database

```
users/
  <push-id>/
    name: "Sahat Sinaga"
    username: "sahat.sinaga"
    password: "..."               # lihat catatan keamanan di bawah
    role: "client"                 # atau "admin"
    category: "Floring & Wall"     # null kalau role admin
    status: "active"               # atau "idle"

categories/
  <push-id>/
    categoryName: "Floring & Wall"
    assignedUsername: "sahat.sinaga"   # atau null
    status: "available"
    itemCount: 42

itemsMap/
  <sanitized-category-key>/
    categoryName: "Floring & Wall"
    items: [ { id, name, codeWms, codeNav, wmsStock, navStock, status }, ... ]
    updatedAt: "2026-07-23T..."

meta/
  lastUploadAt: "23/07/2026 10:40 WIB"
```

Saat aplikasi pertama kali dijalankan dan node `users` masih kosong, otomatis
dibuat akun admin awal: **username `admin`, password `admin123`** — segera
ganti passwordnya lewat menu Manajemen User setelah login pertama.

## Langkah setup

1. **Lengkapi `lib/firebase_options.dart`.**
   File ini sudah diisi `apiKey`, `appId`, `authDomain`, `projectId`, dan
   `messagingSenderId` dari project Firebase yang sudah ada, TAPI kamu wajib
   mengisi `databaseURL` yang benar (lihat Firebase Console → Realtime
   Database → Create Database, lalu salin URL yang muncul di atas halaman).
   Cara termudah & paling aman dari typo — jalankan di root project:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

2. **Install dependency:**
   ```bash
   flutter pub get
   ```

3. **Atur Security Rules** di Firebase Console → Realtime Database → Rules,
   atau upload langsung isi file `database.rules.json` di repo ini. Untuk
   development cepat, rules-nya masih `read: true, write: true` (⚠️ jangan
   dipakai untuk produksi — lihat catatan keamanan di bawah).

4. **Run:**
   ```bash
   flutter run -d chrome     # untuk web
   flutter run                # untuk android/ios (device/emulator terhubung)
   ```

## Cara jalanin TANPA install apa-apa (via GitHub)

Kamu nggak perlu install git, Flutter, atau apapun di laptop. Cukup pakai
browser.

### 1. Buat repo baru di GitHub
- Buka https://github.com/new
- Isi nama repo, misal `akurasi_app` — **catat nama ini**, dipakai di step 3.
- Pilih **Public** (GitHub Pages gratis hanya jalan di repo public).
- Klik **Create repository**, biarkan kosong.

### 2. Upload semua file project ini
- Di halaman repo, klik **Add file → Upload files**.
- Drag & drop seluruh isi folder ini (termasuk `.github`, `lib`, `web`, dan
  `pubspec.yaml`) ke area upload.
- Scroll ke bawah, klik **Commit changes**.

### 3. Sesuaikan nama repo di workflow (kalau beda dari `akurasi_app`)
- Buka `.github/workflows/deploy.yml`, klik ikon pensil (Edit).
- Ganti `"/akurasi_app/"` jadi `"/nama-repo-kamu/"` (harus persis sama,
  termasuk garis miring di awal & akhir).
- Commit changes.

### 4. Nyalakan GitHub Pages
- Repo → **Settings → Pages**.
- Di **"Build and deployment" → Source**, pilih **"GitHub Actions"**.

### 5. Tunggu Actions selesai build
- Tab **Actions** → workflow "Deploy Flutter Web to GitHub Pages" akan
  otomatis jalan.
- Setelah centang hijau ✅ (biasanya 3–6 menit), buka lagi
  **Settings → Pages** untuk link `https://<username-kamu>.github.io/akurasi_app/`.

### 6. Update selanjutnya
Setiap kali file diupload ulang/diganti lewat GitHub web UI, workflow
otomatis jalan lagi dan situsnya ter-update sendiri.

## ⚠️ Catatan keamanan (penting sebelum dipakai beneran)

- Rules Realtime Database saat ini masih `read: true, write: true` untuk
  testing — siapapun yang tahu URL project Firebase-nya bisa baca/ubah/hapus
  semua data. Sebelum dipakai produksi:
  - Tambahkan **Firebase Authentication** (email/password) supaya login
    tidak hanya mengecek password di database secara manual.
  - Ganti rules jadi butuh `auth != null`, dan idealnya batasi field
    tertentu (mis. hanya admin yang boleh menulis ke `users`).
- Password user saat ini disimpan sebagai teks biasa di database (mengikuti
  desain versi sebelumnya) — ini **tidak aman untuk produksi**. Migrasi ke
  Firebase Authentication akan menghilangkan kebutuhan menyimpan password
  manual sama sekali.

## Yang sengaja belum dipindahkan dari versi lama

- Layar **"Misi Hari Ini"** (auditor mengerjakan/checklist item HIT/MISS/OVER)
- Layar **Hasil** (rekap laporan akurasi + grafik donut)
- Layar **Data** (ringkasan info laporan sebelum masuk Upload Data)

Beri tahu saja kalau salah satu di atas mau dilanjutkan berikutnya.
