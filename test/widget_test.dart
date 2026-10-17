import 'package:flutter_test/flutter_test.dart';
import 'package:agroplan/app.dart';
import 'package:agroplan/screens/splash/splash_screen.dart';

void main() {
  testWidgets('AgroPlan smoke test - menampilkan layar Splash Screen', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan (default initialRoute: /splash)
    await tester.pumpWidget(const AgroPlanApp());
    await tester.pump();

    // Verifikasi SplashScreen aktif
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('AgroPlan smoke test - menampilkan layar Masuk', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan langsung ke /login
    await tester.pumpWidget(const AgroPlanApp(initialRoute: '/login'));
    await tester.pump();

    // Verifikasi keberadaan komponen utama layar Masuk
    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('AgroPlan smoke test - menampilkan layar Daftar', (WidgetTester tester) async {
    // Bangun aplikasi AgroPlan langsung ke /register
    await tester.pumpWidget(const AgroPlanApp(initialRoute: '/register'));
    await tester.pump();

    // Verifikasi keberadaan komponen utama layar Daftar
    expect(find.text('Buat Akun AgroPlan'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi'), findsOneWidget);
    expect(find.text('Daftar'), findsWidgets);
    expect(find.text('Sudah punya akun? '), findsOneWidget);
  });
}
