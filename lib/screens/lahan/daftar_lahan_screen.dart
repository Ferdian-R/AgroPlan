import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lahan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/land_card.dart';
import 'tambah_lahan_screen.dart';

/// Layar Daftar Seluruh Lahan (Modul 1: Manajemen Lahan).
///
/// Menampilkan seluruh lahan milik pengguna dalam bentuk Grid 2 kolom,
/// dilengkapi dengan tombol Edit, Hapus, dan FAB Tambah Lahan.
class DaftarLahanScreen extends StatelessWidget {
  const DaftarLahanScreen({super.key});

  Future<void> _bukaTambahLahan(BuildContext context) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahLahanScreen(),
      ),
    );
  }

  Future<void> _bukaEditLahan(BuildContext context, Lahan lahan) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahLahanScreen(lahanToEdit: lahan),
      ),
    );
  }

  Future<void> _konfirmasiHapusLahan(BuildContext context, Lahan lahan) async {
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
          'Apakah Anda yakin ingin menghapus "${lahan.namaLahan}"? Data rencana tanam dan jadwal terkait juga akan terpengaruh.',
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
      final success = await context.read<LahanProvider>().hapusLahan(lahan.idLahan);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Lahan "${lahan.namaLahan}" berhasil dihapus'),
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
                  _bukaEditLahan(context, lahan);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus Lahan', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _konfirmasiHapusLahan(context, lahan);
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
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Daftar Lahan',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Consumer<LahanProvider>(
        builder: (context, provider, _) {
          final list = provider.lahanList;

          if (list.isEmpty) {
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
                        Icons.landscape_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    Text(
                      'Belum Ada Lahan',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      'Tekan tombol "+ Tambah Lahan" untuk\nmendaftarkan lahan pertanian Anda.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.p16,
              AppSpacing.screenPadding,
              100, // Ruang untuk FAB
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.p12,
              mainAxisSpacing: AppSpacing.p12,
              childAspectRatio: 0.72,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final lahan = list[index];
              return LandCard(
                lahan: lahan,
                onTap: () => _bukaEditLahan(context, lahan),
                onMenuPressed: () => _tampilkanMenuLahan(context, lahan),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaTambahLahan(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Lahan'),
      ),
    );
  }
}
