import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../theme/app_colors.dart';
import 'menu_utama_screen.dart';
import 'misi_hari_ini_screen.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String username;

  const LoginPasswordScreen({super.key, required this.username});

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    final username = widget.username.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    try {
      final snapshot = await _usersRef.get();
      final data = snapshot.value;

      if (data == null || data is! Map) {
        setState(() => _errorText = 'Nama user atau password salah');
        return;
      }

      final map = Map<dynamic, dynamic>.from(data);

      Map<dynamic, dynamic>? matchedUser;
      for (final entry in map.entries) {
        final user = Map<dynamic, dynamic>.from(entry.value as Map);
        final storedUsername = (user['username'] ?? '').toString().toLowerCase();
        if (storedUsername == username) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser == null) {
        setState(() => _errorText = 'Nama user atau password salah');
        return;
      }

      final storedPassword = (matchedUser['password'] ?? '').toString();
      if (storedPassword != password) {
        setState(() => _errorText = 'Nama user atau password salah');
        return;
      }

      if (!mounted) return;

      final role = (matchedUser['role'] ?? 'client').toString();
      final category = (matchedUser['category'] ?? '').toString();
      final displayName = (matchedUser['name'] ?? widget.username).toString();

      Widget destination;
      if (role == 'admin') {
        destination = MenuUtamaScreen(name: displayName);
      } else {
        destination = MisiHariIniScreen(category: category, username: displayName);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorText = 'Gagal login: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(Icons.arrow_back, size: 16, color: AppColors.inkSoft),
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
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.navy,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.username.isNotEmpty
                                        ? widget.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Halo, ${widget.username}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Masukkan password kamu untuk\nmelanjutkan',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                autofocus: true,
                                onFieldSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password',
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
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      size: 18,
                                      color: AppColors.inkSoft,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                              ),
                              if (_errorText != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _errorText!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.coral),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Masuk',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
