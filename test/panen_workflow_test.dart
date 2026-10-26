import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/models/riwayat_panen.dart';
import 'package:agroplan/data/siklus_repository.dart';
import 'package:agroplan/providers/siklus_provider.dart';
import 'package:agroplan/data/panen_repository.dart';
import 'package:agroplan/providers/panen_provider.dart';

void main() {
  group('Modul 3: FR-17 & FR-18 (Pencatatan & Riwayat Panen)', () {
    late SiklusProvider siklusProvider;
    late PanenProvider panenProvider;

    setUp(() async {
      siklusProvider = SiklusProvider(repository: MockSiklusRepository());
      panenProvider = PanenProvider(repository: MockPanenRepository());
      await siklusProvider.loadDaftarSiklus();
      await panenProvider.loadRiwayatPanen();
    });

    test('RiwayatPanen model calculation (selisih, persentase, statusEvaluasi)', () {
      final panen = RiwayatPanen(
        idPanen: 101,
        idSiklus: 1,
        idLahan: 1,
        namaLahan: 'Lahan Sawah Barat',
        komoditas: 'Padi',
        luasLahan: 2.0,
        tanggalPanen: DateTime(2026, 10, 25),
        jumlahHasilTon: 10.0,
        estimasiHasilTon: 9.188,
        catatan: 'Hasil panen melimpah',
        tanggalDibuat: DateTime(2026, 10, 25),
      );

      expect(panen.selisihTon, closeTo(0.812, 0.001));
      expect(panen.persentasePencapaian, greaterThan(100.0));
      expect(panen.statusEvaluasi, equals('Melampaui Target'));
    });

    test('PanenProvider.catatPanen otomatis mengubah status siklus tanam menjadi Selesai (FR-18)', () async {
      // Pastikan ada siklus aktif id = 1
      final siklusAwal = siklusProvider.getSiklusById(1);
      expect(siklusAwal, isNotNull);
      expect(siklusAwal!.isBerjalan, isTrue);

      final panenBaru = RiwayatPanen(
        idPanen: 999,
        idSiklus: 1,
        idLahan: siklusAwal.idLahan,
        namaLahan: siklusAwal.namaLahan,
        komoditas: siklusAwal.komoditas,
        luasLahan: 2.0,
        tanggalPanen: DateTime.now(),
        jumlahHasilTon: 9.5,
        estimasiHasilTon: 9.188,
        catatan: 'Panen selesai dan berhasil',
        tanggalDibuat: DateTime.now(),
      );

      // Simpan panen dengan integrasi siklusProvider
      final success = await panenProvider.catatPanen(
        panen: panenBaru,
        siklusProvider: siklusProvider,
      );

      expect(success, isTrue);
      // Data panen bertambah
      expect(panenProvider.riwayatList.any((p) => p.idSiklus == 1), isTrue);

      // Status siklus tanam terkait harus otomatis menjadi 'Selesai' (FR-18)
      final siklusAkhir = siklusProvider.getSiklusById(1);
      expect(siklusAkhir!.isBerjalan, isFalse);
      expect(siklusAkhir.statusSiklus, equals('Selesai'));
    });
  });
}
