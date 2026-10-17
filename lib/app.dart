import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/lahan_repository.dart';
import 'data/laporan_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/lahan_provider.dart';
import 'providers/laporan_provider.dart';
import 'providers/perawatan_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/main_shell.dart';
import 'screens/perawatan/estimasi_panen_screen.dart';
import 'screens/perawatan/jadwal_list_screen.dart';
import 'screens/lahan/tambah_lahan_screen.dart';
import 'screens/lahan/daftar_lahan_screen.dart';
import 'screens/laporan/riwayat_laporan_screen.dart';
import 'screens/laporan/tambah_laporan_screen.dart';
import 'screens/panduan/panduan_tanam_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

/// Root Widget aplikasi AgroPlan.
/// Mengonfigurasi Provider, Tema, dan Rute Navigasi.
class AgroPlanApp extends StatelessWidget {
  final String initialRoute;

  const AgroPlanApp({
    super.key,
    this.initialRoute = '/splash',
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider autentikasi
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Provider manajemen lahan (Modul 1)
        ChangeNotifierProvider(
          create: (_) => LahanProvider(
            repository: MockLahanRepository(),
          ),
        ),
        // Provider monitoring kondisi lahan (Modul 2)
        ChangeNotifierProvider(
          create: (_) => LaporanProvider(
            repository: MockLaporanRepository(),
          ),
        ),
        // Provider jadwal perawatan & estimasi panen (Modul 3)
        ChangeNotifierProvider(
          create: (_) => PerawatanProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'AgroPlan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Alur pengguna dimulai dari layar Splash Screen pada root '/'
        initialRoute: initialRoute,
        routes: {
          '/': (context) => const SplashScreen(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainShell(),
          '/home': (context) => const HomeScreen(),
          '/jadwal-perawatan': (context) => const JadwalListScreen(),
          '/estimasi-panen': (context) => const EstimasiPanenScreen(),
          '/tambah-lahan': (context) => const TambahLahanScreen(),
          '/daftar-lahan': (context) => const DaftarLahanScreen(),
          '/laporan-kondisi': (context) => const RiwayatLaporanScreen(),
          '/tambah-laporan': (context) => const TambahLaporanScreen(),
          '/panduan-tanam': (context) => const PanduanTanamScreen(),
        },
        // Fallback jika terjadi rute yang tidak dikenal di browser
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}
