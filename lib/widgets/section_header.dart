import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Header judul seksi dengan opsi tautan tindakan (misal: "Lihat semua >").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle,
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionPressed,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText!,
                  style: AppTextStyles.linkSection,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: AppTextStyles.linkSection.color,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
