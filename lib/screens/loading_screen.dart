import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Layar "Loading" — ditampilkan saat aplikasi memuat data
/// (misal saat upload XLSX, sinkronisasi Firebase, atau splash awal).
///
/// PENTING — setup asset gambar:
/// 1. Simpan file ilustrasi kamu sebagai: assets/images/loading_worker.png
/// 2. Di pubspec.yaml, pastikan ada baris:
///      flutter:
///        assets:
///          - assets/images/
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Mohon tunggu...',
    this.subMessage = 'Sedang memuat data',
    this.progress, // null = indeterminate (bar bergerak terus), 0.0-1.0 = progress pasti
  });

  final String message;
  final String subMessage;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ilustrasi
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/loading_worker.png',
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 24),
                // Bar loading
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 200,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: progress, // null -> animasi jalan terus otomatis
                      backgroundColor: AppColors.grayChip,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy),
                    ),
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress! * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
