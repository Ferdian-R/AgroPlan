import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lahan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../placeholder_screen.dart';
import '../perawatan/estimasi_panen_screen.dart';
import '../perawatan/jadwal_list_screen.dart';
import '../lahan/tambah_lahan_screen.dart';
import '../lahan/daftar_lahan_screen.dart';
import '../laporan/riwayat_laporan_screen.dart';

/// Layar Beranda (Home Screen) AgroPlan modern dengan tata letak:
/// 1. Top Header: Lokasi pertanian, Search bar, Notifikasi & Profil.
/// 2. Hero Banner: Banner ilustratif "Bertani Lebih Terencana" dengan tombol aksi interaktif.
/// 3. Layanan & Fitur (Menu Utama): Grid 8 menu berikon bergaya modern.
/// 4. Lahan Pertanian: Daftar kartu lahan rekomendasi horizontal scroll dengan foto & badge.
/// 5. Highlight Layanan di bagian bawah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Navigasi ke halaman placeholder untuk fitur lanjutan
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

  /// Dialog opsi manajemen lahan (edit/hapus)
  void _showLandOptions(BuildContext context, Lahan lahan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.p16,
          ),
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
                  final success =
                      await context.read<LahanProvider>().hapusLahan(lahan.idLahan);
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

  @override
  Widget build(BuildContext context) {
    final lahanProvider = context.watch<LahanProvider>();
    final daftarLahan = lahanProvider.lahanList;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═════════════════════════════════════════════════
              // 1. TOP HEADER (LOKASI, NOTIFIKASI, PROFIL)
              // ═════════════════════════════════════════════════
              _buildTopHeader(context),

              const SizedBox(height: 16),

              // ═════════════════════════════════════════════════
              // 2. HERO BANNER ("BERTANI LEBIH TERENCANA")
              // ═════════════════════════════════════════════════
              _buildHeroBanner(context),

              const SizedBox(height: 22),

              // ═════════════════════════════════════════════════
              // 3. LAYANAN & FITUR (MENU 4 KOLOM X 2 BARIS)
              // ═════════════════════════════════════════════════
              _buildPopularServices(context),

              const SizedBox(height: 24),

              // ═════════════════════════════════════════════════
              // 4. DAFTAR LAHAN (DI BAWAH MENU)
              // ═════════════════════════════════════════════════
              _buildLahanSection(context, daftarLahan),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. TOP HEADER (Lokasi, Notifikasi, Profil - Tanpa Search Bar)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.chipGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Padang Pariaman, Sumbar',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokasi pertanian aktif • 28°C Cerah',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Notifikasi dengan titik merah
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.homeBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    _navigateToPlaceholder(
                      context,
                      title: 'Pusat Notifikasi',
                      subtitle:
                          'Pengingat jadwal perawatan, status tanam, dan peringatan dini kondisi lahan.',
                      icon: Icons.notifications_active_outlined,
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Avatar Profil
          GestureDetector(
            onTap: () {
              _navigateToPlaceholder(
                context,
                title: 'Profil Petani',
                subtitle: 'Pengaturan akun, kontak, dan preferensi aplikasi.',
                icon: Icons.person_outline,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. HERO BANNER (Gambar 1 Bersih + Teks, Tombol, Gradasi Manual)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 178,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar Ilustrasi Bersih (Gambar 1)
              Image.asset(
                'assets/images/banner_petani_clean.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),

              // Gradasi Hijau Gelap Manual di Kiri
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.44, 0.66, 0.90],
                      colors: [
                        const Color(0xFF14452F).withValues(alpha: 0.97),
                        const Color(0xFF14452F).withValues(alpha: 0.88),
                        const Color(0xFF14452F).withValues(alpha: 0.48),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Konten Manual: Teks, Ceklis, dan Tombol Interaktif
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Subtitle & Judul Utama
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kelola lahan dengan lebih mudah',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Bertani Lebih\nTerencana.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),

                      // Poin Ceklis
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBannerCheckItem('Catat lahan dan siklus tanam'),
                          const SizedBox(height: 3),
                          _buildBannerCheckItem('Pantau kondisi dan pengingat'),
                        ],
                      ),

                      // Tombol Aksi Manual
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            // Tombol 1: Tambah Lahan (Tombol Putih)
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TambahLahanScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.spa_rounded,
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tambah Lahan',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 7),

                            // Tombol 2: Lihat Jadwal (Tombol Kaca / Outlined)
                            Material(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const JadwalListScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      width: 1.1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lihat Jadwal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildBannerCheckItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: const BoxDecoration(
            color: Color(0xFF68D391),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 9,
              color: Color(0xFF14452F),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. LAYANAN & FITUR (Menu 4 Kolom x 2 Baris - Jarak Simetris)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPopularServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Layanan & Fitur',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => _showAllServicesModal(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'Semua',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Baris 1: 4 Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildServiceItem(
                  title: 'Siklus Tanam',
                  icon: Icons.spa_outlined,
                  onTap: () {
                    _navigateToPlaceholder(
                      context,
                      title: 'Siklus Tanam',
                      subtitle: 'Perencanaan siklus tanam baru dan pengingat jadwal tanam.',
                      icon: Icons.spa_outlined,
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildServiceItem(
                  title: 'Laporan',
                  icon: Icons.assignment_outlined,
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
              Expanded(
                child: _buildServiceItem(
                  title: 'Jadwal',
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JadwalListScreen(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildServiceItem(
                  title: 'Estimasi',
                  icon: Icons.trending_up_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EstimasiPanenScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Baris 2: 4 Menu (Sejajar sempurna dengan Baris 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildServiceItem(
                  title: 'Riwayat Panen',
                  icon: Icons.inventory_2_outlined,
                  onTap: () {
                    _navigateToPlaceholder(
                      context,
                      title: 'Riwayat Panen',
                      subtitle: 'Pencatatan data hasil panen aktual dan evaluasi produktivitas.',
                      icon: Icons.inventory_2_outlined,
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildServiceItem(
                  title: 'Tambah Lahan',
                  icon: Icons.add_location_alt_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TambahLahanScreen(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildServiceItem(
                  title: 'Pantau Hama',
                  icon: Icons.bug_report_outlined,
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
              Expanded(
                child: _buildServiceItem(
                  title: 'Daftar Lahan',
                  icon: Icons.grid_view_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DaftarLahanScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. DAFTAR LAHAN (Di bawah Menu - Modern Card Layout)
  // ─────────────────────────────────────────────────────────────
  Widget _buildLahanSection(BuildContext context, List<Lahan> daftarLahan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lahan Pertanian Anda',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DaftarLahanScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'Lihat semua',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (daftarLahan.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.yard_outlined, size: 40, color: AppColors.iconMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada data lahan',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tekan tombol di bawah untuk menambahkan lahan baru Anda.',
                      style: AppTextStyles.cardSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TambahLahanScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Lahan Sekarang'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          // Horizontal listview of modern cards seperti Gambar 1 ("Recommended for you")
          SizedBox(
            height: 245,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: daftarLahan.length + 1, // +1 untuk kartu Tambah Lahan di akhir
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == daftarLahan.length) {
                  // Kartu "+ Tambah Lahan Baru" di akhir scroll
                  return _buildAddLahanCard(context);
                }
                return _buildModernLandCard(context, daftarLahan[index]);
              },
            ),
          ),
      ],
    );
  }

  /// Kartu Lahan Modern dengan foto, badge, status, dan tombol aksi
  Widget _buildModernLandCard(BuildContext context, Lahan lahan) {
    final bool isPadi = lahan.komoditasUtama.toLowerCase().contains('padi');
    final String imageAsset = (lahan.fotoUrl != null && lahan.fotoUrl!.isNotEmpty)
        ? lahan.fotoUrl!
        : (isPadi ? 'assets/images/lahan_padi.webp' : 'assets/images/lahan_jagung.webp');

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TambahLahanScreen(lahanToEdit: lahan),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Lahan dengan Badge Komoditas & Tombol Titik Tiga
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: _buildCardImage(imageAsset),
                    ),
                  ),

                  // Badge Komoditas & Luas
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        lahan.chipText,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // Menu Titik Tiga
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => _showLandOptions(context, lahan),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Detail Info Lahan
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lahan.namaLahan,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            lahan.lokasi ?? 'Lokasi Lahan',
                            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tombol Aksi "Lihat Jadwal"
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JadwalListScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lihat Jadwal',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu Tambah Lahan Cepat di Akhir Scroll
  Widget _buildAddLahanCard(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TambahLahanScreen(),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tambah\nLahan Baru',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCardImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.chipGreenBg,
          child: const Icon(Icons.yard, color: AppColors.primary, size: 36),
        ),
      );
    }
    if (kIsWeb ||
        path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.chipGreenBg,
          child: const Icon(Icons.yard, color: AppColors.primary, size: 36),
        ),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.chipGreenBg,
        child: const Icon(Icons.yard, color: AppColors.primary, size: 36),
      ),
    );
  }

  /// Bottom sheet menampilkan semua menu
  void _showAllServicesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semua Fitur AgroPlan',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Baris 1: 4 Layanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Siklus Tanam',
                      icon: Icons.spa_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToPlaceholder(
                          context,
                          title: 'Siklus Tanam',
                          subtitle: 'Perencanaan siklus tanam baru dan pengingat jadwal tanam.',
                          icon: Icons.spa_outlined,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Laporan',
                      icon: Icons.assignment_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RiwayatLaporanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Jadwal',
                      icon: Icons.calendar_month_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JadwalListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Estimasi',
                      icon: Icons.trending_up_rounded,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EstimasiPanenScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Baris 2: 4 Layanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Riwayat Panen',
                      icon: Icons.inventory_2_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToPlaceholder(
                          context,
                          title: 'Riwayat Panen',
                          subtitle: 'Pencatatan data hasil panen aktual dan evaluasi produktivitas.',
                          icon: Icons.inventory_2_outlined,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Tambah Lahan',
                      icon: Icons.add_location_alt_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TambahLahanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Pantau Hama',
                      icon: Icons.bug_report_outlined,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RiwayatLaporanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceItem(
                      title: 'Daftar Lahan',
                      icon: Icons.grid_view_rounded,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DaftarLahanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
