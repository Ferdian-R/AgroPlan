import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Kartu informasi cuaca statis di Beranda sesuai visual Figma.
///
/// PERHATIAN (Catatan PRD vs Figma):
/// Berdasarkan PRD AgroPlan Bagian 3.2, integrasi API cuaca real-time maupun
/// fitur prediksi cuaca adalah OUT OF SCOPE.
/// Sesuai instruksi pengguna, widget ini dibuat murni statis tanpa pemanggilan HTTP
/// dan tanpa logika prediksi cuaca.
///
/// TODO (Rekomendasi Alternatif Masa Depan):
/// Ganti widget ini dengan "Ringkasan Siklus Aktif" (Modul 1-3) yang menampilkan:
/// - Nama siklus tanam aktif & hari setelah tanam (HST)
/// - Tanggal jadwal perawatan terdekat (Modul 3)
/// - Status risiko saat ini (Normal / Risiko Tinggi) (Modul 2)
class WeatherInfoCard extends StatelessWidget {
  final VoidCallback? onTap;

  const WeatherInfoCard({
    super.key,
    this.onTap,
  });

  // Nilai statis sesuai mockup Figma
  static const String staticCity = 'Kota Padang';
  static const String staticTemp = '26°C';
  static const String staticCondition = 'Berawan';
  static const String staticHumidity = '78%';
  static const String staticWindSpeed = '12 km/h';
  static const String staticLastUpdated = 'Diperbarui 13 Sep 2026, 06:00 WIB';
  static const String staticStatusBadge = 'Kondisi Ideal Tanam';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Cuaca Utama & Parameter Angin/Kelembaban
          Row(
            children: [
              // Ikon Cuaca Matahari
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.weatherIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.weatherSun,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.p12),

              // Lokasi & Temperatur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          staticCity,
                          style: AppTextStyles.weatherSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          staticTemp,
                          style: AppTextStyles.weatherTemp,
                        ),
                        const SizedBox(width: AppSpacing.p6),
                        Text(
                          staticCondition,
                          style: AppTextStyles.locationText.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Garis Pemisah Vertikal
              Container(
                width: 1,
                height: 36,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
              ),

              // Kelembapan & Kecepatan Angin
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                staticHumidity,
                                style: AppTextStyles.weatherSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.air,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                staticWindSpeed,
                                style: AppTextStyles.weatherSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.p10),

          // Baris Bawah: Waktu Pembaruan & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.p4),
                  Text(
                    staticLastUpdated,
                    style: AppTextStyles.weatherSmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipGreenBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                ),
                child: Text(
                  staticStatusBadge,
                  style: AppTextStyles.chipText.copyWith(
                    color: AppColors.chipGreenText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
