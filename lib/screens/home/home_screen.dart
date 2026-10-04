import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lahan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/land_card.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';
import '../../widgets/weather_info_card.dart';
import '../../widgets/wide_menu_card.dart';
import '../placeholder_screen.dart';
import '../../routes/app_routes.dart';

/// Status tampilan untuk bagian yang memuat data.
enum ViewStatus { loading, success, error }

/// Layar Beranda (Home Screen) AgroPlan di dalam MainShell.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  bool _simulateError = false; // ubah ke true untuk menguji error state

  @override
  void initState() {
    super.initState();
    _loadLahan();
  }

  /// Simulasi pengambilan data lahan + penanganan error.
  Future<void> _loadLahan() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      await Future.delayed(const Duration(seconds: 2)); // simulasi server
      if (_simulateError) {
        throw Exception('Gagal memuat data lahan. Periksa koneksi internet.');
      }
      if (!mounted) return;
      setState(() => _status = ViewStatus.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  /// Navigasi ke halaman placeholder untuk modul/fitur lanjutan
  void _navigateToPlaceholder(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData icon = Icons.construction_outlined,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
      ),
    );
  }

  /// Menampilkan snackbar cepat untuk aksi sederhana
  void _showComingSoonSnackBar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $featureName segera hadir di pembaruan berikutnya.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryNav,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lahanProvider = context.watch<LahanProvider>();
    final daftarLahan = lahanProvider.lahanList;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Aplikasi (Tinggi 64 dp) ---
            AppHeader(
              onNotificationPressed: () {
                _navigateToPlaceholder(
                  context,
                  title: 'Notifikasi',
                  subtitle: 'Pemberitahuan pengingat rencana tanam & jatuh tempo perawatan.',
                  icon: Icons.notifications_active_outlined,
                );
              },
              onProfilePressed: () {
                _navigateToPlaceholder(
                  context,
                  title: 'Profil Petani',
                  subtitle: 'Pengaturan akun dan preferensi lahan.',
                  icon: Icons.person_outline,
                );
              },
            ),

            // --- Konten Beranda (Scrollable) ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Banner
                    _buildHeroSection(context),

                    // Konten halaman di bawah Hero
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.p20),

                          // 2. Seksi "Lahan Saya"
                          SectionHeader(
                            title: 'Lahan Saya',
                            actionText: 'Lihat semua',
                            onActionPressed: () {
                              _navigateToPlaceholder(
                                context,
                                title: 'Daftar Seluruh Lahan',
                                subtitle: 'Modul 1: Manajemen data lahan dan informasi detail.',
                                icon: Icons.landscape_outlined,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.p12),

                          // Kartu Lahan: loading / error / kosong / data
                          _buildLandSection(context, daftarLahan),
                          const SizedBox(height: AppSpacing.p12),

                          // Tombol "+ Tambah Lahan"
                          PrimaryButton.homeAction(
                            text: 'Tambah Lahan',
                            prefixIcon: const Icon(Icons.add, size: 18, color: Colors.white),
                            onPressed: () {
                              _navigateToPlaceholder(
                                context,
                                title: 'Tambah Data Lahan',
                                subtitle: 'FR-01: Form input data lahan baru (nama, luas, jenis tanah, komoditas).',
                                icon: Icons.add_business_outlined,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.p24),

                          // 3. Seksi "Menu Utama"
                          const SectionHeader(title: 'Menu Utama'),
                          const SizedBox(height: AppSpacing.p12),

                          _buildMainMenu(context),
                          const SizedBox(height: AppSpacing.p32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seksi Hero: latar ilustrasi, teks sambutan, dan WeatherInfoCard.
  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/hero_home.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0.3, -0.4),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.65, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.homeBackground,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Petani!',
                      style: AppTextStyles.greeting,
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    Text(
                      'Langkah kecil hari ini untuk\nhasil yang lebih baik 🌱',
                      style: AppTextStyles.taglineHero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),
              WeatherInfoCard(
                onTap: () => _showComingSoonSnackBar(context, 'Detail Cuaca'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Memilih tampilan berdasarkan status: loading / error / (empty | data)
  Widget _buildLandSection(BuildContext context, List<Lahan> daftarLahan) {
    return switch (_status) {
      ViewStatus.loading => const SizedBox(
          height: 160,
          child: LoadingView(message: 'Memuat lahan...'),
        ),
      ViewStatus.error => SizedBox(
          height: 240,
          child: ErrorView(message: _errorMessage, onRetry: _loadLahan),
        ),
      ViewStatus.success => _buildLandRow(context, daftarLahan),
    };
  }

  /// Seksi 2 Kartu Lahan (Lahan Utama & Lahan Belakang)
  Widget _buildLandRow(BuildContext context, List<Lahan> daftarLahan) {
    if (daftarLahan.isEmpty) {
      return const SizedBox(
        height: 160,
        child: EmptyView(
          icon: Icons.landscape_outlined,
          message: 'Belum ada data lahan.',
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Lahan 1 -> kirim data Lahan ke DetailLahanScreen
        Expanded(
          child: LandCard(
            lahan: daftarLahan[0],
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: daftarLahan[0],
            ),
            onMenuPressed: () => _showComingSoonSnackBar(context, 'Menu Opsi Lahan'),
          ),
        ),
        const SizedBox(width: AppSpacing.menuGap),

        // Kartu Lahan 2 (jika ada) -> kirim data Lahan ke DetailLahanScreen
        Expanded(
          child: daftarLahan.length > 1
              ? LandCard(
                  lahan: daftarLahan[1],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: daftarLahan[1],
                  ),
                  onMenuPressed: () => _showComingSoonSnackBar(context, 'Menu Opsi Lahan'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Grid Menu Utama sesuai modul PRD AgroPlan
  Widget _buildMainMenu(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MenuCard(
                title: 'Siklus Tanam',
                subtitle: 'Rencana & fase tanam',
                icon: Icons.spa_outlined,
                isFirst: true,
                onTap: () {
                  _navigateToPlaceholder(
                    context,
                    title: 'Siklus Tanam',
                    subtitle: 'Modul 1: FR-05 (Tambah siklus) & FR-06 (Pengingat rencana tanam).',
                    icon: Icons.spa_outlined,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.menuGap),
            Expanded(
              child: MenuCard(
                title: 'Laporan Kondisi',
                subtitle: 'Pantau risiko & hama',
                icon: Icons.search_rounded,
                isFirst: false,
                onTap: () {
                  _navigateToPlaceholder(
                    context,
                    title: 'Laporan Kondisi Lahan',
                    subtitle: 'Modul 2: FR-07 (Lapor kondisi) & FR-12 (Peringatan risiko tinggi).',
                    icon: Icons.search_rounded,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.menuGap),
        Row(
          children: [
            Expanded(
              child: MenuCard(
                title: 'Jadwal Perawatan',
                subtitle: 'Aktivitas jatuh tempo',
                icon: Icons.calendar_today_outlined,
                isFirst: false,
                onTap: () {
                  _navigateToPlaceholder(
                    context,
                    title: 'Jadwal Perawatan',
                    subtitle: 'Modul 3: FR-13 (Jadwal otomatis) & FR-19 (Pengingat jatuh tempo).',
                    icon: Icons.calendar_today_outlined,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.menuGap),
            Expanded(
              child: MenuCard(
                title: 'Estimasi Panen',
                subtitle: 'Kalkulasi proyeksi hasil',
                icon: Icons.trending_up_rounded,
                isFirst: false,
                onTap: () {
                  _navigateToPlaceholder(
                    context,
                    title: 'Estimasi Hasil Panen',
                    subtitle: 'Modul 3: FR-16 (Kalkulasi potensi dasar x faktor kondisi gabungan).',
                    icon: Icons.trending_up_rounded,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.menuGap),
        WideMenuCard(
          title: 'Riwayat Panen',
          subtitle: 'Evaluasi hasil panen',
          icon: Icons.inventory_2_outlined,
          onTap: () {
            _navigateToPlaceholder(
              context,
              title: 'Riwayat Panen',
              subtitle: 'Modul 3: FR-17 (Catatan data panen) & FR-18 (Evaluasi hasil panen).',
              icon: Icons.inventory_2_outlined,
            );
          },
        ),
      ],
    );
  }
}