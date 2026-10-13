import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/app.dart';

void main() {
  testWidgets('AgroPlan smoke test - verifikasi layar Riwayat Laporan & form Lapor Kondisi', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan
    await tester.pumpWidget(const AgroPlanApp());
    await tester.pumpAndSettle();

    // Verifikasi keberadaan AppBar judul dan FAB
    expect(find.text('Laporan Kondisi Lahan'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Lapor Kondisi'), findsOneWidget);

    // Tap tombol FAB "Lapor Kondisi" untuk membuka form TambahLaporanScreen
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi bahwa navigasi berhasil masuk ke Form Lapor Kondisi
    expect(find.text('Lapor Kondisi Lahan'), findsWidgets);
    expect(find.text('Lahan Yang Diamati *'), findsOneWidget);
    expect(find.text('Jenis Kondisi Tanaman *'), findsOneWidget);
    expect(find.text('Tingkat Keparahan *'), findsOneWidget);
    expect(find.text('Catatan Observasi Lapangan *'), findsOneWidget);

    final kirimButton = find.widgetWithText(ElevatedButton, 'Kirim Laporan Kondisi');
    expect(kirimButton, findsOneWidget);

    // Scroll hingga tombol Kirim terlihat dalam viewport
    await tester.ensureVisible(kirimButton);
    await tester.pumpAndSettle();

    // Verifikasi validasi form ketika tombol Kirim ditekan tanpa input
    await tester.tap(kirimButton);
    await tester.pumpAndSettle();

    expect(find.text('Catatan observasi wajib diisi'), findsOneWidget);
  });
}
