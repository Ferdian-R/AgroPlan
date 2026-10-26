import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/riwayat_panen.dart';
import '../../providers/panen_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'tambah_panen_screen.dart';

/// Layar Daftar & Detail Riwayat Hasil Panen (Modul 3: FR-18).
class RiwayatPanenScreen extends StatelessWidget {
  const RiwayatPanenScreen({super.key});

  void _bukaTambahPanen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahPanenScreen(),
      ),
    );
  }

  void _tampilkanDetailPanen(BuildContext context, RiwayatPanen item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detail Hasil Panen', style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
                  _buildStatusBadge(item),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Lahan', item.namaLahan),
              _buildDetailRow('Komoditas', item.komoditas),
              _buildDetailRow('Luas Lahan', '${item.luasLahan.toString().replaceAll('.', ',')} ha'),
              _buildDetailRow('Tanggal Panen', item.formattedTanggalPanen),
              _buildDetailRow('Hasil Panen Aktual', item.hasilFormatted),
              _buildDetailRow('Proyeksi Estimasi', item.estimasiFormatted),
              _buildDetailRow(
                'Performa Target',
                '${item.persentasePencapaian.toStringAsFixed(1)}% (${item.selisihTon >= 0 ? '+' : ''}${item.selisihTon.toStringAsFixed(2)} ton)',
              ),
              if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Catatan Panen:', style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(item.catatan!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static Widget _buildStatusBadge(RiwayatPanen item) {
    Color bg;
    Color fg;
    if (item.selisihTon > 0.05) {
      bg = AppColors.chipGreenBg;
      fg = AppColors.primary;
    } else if (item.selisihTon < -0.05) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
    } else {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item.statusEvaluasi,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Riwayat Panen',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Consumer<PanenProvider>(
        builder: (context, provider, _) {
          final list = provider.riwayatList;

          if (list.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: provider.loadRiwayatPanen,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                // Ringkasan Total Panen
                _buildSummaryCard(provider),
                const SizedBox(height: 16),

                Text(
                  'Daftar Hasil Panen (${list.length})',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),

                // List kartu panen
                ...list.map((item) => _buildPanenCard(context, item)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaTambahPanen(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Catat Panen'),
      ),
    );
  }

  Widget _buildSummaryCard(PanenProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Total Hasil Panen Terkumpul',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.totalHasilTon.toStringAsFixed(2)} Ton',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dari ${provider.totalPanenCount} siklus tanam yang telah diselesaikan',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPanenCard(BuildContext context, RiwayatPanen item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _tampilkanDetailPanen(context, item),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Lahan, Komoditas, Badge Evaluasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaLahan,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.komoditas} • ${item.formattedTanggalPanen}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(item),
                ],
              ),
              const Divider(height: 24),

              // Baris metrik: Aktual vs Estimasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hasil Aktual', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 3),
                      Text(
                        item.hasilFormatted,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Estimasi Target', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 3),
                      Text(
                        item.estimasiFormatted,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Pencapaian', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 3),
                      Text(
                        '${item.persentasePencapaian.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.selisihTon >= 0 ? AppColors.primary : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.chipGreenBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Belum Ada Riwayat Panen', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              'Catat hasil panen dari siklus tanam aktif untuk melihat perbandingan hasil dan riwayat produktivitas.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => _bukaTambahPanen(context),
              icon: const Icon(Icons.add),
              label: const Text('Catat Panen Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
