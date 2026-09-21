import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/lahan_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/lahan_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

/// Root Widget aplikasi AgroPlan.
/// Mengonfigurasi Provider, Tema, dan Rute Navigasi.
class AgroPlanApp extends StatelessWidget {
  const AgroPlanApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'AgroPlan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Alur pengguna dimulai dari layar Masuk sesuai User Flow PRD 2.4
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainShell(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
