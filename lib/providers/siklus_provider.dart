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

  /// Mendapatkan seluruh siklus aktif (status: 'Berjalan') pada suatu lahan
  List<SiklusTanam> getDaftarSiklusAktif(int idLahan) {
    return _siklusList
        .where((s) => s.idLahan == idLahan && s.isBerjalan)
        .toList();
  }

  /// Mendapatkan siklus aktif pertama (status: 'Berjalan') pada suatu lahan (jika ada)
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

  /// Mendapatkan siklus tanam berdasarkan id siklus
  SiklusTanam? getSiklusById(int idSiklus) {
    try {
      return _siklusList.firstWhere((s) => s.idSiklus == idSiklus);
    } catch (_) {
      return null;
    }
  }

  /// Menambahkan siklus tanam baru untuk suatu lahan (FR-05).
  /// Satu lahan dapat menampung beberapa siklus tanam aktif (multi-komoditas / tumpang sari).
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
      final success = await _repository.tambahSiklus(siklus);
      if (success) {
        await loadDaftarSiklus();

        // Update komoditas acuan lahan jika ada
        if (lahan != null && lahanProvider != null) {
          try {
            String komoditasBaru = siklus.komoditas;
            if (lahan.komoditasUtama.isNotEmpty &&
                lahan.komoditasUtama != 'Belum Ditanami') {
              final list = lahan.komoditasUtama
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              if (!list.contains(siklus.komoditas)) {
                list.add(siklus.komoditas);
                komoditasBaru = list.join(', ');
              } else {
                komoditasBaru = lahan.komoditasUtama;
              }
            }
            lahanProvider.updateLahan(lahan.copyWith(komoditasUtama: komoditasBaru));
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
    String? komoditas,
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
            komoditas: komoditas,
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
