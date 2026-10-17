import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/laporan_kondisi.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';

class TambahLaporanScreen extends StatefulWidget {
  final LaporanKondisi? laporanToEdit;
  final int? initialLahanId;
  final int? initialSiklusId;

  const TambahLaporanScreen({
    super.key,
    this.laporanToEdit,
    this.initialLahanId,
    this.initialSiklusId,
  });

  @override
  State<TambahLaporanScreen> createState() => _TambahLaporanScreenState();
}

class _TambahLaporanScreenState extends State<TambahLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();
  final _imagePicker = ImagePicker();

  int? _selectedLahanId;
  String? _selectedNamaLahan;
  String? _selectedJenisKondisi;
  String? _fotoPath;
  bool _isLoading = false;
  bool _autoValidate = false;

  static const List<String> daftarJenisKondisi = [
    'Normal',
    'Hama',
    'Kekeringan',
    'Banjir',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.laporanToEdit != null) {
      final l = widget.laporanToEdit!;
      _selectedLahanId = l.idLahan;
      _selectedNamaLahan = l.namaLahan;
      _selectedJenisKondisi = daftarJenisKondisi.contains(l.jenisKondisi)
          ? l.jenisKondisi
          : (l.jenisKondisi.contains('Hama')
              ? 'Hama'
              : (l.jenisKondisi.contains('Banjir') ? 'Banjir' : 'Lainnya'));
      _catatanController.text = l.catatan;
      _fotoPath = l.fotoUrl;
    } else if (widget.initialLahanId != null) {
      _selectedLahanId = widget.initialLahanId;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // 1. INPUT / EVENT: Pemilihan Foto (Kamera, Galeri, atau Sampel)
  Future<void> _pilihSumberFoto() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Unggah Foto Kondisi Lahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _ambilFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _ambilFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_filter_outlined, color: AppColors.primary),
                title: const Text('Gunakan Foto Sampel Lahan'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _fotoPath = 'assets/images/lahan_padi.webp');
                },
              ),
              if (_fotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
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
      if (picked != null) setState(() => _fotoPath = picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto gagal dimuat: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // 3. VALIDATION & 2. STATE: Submit Form & Simpan ke Provider
  Future<void> _submitForm() async {
    setState(() => _autoValidate = true);

    // Validasi form (Lahan, Jenis Kondisi, Catatan >= 5 karakter)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isEdit = widget.laporanToEdit != null;
    final laporanBaru = LaporanKondisi(
      id: isEdit ? widget.laporanToEdit!.id : DateTime.now().millisecondsSinceEpoch % 100000,
      idLahan: _selectedLahanId!,
      idSiklus: widget.laporanToEdit?.idSiklus ?? widget.initialSiklusId ?? 1,
      namaLahan: _selectedNamaLahan ?? 'Lahan Petani',
      tanggalLapor: isEdit ? widget.laporanToEdit!.tanggalLapor : DateTime.now(),
      jenisKondisi: _selectedJenisKondisi!,
      catatan: _catatanController.text.trim(),
      fotoUrl: _fotoPath,
    );

    final provider = context.read<LaporanProvider>();
    final success = isEdit
        ? await provider.updateLaporan(laporanBaru)
        : await provider.tambahLaporan(laporanBaru);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // 4. FEEDBACK: Dialog Sukses (Papan Laporan Centang Hijau)
      await _tampilkanDialogSukses(laporanBaru);

      if (!mounted) return;
      // 5. NAVIGATION / RESULT: Pop kembali dan mengembalikan objek laporan baru
      Navigator.pop(context, laporanBaru);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan laporan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─── 4. FEEDBACK: Modal Dialog Sukses Penyimpanan Laporan ───
  Future<void> _tampilkanDialogSukses(LaporanKondisi laporan) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/success_laporan.png',
                width: 140,
                height: 140,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF019484), size: 54),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.laporanToEdit != null ? 'Laporan Diperbarui!' : 'Laporan Terkirim!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data kondisi lahan telah disimpan untuk memantau siklus tanam Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              // Ringkasan Data Laporan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lahan: ${laporan.namaLahan}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Kondisi: ${laporan.jenisKondisi}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: laporan.warnaKondisi)),
                    const SizedBox(height: 4),
                    Text(
                      laporan.hasFoto ? 'Foto bukti: Terlampir' : 'Foto bukti: Tanpa foto (opsional)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF019484),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
    final lahanProvider = context.watch<LahanProvider>();
    final lahanList = lahanProvider.lahanList;

    if (_selectedLahanId != null && _selectedNamaLahan == null && lahanList.isNotEmpty) {
      _selectedNamaLahan = lahanList.where((l) => l.idLahan == _selectedLahanId).firstOrNull?.namaLahan;
    }

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(widget.laporanToEdit != null ? 'Ubah Laporan Kondisi' : 'Lapor Kondisi Lahan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview & Input Foto Bukti
            Center(
              child: GestureDetector(
                onTap: _pilihSumberFoto,
                child: Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                  ),
                  child: _fotoPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.chipGreenBg, shape: BoxShape.circle),
                              child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(height: 8),
                            const Text('Ketuk untuk Melampirkan Foto Bukti',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            const SizedBox(height: 2),
                            const Text('Kamera atau Galeri (Opsional)',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildFotoPreview(_fotoPath!),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('Ubah', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kartu Input Data
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Pilih Lahan
                  const Text('Lahan Pertanian *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedLahanId,
                    isExpanded: true,
                    decoration: _inputDecoration('Pilih lahan', Icons.landscape_outlined),
                    items: lahanList.map((lahan) {
                      return DropdownMenuItem<int>(
                        value: lahan.idLahan,
                        child: Text('${lahan.namaLahan} (${lahan.komoditasUtama})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedLahanId = val;
                        _selectedNamaLahan = lahanList.where((l) => l.idLahan == val).firstOrNull?.namaLahan;
                      });
                    },
                    validator: (val) => val == null ? 'Lahan pertanian wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Jenis Kondisi
                  const Text('Jenis Kondisi Tanaman *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedJenisKondisi,
                    isExpanded: true,
                    decoration: _inputDecoration('Pilih jenis kondisi', Icons.category_outlined),
                    items: daftarJenisKondisi.map((kondisi) {
                      return DropdownMenuItem<String>(value: kondisi, child: Text(kondisi));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJenisKondisi = val),
                    validator: (val) => Validators.requiredDropdown(val, fieldName: 'Jenis kondisi'),
                  ),
                  const SizedBox(height: 16),

                  // 3. Catatan Observasi
                  const Text('Catatan Observasi Lapangan *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),

                  // Kotak Saran Dinamis Berdasarkan Kondisi Terpilih
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedJenisKondisi != null ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedJenisKondisi != null ? const Color(0xFFBBF7D0) : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: _selectedJenisKondisi != null ? const Color(0xFF16A34A) : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedJenisKondisi != null
                                  ? 'Saran Observasi ($_selectedJenisKondisi):'
                                  : 'Panduan Saran Catatan Observasi:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _selectedJenisKondisi != null ? const Color(0xFF166534) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSaranCatatan(_selectedJenisKondisi),
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedJenisKondisi != null ? const Color(0xFF1E293B) : AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        if (_selectedJenisKondisi != null) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              final contoh = _getPlaceholderCatatan(_selectedJenisKondisi)
                                  .replaceFirst('Contoh: ', '');
                              _catatanController.text = contoh;
                              _catatanController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _catatanController.text.length),
                              );
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app_outlined, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Gunakan contoh catatan ini',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: _inputDecoration(_getPlaceholderCatatan(_selectedJenisKondisi)),
                    validator: (val) => Validators.minLength(val, 5, fieldName: 'Catatan observasi'),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Submit
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              widget.laporanToEdit != null ? 'Simpan Perubahan' : 'Kirim Laporan Kondisi',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoPreview(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  InputDecoration _inputDecoration(String hint, [IconData? icon]) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  String _getSaranCatatan(String? jenisKondisi) {
    switch (jenisKondisi) {
      case 'Hama':
        return 'Sebutkan jenis hama yang terlihat, bagian tanaman yang terserang (daun/batang/akar), dan perkiraan persentase kerusakannya.';
      case 'Kekeringan':
        return 'Tuliskan kondisi kelembapan tanah (retak/kering), daun yang layu atau menggulung, dan status pasokan air irigasi.';
      case 'Banjir':
        return 'Catat perkiraan tinggi genangan air (cm), petak yang terendam, dan berapa lama genangan telah terjadi.';
      case 'Normal':
        return 'Laporkan fase pertumbuhan tanaman, warna daun yang sehat, dan kesiapan untuk tahap perawatan berikutnya.';
      case 'Lainnya':
        return 'Jelaskan secara rinci anomali atau kondisi spesifik yang ditemukan di lahan (misal: defisiensi nutrisi, kerusakan pagar, angin kencang).';
      default:
        return 'Pilih jenis kondisi tanaman di atas untuk menampilkan panduan saran catatan observasi.';
    }
  }

  String _getPlaceholderCatatan(String? jenisKondisi) {
    switch (jenisKondisi) {
      case 'Hama':
        return 'Contoh: Ditemukan ulat grayak pada 15% daun muda di petak timur.';
      case 'Kekeringan':
        return 'Contoh: Tanah retak-retak, daun mulai layu akibat 1 minggu tanpa pasokan irigasi.';
      case 'Banjir':
        return 'Contoh: Tergenang air setinggi 10 cm akibat hujan lebat selama 2 hari.';
      case 'Normal':
        return 'Contoh: Tanaman tumbuh optimal, daun hijau segar tanpa tanda serangan hama.';
      case 'Lainnya':
        return 'Contoh: Sebagian tanaman roboh di sudut lahan akibat angin kencang kemarin sore.';
      default:
        return 'Tuliskan catatan observasi kondisi tanaman di lapangan...';
    }
  }
}
