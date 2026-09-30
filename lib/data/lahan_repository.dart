import '../models/lahan.dart';

/// Abstraksi repository untuk data Lahan.
///
/// Memungkinkan pemisahan antara lapisan data dan lapisan presentasi/state (Provider).
/// Pada tahap ini menggunakan mock data lokal, dan siap diganti ke pemanggilan
/// REST API (MySQL backend) tanpa mengubah kode UI.
abstract class LahanRepository {
  Future<List<Lahan>> getDaftarLahan({bool simulateError = false});
  Future<Lahan> getDetailLahan(int idLahan);
  Future<bool> tambahLahan(Lahan lahan);
  Future<bool> updateLahan(Lahan lahan);
  Future<bool> hapusLahan(int idLahan);
}

/// Implementasi sementara LahanRepository berbasis in-memory / mock data.
///
/// Data awal diambil persis sesuai desain Figma (Lahan Utama & Lahan Belakang).
/// TODO: Ganti implementasi kelas ini ke RestApiLahanRepository dengan package http atau dio:
/// ```dart
/// class RestApiLahanRepository implements LahanRepository {
///   final String baseUrl = 'http://api.agroplan.local/api';
///   @override
///   Future<List<Lahan>> getDaftarLahan() async {
///     final response = await http.get(Uri.parse('$baseUrl/lahan'));
///     ...
///   }
/// }
/// ```
class MockLahanRepository implements LahanRepository {
  // Data awal sesuai tampilan Figma
  final List<Lahan> _mockLahan = [
    Lahan(
      idLahan: 1,
      namaLahan: 'Lahan Utama',
      luasLahan: 0.5,
      jenisTanah: 'Aluvial',
      komoditasUtama: 'Padi',
      lokasi: 'Kab. Padang',
      fotoUrl: 'assets/images/lahan_padi.webp',
      tanggalDibuat: DateTime(2026, 9, 1),
      tanggalDiubah: DateTime(2026, 9, 13),
    ),
    Lahan(
      idLahan: 2,
      namaLahan: 'Lahan Belakang',
      luasLahan: 0.3,
      jenisTanah: 'Lempung',
      komoditasUtama: 'Jagung',
      lokasi: 'Kab. Padang',
      fotoUrl: 'assets/images/lahan_jagung.webp',
      tanggalDibuat: DateTime(2026, 9, 5),
      tanggalDiubah: DateTime(2026, 9, 13),
    ),
  ];

  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  @override
  Future<List<Lahan>> getDaftarLahan({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return List.unmodifiable(_mockLahan);
  }

  @override
  Future<Lahan> getDetailLahan(int idLahan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockLahan.firstWhere(
      (lahan) => lahan.idLahan == idLahan,
      orElse: () => throw Exception('Lahan dengan ID $idLahan tidak ditemukan'),
    );
  }

  @override
  Future<bool> tambahLahan(Lahan lahan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockLahan.add(lahan);
    return true;
  }

  @override
  Future<bool> updateLahan(Lahan lahan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockLahan.indexWhere((item) => item.idLahan == lahan.idLahan);
    if (index != -1) {
      _mockLahan[index] = lahan;
      return true;
    }
    return false;
  }

  @override
  Future<bool> hapusLahan(int idLahan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final countBefore = _mockLahan.length;
    _mockLahan.removeWhere((item) => item.idLahan == idLahan);
    return _mockLahan.length < countBefore;
  }
}