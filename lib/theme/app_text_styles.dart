import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Gaya tipografi AgroPlan berbasis Google Fonts (Inter & Plus Jakarta Sans).
class AppTextStyles {
  AppTextStyles._();

  // --- Auth Styles ---
  static TextStyle get authTitle => GoogleFonts.inter(
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: 25 * 0.05, // 0.05em
        color: AppColors.authPrimary,
      );

  static TextStyle get authInput => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 14 * 0.05,
        color: AppColors.textPrimary,
      );

  static TextStyle get authHint => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 14 * 0.05,
        color: AppColors.authTextHint,
      );

  static TextStyle get authButton => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 14 * 0.05,
        color: Colors.white,
      );

  static TextStyle get authFooter => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 14 * 0.05,
        color: AppColors.textPrimary,
      );

  static TextStyle get authFooterLink => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 14 * 0.05,
        color: AppColors.authPrimary,
      );

  // --- Header & Hero Styles ---
  static TextStyle get appName => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get appTagline => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get greeting => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get taglineHero => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // --- Section & Common Styles ---
  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get linkSection => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get chipText => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get locationText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bottomNavLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get weatherTemp => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get weatherSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
