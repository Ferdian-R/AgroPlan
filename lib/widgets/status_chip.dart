import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum StatusChipVariant {
  green,
  grey,
}

/// Chip indikator komoditas dan luas lahan pada kartu lahan.
/// Varian:
/// - [StatusChipVariant.green]: #E8F5E9 dengan teks #0F5238 (misal: "0,5 ha • Padi")
/// - [StatusChipVariant.grey]: #E7E9E5 dengan teks #404943 (misal: "0,3 ha • Jagung")
class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipVariant variant;

  const StatusChip({
    super.key,
    required this.label,
    this.variant = StatusChipVariant.green,
  });

  @override
  Widget build(BuildContext context) {
    final isGreen = variant == StatusChipVariant.green;
    final bgColor = isGreen ? AppColors.chipGreenBg : AppColors.chipGreyBg;
    final textColor = isGreen ? AppColors.chipGreenText : AppColors.chipGreyText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p8,
        vertical: AppSpacing.p4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Text(
        label,
        style: AppTextStyles.chipText.copyWith(color: textColor),
      ),
    );
  }
}
