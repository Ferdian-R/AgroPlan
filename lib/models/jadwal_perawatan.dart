/// Model entitas Jadwal Perawatan (Modul 3: FR-13 & FR-19).
///
/// Menyimpan data kegiatan perawatan lahan seperti pemupukan,
/// penyiraman, penyemprotan, dan penyiangan.
class JadwalPerawatan {
  final int id;
  final String namaKegiatan;
  final int idLahan;
  final String namaLahan;
  final String jenisPerawatan;
  final DateTime tanggalPelaksanaan;
  final String? catatan;
  final DateTime tanggalDibuat;
  final bool selesai;

  const JadwalPerawatan({
    required this.id,
    required this.namaKegiatan,
    required this.idLahan,
    required this.namaLahan,
    required this.jenisPerawatan,
    required this.tanggalPelaksanaan,
    this.catatan,
    required this.tanggalDibuat,
    this.selesai = false,
  });

  /// Daftar jenis perawatan yang tersedia
  static const List<String> daftarJenisPerawatan = [
    'Pemupukan',
    'Penyiraman',
    'Penyemprotan',
    'Penyiangan',
    'Lainnya',
  ];

  /// Format tanggal pelaksanaan ke string Indonesia, contoh: "15 Okt 2026"
  String get tanggalFormatted {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tanggalPelaksanaan.day} ${bulan[tanggalPelaksanaan.month]} ${tanggalPelaksanaan.year}';
  }

  /// Icon sesuai jenis perawatan (untuk tampilan di list)
  String get jenisIcon {
    switch (jenisPerawatan) {
      case 'Pemupukan':
        return '🌿';
      case 'Penyiraman':
        return '💧';
      case 'Penyemprotan':
        return '🧴';
      case 'Penyiangan':
        return '🌾';
      default:
        return '📋';
    }
  }

  JadwalPerawatan copyWith({
    int? id,
    String? namaKegiatan,
    int? idLahan,
    String? namaLahan,
    String? jenisPerawatan,
    DateTime? tanggalPelaksanaan,
    String? catatan,
    DateTime? tanggalDibuat,
    bool? selesai,
  }) {
    return JadwalPerawatan(
      id: id ?? this.id,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      idLahan: idLahan ?? this.idLahan,
      namaLahan: namaLahan ?? this.namaLahan,
      jenisPerawatan: jenisPerawatan ?? this.jenisPerawatan,
      tanggalPelaksanaan: tanggalPelaksanaan ?? this.tanggalPelaksanaan,
      catatan: catatan ?? this.catatan,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
      selesai: selesai ?? this.selesai,
    );
  }
}
