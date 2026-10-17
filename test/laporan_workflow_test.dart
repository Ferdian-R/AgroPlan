import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/models/laporan_kondisi.dart';
import 'package:agroplan/data/laporan_repository.dart';
import 'package:agroplan/providers/laporan_provider.dart';
import 'package:agroplan/utils/validators.dart';

void main() {
  group('Validators - Workflow Laporan Kondisi Lahan (Modul 2)', () {
    test('requiredDropdown: memvalidasi pilihan lahan dan jenis kondisi', () {
      expect(
        Validators.requiredDropdown(null, fieldName: 'Lahan'),
        'Lahan wajib dipilih',
      );
      expect(
        Validators.requiredDropdown('Kekeringan', fieldName: 'Jenis kondisi'),
        isNull,
      );
    });

    test('minLength: catatan observasi minimal 5 karakter', () {
      expect(
        Validators.minLength('', 5, fieldName: 'Catatan observasi'),
        'Catatan observasi wajib diisi',
      );
      expect(
        Validators.minLength('oke', 5, fieldName: 'Catatan observasi'),
        'Catatan observasi minimal 5 karakter',
      );
      expect(
        Validators.minLength('Tanaman subur dan sehat', 5, fieldName: 'Catatan observasi'),
        isNull,
      );
    });
  });

  group('LaporanKondisi Model Helper & Business Logic', () {
    test('getter isNormal, isBermasalah, dan hasFoto berfungsi akurat', () {
      final laporanHama = LaporanKondisi(
        id: 99,
        idLahan: 1,
        idSiklus: 1,
        namaLahan: 'Lahan Uji',
        tanggalLapor: DateTime(2026, 10, 4),
        jenisKondisi: 'Hama',
        catatan: 'Catatan uji lapangan',
        fotoUrl: 'assets/images/lahan_padi.webp',
      );
      expect(laporanHama.isNormal, isFalse);
      expect(laporanHama.isBermasalah, isTrue);
      expect(laporanHama.hasFoto, isTrue);
      expect(laporanHama.formattedTanggal, '04 Okt 2026');

      final laporanNormal = LaporanKondisi(
        id: 100,
        idLahan: 1,
        idSiklus: 1,
        namaLahan: 'Lahan Normal',
        tanggalLapor: DateTime(2026, 10, 5),
        jenisKondisi: 'Normal',
        catatan: 'Kondisi tanaman sehat',
      );
      expect(laporanNormal.isNormal, isTrue);
      expect(laporanNormal.isBermasalah, isFalse);
      expect(laporanNormal.hasFoto, isFalse);
    });
  });

  group('LaporanProvider State Management Tests', () {
    late LaporanProvider provider;

    setUp(() {
      provider = LaporanProvider(repository: MockLaporanRepository());
    });

    test('loadDaftarLaporan memuat initial mock data sesuai PRD v2', () async {
      await provider.loadDaftarLaporan();
      expect(provider.laporanList.isNotEmpty, isTrue);
      expect(provider.jumlahBermasalah, greaterThanOrEqualTo(1));
      expect(provider.jumlahDenganFoto, greaterThanOrEqualTo(1));
    });

    test('tambahLaporan menambahkan laporan baru ke daftar paling depan', () async {
      await provider.loadDaftarLaporan();
      final countBefore = provider.laporanList.length;

      final baru = LaporanKondisi(
        id: 101,
        idLahan: 2,
        idSiklus: 2,
        namaLahan: 'Kebun Jagung',
        tanggalLapor: DateTime.now(),
        jenisKondisi: 'Banjir',
        catatan: 'Air menggenang setinggi 20cm pasca hujan lebat semalaman.',
        fotoUrl: 'assets/images/lahan_jagung.webp',
      );

      final success = await provider.tambahLaporan(baru);
      expect(success, isTrue);
      expect(provider.laporanList.length, countBefore + 1);
      expect(provider.laporanList.first.id, 101);
      expect(provider.laporanList.first.isBermasalah, isTrue);
      expect(provider.laporanList.first.hasFoto, isTrue);
    });

    test('filterByJenisKondisi menyaring data dengan tepat', () async {
      await provider.loadDaftarLaporan();
      final hamaList = provider.filterByJenisKondisi('Hama');
      expect(hamaList.every((e) => e.jenisKondisi == 'Hama'), isTrue);

      final semuaList = provider.filterByJenisKondisi('Semua');
      expect(semuaList.length, provider.laporanList.length);
    });

    test('hapusLaporan menghapus item berdasarkan id', () async {
      await provider.loadDaftarLaporan();
      final idToDelete = provider.laporanList.first.id;
      final countBefore = provider.laporanList.length;

      final success = await provider.hapusLaporan(idToDelete);
      expect(success, isTrue);
      expect(provider.laporanList.length, countBefore - 1);
      expect(provider.laporanList.any((e) => e.id == idToDelete), isFalse);
    });
  });
}
