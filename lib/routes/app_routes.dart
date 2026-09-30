import 'package:flutter/material.dart';
import '../models/lahan.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main_shell.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String main = '/main';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case main:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Lahan) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(lahan: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        // <String> karena layar ini mengembalikan teks saat ditutup
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
