import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/data/referensi_komoditas.dart';
import 'package:agroplan/models/jadwal_perawatan.dart';
import 'package:agroplan/models/lahan.dart';
import 'package:agroplan/providers/perawatan_provider.dart';
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

  group('JadwalPerawatan Model Tests (FR-13 s.d FR-15)', () {
    test('Format tanggal, icon, dan status default', () {
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
      expect(jadwal.status, equals(StatusPelaksanaan.belum));
      expect(jadwal.tanggalDitunda, isNull);
      expect(jadwal.tanggalEfektif, equals(DateTime(2026, 10, 15)));
    });

    test('Status ditunda mengubah tanggalEfektif ke tanggal tunda', () {
      final tglAsli = DateTime(2026, 10, 15);
      final tglTunda = DateTime(2026, 10, 20);

      final jadwal = JadwalPerawatan(
        id: 2,
        namaKegiatan: 'Penyemprotan Fungisida',
        idLahan: 10,
        namaLahan: 'Lahan Cabai',
        jenisPerawatan: 'Penyemprotan',
        tanggalPelaksanaan: tglAsli,
        tanggalDibuat: DateTime(2026, 10, 4),
        status: StatusPelaksanaan.ditunda,
        tanggalDitunda: tglTunda,
      );

      expect(jadwal.status, equals(StatusPelaksanaan.ditunda));
      expect(jadwal.tanggalEfektif, equals(tglTunda));
      expect(jadwal.tanggalDitundaFormatted, equals('20 Okt 2026'));
    });

    test('Pendeteksian jatuh tempo (isJatuhTempo)', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 5));

      final jadwalJatuhTempo = JadwalPerawatan(
        id: 3,
        namaKegiatan: 'Penyiangan Gulma',
        idLahan: 1,
        namaLahan: 'Lahan A',
        jenisPerawatan: 'Penyiangan',
        tanggalPelaksanaan: pastDate,
        tanggalDibuat: DateTime.now().subtract(const Duration(days: 10)),
      );

      final jadwalBelumJatuhTempo = JadwalPerawatan(
        id: 4,
        namaKegiatan: 'Pemupukan Lanjutan',
        idLahan: 1,
        namaLahan: 'Lahan A',
        jenisPerawatan: 'Pemupukan',
        tanggalPelaksanaan: futureDate,
        tanggalDibuat: DateTime.now(),
      );

      expect(jadwalJatuhTempo.isJatuhTempo, isTrue);
      expect(jadwalBelumJatuhTempo.isJatuhTempo, isFalse);
    });
  });

  group('DataReferensi Komoditas & Template Tests (PRD 2.5.2 & 2.5.3)', () {
    test('Daftar 6 komoditas PRD tersedia dengan produktivitas resmi', () {
      expect(DataReferensi.daftarKomoditas.length, equals(6));

      final padi = DataReferensi.cariKomoditas('Padi');
      expect(padi, isNotNull);
      expect(padi!.produktivitas, equals(4.594));
      expect(padi.wilayahAcuan, equals('Sumatera Barat'));

      final cabai = DataReferensi.cariKomoditas('Cabai Merah');
      expect(cabai, isNotNull);
      expect(cabai!.produktivitas, equals(10.62));

      final jagung = DataReferensi.cariKomoditas('Jagung');
      expect(jagung, isNotNull);
      expect(jagung!.produktivitas, equals(6.176));
    });

    test('Pencarian komoditas case-insensitive dan penanganan komoditas tidak dikenal', () {
      expect(DataReferensi.cariKomoditas('padi'), isNotNull);
      expect(DataReferensi.cariKomoditas('PADI'), isNotNull);
      expect(DataReferensi.cariKomoditas('Tomat'), isNotNull);
      expect(DataReferensi.cariKomoditas('Durian'), isNull);
    });

    test('Template jadwal perawatan komoditas terdefinisi dengan HST', () {
      final templatesPadi = DataReferensi.templateUntukKomoditas('Padi');
      expect(templatesPadi.isNotEmpty, isTrue);
      expect(templatesPadi.any((t) => t.namaKegiatan.contains('Pemupukan')), isTrue);

      final templatesJagung = DataReferensi.templateUntukKomoditas('Jagung');
      expect(templatesJagung.isNotEmpty, isTrue);
    });
  });

  group('PerawatanProvider State Management & Workflow Tests (Modul 3)', () {
    late PerawatanProvider provider;
    late Lahan dummyLahan;

    setUp(() {
      provider = PerawatanProvider();
      dummyLahan = Lahan(
        idLahan: 101,
        namaLahan: 'Lahan Riset Agrotek',
        luasLahan: 0.5,
        komoditasUtama: 'Padi',
        tanggalDibuat: DateTime(2026, 10, 1),
      );
    });

    test('FR-13: generateJadwalOtomatis menghasilkan jadwal dari template komoditas', () {
      provider.generateJadwalOtomatis(
        lahan: dummyLahan,
        komoditas: 'Padi',
        tanggalTanam: DateTime(2026, 10, 1),
      );

      expect(provider.jadwalList.isNotEmpty, isTrue);
      expect(provider.jadwalList.first.idLahan, equals(dummyLahan.idLahan));
      expect(provider.jadwalList.first.isOtomatis, isTrue);
      expect(provider.jumlahBelum, equals(provider.jadwalList.length));
    });

    test('FR-13: sesuaikanTanggalTanam menyesuaikan jadwal belum selesai dan mempertahankan jadwal selesai saat tanggal tanam berubah', () {
      final tglTanamAwal = DateTime(2026, 10, 1);
      provider.generateJadwalOtomatis(
        lahan: dummyLahan,
        komoditas: 'Padi',
        tanggalTanam: tglTanamAwal,
      );

      // Ambil jadwal pertama dan tandai selesai
      final jadwalPertama = provider.jadwalList.first;
      final tglPelaksanaanPertamaAwal = jadwalPertama.tanggalPelaksanaan;
      provider.tandaiSelesai(jadwalPertama.id);
      expect(provider.jumlahSelesai, equals(1));

      // Ambil jadwal kedua (masih berstatus belum)
      final jadwalKedua = provider.jadwalList[1];
      final hstKedua = jadwalKedua.hstPengingat!;

      // Simulasikan perubahan tanggal tanam (misal mundur 5 hari: 6 Oktober 2026)
      final tglTanamBaru = DateTime(2026, 10, 6);
      provider.sesuaikanTanggalTanam(
        idLahan: dummyLahan.idLahan,
        tanggalTanamBaru: tglTanamBaru,
      );

      // 1. Jadwal yang sudah selesai TIDAK boleh berubah tanggalnya
      final jadwalPertamaSetelah = provider.jadwalList.firstWhere((j) => j.id == jadwalPertama.id);
      expect(jadwalPertamaSetelah.status, equals(StatusPelaksanaan.selesai));
      expect(jadwalPertamaSetelah.tanggalPelaksanaan, equals(tglPelaksanaanPertamaAwal));

      // 2. Jadwal yang belum selesai HARUS disesuaikan mengikuti tanggal tanam baru + HST
      final jadwalKeduaSetelah = provider.jadwalList.firstWhere((j) => j.id == jadwalKedua.id);
      expect(jadwalKeduaSetelah.tanggalPelaksanaan, equals(tglTanamBaru.add(Duration(days: hstKedua))));
    });

    test('FR-13: CRUD manual jadwal (tambah, update, hapus)', () {
      final manualJadwal = JadwalPerawatan(
        id: 0,
        namaKegiatan: 'Penyiraman Khusus Pupuk Cair',
        idLahan: dummyLahan.idLahan,
        namaLahan: dummyLahan.namaLahan,
        jenisPerawatan: 'Penyiraman',
        tanggalPelaksanaan: DateTime(2026, 10, 20),
        tanggalDibuat: DateTime.now(),
      );

      provider.tambahJadwal(manualJadwal);
      expect(provider.jadwalList.length, equals(1));
      final idBaru = provider.jadwalList.first.id;

      // Update
      final updated = provider.jadwalList.first.copyWith(
        namaKegiatan: 'Penyiraman & Pengkabutan',
      );
      provider.updateJadwal(updated);
      expect(provider.jadwalList.first.namaKegiatan, equals('Penyiraman & Pengkabutan'));

      // Hapus
      provider.hapusJadwal(idBaru);
      expect(provider.jadwalList.isEmpty, isTrue);
    });

    test('FR-15: Update status pelaksanaan (Selesai, Ditunda, Reset ke Belum)', () {
      final jadwal = JadwalPerawatan(
        id: 0,
        namaKegiatan: 'Pemupukan Susulan I',
        idLahan: dummyLahan.idLahan,
        namaLahan: dummyLahan.namaLahan,
        jenisPerawatan: 'Pemupukan',
        tanggalPelaksanaan: DateTime(2026, 10, 15),
        tanggalDibuat: DateTime.now(),
      );
      provider.tambahJadwal(jadwal);
      final id = provider.jadwalList.first.id;

      // Tandai Selesai
      provider.tandaiSelesai(id);
      expect(provider.jadwalList.first.status, equals(StatusPelaksanaan.selesai));
      expect(provider.jumlahSelesai, equals(1));

      // Tandai Ditunda
      final tanggalBaru = DateTime(2026, 10, 25);
      provider.tandaiDitunda(id, tanggalBaru);
      expect(provider.jadwalList.first.status, equals(StatusPelaksanaan.ditunda));
      expect(provider.jadwalList.first.tanggalDitunda, equals(tanggalBaru));
      expect(provider.jumlahDitunda, equals(1));

      // Reset ke Belum
      provider.tandaiBelum(id);
      expect(provider.jadwalList.first.status, equals(StatusPelaksanaan.belum));
      expect(provider.jadwalList.first.tanggalDitunda, isNull);
      expect(provider.jumlahBelum, equals(1));
    });

    test('FR-16: hitungEstimasi sesuai rumus PRD (Luas ha × Produktivitas ton/ha)', () {
      // Contoh dari PRD 2.5.2:
      // Lahan Padi 0.5 ha -> 0.5 * 4.594 = 2.297 ton
      final estimasiPadi = PerawatanProvider.hitungEstimasi(
        komoditas: 'Padi',
        luasHa: 0.5,
      );
      expect(estimasiPadi, isNotNull);
      expect(estimasiPadi!, closeTo(2.297, 0.001));

      // Contoh dari PRD 2.5.2:
      // Lahan Cabai Merah 2 ha -> 2 * 10.62 = 21.24 ton
      final estimasiCabai = PerawatanProvider.hitungEstimasi(
        komoditas: 'Cabai Merah',
        luasHa: 2.0,
      );
      expect(estimasiCabai, isNotNull);
      expect(estimasiCabai!, closeTo(21.24, 0.001));

      // Komoditas tidak terdaftar mengembalikan null
      final estimasiTidakAda = PerawatanProvider.hitungEstimasi(
        komoditas: 'Kopi Luwak',
        luasHa: 1.0,
      );
      expect(estimasiTidakAda, isNull);
    });
  });
}
