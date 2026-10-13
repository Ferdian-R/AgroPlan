import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/jadwal_perawatan.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/perawatan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/jadwal_success_dialog.dart';
import 'tambah_jadwal_screen.dart';
import 'estimasi_panen_screen.dart';

/// Layar Daftar Jadwal Perawatan (Modul 3: FR-13, FR-14, FR-15).
///
/// Workflow Lengkap:
/// - Create: Tap FAB "+" → Form → Dialog Sukses → Muncul di List.
/// - Read: Empty state jika belum ada, List Card jika sudah ada.
/// - Update Status: Tap tombol status → Pilih Belum/Selesai/Ditunda (FR-15).
/// - Update Data: Tap kartu / icon edit → Form edit → Simpan.
/// - Delete: Tap icon hapus → Konfirmasi dialog → Terhapus.
/// - Estimasi Panen: Navigasi ke layar estimasi panen (FR-16).
class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  // Filter status aktif
  String _filterStatus = 'Semua'; // 'Semua', 'Belum', 'Selesai', 'Ditunda'

  @override
  void initState() {
    super.initState();
    // Generate jadwal otomatis dari lahan yang sudah ada jika belum ada jadwal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateJadwalDariLahanYangAda();
    });
  }

  /// Generate jadwal otomatis dari lahan-lahan yang sudah terdaftar (FR-13).
  /// Ini memastikan saat masuk ke halaman jadwal, jadwal sudah ter-generate
  /// berdasarkan komoditas dan tanggal tanam lahan.
  void _generateJadwalDariLahanYangAda() {
    final perawatanProvider = context.read<PerawatanProvider>();
    final lahanProvider = context.read<LahanProvider>();

    // Hanya generate jika belum ada jadwal sama sekali
    if (perawatanProvider.jadwalList.isNotEmpty) return;

    for (final lahan in lahanProvider.lahanList) {
      // Gunakan tanggal dibuat lahan sebagai tanggal tanam (PRD: tanggal acuan)
      final tanggalTanam = lahan.tanggalDibuat ?? DateTime.now();
      perawatanProvider.generateJadwalOtomatis(
        lahan: lahan,
        komoditas: lahan.komoditasUtama,
        tanggalTanam: tanggalTanam,
      );
    }
  }

  /// INPUT/EVENT: User tap FAB "+" untuk tambah jadwal baru
  Future<void> _bukaTambahJadwal() async {
    final lahanProvider = context.read<LahanProvider>();
    if (lahanProvider.lahanList.isEmpty) {
      await lahanProvider.loadDaftarLahan();
    }
    if (!mounted) return;
    final daftarLahan = lahanProvider.lahanList;

    final result = await Navigator.push<JadwalPerawatan>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalScreen(daftarLahan: daftarLahan),
      ),
    );

    if (!mounted || result == null) return;

    context.read<PerawatanProvider>().tambahJadwal(result);

    if (!mounted) return;
    await JadwalSuccessDialog.show(
      context,
      title: 'Jadwal perawatan\nberhasil ditambahkan!',
      subtitle:
          'Jadwal perawatan tanaman telah disimpan dan akan muncul pada daftar jadwal Anda.',
    );
  }

  /// INPUT/EVENT: User tap icon edit / kartu jadwal untuk update
  Future<void> _bukaEditJadwal(JadwalPerawatan jadwal) async {
    final lahanProvider = context.read<LahanProvider>();
    if (lahanProvider.lahanList.isEmpty) {
      await lahanProvider.loadDaftarLahan();
    }
    if (!mounted) return;
    final daftarLahan = lahanProvider.lahanList;

    final result = await Navigator.push<JadwalPerawatan>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalScreen(
          daftarLahan: daftarLahan,
          jadwalToEdit: jadwal,
        ),
      ),
    );

    if (!mounted || result == null) return;

    context.read<PerawatanProvider>().updateJadwal(result);

    if (!mounted) return;
    await JadwalSuccessDialog.show(
      context,
      title: 'Jadwal perawatan\nberhasil diperbarui!',
      subtitle:
          'Perubahan jadwal perawatan tanaman telah disimpan dan diperbarui pada daftar jadwal Anda.',
    );
  }

  /// INPUT/EVENT: User tap icon hapus untuk delete
  Future<void> _konfirmasiHapus(JadwalPerawatan jadwal) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Hapus Jadwal?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${jadwal.namaKegiatan}"?',
          style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      if (!mounted) return;
      context.read<PerawatanProvider>().hapusJadwal(jadwal.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Jadwal "${jadwal.namaKegiatan}" berhasil dihapus'),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
        ),
      );
    }
  }

  /// FR-15: Tampilkan bottom sheet untuk update status pelaksanaan
  Future<void> _ubahStatusPelaksanaan(JadwalPerawatan jadwal) async {
    final provider = context.read<PerawatanProvider>();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
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
                  'Perbarui Status Pelaksanaan',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  jadwal.namaKegiatan,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Status: Belum
                _buildStatusOption(
                  icon: Icons.schedule_outlined,
                  label: 'Belum',
                  subtitle: 'Kegiatan belum dilaksanakan',
                  color: const Color(0xFF757575),
                  isSelected: jadwal.status == StatusPelaksanaan.belum,
                  onTap: () {
                    provider.tandaiBelum(jadwal.id);
                    Navigator.pop(ctx);
                    _showStatusSnackBar('Belum');
                  },
                ),
                const SizedBox(height: 8),

                // Status: Selesai
                _buildStatusOption(
                  icon: Icons.check_circle_outline,
                  label: 'Selesai',
                  subtitle: 'Kegiatan sudah dilakukan',
                  color: const Color(0xFF2E7D32),
                  isSelected: jadwal.status == StatusPelaksanaan.selesai,
                  onTap: () {
                    provider.tandaiSelesai(jadwal.id);
                    Navigator.pop(ctx);
                    _showStatusSnackBar('Selesai');
                  },
                ),
                const SizedBox(height: 8),

                // Status: Ditunda
                _buildStatusOption(
                  icon: Icons.update_outlined,
                  label: 'Ditunda',
                  subtitle: 'Tunda ke tanggal baru',
                  color: const Color(0xFFE65100),
                  isSelected: jadwal.status == StatusPelaksanaan.ditunda,
                  onTap: () async {
                    Navigator.pop(ctx);
                    // Pilih tanggal tunda baru
                    await _pilihTanggalTunda(jadwal);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pilih tanggal tunda baru (bagian dari FR-15: Ditunda)
  Future<void> _pilihTanggalTunda(JadwalPerawatan jadwal) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Pilih Tanggal Tunda Baru',
      cancelText: 'Batal',
      confirmText: 'Tunda',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<PerawatanProvider>().tandaiDitunda(jadwal.id, picked);
      _showStatusSnackBar('Ditunda');
    }
  }

  void _showStatusSnackBar(String status) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status diperbarui menjadi "$status"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryNav,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style:
                          AppTextStyles.cardSubtitle.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Jadwal Perawatan',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          // Tombol navigasi ke Estimasi Panen (FR-16)
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded,
                color: AppColors.primary, size: 24),
            tooltip: 'Estimasi Panen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EstimasiPanenScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PerawatanProvider>(
        builder: (context, provider, _) {
          if (provider.jadwalList.isEmpty) {
            return _buildEmptyView();
          }
          return _buildContentView(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaTambahJadwal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
    );
  }

  /// Konten utama: ringkasan status + filter + list jadwal
  Widget _buildContentView(PerawatanProvider provider) {
    // Terapkan filter
    final List<JadwalPerawatan> filteredList;
    if (_filterStatus == 'Belum') {
      filteredList = provider.jadwalDenganStatus(StatusPelaksanaan.belum);
    } else if (_filterStatus == 'Selesai') {
      filteredList = provider.jadwalDenganStatus(StatusPelaksanaan.selesai);
    } else if (_filterStatus == 'Ditunda') {
      filteredList = provider.jadwalDenganStatus(StatusPelaksanaan.ditunda);
    } else {
      filteredList = provider.jadwalList;
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Ringkasan statistik status
        SliverToBoxAdapter(
          child: _buildStatistikHeader(provider),
        ),

        // 2. Filter chip bar
        SliverToBoxAdapter(
          child: _buildFilterBar(provider),
        ),

        // 3. Daftar jadwal
        if (filteredList.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'Tidak ada jadwal dengan status "$_filterStatus"',
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              100, // ruang untuk FAB
            ),
            sliver: SliverList.separated(
              itemCount: filteredList.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.p12),
              itemBuilder: (context, index) {
                return _buildJadwalCard(filteredList[index]);
              },
            ),
          ),
      ],
    );
  }

  /// Ringkasan jumlah jadwal per status
  Widget _buildStatistikHeader(PerawatanProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.p16,
        AppSpacing.screenPadding,
        AppSpacing.p8,
      ),
      child: Row(
        children: [
          _buildStatCard(
            'Total',
            provider.jadwalList.length.toString(),
            AppColors.primary,
            Icons.calendar_today_outlined,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Belum',
            provider.jumlahBelum.toString(),
            const Color(0xFF757575),
            Icons.schedule_outlined,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Selesai',
            provider.jumlahSelesai.toString(),
            const Color(0xFF2E7D32),
            Icons.check_circle_outline,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Ditunda',
            provider.jumlahDitunda.toString(),
            const Color(0xFFE65100),
            Icons.update_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter chip bar
  Widget _buildFilterBar(PerawatanProvider provider) {
    final filters = ['Semua', 'Belum', 'Selesai', 'Ditunda'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.p8,
        AppSpacing.screenPadding,
        AppSpacing.p12,
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = _filterStatus == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(f),
              labelStyle: AppTextStyles.chipText.copyWith(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _filterStatus = f);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Tampilan saat belum ada jadwal
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.chipGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Belum Ada Jadwal',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.p8),
            Text(
              'Tekan tombol "+ Tambah Jadwal" untuk\nmenambah jadwal perawatan lahan Anda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu jadwal perawatan individual
  Widget _buildJadwalCard(JadwalPerawatan jadwal) {
    final statusColor = switch (jadwal.status) {
      StatusPelaksanaan.belum => const Color(0xFF757575),
      StatusPelaksanaan.selesai => const Color(0xFF2E7D32),
      StatusPelaksanaan.ditunda => const Color(0xFFE65100),
    };

    final statusBgColor = switch (jadwal.status) {
      StatusPelaksanaan.belum => const Color(0xFFF5F5F5),
      StatusPelaksanaan.selesai => const Color(0xFFE8F5E9),
      StatusPelaksanaan.ditunda => const Color(0xFFFFF3E0),
    };

    final statusIcon = switch (jadwal.status) {
      StatusPelaksanaan.belum => Icons.schedule_outlined,
      StatusPelaksanaan.selesai => Icons.check_circle_outline,
      StatusPelaksanaan.ditunda => Icons.update_outlined,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: jadwal.isJatuhTempo && jadwal.status == StatusPelaksanaan.belum
            ? Border.all(color: AppColors.error.withValues(alpha: 0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.roundedCard,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: () => _bukaEditJadwal(jadwal),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ikon jenis perawatan
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.chipGreenBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard),
                      ),
                      child: Center(
                        child: Text(
                          jadwal.jenisIcon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),

                    // Info jadwal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal.namaKegiatan,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              decoration:
                                  jadwal.status == StatusPelaksanaan.selesai
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${jadwal.namaLahan} • ${jadwal.jenisPerawatan}',
                            style: AppTextStyles.cardSubtitle
                                .copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),

                    // Tombol status (FR-15: tap untuk ubah)
                    GestureDetector(
                      onTap: () => _ubahStatusPelaksanaan(jadwal),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.status.label,
                              style: AppTextStyles.chipText.copyWith(
                                fontSize: 11,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p8),

                // Baris info tanggal dan aksi
                Row(
                  children: [
                    // Tanggal pelaksanaan
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      jadwal.tanggalFormatted,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 11.5,
                        decoration: jadwal.status == StatusPelaksanaan.ditunda
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    // Tanggal tunda (jika ada)
                    if (jadwal.status == StatusPelaksanaan.ditunda &&
                        jadwal.tanggalDitundaFormatted != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward,
                          size: 12, color: Color(0xFFE65100)),
                      const SizedBox(width: 4),
                      Text(
                        jadwal.tanggalDitundaFormatted!,
                        style: AppTextStyles.chipText.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],

                    // HST info (jika jadwal otomatis)
                    if (jadwal.hstPengingat != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.chipGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${jadwal.hstPengingat} HST',
                          style: AppTextStyles.chipText.copyWith(
                            fontSize: 10,
                            color: AppColors.chipGreenText,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Tombol aksi: Edit & Hapus
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        tooltip: 'Edit Jadwal',
                        onPressed: () => _bukaEditJadwal(jadwal),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        tooltip: 'Hapus Jadwal',
                        onPressed: () => _konfirmasiHapus(jadwal),
                      ),
                    ),
                  ],
                ),

                // Catatan (jika ada)
                if (jadwal.catatan != null &&
                    jadwal.catatan!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.p6),
                  Text(
                    'Catatan: ${jadwal.catatan}',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Waktu sumber info (jika jadwal otomatis)
                if (jadwal.isOtomatis && jadwal.waktuSumber != null) ...[
                  const SizedBox(height: AppSpacing.p4),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Sumber: ${jadwal.waktuSumber}',
                        style: AppTextStyles.cardSubtitle
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],

                // Badge jatuh tempo
                if (jadwal.isJatuhTempo &&
                    jadwal.status == StatusPelaksanaan.belum) ...[
                  const SizedBox(height: AppSpacing.p6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 13, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Sudah jatuh tempo!',
                          style: AppTextStyles.chipText.copyWith(
                            fontSize: 10.5,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
