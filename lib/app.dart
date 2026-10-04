import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/lahan_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/lahan_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Root Widget aplikasi AgroPlan.
/// Mengonfigurasi Provider, Tema, dan Rute Navigasi.
class AgroPlanApp extends StatelessWidget {
  const AgroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
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
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}