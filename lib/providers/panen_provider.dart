import 'package:flutter/material.dart';
import '../data/panen_repository.dart';
import '../models/riwayat_panen.dart';
import 'siklus_provider.dart';

/// Provider pengelola state Pencatatan & Riwayat Hasil Panen (Modul 3: FR-17 & FR-18).
class PanenProvider extends ChangeNotifier {
  final PanenRepository _repository;

  List<RiwayatPanen> _riwayatList = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _idCounter = 10;

  PanenProvider({PanenRepository? repository})
      : _repository = repository ?? MockPanenRepository() {
    loadRiwayatPanen();
  }

  List<RiwayatPanen> get riwayatList => List.unmodifiable(_riwayatList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Total tonase panen aktual yang telah dicatat
  double get totalHasilTon =>
      _riwayatList.fold(0.0, (acc, item) => acc + item.jumlahHasilTon);

  /// Total jumlah catatan panen yang tersimpan
  int get totalPanenCount => _riwayatList.length;

  /// Memuat daftar riwayat panen dari repository
  Future<void> loadRiwayatPanen() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.getRiwayatPanen();
      _riwayatList = List<RiwayatPanen>.from(list);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat riwayat panen: $e';
      notifyListeners();
    }
  }

  /// FR-17 & FR-18: Tambah catatan panen baru dan selesaikan siklus tanam terkait
  Future<bool> catatPanen({
    required RiwayatPanen panen,
    required SiklusProvider siklusProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _idCounter++;
      final withId = panen.copyWith(idPanen: _idCounter);

      final success = await _repository.tambahCatatanPanen(withId);
      if (success) {
        _riwayatList = [withId, ..._riwayatList];

        // PRD FR-18: Mengubah status siklus tanam menjadi 'Selesai'
        await siklusProvider.selesaikanSiklus(panen.idSiklus);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal mencatat panen: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mengambil riwayat panen berdasarkan ID Lahan
  List<RiwayatPanen> getRiwayatByLahan(int idLahan) {
    return _riwayatList.where((p) => p.idLahan == idLahan).toList();
  }

  /// Mengambil riwayat panen berdasarkan ID Siklus
  RiwayatPanen? getRiwayatBySiklus(int idSiklus) {
    try {
      return _riwayatList.firstWhere((p) => p.idSiklus == idSiklus);
    } catch (_) {
      return null;
    }
  }
}
