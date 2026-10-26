// Model entitas Jadwal Perawatan (Modul 3: FR-13 s.d FR-15, FR-19).
//
// Sesuai PRD v2.0 Bagian 2.5 Data Requirements:
// - id_jadwal, id_siklus (FK), id_template (FK), jenis kegiatan,
//   tanggal terjadwal, status pelaksanaan (Belum/Selesai/Ditunda),
//   tanggal baru (jika ditunda).
//
// Status pelaksanaan mengikuti enum [StatusPelaksanaan]:
// - Belum: jadwal belum dilaksanakan
// - Selesai: kegiatan sudah dilakukan
// - Ditunda: jadwal ditunda ke tanggal baru yang ditentukan pengguna

/// Enum status pelaksanaan jadwal perawatan sesuai PRD v2.0.
enum StatusPelaksanaan {
  belum('Belum'),
  selesai('Selesai'),
  ditunda('Ditunda');

  final String label;
  const StatusPelaksanaan(this.label);
}

class JadwalPerawatan {
  final int id;
  final String namaKegiatan;
  final int idLahan;
  final String namaLahan;
  final String jenisPerawatan;
  final DateTime tanggalPelaksanaan;
  final String? catatan;
  final DateTime tanggalDibuat;

  /// Status pelaksanaan: Belum / Selesai / Ditunda (FR-15)
  final StatusPelaksanaan status;

  /// Tanggal baru jika status = Ditunda (FR-15)
  final DateTime? tanggalDitunda;

  /// Rentang HST dari sumber (misal: "7-10 HST") untuk tampilan detail
  final String? waktuSumber;

  /// HST pengingat (Hari Setelah Tanam) dari template
  final int? hstPengingat;

  /// Nama komoditas (untuk konteks jadwal otomatis)
  final String? komoditas;

  /// Apakah jadwal ini dibuat otomatis dari template
  final bool isOtomatis;

  const JadwalPerawatan({
    required this.id,
    required this.namaKegiatan,
    required this.idLahan,
    required this.namaLahan,
    required this.jenisPerawatan,
    required this.tanggalPelaksanaan,
    this.catatan,
    required this.tanggalDibuat,
    this.status = StatusPelaksanaan.belum,
    this.tanggalDitunda,
    this.waktuSumber,
    this.hstPengingat,
    this.komoditas,
    this.isOtomatis = false,
  });

  /// Daftar jenis perawatan yang tersedia
  static const List<String> daftarJenisPerawatan = [
    'Pemupukan',
    'Penyiraman',
    'Penyemprotan',
    'Penyiangan',
    'Pemasangan Ajir',
    'Penyulaman',
    'Pemeriksaan Panen',
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

  /// Format tanggal tunda (jika ada)
  String? get tanggalDitundaFormatted {
    if (tanggalDitunda == null) return null;
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tanggalDitunda!.day} ${bulan[tanggalDitunda!.month]} ${tanggalDitunda!.year}';
  }

  /// Tanggal efektif: jika ditunda, pakai tanggal baru; jika tidak, tanggal asli
  DateTime get tanggalEfektif => tanggalDitunda ?? tanggalPelaksanaan;

  /// Apakah jadwal sudah jatuh tempo (tanggal efektif <= hari ini)
  bool get isJatuhTempo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final efektif = DateTime(
      tanggalEfektif.year,
      tanggalEfektif.month,
      tanggalEfektif.day,
    );
    return efektif.isBefore(today) || efektif.isAtSameMomentAs(today);
  }

  /// Icon sesuai jenis perawatan (untuk tampilan di list)
  String get jenisIcon {
    final lower = jenisPerawatan.toLowerCase();
    if (lower.contains('pupuk') || lower.contains('pemupukan')) return '🌿';
    if (lower.contains('siram') || lower.contains('penyiraman')) return '💧';
    if (lower.contains('semprot') || lower.contains('penyemprotan')) return '🧴';
    if (lower.contains('siang') || lower.contains('penyiangan')) return '🌾';
    if (lower.contains('ajir') || lower.contains('pemasangan')) return '🪴';
    if (lower.contains('sulam') || lower.contains('penyulaman')) return '🌱';
    if (lower.contains('panen') || lower.contains('periksa')) return '🌽';
    if (lower.contains('ikat') || lower.contains('pengikatan')) return '🪢';
    if (lower.contains('bumbun') || lower.contains('pembumbunan')) return '⛏️';
    return '📋';
  }

  /// Tentukan jenis perawatan berdasarkan nama kegiatan (untuk jadwal otomatis)
  static String _tentukanJenis(String namaKegiatan) {
    final lower = namaKegiatan.toLowerCase();
    if (lower.contains('pupuk') || lower.contains('pemupukan')) return 'Pemupukan';
    if (lower.contains('siang') || lower.contains('penyiangan')) return 'Penyiangan';
    if (lower.contains('ajir') || lower.contains('pemasangan')) return 'Pemasangan Ajir';
    if (lower.contains('sulam') || lower.contains('penyulaman')) return 'Penyulaman';
    if (lower.contains('panen') || lower.contains('periksa')) return 'Pemeriksaan Panen';
    if (lower.contains('ikat') || lower.contains('pengikatan')) return 'Pemasangan Ajir';
    if (lower.contains('bumbun') || lower.contains('pembumbunan')) return 'Penyiangan';
    return 'Lainnya';
  }

  /// Factory: buat jadwal otomatis dari template
  factory JadwalPerawatan.dariTemplate({
    required int id,
    required int idLahan,
    required String namaLahan,
    required String komoditas,
    required DateTime tanggalTanam,
    required String namaKegiatan,
    required int hstPengingat,
    required String waktuSumber,
  }) {
    return JadwalPerawatan(
      id: id,
      namaKegiatan: namaKegiatan,
      idLahan: idLahan,
      namaLahan: namaLahan,
      jenisPerawatan: _tentukanJenis(namaKegiatan),
      tanggalPelaksanaan: tanggalTanam.add(Duration(days: hstPengingat)),
      tanggalDibuat: DateTime.now(),
      status: StatusPelaksanaan.belum,
      waktuSumber: waktuSumber,
      hstPengingat: hstPengingat,
      komoditas: komoditas,
      isOtomatis: true,
    );
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
    StatusPelaksanaan? status,
    DateTime? tanggalDitunda,
    String? waktuSumber,
    int? hstPengingat,
    String? komoditas,
    bool? isOtomatis,
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
      status: status ?? this.status,
      tanggalDitunda: tanggalDitunda ?? this.tanggalDitunda,
      waktuSumber: waktuSumber ?? this.waktuSumber,
      hstPengingat: hstPengingat ?? this.hstPengingat,
      komoditas: komoditas ?? this.komoditas,
      isOtomatis: isOtomatis ?? this.isOtomatis,
    );
  }

  factory JadwalPerawatan.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_jadwal'] ?? json['id'];
    final rawIdLahan = json['id_lahan'];
    final rawStatus = (json['status_pelaksanaan'] as String?) ?? 'Belum';

    StatusPelaksanaan statusEnum = StatusPelaksanaan.belum;
    if (rawStatus.toLowerCase() == 'selesai') {
      statusEnum = StatusPelaksanaan.selesai;
    } else if (rawStatus.toLowerCase() == 'ditunda') {
      statusEnum = StatusPelaksanaan.ditunda;
    }

    return JadwalPerawatan(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      idLahan: rawIdLahan is int ? rawIdLahan : int.parse(rawIdLahan.toString()),
      namaLahan: json['nama_lahan'] as String? ?? 'Lahan',
      namaKegiatan: json['nama_kegiatan'] as String? ?? 'Perawatan',
      jenisPerawatan: json['jenis_perawatan'] as String? ?? json['nama_kegiatan'] as String? ?? 'Perawatan',
      tanggalPelaksanaan: DateTime.parse(json['tanggal_pelaksanaan'].toString()),
      tanggalDitunda: json['tanggal_ditunda'] != null
          ? DateTime.tryParse(json['tanggal_ditunda'].toString())
          : null,
      status: statusEnum,
      waktuSumber: json['waktu_sumber'] as String?,
      hstPengingat: json['hst_pengingat'] is int
          ? json['hst_pengingat'] as int
          : (json['hst_pengingat'] != null ? int.tryParse(json['hst_pengingat'].toString()) : null),
      komoditas: json['komoditas'] as String?,
      catatan: json['catatan'] as String?,
      tanggalDibuat: json['tanggal_dibuat'] != null
          ? DateTime.tryParse(json['tanggal_dibuat'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isOtomatis: json['id_template'] != null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_lahan': idLahan,
        'nama_kegiatan': namaKegiatan,
        'jenis_perawatan': jenisPerawatan,
        'tanggal_pelaksanaan': tanggalPelaksanaan.toIso8601String().split('T')[0],
        'status_pelaksanaan': status.label,
        'tanggal_ditunda': tanggalDitunda?.toIso8601String().split('T')[0],
        'catatan': catatan,
      };
}
