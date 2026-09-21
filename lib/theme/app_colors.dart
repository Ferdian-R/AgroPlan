import 'package:flutter/material.dart';

/// Palet token warna AgroPlan berdasarkan desain Figma dan PRD.
///
/// Catatan desain:
/// - Terdapat 2 varian hijau:
///   1) [authPrimary] (#247B2C) untuk layar Masuk & Daftar.
///   2) [primary] (#0F5238) untuk Beranda (Home) dan tombol utama Home.
/// - Tab navigasi aktif menggunakan [primaryNav] (#2D6A4F).
class AppColors {
  AppColors._();

  // --- Auth Colors (Masuk & Daftar) ---
  static const Color authBackground = Color(0xFFF9F6ED);
  static const Color authPrimary = Color(0xFF247B2C);
  static const Color authInputFill = Color(0x73D9D9D9); // rgba(217, 217, 217, 0.45)
  static const Color authInputBorder = Color(0xFFE2E2E2);
  static const Color authTextHint = Color(0xB3000000); // rgba(0, 0, 0, 0.7)

  // --- Home & General Brand Colors ---
  static const Color homeBackground = Color(0xFFF8FAF6);
  static const Color primary = Color(0xFF0F5238);
  static const Color primaryNav = Color(0xFF2D6A4F);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color surface = Color(0xFFFFFFFF);

  // --- Chip Komoditas ---
  static const Color chipGreenBg = Color(0xFFE8F5E9);
  static const Color chipGreenText = Color(0xFF0F5238);
  static const Color chipGreyBg = Color(0xFFE7E9E5);
  static const Color chipGreyText = Color(0xFF404943);

  // --- Menu Utama Cards ---
  static const Color menuCardFirst = Color(0xFFE8F5E9);
  static const Color menuCard = Color(0x80C1ECD4); // rgba(193, 236, 212, 0.5)
  static const Color menuIconOverlay = Color(0xCCFFFFFF); // putih 80%

  // --- Utility & Status Icons ---
  static const Color iconMuted = Color(0xFF707973);
  static const Color badgeRed = Color(0xFFE53935);
  static const Color weatherSun = Color(0xFFFBC02D);
  static const Color weatherIconBg = Color(0xFFF2F4F0);
  static const Color divider = Color(0xFFE1E3DF);
  static const Color error = Color(0xFFD32F2F);
}
