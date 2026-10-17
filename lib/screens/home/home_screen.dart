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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              // 1. TOP HEADER (LOKASI, SEARCH BAR, NOTIFIKASI)
              // ═════════════════════════════════════════════════
              _buildTopHeader(context),

              const SizedBox(height: 16),

              // ═════════════════════════════════════════════════
              // 2. HERO BANNER (GAMBAR KEDUA "BERTANI LEBIH TERENCANA")
              // ═════════════════════════════════════════════════
              _buildHeroBanner(context),

              const SizedBox(height: 24),

              // ═════════════════════════════════════════════════
              // 3. LAYANAN & FITUR (MENU DI BAWAH GAMBAR - 4 KOLOM)
              // ═════════════════════════════════════════════════
              _buildPopularServices(context),

              const SizedBox(height: 24),

              // ═════════════════════════════════════════════════
              // 4. DAFTAR LAHAN (DI BAWAH MENU)
              // ═════════════════════════════════════════════════
              _buildLahanSection(context, daftarLahan),

              const SizedBox(height: 24),

              // ═════════════════════════════════════════════════
              // 5. HIGHLIGHT LAYANAN (SEPERTI FOOTER GAMBAR 1)
              // ═════════════════════════════════════════════════
              _buildHighlightBadges(),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. TOP HEADER (Lokasi, Profil, Search Bar)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
      child: Column(
        children: [
          // Baris 1: Lokasi & Tombol Aksi (Notifikasi & Profil)
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
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
                              fontSize: 14,
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
                    const SizedBox(height: 1),
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

          const SizedBox(height: 14),

          // Baris 2: Search Bar Modern dengan Filter
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.homeBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari lahan, jadwal, atau laporan...',
                      hintStyle: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. HERO BANNER (Gambar 2: "Bertani Lebih Terencana")
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1024 / 381,
                child: Stack(
                  children: [
                    // Gambar Banner Utama
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/banner_bertani_terencana.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Area Aksi Interaktif Tombol di atas Gambar Banner
                    // Tombol Kiri: "Tambah Lahan"
                    Positioned(
                      left: 12,
                      bottom: 12,
                      width: 135,
                      height: 40,
                      child: Material(
                        color: Colors.transparent,
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
                        ),
                      ),
                    ),

                    // Tombol Kanan: "Lihat Jadwal"
                    Positioned(
                      left: 155,
                      bottom: 12,
                      width: 135,
                      height: 40,
                      child: Material(
                        color: Colors.transparent,
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Dots Indicator seperti Gambar 1
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8D6CE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8D6CE),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. LAYANAN & FITUR (Menu di bawah gambar - 4 Kolom x 2 Baris)
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

          // Grid 4 Kolom x 2 Baris
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

          const SizedBox(height: 14),

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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4), // Hijau pastel sangat lembut
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
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    final String imageAsset = isPadi ? 'assets/images/lahan_padi.webp' : 'assets/images/lahan_jagung.webp';

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
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.chipGreenBg,
                          child: const Icon(Icons.yard, color: AppColors.primary, size: 36),
                        ),
                      ),
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

  // ─────────────────────────────────────────────────────────────
  // 5. HIGHLIGHT LAYANAN (Seperti Bagian Bawah Gambar 1)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHighlightBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHighlightItem(Icons.verified_outlined, 'Manajemen\nTerpadu'),
            _buildHighlightItem(Icons.alarm_on_outlined, 'Pengingat\nOtomatis'),
            _buildHighlightItem(Icons.bolt_outlined, 'Kalkulasi\nCepat'),
            _buildHighlightItem(Icons.insights_outlined, 'Evaluasi\nPanen'),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.cardSubtitle.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Bottom sheet menampilkan semua menu
  void _showAllServicesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
              Text(
                'Semua Fitur AgroPlan',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  _buildServiceItem(
                    title: 'Siklus Tanam',
                    icon: Icons.spa_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToPlaceholder(context, title: 'Siklus Tanam');
                    },
                  ),
                  _buildServiceItem(
                    title: 'Laporan',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RiwayatLaporanScreen()));
                    },
                  ),
                  _buildServiceItem(
                    title: 'Jadwal',
                    icon: Icons.calendar_month_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const JadwalListScreen()));
                    },
                  ),
                  _buildServiceItem(
                    title: 'Estimasi',
                    icon: Icons.trending_up_rounded,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EstimasiPanenScreen()));
                    },
                  ),
                  _buildServiceItem(
                    title: 'Riwayat Panen',
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToPlaceholder(context, title: 'Riwayat Panen');
                    },
                  ),
                  _buildServiceItem(
                    title: 'Tambah Lahan',
                    icon: Icons.add_location_alt_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TambahLahanScreen()));
                    },
                  ),
                  _buildServiceItem(
                    title: 'Daftar Lahan',
                    icon: Icons.grid_view_rounded,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const DaftarLahanScreen()));
                    },
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
