/// Model entitas Lahan sesuai PRD AgroPlan Bagian 2.5 Data Requirements.
/// Digunakan sebagai entitas acuan utama untuk siklus tanam, laporan kondisi,
/// jadwal perawatan, dan estimasi panen.
class Lahan {
  final int idLahan;
  final String namaLahan;
  final double luasLahan; // Luas dalam hektar (ha)
  final String? jenisTanah; // misal: Aluvial, Lempung (nullable)
  final String komoditasUtama; // misal: Padi, Jagung
  final String? lokasi; // misal: "Kab. Padang" (dari tampilan Figma)
  final String? fotoUrl; // Path lokal atau URL gambar lahan
  final DateTime? tanggalDibuat;
  final DateTime? tanggalDiubah;

  const Lahan({
    required this.idLahan,
    required this.namaLahan,
    required this.luasLahan,
    this.jenisTanah,
    required this.komoditasUtama,
    this.lokasi,
    this.fotoUrl,
    this.tanggalDibuat,
    this.tanggalDiubah,
  });

  /// Format luas lahan dalam gaya Indonesia, contoh: "0,5 ha"
  String get luasFormatted {
    final str = luasLahan.toString().replaceAll('.', ',');
    // Hilangkan ,0 jika integer
    final cleanStr = str.endsWith(',0') ? str.substring(0, str.length - 2) : str;
    return '$cleanStr ha';
  }

  /// Format teks untuk StatusChip di kartu lahan, contoh: "0,5 ha • Padi"
  String get chipText => '$luasFormatted • $komoditasUtama';

  /// Konversi dari JSON response REST API backend MySQL
  factory Lahan.fromJson(Map<String, dynamic> json) {
    return Lahan(
      idLahan: json['id_lahan'] is int
          ? json['id_lahan'] as int
          : int.parse(json['id_lahan'].toString()),
      namaLahan: json['nama_lahan'] as String,
      luasLahan: json['luas_lahan'] is num
          ? (json['luas_lahan'] as num).toDouble()
          : double.parse(json['luas_lahan'].toString()),
      jenisTanah: json['jenis_tanah'] as String?,
      komoditasUtama: json['komoditas_utama'] as String,
      lokasi: json['lokasi'] as String?,
      fotoUrl: json['foto_url'] as String?,
      tanggalDibuat: json['tanggal_dibuat'] != null
          ? DateTime.tryParse(json['tanggal_dibuat'].toString())
          : null,
      tanggalDiubah: json['tanggal_diubah'] != null
          ? DateTime.tryParse(json['tanggal_diubah'].toString())
          : null,
    );
  }

  /// Serialisasi ke format JSON untuk request body REST API
  Map<String, dynamic> toJson() {
    return {
      'id_lahan': idLahan,
      'nama_lahan': namaLahan,
      'luas_lahan': luasLahan,
      'jenis_tanah': jenisTanah,
      'komoditas_utama': komoditasUtama,
      'lokasi': lokasi,
      'foto_url': fotoUrl,
      'tanggal_dibuat': tanggalDibuat?.toIso8601String(),
      'tanggal_diubah': tanggalDiubah?.toIso8601String(),
    };
  }

  Lahan copyWith({
    int? idLahan,
    String? namaLahan,
    double? luasLahan,
    String? jenisTanah,
    String? komoditasUtama,
    String? lokasi,
    String? fotoUrl,
    DateTime? tanggalDibuat,
    DateTime? tanggalDiubah,
  }) {
    return Lahan(
      idLahan: idLahan ?? this.idLahan,
      namaLahan: namaLahan ?? this.namaLahan,
      luasLahan: luasLahan ?? this.luasLahan,
      jenisTanah: jenisTanah ?? this.jenisTanah,
      komoditasUtama: komoditasUtama ?? this.komoditasUtama,
      lokasi: lokasi ?? this.lokasi,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
      tanggalDiubah: tanggalDiubah ?? this.tanggalDiubah,
    );
  }
}
