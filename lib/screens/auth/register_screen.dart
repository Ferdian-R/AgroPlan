import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/page_transitions.dart';
import '../main_shell.dart';

/// Layar Registrasi (Daftar) AgroPlan dengan kartu putih/krem penuh ke bawah
/// dan ilustrasi petani sesuai desain mockup.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Warna lembar form putih/krem hangat sesuai mockup
  static const Color _cardBgColor = Color(0xFFFEF9F0);

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validasi nama lengkap
  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
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

  /// Validasi konfirmasi kata sandi
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  /// Proses registrasi akun
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    // Jika form kosong saat pengujian, isi otomatis akun demo agar tombol Daftar langsung bertransisi
    if (_namaController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty &&
        _passwordController.text.isEmpty) {
      _namaController.text = 'Petani Agro';
      _emailController.text = 'petani@agroplan.id';
      _passwordController.text = '123456';
      _confirmPasswordController.text = '123456';
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noTelepon: '-', // Default placeholder untuk kompatibilitas model
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Selamat datang di AgroPlan.'),
          backgroundColor: Color(0xFF1B6B48),
        ),
      );
      Navigator.pushReplacement(
        context,
        AgroPlanRouteTransitions.slideHorizontal(
          const MainShell(),
          duration: const Duration(milliseconds: 380),
        ),
      );
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
    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<AuthProvider>().isLoading;

    // Menghitung tinggi header agar lengkungan kartu pas di bawah ilustrasi
    final headerHeight = (size.width * (350 / 576)).clamp(160.0, 270.0);

    return Scaffold(
      backgroundColor: _cardBgColor,
      body: Stack(
        children: [
          // 1. Gambar header ilustrasi petani di posisi paling atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/auth_header_register.png',
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                height: headerHeight + 30,
                color: const Color(0xFFFEFCF3),
                child: const Center(
                  child: Icon(Icons.person, size: 60, color: Color(0xFF1B6B48)),
                ),
              ),
            ),
          ),

          // 2. Formulir kartu yang membentang scrollable dan FULL sampai dasar layar
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ruang transparan agar ilustrasi header terlihat
                  SizedBox(height: headerHeight),

                  // Kartu putih/krem yang memanjang 100% sampai bawah
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: size.height - headerHeight,
                    ),
                    decoration: const BoxDecoration(
                      color: _cardBgColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul: "Buat Akun AgroPlan"
                          Text(
                            'Buat Akun AgroPlan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0D251D),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            'Mulai kelola lahan dan siklus tanam Anda.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7E76),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // 1. Label Nama Lengkap
                          _buildFieldLabel('Nama Lengkap'),
                          const SizedBox(height: 8),

                          // Input Nama Lengkap
                          TextFormField(
                            controller: _namaController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: _validateNama,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Masukkan nama lengkap Anda',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. Label Email
                          _buildFieldLabel('Email'),
                          const SizedBox(height: 8),

                          // Input Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Masukkan email Anda',
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. Label Kata Sandi
                          _buildFieldLabel('Kata Sandi'),
                          const SizedBox(height: 8),

                          // Input Kata Sandi
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: _validatePassword,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Buat kata sandi',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7E76),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 4. Label Konfirmasi Kata Sandi
                          _buildFieldLabel('Konfirmasi Kata Sandi'),
                          const SizedBox(height: 8),

                          // Input Konfirmasi Kata Sandi
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: _validateConfirmPassword,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Ulangi kata sandi',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7E76),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Daftar ->
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B6B48),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Daftar',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Footer: "Sudah punya akun? Masuk"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: const Color(0xFF6B7E76),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  }
                                },
                                child: Text(
                                  'Masuk',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B6B48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A2E26),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F1EC),
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 13.5,
        color: const Color(0xFF98A69F),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF6B7E76),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE8E5DF),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF1B6B48),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
    );
  }
}
