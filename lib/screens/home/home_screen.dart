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
import '../../widgets/weather_info_card.dart';
import '../../widgets/wide_menu_card.dart';
import '../placeholder_screen.dart';
import '../perawatan/jadwal_list_screen.dart';
import '../lahan/tambah_lahan_screen.dart';
import '../lahan/daftar_lahan_screen.dart';
import '../laporan/riwayat_laporan_screen.dart';

/// Layar Beranda (Home Screen) AgroPlan di dalam MainShell.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    // 1. Hero Banner dengan Latar Belakang Petani, Sawah, & Weather Card
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DaftarLahanScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.p12),

                          // Dua Kartu Lahan Berdampingan (Data dari LahanProvider)
                          _buildLandSection(context, daftarLahan),
                          const SizedBox(height: AppSpacing.p12),

                          // Tombol "+ Tambah Lahan" (WORKFLOW: Entry point Tambah Lahan Baru)
                          PrimaryButton.homeAction(
                            text: 'Tambah Lahan',
                            prefixIcon: const Icon(Icons.add, size: 18, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TambahLahanScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.p24),

                          // 3. Seksi "Menu Utama"
                          const SectionHeader(title: 'Menu Utama'),
                          const SizedBox(height: AppSpacing.p12),

                          // Grid Menu 2 Kolom + 1 Kartu Riwayat Panen Penuh
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

  /// Seksi Hero terintegrasi sesuai desain Figma (Foto ke-3):
  /// Menampilkan latar ilustrasi petani dan sawah dengan teks sambutan di kiri atas,
  /// petani di kanan, serta WeatherInfoCard yang mengambang di atas latar sawah.
  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        // Latar Belakang Gambar Hero dengan degradasi halus di bagian bawah
        Positioned.fill(
          child: Image.asset(
            'assets/images/hero_home.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0.3, -0.4),
          ),
        ),

        // Gradien halus di bawah agar menyatu sempurna dengan warna latar belakang #F8FAF6
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

        // Konten Hero: Sambutan Petani + Kartu Cuaca Statis
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p20),

              // Teks Sambutan & Tagline Hero (diberi batas kanan agar petani di kanan terlihat)
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

              // Kartu Cuaca Statis di atas ilustrasi sawah
              WeatherInfoCard(
                onTap: () => _showComingSoonSnackBar(context, 'Detail Cuaca'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Seksi 2 Kartu Lahan (Lahan Utama & Lahan Belakang)
  Widget _buildLandSection(BuildContext context, List<Lahan> daftarLahan) {
    if (daftarLahan.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: Text('Belum ada data lahan'),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Lahan 1 (Lahan Utama)
        Expanded(
          child: LandCard(
            lahan: daftarLahan[0],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TambahLahanScreen(lahanToEdit: daftarLahan[0]),
                ),
              );
            },
            onMenuPressed: () => _tampilkanMenuLahan(context, daftarLahan[0]),
          ),
        ),
        const SizedBox(width: AppSpacing.menuGap),

        // Kartu Lahan 2 (Lahan Belakang jika ada)
        Expanded(
          child: daftarLahan.length > 1
              ? LandCard(
                  lahan: daftarLahan[1],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TambahLahanScreen(lahanToEdit: daftarLahan[1]),
                      ),
                    );
                  },
                  onMenuPressed: () => _tampilkanMenuLahan(context, daftarLahan[1]),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _tampilkanMenuLahan(BuildContext context, Lahan lahan) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.p12),
              Text(
                lahan.namaLahan,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.p8),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Edit Informasi Lahan'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TambahLahanScreen(lahanToEdit: lahan),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus Lahan', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final success = await context.read<LahanProvider>().hapusLahan(lahan.idLahan);
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lahan "${lahan.namaLahan}" berhasil dihapus'),
                        backgroundColor: AppColors.textPrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grid Menu Utama sesuai modul PRD AgroPlan
  Widget _buildMainMenu(BuildContext context) {
    return Column(
      children: [
        // Baris 1: Siklus Tanam (Modul 1) & Laporan Kondisi (Modul 2)
        Row(
          children: [
            Expanded(
              child: MenuCard(
                title: 'Siklus Tanam',
                subtitle: 'Rencana & fase tanam',
                icon: Icons.spa_outlined,
                isFirst: true, // Warna #E8F5E9 & teks primary
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatLaporanScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.menuGap),

        // Baris 2: Jadwal Perawatan (Modul 3) & Estimasi Panen (Modul 3)
        Row(
          children: [
            Expanded(
              child: MenuCard(
                title: 'Jadwal Perawatan',
                subtitle: 'Aktivitas jatuh tempo',
                icon: Icons.calendar_today_outlined,
                isFirst: false,
                onTap: () {
                  // WORKFLOW: Entry point → navigasi ke Daftar Jadwal Perawatan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JadwalListScreen(),
                    ),
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

        // Baris 3: Riwayat Panen (Kartu Selebar Penuh)
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
