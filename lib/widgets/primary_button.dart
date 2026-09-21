import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tombol utama AgroPlan yang mendukung varian Auth dan Home (+ Tambah Lahan).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final bool hasShadow;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.height = AppSpacing.buttonHeight48,
    this.borderRadius = AppSpacing.radiusButton,
    this.textStyle,
    this.prefixIcon,
    this.hasShadow = false,
  });

  /// Varian tombol untuk halaman Auth (radius 10, authPrimary)
  factory PrimaryButton.auth({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.authPrimary,
      borderRadius: AppSpacing.radiusAuthButton,
      height: AppSpacing.buttonHeight48,
      textStyle: AppTextStyles.authButton,
      hasShadow: false,
    );
  }

  /// Varian tombol untuk Home "+ Tambah Lahan" (tinggi 44, radius 12, primary, soft shadow)
  factory PrimaryButton.homeAction({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Widget? prefixIcon,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      borderRadius: AppSpacing.radiusButton,
      height: AppSpacing.buttonHeight44,
      textStyle: AppTextStyles.authButton.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: prefixIcon,
      hasShadow: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: AppSpacing.p8),
                    ],
                    Text(
                      text,
                      style: textStyle ?? AppTextStyles.authButton,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
