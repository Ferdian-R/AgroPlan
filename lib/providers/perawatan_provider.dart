import 'package:flutter/material.dart';
import '../data/referensi_komoditas.dart';
import '../models/jadwal_perawatan.dart';
import '../models/lahan.dart';

/// Provider pengelola state Jadwal Perawatan & Estimasi Panen (Modul 3).
///
/// Mengelola:
/// - Jadwal perawatan otomatis dari template komoditas (FR-13)
/// - Jadwal perawatan manual yang ditambah pengguna
/// - Status pelaksanaan: Belum / Selesai / Ditunda (FR-15)
/// - Estimasi panen otomatis: Luas (ha) × Produktivitas (ton/ha) (FR-16)
class PerawatanProvider extends ChangeNotifier {
  // ─────────────── STATE ───────────────
  final List<JadwalPerawatan> _jadwalList = [];
  int _idCounter = 0;

  List<JadwalPerawatan> get jadwalList => List.unmodifiable(_jadwalList);

  // ─────────── FR-13: Generate Jadwal Otomatis dari Template ───────────

  /// Buat jadwal perawatan otomatis berdasarkan komoditas dan tanggal tanam.
  /// Dipanggil saat siklus tanam baru dibuat (Modul 1 → Modul 3).
  void generateJadwalOtomatis({
    required Lahan lahan,
    required String komoditas,
    required DateTime tanggalTanam,
  }) {
    final templates = DataReferensi.templateUntukKomoditas(komoditas);

    for (final template in templates) {
      _idCounter++;
      final jadwal = JadwalPerawatan.dariTemplate(
        id: _idCounter,
        idLahan: lahan.idLahan,
        namaLahan: lahan.namaLahan,
        komoditas: komoditas,
        tanggalTanam: tanggalTanam,
        namaKegiatan: template.namaKegiatan,
        hstPengingat: template.hstPengingat,
        waktuSumber: template.waktuSumber,
      );
      _jadwalList.add(jadwal);
    }

    // Urutkan jadwal berdasarkan tanggal
    _jadwalList.sort(
      (a, b) => a.tanggalPelaksanaan.compareTo(b.tanggalPelaksanaan),
    );
    notifyListeners();
  }

  // ─────────── CRUD Manual ───────────

  /// Tambah jadwal perawatan manual
  void tambahJadwal(JadwalPerawatan jadwal) {
    _idCounter++;
    final withId = jadwal.copyWith(id: _idCounter);
    _jadwalList.add(withId);
    _jadwalList.sort(
      (a, b) => a.tanggalPelaksanaan.compareTo(b.tanggalPelaksanaan),
    );
    notifyListeners();
  }

  /// Update jadwal (edit data)
  void updateJadwal(JadwalPerawatan jadwalBaru) {
    final index = _jadwalList.indexWhere((j) => j.id == jadwalBaru.id);
    if (index != -1) {
      _jadwalList[index] = jadwalBaru;
      _jadwalList.sort(
        (a, b) => a.tanggalPelaksanaan.compareTo(b.tanggalPelaksanaan),
      );
      notifyListeners();
    }
  }

  /// Hapus jadwal berdasarkan ID
  void hapusJadwal(int id) {
    _jadwalList.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  // ─────────── FR-15: Update Status Pelaksanaan ───────────

  /// Ubah status menjadi Selesai
  void tandaiSelesai(int id) {
    final index = _jadwalList.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jadwalList[index] = _jadwalList[index].copyWith(
        status: StatusPelaksanaan.selesai,
      );
      notifyListeners();
    }
  }

  /// Ubah status menjadi Ditunda dengan tanggal baru
  void tandaiDitunda(int id, DateTime tanggalBaru) {
    final index = _jadwalList.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jadwalList[index] = _jadwalList[index].copyWith(
        status: StatusPelaksanaan.ditunda,
        tanggalDitunda: tanggalBaru,
      );
      _jadwalList.sort(
        (a, b) => a.tanggalEfektif.compareTo(b.tanggalEfektif),
      );
      notifyListeners();
    }
  }

  /// Kembalikan status ke Belum (reset)
  void tandaiBelum(int id) {
    final index = _jadwalList.indexWhere((j) => j.id == id);
    if (index != -1) {
      // Buat ulang tanpa tanggalDitunda
      _jadwalList[index] = JadwalPerawatan(
        id: _jadwalList[index].id,
        namaKegiatan: _jadwalList[index].namaKegiatan,
        idLahan: _jadwalList[index].idLahan,
        namaLahan: _jadwalList[index].namaLahan,
        jenisPerawatan: _jadwalList[index].jenisPerawatan,
        tanggalPelaksanaan: _jadwalList[index].tanggalPelaksanaan,
        catatan: _jadwalList[index].catatan,
        tanggalDibuat: _jadwalList[index].tanggalDibuat,
        status: StatusPelaksanaan.belum,
        waktuSumber: _jadwalList[index].waktuSumber,
        hstPengingat: _jadwalList[index].hstPengingat,
        komoditas: _jadwalList[index].komoditas,
        isOtomatis: _jadwalList[index].isOtomatis,
      );
      notifyListeners();
    }
  }

  // ─────────── FR-14: Filter & Query ───────────

  /// Jadwal untuk lahan tertentu
  List<JadwalPerawatan> jadwalUntukLahan(int idLahan) {
    return _jadwalList.where((j) => j.idLahan == idLahan).toList();
  }

  /// Jadwal dengan status tertentu
  List<JadwalPerawatan> jadwalDenganStatus(StatusPelaksanaan status) {
    return _jadwalList.where((j) => j.status == status).toList();
  }

  /// Jumlah jadwal per status (untuk ringkasan)
  int get jumlahBelum =>
      _jadwalList.where((j) => j.status == StatusPelaksanaan.belum).length;
  int get jumlahSelesai =>
      _jadwalList.where((j) => j.status == StatusPelaksanaan.selesai).length;
  int get jumlahDitunda =>
      _jadwalList.where((j) => j.status == StatusPelaksanaan.ditunda).length;

  /// Jadwal yang sudah jatuh tempo dan belum selesai (untuk peringatan)
  List<JadwalPerawatan> get jadwalJatuhTempo {
    return _jadwalList
        .where((j) => j.isJatuhTempo && j.status == StatusPelaksanaan.belum)
        .toList();
  }

  // ─────────── FR-16: Estimasi Panen ───────────

  /// Hitung estimasi panen untuk komoditas dan luas lahan tertentu.
  /// Rumus PRD: Estimasi (ton) = Luas (ha) × Produktivitas (ton/ha)
  /// Mengembalikan null jika komoditas tidak ditemukan.
  static double? hitungEstimasi({
    required String komoditas,
    required double luasHa,
  }) {
    final ref = DataReferensi.cariKomoditas(komoditas);
    if (ref == null) return null;
    return luasHa * ref.produktivitas;
  }

  /// Ambil data referensi komoditas (untuk tampilan detail estimasi)
  static ReferensiKomoditas? getReferensiKomoditas(String komoditas) {
    return DataReferensi.cariKomoditas(komoditas);
  }
}
