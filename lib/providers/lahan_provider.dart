import 'package:flutter/material.dart';
import '../data/lahan_repository.dart';
import '../models/lahan.dart';

/// Provider pengelola state Lahan (Modul 1: Manajemen Lahan & Siklus Tanam).
/// Memisahkan logika pengambilan data dari UI HomeScreen.
class LahanProvider extends ChangeNotifier {
  final LahanRepository _repository;

  List<Lahan> _lahanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  LahanProvider({LahanRepository? repository})
      : _repository = repository ?? MockLahanRepository() {
    // Muat data awal secara otomatis
    loadDaftarLahan();
  }

  List<Lahan> get lahanList => _lahanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat daftar lahan dari repository
  Future<void> loadDaftarLahan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lahanList = await _repository.getDaftarLahan();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data lahan: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Helper terpusat untuk operasi data (tambah/update/hapus) agar alur loading,
  /// refresh data, dan penanganan error tidak berulang.
  Future<bool> _kelolaAksi(
    Future<bool> Function() aksi,
    String pesanError,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await aksi();
      if (success) {
        await loadDaftarLahan();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '$pesanError: $e';
      notifyListeners();
      return false;
    }
  }

  /// Menambahkan lahan baru (FR-01)
  Future<bool> tambahLahan(Lahan lahan) =>
      _kelolaAksi(() => _repository.tambahLahan(lahan), 'Gagal menambah lahan');

  /// Memperbarui data lahan (FR-02)
  Future<bool> updateLahan(Lahan lahan) =>
      _kelolaAksi(() => _repository.updateLahan(lahan), 'Gagal memperbarui lahan');

  /// Menghapus data lahan (FR-03)
  Future<bool> hapusLahan(int idLahan) =>
      _kelolaAksi(() => _repository.hapusLahan(idLahan), 'Gagal menghapus lahan');
}
