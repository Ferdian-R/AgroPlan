import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/page_transitions.dart';
import '../auth/login_screen.dart';
import '../main_shell.dart';

/// Layar Splash Screen AgroPlan.
///
/// Menampilkan identitas visual AgroPlan:
/// - Logo & nama aplikasi dengan tagline "Kelola Lahan, Rencanakan Panen"
/// - Ilustrasi lanskap pertanian di bagian bawah
/// - Animasi fade & scale yang halus
/// - Otomatis mengarahkan ke '/main' (jika sudah login) atau '/login' (jika belum)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _navTimer;

  // Warna latar belakang yang menyatu dengan langit pada ilustrasi
  static const Color _bgColor = Color(0xFFFEFCF3);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // Navigasi otomatis setelah durasi splash screen selesai (2.8 detik)
    _navTimer = Timer(const Duration(milliseconds: 2800), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final targetWidget = authProvider.isAuthenticated
        ? const MainShell()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      AgroPlanRouteTransitions.crossFade(
        targetWidget,
        duration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final landscapeHeight = (size.height * 0.50).clamp(180.0, 500.0);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ilustrasi lanskap pertanian di bagian bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: landscapeHeight,
              child: Image.asset(
                'assets/images/splash_landscape.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Konten Logo & Branding di area atas layar
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: (size.height * 0.13).clamp(48.0, 110.0),
                    left: 24.0,
                    right: 24.0,
                    bottom: 16.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo resmi aplikasi AgroPlan (posisi elegan di area atas)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 260,
                                maxHeight:
                                    (size.height * 0.35).clamp(140.0, 300.0),
                              ),
                              child: Image.asset(
                                'assets/images/splash_logo_transparent.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/logo_agroplan.webp',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Indikator loading halus yang serasi dengan brand hijau
                            SizedBox(
                              width: 36,
                              height: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: const LinearProgressIndicator(
                                  backgroundColor: Color(0x330F5238),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}
