import 'package:flutter/material.dart';

/// Model entitas Laporan Kondisi Lahan 
class LaporanKondisi {
  final int id;
  final int idLahan;
  final int? idSiklus;
  final String namaLahan;
  final DateTime tanggalLapor;
  final String jenisKondisi;
  final String catatan;
  final String? fotoUrl;

  const LaporanKondisi({
    required this.id,
    required this.idLahan,
    this.idSiklus,
    required this.namaLahan,
    required this.tanggalLapor,
    required this.jenisKondisi,
    required this.catatan,
    this.fotoUrl,
  });

  static const List<String> daftarJenisKondisiResmi = [
    'Normal',
    'Hama',
    'Kekeringan',
    'Banjir',
    'Lainnya',
  ];

  bool get isNormal => jenisKondisi.toLowerCase() == 'normal';
  bool get isBermasalah => !isNormal;
  bool get hasFoto => fotoUrl != null && fotoUrl!.trim().isNotEmpty;

  String get formattedTanggal =>
      '${tanggalLapor.day.toString().padLeft(2, '0')} '
      '${['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][tanggalLapor.month]} '
      '${tanggalLapor.year}';

  Color get warnaKondisi {
    final k = jenisKondisi.toLowerCase();
    if (k == 'normal') return const Color(0xFF388E3C);
    if (k.contains('hama')) return const Color(0xFFD32F2F);
    if (k.contains('kering')) return const Color(0xFFF57C00);
    if (k.contains('banjir')) return const Color(0xFF1976D2);
    return const Color(0xFF7B1FA2);
  }

  Color get backgroundWarnaKondisi {
    final k = jenisKondisi.toLowerCase();
    if (k == 'normal') return const Color(0xFFE8F5E9);
    if (k.contains('hama')) return const Color(0xFFFFEBEE);
    if (k.contains('kering')) return const Color(0xFFFFF3E0);
    if (k.contains('banjir')) return const Color(0xFFE3F2FD);
    return const Color(0xFFF3E5F5);
  }

  IconData get iconJenisKondisi {
    final k = jenisKondisi.toLowerCase();
    if (k.contains('hama')) return Icons.bug_report_outlined;
    if (k.contains('kering')) return Icons.wb_sunny_outlined;
    if (k.contains('banjir')) return Icons.water_drop_outlined;
    if (k == 'normal') return Icons.check_circle_outline;
    return Icons.warning_amber_outlined;
  }

  LaporanKondisi copyWith({
    int? id,
    int? idLahan,
    int? idSiklus,
    String? namaLahan,
    DateTime? tanggalLapor,
    String? jenisKondisi,
    String? catatan,
    String? fotoUrl,
  }) {
    return LaporanKondisi(
      id: id ?? this.id,
      idLahan: idLahan ?? this.idLahan,
      idSiklus: idSiklus ?? this.idSiklus,
      namaLahan: namaLahan ?? this.namaLahan,
      tanggalLapor: tanggalLapor ?? this.tanggalLapor,
      jenisKondisi: jenisKondisi ?? this.jenisKondisi,
      catatan: catatan ?? this.catatan,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_lahan': idLahan,
        'id_siklus': idSiklus,
        'nama_lahan': namaLahan,
        'tanggal_lapor': tanggalLapor.toIso8601String(),
        'jenis_kondisi': jenisKondisi,
        'catatan': catatan,
        'foto_url': fotoUrl,
      };

  factory LaporanKondisi.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_laporan'] ?? json['id'];
    final rawIdLahan = json['id_lahan'];
    final rawIdSiklus = json['id_siklus'];
    return LaporanKondisi(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      idLahan: rawIdLahan is int ? rawIdLahan : int.parse(rawIdLahan.toString()),
      idSiklus: rawIdSiklus != null
          ? (rawIdSiklus is int ? rawIdSiklus : int.parse(rawIdSiklus.toString()))
          : null,
      namaLahan: json['nama_lahan'] as String? ?? 'Lahan',
      tanggalLapor: DateTime.parse(json['tanggal_lapor'] as String),
      jenisKondisi: json['jenis_kondisi'] as String,
      catatan: json['catatan'] as String? ?? '',
      fotoUrl: json['foto_url'] as String?,
    );
  }
}
