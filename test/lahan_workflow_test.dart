import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/data/lahan_repository.dart';
import 'package:agroplan/models/lahan.dart';
import 'package:agroplan/providers/lahan_provider.dart';
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

    test('requiredDropdown: komoditas dan jenis tanah wajib dipilih', () {
      expect(Validators.requiredDropdown(null, fieldName: 'Komoditas'), equals('Komoditas wajib dipilih'));
      expect(Validators.requiredDropdown('Padi', fieldName: 'Komoditas'), isNull);
      expect(Validators.requiredDropdown(null, fieldName: 'Jenis tanah'), equals('Jenis tanah wajib dipilih'));
      expect(Validators.requiredDropdown('Aluvial', fieldName: 'Jenis tanah'), isNull);
    });
  });

  group('Lahan Model & Provider Tests', () {
    test('Format luas dan chipText model Lahan sesuai', () {
      final lahan = Lahan(
        idLahan: 10,
        namaLahan: 'Lahan Cabai Timur',
        luasLahan: 0.75,
        komoditasUtama: 'Cabai',
        jenisTanah: 'Andosol',
        lokasi: 'Padang Pariaman',
        tanggalDibuat: DateTime.now(),
      );

      expect(lahan.luasFormatted, equals('0,75 ha'));
      expect(lahan.chipText, equals('0,75 ha • Cabai'));
    });

    test('LahanProvider tambahLahan menambahkan item baru ke state', () async {
      final repo = MockLahanRepository();
      final provider = LahanProvider(repository: repo);

      // Tunggu inisialisasi selesai
      await Future.delayed(const Duration(milliseconds: 350));
      final initialCount = provider.lahanList.length;

      final lahanBaru = Lahan(
        idLahan: 99,
        namaLahan: 'Lahan Jagung Baru',
        luasLahan: 1.5,
        komoditasUtama: 'Jagung',
        jenisTanah: 'Lempung',
        lokasi: 'Kab. Solok',
        tanggalDibuat: DateTime.now(),
      );

      final success = await provider.tambahLahan(lahanBaru);
      expect(success, isTrue);
      expect(provider.lahanList.length, equals(initialCount + 1));
      expect(provider.lahanList.any((l) => l.idLahan == 99), isTrue);
    });
  });
}
