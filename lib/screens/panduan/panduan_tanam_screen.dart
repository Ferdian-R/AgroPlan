import 'package:flutter/material.dart';
import '../../data/referensi_komoditas.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Layar Panduan Tanam & Budidaya Komoditas
/// Menampilkan referensi siklus, produktivitas, dan template perawatan komoditas.
class PanduanTanamScreen extends StatefulWidget {
  const PanduanTanamScreen({super.key});

  @override
  State<PanduanTanamScreen> createState() => _PanduanTanamScreenState();
}

class _PanduanTanamScreenState extends State<PanduanTanamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ReferensiKomoditas> _komoditasList = DataReferensi.daftarKomoditas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _komoditasList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getKomoditasIcon(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('padi')) return Icons.grass_rounded;
    if (lower.contains('jagung')) return Icons.eco_rounded;
    if (lower.contains('cabai')) return Icons.local_fire_department_rounded;
    if (lower.contains('bawang')) return Icons.spa_rounded;
    if (lower.contains('kedelai')) return Icons.grain_rounded;
    return Icons.nature_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Panduan Tanam & Budidaya'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.cardTitle.copyWith(fontSize: 13),
          tabs: _komoditasList.map((k) {
            return Tab(
              icon: Icon(_getKomoditasIcon(k.nama), size: 18),
              text: k.nama,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _komoditasList.map((komoditas) {
          final templates = DataReferensi.templateJadwal
              .where((t) =>
                  t.komoditas.toLowerCase() == komoditas.nama.toLowerCase())
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // Header Ringkasan Komoditas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.chipGreenBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getKomoditasIcon(komoditas.nama),
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            komoditas.nama,
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Potensi Panen: ${komoditas.produktivitas.toStringAsFixed(2)} ton/ha',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12.5,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subheading Jadwal Perawatan Standar
              Row(
                children: [
                  const Icon(Icons.timeline_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tahapan & Jadwal Perawatan Rekomendasi',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Daftar Kegiatan
              if (templates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Belum ada data tahapan perawatan untuk komoditas ini.'),
                  ),
                )
              else
                ...templates.map((t) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '${t.hstPengingat} HST',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.namaKegiatan,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Waktu anjuran: ${t.waktuSumber}',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
