import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/lahan_repository.dart';
import 'data/laporan_repository.dart';
import 'providers/lahan_provider.dart';
import 'providers/laporan_provider.dart';
import 'screens/laporan/riwayat_laporan_screen.dart';
import 'theme/app_theme.dart';

/// Root Widget aplikasi AgroPlan - Practical Challenge (Modul 2: Pelaporan Kondisi Lahan).
/// Branch: adin_practical
class AgroPlanApp extends StatelessWidget {
  const AgroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LahanProvider(
            repository: MockLahanRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LaporanProvider(
            repository: MockLaporanRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AgroPlan - Laporan Kondisi Lahan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Langsung membuka layar riwayat laporan kondisi untuk demo workflow Modul 2
        home: const RiwayatLaporanScreen(),
        routes: {
          '/laporan': (context) => const RiwayatLaporanScreen(),
          '/laporan-kondisi': (context) => const RiwayatLaporanScreen(),
        },
      ),
    );
  }
}
