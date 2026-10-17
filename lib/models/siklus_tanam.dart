/// Model entitas Siklus Tanam sesuai PRD AgroPlan Bagian 2.5 Data Requirements.
///
/// Atribut utama:
/// - id_siklus: ID unik siklus tanam
/// - id_lahan: ID lahan acuan (FK)
/// - komoditas: salah satu dari 6 komoditas resmi PRD (Padi, Jagung, Kedelai, Cabai Merah, Bawang Merah, Tomat)
/// - tanggal_rencana_tanam: tanggal mulai / rencana tanam
/// - tanggal_tanam_aktual: tanggal aktual realisasi tanam (opsional)
/// - status_siklus: 'Berjalan' atau 'Selesai' (PRD 2.5.4: hanya 1 siklus aktif per lahan)
class SiklusTanam {
  final int idSiklus;
  final int idLahan;
  final String namaLahan;
  final String komoditas;
  final DateTime tanggalRencanaTanam;
  final DateTime? tanggalTanamAktual;
  final String statusSiklus; // 'Berjalan' atau 'Selesai'
  final String? catatan;
  final DateTime? tanggalDibuat;

  const SiklusTanam({
    required this.idSiklus,
    required this.idLahan,
    required this.namaLahan,
    required this.komoditas,
    required this.tanggalRencanaTanam,
    this.tanggalTanamAktual,
    this.statusSiklus = 'Berjalan',
    this.catatan,
    this.tanggalDibuat,
  });

  /// Apakah siklus tanam saat ini sedang berlangsung/aktif
  bool get isBerjalan => statusSiklus.toLowerCase() == 'berjalan';

  /// Hari Setelah Tanam (HST) dihitung dari tanggal rencana/mulai tanam
  int get hst {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tanam = DateTime(
      tanggalRencanaTanam.year,
      tanggalRencanaTanam.month,
      tanggalRencanaTanam.day,
    );
    final diff = today.difference(tanam).inDays;
    return diff >= 0 ? diff : 0;
  }

  /// Format tanggal ramah pengguna (contoh: "15 Okt 2026")
  String get formattedTanggalTanam {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = tanggalRencanaTanam.day;
    final m = bulan[tanggalRencanaTanam.month - 1];
    final y = tanggalRencanaTanam.year;
    return '$d $m $y';
  }

  factory SiklusTanam.fromJson(Map<String, dynamic> json) {
    return SiklusTanam(
      idSiklus: json['id_siklus'] is int
          ? json['id_siklus'] as int
          : int.parse(json['id_siklus'].toString()),
      idLahan: json['id_lahan'] is int
          ? json['id_lahan'] as int
          : int.parse(json['id_lahan'].toString()),
      namaLahan: (json['nama_lahan'] as String?) ?? 'Lahan',
      komoditas: json['komoditas'] as String,
      tanggalRencanaTanam: DateTime.parse(json['tanggal_rencana_tanam'].toString()),
      tanggalTanamAktual: json['tanggal_tanam_aktual'] != null
          ? DateTime.tryParse(json['tanggal_tanam_aktual'].toString())
          : null,
      statusSiklus: (json['status_siklus'] as String?) ?? 'Berjalan',
      catatan: json['catatan'] as String?,
      tanggalDibuat: json['tanggal_dibuat'] != null
          ? DateTime.tryParse(json['tanggal_dibuat'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_siklus': idSiklus,
      'id_lahan': idLahan,
      'nama_lahan': namaLahan,
      'komoditas': komoditas,
      'tanggal_rencana_tanam': tanggalRencanaTanam.toIso8601String(),
      'tanggal_tanam_aktual': tanggalTanamAktual?.toIso8601String(),
      'status_siklus': statusSiklus,
      'catatan': catatan,
      'tanggal_dibuat': tanggalDibuat?.toIso8601String(),
    };
  }

  SiklusTanam copyWith({
    int? idSiklus,
    int? idLahan,
    String? namaLahan,
    String? komoditas,
    DateTime? tanggalRencanaTanam,
    DateTime? tanggalTanamAktual,
    String? statusSiklus,
    String? catatan,
    DateTime? tanggalDibuat,
  }) {
    return SiklusTanam(
      idSiklus: idSiklus ?? this.idSiklus,
      idLahan: idLahan ?? this.idLahan,
      namaLahan: namaLahan ?? this.namaLahan,
      komoditas: komoditas ?? this.komoditas,
      tanggalRencanaTanam: tanggalRencanaTanam ?? this.tanggalRencanaTanam,
      tanggalTanamAktual: tanggalTanamAktual ?? this.tanggalTanamAktual,
      statusSiklus: statusSiklus ?? this.statusSiklus,
      catatan: catatan ?? this.catatan,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
    );
  }
}
