import 'package:flutter/material.dart';
import '../data/siklus_repository.dart';
import '../models/lahan.dart';
import '../models/siklus_tanam.dart';
import 'perawatan_provider.dart';

/// Provider pengelola state Siklus Tanam (Modul 1: FR-05).
/// Terintegrasi dengan PerawatanProvider untuk pembuatan jadwal otomatis.
class SiklusProvider extends ChangeNotifier {
  final SiklusRepository _repository;

  List<SiklusTanam> _siklusList = [];
  bool _isLoading = false;
  String? _errorMessage;

  SiklusProvider({SiklusRepository? repository})
      : _repository = repository ?? MockSiklusRepository() {
    loadDaftarSiklus();
  }

  List<SiklusTanam> get siklusList => _siklusList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat seluruh daftar siklus tanam dari repository
  Future<void> loadDaftarSiklus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _siklusList = await _repository.getDaftarSiklus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data siklus: $e';
      notifyListeners();
    }
  }

  /// Mendapatkan siklus aktif (status: 'Berjalan') pada suatu lahan (PRD 2.5.4)
  SiklusTanam? getSiklusAktif(int idLahan) {
    try {
      return _siklusList.firstWhere(
        (s) => s.idLahan == idLahan && s.isBerjalan,
      );
    } catch (_) {
      return null;
    }
  }

  /// Mendapatkan seluruh riwayat siklus tanam pada suatu lahan
  List<SiklusTanam> getSiklusByLahan(int idLahan) {
    return _siklusList.where((s) => s.idLahan == idLahan).toList();
  }

  /// Menambahkan siklus tanam baru untuk suatu lahan (FR-05)
  ///
  /// Secara otomatis memicu pembuatan jadwal perawatan pada Modul 3
  /// via [perawatanProvider.generateJadwalOtomatis].
  Future<bool> tambahSiklus({
    required SiklusTanam siklus,
    Lahan? lahan,
    dynamic lahanProvider,
    PerawatanProvider? perawatanProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validasi aturan PRD: satu lahan hanya dapat memiliki 1 siklus aktif
      final siklusAktif = getSiklusAktif(siklus.idLahan);
      if (siklusAktif != null) {
        throw Exception(
          'Lahan "${siklus.namaLahan}" masih memiliki siklus aktif (${siklusAktif.komoditas}). Selesaikan siklus sebelumnya terlebih dahulu.',
        );
      }

      final success = await _repository.tambahSiklus(siklus);
      if (success) {
        await loadDaftarSiklus();

        // Update komoditas acuan lahan jika ada
        if (lahan != null && lahanProvider != null) {
          try {
            lahanProvider.updateLahan(lahan.copyWith(komoditasUtama: siklus.komoditas));
          } catch (_) {}
        }

        // Integrasi Modul 1 → Modul 3: Generate jadwal perawatan otomatis
        if (perawatanProvider != null && lahan != null) {
          perawatanProvider.generateJadwalOtomatis(
            lahan: lahan,
            komoditas: siklus.komoditas,
            tanggalTanam: siklus.tanggalRencanaTanam,
          );
        }
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Menandai siklus tanam sebagai 'Selesai' (FR-18)
  Future<bool> selesaikanSiklus(int idSiklus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.updateStatusSiklus(idSiklus, 'Selesai');
      if (success) {
        await loadDaftarSiklus();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyelesaikan siklus: $e';
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui tanggal tanam pada siklus aktif dan menyesuaikan jadwal perawatan belum selesai (FR-13).
  Future<bool> updateTanggalTanam({
    required int idSiklus,
    required int idLahan,
    required DateTime tanggalBaru,
    PerawatanProvider? perawatanProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.updateTanggalTanam(idSiklus, tanggalBaru);
      if (success) {
        await loadDaftarSiklus();

        // FR-13: Jika tanggal tanam berubah, jadwal yang belum selesai disesuaikan
        if (perawatanProvider != null) {
          perawatanProvider.sesuaikanTanggalTanam(
            idLahan: idLahan,
            tanggalTanamBaru: tanggalBaru,
          );
        }
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui tanggal tanam: $e';
      notifyListeners();
      return false;
    }
  }
}
