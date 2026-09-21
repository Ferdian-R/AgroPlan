import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Kartu menu 2-kolom pada seksi Menu Utama.
/// - [isFirst]: true untuk kartu "Siklus Tanam" yang memakai latar #E8F5E9 dan teks primary.
/// - Lainnya memakai latar semi-transparan rgba(193,236,212,0.5).
class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isFirst;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isFirst = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFirst ? AppColors.menuCardFirst : AppColors.menuCard;
    final titleColor = isFirst ? AppColors.primary : AppColors.textPrimary;
    final arrowColor = isFirst ? AppColors.primary : AppColors.primaryNav;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Baris Ikon & Tombol Panah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kotak Ikon dengan Overlay Putih 80%
                    Container(
                      width: 36,
                      height: 36,
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
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: arrowColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p14),

                // Judul & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(color: titleColor),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
