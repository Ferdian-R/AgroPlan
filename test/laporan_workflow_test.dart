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

  group('LaporanKondisi Model & Business Logic (FR-12)', () {
    test('tentukanStatusRisiko menghasilkan Risiko Tinggi jika keparahan Berat', () {
      final risiko = LaporanKondisi.tentukanStatusRisiko(
        jenisKondisi: 'Kekeringan',
        tingkatKeparahan: 'Berat',
      );
      expect(risiko, 'Risiko Tinggi');
    });

    test('tentukanStatusRisiko menghasilkan Risiko Tinggi jika Hama dengan keparahan Sedang', () {
      final risiko = LaporanKondisi.tentukanStatusRisiko(
        jenisKondisi: 'Serangan Hama/Penyakit',
        tingkatKeparahan: 'Sedang',
      );
      expect(risiko, 'Risiko Tinggi');
    });

    test('tentukanStatusRisiko menghasilkan Normal jika kondisi Normal atau keparahan Rendah', () {
      final risiko = LaporanKondisi.tentukanStatusRisiko(
        jenisKondisi: 'Normal',
        tingkatKeparahan: 'Rendah',
      );
      expect(risiko, 'Normal');
    });

    test('formattedTanggal menampilkan format tanggal yang benar', () {
      final laporan = LaporanKondisi(
        id: 99,
        idLahan: 1,
        namaLahan: 'Lahan Uji',
        tanggalLapor: DateTime(2026, 10, 4),
        jenisKondisi: 'Normal',
        tingkatKeparahan: 'Rendah',
        catatan: 'Catatan uji',
        statusRisiko: 'Normal',
      );
      expect(laporan.formattedTanggal, '04 Okt 2026');
      expect(laporan.isRisikoTinggi, isFalse);
    });
  });

  group('LaporanProvider State Management Tests', () {
    late LaporanProvider provider;

    setUp(() {
      provider = LaporanProvider(repository: MockLaporanRepository());
    });

    test('loadDaftarLaporan memuat initial mock data', () async {
      await provider.loadDaftarLaporan();
      expect(provider.laporanList.isNotEmpty, isTrue);
      expect(provider.jumlahRisikoTinggi, greaterThanOrEqualTo(1));
    });

    test('tambahLaporan menambahkan laporan baru ke daftar paling depan', () async {
      await provider.loadDaftarLaporan();
      final countBefore = provider.laporanList.length;

      final baru = LaporanKondisi(
        id: 101,
        idLahan: 2,
        namaLahan: 'Kebun Jagung',
        tanggalLapor: DateTime.now(),
        jenisKondisi: 'Banjir/Tergenang',
        tingkatKeparahan: 'Berat',
        catatan: 'Air menggenang setinggi 20cm pasca hujan lebat semalaman.',
        statusRisiko: 'Risiko Tinggi',
      );

      final success = await provider.tambahLaporan(baru);
      expect(success, isTrue);
      expect(provider.laporanList.length, countBefore + 1);
      expect(provider.laporanList.first.id, 101);
      expect(provider.laporanList.first.isRisikoTinggi, isTrue);
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
