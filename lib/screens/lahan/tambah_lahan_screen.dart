import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lahan.dart';
import '../../providers/lahan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/jadwal_success_dialog.dart';

/// Layar Form Tambah & Edit Data Lahan (Modul 1: FR-01 & FR-02).
///
/// Workflow 5 Tahap:
/// 1. INPUT / EVENT  → User mengisi formulir (nama, luas, komoditas, jenis tanah, lokasi).
/// 2. STATE        → Input memperbarui state lokal form dan status loading.
/// 3. VALIDATION   → Validasi komprehensif (nama min 3 char, luas > 0, dropdown wajib, lokasi min 3 char).
/// 4. FEEDBACK     → Error teks merah di bawah input / loading tombol / Modal Sukses Gambar 2.
/// 5. NAVIGATION   → Simpan ke LahanProvider, pop kembali ke Beranda / Daftar Lahan.
class TambahLahanScreen extends StatefulWidget {
  /// Objek lahan yang akan diedit (jika null, berarti mode tambah baru)
  final Lahan? lahanToEdit;

  const TambahLahanScreen({super.key, this.lahanToEdit});

  @override
  State<TambahLahanScreen> createState() => _TambahLahanScreenState();
}

class _TambahLahanScreenState extends State<TambahLahanScreen> {
  // ──────────────────── 2. STATE ────────────────────
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _namaController = TextEditingController();
  final _luasController = TextEditingController();
  final _lokasiController = TextEditingController();

  // Dropdown States
  String? _selectedKomoditas;
  String? _selectedJenisTanah;

  // Process States
  bool _isLoading = false;
  bool _autoValidate = false;

  // Opsi Dropdown
  static const List<String> daftarKomoditas = [
    'Padi',
    'Jagung',
    'Kedelai',
    'Cabai',
    'Bawang Merah',
    'Tomat',
    'Lainnya',
  ];

  static const List<String> daftarJenisTanah = [
    'Aluvial',
    'Lempung',
    'Andosol',
    'Regosol',
    'Grumusol',
    'Latosol',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // Jika mode edit, inisialisasi form dengan data lama
    if (widget.lahanToEdit != null) {
      final l = widget.lahanToEdit!;
      _namaController.text = l.namaLahan;
      _luasController.text = l.luasLahan.toString().replaceAll('.', ',');
      _lokasiController.text = l.lokasi ?? '';
      _selectedKomoditas = l.komoditasUtama;
      _selectedJenisTanah = l.jenisTanah;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _luasController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  // ──────────────── 1. INPUT / EVENT: Tap Simpan Lahan ────────────────
  Future<void> _simpan() async {
    // Aktifkan validasi visual real-time setelah submit pertama
    setState(() => _autoValidate = true);

    // ──────────────── 3. VALIDATION: Validasi Form ────────────────
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final komoditasError = Validators.requiredDropdown(
      _selectedKomoditas,
      fieldName: 'Komoditas utama',
    );
    final tanahError = Validators.requiredDropdown(
      _selectedJenisTanah,
      fieldName: 'Jenis tanah',
    );

    if (!isFormValid || komoditasError != null || tanahError != null) {
      // Validasi gagal: tetap di halaman form dan tampilkan pesan error
      return;
    }

    // Ubah state proses menjadi loading
    setState(() => _isLoading = true);

    final normalizedLuas = _luasController.text.trim().replaceAll(',', '.');
    final luas = double.parse(normalizedLuas);
    final isEdit = widget.lahanToEdit != null;

    final lahanProvider = context.read<LahanProvider>();
    bool success = false;

    if (isEdit) {
      // Update data lahan yang ada
      final updated = widget.lahanToEdit!.copyWith(
        namaLahan: _namaController.text.trim(),
        luasLahan: luas,
        komoditasUtama: _selectedKomoditas!,
        jenisTanah: _selectedJenisTanah,
        lokasi: _lokasiController.text.trim().isEmpty
            ? null
            : _lokasiController.text.trim(),
        tanggalDiubah: DateTime.now(),
      );
      success = await lahanProvider.updateLahan(updated);
    } else {
      // Buat data lahan baru (ID auto-increment berbasis timestamp sederhana)
      final newId = DateTime.now().millisecondsSinceEpoch % 10000;
      final fotoDefault = _selectedKomoditas!.toLowerCase().contains('padi')
          ? 'assets/images/lahan_padi.webp'
          : 'assets/images/lahan_jagung.webp';

      final baru = Lahan(
        idLahan: newId,
        namaLahan: _namaController.text.trim(),
        luasLahan: luas,
        komoditasUtama: _selectedKomoditas!,
        jenisTanah: _selectedJenisTanah,
        lokasi: _lokasiController.text.trim().isEmpty
            ? 'Lokasi belum diatur'
            : _lokasiController.text.trim(),
        fotoUrl: fotoDefault,
        tanggalDibuat: DateTime.now(),
      );
      success = await lahanProvider.tambahLahan(baru);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // ──────────────── 4. FEEDBACK: Modal Dialog Sukses Gambar 2 ────────────────
      await JadwalSuccessDialog.show(
        context,
        title: isEdit
            ? 'Data lahan\nberhasil diperbarui!'
            : 'Data lahan\nberhasil ditambahkan!',
        subtitle: isEdit
            ? 'Perubahan data lahan telah berhasil disimpan dan diperbarui.'
            : 'Data lahan baru telah disimpan dan akan muncul pada daftar lahan Anda.',
      );

      // ──────────────── 5. NAVIGATION / RESULT: Kembali ke Layar Sebelumnya ────────────────
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      // Feedback jika terjadi kegagalan sistem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lahanProvider.errorMessage ?? 'Gagal menyimpan data lahan',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lahanToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Data Lahan' : 'Tambah Lahan Baru',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.p8),

              // ═══════ FIELD 1: Nama Lahan ═══════
              _buildSectionLabel('Nama Lahan *'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration(
                  hint: 'Contoh: Lahan Jagung Timur',
                  prefixIcon: Icons.landscape_outlined,
                ),
                textInputAction: TextInputAction.next,
                validator: (val) => Validators.minLength(
                  val,
                  3,
                  fieldName: 'Nama lahan',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 2: Luas Lahan (Hektar) ═══════
              _buildSectionLabel('Luas Lahan (Hektar) *'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _luasController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                  hint: 'Contoh: 0.5 atau 1.2',
                  prefixIcon: Icons.square_foot_outlined,
                  suffixText: 'ha',
                ),
                textInputAction: TextInputAction.next,
                validator: (val) => Validators.positiveNumber(
                  val,
                  fieldName: 'Luas lahan',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 3: Komoditas Utama (Dropdown) ═══════
              _buildSectionLabel('Komoditas Utama *'),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<String>(
                initialValue: _selectedKomoditas,
                decoration: _inputDecoration(
                  hint: 'Pilih komoditas',
                  prefixIcon: Icons.grass_outlined,
                ),
                items: daftarKomoditas.map((komoditas) {
                  return DropdownMenuItem<String>(
                    value: komoditas,
                    child: Text(
                      komoditas,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedKomoditas = val),
                validator: (_) => Validators.requiredDropdown(
                  _selectedKomoditas,
                  fieldName: 'Komoditas utama',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 4: Jenis Tanah (Dropdown) ═══════
              _buildSectionLabel('Jenis Tanah *'),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenisTanah,
                decoration: _inputDecoration(
                  hint: 'Pilih jenis tanah',
                  prefixIcon: Icons.layers_outlined,
                ),
                items: daftarJenisTanah.map((tanah) {
                  return DropdownMenuItem<String>(
                    value: tanah,
                    child: Text(
                      tanah,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedJenisTanah = val),
                validator: (_) => Validators.requiredDropdown(
                  _selectedJenisTanah,
                  fieldName: 'Jenis tanah',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 5: Lokasi Lahan ═══════
              _buildSectionLabel('Lokasi Lahan *'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _lokasiController,
                decoration: _inputDecoration(
                  hint: 'Contoh: Kab. Padang Pariaman',
                  prefixIcon: Icons.place_outlined,
                ),
                textInputAction: TextInputAction.done,
                validator: (val) => Validators.minLength(
                  val,
                  3,
                  fieldName: 'Lokasi lahan',
                ),
              ),
              const SizedBox(height: AppSpacing.p32),

              // ═══════ TOMBOL SIMPAN LAHAN ═══════
              SizedBox(
                height: AppSpacing.buttonHeight48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _simpan,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedButton,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Simpan Lahan',
                          style: AppTextStyles.authButton.copyWith(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.p20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      suffixText: suffixText,
      suffixStyle: AppTextStyles.cardSubtitle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p14,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
