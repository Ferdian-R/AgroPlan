import '../models/riwayat_panen.dart';

/// Abstraksi repository untuk data riwayat hasil panen (FR-18).
abstract class PanenRepository {
  Future<List<RiwayatPanen>> getRiwayatPanen();
  Future<bool> tambahCatatanPanen(RiwayatPanen panen);
}

/// Implementasi repository Panen berbasis mock data lokal in-memory.
class MockPanenRepository implements PanenRepository {
  final List<RiwayatPanen> _mockList = [
    RiwayatPanen(
      idPanen: 1,
      idSiklus: 901,
      idLahan: 2,
      namaLahan: 'Lahan Belakang',
      komoditas: 'Jagung',
      luasLahan: 0.3,
      tanggalPanen: DateTime(2026, 9, 20),
      jumlahHasilTon: 1.75,
      estimasiHasilTon: 1.62,
      catatan: 'Hasil panen pipil kering memuaskan dengan kadar air rendah.',
      tanggalDibuat: DateTime(2026, 9, 20),
    ),
  ];

  @override
  Future<List<RiwayatPanen>> getRiwayatPanen() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockList);
  }

  @override
  Future<bool> tambahCatatanPanen(RiwayatPanen panen) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockList.insert(0, panen);
    return true;
  }
}
