import 'package:flutter/material.dart';

/// Model entitas Laporan Kondisi Lahan (Modul 2: Monitoring Kondisi Lahan & Peringatan Dini).
/// Sesuai PRD AgroPlan Kelompok 8 (FR-07, FR-08, FR-09, FR-10, FR-11, FR-12).
class LaporanKondisi {
  final int id;
  final int idLahan;
  final String namaLahan;
  final DateTime tanggalLapor;
  final String jenisKondisi; // Normal, Serangan Hama/Penyakit, Kekeringan, Banjir, Kurang Nutrisi, Lainnya
  final String tingkatKeparahan; // Rendah, Sedang, Berat
  final String catatan;
  final String? fotoUrl; // Path lokal (kamera/galeri) atau URL / blob / aset
  final String statusRisiko; // Normal, Risiko Tinggi (FR-12)

  const LaporanKondisi({
    required this.id,
    required this.idLahan,
    required this.namaLahan,
    required this.tanggalLapor,
    required this.jenisKondisi,
    required this.tingkatKeparahan,
    required this.catatan,
    this.fotoUrl,
    required this.statusRisiko,
  });

  /// Evaluasi otomatis status risiko berdasarkan keparahan dan jenis kondisi (FR-12)
  static String tentukanStatusRisiko({
    required String jenisKondisi,
    required String tingkatKeparahan,
  }) {
    if (tingkatKeparahan == 'Berat') {
      return 'Risiko Tinggi';
    }
    if (tingkatKeparahan == 'Sedang' &&
        (jenisKondisi.contains('Hama') ||
            jenisKondisi.contains('Kekeringan') ||
            jenisKondisi.contains('Banjir'))) {
      return 'Risiko Tinggi';
    }
    return 'Normal';
  }

  bool get isRisikoTinggi => statusRisiko == 'Risiko Tinggi';

  /// Format tanggal singkat (cth: "04 Okt 2026")
  String get formattedTanggal {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final d = tanggalLapor.day.toString().padLeft(2, '0');
    final m = bulan[tanggalLapor.month];
    final y = tanggalLapor.year;
    return '$d $m $y';
  }

  /// Warna badge tingkat keparahan
  Color get warnaKeparahan {
    switch (tingkatKeparahan.toLowerCase()) {
      case 'berat':
        return const Color(0xFFD32F2F); // Merah
      case 'sedang':
        return const Color(0xFFF57C00); // Oranye
      case 'rendah':
      default:
        return const Color(0xFF388E3C); // Hijau
    }
  }

  /// Warna background chip tingkat keparahan
  Color get backgroundWarnaKeparahan {
    switch (tingkatKeparahan.toLowerCase()) {
      case 'berat':
        return const Color(0xFFFFEBEE);
      case 'sedang':
        return const Color(0xFFFFF3E0);
      case 'rendah':
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  /// Ikon representatif jenis kondisi
  IconData get iconJenisKondisi {
    switch (jenisKondisi.toLowerCase()) {
      case 'serangan hama/penyakit':
      case 'hama':
        return Icons.bug_report_outlined;
      case 'kekeringan':
        return Icons.wb_sunny_outlined;
      case 'banjir/tergenang':
      case 'banjir':
        return Icons.water_drop_outlined;
      case 'defisiensi nutrisi':
      case 'kurang nutrisi':
        return Icons.eco_outlined;
      case 'normal':
        return Icons.check_circle_outline;
      default:
        return Icons.warning_amber_outlined;
    }
  }

  LaporanKondisi copyWith({
    int? id,
    int? idLahan,
    String? namaLahan,
    DateTime? tanggalLapor,
    String? jenisKondisi,
    String? tingkatKeparahan,
    String? catatan,
    String? fotoUrl,
    String? statusRisiko,
  }) {
    return LaporanKondisi(
      id: id ?? this.id,
      idLahan: idLahan ?? this.idLahan,
      namaLahan: namaLahan ?? this.namaLahan,
      tanggalLapor: tanggalLapor ?? this.tanggalLapor,
      jenisKondisi: jenisKondisi ?? this.jenisKondisi,
      tingkatKeparahan: tingkatKeparahan ?? this.tingkatKeparahan,
      catatan: catatan ?? this.catatan,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      statusRisiko: statusRisiko ?? this.statusRisiko,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_lahan': idLahan,
      'nama_lahan': namaLahan,
      'tanggal_lapor': tanggalLapor.toIso8601String(),
      'jenis_kondisi': jenisKondisi,
      'tingkat_keparahan': tingkatKeparahan,
      'catatan': catatan,
      'foto_url': fotoUrl,
      'status_risiko': statusRisiko,
    };
  }

  factory LaporanKondisi.fromJson(Map<String, dynamic> json) {
    return LaporanKondisi(
      id: json['id'] as int,
      idLahan: json['id_lahan'] as int,
      namaLahan: json['nama_lahan'] as String? ?? 'Lahan',
      tanggalLapor: DateTime.parse(json['tanggal_lapor'] as String),
      jenisKondisi: json['jenis_kondisi'] as String,
      tingkatKeparahan: json['tingkat_keparahan'] as String,
      catatan: json['catatan'] as String,
      fotoUrl: json['foto_url'] as String?,
      statusRisiko: json['status_risiko'] as String? ?? 'Normal',
    );
  }
}
