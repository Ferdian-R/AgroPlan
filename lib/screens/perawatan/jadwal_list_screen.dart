import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/jadwal_perawatan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'tambah_jadwal_screen.dart';

/// Layar Daftar Jadwal Perawatan (Modul 3: FR-13).
///
/// Workflow:
/// - Menampilkan list jadwal perawatan (awalnya kosong → EmptyView).
/// - User tap FAB "+" → navigasi ke TambahJadwalScreen.
/// - Setelah berhasil tambah → menerima result JadwalPerawatan via Navigator.pop.
/// - Data baru langsung tampil di list.
class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  // STATE: Daftar jadwal perawatan yang tersimpan
  final List<JadwalPerawatan> _jadwalList = [];

  /// INPUT/EVENT: User tap FAB "+"
  /// NAVIGATION: Buka TambahJadwalScreen, kirim daftarLahan sebagai parameter
  /// RESULT: Menerima JadwalPerawatan dari screen form via Navigator.pop
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

    // FEEDBACK: SnackBar sukses
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Jadwal perawatan berhasil ditambahkan!'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        duration: const Duration(seconds: 3),
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

  /// Kartu jadwal perawatan individual
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
          ],
        ),
      ),
    );
  }
}
