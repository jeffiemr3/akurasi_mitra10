import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../theme/app_colors.dart';
import '../widgets/app_badge.dart';
import '../widgets/common_widgets.dart';
import 'login_password_screen.dart';

/// Langkah 1 dari login: masukkan nama user.
/// Porting dari src/screens/LoginUsernameScreen.tsx
class LoginUsernameScreen extends StatefulWidget {
  final List<AppUser> users;
  final void Function(AppUser loggedInUser) onLoginSuccess;

  const LoginUsernameScreen({
    super.key,
    required this.users,
    required this.onLoginSuccess,
  });

  @override
  State<LoginUsernameScreen> createState() => _LoginUsernameScreenState();
}

class _LoginUsernameScreenState extends State<LoginUsernameScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    final typed = _controller.text.trim();
    if (typed.isEmpty) {
      setState(() => _error = 'Nama user wajib diisi');
      return;
    }

    AppUser? matchedUser;
    for (final u in widget.users) {
      if (u.username.toLowerCase() == typed.toLowerCase()) {
        matchedUser = u;
        break;
      }
    }

    if (widget.users.isNotEmpty) {
      if (matchedUser == null) {
        setState(() => _error = 'user tidak terdaftar');
        return;
      }
      if (!matchedUser.isActive) {
        setState(() =>
            _error = 'Akun @${matchedUser!.username} sedang dinonaktifkan oleh Admin.');
        return;
      }
    }

    setState(() => _error = null);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LoginPasswordScreen(
        username: matchedUser?.username ?? typed,
        users: widget.users,
        onLoginSuccess: widget.onLoginSuccess,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenLabel('Masuk'),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      child: AppCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const AppBadge(size: 56),
                            const SizedBox(height: 16),
                            const Text(
                              'MITRA10',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Akurasi',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Masuk dengan nama user kamu untuk\nmulai misi hari ini',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              controller: _controller,
                              label: 'Nama user',
                              hint: 'nama.user (mis: admin, sahat.sinaga)',
                              autofocus: true,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppColors.coral,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Lanjutkan',
                              onPressed: _handleNext,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Dengan melanjutkan, kamu menyetujui Ketentuan Layanan dan Kebijakan Privasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.inkSoft,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
