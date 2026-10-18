import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/referensi_komoditas.dart';
import '../../models/lahan.dart';
import '../../models/siklus_tanam.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/perawatan_provider.dart';
import '../../providers/siklus_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/jadwal_success_dialog.dart';

/// Layar Form Tambah Siklus Tanam Baru (Modul 1: FR-05).
///
/// Workflow 5 Tahap:
/// 1. INPUT / EVENT  → User memilih lahan (jika belum terpilih), memilih 1 dari 6 komoditas PRD,
///                      menentukan tanggal mulai/rencana tanam, dan catatan opsional.
/// 2. STATE        → Menyimpan state form lokal, tanggal terpilih, dan status loading.
/// 3. VALIDATION   → Memvalidasi kelengkapan data input (1 lahan dapat memiliki beberapa siklus tanam).
/// 4. FEEDBACK     → Indikator loading tombol & modal dialog sukses jadwal perawatan ter-generate.
/// 5. NAVIGATION   → Simpan ke SiklusProvider, otomatis trigger jadwal otomatis, pop kembali.
class TambahSiklusScreen extends StatefulWidget {
  /// Lahan yang sudah ditentukan sebelumnya (misal dibuka dari Detail Lahan)
  final Lahan? lahanTerpilih;

  const TambahSiklusScreen({super.key, this.lahanTerpilih});

  @override
  State<TambahSiklusScreen> createState() => _TambahSiklusScreenState();
}

class _TambahSiklusScreenState extends State<TambahSiklusScreen> {
  final _formKey = GlobalKey<FormState>();

  // State
  Lahan? _selectedLahan;
  String? _selectedKomoditas;
  DateTime? _selectedTanggal;
  final _catatanController = TextEditingController();

  bool _isLoading = false;
  bool _autoValidate = false;

  // 6 Komoditas resmi sesuai PRD AgroPlan Bagian 2.5.1
  static const List<String> enamKomoditas = [
    'Padi',
    'Jagung',
    'Kedelai',
    'Cabai Merah',
    'Bawang Merah',
    'Tomat',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLahan = widget.lahanTerpilih;
    // Default tanggal rencana tanam adalah hari ini
    _selectedTanggal = DateTime.now();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  /// Date picker untuk memilih tanggal rencana/mulai tanam
  Future<void> _pilihTanggal(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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

  /// Format tanggal ramah pengguna
  String _formatTanggal(DateTime dt) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  // ──────────────── 1. INPUT / EVENT: Simpan Siklus Tanam ────────────────
  Future<void> _simpan() async {
    setState(() => _autoValidate = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedLahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih lahan terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tentukan tanggal rencana tanam'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final siklusProvider = context.read<SiklusProvider>();
    final perawatanProvider = context.read<PerawatanProvider>();

    // ──────────────── 2. STATE: Set loading ────────────────
    setState(() => _isLoading = true);

    final siklusBaru = SiklusTanam(
      idSiklus: DateTime.now().millisecondsSinceEpoch % 100000,
      idLahan: _selectedLahan!.idLahan,
      namaLahan: _selectedLahan!.namaLahan,
      komoditas: _selectedKomoditas!,
      tanggalRencanaTanam: _selectedTanggal!,
      tanggalTanamAktual: _selectedTanggal!,
      statusSiklus: 'Berjalan',
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      tanggalDibuat: DateTime.now(),
    );

    final success = await siklusProvider.tambahSiklus(
      siklus: siklusBaru,
      lahan: _selectedLahan,
      lahanProvider: context.read<LahanProvider>(),
      perawatanProvider: perawatanProvider,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // ──────────────── 4. FEEDBACK: Dialog Sukses ────────────────
      await JadwalSuccessDialog.show(
        context,
        imagePath: 'assets/images/success_lahan.png',
        title: 'Siklus tanam\nberhasil dimulai!',
        subtitle:
            'Siklus baru untuk komoditas $_selectedKomoditas di ${_selectedLahan!.namaLahan} telah aktif. Jadwal perawatan otomatis telah dibuat sesuai panduan budidaya.',
      );

      // ──────────────── 5. NAVIGATION / RESULT ────────────────
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            siklusProvider.errorMessage ?? 'Gagal menambahkan siklus tanam',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lahanProvider = context.watch<LahanProvider>();
    final daftarLahan = lahanProvider.lahanList;

    // Ambil info produktivitas referensi komoditas terpilih
    final refKomoditas = _selectedKomoditas != null
        ? DataReferensi.cariKomoditas(_selectedKomoditas!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Mulai Siklus Tanam Baru',
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
              // ═══════ BANNER INFORMASI SIKLUS TANAM ═══════
              Container(
                padding: const EdgeInsets.all(AppSpacing.p14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Satu lahan dapat memiliki lebih dari satu siklus tanam aktif (untuk sistem tumpang sari atau aneka komoditas). Setiap siklus akan mendapatkan jadwal perawatan otomatisnya masing-masing.',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 1: PILIH LAHAN ═══════
              _buildSectionLabel('Pilih Lahan Pertanian *'),
              const SizedBox(height: AppSpacing.p8),
              if (widget.lahanTerpilih != null)
                // Jika sudah terkunci dari Detail Lahan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSpacing.roundedCard,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.landscape, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lahanTerpilih!.namaLahan,
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                            ),
                            Text(
                              '${widget.lahanTerpilih!.luasFormatted} • ${widget.lahanTerpilih!.lokasi ?? 'Lokasi'}',
                              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.lock_outline, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                )
              else
                // Dropdown pilihan lahan
                DropdownButtonFormField<int>(
                  initialValue: _selectedLahan?.idLahan,
                  decoration: _inputDecoration(
                    hint: 'Pilih lahan yang akan ditanami',
                    prefixIcon: Icons.landscape_outlined,
                  ),
                  items: daftarLahan.map((l) {
                    return DropdownMenuItem<int>(
                      value: l.idLahan,
                      child: Text(
                        '${l.namaLahan} (${l.luasFormatted})',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      setState(() {
                        _selectedLahan = daftarLahan.firstWhere((l) => l.idLahan == id);
                      });
                    }
                  },
                  validator: (_) => _selectedLahan == null ? 'Lahan wajib dipilih' : null,
                ),

              // Info jika lahan sudah memiliki siklus tanam aktif sebelumnya
              if (_selectedLahan != null) ...[
                Builder(
                  builder: (context) {
                    final siklusAktif = context
                        .watch<SiklusProvider>()
                        .getDaftarSiklusAktif(_selectedLahan!.idLahan);
                    if (siklusAktif.isEmpty) return const SizedBox.shrink();
                    final komoditasAktif =
                        siklusAktif.map((s) => '${s.komoditas} (${s.hst} HST)').join(', ');
                    return Container(
                      margin: const EdgeInsets.only(top: AppSpacing.p8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p12,
                        vertical: AppSpacing.p10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lahan ini memiliki ${siklusAktif.length} siklus aktif: $komoditasAktif. Siklus tanam baru akan ditambahkan ke lahan ini.',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 2: PILIH ENAM KOMODITAS RESMI (FR-05) ═══════
              _buildSectionLabel('Komoditas yang Ditanam (6 Komoditas Resmi) *'),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<String>(
                initialValue: _selectedKomoditas,
                decoration: _inputDecoration(
                  hint: 'Pilih komoditas tanaman',
                  prefixIcon: Icons.grass_outlined,
                ),
                items: enamKomoditas.map((k) {
                  return DropdownMenuItem<String>(
                    value: k,
                    child: Text(
                      k,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedKomoditas = val),
                validator: (val) => Validators.requiredDropdown(
                  val,
                  fieldName: 'Komoditas',
                ),
              ),

              // Highlight info produktivitas PRD jika komoditas dipilih
              if (refKomoditas != null) ...[
                const SizedBox(height: AppSpacing.p8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.chipGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Produktivitas acuan: ${refKomoditas.produktivitas} ton/ha (${refKomoditas.wilayahAcuan})',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 3: TANGGAL RENCANA / MULAI TANAM ═══════
              _buildSectionLabel('Tanggal Mulai / Rencana Tanam *'),
              const SizedBox(height: AppSpacing.p8),
              InkWell(
                borderRadius: AppSpacing.roundedCard,
                onTap: () => _pilihTanggal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSpacing.roundedCard,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTanggal != null
                              ? _formatTanggal(_selectedTanggal!)
                              : 'Pilih tanggal tanam',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selectedTanggal != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p20),

              // ═══════ FIELD 4: CATATAN (OPSIONAL) ═══════
              _buildSectionLabel('Catatan Siklus (Opsional)'),
              const SizedBox(height: AppSpacing.p8),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: 'Misal: Varietas bibit, pola tanam, atau target hasil',
                  prefixIcon: Icons.notes_outlined,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.p32),

              // ═══════ TOMBOL SUBMIT ═══════
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
                          'Mulai Siklus Tanam',
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
      style: AppTextStyles.cardTitle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.cardSubtitle.copyWith(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
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
