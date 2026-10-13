import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/referensi_komoditas.dart';
import '../../models/lahan.dart';
import '../../providers/lahan_provider.dart';
import '../../providers/perawatan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Layar Estimasi Hasil Panen (Modul 3: FR-16).
///
/// Logika & Aturan Bisnis (PRD v2.0 Bagian 2.5.2):
/// - Rumus: Estimasi (ton) = Luas (ha) × Produktivitas (ton/ha)
/// - Sumber data: DataReferensi.daftarKomoditas (BPS & Kementan)
/// - Menampilkan wilayah acuan data dan status verifikasi
/// - Respon kalkulasi real-time (NFR-05: ≤ 2 detik)
/// - Mode 1: Hitung dari data Lahan terdaftar
/// - Mode 2: Kalkulator mandiri / simulasi bebas
class EstimasiPanenScreen extends StatefulWidget {
  final Lahan? lahanAwal;

  const EstimasiPanenScreen({
    super.key,
    this.lahanAwal,
  });

  @override
  State<EstimasiPanenScreen> createState() => _EstimasiPanenScreenState();
}

class _EstimasiPanenScreenState extends State<EstimasiPanenScreen> {
  // Mode: 0 = Dari Lahan Terdaftar, 1 = Simulasi Bebas
  int _tabMode = 0;

  // State Mode 1: Lahan Terdaftar
  Lahan? _selectedLahan;

  // State Mode 2: Simulasi Bebas
  String _selectedKomoditasSimulasi = 'Padi';
  final _luasSimulasiController = TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _selectedLahan = widget.lahanAwal;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lahanProvider = context.read<LahanProvider>();
      if (_selectedLahan == null && lahanProvider.lahanList.isNotEmpty) {
        setState(() {
          _selectedLahan = lahanProvider.lahanList.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _luasSimulasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lahanProvider = context.watch<LahanProvider>();
    final daftarLahan = lahanProvider.lahanList;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Estimasi Hasil Panen',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══════ HEADER INFO BANNER ═══════
            _buildInfoBanner(),
            const SizedBox(height: AppSpacing.p16),

            // ═══════ TAB PEMILIH MODE ═══════
            _buildModeSelector(),
            const SizedBox(height: AppSpacing.p16),

            if (_tabMode == 0) ...[
              // MODE 1: DARI LAHAN TERDAFTAR
              _buildModeLahanTerdaftar(daftarLahan),
            ] else ...[
              // MODE 2: SIMULASI MANDIRI
              _buildModeSimulasi(),
            ],

            const SizedBox(height: AppSpacing.p24),

            // ═══════ TABEL REFERENSI BPS / KEMENTAN ═══════
            _buildTabelReferensi(),
            const SizedBox(height: AppSpacing.p24),
          ],
        ),
      ),
    );
  }

  // ──────────────── Info Banner PRD ────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p14),
      decoration: BoxDecoration(
        color: AppColors.chipGreenBg,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.p10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumus Estimasi Hasil Panen (PRD v2.0)',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Estimasi (ton) = Luas Lahan (ha) × Produktivitas (ton/ha)\n'
                  'Angka produktivitas merujuk data resmi BPS & Kementerian Pertanian.',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Pemilih Mode Tab ────────────────
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Dari Lahan Saya',
              icon: Icons.yard_outlined,
              isSelected: _tabMode == 0,
              onTap: () => setState(() => _tabMode = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Kalkulator Bebas',
              icon: Icons.calculate_outlined,
              isSelected: _tabMode == 1,
              onTap: () => setState(() => _tabMode = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── MODE 1: Lahan Terdaftar ────────────────
  Widget _buildModeLahanTerdaftar(List<Lahan> daftarLahan) {
    if (daftarLahan.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.p20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.iconMuted),
            const SizedBox(height: 12),
            Text(
              'Belum ada data lahan',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan lahan di Modul 1 terlebih dahulu atau gunakan mode Kalkulator Bebas.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      );
    }

    // Jika belum ada lahan terpilih, pilih yang pertama
    final lahan = _selectedLahan ?? daftarLahan.first;
    final komoditas = lahan.komoditasUtama;
    final luasHa = lahan.luasLahan;
    final referensi = PerawatanProvider.getReferensiKomoditas(komoditas);
    final hasilEstimasi = PerawatanProvider.hitungEstimasi(
      komoditas: komoditas,
      luasHa: luasHa,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown Pemilihan Lahan
        Container(
          padding: const EdgeInsets.all(AppSpacing.p16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Lahan Pertanian', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.p8),
              DropdownButtonFormField<Lahan>(
                initialValue: daftarLahan.contains(lahan) ? lahan : daftarLahan.first,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.roundedButton,
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.roundedButton,
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.roundedButton,
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.yard_outlined, color: AppColors.primary),
                ),
                items: daftarLahan.map((l) {
                  return DropdownMenuItem<Lahan>(
                    value: l,
                    child: Text(
                      '${l.namaLahan} • ${l.komoditasUtama} (${l.luasFormatted})',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLahan = val);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p16),

        // Hasil Perhitungan Lahan Terpilih
        _buildHasilKalkulasiCard(
          komoditas: komoditas,
          luasHa: luasHa,
          referensi: referensi,
          hasilTon: hasilEstimasi,
        ),
      ],
    );
  }

  // ──────────────── MODE 2: Simulasi Bebas ────────────────
  Widget _buildModeSimulasi() {
    final double? luasInput = double.tryParse(
      _luasSimulasiController.text.replaceAll(',', '.'),
    );
    final referensi = PerawatanProvider.getReferensiKomoditas(
      _selectedKomoditasSimulasi,
    );
    final double? hasilTon = (luasInput != null && referensi != null)
        ? luasInput * referensi.produktivitas
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.p16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parameter Simulasi', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.p12),

              // Dropdown Komoditas
              Text(
                'Komoditas Pertanian',
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedKomoditasSimulasi,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.roundedButton,
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  prefixIcon: const Icon(Icons.grass_outlined, color: AppColors.primary),
                ),
                items: DataReferensi.daftarKomoditas.map((k) {
                  return DropdownMenuItem<String>(
                    value: k.nama,
                    child: Text(
                      '${k.nama} (Prod: ${k.produktivitas} ton/ha)',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedKomoditasSimulasi = val);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.p16),

              // Input Luas Lahan (ha)
              Text(
                'Luas Lahan (Hektare / ha)',
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _luasSimulasiController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Contoh: 0.5 atau 2.0',
                  suffixText: 'ha',
                  suffixStyle: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.roundedButton,
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  prefixIcon: const Icon(Icons.square_foot_outlined, color: AppColors.primary),
                ),
                onChanged: (_) {
                  // Real-time update (NFR-05)
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p16),

        // Hasil Perhitungan Simulasi
        _buildHasilKalkulasiCard(
          komoditas: _selectedKomoditasSimulasi,
          luasHa: luasInput ?? 0.0,
          referensi: referensi,
          hasilTon: hasilTon,
        ),
      ],
    );
  }

  // ──────────────── Kartu Tampilan Hasil Kalkulasi ────────────────
  Widget _buildHasilKalkulasiCard({
    required String komoditas,
    required double luasHa,
    required ReferensiKomoditas? referensi,
    required double? hasilTon,
  }) {
    const warningColor = Color(0xFFE65100);

    if (referensi == null || hasilTon == null || luasHa <= 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.p20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: warningColor,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              'Estimasi Belum Dapat Dihitung',
              style: AppTextStyles.cardTitle.copyWith(
                color: warningColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              referensi == null
                  ? 'Data produktivitas komoditas "$komoditas" belum tersedia dalam basis data referensi BPS/Kementan.'
                  : 'Pastikan luas lahan diisi dengan angka positif yang valid.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      );
    }

    final double hasilKg = hasilTon * 1000;
    final double hasilKuintal = hasilTon * 10;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROYEKSI HASIL PANEN',
                style: AppTextStyles.cardSubtitle.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Otomatis FR-16',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.chipGreenText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p14),

          // Angka Utama (Ton)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasilTon.toStringAsFixed(3),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ton',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Konversi alternatif
          Text(
            '≈ ${hasilKg.toStringAsFixed(1)} kg  |  ≈ ${hasilKuintal.toStringAsFixed(2)} kuintal',
            style: AppTextStyles.cardSubtitle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 28),

          // Rincian Kalkulasi
          _buildDetailRow(
            label: 'Komoditas',
            value: referensi.nama,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Luas Lahan',
            value: '${luasHa.toStringAsFixed(2)} ha',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Produktivitas Acuan',
            value: '${referensi.produktivitas} ton/ha',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Wilayah Acuan',
            value: referensi.wilayahAcuan,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'Status Verifikasi',
            value: referensi.statusVerifikasi,
            valueColor: AppColors.primaryNav,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
        ),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ──────────────── Tabel Referensi 6 Komoditas (Tabel PRD 2.5.2) ────────────────
  Widget _buildTabelReferensi() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tabel Referensi Produktivitas (PRD 2.5.2)',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: DataReferensi.daftarKomoditas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final k = DataReferensi.daftarKomoditas[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            k.nama,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Acuan: ${k.wilayahAcuan}',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${k.produktivitas} ton/ha',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.p12),
            child: Text(
              'Sumber data: Publikasi BPS & Kementerian Pertanian Republik Indonesia.',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
