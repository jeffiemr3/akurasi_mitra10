import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo bulat "Akurasi" — porting dari src/components/Badge.tsx
class AppBadge extends StatelessWidget {
  final double size;

  const AppBadge({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.check_circle,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
