import 'package:flutter/material.dart';
import '../data/laporan_repository.dart';
import '../models/laporan_kondisi.dart';

/// Provider pengelola state Laporan Kondisi Lahan (Modul 2: Monitoring & Peringatan Dini).
/// Mengelola alur State, mutasi data, dan notifikasi UI (ChangeNotifier).
class LaporanProvider extends ChangeNotifier {
  final LaporanRepository _repository;

  List<LaporanKondisi> _laporanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  LaporanProvider({LaporanRepository? repository})
      : _repository = repository ?? MockLaporanRepository() {
    loadDaftarLaporan();
  }

  List<LaporanKondisi> get laporanList => _laporanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Jumlah laporan dengan status 'Risiko Tinggi' (FR-12)
  int get jumlahRisikoTinggi =>
      _laporanList.where((item) => item.isRisikoTinggi).length;

  /// Memuat riwayat laporan kondisi dari repository
  Future<void> loadDaftarLaporan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _laporanList = await _repository.getDaftarLaporan();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat riwayat laporan: $e';
      notifyListeners();
    }
  }

  /// Menambahkan laporan kondisi baru (FR-07, FR-08, FR-12)
  Future<bool> tambahLaporan(LaporanKondisi laporan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.tambahLaporan(laporan);
      if (success) {
        await loadDaftarLaporan();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menambahkan laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui laporan kondisi yang ada (FR-10)
  Future<bool> updateLaporan(LaporanKondisi laporan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.updateLaporan(laporan);
      if (success) {
        await loadDaftarLaporan();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Menghapus laporan kondisi (FR-11)
  Future<bool> hapusLaporan(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.hapusLaporan(id);
      if (success) {
        await loadDaftarLaporan();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mendapatkan riwayat laporan untuk satu lahan spesifik
  List<LaporanKondisi> getLaporanByLahan(int idLahan) {
    return _laporanList.where((item) => item.idLahan == idLahan).toList();
  }
}
