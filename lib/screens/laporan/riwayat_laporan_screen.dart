import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/laporan_kondisi.dart';
import '../../providers/laporan_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/laporan_card.dart';
import 'tambah_laporan_screen.dart';

/// Screen 1: Riwayat Pemantauan Kondisi Lahan (Modul 2)
/// Menampilkan daftar observasi, filter jenis kondisi, metrik, dan menerima feedback dari Screen 2.
class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Monitoring Kondisi Lahan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, _) {
          final allList = provider.laporanList;
          final filteredList = provider.filterByJenisKondisi(_selectedFilter);

          final countBermasalah = provider.jumlahBermasalah;
          final countHama = allList.where((l) => l.jenisKondisi.toLowerCase().contains('hama')).length;
          final countKering = allList.where((l) => l.jenisKondisi.toLowerCase().contains('kering')).length;
          final countBanjir = allList.where((l) => l.jenisKondisi.toLowerCase().contains('banjir')).length;
          final countNormal = allList.where((l) => l.isNormal).length;
          final countLainnya = allList.where((l) => l.jenisKondisi.toLowerCase() == 'lainnya').length;

          return RefreshIndicator(
            onRefresh: () => provider.loadDaftarLaporan(),
            color: AppColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Kartu Ringkasan Metrik
                _buildMetricCards(allList.length, countBermasalah),
                const SizedBox(height: 16),

                // Filter Chips berdasarkan Jenis Kondisi
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', allList.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Hama', countHama, const Color(0xFFD32F2F)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Kekeringan', countKering, const Color(0xFFF57C00)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Banjir', countBanjir, const Color(0xFF1976D2)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Normal', countNormal, const Color(0xFF388E3C)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Lainnya', countLainnya, const Color(0xFF7B1FA2)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // 2. Daftar Laporan
              if (filteredList.isEmpty)
                _buildEmptyState()
              else
                ...filteredList.map((item) => LaporanCard(
                      laporan: item,
                      onTap: () => _bukaDetailLaporan(item),
                      onEdit: () => _editLaporan(item),
                      onDelete: () => _konfirmasiHapusLaporan(item),
                    )),
              const SizedBox(height: 70), // Ruang untuk FAB
            ],
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahLaporanBaru,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
        label: const Text('Lapor Kondisi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ─── Header Kartu Metrik ───
  Widget _buildMetricCards(int total, int bermasalah) {
    return Row(
      children: [
        Expanded(child: _metricBox('Total Laporan', '$total', Colors.white, AppColors.textPrimary)),
        const SizedBox(width: 12),
        Expanded(
          child: _metricBox(
            'Kondisi Bermasalah',
            '$bermasalah',
            bermasalah > 0 ? const Color(0xFFFFEBEE) : Colors.white,
            bermasalah > 0 ? const Color(0xFFD32F2F) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String title, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, [Color? color]) {
    final isSelected = _selectedFilter == label;
    final activeColor = color ?? AppColors.primary;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: activeColor.withValues(alpha: 0.15),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? activeColor : AppColors.divider),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.primary),
            SizedBox(height: 12),
            Text('Belum ada laporan kondisi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 4),
            Text('Ketuk tombol di bawah untuk melaporkan kondisi tanaman.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

 
  Future<void> _tambahLaporanBaru() async {
    final resultLaporan = await Navigator.push<LaporanKondisi>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahLaporanScreen(),
      ),
    );

    // 2. RESULT YANG DIKEMBALIKAN KE SCREEN SEBELUMNYA
    if (resultLaporan != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Laporan "${resultLaporan.jenisKondisi}" pada ${resultLaporan.namaLahan} berhasil disimpan!',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editLaporan(LaporanKondisi laporan) async {
    final resultLaporan = await Navigator.push<LaporanKondisi>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahLaporanScreen(laporanToEdit: laporan),
      ),
    );

    if (resultLaporan != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan "${resultLaporan.jenisKondisi}" pada ${resultLaporan.namaLahan} berhasil diperbarui.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _bukaDetailLaporan(LaporanKondisi laporan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(laporan.iconJenisKondisi, color: laporan.warnaKondisi),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Detail Laporan - ${laporan.jenisKondisi}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    if (laporan.isBermasalah)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Perlu Penanganan',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                if (laporan.hasFoto) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: _buildFotoDetail(laporan.fotoUrl!),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text('Lahan: ${laporan.namaLahan}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text('Tanggal: ${laporan.formattedTanggal}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                const Text('Catatan Observasi:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    laporan.catatan,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFotoDetail(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  Future<void> _konfirmasiHapusLaporan(LaporanKondisi laporan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text('Laporan "${laporan.jenisKondisi}" pada ${laporan.namaLahan} akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<LaporanProvider>().hapusLaporan(laporan.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dihapus.'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
