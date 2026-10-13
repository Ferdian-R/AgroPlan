// Data referensi komoditas dan template jadwal perawatan
// berdasarkan PRD AgroPlan v2.0 Bagian 2.5.2 dan 2.5.3.
//
// Sumber data:
// - Produktivitas: BPS dan Kementerian Pertanian (Tabel 2.5.2)
// - Template jadwal: Publikasi Kementan & Dinas Pertanian (Tabel 2.5.3)

/// Model data produktivitas satu komoditas.
class ReferensiKomoditas {
  final String nama;
  final double produktivitas; // ton/ha
  final String wilayahAcuan;
  final String statusVerifikasi;

  const ReferensiKomoditas({
    required this.nama,
    required this.produktivitas,
    required this.wilayahAcuan,
    this.statusVerifikasi = 'Referensi awal, perlu diverifikasi',
  });
}

/// Model satu baris template kegiatan perawatan per komoditas.
class TemplateJadwal {
  final String komoditas;
  final String namaKegiatan;
  final String waktuSumber; // Deskripsi rentang dari sumber
  final int hstPengingat; // Hari Setelah Tanam untuk pengingat
  final String sumber; // Kode sumber (S1, S2, dst.)

  const TemplateJadwal({
    required this.komoditas,
    required this.namaKegiatan,
    required this.waktuSumber,
    required this.hstPengingat,
    required this.sumber,
  });
}

/// Kelas utilitas berisi data statis referensi PRD v2.0.
class DataReferensi {
  DataReferensi._();

  // ═══════════════════════════════════════════════════════
  // Tabel 2.5.2 – Produktivitas Komoditas (ton/ha)
  // ═══════════════════════════════════════════════════════

  static const List<ReferensiKomoditas> daftarKomoditas = [
    ReferensiKomoditas(
      nama: 'Padi',
      produktivitas: 4.594,
      wilayahAcuan: 'Sumatera Barat',
    ),
    ReferensiKomoditas(
      nama: 'Jagung',
      produktivitas: 6.176,
      wilayahAcuan: 'Sumatera Barat',
    ),
    ReferensiKomoditas(
      nama: 'Kedelai',
      produktivitas: 1.623,
      wilayahAcuan: 'Nasional',
    ),
    ReferensiKomoditas(
      nama: 'Cabai Merah',
      produktivitas: 10.62,
      wilayahAcuan: 'Nasional, kategori cabai besar',
    ),
    ReferensiKomoditas(
      nama: 'Bawang Merah',
      produktivitas: 11.05,
      wilayahAcuan: 'Nasional',
    ),
    ReferensiKomoditas(
      nama: 'Tomat',
      produktivitas: 19.54,
      wilayahAcuan: 'Nasional',
    ),
  ];

  /// Cari referensi komoditas berdasarkan nama (case-insensitive).
  /// Mengembalikan null jika tidak ditemukan.
  static ReferensiKomoditas? cariKomoditas(String nama) {
    final lower = nama.toLowerCase();
    for (final k in daftarKomoditas) {
      if (k.nama.toLowerCase() == lower) return k;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════
  // Tabel 2.5.3 – Template Jadwal Perawatan per Komoditas
  // ═══════════════════════════════════════════════════════

  static const List<TemplateJadwal> templateJadwal = [
    // ── Padi ──
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Pemupukan susulan I',
      waktuSumber: '7-10 HST',
      hstPengingat: 7,
      sumber: 'S1, S3',
    ),
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Penyiangan I',
      waktuSumber: '21 HST',
      hstPengingat: 21,
      sumber: 'S2, S3',
    ),
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Pemupukan susulan II',
      waktuSumber: '21-25 HST',
      hstPengingat: 21,
      sumber: 'S1',
    ),
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Pemupukan susulan III (bila diperlukan)',
      waktuSumber: '30-35 HST',
      hstPengingat: 30,
      sumber: 'S1',
    ),
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Penyiangan II',
      waktuSumber: '42 HST',
      hstPengingat: 42,
      sumber: 'S2',
    ),
    TemplateJadwal(
      komoditas: 'Padi',
      namaKegiatan: 'Mulai periksa kesiapan panen',
      waktuSumber: '135-145 HST',
      hstPengingat: 135,
      sumber: 'S4',
    ),

    // ── Jagung ──
    TemplateJadwal(
      komoditas: 'Jagung',
      namaKegiatan: 'Pemupukan I',
      waktuSumber: '10-15 HST',
      hstPengingat: 10,
      sumber: 'S5',
    ),
    TemplateJadwal(
      komoditas: 'Jagung',
      namaKegiatan: 'Penyiangan I',
      waktuSumber: '15 HST',
      hstPengingat: 15,
      sumber: 'S5',
    ),
    TemplateJadwal(
      komoditas: 'Jagung',
      namaKegiatan: 'Pemupukan II',
      waktuSumber: '28-35 HST',
      hstPengingat: 28,
      sumber: 'S5',
    ),
    TemplateJadwal(
      komoditas: 'Jagung',
      namaKegiatan: 'Penyiangan II dan pembumbunan',
      waktuSumber: '30-35 HST',
      hstPengingat: 30,
      sumber: 'S6',
    ),
    TemplateJadwal(
      komoditas: 'Jagung',
      namaKegiatan: 'Mulai periksa kesiapan panen',
      waktuSumber: '100-110 HST (dataran rendah)',
      hstPengingat: 100,
      sumber: 'S7',
    ),

    // ── Kedelai ──
    TemplateJadwal(
      komoditas: 'Kedelai',
      namaKegiatan: 'Pemupukan',
      waktuSumber: 'Paling lambat 14 HST',
      hstPengingat: 14,
      sumber: 'S8',
    ),
    TemplateJadwal(
      komoditas: 'Kedelai',
      namaKegiatan: 'Penyiangan I',
      waktuSumber: '15-20 HST',
      hstPengingat: 15,
      sumber: 'S8',
    ),
    TemplateJadwal(
      komoditas: 'Kedelai',
      namaKegiatan: 'Penyiangan II',
      waktuSumber: '40-45 HST',
      hstPengingat: 40,
      sumber: 'S8',
    ),
    TemplateJadwal(
      komoditas: 'Kedelai',
      namaKegiatan: 'Mulai periksa kesiapan panen',
      waktuSumber: '70-90 HST (95% polong kuning kecoklatan)',
      hstPengingat: 70,
      sumber: 'S8, S9',
    ),

    // ── Cabai Merah ──
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Pemasangan ajir',
      waktuSumber: '7 HST',
      hstPengingat: 7,
      sumber: 'S10',
    ),
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Pemupukan susulan I',
      waktuSumber: 'Minggu ke-3',
      hstPengingat: 21,
      sumber: 'S11',
    ),
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Pengikatan tanaman pada ajir',
      waktuSumber: '25 HST',
      hstPengingat: 25,
      sumber: 'S10',
    ),
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Pemupukan susulan II',
      waktuSumber: 'Minggu ke-6',
      hstPengingat: 42,
      sumber: 'S11',
    ),
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Pemupukan susulan III',
      waktuSumber: 'Minggu ke-9',
      hstPengingat: 63,
      sumber: 'S11',
    ),
    TemplateJadwal(
      komoditas: 'Cabai Merah',
      namaKegiatan: 'Panen pertama (berikutnya tiap 3-7 hari)',
      waktuSumber: '70-75 HST (dataran rendah)',
      hstPengingat: 70,
      sumber: 'S12',
    ),

    // ── Bawang Merah ──
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Penyulaman',
      waktuSumber: 'Sampai 7-10 HST',
      hstPengingat: 7,
      sumber: 'S16',
    ),
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Penyiangan I',
      waktuSumber: '10-15 HST',
      hstPengingat: 10,
      sumber: 'S15',
    ),
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Pemupukan susulan I',
      waktuSumber: '10-15 HST',
      hstPengingat: 10,
      sumber: 'S13, S14',
    ),
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Penyiangan II',
      waktuSumber: '28-35 HST',
      hstPengingat: 28,
      sumber: 'S15',
    ),
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Pemupukan susulan II',
      waktuSumber: '30-35 HST',
      hstPengingat: 30,
      sumber: 'S13',
    ),
    TemplateJadwal(
      komoditas: 'Bawang Merah',
      namaKegiatan: 'Mulai periksa kesiapan panen',
      waktuSumber: '60-70 HST (leher batang mulai lunak, daun rebah)',
      hstPengingat: 60,
      sumber: 'S14',
    ),

    // ── Tomat ──
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemasangan ajir',
      waktuSumber: 'Segera setelah tanam',
      hstPengingat: 1,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan I',
      waktuSumber: '10 HST',
      hstPengingat: 10,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Penyulaman',
      waktuSumber: 'Sampai 15 HST',
      hstPengingat: 15,
      sumber: 'S19',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan II',
      waktuSumber: '20 HST',
      hstPengingat: 20,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan III',
      waktuSumber: '30 HST',
      hstPengingat: 30,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan lanjutan (40 HST)',
      waktuSumber: '40 HST',
      hstPengingat: 40,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan lanjutan (50 HST)',
      waktuSumber: '50 HST',
      hstPengingat: 50,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Pemupukan susulan lanjutan (60 HST)',
      waktuSumber: '60 HST',
      hstPengingat: 60,
      sumber: 'S17',
    ),
    TemplateJadwal(
      komoditas: 'Tomat',
      namaKegiatan: 'Mulai periksa kesiapan panen',
      waktuSumber: '55-75 HST (dataran rendah)',
      hstPengingat: 55,
      sumber: 'S17, S18',
    ),
  ];

  /// Ambil template jadwal untuk komoditas tertentu.
  static List<TemplateJadwal> templateUntukKomoditas(String komoditas) {
    final lower = komoditas.toLowerCase();
    return templateJadwal
        .where((t) => t.komoditas.toLowerCase() == lower)
        .toList();
  }
}
