import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Header utama aplikasi AgroPlan (tinggi 64 dp) dengan logo, nama, tagline,
/// tombol notifikasi ber-badge titik merah, dan avatar profil.
class AppHeader extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  const AppHeader({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo AgroPlan dengan fallback ikon tanaman
            _buildLogo(),
            const SizedBox(width: AppSpacing.p10),

            // Nama Aplikasi & Tagline
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AgroPlan',
                    style: AppTextStyles.appName,
                  ),
                  Text(
                    'Bertani Lebih Terencana',
                    style: AppTextStyles.appTagline,
                  ),
                ],
              ),
            ),

            // Ikon Lonceng Notifikasi dengan Titik Merah
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: onNotificationPressed,
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.badgeRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.p4),

            // Avatar Bulat Hijau
            GestureDetector(
              onTap: onProfilePressed,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Image.asset(
          'assets/images/logo_agroplan.webp',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback jika aset logo belum ada
            return Container(
              decoration: BoxDecoration(
                color: AppColors.chipGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
