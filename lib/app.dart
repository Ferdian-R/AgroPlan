import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/lahan_repository.dart';
import 'providers/lahan_provider.dart';
import 'screens/lahan/daftar_lahan_screen.dart';
import 'theme/app_theme.dart';

/// Root Widget aplikasi AgroPlan - Practical Challenge (Modul 1: Manajemen Lahan).
/// Branch: jilpuy_practical
class AgroPlanApp extends StatelessWidget {
  const AgroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LahanProvider(
        repository: MockLahanRepository(),
      ),
      child: MaterialApp(
        title: 'AgroPlan - Kelola Lahan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Langsung membuka layar daftar lahan untuk demo workflow Modul 1
        home: const DaftarLahanScreen(),
        routes: {
          '/lahan': (context) => const DaftarLahanScreen(),
        },
      ),
    );
  }
}
