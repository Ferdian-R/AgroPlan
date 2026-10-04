import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/laporan_kondisi.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Kartu tampilan laporan kondisi lahan (Modul 2: FR-09).
/// Mendukung foto dari Web (blob/url), Mobile (kamera/galeri), maupun Aset lokal.
class LaporanCard extends StatelessWidget {
  final LaporanKondisi laporan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LaporanCard({
    super.key,
    required this.laporan,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: laporan.isRisikoTinggi
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.divider,
          width: laporan.isRisikoTinggi ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedCard,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Badge Keparahan, Badge Risiko Tinggi, & Menu
                Row(
                  children: [
                    // Badge Tingkat Keparahan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: laporan.backgroundWarnaKeparahan,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Keparahan: ${laporan.tingkatKeparahan}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: laporan.warnaKeparahan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge Risiko Tinggi (jika ada)
                    if (laporan.isRisikoTinggi)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFEF5350),
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 13,
                              color: Color(0xFFD32F2F),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Risiko Tinggi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Menu Edit/Hapus
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (val) {
                          if (val == 'edit') onEdit?.call();
                          if (val == 'delete') onDelete?.call();
                        },
                        itemBuilder: (ctx) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ubah Laporan'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.p12),

                // Konten Tengah: Foto Thumbnail & Rincian Laporan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Bukti Lapangan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: _buildThumbnail(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),

                    // Info Laporan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Lahan
                          Text(
                            laporan.namaLahan,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Jenis Kondisi + Ikon
                          Row(
                            children: [
                              Icon(
                                laporan.iconJenisKondisi,
                                size: 15,
                                color: laporan.warnaKeparahan,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  laporan.jenisKondisi,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: laporan.warnaKeparahan,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Catatan Observasi
                          Text(
                            laporan.catatan,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 16),

                // Baris Bawah: Tanggal Lapor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dilaporkan: ${laporan.formattedTanggal}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ID: #LP-${laporan.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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

  Widget _buildThumbnail() {
    if (laporan.fotoUrl == null || laporan.fotoUrl!.isEmpty) {
      return Container(
        color: AppColors.chipGreenBg,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.primary,
          size: 32,
        ),
      );
    }
    final url = laporan.fotoUrl!;
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackThumbnail(),
      );
    } else if (kIsWeb ||
        url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackThumbnail(),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackThumbnail(),
      );
    }
  }

  Widget _fallbackThumbnail() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }
}
