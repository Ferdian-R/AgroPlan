import 'package:flutter/material.dart';
import '../models/lahan.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  // (1) data yang DITERIMA dari Home
  final Lahan lahan;

  const DetailScreen({super.key, required this.lahan});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // (3) buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return; // null = pengguna batal
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.lahan"
    final lahan = widget.lahan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lahan.namaLahan,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Nama Lahan
          Text(
            lahan.namaLahan,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.p4),

          // Subtitle: Komoditas & Luas
          Text(
            lahan.chipText,
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.p16),

          // Informasi Detail
          _buildInfoRow('Jenis Tanah', lahan.jenisTanah ?? '-'),
          _buildInfoRow('Lokasi', lahan.lokasi ?? '-'),
          _buildInfoRow('Luas', lahan.luasFormatted),
          _buildInfoRow('Komoditas', lahan.komoditasUtama),

          const Divider(height: AppSpacing.p32),

          // Catatan
          Text(
            _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.p16),

          // Tombol Tulis Catatan
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(AppSpacing.buttonHeight48),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.roundedButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baris informasi detail lahan
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
