import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/jadwal_perawatan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/jadwal_success_dialog.dart';
import 'tambah_jadwal_screen.dart';

/// Layar Daftar Jadwal Perawatan (Modul 3: FR-13 & FR-19).
///
/// Workflow Lengkap:
/// - Create: Tap FAB "+" → Form → Dialog Sukses Gambar 2 → Muncul di List.
/// - Read: Empty state jika belum ada, List Card jika sudah ada.
/// - Update: Tap kartu / icon edit → Form edit terisi data → Simpan → Dialog Sukses Update.
/// - Delete: Tap icon hapus → Konfirmasi dialog → Terhapus dari state list.
class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  // STATE: Daftar jadwal perawatan yang tersimpan
  final List<JadwalPerawatan> _jadwalList = [];

  /// INPUT/EVENT: User tap FAB "+" untuk tambah jadwal baru
  Future<void> _bukaTambahJadwal() async {
    // Ambil daftar lahan dari LahanProvider untuk dropdown di form
    final lahanProvider = context.read<LahanProvider>();
    if (lahanProvider.lahanList.isEmpty) {
      await lahanProvider.loadDaftarLahan();
    }
    if (!mounted) return;
    final daftarLahan = lahanProvider.lahanList;

    // Navigasi ke form dan TUNGGU hasilnya
    final result = await Navigator.push<JadwalPerawatan>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalScreen(daftarLahan: daftarLahan),
      ),
    );

    // Jika user batal (tap back), result = null
    if (!mounted || result == null) return;

    // STATE: Tambah jadwal baru ke list
    setState(() {
      _jadwalList.add(result);
    });

    // FEEDBACK: Tampilkan modal dialog sukses persis seperti di Gambar 2
    if (!mounted) return;
    await JadwalSuccessDialog.show(
      context,
      title: 'Jadwal perawatan\nberhasil ditambahkan!',
      subtitle: 'Jadwal perawatan tanaman telah disimpan dan akan muncul pada daftar jadwal Anda.',
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

    // Navigasi ke form dengan membawa data lama
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

    // STATE: Cari index dan perbarui data di list
    final index = _jadwalList.indexWhere((item) => item.id == result.id);
    if (index != -1) {
      setState(() {
        _jadwalList[index] = result;
      });

      // FEEDBACK: Tampilkan modal dialog sukses pembaruan
      if (!mounted) return;
      await JadwalSuccessDialog.show(
        context,
        title: 'Jadwal perawatan\nberhasil diperbarui!',
        subtitle: 'Perubahan jadwal perawatan tanaman telah disimpan dan diperbarui pada daftar jadwal Anda.',
      );
    }
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
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
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
      setState(() {
        _jadwalList.removeWhere((item) => item.id == jadwal.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Jadwal "${jadwal.namaKegiatan}" berhasil dihapus'),
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
      ),
      // NAVIGATION/RESULT: Tampilan berubah sesuai ada/tidaknya data
      body: _jadwalList.isEmpty ? _buildEmptyView() : _buildListView(),
      // INPUT/EVENT: FAB untuk memulai workflow tambah jadwal
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaTambahJadwal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
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
            // Ikon besar
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

  /// Tampilan list jadwal perawatan
  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.p16,
        AppSpacing.screenPadding,
        100, // ruang untuk FAB
      ),
      itemCount: _jadwalList.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.p12),
      itemBuilder: (context, index) {
        final jadwal = _jadwalList[index];
        return _buildJadwalCard(jadwal);
      },
    );
  }

  /// Kartu jadwal perawatan individual dengan tombol Edit dan Hapus
  Widget _buildJadwalCard(JadwalPerawatan jadwal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
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
            child: Row(
              children: [
                // Ikon jenis perawatan
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.chipGreenBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Center(
                    child: Text(
                      jadwal.jenisIcon,
                      style: const TextStyle(fontSize: 24),
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
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.p4),
                      Text(
                        '${jadwal.jenisPerawatan} • ${jadwal.namaLahan}',
                        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.p2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jadwal.tanggalFormatted,
                            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      if (jadwal.catatan != null && jadwal.catatan!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.p4),
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
                    ],
                  ),
                ),

                // Tombol Aksi: Edit & Hapus
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                      tooltip: 'Edit Jadwal',
                      onPressed: () => _bukaEditJadwal(jadwal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      tooltip: 'Hapus Jadwal',
                      onPressed: () => _konfirmasiHapus(jadwal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
