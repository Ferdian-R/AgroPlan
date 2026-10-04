import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/models/jadwal_perawatan.dart';
import 'package:agroplan/utils/validators.dart';

void main() {
  group('Validators - Practical Workflow Tests', () {
    test('requiredField: mengembalikan error jika kosong / spasi saja', () {
      expect(Validators.requiredField(null), equals('Field ini wajib diisi'));
      expect(Validators.requiredField(''), equals('Field ini wajib diisi'));
      expect(Validators.requiredField('   '), equals('Field ini wajib diisi'));
      expect(Validators.requiredField('Pemupukan'), isNull);
    });

    test('minLength: mengembalikan error jika karakter kurang dari batas minimum', () {
      expect(Validators.minLength('ab', 3, fieldName: 'Nama'), equals('Nama minimal 3 karakter'));
      expect(Validators.minLength('abc', 3, fieldName: 'Nama'), isNull);
      expect(Validators.minLength('  a  ', 3, fieldName: 'Nama'), equals('Nama minimal 3 karakter'));
    });

    test('requiredDropdown: mengembalikan error jika null', () {
      expect(Validators.requiredDropdown(null, fieldName: 'Lahan'), equals('Lahan wajib dipilih'));
      expect(Validators.requiredDropdown('Lahan Blok A', fieldName: 'Lahan'), isNull);
    });

    test('futureDate: mengembalikan error jika null atau di masa lalu', () {
      expect(Validators.futureDate(null), equals('Tanggal wajib diisi'));

      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      expect(Validators.futureDate(pastDate), equals('Tanggal tidak boleh di masa lalu'));

      final today = DateTime.now();
      expect(Validators.futureDate(today), isNull);

      final futureDate = DateTime.now().add(const Duration(days: 7));
      expect(Validators.futureDate(futureDate), isNull);
    });
  });

  group('JadwalPerawatan Model Tests', () {
    test('Format tanggal dan ikon sesuai jenis perawatan', () {
      final jadwal = JadwalPerawatan(
        id: 1,
        namaKegiatan: 'Pemupukan NPK',
        idLahan: 10,
        namaLahan: 'Lahan Jagung Selatan',
        jenisPerawatan: 'Pemupukan',
        tanggalPelaksanaan: DateTime(2026, 10, 15),
        tanggalDibuat: DateTime(2026, 10, 4),
      );

      expect(jadwal.tanggalFormatted, equals('15 Okt 2026'));
      expect(jadwal.jenisIcon, equals('🌿'));
    });
  });
}
