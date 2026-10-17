import '../models/siklus_tanam.dart';

/// Abstraksi repository untuk entitas Siklus Tanam (Modul 1: FR-05).
abstract class SiklusRepository {
  Future<List<SiklusTanam>> getDaftarSiklus();
  Future<List<SiklusTanam>> getSiklusByLahan(int idLahan);
  Future<SiklusTanam?> getSiklusAktif(int idLahan);
  Future<bool> tambahSiklus(SiklusTanam siklus);
  Future<bool> updateStatusSiklus(int idSiklus, String status);
}

/// Implementasi in-memory / mock repository untuk Siklus Tanam.
class MockSiklusRepository implements SiklusRepository {
  final List<SiklusTanam> _mockSiklus = [
    SiklusTanam(
      idSiklus: 1,
      idLahan: 1,
      namaLahan: 'Lahan Utama',
      komoditas: 'Padi',
      tanggalRencanaTanam: DateTime.now().subtract(const Duration(days: 14)),
      tanggalTanamAktual: DateTime.now().subtract(const Duration(days: 14)),
      statusSiklus: 'Berjalan',
      catatan: 'Musim tanam rendengan, varietas Ciherang',
      tanggalDibuat: DateTime.now().subtract(const Duration(days: 15)),
    ),
    SiklusTanam(
      idSiklus: 2,
      idLahan: 2,
      namaLahan: 'Lahan Belakang',
      komoditas: 'Jagung',
      tanggalRencanaTanam: DateTime.now().subtract(const Duration(days: 7)),
      tanggalTanamAktual: DateTime.now().subtract(const Duration(days: 7)),
      statusSiklus: 'Berjalan',
      catatan: 'Jagung hibrida BISI 18',
      tanggalDibuat: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Future<List<SiklusTanam>> getDaftarSiklus() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockSiklus);
  }

  @override
  Future<List<SiklusTanam>> getSiklusByLahan(int idLahan) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockSiklus.where((s) => s.idLahan == idLahan).toList();
  }

  @override
  Future<SiklusTanam?> getSiklusAktif(int idLahan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matching = _mockSiklus.where((s) => s.idLahan == idLahan && s.isBerjalan);
    return matching.isEmpty ? null : matching.first;
  }

  @override
  Future<bool> tambahSiklus(SiklusTanam siklus) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // Validasi aturan PRD 2.5.4: hanya 1 siklus aktif per lahan
    if (siklus.isBerjalan) {
      final adaAktif = _mockSiklus.any((s) => s.idLahan == siklus.idLahan && s.isBerjalan);
      if (adaAktif) {
        throw Exception(
          'Lahan "${siklus.namaLahan}" masih memiliki siklus tanam aktif. Satu lahan hanya boleh memiliki satu siklus tanam aktif.',
        );
      }
    }
    _mockSiklus.insert(0, siklus);
    return true;
  }

  @override
  Future<bool> updateStatusSiklus(int idSiklus, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockSiklus.indexWhere((s) => s.idSiklus == idSiklus);
    if (index != -1) {
      _mockSiklus[index] = _mockSiklus[index].copyWith(statusSiklus: status);
      return true;
    }
    return false;
  }
}
