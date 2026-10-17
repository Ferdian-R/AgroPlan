import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Utilitas transisi rute khusus AgroPlan yang mulus, dinamis, dan elegan.
class AgroPlanRouteTransitions {
  AgroPlanRouteTransitions._();

  /// Transisi geser horizontal mulus ala iOS / Material 3 yang modern.
  /// Layar baru bergeser dari kanan ke kiri dengan kurva lembut.
  static Route<T> slideHorizontal<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 380),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnim = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final fadeAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        );

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: child,
          ),
        );
      },
    );
  }

  /// Transisi geser ke atas (Slide Up) yang sangat elegan saat masuk ke Beranda.
  /// Memberikan kepuasan visual yang jelas dan responsif saat pengguna menekan "Masuk".
  static Route<T> slideUp<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 450),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnim = Tween<Offset>(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: child,
          ),
        );
      },
    );
  }

  /// Transisi Fade sinematik yang lembut (misal dari Splash ke Login).
  static Route<T> crossFade<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
