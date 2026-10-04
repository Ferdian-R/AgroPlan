import '../models/laporan_kondisi.dart';

/// Kontrak repository untuk data Laporan Kondisi Lahan (Modul 2).
abstract class LaporanRepository {
  Future<List<LaporanKondisi>> getDaftarLaporan();
  Future<bool> tambahLaporan(LaporanKondisi laporan);
  Future<bool> updateLaporan(LaporanKondisi laporan);
  Future<bool> hapusLaporan(int id);
}

/// Implementasi mock repository lokal untuk demo dan demonstrasi workflow (FR-07 s.d FR-12).
class MockLaporanRepository implements LaporanRepository {
  final List<LaporanKondisi> _data = [
    LaporanKondisi(
      id: 1,
      idLahan: 1,
      namaLahan: 'Lahan Sawah Padi Barat',
      tanggalLapor: DateTime(2026, 10, 2),
      jenisKondisi: 'Serangan Hama/Penyakit',
      tingkatKeparahan: 'Sedang',
      catatan: 'Ditemukan bercak daun wereng coklat pada petak bagian timur. Perlu penyemprotan insektisida organik segera.',
      fotoUrl: 'assets/images/lahan_padi.webp',
      statusRisiko: 'Risiko Tinggi',
    ),
    LaporanKondisi(
      id: 2,
      idLahan: 2,
      namaLahan: 'Kebun Jagung Manis Selatan',
      tanggalLapor: DateTime(2026, 9, 28),
      jenisKondisi: 'Normal',
      tingkatKeparahan: 'Rendah',
      catatan: 'Tanaman tumbuh subur seragam, daun hijau segar dan drainase lancar pasca pemupukan kedua.',
      fotoUrl: 'assets/images/lahan_jagung.webp',
      statusRisiko: 'Normal',
    ),
    LaporanKondisi(
      id: 3,
      idLahan: 1,
      namaLahan: 'Lahan Sawah Padi Barat',
      tanggalLapor: DateTime(2026, 9, 20),
      jenisKondisi: 'Kekeringan',
      tingkatKeparahan: 'Berat',
      catatan: 'Debit air irigasi primer menyusut drastis, tanah mulai retak di ujung petak 2.',
      fotoUrl: 'assets/images/lahan_padi.webp',
      statusRisiko: 'Risiko Tinggi',
    ),
  ];

  @override
  Future<List<LaporanKondisi>> getDaftarLaporan() async {
    // Simulasi latensi jaringan
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_data);
  }

  @override
  Future<bool> tambahLaporan(LaporanKondisi laporan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.insert(0, laporan);
    return true;
  }

  @override
  Future<bool> updateLaporan(LaporanKondisi laporan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _data.indexWhere((e) => e.id == laporan.id);
    if (idx != -1) {
      _data[idx] = laporan;
      return true;
    }
    return false;
  }

  @override
  Future<bool> hapusLaporan(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final initialCount = _data.length;
    _data.removeWhere((e) => e.id == id);
    return _data.length < initialCount;
  }
}
