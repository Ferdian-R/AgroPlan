import 'package:flutter/material.dart';

/// Konstanta spacing, radius, dan ukuran untuk AgroPlan.
/// Memastikan tidak ada hardcoded dimensi di dalam widget UI.
class AppSpacing {
  AppSpacing._();

  // --- Spacing & Padding ---
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p14 = 14.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p28 = 28.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;

  // Screen Padding
  static const double screenPadding = 16.0;
  static const double authCardPaddingHorizontal = 23.0;
  static const double authCardPaddingVertical = 28.0;

  // Grid Gap
  static const double menuGap = 12.0;

  // --- Border Radius ---
  static const double radiusAuthCard = 30.0;
  static const double radiusInput = 20.0;
  static const double radiusAuthButton = 10.0;
  static const double radiusCard = 12.0;
  static const double radiusButton = 12.0;
  static const double radiusPhoto = 8.0;
  static const double radiusChip = 8.0;
  static const double radiusMenuIcon = 8.0;
  static const double radiusCircleButton = 28.0;

  // BorderRadius instances
  static const BorderRadius roundedAuthCard = BorderRadius.all(Radius.circular(radiusAuthCard));
  static const BorderRadius roundedInput = BorderRadius.all(Radius.circular(radiusInput));
  static const BorderRadius roundedAuthButton = BorderRadius.all(Radius.circular(radiusAuthButton));
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius roundedButton = BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius roundedPhoto = BorderRadius.all(Radius.circular(radiusPhoto));
  static const BorderRadius roundedChip = BorderRadius.all(Radius.circular(radiusChip));
  static const BorderRadius roundedMenuIcon = BorderRadius.all(Radius.circular(radiusMenuIcon));

  // --- Fixed Component Dimensions ---
  static const double buttonHeight44 = 44.0;
  static const double buttonHeight48 = 48.0;
  static const double minTouchTarget = 48.0;
  static const double headerHeight = 64.0;
  static const double bottomNavHeight = 64.0;
  static const double threeDotSize = 28.0;
  static const double avatarSize = 40.0;
}
