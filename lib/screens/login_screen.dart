import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'login_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPasswordScreen(username: _usernameCtrl.text.trim()),
      ),
    );
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
              const Text(
                'MASUK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.inkSoft,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Badge(),
                              const SizedBox(height: 18),
                              const Text(
                                'MITRA10',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Akurasi',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Masuk dengan nama user kamu untuk\nmulai misi hari ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Nama user',
                                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _usernameCtrl,
                                onFieldSubmitted: (_) => _next(),
                                decoration: InputDecoration(
                                  hintText: 'nama.user',
                                  filled: true,
                                  fillColor: AppColors.fieldFill,
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.line),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.line),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Nama user wajib diisi' : null,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _next,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28)),
                                  ),
                                  child: const Text('Lanjutkan',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.5),
                                  children: [
                                    TextSpan(text: 'Dengan melanjutkan, kamu menyetujui '),
                                    TextSpan(
                                      text: 'Ketentuan Layanan',
                                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: ' dan '),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
