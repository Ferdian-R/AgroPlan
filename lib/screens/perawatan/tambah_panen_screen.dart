import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/referensi_komoditas.dart';
import '../../models/lahan.dart';
import '../../models/riwayat_panen.dart';
import '../../models/siklus_tanam.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/panen_provider.dart';
import '../../providers/siklus_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/jadwal_success_dialog.dart';
import '../../widgets/primary_button.dart';

/// Layar Pencatatan Hasil Panen (Modul 3: FR-17 & FR-18).
///
/// Logika & Aturan:
/// - Pengguna mencatat hasil panen aktual (ton) untuk siklus tanam yang sedang aktif.
/// - Data divalidasi: tanggal panen tidak boleh sebelum tanggal tanam, jumlah > 0.
/// - Menyimpan data panen akan mengubah status siklus tanam menjadi 'Selesai' (FR-18).
class TambahPanenScreen extends StatefulWidget {
  final int? initialLahanId;
  final int? initialSiklusId;

  const TambahPanenScreen({
    super.key,
    this.initialLahanId,
    this.initialSiklusId,
  });

  @override
  State<TambahPanenScreen> createState() => _TambahPanenScreenState();
}

class _TambahPanenScreenState extends State<TambahPanenScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _jumlahHasilController = TextEditingController();
  final _catatanController = TextEditingController();

  // State
  SiklusTanam? _selectedSiklus;
  Lahan? _selectedLahan;
  DateTime? _tanggalPanen = DateTime.now();
  bool _isLoading = false;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPilihanSiklus();
    });
  }

  void _initPilihanSiklus() {
    final siklusProvider = context.read<SiklusProvider>();
    final lahanProvider = context.read<LahanProvider>();

    final siklusAktifList = siklusProvider.siklusList.where((s) => s.isBerjalan).toList();

    if (siklusAktifList.isEmpty) return;

    if (widget.initialSiklusId != null) {
      try {
        _selectedSiklus = siklusAktifList.firstWhere(
          (s) => s.idSiklus == widget.initialSiklusId,
        );
      } catch (_) {
        _selectedSiklus = siklusAktifList.first;
      }
    } else if (widget.initialLahanId != null) {
      try {
        _selectedSiklus = siklusAktifList.firstWhere(
          (s) => s.idLahan == widget.initialLahanId,
        );
      } catch (_) {
        _selectedSiklus = siklusAktifList.first;
      }
    } else {
      _selectedSiklus = siklusAktifList.first;
    }

    if (_selectedSiklus != null) {
      try {
        _selectedLahan = lahanProvider.lahanList.firstWhere(
          (l) => l.idLahan == _selectedSiklus!.idLahan,
        );
      } catch (_) {}
    }

    setState(() {});
  }

  @override
  void dispose() {
    _jumlahHasilController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  /// Menghitung estimasi hasil panen otomatis berdasarkan luas dan komoditas
  double _hitungEstimasiPanen() {
    if (_selectedSiklus == null) return 0.0;
    final luas = _selectedLahan?.luasLahan ?? 1.0;
    final ref = DataReferensi.cariKomoditas(_selectedSiklus!.komoditas);
    final produktivitas = ref?.produktivitas ?? 4.594;
    return luas * produktivitas;
  }

  Future<void> _pilihTanggalPanen() async {
    final now = DateTime.now();
    final tanggalTanam = _selectedSiklus?.tanggalRencanaTanam ?? DateTime(now.year - 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPanen ?? now,
      firstDate: tanggalTanam, // PRD: Tanggal panen tidak boleh sebelum tanggal tanam
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Pilih Tanggal Panen',
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

    if (picked != null) {
      setState(() => _tanggalPanen = picked);
    }
  }

  Future<void> _konfirmasiDanSimpan() async {
    setState(() => _autoValidate = true);

    if (_selectedSiklus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih siklus tanam aktif terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isTanggalValid = _tanggalPanen != null;

    if (!isFormValid || !isTanggalValid) {
      return;
    }

    // Validasi aturan PRD: Tanggal panen tidak boleh sebelum tanggal tanam
    if (_tanggalPanen!.isBefore(_selectedSiklus!.tanggalRencanaTanam)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal panen tidak boleh sebelum tanggal rencana tanam'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final jumlahHasil = double.tryParse(
          _jumlahHasilController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;

    if (jumlahHasil <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah hasil panen harus lebih dari 0 ton'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Dialog Konfirmasi Penyelesaian Siklus (FR-18)
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hasil Panen?'),
        content: Text(
          'Mencatat data panen (${jumlahHasil.toStringAsFixed(2)} ton) akan menyelesaikan siklus tanam "${_selectedSiklus!.komoditas}" pada "${_selectedSiklus!.namaLahan}".\n\nApakah Anda yakin data sudah benar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Periksa Kembali'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Simpan Panen'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() => _isLoading = true);

    final panenProvider = context.read<PanenProvider>();
    final siklusProvider = context.read<SiklusProvider>();

    final riwayatBaru = RiwayatPanen(
      idPanen: 0,
      idSiklus: _selectedSiklus!.idSiklus,
      idLahan: _selectedSiklus!.idLahan,
      namaLahan: _selectedSiklus!.namaLahan,
      komoditas: _selectedSiklus!.komoditas,
      luasLahan: _selectedLahan?.luasLahan ?? 1.0,
      tanggalPanen: _tanggalPanen!,
      jumlahHasilTon: jumlahHasil,
      estimasiHasilTon: _hitungEstimasiPanen(),
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      tanggalDibuat: DateTime.now(),
    );

    final success = await panenProvider.catatPanen(
      panen: riwayatBaru,
      siklusProvider: siklusProvider,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      await JadwalSuccessDialog.show(
        context,
        title: 'Hasil Panen Berhasil Dicatat!',
        subtitle:
            'Data panen telah disimpan ke riwayat dan status siklus tanam telah diselesaikan.',
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final siklusProvider = context.watch<SiklusProvider>();
    final lahanProvider = context.watch<LahanProvider>();
    final siklusAktifList = siklusProvider.siklusList.where((s) => s.isBerjalan).toList();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Catat Hasil Panen',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: siklusAktifList.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner panduan
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p14),
                      decoration: BoxDecoration(
                        color: AppColors.chipGreenBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pencatatan hasil panen akan otomatis menutup status siklus tanam aktif menjadi Selesai (FR-18).',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),

                    // Pilih Siklus Tanam Aktif
                    _buildLabel('Pilih Siklus Tanam Aktif *'),
                    const SizedBox(height: AppSpacing.p8),
                    DropdownButtonFormField<SiklusTanam>(
                      initialValue: _selectedSiklus,
                      decoration: _inputDecoration(
                        hint: 'Pilih siklus tanam',
                        prefixIcon: Icons.eco_outlined,
                      ),
                      items: siklusAktifList.map((siklus) {
                        return DropdownMenuItem<SiklusTanam>(
                          value: siklus,
                          child: Text(
                            '${siklus.namaLahan} • ${siklus.komoditas}',
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSiklus = val;
                          if (val != null) {
                            try {
                              _selectedLahan = lahanProvider.lahanList.firstWhere(
                                (l) => l.idLahan == val.idLahan,
                              );
                            } catch (_) {}
                          }
                        });
                      },
                      validator: (_) =>
                          Validators.requiredDropdown(_selectedSiklus, fieldName: 'Siklus tanam'),
                    ),
                    const SizedBox(height: AppSpacing.p16),

                    // Kartu Info Proyeksi Estimasi
                    if (_selectedSiklus != null) _buildEstimasiInfoCard(),

                    const SizedBox(height: AppSpacing.p16),

                    // Field: Tanggal Panen
                    _buildLabel('Tanggal Panen *'),
                    const SizedBox(height: AppSpacing.p8),
                    GestureDetector(
                      onTap: _pilihTanggalPanen,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration(
                            hint: 'Pilih tanggal panen',
                            prefixIcon: Icons.calendar_today_outlined,
                            suffixIcon: Icons.arrow_drop_down,
                          ).copyWith(
                            hintText: _tanggalPanen == null
                                ? 'Pilih tanggal panen'
                                : '${_tanggalPanen!.day}/${_tanggalPanen!.month}/${_tanggalPanen!.year}',
                            hintStyle: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p16),

                    // Field: Jumlah Hasil Panen (ton)
                    _buildLabel('Hasil Panen Aktual (ton) *'),
                    const SizedBox(height: AppSpacing.p8),
                    TextFormField(
                      controller: _jumlahHasilController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        hint: 'Contoh: 2.45',
                        prefixIcon: Icons.scale_outlined,
                      ).copyWith(
                        suffixText: 'ton',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      validator: (val) =>
                          Validators.positiveNumber(val, fieldName: 'Hasil panen'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.p16),

                    // Field: Catatan Panen
                    _buildLabel('Catatan Panen (Opsional)'),
                    const SizedBox(height: AppSpacing.p8),
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        hint: 'Tuliskan catatan kondisi hasil panen, kualitas biji/buah, harga jual...',
                        prefixIcon: Icons.note_alt_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p28),

                    // Tombol Submit
                    PrimaryButton(
                      text: 'Simpan & Selesaikan Siklus',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _konfirmasiDanSimpan,
                      prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEstimasiInfoCard() {
    final estimasi = _hitungEstimasiPanen();
    final inputTeks = _jumlahHasilController.text.trim().replaceAll(',', '.');
    final aktual = double.tryParse(inputTeks) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Perbandingan Estimasi & Aktual',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proyeksi Estimasi', style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    '${estimasi.toStringAsFixed(2)} ton',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (aktual > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Hasil Aktual', style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      '${aktual.toStringAsFixed(2)} ton',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: aktual >= estimasi ? AppColors.primary : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(Icons.agriculture_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Tidak Ada Siklus Tanam Aktif', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              'Catatan panen hanya dapat ditambahkan pada siklus tanam yang sedang berstatus Berjalan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.cardTitle.copyWith(fontSize: 14));
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.divider),
      ),
    );
  }
}
