import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lahan.dart';
import '../../models/siklus_tanam.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/perawatan_provider.dart';
import '../../providers/siklus_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../perawatan/jadwal_list_screen.dart';
import 'tambah_lahan_screen.dart';
import 'tambah_siklus_screen.dart';

/// Layar Detail Data Lahan (Modul 1: FR-02).
///
/// Menampilkan:
/// - Informasi lengkap profil lahan (nama, luas ha, lokasi, foto, tanggal dibuat)
/// - Status siklus tanam aktif saat ini di lahan tersebut
/// - Akses untuk Memulai Siklus Tanam Baru (FR-05)
/// - Akses untuk Mengubah Data Lahan (FR-03)
/// - Akses untuk Menghapus Lahan (FR-04)
class DetailLahanScreen extends StatelessWidget {
  final Lahan lahan;

  const DetailLahanScreen({super.key, required this.lahan});

  Future<void> _bukaEdit(BuildContext context, Lahan currentLahan) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahLahanScreen(lahanToEdit: currentLahan),
      ),
    );
    if (updated == true && context.mounted) {
      // Data diperbarui di LahanProvider
    }
  }

  Future<void> _konfirmasiHapus(BuildContext context, Lahan currentLahan) async {
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
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Hapus Lahan?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${currentLahan.namaLahan}"? Seluruh data riwayat siklus tanam dan jadwal terkait juga akan terhapus.',
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

    if (konfirmasi == true && context.mounted) {
      final success = await context.read<LahanProvider>().hapusLahan(currentLahan.idLahan);
      if (context.mounted && success) {
        Navigator.pop(context); // Kembali ke daftar lahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lahan "${currentLahan.namaLahan}" berhasil dihapus'),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// FR-13: Mengubah tanggal tanam siklus aktif & menyesuaikan jadwal perawatan yang belum selesai
  Future<void> _ubahTanggalTanam(BuildContext context, SiklusTanam siklus) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: siklus.tanggalRencanaTanam,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Tanggal Tanam Baru',
      confirmText: 'Simpan',
      cancelText: 'Batal',
    );

    if (picked != null && context.mounted) {
      final siklusProvider = context.read<SiklusProvider>();
      final perawatanProvider = context.read<PerawatanProvider>();

      final success = await siklusProvider.updateTanggalTanam(
        idSiklus: siklus.idSiklus,
        idLahan: siklus.idLahan,
        tanggalBaru: picked,
        perawatanProvider: perawatanProvider,
        komoditas: siklus.komoditas,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tanggal tanam ${siklus.komoditas} diubah ke ${picked.day}/${picked.month}/${picked.year}. Jadwal yang belum selesai telah disesuaikan otomatis (FR-13).',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Menandai siklus tanam sebagai selesai (panen)
  Future<void> _konfirmasiSelesaikanSiklus(
    BuildContext context,
    SiklusTanam siklus,
  ) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Siklus Tanam'),
        content: Text(
          'Tandai siklus tanam ${siklus.komoditas} sebagai selesai (panen)? Siklus ini akan dipindahkan ke riwayat siklus tanam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );

    if (setuju == true && context.mounted) {
      final success =
          await context.read<SiklusProvider>().selesaikanSiklus(siklus.idSiklus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Siklus tanam ${siklus.komoditas} berhasil diselesaikan.'
                  : 'Gagal menyelesaikan siklus.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data lahan terbaru dari provider
    final lahanProvider = context.watch<LahanProvider>();
    final currentLahan = lahanProvider.lahanList.firstWhere(
      (l) => l.idLahan == lahan.idLahan,
      orElse: () => lahan,
    );

    final siklusProvider = context.watch<SiklusProvider>();
    final siklusAktifList = siklusProvider.getDaftarSiklusAktif(currentLahan.idLahan);
    final riwayatSiklus = siklusProvider.getSiklusByLahan(currentLahan.idLahan);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Detail Lahan',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Ubah Data Lahan (FR-03)',
            onPressed: () => _bukaEdit(context, currentLahan),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Lahan (FR-04)',
            onPressed: () => _konfirmasiHapus(context, currentLahan),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════ 1. FOTO LAHAN ═══════
            ClipRRect(
              borderRadius: AppSpacing.roundedCard,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildPhotoHeader(currentLahan.fotoUrl),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),

            // ═══════ 2. KARTU INFORMASI UTAMA LAHAN ═══════
            Container(
              padding: const EdgeInsets.all(AppSpacing.p16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppSpacing.roundedCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentLahan.namaLahan,
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentLahan.luasFormatted,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),

                  // Detail atribut
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Lokasi Lahan',
                    currentLahan.lokasi ?? 'Lokasi belum diatur',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.square_foot_outlined,
                    'Luas Area',
                    '${currentLahan.luasLahan} Hektare (ha)',
                  ),
                  if (currentLahan.tanggalDibuat != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.event_outlined,
                      'Terdaftar Sejak',
                      '${currentLahan.tanggalDibuat!.day}/${currentLahan.tanggalDibuat!.month}/${currentLahan.tanggalDibuat!.year}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.p20),

            // ═══════ 3. SIKLUS TANAM AKTIF (FR-05) ═══════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Siklus Tanam Aktif',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                    ),
                    if (siklusAktifList.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${siklusAktifList.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Tombol Tambah Siklus selalu tersedia untuk menambahkan komoditas lain di lahan yang sama
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TambahSiklusScreen(lahanTerpilih: currentLahan),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(siklusAktifList.isEmpty ? 'Mulai Siklus' : 'Tambah Siklus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p10),

            if (siklusAktifList.isNotEmpty)
              // Daftar seluruh siklus aktif pada lahan ini
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: siklusAktifList.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.p12),
                itemBuilder: (context, index) {
                  final s = siklusAktifList[index];
                  return _buildSiklusAktifCard(context, s);
                },
              )
            else
              // Tampilan kosong jika belum ada siklus aktif
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.p20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 36,
                      color: AppColors.iconMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum Ada Siklus Tanam Aktif',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih salah satu dari 6 komoditas dan tanggal tanam untuk membuat siklus serta jadwal perawatan otomatis.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.p24),

            // ═══════ 4. RIWAYAT SIKLUS TANAM LAHAN ═══════
            Text(
              'Riwayat Siklus Tanam (${riwayatSiklus.length})',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.p10),

            if (riwayatSiklus.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada riwayat siklus tanam pada lahan ini.',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayatSiklus.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final s = riwayatSiklus[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.p12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          s.isBerjalan ? Icons.play_circle_outline : Icons.check_circle_outline,
                          color: s.isBerjalan ? AppColors.primary : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.komoditas,
                                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                              ),
                              Text(
                                'Mulai: ${s.formattedTanggalTanam}',
                                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: s.isBerjalan ? AppColors.chipGreenBg : AppColors.chipGreyBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.statusSiklus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: s.isBerjalan ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildSiklusAktifCard(BuildContext context, SiklusTanam siklusAktif) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siklusAktif.komoditas,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Mulai: ${siklusAktif.formattedTanggalTanam}',
                        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${siklusAktif.hst} HST',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (siklusAktif.catatan != null && siklusAktif.catatan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Catatan: ${siklusAktif.catatan}',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _ubahTanggalTanam(context, siklusAktif),
                  icon: const Icon(Icons.edit_calendar_outlined, size: 15),
                  label: const Text('Ubah Tanggal', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JadwalListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined, size: 16),
                  label: const Text('Jadwal Perawatan', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _konfirmasiSelesaikanSiklus(context, siklusAktif),
                tooltip: 'Selesaikan Siklus (Panen)',
                icon: const Icon(Icons.check_circle_outline, color: AppColors.textSecondary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11.5),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoHeader(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: AppColors.chipGreenBg,
        child: const Center(
          child: Icon(Icons.landscape, size: 48, color: AppColors.primary),
        ),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    if (kIsWeb || path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }
}
