import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
/// Workflow 5 Tahap Lengkap:
/// 1. INPUT / EVENT  → User mengisi formulir & mengunggah foto lahan (Kamera/Galeri/Contoh).
/// 2. STATE        → Input memperbarui state lokal form, foto, dan status proses.
/// 3. VALIDATION   → Validasi komprehensif (nama min 3 char, luas > 0, dropdown wajib, lokasi min 3 char).
/// 4. FEEDBACK     → Loading tombol & Modal Sukses Gambar 2 dengan ilustrasi lahan.
/// 5. NAVIGATION   → Simpan ke LahanProvider, pop kembali ke Beranda / Daftar Lahan dengan foto terpilih.
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

  // Foto State (bisa path file lokal dari kamera/galeri, atau asset path)
  String? _fotoPath;

  // Process States
  bool _isLoading = false;
  bool _autoValidate = false;

  final ImagePicker _imagePicker = ImagePicker();

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
      _fotoPath = l.fotoUrl;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _luasController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  // ──────────────── 1. INPUT / EVENT: Memilih & Mengunggah Foto Lahan ────────────────
  Future<void> _pilihSumberFoto() async {
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
                'Pilih Sumber Foto Lahan',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.p8),

              // Opsi 1: Kamera
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.chipGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text('Ambil dari Kamera'),
                subtitle: const Text('Gunakan kamera ponsel untuk memotret lahan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _ambilFoto(ImageSource.camera);
                },
              ),

              // Opsi 2: Galeri
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.chipGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Pilih foto lahan yang sudah ada di memori HP'),
                onTap: () {
                  Navigator.pop(ctx);
                  _ambilFoto(ImageSource.gallery);
                },
              ),

              // Opsi 3: Gunakan Contoh Foto
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_outlined, color: Colors.orange),
                ),
                title: const Text('Gunakan Foto Contoh Lahan Padi / Jagung'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihFotoContoh();
                },
              ),

              // Opsi 4: Hapus Foto (jika sudah ada foto terpilih)
              if (_fotoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: const Text('Hapus Foto Terpilih', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _fotoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 960,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _fotoPath = picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat mengambil foto: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _pilihFotoContoh() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Contoh Foto Lahan'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _fotoPath = 'assets/images/lahan_padi.webp');
                Navigator.pop(ctx);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/lahan_padi.webp',
                      width: 100,
                      height: 75,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Lahan Padi'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _fotoPath = 'assets/images/lahan_jagung.webp');
                Navigator.pop(ctx);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/lahan_jagung.webp',
                      width: 100,
                      height: 75,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Lahan Jagung'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

    // Foto lahan yang disimpan (prioritaskan hasil upload user, atau default dari komoditas)
    final fotoFinal = _fotoPath ??
        (_selectedKomoditas!.toLowerCase().contains('padi')
            ? 'assets/images/lahan_padi.webp'
            : 'assets/images/lahan_jagung.webp');

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
        fotoUrl: fotoFinal,
        tanggalDiubah: DateTime.now(),
      );
      success = await lahanProvider.updateLahan(updated);
    } else {
      // Buat data lahan baru (ID auto-increment berbasis timestamp sederhana)
      final newId = DateTime.now().millisecondsSinceEpoch % 10000;

      final baru = Lahan(
        idLahan: newId,
        namaLahan: _namaController.text.trim(),
        luasLahan: luas,
        komoditasUtama: _selectedKomoditas!,
        jenisTanah: _selectedJenisTanah,
        lokasi: _lokasiController.text.trim().isEmpty
            ? 'Lokasi belum diatur'
            : _lokasiController.text.trim(),
        fotoUrl: fotoFinal,
        tanggalDibuat: DateTime.now(),
      );
      success = await lahanProvider.tambahLahan(baru);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // ──────────────── 4. FEEDBACK: Modal Dialog Sukses Gambar 2 Spesifik Lahan ────────────────
      await JadwalSuccessDialog.show(
        context,
        imagePath: 'assets/images/success_lahan.png',
        title: isEdit
            ? 'Data lahan\nberhasil diperbarui!'
            : 'Data lahan\nberhasil ditambahkan!',
        subtitle: isEdit
            ? 'Perubahan data lahan telah berhasil disimpan dan diperbarui.'
            : 'Informasi lahan telah disimpan dan siap digunakan untuk perencanaan siklus tanam Anda.',
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

              // ═══════ SEKSI UPLOAD FOTO LAHAN ═══════
              _buildSectionLabel('Foto Lahan'),
              const SizedBox(height: AppSpacing.p8),
              _buildPhotoUploadArea(),
              const SizedBox(height: AppSpacing.p20),

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

  /// Komponen UI untuk area Unggah Foto Lahan
  Widget _buildPhotoUploadArea() {
    if (_fotoPath != null) {
      // Tampilan jika sudah ada foto terpilih
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: AppSpacing.roundedCard,
              child: _fotoPath!.startsWith('assets/')
                  ? Image.asset(
                      _fotoPath!,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_fotoPath!),
                      fit: BoxFit.cover,
                    ),
            ),
            // Tombol Ganti & Hapus di atas preview foto
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: _pilihSumberFoto,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Ganti Foto'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                      onPressed: () => setState(() => _fotoPath = null),
                      tooltip: 'Hapus foto',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tampilan jika belum ada foto (kotak unggah interaktif)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pilihSumberFoto,
        borderRadius: AppSpacing.roundedCard,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.chipGreenBg,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unggah Foto Lahan',
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ambil dari Kamera atau Galeri ponsel',
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
              ),
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
