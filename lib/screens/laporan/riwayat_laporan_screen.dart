import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/laporan_kondisi.dart';
import '../../providers/laporan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/laporan_card.dart';
import 'tambah_laporan_screen.dart';

/// Layar Riwayat Laporan Kondisi Lahan (Modul 2: FR-09, FR-10, FR-11).
/// Menampilkan statistik pemantauan, filter risiko, daftar kartu laporan, dan FAB Tambah Laporan.
class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Risiko Tinggi', 'Normal'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Laporan Kondisi Lahan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.laporanList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allList = provider.laporanList;
          final filteredList = allList.where((item) {
            if (_selectedFilter == 'Risiko Tinggi') {
              return item.isRisikoTinggi;
            } else if (_selectedFilter == 'Normal') {
              return !item.isRisikoTinggi;
            }
            return true;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Ringkasan Statistik Pemantauan (Header Metric)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricCards(allList, provider.jumlahRisikoTinggi),
                      const SizedBox(height: AppSpacing.p16),

                      // Filter Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', allList.length),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Risiko Tinggi',
                              provider.jumlahRisikoTinggi,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Normal',
                              allList.length - provider.jumlahRisikoTinggi,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Daftar Kartu Laporan Kondisi
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredList[index];
                        return LaporanCard(
                          laporan: item,
                          onTap: () => _bukaDetailLaporan(item),
                          onEdit: () => _editLaporan(item),
                          onDelete: () => _konfirmasiHapusLaporan(item),
                        );
                      },
                      childCount: filteredList.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Ruang untuk FAB
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahLaporanBaru,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text(
          'Lapor Kondisi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ─── Header Kartu Metrik ───
  Widget _buildMetricCards(List<LaporanKondisi> list, int risikoTinggi) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.p14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Laporan',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${list.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.p12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.p14),
            decoration: BoxDecoration(
              color: risikoTinggi > 0 ? const Color(0xFFFFEBEE) : Colors.white,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(
                color: risikoTinggi > 0
                    ? const Color(0xFFEF5350).withValues(alpha: 0.5)
                    : AppColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Risiko Tinggi',
                      style: TextStyle(
                        fontSize: 12,
                        color: risikoTinggi > 0
                            ? const Color(0xFFD32F2F)
                            : AppColors.textSecondary,
                        fontWeight: risikoTinggi > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (risikoTinggi > 0) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Color(0xFFD32F2F),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$risikoTinggi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: risikoTinggi > 0
                        ? const Color(0xFFD32F2F)
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int count, {Color? color}) {
    final isSelected = _selectedFilter == label;
    final activeColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: activeColor.withValues(alpha: 0.15),
      backgroundColor: Colors.white,
      checkmarkColor: activeColor,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeColor : AppColors.divider,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.chipGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            const Text(
              'Belum Ada Laporan Kondisi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tekan tombol "+ Lapor Kondisi" untuk mendokumentasikan perkembangan dan kesehatan tanaman lahan Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Aksi Navigasi ───
  Future<void> _tambahLaporanBaru() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TambahLaporanScreen()),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan kondisi lahan berhasil ditambahkan.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editLaporan(LaporanKondisi laporan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahLaporanScreen(laporanToEdit: laporan),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan kondisi berhasil diperbarui.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _bukaDetailLaporan(LaporanKondisi item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.p20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.namaLahan,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.backgroundWarnaKeparahan,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tingkatKeparahan,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.warnaKeparahan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tanggal Observasi: ${item.formattedTanggal}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Jenis Kondisi: ${item.jenisKondisi}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 24),
            const Text(
              'Catatan Lapangan:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              item.catatan,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _konfirmasiHapusLaporan(LaporanKondisi laporan) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text(
          'Laporan kondisi "${laporan.jenisKondisi}" pada "${laporan.namaLahan}" akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true && mounted) {
      final success = await context.read<LaporanProvider>().hapusLaporan(laporan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Laporan berhasil dihapus.' : 'Gagal menghapus laporan.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
          ),
        );
      }
    }
  }
}
