import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/app.dart';

void main() {
  testWidgets('AgroPlan smoke test - verifikasi layar Daftar Lahan & form Tambah Lahan Baru', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan
    await tester.pumpWidget(const AgroPlanApp());
    await tester.pumpAndSettle();

    // Verifikasi keberadaan AppBar judul dan FAB
    expect(find.text('Daftar Lahan'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Tambah Lahan'), findsOneWidget);

    // Tap tombol FAB "Tambah Lahan" untuk membuka form TambahLahanScreen
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi bahwa navigasi berhasil masuk ke Form Tambah Lahan
    expect(find.text('Tambah Lahan Baru'), findsOneWidget);
    expect(find.text('Nama Lahan *'), findsOneWidget);
    expect(find.text('Luas Lahan (Hektar) *'), findsOneWidget);
    expect(find.text('Komoditas Utama *'), findsOneWidget);
    expect(find.text('Jenis Tanah *'), findsOneWidget);
    expect(find.text('Lokasi Lahan *'), findsOneWidget);

    final simpanButton = find.widgetWithText(FilledButton, 'Simpan Lahan');
    expect(simpanButton, findsOneWidget);

    // Scroll hingga tombol Simpan terlihat dalam viewport
    await tester.ensureVisible(simpanButton);
    await tester.pumpAndSettle();

    // Verifikasi validasi form ketika tombol Simpan ditekan tanpa input
    await tester.tap(simpanButton);
    await tester.pumpAndSettle();

    expect(find.text('Nama lahan wajib diisi'), findsOneWidget);
  });
}
