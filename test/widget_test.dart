import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/app.dart';

void main() {
  testWidgets('AgroPlan smoke test - menampilkan layar Masuk', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan
    await tester.pumpWidget(const AgroPlanApp());
    await tester.pump();

    // Verifikasi keberadaan komponen utama layar Masuk
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });
}
