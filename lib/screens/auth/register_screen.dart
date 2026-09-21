import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_card.dart';
import '../../widgets/primary_button.dart';

/// Layar Registrasi (Daftar) AgroPlan sesuai desain Figma "Daftar".
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validasi nama
  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    return null;
  }

  /// Validasi format email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi nomor telepon (hanya angka)
  String? _validateTelepon(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final cleanValue = value.trim();
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(cleanValue)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (cleanValue.length < 9) {
      return 'Nomor telepon minimal 9 digit';
    }
    return null;
  }

  /// Validasi kata sandi (minimal 6 karakter)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  /// Proses registrasi akun
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // TODO: Hubungkan ke REST API MySQL backend
    // POST /api/auth/register dengan { nama, email, no_telepon, password }
    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noTelepon: _teleponController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan masuk.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context); // Kembali ke layar Masuk
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal mendaftar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.p24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Judul Layar: "Daftar"
                  Text(
                    'Daftar',
                    style: AppTextStyles.authTitle,
                  ),
                  const SizedBox(height: AppSpacing.p24),

                  // Kartu Putih Berisi Form Pendaftaran
                  AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Field Nama
                          AppTextField(
                            controller: _namaController,
                            hintText: 'Nama',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: _validateNama,
                          ),
                          const SizedBox(height: AppSpacing.p14),

                          // Field Email
                          AppTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.p14),

                          // Field No Telepon
                          AppTextField(
                            controller: _teleponController,
                            hintText: 'No telepon',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: _validateTelepon,
                          ),
                          const SizedBox(height: AppSpacing.p14),

                          // Field Password
                          AppTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: AppSpacing.p20),

                          // Tombol DAFTAR
                          PrimaryButton.auth(
                            text: 'DAFTAR',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.p20),

                  // Footer: "Sudah memiliki akun? Masuk"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah memiliki akun? ',
                        style: AppTextStyles.authFooter,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Masuk',
                          style: AppTextStyles.authFooterLink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
