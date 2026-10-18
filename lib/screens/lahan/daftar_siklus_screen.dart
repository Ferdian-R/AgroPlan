import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/siklus_tanam.dart';
import '../../providers/siklus_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../perawatan/jadwal_list_screen.dart';
import 'tambah_siklus_screen.dart';

/// Layar Daftar Seluruh Siklus Tanam (Modul 1: FR-05).
/// Menampilkan siklus aktif dan riwayat siklus tanam di semua lahan.
class DaftarSiklusScreen extends StatelessWidget {
  const DaftarSiklusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        appBar: AppBar(
          title: Text(
            'Siklus Tanam',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Sedang Berjalan'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: Consumer<SiklusProvider>(
          builder: (context, provider, _) {
            final semuaSiklus = provider.siklusList;
            final aktifList = semuaSiklus.where((s) => s.isBerjalan).toList();
            final selesaiList = semuaSiklus.where((s) => !s.isBerjalan).toList();

            return TabBarView(
              children: [
                _buildListTab(context, aktifList, isAktif: true),
                _buildListTab(context, selesaiList, isAktif: false),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab_siklus',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TambahSiklusScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Mulai Siklus Baru'),
        ),
      ),
    );
  }

  Widget _buildListTab(BuildContext context, List<SiklusTanam> list, {required bool isAktif}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isAktif ? Icons.spa_outlined : Icons.check_circle_outline,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              Text(
                isAktif ? 'Tidak Ada Siklus Aktif' : 'Belum Ada Siklus Selesai',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.p8),
              Text(
                isAktif
                    ? 'Tekan tombol "+ Mulai Siklus Baru" untuk merencanakan komoditas dan jadwal tanam Anda.'
                    : 'Riwayat siklus yang telah dipanen akan tersimpan di sini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.p16,
        AppSpacing.screenPadding,
        100, // Ruang untuk FAB
      ),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.p12),
      itemBuilder: (context, index) {
        final siklus = list[index];
        return _buildSiklusCard(context, siklus);
      },
    );
  }

  Widget _buildSiklusCard(BuildContext context, SiklusTanam siklus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: siklus.isBerjalan
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: () {
            // Aksi melihat jadwal perawatan terkait siklus ini
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JadwalListScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: siklus.isBerjalan
                                ? AppColors.chipGreenBg
                                : AppColors.chipGreyBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.spa,
                            color: siklus.isBerjalan
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              siklus.komoditas,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              siklus.namaLahan,
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (siklus.isBerjalan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${siklus.hst} HST',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipGreyBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          siklus.statusSiklus,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mulai Tanam: ${siklus.formattedTanggalTanam}',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
