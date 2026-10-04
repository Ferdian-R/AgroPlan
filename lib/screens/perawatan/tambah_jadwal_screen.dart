import 'package:flutter/material.dart';
import '../../models/jadwal_perawatan.dart';
import '../../models/lahan.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';

/// Layar Form Tambah Jadwal Perawatan (Modul 3: FR-13).
///
/// Workflow:
/// 1. INPUT/EVENT  → User mengisi form (nama kegiatan, pilih lahan, jenis, tanggal, catatan).
/// 2. STATE        → Setiap field mengubah state (_namaController, _selectedLahan, dll).
/// 3. VALIDATION   → Saat tap Simpan, validasi semua field (wajib isi, min 3 char, tanggal valid).
/// 4. FEEDBACK     → Error text merah di bawah field / loading di tombol / SnackBar gagal.
/// 5. NAVIGATION   → Jika valid: Navigator.pop(context, jadwalBaru) → kembali ke list.
class TambahJadwalScreen extends StatefulWidget {
  /// Data lahan yang dikirim dari JadwalListScreen (untuk dropdown)
  final List<Lahan> daftarLahan;

  /// Data jadwal yang ingin diedit (jika null, berarti mode tambah baru)
  final JadwalPerawatan? jadwalToEdit;

  const TambahJadwalScreen({
    super.key,
    required this.daftarLahan,
    this.jadwalToEdit,
  });

  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  // ──────────────────── STATE ────────────────────
  final _formKey = GlobalKey<FormState>();

  // Field controllers
  final _namaController = TextEditingController();
  final _catatanController = TextEditingController();

  // State dropdown & date picker
  Lahan? _selectedLahan;
  String? _selectedJenis;
  DateTime? _selectedTanggal;

  // State proses
  bool _isLoading = false;
  bool _autoValidate = false;

  // Counter untuk ID auto-increment sederhana
  static int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, inisialisasi state dari data yang ada
    if (widget.jadwalToEdit != null) {
      final j = widget.jadwalToEdit!;
      _namaController.text = j.namaKegiatan;
      _catatanController.text = j.catatan ?? '';
      _selectedJenis = j.jenisPerawatan;
      _selectedTanggal = j.tanggalPelaksanaan;

      // Cari lahan yang sesuai di daftarLahan
      try {
        _selectedLahan = widget.daftarLahan.firstWhere(
          (l) => l.idLahan == j.idLahan,
        );
      } catch (_) {
        if (widget.daftarLahan.isNotEmpty) {
          _selectedLahan = widget.daftarLahan.first;
        }
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // ──────────────── INPUT/EVENT: Buka Date Picker ────────────────
  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Pilih Tanggal Pelaksanaan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
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
      setState(() => _selectedTanggal = picked);
    }
  }

  // ──────────────── INPUT/EVENT: Tap Simpan ────────────────
  Future<void> _simpan() async {
    // Aktifkan auto-validate agar error tampil real-time setelah tap pertama
    setState(() => _autoValidate = true);

    // VALIDATION: Cek semua field
    final isValid = _formKey.currentState?.validate() ?? false;

    // Validasi tambahan untuk dropdown & date yang tidak di-handle oleh Form
    final lahanError = Validators.requiredDropdown(
      _selectedLahan,
      fieldName: 'Lahan',
    );
    final tanggalError = Validators.futureDate(
      _selectedTanggal,
      fieldName: 'Tanggal pelaksanaan',
    );

    if (!isValid || lahanError != null || tanggalError != null) {
      // FEEDBACK: Form tidak valid, user tetap di halaman form
      return;
    }

    // STATE: Mulai proses simpan
    setState(() => _isLoading = true);

    // Simulasi delay network (agar terlihat loading state)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (widget.jadwalToEdit != null) {
      // MODE EDIT: Kembalikan objek yang diperbarui
      final updated = widget.jadwalToEdit!.copyWith(
        namaKegiatan: _namaController.text.trim(),
        idLahan: _selectedLahan!.idLahan,
        namaLahan: _selectedLahan!.namaLahan,
        jenisPerawatan: _selectedJenis!,
        tanggalPelaksanaan: _selectedTanggal!,
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );
      Navigator.pop(context, updated);
    } else {
      // MODE TAMBAH BARU
      _idCounter++;
      final jadwalBaru = JadwalPerawatan(
        id: _idCounter,
        namaKegiatan: _namaController.text.trim(),
        idLahan: _selectedLahan!.idLahan,
        namaLahan: _selectedLahan!.namaLahan,
        jenisPerawatan: _selectedJenis!,
        tanggalPelaksanaan: _selectedTanggal!,
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
        tanggalDibuat: DateTime.now(),
      );
      Navigator.pop(context, jadwalBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.jadwalToEdit != null;
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
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
          // STATE: AutoValidateMode berubah setelah user pertama kali tap Simpan
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.p8),

              // ═══════ FIELD 1: Nama Kegiatan ═══════
              _buildSectionLabel('Nama Kegiatan *'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration(
                  hint: 'Contoh: Pemupukan Urea',
                  prefixIcon: Icons.edit_outlined,
                ),
                textInputAction: TextInputAction.next,
                // VALIDATION: Minimal 3 karakter
                validator: (value) => Validators.minLength(
                  value,
                  3,
                  fieldName: 'Nama kegiatan',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 2: Pilih Lahan (Dropdown) ═══════
              _buildSectionLabel('Pilih Lahan *'),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<Lahan>(
                initialValue: _selectedLahan,
                decoration: _inputDecoration(
                  hint: 'Pilih lahan',
                  prefixIcon: Icons.yard_outlined,
                ),
                items: widget.daftarLahan.map((lahan) {
                  return DropdownMenuItem<Lahan>(
                    value: lahan,
                    child: Text(
                      '${lahan.namaLahan} (${lahan.luasFormatted})',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                // STATE: Berubah saat user memilih lahan
                onChanged: (value) {
                  setState(() => _selectedLahan = value);
                },
                // VALIDATION: Wajib dipilih
                validator: (_) => Validators.requiredDropdown(
                  _selectedLahan,
                  fieldName: 'Lahan',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 3: Jenis Perawatan (Dropdown) ═══════
              _buildSectionLabel('Jenis Perawatan *'),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenis,
                decoration: _inputDecoration(
                  hint: 'Pilih jenis perawatan',
                  prefixIcon: Icons.category_outlined,
                ),
                items: JadwalPerawatan.daftarJenisPerawatan.map((jenis) {
                  return DropdownMenuItem<String>(
                    value: jenis,
                    child: Text(
                      jenis,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                // STATE: Berubah saat user memilih jenis
                onChanged: (value) {
                  setState(() => _selectedJenis = value);
                },
                // VALIDATION: Wajib dipilih
                validator: (_) => Validators.requiredDropdown(
                  _selectedJenis,
                  fieldName: 'Jenis perawatan',
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 4: Tanggal Pelaksanaan (Date Picker) ═══════
              _buildSectionLabel('Tanggal Pelaksanaan *'),
              const SizedBox(height: AppSpacing.p8),
              // INPUT/EVENT: Tap field → buka DatePicker
              GestureDetector(
                onTap: _pilihTanggal,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration(
                      hint: 'Pilih tanggal',
                      prefixIcon: Icons.calendar_today_outlined,
                      suffixIcon: Icons.arrow_drop_down,
                    ).copyWith(
                      // Tampilkan tanggal yang sudah dipilih
                      hintText: _selectedTanggal != null
                          ? _formatTanggal(_selectedTanggal!)
                          : 'Pilih tanggal',
                      hintStyle: _selectedTanggal != null
                          ? AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                            )
                          : null,
                    ),
                    // VALIDATION: Wajib diisi, tidak boleh masa lalu
                    validator: (_) => Validators.futureDate(
                      _selectedTanggal,
                      fieldName: 'Tanggal pelaksanaan',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 5: Catatan (Opsional) ═══════
              _buildSectionLabel('Catatan (opsional)'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: 'Tambahkan catatan perawatan...',
                  prefixIcon: Icons.note_alt_outlined,
                ),
                textInputAction: TextInputAction.done,
                // Tidak ada validasi — field opsional
              ),
              const SizedBox(height: AppSpacing.p32),

              // ═══════ TOMBOL SIMPAN ═══════
              // FEEDBACK: Loading indicator saat proses simpan
              SizedBox(
                height: AppSpacing.buttonHeight48,
                child: FilledButton(
                  // STATE: Disabled saat loading
                  onPressed: _isLoading ? null : _simpan,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedButton,
                    ),
                  ),
                  // FEEDBACK: Tombol berubah jadi loading indicator
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
                          isEdit ? 'Simpan Perubahan' : 'Simpan',
                          style: AppTextStyles.authButton.copyWith(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Helper: Label Section ────────────────
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
    );
  }

  // ──────────────── Helper: Input Decoration ────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.cardSubtitle.copyWith(fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: AppColors.textSecondary)
          : null,
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

  // ──────────────── Helper: Format Tanggal ────────────────
  String _formatTanggal(DateTime date) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }
}
