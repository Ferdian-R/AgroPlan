import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Kartu menu selebar penuh untuk "Riwayat Panen" pada baris terakhir seksi Menu Utama.
/// Memiliki kotak ikon di kiri, teks di tengah, dan tombol panah bulat di kanan.
class WideMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const WideMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.menuCard,
        borderRadius: AppSpacing.roundedCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p14,
              vertical: AppSpacing.p12,
            ),
            child: Row(
              children: [
                // Kotak Ikon Kiri (Overlay Putih 80%)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.menuIconOverlay,
                    borderRadius: AppSpacing.roundedMenuIcon,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.p12),

                // Teks Judul & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.p2),
                      Text(
                        subtitle,
                        style: AppTextStyles.cardSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tombol Panah Bulat di Kanan
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.menuIconOverlay,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primaryNav,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
