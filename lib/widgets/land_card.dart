import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/lahan.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'status_chip.dart';

/// Kartu data lahan di bagian "Lahan Saya" pada Beranda.
/// Memuat foto rasio 4:3, tombol menu titik tiga, nama lahan, chip komoditas, dan lokasi.
class LandCard extends StatelessWidget {
  final Lahan lahan;
  final VoidCallback? onTap;
  final VoidCallback? onMenuPressed;

  const LandCard({
    super.key,
    required this.lahan,
    this.onTap,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPadi = lahan.komoditasUtama.toLowerCase().contains('padi');
    final chipVariant = isPadi ? StatusChipVariant.green : StatusChipVariant.grey;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Area Foto dengan Tombol Titik Tiga ---
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppSpacing.roundedPhoto,
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _buildPhoto(),
                      ),
                    ),
                    // Tombol Titik Tiga Bulat (Ukuran 28 dp sesuai Figma)
                    Positioned(
                      top: AppSpacing.p6,
                      right: AppSpacing.p6,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onMenuPressed,
                          child: const SizedBox(
                            width: AppSpacing.threeDotSize,
                            height: AppSpacing.threeDotSize,
                            child: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p10),

                // --- Nama Lahan ---
                Text(
                  lahan.namaLahan,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.p6),

                // --- Chip Komoditas & Luas ---
                StatusChip(
                  label: lahan.chipText,
                  variant: chipVariant,
                ),
                const SizedBox(height: AppSpacing.p8),

                // --- Lokasi Lahan ---
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.p4),
                    Expanded(
                      child: Text(
                        lahan.lokasi ?? 'Lokasi belum diatur',
                        style: AppTextStyles.locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildPhoto() {
    if (lahan.fotoUrl == null || lahan.fotoUrl!.isEmpty) {
      return _buildPhotoFallback();
    }
    final url = lahan.fotoUrl!;
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPhotoFallback(),
      );
    } else if (kIsWeb ||
        url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPhotoFallback(),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPhotoFallback(),
      );
    }
  }

  /// Placeholder berwarna ketika aset gambar belum diekspor dari Figma
  Widget _buildPhotoFallback() {
    final isPadi = lahan.komoditasUtama.toLowerCase().contains('padi');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPadi
              ? [const Color(0xFFA5D6A7), const Color(0xFF81C784)]
              : [const Color(0xFFFFE082), const Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          isPadi ? Icons.grass : Icons.eco,
          color: Colors.white.withValues(alpha: 0.8),
          size: 32,
        ),
      ),
    );
  }
}
