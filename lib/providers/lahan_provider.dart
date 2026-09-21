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

  /// Menambahkan lahan baru (persiapan untuk FR-01)
  Future<bool> tambahLahan(Lahan lahan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.tambahLahan(lahan);
      if (success) {
        await loadDaftarLahan();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menambah lahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
