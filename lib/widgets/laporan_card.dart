import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/laporan_kondisi.dart';
import '../theme/app_colors.dart';

/// Kartu tampilan laporan kondisi lahan (Modul 2)
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: laporan.isBermasalah ? AppColors.error.withValues(alpha: 0.3) : AppColors.divider,
          width: laporan.isBermasalah ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Atas: Badge Jenis Kondisi, Badge Foto, & Menu Titik Tiga
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: laporan.backgroundWarnaKondisi,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(laporan.iconJenisKondisi, size: 13, color: laporan.warnaKondisi),
                        const SizedBox(width: 4),
                        Text(
                          laporan.jenisKondisi,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: laporan.warnaKondisi,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (laporan.hasFoto) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Ada Foto',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (laporan.isBermasalah) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Perlu Penanganan',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Ubah Laporan')]),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.error))]),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Baris Tengah: Thumbnail & Info Laporan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(width: 68, height: 68, child: _buildThumbnail()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.namaLahan,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          laporan.catatan,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Baris Bawah: Tanggal Lapor & ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dilaporkan: ${laporan.formattedTanggal}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    '#LP-${laporan.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (laporan.fotoUrl == null || laporan.fotoUrl!.isEmpty) {
      return Container(
        color: AppColors.chipGreenBg,
        child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
      );
    }
    final url = laporan.fotoUrl!;
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    } else if (kIsWeb || url.startsWith('http') || url.startsWith('blob:')) {
      return Image.network(url, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _errorThumb());
    } else {
      return Image.file(File(url), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _errorThumb());
    }
  }

  Widget _errorThumb() => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );
}
