import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/data/lahan_repository.dart';
import 'package:agroplan/data/siklus_repository.dart';
import 'package:agroplan/models/lahan.dart';
import 'package:agroplan/models/siklus_tanam.dart';
import 'package:agroplan/providers/lahan_provider.dart';
import 'package:agroplan/providers/perawatan_provider.dart';
import 'package:agroplan/providers/siklus_provider.dart';
import 'package:agroplan/utils/validators.dart';

void main() {
  group('Validators - Workflow Tambah Lahan Baru (FR-01)', () {
    test('positiveNumber: memvalidasi format angka luas lahan positif', () {
      expect(Validators.positiveNumber(null, fieldName: 'Luas'), equals('Luas wajib diisi'));
      expect(Validators.positiveNumber('', fieldName: 'Luas'), equals('Luas wajib diisi'));
      expect(Validators.positiveNumber('abc', fieldName: 'Luas'), equals('Luas harus berupa angka lebih dari 0'));
      expect(Validators.positiveNumber('0', fieldName: 'Luas'), equals('Luas harus berupa angka lebih dari 0'));
      expect(Validators.positiveNumber('-1.5', fieldName: 'Luas'), equals('Luas harus berupa angka lebih dari 0'));

      // Format desimal titik dan koma valid
      expect(Validators.positiveNumber('0.5', fieldName: 'Luas'), isNull);
      expect(Validators.positiveNumber('1,2', fieldName: 'Luas'), isNull);
      expect(Validators.positiveNumber('10', fieldName: 'Luas'), isNull);
    });

    test('minLength: nama lahan dan lokasi minimal 3 karakter', () {
      expect(Validators.minLength('ab', 3, fieldName: 'Nama lahan'), equals('Nama lahan minimal 3 karakter'));
      expect(Validators.minLength('Lahan Jagung', 3, fieldName: 'Nama lahan'), isNull);
      expect(Validators.minLength('Pd', 3, fieldName: 'Lokasi'), equals('Lokasi minimal 3 karakter'));
      expect(Validators.minLength('Padang', 3, fieldName: 'Lokasi'), isNull);
    });

    test('requiredDropdown: komoditas wajib dipilih', () {
      expect(Validators.requiredDropdown(null, fieldName: 'Komoditas'), equals('Komoditas wajib dipilih'));
      expect(Validators.requiredDropdown('Padi', fieldName: 'Komoditas'), isNull);
    });
  });

  group('Modul 1: Manajemen Lahan (FR-01 s.d. FR-04)', () {
    test('FR-01 & FR-02: Format luas, chipText, dan profil model Lahan', () {
      final lahan = Lahan(
        idLahan: 10,
        namaLahan: 'Lahan Cabai Timur',
        luasLahan: 0.75,
        komoditasUtama: 'Cabai Merah',
        lokasi: 'Padang Pariaman',
        tanggalDibuat: DateTime.now(),
      );

      expect(lahan.luasFormatted, equals('0,75 ha'));
      expect(lahan.chipText, equals('0,75 ha • Cabai Merah'));
      expect(lahan.lokasi, equals('Padang Pariaman'));
    });

    test('FR-01: LahanProvider tambahLahan menambahkan item baru ke state', () async {
      final repo = MockLahanRepository();
      final provider = LahanProvider(repository: repo);

      await Future.delayed(const Duration(milliseconds: 350));
      final initialCount = provider.lahanList.length;

      final lahanBaru = Lahan(
        idLahan: 99,
        namaLahan: 'Lahan Jagung Baru',
        luasLahan: 1.5,
        komoditasUtama: 'Jagung',
        lokasi: 'Kab. Solok',
        tanggalDibuat: DateTime.now(),
      );

      final success = await provider.tambahLahan(lahanBaru);
      expect(success, isTrue);
      expect(provider.lahanList.length, equals(initialCount + 1));
      expect(provider.lahanList.any((l) => l.idLahan == 99), isTrue);
    });

    test('FR-03: LahanProvider updateLahan memperbarui data lahan yang ada', () async {
      final repo = MockLahanRepository();
      final provider = LahanProvider(repository: repo);

      await Future.delayed(const Duration(milliseconds: 350));
      final lahanLama = provider.lahanList.first;

      final lahanUpdate = lahanLama.copyWith(
        namaLahan: 'Lahan Utama Diperbarui',
        luasLahan: 1.25,
      );

      final success = await provider.updateLahan(lahanUpdate);
      expect(success, isTrue);

      final updated = provider.lahanList.firstWhere((l) => l.idLahan == lahanLama.idLahan);
      expect(updated.namaLahan, equals('Lahan Utama Diperbarui'));
      expect(updated.luasLahan, equals(1.25));
    });

    test('FR-04: LahanProvider hapusLahan menghapus data lahan dari state', () async {
      final repo = MockLahanRepository();
      final provider = LahanProvider(repository: repo);

      await Future.delayed(const Duration(milliseconds: 350));
      final countBefore = provider.lahanList.length;
      final targetId = provider.lahanList.first.idLahan;

      final success = await provider.hapusLahan(targetId);
      expect(success, isTrue);
      expect(provider.lahanList.length, equals(countBefore - 1));
      expect(provider.lahanList.any((l) => l.idLahan == targetId), isFalse);
    });
  });

  group('Modul 1: Siklus Tanam (FR-05)', () {
    test('SiklusTanam model menghitung HST dan formattedTanggalTanam dengan benar', () {
      final tanamTgl = DateTime.now().subtract(const Duration(days: 10));
      final siklus = SiklusTanam(
        idSiklus: 1,
        idLahan: 1,
        namaLahan: 'Lahan Utama',
        komoditas: 'Padi',
        tanggalRencanaTanam: tanamTgl,
        statusSiklus: 'Berjalan',
      );

      expect(siklus.isBerjalan, isTrue);
      expect(siklus.hst, equals(10));
      expect(siklus.komoditas, equals('Padi'));
    });

    test('FR-05: Menambahkan siklus tanam baru memicu pembuatan jadwal otomatis', () async {
      final siklusRepo = MockSiklusRepository();
      final siklusProvider = SiklusProvider(repository: siklusRepo);
      final perawatanProvider = PerawatanProvider();

      await Future.delayed(const Duration(milliseconds: 250));

      final dummyLahan = Lahan(
        idLahan: 50,
        namaLahan: 'Lahan Kedelai Barat',
        luasLahan: 0.8,
        komoditasUtama: 'Belum Ditanami',
        lokasi: 'Kab. Agam',
      );

      final siklusBaru = SiklusTanam(
        idSiklus: 99,
        idLahan: 50,
        namaLahan: dummyLahan.namaLahan,
        komoditas: 'Kedelai',
        tanggalRencanaTanam: DateTime.now(),
        statusSiklus: 'Berjalan',
      );

      final success = await siklusProvider.tambahSiklus(
        siklus: siklusBaru,
        lahan: dummyLahan,
        perawatanProvider: perawatanProvider,
      );

      expect(success, isTrue);
      expect(siklusProvider.siklusList.any((s) => s.idSiklus == 99), isTrue);

      // Verifikasi jadwal perawatan otomatis ter-generate di PerawatanProvider (FR-13)
      final jadwalLahanIni = perawatanProvider.jadwalList.where((j) => j.idLahan == 50).toList();
      expect(jadwalLahanIni.isNotEmpty, isTrue);
      expect(jadwalLahanIni.first.komoditas, equals('Kedelai'));
    });

    test('FR-05: Validasi PRD menolak siklus baru jika lahan masih punya siklus aktif', () async {
      final siklusRepo = MockSiklusRepository();
      final siklusProvider = SiklusProvider(repository: siklusRepo);

      await Future.delayed(const Duration(milliseconds: 250));

      // Lahan ID 1 di mock sudah memiliki siklus aktif Padi
      final siklusDuplikat = SiklusTanam(
        idSiklus: 101,
        idLahan: 1, // Lahan Utama
        namaLahan: 'Lahan Utama',
        komoditas: 'Jagung',
        tanggalRencanaTanam: DateTime.now(),
        statusSiklus: 'Berjalan',
      );

      final success = await siklusProvider.tambahSiklus(siklus: siklusDuplikat);
      expect(success, isFalse);
      expect(siklusProvider.errorMessage, contains('masih memiliki siklus aktif'));
    });
  });
}
