/// Model entitas Riwayat Panen (Modul 3: FR-17 & FR-18).
///
/// Sesuai PRD v2.0 Bagian 2.5.4 Data Requirements:
/// - id_panen, id_siklus (FK), tanggal_panen, jumlah_hasil_panen (ton),
///   estimasi_hasil (hasil kalkulasi), catatan.
class RiwayatPanen {
  final int idPanen;
  final int idSiklus;
  final int idLahan;
  final String namaLahan;
  final String komoditas;
  final double luasLahan;
  final DateTime tanggalPanen;
  final double jumlahHasilTon;
  final double estimasiHasilTon;
  final String? catatan;
  final DateTime tanggalDibuat;

  const RiwayatPanen({
    required this.idPanen,
    required this.idSiklus,
    required this.idLahan,
    required this.namaLahan,
    required this.komoditas,
    required this.luasLahan,
    required this.tanggalPanen,
    required this.jumlahHasilTon,
    required this.estimasiHasilTon,
    this.catatan,
    required this.tanggalDibuat,
  });

  /// Format tanggal Indonesia untuk tampilan (contoh: "26 Okt 2026")
  String get formattedTanggalPanen {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tanggalPanen.day} ${bulan[tanggalPanen.month]} ${tanggalPanen.year}';
  }

  /// Selisih hasil panen aktual terhadap estimasi (ton)
  double get selisihTon => jumlahHasilTon - estimasiHasilTon;

  /// Persentase pencapaian hasil aktual terhadap estimasi
  double get persentasePencapaian {
    if (estimasiHasilTon <= 0) return 100.0;
    return (jumlahHasilTon / estimasiHasilTon) * 100.0;
  }

  /// Status efektivitas panen
  String get statusEvaluasi {
    final selisih = selisihTon;
    if (selisih > 0.05) {
      return 'Melampaui Target';
    } else if (selisih < -0.05) {
      return 'Di Bawah Target';
    } else {
      return 'Sesuai Target';
    }
  }

  /// Format teks hasil panen aktual (contoh: "2.45 ton")
  String get hasilFormatted => '${jumlahHasilTon.toStringAsFixed(2)} ton';

  /// Format teks estimasi (contoh: "2.30 ton")
  String get estimasiFormatted => '${estimasiHasilTon.toStringAsFixed(2)} ton';

  RiwayatPanen copyWith({
    int? idPanen,
    int? idSiklus,
    int? idLahan,
    String? namaLahan,
    String? komoditas,
    double? luasLahan,
    DateTime? tanggalPanen,
    double? jumlahHasilTon,
    double? estimasiHasilTon,
    String? catatan,
    DateTime? tanggalDibuat,
  }) {
    return RiwayatPanen(
      idPanen: idPanen ?? this.idPanen,
      idSiklus: idSiklus ?? this.idSiklus,
      idLahan: idLahan ?? this.idLahan,
      namaLahan: namaLahan ?? this.namaLahan,
      komoditas: komoditas ?? this.komoditas,
      luasLahan: luasLahan ?? this.luasLahan,
      tanggalPanen: tanggalPanen ?? this.tanggalPanen,
      jumlahHasilTon: jumlahHasilTon ?? this.jumlahHasilTon,
      estimasiHasilTon: estimasiHasilTon ?? this.estimasiHasilTon,
      catatan: catatan ?? this.catatan,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
    );
  }
}
