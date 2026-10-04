import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/laporan_kondisi.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';

/// Layar Form Tambah & Edit Laporan Kondisi Lahan (Modul 2: FR-07, FR-08, FR-10, FR-12).
///
/// Workflow 5 Tahap Lengkap:
/// 1. INPUT / EVENT  → User mengisi formulir: pilih lahan, jenis kondisi, tingkat keparahan, foto bukti, catatan.
/// 2. STATE        → Input memperbarui state lokal form, foto, dan status proses.
/// 3. VALIDATION   → Validasi komprehensif (lahan wajib, kondisi wajib, keparahan wajib, catatan min 5 char).
/// 4. FEEDBACK     → Loading tombol, modal sukses & alert notifikasi peringatan risiko tinggi (FR-12).
/// 5. NAVIGATION   → Simpan ke LaporanProvider, pop kembali ke RiwayatLaporanScreen.
class TambahLaporanScreen extends StatefulWidget {
  final LaporanKondisi? laporanToEdit;

  const TambahLaporanScreen({super.key, this.laporanToEdit});

  @override
  State<TambahLaporanScreen> createState() => _TambahLaporanScreenState();
}

class _TambahLaporanScreenState extends State<TambahLaporanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _catatanController = TextEditingController();
  final _imagePicker = ImagePicker();

  // State Form
  int? _selectedLahanId;
  String? _selectedNamaLahan;
  String? _selectedJenisKondisi;
  String _selectedTingkatKeparahan = 'Rendah';
  String? _fotoPath;

  bool _isLoading = false;
  bool _autoValidate = false;

  static const List<String> daftarJenisKondisi = [
    'Normal',
    'Serangan Hama/Penyakit',
    'Kekeringan',
    'Banjir/Tergenang',
    'Defisiensi Nutrisi',
    'Lainnya',
  ];

  static const List<String> daftarTingkatKeparahan = [
    'Rendah',
    'Sedang',
    'Berat',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.laporanToEdit != null) {
      final l = widget.laporanToEdit!;
      _selectedLahanId = l.idLahan;
      _selectedNamaLahan = l.namaLahan;
      _selectedJenisKondisi = l.jenisKondisi;
      _selectedTingkatKeparahan = l.tingkatKeparahan;
      _catatanController.text = l.catatan;
      _fotoPath = l.fotoUrl;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // ──────────────── 1. INPUT / EVENT: Memilih & Mengunggah Foto Bukti ────────────────
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
                'Pilih Sumber Foto Kondisi Lahan',
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
                subtitle: const Text('Potret langsung kondisi tanaman atau lahan'),
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
                subtitle: const Text('Pilih foto dokumentasi yang tersimpan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _ambilFoto(ImageSource.gallery);
                },
              ),

              // Opsi 3: Preset Cepat
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_outlined, color: Colors.orange),
                ),
                title: const Text('Gunakan Foto Sampel (Padi / Jagung)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihFotoContoh();
                },
              ),

              // Opsi 4: Hapus Foto
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
      final isMissingPlugin = e.toString().contains('MissingPluginException');
      final errorMsg = isMissingPlugin
          ? 'Harap restart penuh flutter run agar plugin kamera/galeri terdaftar.'
          : 'Tidak dapat mengambil foto: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    }
  }

  void _pilihFotoContoh() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Foto Sampel Lahan'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
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
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Lahan Padi', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            InkWell(
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
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Lahan Jagung', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── 1. INPUT / EVENT & 3. VALIDATION: Submit Laporan ────────────────
  Future<void> _submitForm() async {
    setState(() => _autoValidate = true);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap periksa kembali inputan Anda.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2. STATE: Mengaktifkan status proses
    setState(() => _isLoading = true);

    final statusRisikoDihasilkan = LaporanKondisi.tentukanStatusRisiko(
      jenisKondisi: _selectedJenisKondisi!,
      tingkatKeparahan: _selectedTingkatKeparahan,
    );

    final isEdit = widget.laporanToEdit != null;
    final laporanBaru = LaporanKondisi(
      id: isEdit ? widget.laporanToEdit!.id : DateTime.now().millisecondsSinceEpoch % 100000,
      idLahan: _selectedLahanId!,
      namaLahan: _selectedNamaLahan ?? 'Lahan Petani',
      tanggalLapor: isEdit ? widget.laporanToEdit!.tanggalLapor : DateTime.now(),
      jenisKondisi: _selectedJenisKondisi!,
      tingkatKeparahan: _selectedTingkatKeparahan,
      catatan: _catatanController.text.trim(),
      fotoUrl: _fotoPath,
      statusRisiko: statusRisikoDihasilkan,
    );

    final provider = context.read<LaporanProvider>();
    final success = isEdit
        ? await provider.updateLaporan(laporanBaru)
        : await provider.tambahLaporan(laporanBaru);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // 4. FEEDBACK: Menampilkan Dialog Sukses & Peringatan Dini (FR-12)
      await _tampilkanDialogSukses(laporanBaru);

      if (!mounted) return;
      // 5. NAVIGATION / RESULT: Kembali ke layar riwayat laporan
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan laporan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ──────────────── 4. FEEDBACK: Modal Dialog Sukses & Peringatan Risiko Tinggi ────────────────
  Future<void> _tampilkanDialogSukses(LaporanKondisi laporan) async {
    final isRisikoTinggi = laporan.isRisikoTinggi;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ilustrasi Papan Laporan Centang Hijau
              Image.asset(
                'assets/images/success_laporan.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Judul Utama
              Text(
                widget.laporanToEdit != null
                    ? 'Laporan kondisi lahan berhasil diperbarui!'
                    : 'Laporan kondisi lahan berhasil ditambahkan!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi Subtitle
              const Text(
                'Laporan kondisi lahan telah disimpan dan akan digunakan untuk memantau perkembangan siklus tanam Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              // Banner Feedback Peringatan Dini (FR-12) jika Risiko Tinggi
              if (isRisikoTinggi) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF5350)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD32F2F),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peringatan Dini: Risiko Tinggi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kondisi "${laporan.jenisKondisi}" (${laporan.tingkatKeparahan}) memicu status Risiko Tinggi.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Tombol OK Hijau Teal (Pill Shape)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF019484),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.laporanToEdit != null;
    final lahanList = context.watch<LahanProvider>().lahanList;

    // Pastikan nama lahan terisi jika ID sudah ada
    if (_selectedLahanId != null && _selectedNamaLahan == null) {
      final matching = lahanList.where((l) => l.idLahan == _selectedLahanId).firstOrNull;
      if (matching != null) {
        _selectedNamaLahan = matching.namaLahan;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Laporan Kondisi' : 'Lapor Kondisi Lahan',
          style: const TextStyle(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.p12),
                  decoration: BoxDecoration(
                    color: AppColors.chipGreenBg,
                    borderRadius: AppSpacing.roundedCard,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: AppSpacing.p12),
                      Expanded(
                        child: Text(
                          'Catat perkembangan kondisi tanaman & lahan untuk pemantauan dini dan deteksi risiko otomatis.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.p20),

                // ─── 1. UPLOAD FOTO BUKTI LAPANGAN (FR-08) ───
                const Text(
                  'Foto Bukti Kondisi Lapangan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.p8),
                _buildFotoUploadBox(),
                const SizedBox(height: AppSpacing.p20),

                // ─── 2. PILIH LAHAN ───
                const Text(
                  'Lahan Yang Diamati *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.p8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedLahanId,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    hint: 'Pilih lahan pertanian',
                    prefixIcon: Icons.landscape_outlined,
                  ),
                  items: lahanList.map((lahan) {
                    return DropdownMenuItem<int>(
                      value: lahan.idLahan,
                      child: Text(
                        '${lahan.namaLahan} (${lahan.komoditasUtama})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedLahanId = val;
                      final match = lahanList.where((l) => l.idLahan == val).firstOrNull;
                      _selectedNamaLahan = match?.namaLahan;
                    });
                  },
                  validator: (val) => val == null ? 'Lahan pertanian wajib dipilih' : null,
                ),
                const SizedBox(height: AppSpacing.p16),

                // ─── 3. JENIS KONDISI ───
                const Text(
                  'Jenis Kondisi Tanaman *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.p8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedJenisKondisi,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    hint: 'Pilih jenis kondisi',
                    prefixIcon: Icons.category_outlined,
                  ),
                  items: daftarJenisKondisi.map((kondisi) {
                    return DropdownMenuItem<String>(
                      value: kondisi,
                      child: Text(kondisi),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedJenisKondisi = val),
                  validator: (val) => Validators.requiredDropdown(val, fieldName: 'Jenis kondisi'),
                ),
                const SizedBox(height: AppSpacing.p16),

                // ─── 4. TINGKAT KEPARAHAN ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tingkat Keparahan *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    if (_selectedTingkatKeparahan == 'Berat')
                      const Text(
                        '⚠️ Memicu Risiko Tinggi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p8),
                Row(
                  children: daftarTingkatKeparahan.map((keparahan) {
                    final isSelected = _selectedTingkatKeparahan == keparahan;
                    Color activeColor = AppColors.primary;
                    if (keparahan == 'Sedang') activeColor = Colors.orange;
                    if (keparahan == 'Berat') activeColor = AppColors.error;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              keparahan,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: activeColor,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? activeColor : AppColors.divider,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() => _selectedTingkatKeparahan = keparahan);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.p16),

                // ─── 5. CATATAN OBSERVASI ───
                const Text(
                  'Catatan Observasi Lapangan *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.p8),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hint: 'Contoh: Ditemukan hama ulat grayak pada daun muda petak timur, telah diberikan penanganan awal.',
                  ),
                  validator: (val) => Validators.minLength(val, 5, fieldName: 'Catatan observasi'),
                ),
                const SizedBox(height: AppSpacing.p28),

                // ─── TOMBOL KIRIM LAPORAN ───
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.roundedButton,
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan Laporan' : 'Kirim Laporan Kondisi',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Widget Upload Foto Lapangan (Mendukung Web & Mobile) ───
  Widget _buildFotoUploadBox() {
    if (_fotoPath == null) {
      return InkWell(
        onTap: _pilihSumberFoto,
        borderRadius: AppSpacing.roundedCard,
        child: Container(
          width: double.infinity,
          height: 125,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unggah Foto Bukti Lapangan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kamera atau Galeri ponsel',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 160,
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
                ? Image.asset(_fotoPath!, fit: BoxFit.cover)
                : (kIsWeb ||
                        _fotoPath!.startsWith('http://') ||
                        _fotoPath!.startsWith('https://') ||
                        _fotoPath!.startsWith('blob:'))
                    ? Image.network(_fotoPath!, fit: BoxFit.cover)
                    : Image.file(File(_fotoPath!), fit: BoxFit.cover),
          ),
          // Tombol Ubah & Hapus
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: _pilihSumberFoto,
                  icon: const Icon(Icons.camera_alt, size: 14),
                  label: const Text('Ganti Foto', style: TextStyle(fontSize: 11)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: () => setState(() => _fotoPath = null),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.8),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p14,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedCard,
        borderSide: const BorderSide(color: AppColors.divider),
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
